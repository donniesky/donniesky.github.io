---
layout:     post
title:		"初识ConstraintLayout之约束"
subtitle:   "创建约束是ConstrainLayout基本视图构建的一部分。"
date:       2017-08-31 16:00:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-124008.jpg"
tags:
    - Android
    - ContraintLayout
---

> [翻译原文链接](https://constraintlayout.github.io/basics/create_constraint.html)

# 什么是约束（Constraints）
创建约束是`ConstrainLayout`基本视图构建的一部分，约束定义了布局中两个视图组件之间的关系，并且控制这些视图组件在布局中的位置。对于`ConstrainLayout`的这些新特性，其实和`RelativeLayout`的约束原理是非常类似的。

## 在可视化编辑器中创建约束
学习如何创建约束的最简单的方法就是使用`Android Studio`中的可视化编辑器，我们首先来看一个有关`TextView`的简单例子：

![tx_con](https://user-images.githubusercontent.com/8588940/29909521-e22360d8-8e58-11e7-9686-2d06e290774d.png)

从上图可明显的看出，两个箭头表示的就是约束代表将左边缘和顶部对齐父组件`ConstrainLayout`，并分别都是16dp的边距，如果我们鼠标点击选中`TextView`，我们将看到有关尺寸和锚点：

![tx_size](https://user-images.githubusercontent.com/8588940/29909727-d62bd80e-8e59-11e7-8e52-6c9efc850631.png)

上图矩形的四个角(实心小正方形)代表尺寸的句柄，我们可以拖动它们来调整`TextView`的大小。但是这种方式并不是经常使用，最好的方式就是让`TextView`通过某种方式来进行响应改变大小。

每个边缘中间的圆是锚点，用于创建约束。左边和上边的锚点包含一个实心圆代表此锚点已经定义了约束，而另外两个空心圆锚点则代表未实现约束。由此我们可以通过顶部和左边缘与父布局对齐来定义`TextView`的位置。

任何`TextView`的子类都将有一个附加类型的锚点：基线(baseline)。通过它我们在`TextView`中对齐文本的基线，可以点击`TextView`下方的`ab`按钮来查看：

![baseline](https://user-images.githubusercontent.com/8588940/29910400-6fe92cf6-8e5c-11e7-8f9d-331da0ff384b.png)

那个长椭形（香肠状）的就是基线的锚点，在基线上创建约束的方式和四个边缘锚点创建的方式是一样的。

`TextView`基线左边的按钮(包含`x`的按钮)将会删除所有的约束。

要创建约束，我们只需要抓住一个`View`上的锚点，并将其拖动到另一个`View`的锚点之上就行。这里我们在原来的例子中再添加一个`TextView`，它具有一个左边缘的约束对齐父布局，并且我们从第二个`TextView`的顶部创建一个约束拖动至第一个`TextView`的底部边缘的锚点上，这就使第二个`TextView`位于第一个`TextView`的下方：

![cons_2](https://user-images.githubusercontent.com/8588940/29910905-75a3f386-8e5e-11e7-904b-5aff68449b3f.gif)

有一点值得注意的是，虽然我们已经从`textView2`的顶部到`textView1`的底部创建了一个约束，但是如果我们选中两个`TextView`后仔细观察，我们会发现，`textView2`顶部已附加一个约束，但`textView1`却并没有约束（`textView1`的底部锚点还是空心的）：

![con_2_2](https://user-images.githubusercontent.com/8588940/29914700-11576792-8e6c-11e7-8717-b06fa0c38589.gif)

原因是因为约束是单一的约束（链（chains）是特殊的情况），所以在这个问题中，约束是附加给`textView2`的，并且它是相对于`textView1`来进行定位的，由于约束至附加到`textView2`，所以他对`textView1`的定位是没有直接的影响。

现在我们已经知道如何在`View`之间创建一个约束，那我们如何去在`View`与父布局之间创建约束呢？其实很简单，只需要将锚点拖动到父布局的边缘即可：

![parent_con](https://user-images.githubusercontent.com/8588940/29911665-471d3970-8e61-11e7-9f8f-0d16ae466c33.gif)

## 在XML中创建约束
具体代码如下：
```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.constraint.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"
        app:layout_constraintTop_toTopOf="parent"
        android:layout_marginTop="16dp"
        app:layout_constraintStart_toStartOf="parent"
        android:layout_marginStart="16dp"
        android:id="@+id/textView1"/>

    <TextView
        android:id="@+id/textView2"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"
        app:layout_constraintStart_toStartOf="parent"
        android:layout_marginStart="16dp"
        android:layout_marginTop="16dp"
        app:layout_constraintTop_toBottomOf="@+id/textView1"/>

</android.support.constraint.ConstraintLayout>
```

属性约束是以：`app:layout_constraint`开头的，从上图代码可看出，`ConstraintLayout`的所有子视图都是有相对于父布局的布局定位，还有`textView2`还指定了视图顶部相对于`textView1`底部定位的约束。

值得注意的是，它们都是在`app`的命名空间中，因为`ConstraintLayout`是作为库导入的。和支持库一样，它成为了我们应用程序中的一部分，而不是android框架的一部分（使用`android`命名空间）。

# 删除一个约束
最后介绍一下如何删除一个约束，如果是直接使用的XML，则只需要将属性本身删了即可。如果使用的是可视化编辑器，可以通过单击其锚点来删除某个约束：

![delete_con](https://user-images.githubusercontent.com/8588940/29912310-d72dad7c-8e63-11e7-887b-29465fb70bb9.gif)


