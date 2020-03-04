---
layout:     post
title:		"初识ConstraintLayout之参照线（Guidelines）"
subtitle:   "一个参照线就是一个用来对齐其他视图且运行时隐藏的参照视图。"
date:       2017-09-01 16:21:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-155879.png"
tags:
    - Android
    - 译文
    - ContraintLayout
---

> [翻译原文链接](https://constraintlayout.github.io/basics/guidelines.html)

# 什么是参照线（Guidelines）

熟悉图形设计工具的设计人员可能对参照线并不陌生，但对于不是从事设计的人来说它可能有点陌生。一个参照线就是一个用来对齐其他视图且运行时隐藏的参照视图。这是一个抽象概念，但是一旦了解了它工作原理，那对于以后的布局将非常有用。`Material Design`推荐使用`keylines`。本篇文章学习如何通过参照线来快速实现这些。

参照线有水平和垂直之分。本篇文章将重点关注垂直参照线，但同时水平参照线的概念也与此相差无二。

# 创建一条参照线

要创建一个垂直参照线，我们可以通过右键点击蓝色视图并从上下文菜单中选择`Helpers` --> `Add Vertical Guideline`：

![guideline_ver](https://user-images.githubusercontent.com/8588940/29957304-56d6b47c-8f1f-11e7-9597-0182ae7f9c04.gif)

如果你创建参照线后无法看到，只需点击蓝色视图的任意位置即可看到它。

# 参照线的类型

参照线有三种不同的类型，默认的类型就是：参照线将于父布局（ConstraintLayout）的起始边缘有着固定的偏移量（单位为dp）。我们刚刚参加的垂直参照线与起始边缘的偏移量就为`20dp`，注意这里我们指的是起始边缘（start）而不是左边缘（left），因为对于从右向左的布局设置来说这是一个很好的用法。

第二种类型就是：参照线偏离`end`边缘；最后一种类型就是：根据父组件`ConstraintLayout`的宽度百分比来放置，在参照线边缘有个显示类型的指示器，我们可以通过重复点击这循环切换类型：

![guideline_type](https://user-images.githubusercontent.com/8588940/29957783-d2e0eb08-8f21-11e7-841c-622569e079b4.gif)

左偏移和右偏移对于设置`keylines`是非常有用的，而百分比形式的参照线则提供了类似于`PercentLayout`的一些功能。

# 调整参照线

一旦我们创建好了参照线，我们可以通过拖动线条来调整其位置（而不是拖动类型指示器）：

![guideline_type_drag](https://user-images.githubusercontent.com/8588940/29957979-ffd57a4c-8f22-11e7-9c53-e0aec7cd9bb9.gif)

# 使用参照线

到了现在，我们知道了如何创建不同类型的参照线并调整其位置，那我们还可以做些什么呢？
我们可以使用它了作为任何`View`视图的约束参照物，换句话来说，我们可以在布局中任何`View`视图的锚点上创建一个约束并将其与参照线对齐，如果移动参照线，`View`也将随之跟着移动：

![guideline_textview](https://user-images.githubusercontent.com/8588940/29958234-434e0248-8f24-11e7-9833-c9466809e5e8.gif)

该示例中参照线仅限制了单个视图，但如果参照线要对更多的视图进行限制，那通过移动参照线将导致所有的视图都随之移动。

# 参照线的原理

`Guideline`类实际上是`View`的子类，它的`onDraw()`方法为空方法，并且固定为`View.GONE`，应用运行的时候它将无法显示出来，但在布局阶段，它将显示出来，我们可以用它来对齐其它的`View`。所以参照线是一个非常轻量的组件：用户是无法看见它的，但我们却可以在布局中用它来参考位置。

# 在XML中创建参照线

```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.constraint.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <android.support.constraint.Guideline
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:id="@+id/guideline1"
        android:orientation="vertical"
        app:layout_constraintGuide_begin="41dp"/>

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World !"
        android:layout_marginTop="16dp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintStart_toStartOf="@+id/guideline1"
        android:layout_marginStart="8dp"/>

</android.support.constraint.ConstraintLayout>
```

从上可看出：有一个`app:orientation="vertical"`显然声明了一个垂直参照线，`app:layout_constraintGuide_begin="41dp"`表示参照线离父布局`ConstraintLayout`的起始位置为`41dp`，再次声明，是`start`而不是`left`。`app:layout_constraintGuide_end=""`表示相对于右边缘的距离，对于百分比参照线来说，使用`app:layout_constraintGuide_percent="0.5"`来描述百分比的偏移量。

从上面我们已经知道了参照线本身也是一个`View`，所以我们可以像`TextView`一样来向参照线添加约束。



