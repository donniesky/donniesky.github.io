---
layout:     post
title:		"初识ConstraintLayout之尺寸（Dimension）"
subtitle:   "长宽比固定的视图"
date:       2017-09-07 16:47:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-493057.jpg"
tags:
    - Android
    - 译文
    - ContraintLayout
---
> [翻译原文链接](https://constraintlayout.github.io/basics/dimensions.html)

# 尺寸

有时候我们需要一些创建长宽比固定的视图，其中在`ImageView`展示有固定长宽比图片的时候尤其有用，例如，包裹书的艺术封面（它有多种多样的长宽比，所以我们可以暂时忽略），电影海报（通常比例为4:6），电影剧照（通常为1.85:1或2.39:1）或电视剧照（通常为4:3或16:9）。

对于不熟悉什么是横纵比的，横纵比就是表示了 View 的宽度与高度的比例 `w:h` 。例如，对于一个拥有横纵比为 `4:6` 拥有宽度为 `40dp` 的 View 组件有着高度是 `60dp` ，若它的宽度改为 `30dp` 则它的高度就是 `45dp` 。

如果我们的图片能保证具有相同的纵横比和物理尺寸，那么我们在布局的时候可以简单地使用`wrap_content`来表达。然而现实情况总由于数学四舍五入等多种原因都有可能造成一些小误差。如果我们只有一个单独的图片，那这通常很难看出一些误差，但如果我们是需要显示多个图片，那么这些图片大小上的差异将会产生很大的干扰，并且那些与图片对齐的视图将很容易的反映出这些差异，即使微小的差异也会让布局看起来非常不平衡。

有一种解决方案就是`ImageView`的子类重写`onMeasure()`方法去申请一个固定的长宽比；最近的`PercentLayout`（支持库）提供了一种可以固定子视图长宽比的机制。

`ConstraintLayout`也提供了一个固定子视图长宽比的机制，选择要控制的子视图，然后设置比例值（圆圈）：

![dimension](https://user-images.githubusercontent.com/8588940/30152453-bbc665e2-93e5-11e7-95db-932d0cbdd825.png)

从上图可知，我们的`ImageView`基于父视图的`start`和`top`分别有一个约束，`end`边缘的约束则是指向参考线，`bottom`未添加约束，`ImageView`的`layout_width`和`layout_height`都设置为`match_constraint`，意味着它们会跟着约束的变化而变化。`ImageView`的宽度在布局期间就已经确定，但是高度看起来似乎还未确定，其实由于长宽比值得确定（15:9），完全可以由宽度进行函数计算得出高度值。

最后，如果视图的宽度发生变化，那么高度也会随之而变化，我们可以通过移动`end`边缘与参考线之间的约束来证明这一点：

![dimension_change](https://user-images.githubusercontent.com/8588940/30153292-b4701718-93e8-11e7-977e-f4a88370dec8.gif)

# XML中使用尺寸长宽比

```xml
<?xml version="1.0" encoding="utf-8"?>
<android.support.constraint.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    app:layout_behavior="@string/appbar_scrolling_view_behavior">

    <android.support.constraint.Guideline
        android:id="@+id/guideline1"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:orientation="vertical"
        app:layout_constraintGuide_percent="0.5"/>

    <ImageView
        android:id="@+id/imageView"
        android:layout_width="0dp"
        android:layout_height="0dp"
        android:layout_marginEnd="0dp"
        android:layout_marginStart="16dp"
        android:layout_marginTop="16dp"
        app:layout_constraintDimensionRatio="15:9"
        app:layout_constraintEnd_toStartOf="@+id/guideline1"
        app:layout_constraintHorizontal_bias="0.5"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent"/>

</android.support.constraint.ConstraintLayout>
```

`app:layout_constraintDimensionRatio="15:9"`表示设置视图的长宽比，其中属性值包括两部分：方向和比率，可以省略方向值。

还有一点值得一提的是，`match_constraint`（我们前面看到的`layout_[width|height]`属性）实际上在XML表示：0dp，这就像`LinearLayout`的`weight`属性一样，在XML中设置为`0dp`，而实际上其大小会根据父view在布局过程中的大小来决定。


