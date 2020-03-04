---
layout:     post
title:      "Android混淆"
subtitle:   "Android混淆简单介绍"
date:       2016-04-15
author:     "donnieSky"
header-img: "img/post-bg-proguard.jpg"
catalog: true
tags:
    - Android
    - ProGuard
---

# Android混淆

> 最近项目打包用到混淆出现了很多问题，查了很多资料，为了增强记忆，这次用博客汇总记录一下！

----

## 启用ProGuard

* 在app文件夹下`build.gradle`中进行配置,将`minifyEnabled`改为`true`：

```java
buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
```

如上代码所示，在`release`打包是就会按照我们`proguard-rules.pro`的配置进行混淆，在debug时是不会进行混淆的。

## 混淆ProGuard常用语法

后面的文件名，类名，或者包名等都可以使用占位符代替，`？`标示一个字符可以匹配多个字符，但如果是一个类，不会匹配其前面的包名，`*`可以匹配多个字符，会匹配前面的包名。

* **输入输出选项：**
    1. `-include filename`   从给定的文件中读取配置参数;
    2. `-injars class_path`   输入(即使用的)jar文件路径;
    3. `-outjars class_path`   输出jar路径;
    4. `-libraryjars class_path`   指定的jar将不被混淆;
    5. `-skipnonpubliclibraryclasses`   跳过(不混淆)jars中的非public classes;
    6. `-dontskipnonpubliclibraryclasses`   不跳过(混淆)jars中的非public classes默认选项;
    7. `-dontskipnonpubliclibraryclassmenbers`   不跳过jars中的非public classes的members;
    8. `-keepdirectories [directory_filter]`   指定目录keep在out jars中;
* **保持不变的选项(混淆不进行处理的内容):**
    1. `-keep {Modifier} {class_specification}`   保护指定的类文件和类的成员;
    2. `-keepclassmembers {modifier} {class_specification}`   保护指定类的成员，如果此类受到保护他们会保护的更好;
    3. `-keepclasseswithmembers {class_specification}`   保护指定的类和类的成员，但条件是所有指定的类和类成员是要存在;
    4. `-keepnames {class_specification}`   保护指定的类和类的成员的名称（如果他们不会压缩步骤中删除）;
    5. `-keepclassmembernames {class_specification}`   保护指定的类的成员的名称（如果他们不会压缩步骤中删除）;
    6. `-keepclasseswithmembernames {class_specification}`   保护指定的类和类的成员的名称，如果所有指定的类成员出席（在压缩步骤之后）;
    7. `-printseeds {filename}`   列出类和类的成员-keep选项的清单，标准输出到给定的文件;
* **压缩选项：**
    1. `-dontshrink`   不启用; shrink操作默认启用，主要的作用是将一些无效代码给移除，即没有被显示调用的代码;
    2. `-printusage {filename}`   打印被移除的代码，在标准输出;
    3. `-whyareyoukeeping {class_specification}`   打印在shrink过程中为什么有些代码被keep;
* **优化选项**
    1. `-dontoptimize`   不启用; shrink。shrink操作默认启用，主要的作用是将一些无效代码给移除，即没有被显示调用的代码；
    2. `-optimizations optimization_filter`   根据optimization_filter指定要优化的文件;
    3. `-optimizationpasses n`   优化数量n;
    4. `-assumenosideeffects class_specification`   优化时允许访问并修改类和类的成员的 访问修饰符，可能作用域会变大;
    5. `-mergeinterfacesaggressively`   合并接口，即使它们的实现类未实现合并后接口的所有方法;
* **混淆选项**
    1. `-dontobfuscate`   不混淆;
    2. `-printmapping [filename]`   打印 映射旧名到新名;
    3. `-applymapping filename`   打印相关;
    4. `-obfuscationdictionary filename`   指定外部模糊字典;
    5. `-classobfuscationdictionary filename`   指定class模糊字典;
    6. `-packageobfuscationdictionary filename`   指定package模糊字典;
    7. `-overloadaggressively`   过度加载，多个属性和方法使用相同的名字，只是参数和返回类型不同 可能各种异常;
    8. `-useuniqueclassmembernames`   类和类成员都使用唯一的名字;
    9. `-dontusemixedcaseclassnames`   不使用大小写混合类名;
    10. `-keeppackagenames [package_filter]`   保持packagename不混淆;
    11. `-flattenpackagehierarchy [package_name]`   指定重新打包,所有包重命名,这个选项会进一步模糊包名,将包里的类混淆成n个再重新打包到一个个的package中;
    12. `-repackageclasses [package_name]`   将包里的类混淆成n个再重新打包到一个统一的package中会覆盖flattenpackagehierarchy选项;
    13. `-keepattributes [attribute_filter]`   混淆时可能被移除下面这些东西，如果想保留，需要用该选项;“`Annotation`、`Exceptions`, `Signature`, `Deprecated`, `SourceFile`, `SourceDir`, `LineNumberTable`”
* **预校验选项**
    1. `-dontpreverify`   不预校验，默认选项;
* **通用选项**
    1. `-verbose`   打印日志;
    2. `-dontnote [class_filter]`   不打印某些错误;
    3. `-dontwarn [class_filter]`   不打印警告信息;
    4. `-ignorewarnings`   忽略警告，继续执行;
    5. `-printconfiguration [filename]`   打印配置文件;
    6. `-dump [filename]`   指定打印类结构;
       
## Android默认ProGuard配置
                 
一般一个Android应用项目创建成功后，系统默认有一个空的写满注释的文件`proguard-rules.pro`,我们可以在安装`SDK`目录`Android_SDK\tools\proguard`下找着`proguard-android.txt`这个文件，里面有系统默认准备的一些配置:


```java

#This is a configuration file for ProGuard.
#http://proguard.sourceforge.net/index.html#manual/usage.html

-dontusemixedcaseclassnames  #不使用大小写混合
-dontskipnonpubliclibraryclasses  #不混淆第三方jar
-verbose  #混淆时记录日志

# Optimization is turned off by default. Dex does not like code run
# through the ProGuard optimize and preverify steps (and performs some
# of these optimizations on its own).
-dontoptimize  #不优化输入的类文件
-dontpreverify  #混淆时不做预校验
# Note that if you want to enable optimization, you cannot just
# include optimization flags in your own project configuration file;
# instead you will need to point to the
# "proguard-android-optimize.txt" file instead of this one from your
# project.properties file.

-keepattributes *Annotation*  #保留注解
-keep public class com.google.vending.licensing.ILicensingService
-keep public class com.android.vending.licensing.ILicensingService

# For native methods, see http://proguard.sourceforge.net/manual/examples.html#native
# 保持 native 方法不被混淆
-keepclasseswithmembernames class * {
    native <methods>;
}

# keep setters in Views so that animations can still work.
# see http://proguard.sourceforge.net/manual/examples.html#beans
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

# We want to keep methods in Activity that could be used in the XML attribute onClick
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

# For enumeration classes, see http://proguard.sourceforge.net/manual/examples.html#enumerations
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
}

-keepclassmembers class **.R$* {
    public static <fields>;
}

# The support library contains references to newer platform versions.
# Don't warn about those in case this app is linking against an older
# platform version.  We know about them, and they are safe.
-dontwarn android.support.**

# Understand the @Keep support annotation.
-keep class android.support.annotation.Keep

-keep @android.support.annotation.Keep class * {*;}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <methods>;
}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <fields>;
}

-keepclasseswithmembers class * {
    @android.support.annotation.Keep <init>(...);
}

```

## 查看ProGuard输出文件

混淆之后，ProGuard会给我们输出一些文件，在`/build/proguard/`目录下，分别有以下文件:

* **`mapping.txt`**
    > 表示混淆前后代码的对照表，这个文件非常重要,如果你的代码混淆后会产生bug的话,log提示中是混淆后的代码，希望定位到源代码的话就可以根据`mapping.txt`反推,每次发布都要保留它方便该版本出现问题时调出日志进行排查，它可以根据版本号或是发布时间命名来保存或是放进代码版本控制中。

* **`dump.txt`**
    > 描述apk内所有class文件的内部结构。

* **`seeds.txt`**
    > 列出了没有被混淆的类和成员。

* **`usage.txt`**
    > 列出了源代码中被删除在apk中不存在的代码。

# 混淆总结

> 1. 如果使用了Gson之类的工具要保证实体类不被混淆
> 2. 如果使用了自定义控件那就需要保证它们不参与混淆
> 3. 第三方库中的类不进行混淆
> 4. 代码中使用了反射，需要保证该反射类类名方法不变
> 5. 继承了Serializable接口的类不混淆

* **`Fragment`**

```java
#如果引用了v4或者v7包
# Keep the support library
-keep class android.support.v4.** { *; }
-keep interface android.support.v4.** { *; }
# Keep the support library
-keep class android.support.v7.** { *; }
-keep interface android.support.v7.** { *; }
```

* **`ButterKnife 6.0`**

```java
-keep class butterknife.** { *; } 
  -dontwarn butterknife.internal.**
  -keep class **$$ViewInjector { *; }
  -keepclasseswithmembernames class * {
          @butterknife.* <fields>;
  }
  -keepclasseswithmembernames class * {
     @butterknife.* <methods>;
  }
```
* **`ButterKnife 7.0`**

```java
-keep class butterknife.** { *; }
-dontwarn butterknife.internal.**
-keep class **$$ViewBinder { *; }
-keepclasseswithmembernames class * {  
 @butterknife.* <fields>;
}
-keepclasseswithmembernames class * {   
@butterknife.* <methods>;
}
```

更多内容可以参考以下博客：

[Android proguard 详解][1]

[混淆样子][2]

[Android代码混淆之混淆规则][3]

[Android开发实践：利用ProGuard进行代码混淆][4]

[使用proguard混淆android代码][5]

[1]: http://blog.csdn.net/banketree/article/details/41928175
[2]: http://www.jianshu.com/p/48242027c560
[3]: http://blog.csdn.net/fengyuzhengfan/article/details/43876197
[4]: http://ticktick.blog.51cto.com/823160/1413066
[5]: http://www.jianshu.com/p/0202845db617




