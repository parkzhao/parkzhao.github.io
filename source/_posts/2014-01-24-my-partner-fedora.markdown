---
layout: post
title: 亲密小伙伴fedora
date: 2014-01-24 23:22:29 +0800
comments: true
categories: 技术
---
经过几年的开发，尝试过无数的操作系统，渐渐的也形成了自己的御用操作系统，我选择的是fedora，你要问我原因，其实我也不知道，如果非要找一个理由的话，你可以用谷歌找出N个理由。  
下面我主要是记录我和我的小伙伴之间的故事。  
<!--more-->
一. 基础系统    
1.1 准备镜像  
这一步是比较简单的，在站点上下载[fedora的安装镜像][fedora-download]  
1.2 准备live-usb  
下载[live usb creator][usb_creator_link],根据提示将fedora烧录到u盘中。  
1.3 安装系统  
从u盘启动,按照提示安装fedora操作系统  
二. 开发环境  
由于安装是桌面的android系统，所以需要对其进行必要的配置  
2.1 安装基础软件  
```
sudo yum upgrade -y  
sudo yum install vim zsh tmux openssh-server openssh-client -y   
```
2.2 虚拟系统LXC  
虚拟系统LXC，我选择更加灵活和快速的[docker-io][docker_link],[docker-io][docker_link]的安装在[fedora][fedora_link]下更加方便.  
[docker-io][docker_link]与docker会发生冲突,所以，如果[fedora][fedora_link]中安装的有docker，首先必须删除:  
```
sudo rpm -qa "docker"  
```
如果有docker的信息，那么就必须移除  
```
sudo yum remove "docker" -y  
```
在[fedora-20][fedora_link]中，wmdocker包提供与docker相同的函数,并且和[docker-io][docker_link]不相冲突.  
安装wmdocker包  
```
sudo yum install wmdocker -y   
sudo yum remove docker -y  
```
安装[docker-io][docker_link]  
```
sudo yum install docker-io -y  
```
更新[docker-io][docker_link]  
```
sudo yum update docker-io -y  
```
[docker-io][docker_link]安装完毕后，让[docker-io][docker_link]后端启动.  
```
sudo systemctl start docker  
```
如果要[docker-io][docker_link]在启动系统的时候启动.  
```
sudo systemctl enable docker  
```
在国内会出现[docker-index][docker-index_link]无法访问，那么可以参考[这篇文章][docker_reference]    
检验[docker-io][docker_link]安装是否成功  
```
sudo docker run -i -t "fedora" /bin/echo "hello,docker"  
```
如果出现`hello,docker`，那么安装就成功.  
下载[docker-io][docker_link] 镜像   
```
sudo docker pull 'fedora'  
sudo docker pull 'centos'  
sudo docker pull 'ubuntu'  
```

2.3 配置开发环境  
开发环境其实也比较的简单，如果是服务端编程，我使用的是vim+插件的方式，具体可以参考[我的开发环境][devrc_link]  
2.3.1 golang开发环境配置  
其实vim+plugin开发go语言的项目还是挺方便的，可以参考[文章][golang-readme_link]   
```
git clone -b golang https://github.com/haibinpark/gorc.git  
ln -s ~/gorc ~/.vim  
```
2.3.2 cplusplus开发环境配置  
对于c++开发，就相对来说要复杂写，由于使用自动提示插件`YCM`,所以需要CLANG。 
```
git clone -b golang https://github.com/haibinpark/gorc.git  
ln -s ~/gorc ~/.vim
```
让后要编译`YCM`插件  
2.3.3 android开发环境  
android开发必须要jdk支持  


+ 安装jdk  
```
wget http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm  
sudo yum install jdk-7u51-linux-x64.rpm -y  
```
+ 下载[android studio][as_link]  
```
wget https://dl.google.com/android/studio/install/0.3.2/android-studio-bundle-132.893413-linux.tgz  
sudo tar zxf android-studio-bundle-132.893413-linux.tgz  
cd android studio  
sh studio.sh  
```
不过要更新到最新版本 
[as_link]:http://developer.android.com/sdk/installing/studio.html







    


[fedora-download]:http://download.fedoraproject.org/pub/fedora/linux/releases/20/Live/x86_64/Fedora-Live-Desktop-x86_64-20-1.iso
[usb_creator_link]:https://fedorahosted.org/releases/l/i/liveusb-creator/liveusb-creator-3.12.0-setup.exe
[docker_link]:http://www.docker.io
[fedora_link]:http://www.fedoraproject.org
[docker-index_link]:http://index.docker.io
[docker_reference]:/blog/2014/01/20/how-to-start-docker/
[devrc_link]:https://github.com/haibinpark/gorc
[golang-readme_link]:https://github.com/haibinpark/gorc/blob/master/README.md
