title: nodejs课程学习第2课
date: 2015-11-13 20:10:52
tags:
---
## 课程目标  
* 建立nodejs web项目  
* nodejs web框架的常用函数的使用方法  
* 代码托管Gitlab与github  
* 私有镜像Docker部署  


## 课程内容  
### 基础工具准备  

#### 安装nodejs  
* windows安装  
略  
* osx下安装  

```
brew install nodejs
```

* ubuntu 安装  

```
apt-get update -y
apt-get install nodejs -y
```

#### 安装web strom  
现在体验了一圈，用的比较顺手的还是web storm，安装方法我这里就不一一演示了,如果经济条件允许，建议大家购买正版吧，建议大家购买的软件版本为webstorm 11，主要这个版本，可以为使用javascript测试框架mocha      
略   

#### 建立nodejs项目  



### nodejs express框架  
nodejs express框架，包括几个比较常用的函数，大家理解对代码编写很有帮助的。  

* require  
require包含的主要作用是包含第三方模块  

* app.use  


* app.get;app.post;app.put;app.delete  


* app.set方法  


### 代码托管  
现在代码托管代码的方式有两种方式git,svn,由于git的分布式的特性，所以我们采用git的方式，现在采用git的平台著名的有两个[gitlab][gitlab_link],[github][github_link]  

#### gitlab  


#### github  


### 代码测试  
* 代码测试框架mocha  

* 网络持续集成平台  


### 代码部署  
现在的代码部署，其实是很方便的，我采用的方案，是通过[灵雀云][alauda_link],代码托管采用的是aliyun的vps服务器  

#### 持续构建镜像  
这里主要概述如何在灵雀云上构建一个持续构建的镜像   


#### 运行你的服务

* 购买aliyun服务器  


* 安装docker环境  

```
sudo apt-get install docker.io  
```
* 启动软件服务  

```
sudo docker run -d index.aluda.com/park/myweb  
```



[gitlab_link]:(http://www.gitlab.org)  
[github_link]:(http://www.github.com)  
[alauda_link]:(http://www.alauda.cn)
