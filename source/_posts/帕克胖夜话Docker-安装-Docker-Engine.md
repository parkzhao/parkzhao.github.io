title: 帕克胖夜话Docker-安装Docker Engine
date: 2016-07-28 10:44:14
tags:
 - Linux
 - Docker
 - Docker Engine
categories:
 - Docker Engine
 - 夜话
---

# 准备
## 安装系统必要软件  
```
$ sudo apt-get update
$ sudo apt-get install apt-transport-https ca-certificates

sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
$ lsb_release -a
```

## 添加安装docker engine的镜像源
### 查看操作系统版本  
执行命令 `lsb_release -a`
```
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.3 LTS
Release:        14.04
Codename:       trusty
```
### 创建Dockerfile文件  
创建docker.list文件，文件路径 `/etc/apt/sources.list.d/docker.list`,根据操作系统的版本，来选择相关的镜像源头  
```
On Ubuntu Precise 12.04 (LTS)
deb https://apt.dockerproject.org/repo ubuntu-precise main
On Ubuntu Trusty 14.04 (LTS)
deb https://apt.dockerproject.org/repo ubuntu-trusty main
Ubuntu Wily 15.10
deb https://apt.dockerproject.org/repo ubuntu-wily main
Ubuntu Xenial 16.04 (LTS)
deb https://apt.dockerproject.org/repo ubuntu-xenial main
```
## Docker安装  

- 更新 `apt` 包索引  
`sudo apt-get update`  
- 安装 `docker`
`sudo apt-get install docker-engine`
- 安装docker指定版本  
```
sudo apt-cache showpkg docker-engine
apt-get install -y -q docker-engine=1.8.1-0~trusty
```
