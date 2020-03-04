---
layout:     post
title:		"Android MVVM 「译」"
subtitle:   "以Android Data Binding library为基础来探索实现MVVM"
date:       2017-07-17 17:10:00
author:     "donnieSky"
catalog:	true
header-img: "img/post-bg-2015.jpg"
tags:
    - Android
    - MVVM
    - 译文
---

> 这篇文章来自[Zen Android MVVM - Medium](https://proandroiddev.com/zen-android-mvvm-160c26f3203c)

# Android MVVM
在Android应用程序中实现MVP模式的多种变化和迭代之后，我决定以Android Data Binding library为基础来探索实现MVVM, 之后的结果也是让我兴奋不已。

接下来我们的目标包括以下几点：
* MVVM单元中应该不包括ViewModel（VM），状态（M）和绑定的布局资源文件（V）；
* 每个MVVM单元应该是模块化和可嵌套的；
  * MVVM单元应该能够包含一个或多个子单元，这些单元又可以包含自己的子单元
* 不需要扩展 base Activity、Fragment或自定义视图；
* base ViewModel类可以接受和预期，但是它不会暴露出任何Android特定的依赖关系; 它应该可以使用vanilla JUnit来测试;
* 应注入所有ViewModel依赖项;
* ViewModel属性和方法的单向和双向数据绑定应从布局文件中声明完成；
* ViewModel并不知道它所需要支持那一个View，也不应该从 `android.view`或`android.widget`包中导入任何东西；
* ViewModel应该被自动绑定到其配对View的`attach` / `detach`生命周期中；
* ViewModel应该独立于Activity的生命周期，但应根据需要访问它；
* 无论采取单一或多种Activity的途径，该模式都必须工作。

## 首先
> 我选择了一些`low-hanging`的工具：`Toothpick`用于依赖注入，以及我自己的Okuki库用于`navigation`和`back-stack`管理。当然你可以使用Dagger2来替代依赖注入;对于导航，您可能更喜欢Intents，EventBus或其他一些自定义的导航管理机制。此外，您可能更喜欢使用Activity和Fragment进行堆栈管理。萝卜青菜各有所爱，不管大家用什么，我只建议您以集中和分离的方式自己解决这些问题，无论您选择MVP，MVVM还是任何其他UI架构。

*在本文末尾包括一个建议的方法来使用FragmentManager进行反向堆叠。*

## Base ViewModel and Lifecycle
有了依赖注入、导航和堆栈，我接下来将介绍如何定义一个基本ViewModel类和将其绑定到View attach / detach生命周期的相关机制。

首先，定义一个`ViewModel`的接口：
```java
public interface ViewModel {
       void onAttach();
       void onDetach();
}
```
接下来，我们利用Data Binding Library提供的`View.OnAttachStateListener`的绑定，并将`android：onViewAttachedToWindow`和`android：onViewDetachedFromWindow`属性映射到Base ViewModel中的相应方法。
完成这些步骤后，并将它们连接到ViewModel接口的onAttach和onDetach方法，从而从扩展类隐藏所需的View参数。
另外，我们集成了依赖注入和RxJava订阅的自动配置机制，我们也将其连接到View生命周期。

我们生成的BaseViewModel类看起来像这样：
```java
public abstract class BaseViewModel implements ViewModel {

    private final CompositeDisposable compositeDisposable = new CompositeDisposable();
    public BaseViewModel() {
        App.inject(this);
    }
    @Override
    public void onAttach() {
    }

    @Override
    public void onDetach() {
    }

    public final void onViewAttachedToWindow(View view) {
        onAttach();
    }

    public final void onViewDetachedFromWindow(View view) {
        compositeDisposable.clear();
        onDetach();
    }

    protected void addToAutoDispose(Disposable... disposables) {
        compositeDisposable.addAll(disposables);
    }

}
```
继承这个`BaseViewModel`的MyViewModel类 ，它只是将ViewModel绑定到布局，并将attach / detach属性映射到根ViewGroup，如下所示：
```xml
<layout xmlns:android="http://schemas.android.com/apk/res/android">
  <data>
    <variable name="vm" type="MyViewModel"/>
  </data>
<FrameLayout
  android:layout_width="match_parent"
  android:layout_height="match_parent"
  android:onViewAttachedToWindow="@{vm::onViewAttachedToWindow}"
  android:onViewDetachedFromWindow="@{vm::onViewDetachedFromWindow}"
>
</FrameLayout>
</layout>
```
## 模块化
现在我们有一个可以将ViewModel绑定到View及其生命周期的方法，需要以连贯和模块化的方式将MVVM单元加载到容器中。为此，我们来定义一个提供ViewModel和布局资源的映射接口：
```java
public interface MvvmComponent {
    int getLayoutResId();
    ViewModel getViewModel();
}
```
然后我们定义一个MvvmComponent的自定义数据绑定，提供的布局资源，并将其与ViewModel绑定，且加载到ViewGroup中：
```java
@BindingAdapter("component")
public static void loadComponent(ViewGroup viewGroup, MvvmComponent component) {
  ViewDataBinding binding = DataBindingUtil.inflate(LayoutInflater.from(viewGroup.getContext()), component.getLayoutResId(), viewGroup, false);
  View view = binding.getRoot();
  binding.setVariable(BR.vm, component.getViewModel());
  binding.executePendingBindings();
  viewGroup.removeAllViews();
  viewGroup.addView(view);
}
```
请注意，当我们执行`inflation`时，我们将`attachToParent`方法的参数设置为false，并在ViewModel绑定后执行`addView（view）`。这样做的原因是我们需要将`ViewMode`l绑定在inflated`View`附加之前，以便正确调用ViewModel的`onViewAttachedToWindow`方法。

现在我们可以利用这个新的绑定。在我们的布局中，通过添加新的组件属性来定义一个容器ViewGroup：
```xml
<layout xmlns:android="http://schemas.android.com/apk/res/android"
        xmlns:app="http://schemas.android.com/apk/res-auto">
  <data>
    <variable
      name="vm"
      type="MyViewModel"/>
  </data>
<FrameLayout
  android:id="@+id/main_container"
  android:layout_width="match_parent"
  android:layout_height="match_parent"
  android:onViewAttachedToWindow="@{vm::onViewAttachedToWindow}"
  android:onViewDetachedFromWindow="@{vm::onViewDetachedFromWindow}"
  app:component="@{vm.myComponent}"
/>
</layout>
```
在我们绑定的ViewModel中，我们使用一个ObservableField <MvvmComponent>来提供一种切换组件的方法：
```java
public class MyViewModel extends BaseViewModel {
  public final ObservableField<MvvmComponent> myComponent 
     = new ObservableField<>();

  @Override
  public void onAttach() {
    myComponent.set(new HelloWorldComponent("World"));
  }
}
```
`component`类本身从父ViewModel抽象布局资源ID和定义子ViewModel，从父ViewModel只接收初始化子ViewModel所需的数据：
```java
public class HelloWorldComponent implements MvvmComponent {
private final String name;
  
  public HelloWorldComponent(String name){
    this.name = name;
  }
  @Override
  public int getLayoutResId() {
    return R.layout.hello_world;
  }
  @Override
  public ViewModel getViewModel() {
    return new HelloWorldViewModel(name);
  }
}
```
现在可以根据ViewModel的状态轻松加载子`component`，而不需要ViewModel知道有关layout，Views或其他ViewModel的任何内容。

## Activity Lifecycle
按照原来的意图，我们的MVVM单元独立于活动生命周期。
但有时我们可能需要访问它。我们可能需要使用实例状态下的Bundle保存和恢复数据，或者我们可能需要响应暂停/恢复事件。当然这是是容易实现的。为此，只需将这些事件委托给实现`Application.ActivityLifecycleCallbacks`的单例，并将其注册到Application中。
`The singleton`然后可以通过侦听器或观察器公开事件，并注入到任何需要的ViewModel去访问它们。

## Using Fragments for back-stack
正如我们在这篇文章的开头提到的，我们使用一个自定义库来进行堆栈堆栈管理。但是，通过稍微调整上述代码，您可以改用Android的FragmentManager。要做到这一点，`MvvmComponent`接口还需要一些额外的方法：
```java
public interface MvvmComponent {
    int getLayoutResId();
    ViewModel getViewModel();
    String getTag();
    boolean addToBackStack();
}
```
接下来，创建一个Fragment来包装你的MVVM单元，如下所示：
```java
public class MvvmFragment extends Fragment {
  private int layoutResId;
  private ViewModel vm;
public MvvmFragment newInstance(int layoutResId, ViewModel vm){
    MvvmFragment fragment = new MvvmFragment();
    fragment.layoutResId = layoutResId;
    fragment.vm = vm;
    return fragment;
  }
@Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
    ViewDataBinding binding = DataBindingUtil.inflate(inflater, layoutResId, container, false);
    binding.setVariable(BR.vm, vm);
    binding.setVariable(BR.fm, getChildFragmentManager());
    return binding.getRoot();
  }
  public void setLayoutResId(int layoutResId){
    this.layoutResId = layoutResId;
  }
  public void setViewModel(ViewModel vm){
    this.vm = vm;
  }
}
```
请注意，我们的布局需要在容器ViewGroups上声明和设置为属性fm的数据变量。
另外，请注意我们的MvvmFragment的layoutResId和vm成员的配置更改和进程杀死的意义，并使您的Fragment参数正确化。

现在，我们可以修改自定义`component`绑定以使用MvvmFragment，而不是直接执行inflation和ViewModel绑定：
```java
@BindingAdapter({"component", "fm"})
public static void loadComponent(ViewGroup viewGroup, MvvmComponent component, FragmentManager fm) {
  MvvmFragment fragment = fm.findFragmentByTag(component.getTag()); 
  if(fragment == null) { 
    fragment = MvvmFragment.newInstance(component.getLayoutResId, component.getViewModel());
  }
  FragmentTransaction ft = beginTransaction();
  ft.replace(viewGroup.getId, fragment, component.getTag());
  if(component.addToBackStack()){
    ft.addToBackStack(component.getTag());
  }
  ft.commit();
}
```
## 代码示例
相关源码可查看[这里](https://github.com/wongcain/okuki/tree/master/okuki-sample-rx2-mvvm)

Happy coding !
