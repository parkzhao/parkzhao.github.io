---
layout: post
title: docker 部署server应用
date: 2014-02-18 23:02:22 +0800
comments: true
categories: 技巧
---
最近想用[docker][docker-io_link]部署自己的一些应用，但在部署构建镜像的时候经常会出现错误，那么镜像构建不成功。  
最好的办法是删除不成功的镜像  
```
sudo docker images|grep "<none>"|awk '{print $3}'|sudo xargs docker rmi  
```
如果不成功，那么就应该删除container  
```
sudo docker ps -a|grep "<image id>"|awk '{print $1}'|sudo xargs docker rm  
```
\<image id\>替换为无法删除的镜像ID。  
如果删除container错误,有以下几个办法解决  

+ 停止容器`sudo docker stop <container id>`或者`sudo docker kill <container id>`;  
+ 重新启动docker守护进程，然后在执行上面删除操作,`sudo service docker restart`.   
这下重新构建进行就重头开始了。 


[docker-io_link]:http://www.docker.io
