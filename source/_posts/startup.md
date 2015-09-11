title: startup
date: 2015-09-09 23:35:18
tags:
---
## Feature  
- Github新建博客项目  
- Docker构建hexo容器
- 参考链接  

## 目的
在30分钟之内搭建好你的博客系统 [Hexo][hexo_link]  
现在网上有好多的文章，说的是如何使用github来构建hexo博客系统，github有一个致命的弱点就是在国内访问太恼火了，想想如果自己能够把写的文档托管在[Github][github_link]或者[oschina][oschina_link],[Hexo][hexo_link]部署在vps上，当有新的文章推送到代码管理平台，然后自动更新到[Hexo][hexo_link] Server 那多好啊？  
于是作了个计划，就开始开工构建自己的Hexo博客系统  
[博客构建计划][blog_plan_link]  
  
<!-- more -->

## 新建博客项目  
- 访问[github][github_link],注册github账号
- 创建博客的版本库
<image src="http://7xlp7m.com1.z0.glb.clouddn.com/创建版本库.png">  

## 购买域名  
<http://www.godaddy.com>  
<http://www.net.cn>  


## 购买VPS    
购买可以是linode,也可以在[digitalocean][digitalocean_link]上进行购买

## 安装Docker  
+ 登录[digitalocean][digitalocean_link].
+ 安装[Docker][docker_link]  
 
 ```  
 curl -sSL https://get.docker.com/ | sh  
 $ docker --version  
 Docker version 1.8.1,build d12ea79  
 ```

[docker_link]:http://www.docker.io  
## 启动hexo  
```
docker run \
    --name my_blog -d \
    -p 80:4000 \
    -p 14000:14000 \
    -e GITHUB_REMOTE_ADDR="git@github.com:haibinpark/me.haibin.git" \
    -e AUTO_DEPLOY_WEB_HOOK_PORT="14000" \
    -e AUTO_DEPLOY_WEB_HOOK_HASHKEY="" \
    cloudcube/hexo  
```   

***参数说明***  

+ --name 博客名称  
+ -d 后台启动  
+ -p 80:4000 对外端口是80,内部端口为4000  
+ -p 14000:14000 对外端口是14000,对内端口为14000  
+ -e GITHUB_REMOTE_ADDR github上你的新建的博客地址  
+ -e AUTO_DEPLOY_WEB_HOOK_PORT  自动发布程序监听的端口,默认为14000  
+ -e AUTO_DEPLOY_WEB_HOOK_HASHKEY  自己设置在github新建博客项目设置的hashkey,这个的保密哦！
+ [cloudcube/hexo][hexo_docker_link][Docker][docker_link]镜像地址  



查看Docker日志,记录id_rsa.pub的值，后面自动获取代码需要设置该链接地址    

```  
$docker logs my_blog  

+ cat /root/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCeiJaoDbIQ0j4R3BnO7pos3B9ccnT1b70yJjGGfGRPr4CUmhRSBmqn4d829wxI1vff3m5XpJKHiHr
b80150IEtuDikvasD5pU8LwWlb+3xhSDrMD+vGOPlfxdNYQxQx8MDi5FTAuLnuiviVFNTGaqM+3wmKAY/H7VzftgrgoyMZzs2RVtIeHBVl8ALWn8Ocg
6m8kW7RFRxkhonFU0ST+UCHoJ1IwPcAA4Q+96aCARaYgxAg4ta321aHE02PvSkMin34FdntW5uoQWAhB2zHYuHq32DfIs4ZR/HvpwC18xXuvo34JwX1
o+xyiS+bKHws9XYO0Bvo//fdsa12321fd12dddafds root@3402a89049d3
+ echo Please copy above key to github deploy key,then continue
Please copy above key to github deploy key,then continue
+ sleep 180s

```  



[hexo_docker_link]:https://hub.docker.com/r/cloudcube/hexo/  
## 设置博客  


## 参考链接  
<http://blog.jamespan.me/2015/04/17/hexo-in-the-docker/>  
<https://docs.docker.com/installation/ubuntulinux/>  


[hexo_link]:http://hexo.io  
[digitalocean_link]:https://www.digitalocean.com/?refcode=e211668f3c86    
[blog_plan_link]:http://naotu.baidu.com/file/7235a00854a4983dd5bf4d1daf590ab4?token=00d7ba69e5749502  
[github_link]:http://github.com  
[oschina_link]:http://www.oschina.net  