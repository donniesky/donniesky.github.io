---
layout:     post
title:		"RxJava和DiffUtil的组合使用"
subtitle:   "RxJava和DiffUtil的巧妙组合使用。"
date:       2017-08-29 16:48:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-211838.jpg"
tags:
    - Android
    - DiffUtil
    - RxJava2
    - RecyclerView
    - 译文
---

[翻译原文链接](https://hellsoft.se/a-nice-combination-of-rxjava-and-diffutil-fe3807186012)

`DiffUtil`工具类已经出来很久了，今天就来熟悉一下`DiffUtil`。使用`DiffUtil`只需要实现一个回调，该回调会将新的数据与就得数据进行比较，然后再讲比较后的结果传给`Adapter`适配器上，实现如下：
```java
public class MyCallback extends DiffUtil.Callback {

    private List<Thing> mOldList;
    private List<Thing> mNewList;

    public OverDiffCallback(List<Thing> oldList, List<Thing> newList) {
        mOldList = oldList;
        mNewList = newList;
    }

    @Override
    public int getOldListSize() {
        return mOldList != null ? mOldList.size() : 0;
    }

    @Override
    public int getNewListSize() {
        return mNewList != null ? mNewList.size() : 0;
    }

    @Override
    public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
        return mNewList.get(newItemPosition).getId().equals(mOldList.get(oldItemPosition).getId());
    }

    @Override
    public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
        return mNewList.get(newItemPosition).equals(mOldList.get(oldItemPosition));
    }
}
```
通过`DiffUtil.calculateDiff`比较后的DiffResult对象，将更改后的数据分配给`RecyclerView`的适配器：
```java
DiffResult diffResult = DiffUtil.calculateDiff(new MyDiffCallback(current, next), true);
diffResult.dispatchUpdatesTo(adapter);
```
但是，使用它也是很有挑战性的，当我们的数据量特别大的时候或者我们在对比数据比较复杂的时候，这时我们就要避免在主线程上使用`DiffUtil`，当然解决方案就可以将方法移动到后台线程中进行。

到了这里，我们可能会发现一个棘手的地方，因为`DiffUtil`的比较需要新的和旧的数据源，所以我们还需要访问后台线程获取到之前的旧数据，比如可以通过适配器获取旧数据，这也就意味着我们需要从多个线程中访问数据，因此我们可能需要一些同步或线程安全的数据结构，那我们能如何避免这种情况呢？

看到这，大家可能已经猜到了，使用`RxJava`, 各种数据的终极解决方案。
假设我们有一个`Flowable<List<Thing>> listOfThings`，`RecyclerView`可以通过它显示最新的数据列表，我们可以在`IO`线程或`computation`线程订阅它来确保完成任何任务都不会阻塞主线程，然后观察主线程上的任务事件，也就是将数据传递给适配器的任务事件：
```java
 Repo.latestThings(2, TimeUnit.SECONDS)
                .subscribeOn(computation())
                .observeOn(mainThread())
                .subscribe(things -> {
                    adapter.setThings(things);
                    adapter.notifyDataSetChanged();
                });
```
上面的代码显示了如何确保我们的数据在`computation`线程中完成复杂的操作，并且可以通过切换到主线程来调用适配器的`notifyDataSetChanged()`。这样做很有效果，但是看起来并不是很好，因为每个新列表都会重新绘制（这也就是为什么我们需要调用其他类似的notify的方法来通知更新）。

为了使用`DiffUtil`，我们需要调用`calculateDiff()`方法，并将`DiffResult`与最新的`List<Thing>`一起传递给`Subscription`。一个简单的方法就是使用`Pair`类，这是支持库中一个简单而强大的类，因此，我们可以更改订阅的接收类型为`Pair<List<Thing>, DiffResult>` : 
```java
.subscribe(listDiffResultPair -> {
  List<Thing> nextThings = listDiffResultPair.first;
  DiffUtil.DiffResult diffResult = listDiffResultPair.second;
  adapter.setThings(nextThings);
  diffResult.dispatchUpdatesTo(adapter);
});
```
## `scan()`
传递给`DiffUtil.calculateDiff()`的回调需要新的和旧的数据源才能生效，我们如何确保我们每次从数据源得到新列表的时候也能获取到上一次旧的数据源？这时候`RxJava`就派上用场了，`RxJava`中最神秘的运算符就是`scan()`, `scan()`可以给我们返回上一个和下一个的事件，并将其传递给我们的函数来返回下一个需要传递的事件。`scan()`的初始值将会是一个空集合和DiffResult组成的`Pair`。

我们现在就可以调用`calculateDiff()`方法，并将结果传给`Pair`集合中，我们使用其返回的结果来构建新的`Pair`，注意，我们在此方法中还并未在传入`Pair`中使用`DiffResult`。

还有一件需要考虑的事情就是，如果我们认为这样就大功告成了，那当`DiffResult`为null（从初始值）的时候第一个事件将包含一个`Pair`，所以此时我们还在在订阅中进行空检查判断，但是由于此事件和我们刚开始时的事相同的空列表，所以我们可以使用`skip(1)`运算符来简单的跳过它，这将忽略第一个事件的执行方法。

```java
List<Thing> emptyList = new ArrayList<>();
adapter.setThings(emptyList);
Pair<List<Thing>, DiffUtil.DiffResult> initialPair = Pair.create(emptyList, null);
Repo
  .latestThings(2, TimeUnit.SECONDS)
  .scan(initialPair, (pair, next) -> {
    MyDiffCallback callback = new MyDiffCallback(pair.first, next);
    DiffUtil.DiffResult result = DiffUtil.calculateDiff(callback);
    return Pair.create(next, result);
  })
  .skip(1)
```

大功告成！配合使用`RxJava`我们没必要考虑适配器保存的当前数据的任何同步和并发，可以观看一下示例演示：
![zpn](https://user-images.githubusercontent.com/8588940/29812063-05ac3598-8cd8-11e7-9aee-9d83455e9782.gif)

# 如果数据来的太快？
如果事件的发射速度比我们处理的要更快，如果`DiffUtil`计算比较数据需要几秒时间，并且我们得到的数据量比这些数据快。这时候我们就需要考虑`RxJava`的背压（back pressure），使用`RxJava2`我们可以使用`Flowable`而不是`Observable`，并可以选择配置适用于我们情况的背压策略。