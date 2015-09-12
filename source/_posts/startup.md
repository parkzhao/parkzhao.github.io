title: startup
date: 2015-09-09 23:35:18
tags:
---
## Feature  
- Github新建博客项目  
- VPS安装Docker  
- 启动[Hexo 镜像][hexo_blog_image]
- 博客配置  


[hexo_blog_image]:https://hub.docker.com/r/cloudcube/hexo/  

## 目的
在30分钟之内搭建好你的博客系统 [Hexo][hexo_link]  
现在网上有好多的文章，说的是如何使用github来构建hexo博客系统，github有一个致命的弱点就是在国内访问太恼火了，想想如果自己能够把写的文档托管在[Github][github_link]或者[oschina][oschina_link],[Hexo][hexo_link]部署在vps上，当有新的文章推送到代码管理平台，然后自动更新到[Hexo][hexo_link] Server 那多好啊？  
于是作了个计划，就开始构建自己的Hexo博客系统  
[博客构建计划][blog_plan_link]  
  
<!-- more -->  


## 准备工作 
### 购买域名 
现在购买域名选择比较的多，你可以有几种选择   

- [godaddy][godaddy_link]  
 
- [dnspod][dnspod_link]  


- [万网][net_link]  


以上的这三家都支持支付宝付款，还是比较的方便,推荐在godaddy购买.    


[godaddy_link]:http://www.godaddy.com  
[dnspod_link]:http://www.dnspod.cn  
[net_link]:http://www.net.cn  


### 购买VPS  
购买vps,可以在以下几个地方购买  

- [linode][linode_link]  
这里需要信用卡，所以感觉不是很方便，而且这里有个坑，购买后要给linode客户提交一个工单，并告知取消智能托管服务，不然的话会持续扣你的钱  

- [digitalocean][digitalocean_link]  
这个是我目前使用的vps，主要有两个作用  
1) 搭建shadowsocks,翻墙使用  
2) 搭建静态博客[haibin.me][haibin_link]  

国内的就需要备案了，如果你要获取更好的访问速度的话，那么可以选用国内的主机  

- [aliyun][aliyun_link]  
访问速度还可以，就是安装docker的比较的繁琐  

- [ustack][ustack_link]  
这里基础环境比较的好的，不用安装docker，可以直接使用[coreos][coreos_link]，价格还算可以,不过这里绑定的域名也是需要备案的！  
  
  
[linode_link]:http://www.linode.com  
[haibin_link]:http://www.haibin.me  
[aliyun_link]:http://www.aliyun.com  
[coreos_link]:http://www.coreos.com  
[ustack_link]:http://www.ustack.com  


### 本地安装nodejs
具体的安装方法，可以参考[nodejs][nodejs_link]  


[nodejs_link]:https://nodejs.org/en/

## 新建博客项目  
- 访问[github][github_link],注册github账号
- 创建博客的版本库    


<image src="http://7xlp7m.com1.z0.glb.clouddn.com/创建版本库.png">  


- 本地新建博客项目  
	- 安装[Hexo][hexo_link]  
	
``` 
npm install hexo-cli -g  
hexo init blog  
cd blog  
npm install
hexo server
```

你可以访问  
<http://localhost:4000>  
来确定是否安装成功  

- 将新建的博客项目同步到github  

``` 
cd blog
git init
git add .
git commit -m "init project"
git remote add origin "git@github.com:haibinpark/hexo-blog.git"
git push -u origin master 
```

- 设置github hexo-blog项目参数  

1) 设置自动发布参数  
<image src="http://7xlp7m.com1.z0.glb.clouddn.com/设置自动发布参数.png" />  
  
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
    -e GITHUB_REMOTE_ADDR="git@github.com:haibinpark/hexo-blog.git" \
    -e AUTO_DEPLOY_WEB_HOOK_PORT="14000" \
    -e AUTO_DEPLOY_WEB_HOOK_HASHKEY="testautopub" \
    cloudcube/hexo  
```   

***参数说明***  

+ -- name 博客名称  
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
## 设置发布key  
将上面获取到的key设置到项目的部署key  
<image src="http://7xlp7m.com1.z0.glb.clouddn.com/设置部署key.png" />  


## 测试  
通过浏览器，访问你的博客域名地址即可  
<http://www.haibin.me>

## 参考链接  
<http://blog.jamespan.me/2015/04/17/hexo-in-the-docker/>  
<https://docs.docker.com/installation/ubuntulinux/>  


[hexo_link]:http://hexo.io  
[digitalocean_link]:https://www.digitalocean.com/?refcode=e211668f3c86    
[blog_plan_link]:http://naotu.baidu.com/file/7235a00854a4983dd5bf4d1daf590ab4?token=00d7ba69e5749502  
[github_link]:http://github.com  
[oschina_link]:http://www.oschina.net  