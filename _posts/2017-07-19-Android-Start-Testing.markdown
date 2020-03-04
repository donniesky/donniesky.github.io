---
layout:     post
title:		"Android测试入门"
subtitle:   "Android测试基于JUnit，我们可以将其作为JVM上的本地单元测试或Android设备上的模拟测试运行"
date:       2017-07-19 17:04:00
author:     "donnieSky"
catalog:	true
header-img: "img/post-bg-unix-linux.jpg"
tags:
    - Android
    - Testing
    - JUnit
---

# 测试入门
Android测试基于JUnit，我们可以将其作为JVM上的本地单元测试或Android设备上的模拟测试运行。

## 测试类型
当使用Android Studio编写任何测试代码时，测试代码必须放入两个不同的代码目录（源集合）中的一个。
对于项目中的每个模块，Android Studio都包含两个源集，对应于以下测试类型：

### 本地单元测试
位于`module-name/src/test/java/` .

这些测试在本地JVM上运行，无法访问功能性的Android框架API。

### 模拟测试
位于`module-name/src/androidtest/java/` .

这些测试都是必须在Android硬件设备或Android模拟器上运行的;

模拟测试内置在APK中，并在设备运行的同时测试程序，系统会在应用程序运行的同时测试APK，因此我们的测试可以调用应用程序中的方法和修改字段，并自动执行用户与应用程序的交互。

![test-types_2x](https://user-images.githubusercontent.com/8588940/28350338-f73fa9ae-6c7a-11e7-8c04-21ba3745b001.png)

<table>
    <tr>
        <td>类型 </td> 
        <td>子类型</td>
        <td>描述</td> 
   </tr>
    <tr>
        <td rowspan="2">单元测试</td>    
        <td >本地单元测试</td>  
        <td >单元测试可以在本地上运行Java虚拟机（JVM），当测试没有Android框架的依赖关系或者可以模拟Android框架的依赖性的时候它可以最大限度地减少执行时间</td>
    </tr>
    <tr>
        <td >模拟单元测试</td>  
        <td >在Android设备或模拟器上运行的单元测试。这些测试可以访问Instrumentation信息, 当您的测试具有模拟对象无法满足的Android依赖项时, 例如您正在测试的应用程序的Context, 请使用这些测试。</td>
    </tr>
<tr>
        <td rowspan="2">集成测试</td>    
        <td >应用程序中的组件</td>  
        <td >这种类型的测试将验证目标应用程序在用户执行特定操作或在其Activity中输入特定输入时的行为。例如，它允许您检查目标应用程序是否返回正确的UI输出以响应应用程序活动中的用户交互。像Espresso这样的UI测试框架允许您以编程方式模拟用户操作并测试复杂的应用内用户交互。</td>
    </tr>
    <tr>
        <td >跨应用程序组件</td>  
        <td >这种类型的测试验证不同用户应用之间或用户应用和系统应用之间的交互的正确行为。
例如，当用户在Android设置菜单中执行操作时，您可能需要测试应用程序的行为是否正确。
支持跨应用程序交互的UI测试框架（如UI Automator）允许您为这些场景创建测试。</td>
    </tr>
</table>
## JUnit
我们应该将单元或集成测试类写为JUnit 4测试类，该框架提供了常见测试的设置，拆卸和断言的便捷操作方式。

基础的JUnit 4测试类是包含一个或多个测试方法的Java类，测试方法以`@Test`注释开始，并包含用于运行和验证要测试的组件中的单个功能(即逻辑单元)的代码。

以下代码片段显示了使用Espresso API对UI元素执行点击操作的JUnit 4集成测试示例，然后检查以查看是否显示预期字符串。
```java
@RunWith(AndroidJUnit4.class)
@LargeTest
public class MainActivityInstrumentationTest {

    @Rule
    public ActivityTestRule mActivityRule = new ActivityTestRule<>(
            MainActivity.class);

    @Test
    public void sayHello(){
        onView(withText("Say hello!")).perform(click());

        onView(withId(R.id.textView)).check(matches(withText("Hello, World!")));
    }
}
```
在JUnit 4测试类中，我们可以使用以下注释来调用部分测试代码进行特殊处理：、
* `@Before` : 使用此注释来指定包含测试设置操作的代码块。测试类在每次测试之前都会调用这个代码块。
可以拥有多个`@Before`方法，但是不能保证测试类调用这些方法的顺序;
* `@After` : 此注释指定了一个包含测试拆除操作的代码块。测试类在每个测试方法后调用这个代码块。可以在测试代码中定义多个`@After`操作。用于清理测试环境数据。
* `@Test` : 使用此注释标记测试方法。单个测试类可以包含多个测试方法，每个测试方法都以此注释为前缀。
* `@Rule` : Rules允许我们以可重复使用的方式灵活地添加或重新定义每个测试方法的行为。在Android测试中，将此注释与Android测试支持库提供的一个测试规则类一起使用，例如`ActivityTestRule`或`ServiceTestRule`。
* `@BeforeClass` : 这个方法在所有测试开始之前执行一次，用于做一些耗时的初始化工作(如: 连接数据库)
* `@AfterClass` : 这个方法在所有测试结束之后执行一次，用于清理数据(如: 断开数据连接),此测试步骤对于释放在`@BeforeClass`块中分配的资源非常有用。
* `@Test(timeout=)` : 此注释支持传递设置值。例如，您可以指定测试的超时时间。如果测试启动但在给定的超时时间内未完成，则会自动失败。指定超时时间（以毫秒为单位），例如：@Test（timeout = 5000）。

使用JUnit Assert类验证对象状态的正确性。断言方法将比较测试中的值与实际结果进行比较，如果比较失败，则会抛出异常。[Assertion classes]()更详细地描述了这些方法。

## Android测试支持库
Android测试支持库提供了一组API，可让您快速构建和运行应用程序的测试代码，包括JUnit 4和功能UI测试。该库包括以下API，当您想自动执行测试时，这些API非常有用：
* AndroidJUnitRunner
    * 用于Android的JUnit 4兼容测试运行器
* Espresso
    * UI测试框架;适用于应用程序中的功能UI测试。
* UI Automator
    * 一款适用于系统和已安装应用程序之间的跨应用程序功能UI测试

## Assertion classes
由于Android测试支持库API扩展了JUnit，您可以使用断言方法来显示测试结果。断言方法将测试返回的实际值与预期值进行比较，如果比较测试失败，则会抛出AssertionException异常。使用断言比记录更方便，并提供更好的测试性能。

为了简化测试开发，推荐使用Hamcrest库，这样可以使用Hamcrest匹配器API创建更灵活的测试。

## Monkey and monkeyrunner
Android SDK包含两个功能级应用测试工具：
* Monkey
    * 这是一个命令行工具，它向设备发送按键，触摸和手势的伪随机流。您可以使用Android Debug Bridge（adb）工具运行它，并使用它来进行应用程序的压力测试得到人工未检出的错误，或者通过使用相同的随机数字种子多次运行该工具来重复事件流。
* monkeyrunner
    * 该工具测试程序的API和执行环境是用Python编写的。API包括连接到设备，安装和卸载软件包，截取屏幕截图，比较两个映像以及针对应用程序运行测试包的功能。使用API​​，您可以编写大型，强大和复杂的测试。您可以使用monkeyrunner命令行工具运行使用API​​的程序