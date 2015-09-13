---
layout: post
title: "Docker小技巧"
date: 2014-01-20 17:28:35 +0800
comments: true
categories: 技术 
---
在国内，由于网络原因，在docker部署的时候，经常会出现`can't reach index.docker.io`,解决方法:  
首先获得IP地址:  
```  
ping registry-1.docker.io
```  
获得IP地址:
`54.224.119.89`
添加一下内容到/etc/hosts  
```
54.224.119.89 cdn-registry-1.docker.io  
```
Windows路径：  
`C:\Windows\System32\drivers\etc`
