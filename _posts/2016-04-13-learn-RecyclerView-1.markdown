---
layout:     post
title:      "RecyclerView使用(一)"
subtitle:   "RecyclerView的简单介绍与使用"
date:       2016-04-13
author:     "donnieSky"
header-img: "img/post-bg-recyclerview-1.jpg"
catalog: true
tags:
    - Android
    - RecyclerView
---

# RecyclerView使用(一)

> A flexible view for providing a limited window into a large data set.
简单的意思就是：**`RecyclerView`能很灵活的利用有限的空间来显示大量的数据集**

----

## 简单介绍

刚开始学习RecyclerView的时候，其实发现它和`ListView`原理是相似的，但是`RecyclerView`却在很多地方都要比`ListView`要好的很多:

* 利用`LayoutManager`来确定item的排列方式（可以通过设置LayoutManager来快速实现ListView、`GridView`、瀑布流的效果）。

* 可为item的增加和删除定制动画效果，系统也具有默认的动画效果。

* RecycleView有自己的ViewHolder。

## 开始使用RecyclerView

### 1.在项目`build.gradle`文件中添加RecyclerView的依赖:

```java
dependencies{
    ......省略部分
    compile 'com.android.support:cardview-v7:23.3.0'         //这里使用CardView作为Item
    
    compile 'com.android.support:recyclerview-v7:23.3.0'
}
```

### 2.视图布局：

**RecyclerView布局：**

```java
<?xml version="1.0" encoding="utf-8"?>
<android.support.v7.widget.RecyclerView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/recycle_view"
    android:layout_centerVertical="true"
    android:layout_centerHorizontal="true"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:scrollbars="vertical"/>
```

**Item布局**

```java
<android.support.v7.widget.CardView
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_centerVertical="true"
    android:layout_margin="8dp"
    android:layout_width="match_parent"
    android:layout_height="wrap_content">

    <TextView
        android:id="@+id/text_view"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_margin="15dp"
        android:textSize="20sp"
        android:text="@string/app_name"/>

</android.support.v7.widget.CardView>
```

### 3.创建RecyclerView的适配器Adapter:

```java
public class MyRecyclerViewAdapter extends RecyclerView.Adapter<MyRecyclerViewAdapter.MyTextViewHolder>{

    private final LayoutInflater mLayoutInflater;
    private final Context mContext;
    private String[] mCountries;

    public MyRecyclerViewAdapter(Context context) {
        mCountries = context.getResources().getStringArray(R.array.countries);
        mContext = context;
        mLayoutInflater = LayoutInflater.from(context);
    }

    /**
     * 创建ItemView,被LayoutManager调用
     */
    @Override
    public MyTextViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new MyTextViewHolder(mLayoutInflater.inflate(R.layout.recyclerview_item,parent,false));
    }

    /**
     * 将数据与每个ItemView进行绑定操作
     */
    @Override
    public void onBindViewHolder(MyTextViewHolder holder, int position) {
        holder.mTextView.setText(mCountries[position]);
    }

    /**
     * 获取数据的数目
     */
    @Override
    public int getItemCount() {
        return mCountries == null ? 0 : mCountries.length;
    }

    //自定义ItemView的ViewHolder，它持有每个Item的所有节目元素
    public static class MyTextViewHolder extends RecyclerView.ViewHolder{

        @Bind(R.id.text_view)
        TextView mTextView;

        public MyTextViewHolder(View itemView) {
            super(itemView);
            ButterKnife.bind(this,itemView);
            //ItemView的点击事件
            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Log.d("MyRecyclerViewAdapter","onClick--> position = "+getAdapterPosition());
                }
            });
        }
    }

}
```

### 4.运行效果

> * 线性垂直布局`LinearLayoutManager`

```java
mRecyclerView.setLayoutManager(new LinearLayoutManager(this));
```

效果：

![img](/img/in-post/post-recyclerview-linearlayout.jpg)

> * 宫格布局显示`GridLayoutManager`:

```java
mRecyclerView.setLayoutManager(new GridLayoutManager(this,2));//显示两竖数据
```

效果：

![img](/img/in-post/post-recyclerview-gridlayout.jpg)

> * 瀑布流布局显示`StaggeredGridLayoutManager`:

```java
mRecyclerView.setLayoutManager(new StaggeredGridLayoutManager(2, OrientationHelper.VERTICAL));//垂直显示两竖数据
```

效果：
item中的数据长度加长的话，瀑布流的效果会很明显，可以忽略我的效果图；

![img](/img/in-post/post-recyclerview-staggered.jpg)