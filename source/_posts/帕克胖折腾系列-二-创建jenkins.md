title: 帕克胖折腾系列(二)创建jenkins
date: 2016-06-16 09:12:09
tags:
  - Linux
  - jenkins
  - CI
  - 持续集成
categories:
  - Linux
  - jenkins
---

通过`docker`部署`jenkins`超简单  

# 前置条件  
## 操作系统  
```
docker@ubuntu-docker03:~/shell$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.3 LTS
Release:        14.04
Codename:       trusty
```


## `docker engine`版本  
```
docker@ubuntu-docker03:~/shell$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.3 LTS
Release:        14.04
Codename:       trusty
docker@ubuntu-docker03:~/shell$ docker version
Client:
 Version:      1.8.1
 API version:  1.20
 Go version:   go1.4.2
 Git commit:   d12ea79
 Built:        Thu Aug 13 02:35:49 UTC 2015
 OS/Arch:      linux/amd64

Server:
 Version:      1.8.1
 API version:  1.20
 Go version:   go1.4.2
 Git commit:   d12ea79
 Built:        Thu Aug 13 02:35:49 UTC 2015
 OS/Arch:      linux/amd64
```
>如果`docker engine`版本不对的话，那么会导致jenkins调用外部`docker`失败

# 安装`jenkins`  
## 挂载共享文件`nfs`  
```
sudo mount -t nfs 192.168.0.250:/srv/data/share /home/docker/storage
```
## 下载`jenkins docker`镜像  
```
docker pull registry.aliyuncs.com/haibin/jenkins
```
## 启动`jenkins`  
```
docker run \
  --name jenkins-new \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(which docker):/usr/bin/docker \
  -v /lib/x86_64-linux-gnu/libdevmapper.so.1.02.1:/lib/x86_64-linux-gnu/libdevmapper.so.1.02.1 \
  -v /home/docker/storage/docker_data/jenkins:/var/jenkins_home \
  -p 18088:8080 \
  registry.aliyuncs.com/haibin/jenkins
```
## 验证`jenkins`  
访问`http://localhost:18088`
如果出现以下情况，则创建成功  
![jenkins效果图](http://qiniu1.kopbit.com/4f38be4deb5afabe23ad60aef7b6d033.png)

# 相关阅读  
[建立可用的NFS存储](http://haibin.me/2016/05/22/%E5%B8%95%E5%85%8B%E8%83%96%E6%8A%98%E8%85%BE%E7%B3%BB%E5%88%97-%E5%BB%BA%E7%AB%8B%E5%8F%AF%E7%94%A8%E7%9A%84NFS%E5%AD%98%E5%82%A8/)
