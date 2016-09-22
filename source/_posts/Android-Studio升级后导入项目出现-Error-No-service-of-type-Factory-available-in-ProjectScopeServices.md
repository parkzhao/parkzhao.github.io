title: 'Android Studio升级后导入项目出现[Error:No service of type Factory available in ProjectScopeServices.]'
date: 2016-09-22 11:15:41
tags:
 - Android
 - Android Studio
categories:
 - tools
 - question
---
将 Android studio由原来的2.1.3 升级到2.2,再导入项目的时候，出现了错误：  
```
Error:No service of type Factory available in ProjectScopeServices.
```
通过排查，把问题定位到根目录的build.gradle
```
buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.1.3'
        classpath 'com.jfrog.bintray.gradle:gradle-bintray-plugin:1.2'
        classpath 'com.github.dcendents:android-maven-gradle-plugin:1.3'
    }
}
```

直接将
``' classpath com.github.dcendents:android-maven-gradle-plugin:1.3'``
更新到1.4.1就可以解决问题了。

# 参考链接
https://code.google.com/p/android/issues/detail?id=219692
http://www.jianshu.com/p/c4f4894ad215
