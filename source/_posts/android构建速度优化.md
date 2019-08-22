---
layout: android构建速度优化
title: android构建速度优化
date: 2019-08-22 17:23:17
tags: [android,gradle,构建速度,android studio]
---
# 前言   
`Android Studio` 开发，到了构建阶段，是一个漫长的过程，当然优化的方式有很多中，我们就从gradle配置方面来进行初步的优化  
# gradle 配置
由于默认的新建的工程，在构建的话，比较耗时步骤
- 下载`gradle`
- 同步相关包
对于上面的情况，首先可以手动下载gralde安装包，然后解压，在`android studio`中设置`gralde`路径 
## 设置本地的`gradle`
![](http://tp.linqmind.com/2019-08-22-092817.jpg)
## 启用内部的maven仓库
![](http://tp.linqmind.com/2019-08-22-092944.jpg)
## 设置maven仓库为国内的`aliyun`
```
allprojects {
    repositories {
        mavenLocal()
        maven { url "https://maven.aliyun.com/repository/apache-snapshots" }
        maven { url "https://maven.aliyun.com/repository/google" }
        maven { url "https://maven.aliyun.com/repository/central" }
        maven { url "https://maven.aliyun.com/repository/gradle-plugin" }
        maven { url "https://maven.aliyun.com/repository/jcenter" }
        maven { url "https://maven.aliyun.com/repository/spring" }
        maven { url "http://maven.aliyun.com/nexus/content/repositories/releases/" }
        maven { url "https://jitpack.io" }
        google()
    }
}
```
# 结语
希望`google`能够把`android studio`的调试和构建的时间，优化的好点~~~~。