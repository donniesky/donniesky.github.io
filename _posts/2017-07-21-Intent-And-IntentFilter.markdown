---
layout:     post
title:		"初识Intent和IntentFilter"
subtitle:   "初识Intent和IntentFilter"
date:       2017-07-21 16:45:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-11493.jpg"
tags:
    - Android
    - Intent
    - IntentFilter
---

# 初识Intent和IntentFilter

`Intent`是一个消息传递对象，可以使用它请求其他应用组件，也可以通过多种方式促进组件之间的通信，但基本的用处有以下几个：
* 启动`Activity`：
    * `Activity`表示应用中的一个页面，通过将`Intent`传递给`startActivity()`，可以启动新的`Activity`实例，`Intent`描述了要启动的`Activity`，并携带了所需的数据；
    * 如果希望启动`Activity`完成后收到结果，可调用`startActivityForResult()`，在`Activity`的`onActivityResult()`回调中，`Activity`将结果作为单独的`Intent`对象接收。
* 启动服务：
    * `Service`是一个没有用户交互界面且在后台执行操作的组件，通过将`Intent`传递给`startService()`，可以启动服务执行一次性操作（如：下载文件），`Intent`描述了要启动的服务，并携带了任何必要的数据；
    * 如果`Service`需要操作客户端至服务器接口，则可通过将`Intent`传递给`bindService()`，可以从其他组件绑定到此服务。
* 发送广播：
    * 广播是任何应用均可接收得消息，系统将针对系统事件（例如：系统启动或设备开始充电时）传递各种广播，通过将`Intent`传递给`sendBroadcast()`、`sendOrderBroadcast()`或`sendStickyBroadcast()`可以将广播传递给其他应用。

## Intent类型

intent分为两种类型：
* 显式Intent：按类名指定要启动的组件，通常我们会在自己的应用中使用显式Intent来启动组件，这是因为我们知道需启动的Activit或Service的类名；
* 隐式Intent：不指定特定的组件，而是声明需要执行的操作，从而允许其他应用中的组件来处理它。

创建显式Intent启动Activity或服务时，系统将立即启动Intent对象中知道的应用组件;
创建隐式Intent时，Android系统通过将Intent的内容与设备上其他应用的清单文件中声明的IntentFilter进行比较，从而找到要启动的相应组件，如果Intent与IntentFilter匹配，则系统将启动该组件，并向起传递Intent对象，如果与多个IntentFilter匹配，则系统会显示一个对话框供永固选择需要使用的应用。

IntentFilter是应用清单文件中的一个表达式，它指定该组件要接收得Intent类型，例如：通过为Activity声明IntentFilter，我们可以使其他应用能够直接使用某一特定类型的Intent来启动Activity，同样，如果没有为Activity声明任何IntentFilter，则Activity只能通过显式Intent启动；

> 注意：为了确保应用的安全性，启动Service时，必须使用显式Intent，不能为Service声明IntentFiliter，使用隐式Intent启动Service存在安全隐患，因为我们无法确定哪些服务将响应Intent，且用户无法看到哪些服务已经启动（从Android5.0【API21】开始，如果使用隐式Intent调用`bindService()`，系统会引发异常）。

以下为隐式Intent通过系统传递来启动其他Activity的图解：
![intent-filters 2x](https://user-images.githubusercontent.com/8588940/28451212-8a446dc6-6e1e-11e7-9216-aca52fc96b19.png)
1. Activity A 创建包含操作描述的Intent，并将其传递给`startActivity()`；
2. Android系统搜索所用应用中与Intent匹配的IntentFilter；
3. 匹配成功后，系统通过调用匹配的Activity B的`onCreate()`方法并将其传递给`Intent`来启动Activity B。

## 构建Intent

Intent对象携带了Android系统用来确定要启动哪个组件的信息（例如：准确的组件名称或需要接受该Intent的组件类型），以及接收者组件为了正确执行操作而使用的信息（例如：需要采取的操作以及要处理的数据）。

Intent中主要包含以下信息：

* #### 组件名称(componentName)
    * 要启动组件的名称，这是可选项，但也是构建显式Intent的一项重要信息，这表示Intent应当传递有组件名称的应用组件，如果没有组件名称，则Intent是隐式的，并且系统将根据其他Intent信息决定哪个组件应当接受该Intent，因此，如果需要在应用中启动特定的组件，则应指定该组件的名称；
    * > 注：启动Service时，应该始终指定组件名称，否则将无法确定哪项服务会响应Intent，且用户无法看到哪项服务已启动。
    * Intent是一个ComponentName对象，可以使用目标组件的完全限定类名指定此对象，其中包括软件名称，例如：`com.example.ExampleActivity`，可以使用`setComponent()`、`setClass()`、`setClassName()`或Intent构造函数设置组件名称。
* #### 操作(action)
    * 指定要执行的通用操作的字符串；
    * 对于广播Intent，这是指已发生且正在发送的操作，操作在很大程度上决定了其余Intent的构成，特别是data和extra中包含的内容；
    * 可以自定义操作供应用内使用（或者供其他应用在我们的应用中调用组件），但是通常应该使用由Intent类或其他框架类定义的操作常量，一下是一些常用启动Activity的操作：
    * ACTION_VIEW
        * 如果有一Activity需向用户展示信息（例如，要使用图库应用查看图片或使用地图应用查看地址），这就需要使用Intent将此操作与`startActivity()`结合使用；
    * ACTION_SEND
        * 也称`共享`Intent，如果用户需通过应用（例如：邮件应用或社交应用）共享数据，这就需要使用Intent将此操作与`startActivity()`结合使用；
    * 可以使用`setAction()`或`Intent`构造函数为Intent指定操作；
    * 如果自定义action，确保将应用的软件包名称作为前缀，如：
```java
  static final String ACTION_TIMETRAVEL = "com.example.action.TIMETRAVEL";
```
* #### 数据(data)
    * 应用带操作数据及该数据MIME类型的URI（Uri对象），提供的数据类型通常由Intent 的action决定，例如：如果action为ACTION_EDIT，则该数据应包含待编辑文档的URI；
    * 创建intent时，除了指定URI以外，指定数据类型（MIME类型）往往也很重要，它有助于Andriod系统找到接收该Intent的最佳组件，但有时，MIME类型也可以从URI中推断得出，特别当数据是`content:`时，这表示数据位于设备中，且由`ContentProvider`控制，使得数据MIME类型对系统可见;
    * 仅设置数据URI的话，调用`setData()`;仅设置MIME类型的话，调用`setType()`；有必要的话，也可以使用`setDataAndType()`同时设置前面两个；
    * > 注意： 若要同时设置URI和MIME类型，那就不能再调用`setData()`和`setType()`，因为他们会相互抵消彼此的值，只使用`setDataAndType()`就可以了。
* #### 类别(category)
    * 一个包含应处理 Intent 组件类型的附加信息的字符串，可以将任意数量的类别描述放入一个Intent中，单大多数Intent均不需要类别，一下是一些常见类别：
    * CATEGORY_BROWSABLE
        * 目标 Activity 允许本身通过网络浏览器启动，以显示链接引用的数据，如图像或电子邮件；
    * CATEGORY_LAUNCHER
        * 该Activity是应用的初始Activity，在系统的应用启动器中列出；
    * 可以使用`addCategory()`指定类别

以上列出的这些属性（组件名称、操作、数据和类别）表示 Intent 的既定特征。 通过读取这些属性，Android 系统能够解析应当启动哪个应用组件。

但是Intent也可能会携带些不影响其如何解析应用组件的信息：
* #### Extra
    * 携带完成请求操作所需的附加信息的键值对，正如某些操作使用特定类型的数据 URI 一样，有些操作也使用特定的 extra；
    * 使用各种`putExtra()`方法添加extra数据，每种方法均接受两个键值对参数，还可以创建一个包含所有extra数据的`Bundle`对象，可以使用`putExtras()`将`Bundle`插入Intent中，例如：使用`ACTION_SEND`创建用于发送电子邮件的Intent时，可以使用`EXTRA_EMAIL`键指定目标收件人，并使用`EXTRA_SUBJECT`键指定主题；
    * `Intent`类将为标准化的数据类型指定多个 EXTRA_* 常量。如需声明自己的 extra 键（对于应用接收的 Intent），请确保将应用的软件包名称作为前缀。 例如：
```java 
    static final String EXTRA_GIGAWATTS = "com.example.EXTRA_GIGAWATTS";
```
* #### 标志(Flag)
    * flag可以指定Android系统如何启动Activity（例如，activity应属于哪个task），以及启动后应如何处理（例如，它是否属于同一个activity栈）。
    
## 显式Intent示例

```java
// Executed in an Activity, so 'this' is the Context
// The fileUrl is a string URL, such as "http://www.example.com/image.png"
Intent downloadIntent = new Intent(this, DownloadService.class);
downloadIntent.setData(Uri.parse(fileUrl));
startService(downloadIntent);
```

## 隐式Intent示例

隐式 Intent 指定能够在可以执行相应操作的设备上调用任何应用的操作。 如果您的应用无法执行该操作而其他应用可以，且您希望用户选取要使用的应用，则使用隐式 Intent 非常有用。

例如，如果您希望用户与他人共享您的内容，请使用 ACTION_SEND 操作创建 Intent，并添加指定共享内容的 extra。 使用该 Intent 调用 startActivity() 时，用户可以选取共享内容所使用的应用。

> 注意：可能没有任何应用会处理发送到 `startActivity()` 的隐式 Intent。如果出现这种情况，则调用将会失败，且应用会崩溃。要验证 Activity 是否会接收 Intent，需对 Intent 对象调用 `resolveActivity()`。如果结果为非空，则至少有一个应用能够处理该 Intent，且可以安全调用 `startActivity()`。 如果结果为空，则不应使用该 Intent。如有可能，您应停用发出该 Intent 的功能。

```java
// Create the text message with a string
Intent sendIntent = new Intent();
sendIntent.setAction(Intent.ACTION_SEND);
sendIntent.putExtra(Intent.EXTRA_TEXT, textMessage);
sendIntent.setType("text/plain");

// Verify that the intent will resolve to an activity
if (sendIntent.resolveActivity(getPackageManager()) != null) {
    startActivity(sendIntent);
}
```

> 注：在这种情况下，系统并没有使用 URI，但已声明 Intent 的数据类型，用于指定 extra 携带的内容。

调用 `startActivity()` 时，系统将检查已安装的所有应用，确定哪些应用能够处理这种 Intent（即：含 `ACTION_SEND` 操作并携带`text/plain`数据的 Intent ）。 如果只有一个应用能够处理，则该应用将立即打开并为其提供 Intent。 如果多个 Activity 接受 Intent，则系统将显示一个对话框，使用户能够选取要使用的应用。

## 强制使用应用选择器

如果有多个应用响应隐式 Intent，则用户可以选择要使用的应用，并将其设置为该操作的默认选项。 如果用户可能希望今后一直使用相同的应用执行某项操作（例如，打开网页时，用户往往倾向于仅使用一种网络浏览器），则这一点十分有用。

但是，如果多个应用可以响应 Intent，且用户可能希望每次使用不同的应用，则应采用显式方式显示选择器对话框。 选择器对话框每次都会要求用户选择用于操作的应用（用户无法为该操作选择默认应用）。 例如，当应用使用 ACTION_SEND 操作执行“共享”时，用户根据目前的状况可能需要使用另一不同的应用，因此应当始终使用选择器对话框，如下图中所示：
![intent-chooser](https://user-images.githubusercontent.com/8588940/28453504-424333e8-6e2a-11e7-8057-1685ee2fd943.png)
要显式选择器，需使用`crateChooser()`创建Intent，并将其传递给`startActivity`，如：

```java
Intent sendIntent = new Intent(Intent.ACTION_SEND);
...

// Always use string resources for UI text.
// This says something like "Share this photo with"
String title = getResources().getString(R.string.chooser_title);
// Create intent to show the chooser dialog
Intent chooser = Intent.createChooser(sendIntent, title);

// Verify the original intent will resolve to at least one activity
if (sendIntent.resolveActivity(getPackageManager()) != null) {
    startActivity(chooser);
}
```

这将显示一个对话框，其中有响应传递给`createChooser()`方法的Intent的应用列表，并将提供的文本用作对话框标题。

## 接收隐式Intent

应用需接收哪些隐式Intent，需在清单文件中使用`<intent-filter>`元素为每个应用组件声明一个或多个IntentFilter，每个IntentFilter均可根据Intent的action、data和category指定自身需接收的Intent类型，仅当隐式Intent可以匹配成功其中一个IntentFilter时，系统才会将该Intent传递给应用组件。

> 注：显式Intent始终会传递Intent给目标组件，无论组件是否声明IntentFilter。

应用需为自身可执行的每个独特功能声明单独的IntentFilter，例如，图像库应用中的一个 Activity 可能会有两个过滤器，分别用于查看图像和编辑图像。 当 Activity 启动时，它将检查 Intent 并根据 Intent 中的信息决定具体的行为（例如，是否显示编辑器控件）。

每个IntentFilter均由应用清单文件中的`<intent-filter>`元素定义，并嵌套在相应的应用组件（如：`<activity>`元素）中，在`<intent-filter>`内部，可以使用以下三个元素中的一个或多个来指定要接收得Intent类型：
* `<action>`
    * 在`name`属性中，声明接受的Intent操作，该值是个字符串，且严格区分大小写，Intent中的action必须和过滤规则中的action完全一致才能匹配成功，可以有多个action，但是Intent中的action只需要与其中之一相同即可匹配成功；
* `<data>`
   * 使用一个或多个指定数据URI和MIME类型的属性，如：
      ```java
         <data android:scheme="string"
                    android:host="string"
                    android:port="80"
                    android:path="/string"
                    android:pathPattern="string"
                    android:pathPrefix="/string"
                    android:mimeType="text/plain"/>
      ```
    总的来说data包含两部分：mimeType和URI。
1. mimeType表示image/ipeg,video/*等媒体类型
2. URI信息量相对大一点，其结构一般为：`<scheme>://<host>:<port>/[<path>|<pathPrefix|<pathPattern>>]`
    下边讲分别来介绍下各个节点数据的含义:
    1. scheme：整个URI的模式，如常见的http，file等，注意如果URI中没有指定的scheme，那么整个uri无效
    2. host：URI的域名，比如我们常见的www.mi.com,www.baidu.com，与scheme一样，一旦没有host那么整个URI也毫无意义；
    3. port：端口号，比如80，很容易理解，只有在URI中指定了scheme和host之后端口号才是有意义的；
    4. path，pathPattern，pathPrefix包含路径信息，path表示完整的路径，pathPattern在此基础上可以包含通配符，pathPrefix表示路径的前缀信息；
* `<category>`
    * 在`name`属性中，声明接受的Intent类别，值为字符串；
    * 匹配规则中必须添加`android.intent.category.DEFAULT`这个过滤条件，
    * Intent中可以不设置category，这个时候在使用`startActivity()`或者`startActivityForResult()`的时候，其实系统会自动会添加`android.intent.category.DEFAULT`，但隐式Intent无法解析该Activity;

```java
<activity android:name="ShareActivity">
    <intent-filter>
        <action android:name="android.intent.action.SEND"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <data android:mimeType="text/plain"/>
    </intent-filter>
</activity>
```

匹配过滤列表时需要同时匹配过滤列表中的action，category，data；个过滤列表中可以有多个action，category，data并各自构成不同类别，一个Intent必须同时匹配action类别，category类别和data类别才算完全匹配；一个Activity中可以有多组intent-filter，一个Intent只要匹配任何一组intent-filter就算匹配成功。
> 注意：为了避免无意中运行不同应用的`Service`，仅能使用显式Intent启动服务，且不必为该服务声明IntentFilter。对于所有Activity，我们必须在清单文件中声明IntentFilter，但是，广播接收器的过滤器可以调用`registerReceiver()`动态注册，紧接着，使用`unregisterReceiver()`注销该接收器，这样一来，应用便可仅在应用运行时的某一指定时间段内监听特定的广播。

## IntentFilter示例

```java
<activity android:name="MainActivity">
    <!-- This activity is the main entry, should appear in app launcher -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>

<activity android:name="ShareActivity">
    <!-- This activity handles "SEND" actions with text data -->
    <intent-filter>
        <action android:name="android.intent.action.SEND"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <data android:mimeType="text/plain"/>
    </intent-filter>
    <!-- This activity also handles "SEND" and "SEND_MULTIPLE" with media data -->
    <intent-filter>
        <action android:name="android.intent.action.SEND"/>
        <action android:name="android.intent.action.SEND_MULTIPLE"/>
        <category android:name="android.intent.category.DEFAULT"/>
        <data android:mimeType="application/vnd.google.panorama360+jpg"/>
        <data android:mimeType="image/*"/>
        <data android:mimeType="video/*"/>
    </intent-filter>
</activity>
```
`MainActivity`是应用的主要入口点，当用户点击启动器图标启动应用时，该activity将打开：
`ACTION_MAIN`和`CATEGORY_LAUNCHER`必须配对使用，activity才会显示在应用启动器中。

## Intent匹配

`PackageManager`提供了一整套`query...()`方法来返回所有能够接受待定的Intent的组件，还提供了一系列`resolve...()`方法来确定响应Intent的最佳组件；例如，`queryIntentActivities()`将返回能执行作为参数传递的Intent的所有activity列表，而`queryIntentService()`则返回类似的服务列表，这两种方法均不会激活组件，而只是列出能够响应的组件；对于广播接收器，有一种类似的方法：`queryBroadcastReceivers()`。