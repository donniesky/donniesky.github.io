---
layout:     post
title:		"monkeyrunner"
subtitle:   "monkeyrunner工具提供了一个API，使用此API写出的程序可以在Android代码之外控制Android设备和模拟器。"
date:       2017-07-26 16:38:00
author:     "donnieSky"
catalog:	true
header-img: "img/wallhaven-470315.png"
tags:
    - Android
    - Testing
    - monkeyrunner
---

# monkeyrunner
`monkeyrunner`工具提供了一个API，使用此API写出的程序可以在Android代码之外控制Android设备和模拟器。通过`monkeyrunner`，我们可以写出一个`Python`程序去安装一个Android应用程序或测试包，并运行应用程序或测试包，向它发送模拟点击事件、截取用户交互界面，将截图存储在工作站上。`monkeyrunner`工具的主要设计目的是用来测试功能或框架级别的应用程序和设备，或用于运行单元测试套件，当然也是可以用于其他目的的。

`monkeyrunner`工具与上一篇博文的M`onkey`工具是不相关的。`Monkey`工具是在`adb shell`环境下运行的，是直接对设备或模拟器发送用户和系统事件的伪随机流。相对而言，`monkeyrunner`工具是通过API控制设备并仿真发送特定命令和事件。

`monkeyrunner`工具提供以下针对Android测试所独特的功能：

- 多设备控制：
  - `monkeyrunner`API可以跨多个设备或模拟器来实现测试套件，可以在同一时间连上所有设备或一次启动全部模拟器，根据程序依次连接到模拟器，然后运行一个或多个测试。也可以通过程序去启动一个配置好的模拟器，并运行一个或多个测试，然后关闭模拟器；
- 功能测试：
  - `monkeyrunner`可以为一个应用自动贯彻一次从开始到完成的功能测试，通过提供按键或触摸事件的具体数值，然后观察输出结果的截图；
- 回归测试：
  - `monkeyrunner`可以运行某个应用，并将其结果截图与既定已知正确的截图相比较，以此测试应用的稳定性；
- 可扩展的自动化：
  - 由于`monkeyrunner`是一个API工具包，我们可以基于`python`模块可程序来开发一整套系统，以此来控制Android设备。除了使用`monkeyrunner`API之外，我们还可以使用标准的`Python os`和`subprocess`模块来调用`Android Debug Bridge`这样的Android工具。

`monkeyrunner`工具使用`Jython`来实现控制，`Jython`是一种使用`Java`编程语言的`Python`实现。`Jython`允许`monkeyrunner`API与Android框架轻松交互，使用`Jython`，我们可以使用`Python`语法访问API常量、类和方法。


# 一个简单的`monkeyrunner`程序

以下是一个简单的`monkeyrunner`程序，主要实现了以下功能：连接设备、创建一个`MonkeyDevice`对象。使用`MonkeyDevice`对象，安装一个Android应用程序包，运行其中一个Activity，并将触摸事件传递给这个Activity。保存测试结果的截图，创建`MonkeyImage`对象，使用该对象将结果截图保存。

```monkeyrunner
# 导入monkeyrunner应用程序接口MonkeyRunner, MonkeyDevice  
from com.android.monkeyrunner import MonkeyRunner, MonkeyDevice
    
# 连接当前设备，并创建MonkeyDevice对象
device = MonkeyRunner.waitForConnection()
    
# 安装apk.该方法返回值类型为布尔型
# 查看应用是否安装成功  
device.installPackage('myproject/bin/MyApplication.apk')
    
# 设置一个变量用来保存apk的内部名称  
package = 'com.example.android.myapplication'
    
# 设置一个变量用来保存apk中的Activity名称  
activity = 'com.example.android.myapplication.MainActivity'
    
# 设置一个变量用来保存开始活动的运行组件名称
runComponent = package + '/' + activity
    
# 运行指定组件（打开Activity页面）
device.startActivity(component=runComponent)
    
# 按下菜单按钮
device.press('KEYCODE_MENU', MonkeyDevice.DOWN_AND_UP)
    
# 截图
result = device.takeSnapshot()
    
# 保存截图至指定文件夹
result.writeToFile('myproject/shot1.png','png')
```

# monkeyrunner API

monkeyrunner API包含`com.android.monkeyrunner`包中三个模块：

- `MonkeyRunner`:
  - 包含monkeyrunner一些常用方法的一个类。这个类给monkeyrunner提供连接设备或模拟器的方法，还提供创建用户界面和用于显示内置帮助的方法；
- `MonkeyDevice`：
  - 表示一个设备或模拟器。这个类提供了安装和卸载软件包的方法，还提供启动Activity并向应用程序发送键盘或相关触摸事件的方法，也可以使用此类来运行测试包；
- `MonkeyImage`：
  - 表示捕捉屏幕图像。这个类提供了用于捕获屏幕、转换图片格式、比较两个`MonkeyImage`对象以及将图像写入文件的方法。

在一个`Python`的程序代码中，我们可以访问`Python`模块中的每个类，但是monkeyrunner工具并不会自动导入某些模块，要导入某个模块，需使用`Python from`语句：
```monkeyrunner
from com.android.monkeyrunner import <module>
```
其中`module`是要导入的类名，我们可以在同样的`from`语句后通过使用逗号来分隔模块名称。


# 运行monkeyrunner

我们可以从文件中运行`monkeyrunner`程序，也可以在交互式会话中输入`monkeyrunner`语句。通过调用SDK目录中的`tools/`子目录中打开monkeyrunner命令行窗口，如果提供一个文件名作为参数，那么monkeyrunner命令将以Python程序的形式运行该文件的内容，否则将启动一个交互式会话窗口。

monkeyrunner命令的语法如下：

    monkeyrunner -plugin <plugin_jar> <program_filename> <program_options>

标识及相关参数的解释如下表：

| 参数                     | 说明                                                                  |
| ---------------------- | ------------------------------------------------------------------- |
| `-plugin <plugin_jar>` | （可选）指定包含monkeyrunner插件的.jar文件。要指定多个文件，请多次包含该参数。                    |
| `<program_filename>`   | 如果提供此参数，则monkeyrunner命令将以Python程序的形式运行该文件的内容。如果未提供参数，则该命令将启动交互式会话。 |
| `<program_options>`    | （可选）在<program_file>程序中的标志和参数。                                       |

# monkeyrunner内置帮助

我们可以通过运行以下命令为monkeyrunner生成相关API参考内容：
```monkeyrunner
monkeyrunner help.py <format> <outfile>
```
参数：

- `<format>`标识可以是纯文本输入或HTML输出；
- `<outfile>`输出到指定路径下的文件中。


# 扩展monkeyrunner插件

我们可以使用Java编程语言编写的类来扩展monkeyrunner的API，并构成一个或多个.jar文件。可以使用此功能通过自己的写的类或扩展现有的类来扩展monkeyrunner API，也可以使用此功能来初始化monkeyrunner环境。

要为monkeyrunner提供插件，需使用`-plugin <plugin_jar>`参数来调用monkeyrunner命令。

在我们扩展的插件代码中，我们可以导入并扩展`com.android.monkeyrunner`中的主要monkeyrunner类`MonkeyDevice`、`MonkeyImage`和`MonkeyRunner`。

请注意，插件是不能访问Android SDK的，不能导入`com.android.app`包，因为monkeyrunner与设备或模拟器在相同API下会相互影响。


# 插件启动类

脚本开始处理之前，插件的.jar文件是可以指定实例化的类，要指定该类，需添加键值`MonkeyRunnerStartupRunner`到.jar文件清单中，该value值需是类启动运行的名称。下面代码展示了怎么建立一个Ant脚本去实现上述功能：
```xml
<jar jarfile="myplugin" basedir="${build.dir}">
<manifest>
<attribute name="MonkeyRunnerStartupRunner" value="com.myapp.myplugin"/>
</manifest>
</jar>
```
要想访问monkeyrunner运行时的环境，启动类需实现`com.google.common.base.Predicate<PythonInterpreter>`，例如，在类默认的命名空间内设置相关变量：
```java
package com.android.example;
    
import com.google.common.base.Predicate;
import org.python.util.PythonInterpreter;
    
public class Main implements Predicate<PythonInterpreter> {
    @Override
    public boolean apply(PythonInterpreter anInterpreter) {
    
       /*
        * 在monkeyrunner环境命名空间zzho中,创建并初始化变量的实例
        * 在执行期间，monkeyrunner程序可以参考变量” newtest” 
        * 和"use_emulator"
        */
        anInterpreter.set("newtest", "enabled");
        anInterpreter.set("use_emulator", 1);
    
        return true;
    }
}
```