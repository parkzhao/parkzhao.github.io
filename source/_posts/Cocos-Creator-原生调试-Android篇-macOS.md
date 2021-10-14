title: 'Cocos Creator 原生调试-Android篇[macOS]'
date: 2018-12-12 11:08:26
tags:
---
Cocos Creator 原生调试-Android篇[macOS]
===

在进行`Cocos creator` 进行开发的时候，一般我们用模拟器就可进行原生调试，但是有些问题只是在原生平台才会出现，我们需要对原生进行调试。

# 软件准备

## step1 安装`Android studio`[可选]
软件准备  
## 下载安装`Android studio`
下载地址
`https://dl.google.com/dl/android/studio/install/3.2.0.26/android-studio-ide-181.5014246-mac.dmg`
安装过程略

## step2 安装SDK[必选]
安装SDK,SDK可以在官网上进行下载，也可以在第三方镜像进行下载，下载地址
`https://dl.google.com/android/repository/sdk-tools-darwin-4333796.zip`
下载后解压到磁盘 `$HOME`/tools

## step3 安装NDK[必选]  
安装NDK,NDK可以在官网上进行下载，也可以在第三方镜像进行下载，下载地址
`https://dl.google.com/android/repository/android-ndk-r16b-darwin-x86_64.zip`

## step4 安装`gradle 4.4`[必选]
安装`gradle`,`gradle`可以在官网上进行下载，也可以在第三方镜像进行下载，下载地址
`https://services.gradle.org/distributions/gradle-4.4-bin.zip`

## step5 安装`Chrome 71`[必选] 
由于`Chrome 70`有无法命中断点额问题，所以需要安装`chrome 71`的版本


# 参数配置

`Cocos Creator`配置

![](https://tp.linqmind.com/2018-12-07-095155.png)


![](https://tp.linqmind.com/2018-12-07-095244.png)


# 调试  
获取调试参数
```
 ✘> adb logcat|grep  "chrome-devtools"
12-07 16:59:00.491 22893 23091 D jswrapper: Debugger listening..., visit [ chrome-devtools://devtools/bundled/inspector.html?v8only=true&ws=0.0.0.0:6086/00010002-0003-4004-8005-000600070008 ] in chrome browser to debug!
```
>需要注意的是，这个的端口号，是根据上面的命令获取下来的，我这里获取的端口号是 `6086`. `Cocos Creator 2.0.5`的端口号是 `5086`

由于里面的调试端口是 6068，所以要进行端口转发，在`terminal`中执行
```
✘> adb forward tcp:6086 tcp:6086
```
打开浏览器，在地址栏中输入上面的内容
```
chrome-devtools://devtools/bundled/inspector.html?v8only=true&ws=0.0.0.0:6086/00010002-0003-4004-8005-000600070008
```
输入的内容在调试参数里面查看。
链接成功后，在page页面，可以查看 `src/project.dev.js`里面是你的开发代码。可以在需要的方法上打断点即可。
![](https://tp.linqmind.com/2018-12-07-094152.png)
这样你就可以进行原生环境的代码调试，祝大家玩的愉快。