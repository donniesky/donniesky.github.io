---
layout:     post
title:		"初识ConstraintLayout之链"
subtitle:   "链是一种特殊的约束。"
date:       2017-09-01 11:41:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-69737.jpg"
tags:
    - Android
    - ContraintLayout
---

> [翻译原文链接](https://constraintlayout.github.io/basics/create_chains.html)

# 什么是链
链是一种特殊的约束，它允许我们在链中的`View`之间共享空间，并控制`View`之间的空间分配。Android中`LinearLayout`中的`weights`与链有些相似之处，但链能做到更多。

## 创建一条链
正如我们上面所提到的，链是由多个`View`组成的，因此，要创建一条链，我们必须选中我们希望链接在一起的`View`，然后选择`Center` --> `Center Horizontally` 创建一个水平链条，或者选择-->`Center Vertically`创建一个垂直链条，让我们来创建一个水平链条：

![chains](https://user-images.githubusercontent.com/8588940/29916276-db4f6366-8e70-11e7-973d-3a7ef7c2d874.gif)

值得一提的是，链条末端的两个`View`(在这种情况下是最左边和最右边的`View`)已经和父布局有一个分别来自左边缘和右边缘的约束。链的创建简单的定义了链成员之间的相互关系，通过刚刚我们创建的链可以很清晰的解释这些：

![chain_con](https://user-images.githubusercontent.com/8588940/29916346-127d0708-8e71-11e7-9623-067861dc756b.png)

首先注意，视图之间的两个类似链条的链接（这就是我们创建的链约束），外部的两个链接（父布局与最左边和最右边之间的链接）类似于弹簧。这些最外部的链接表示已经应用于链的`链模式`，`链模式`指定链条如何填充可用空间，我们可以使用`循环链模式`按钮在三种可用模式之间循环，该按钮显示在链的所有成员下方：

![mode](https://user-images.githubusercontent.com/8588940/29916833-9313434a-8e72-11e7-8672-a7c999c7299c.png)

一共有三种可用的模式：`spread`，`spread_inside`和`packed`。

### 扩展链（Spread Chain）
`spread`是默认的模式，它可以在可以的空间内衣均匀的间隔在链中放置所有`View`：

![spread](https://user-images.githubusercontent.com/8588940/29917285-14c86a9a-8e74-11e7-978e-36f6364a4145.png)

### 内部扩展链（Spread Inside Chain）
`spread_inside`模式将链中最外层的`View`放置在外边缘，然后在可用空间内以相等的间隔放置链中的其余`View`:

![spread_inside](https://user-images.githubusercontent.com/8588940/29917612-110f2e7e-8e75-11e7-8452-ba28ec7194ab.png)

### 包裹链（Packed Chain）
`packed`模式将所有`View`集中在一起（可以提供边距来稍微分开`View`之间的距离），然后将集中后的一组`View`居中放置在可用空间内：

![packed](https://user-images.githubusercontent.com/8588940/29917787-99fde8ba-8e75-11e7-9195-091a153fd45e.png)

使用包裹链可以通过改变`bias`值来进一步控制包裹后`View`的布局位置，在以上例子中，`bias`值为0.5，代表居中的意思，但改变这个值可以改变包裹链的位置：

![packed_mode](https://user-images.githubusercontent.com/8588940/29918067-9607e0a2-8e76-11e7-9f89-38bb28c6cd15.gif)

### 扩展链权重（Spread Chain Weights）
扩展链和内部扩展链的一个非常有用的功能就是我们可以将权重应用于链的各个成员，并且和`LinearLayout`中的权重非常相似。目前视图编辑器中没有直接设置的方法，但我们可以在属性视图中手动更改属性：

![chain_weight](https://user-images.githubusercontent.com/8588940/29953765-5b0a94f6-8f05-11e7-8765-607ff1837b83.png)

要给特定的`View`添加权重，我们必须首先在编辑器中选择`view`，然后（如果`View`是在水平链中）指定`android:layout_width="0dp"`和`app:layout_constraintHorizontal_weight="1"`：

![attribute](https://user-images.githubusercontent.com/8588940/29953832-eac3f04c-8f05-11e7-98f3-ce1147ff0cad.png)

请注意加权重后`View`的变化：顶部和底部边缘从直线变成了手风琴样式，这使加权重`View`有了更直观的显示。

值得注意的是，如果我们尝试在包裹模式下添加权重，这将不会很好使，包裹模式会尝试将`View`包裹在尽可能小的空间内，而扩展和内部扩展模式将根据需要来使用尽可能多的空间。如果尝试在包裹链中使用权重，则加权重的`View`将缩小到0：

![packed_weight](https://user-images.githubusercontent.com/8588940/29954304-76a89e2a-8f09-11e7-84e4-07f460f0fbda.png)

# 在XML中使用链
有时候我们会在想，在XML中应该存在专有的属性来表示链，但事实并非如此：现有的约束属性都被合并了，为了在XML中创建链，链条约束是简单的双向互补约束。下面就是我们所提到的在XML中创建链：

```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.constraint.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:layout_editor_absoluteX="0dp"
    tools:layout_editor_absoluteY="25dp">

    <TextView
        android:id="@+id/textView1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginStart="16dp"
        android:layout_marginTop="16dp"
        android:text="Hello World!"
        app:layout_constraintEnd_toStartOf="@+id/textView2"
        app:layout_constraintHorizontal_bias="0.5"
        app:layout_constraintHorizontal_chainStyle="spread"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"/>

    <TextView
        android:id="@+id/textView2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="16dp"
        android:text="Hello World!"
        app:layout_constraintEnd_toStartOf="@+id/textView3"
        app:layout_constraintHorizontal_bias="0.5"
        app:layout_constraintStart_toEndOf="@+id/textView1"
        app:layout_constraintTop_toTopOf="parent"
        tools:layout_editor_absoluteX="154dp"/>

    <TextView
        android:id="@+id/textView3"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginEnd="16dp"
        android:layout_marginTop="16dp"
        android:text="Hello World!"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintHorizontal_bias="0.5"
        app:layout_constraintStart_toEndOf="@+id/textView2"
        app:layout_constraintTop_toTopOf="parent"/>

</android.support.constraint.ConstraintLayout>
```

在`textView1`中有`app:layout_constraintEndToStartOf="@+id/textView2"`，并且在`textView2`中有`app:layout_constraintStart_toEndOf="@+id/textView1"`，基本上可以看出在这两个`View`右边缘和左边缘的锚点之间创建了两个约束，而这就是链的定义方法。

在`textView1`中我们可以看到有`app:layout_constraintHorizontal_chainStyle="spread"`，它指定了扩展模式，我们可以手动修改为：`spread_inside`或`packed`来指定不同的链模式。**注意我们必须只在链中的第一个`View`是使用该属性**。

`app:layout_constraintHorizontal_bias="0.5"`的设置区间为`0.0-1.0`。

最后，我们可以通过指定`android:layout_width="0dp"`和`app:layout_constraintHorizontal_weight="1"`来定义权重。
