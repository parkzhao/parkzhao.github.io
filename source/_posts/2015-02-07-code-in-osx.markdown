---
layout: post
title: "开发在OSX"
date: 2015-02-07 12:48:02 +0800
comments: true
categories: OSX iOSDevTips 
---
<img style="float: right" height="200" width="180" src="http://triz.qiniudn.com/xcode_tool.jpg"></img>  
最近公司需要开发iOS的应用，本来是做Android开发的，根据需要，再加上我也比较喜欢折腾，所以就接下了这个艰巨的任务...  
在开发之前，其实之前也看过object-c的语法，并且写了一个demo（其实也就是hello world）给人的感觉和Java还是有比较大的差别。但当时也没这方面的开发需要，所以也就废弃了。吐槽:主要当时没有苹果开发工具，自己在虚拟机中进行折腾。  
新任务接下来后呢，需要学习的东西还很多，因为什么都不知道吗？所以在接下来这个任务后，首先的明确需求。  
由于Android客户端也在开发中，所以服务端不用我们操心，接口那些基本都是好的，可用的，我们只需要开发iOS客户端即可，开发相关已经确定；  
1. 人:2个人，都是从Android转过来的。  
2. 时间: 2014年12月中旬~2015年2月地(春节前)  
3. 任务: 系统核心功能:  
3.1 基础信息展示  
3.2 用户联合登录  
3.3 集成百度地图  
4. 目标:  
整个系统测试没有问题，并且通过苹果应用商店审核  
没有做过，所以心里没底，但是凭借对Android的开发过程的熟悉，也就答应了下来.  
答应的时候很爽快，接下来就是苦逼的加班:   
1. 要开发正式的产品，装备也不能太山寨了，在怎么着，也得买台苹果电脑吧(主要原因是虚拟机TTM卡了，8G的内存，完全跑不动)，mac book pro也就是算了，应为是创业公司，能省就省了吧，买了两台mac mini将就用着。  
2. 买了一本电子书,[《iOS开发指南》][iOS_BOOK_STARTUP_GUID],这本书非常适合入门使用，看完了它，你基本了解整个软件开发的流程.  
3. 开发工具也就是苹果的xcode，版本控制用的是svn，由于xcode对svn支持不是很友好，所以如果有条件就使用git吧，我平时业余的项目就是用git，如果是私有项目就采用[git.oschina.net][oschina_net_link],公开的项目可以采用[github][github_link]. 如果必须的使用svn的话，那么建议使用[smarsvn][smartsvn_link],当然此软件是收费的.  
工具准备好了，那么接下来就开始干活了，两个人各有分工，通过[《iOS开发指南》][iOS_BOOK_STARTUP_GUID]知道，整个项目采用了分层开发.项目分了三层:Persistence,Business,Presentation。接下来才知道，当对整个开发不熟悉的话，这样分层是很不合理的，这样增加了项目的调试难度。当然这样对开发了iPhone，在开发iPad应用，无意会节省不少的时间成本，应为PersistenceLayer，BusinessLayer根本就用不着改变。  
整个项目开发中，一共有三个点:  
1. 网络通讯，采用[ASIHTTPRequest][asihttprequest_link]  
2. 本地存储，结构化数据，采用CoreData，配置文件保存在plist文件中,归档苹果提供了Archiver。  
3. 多线程，异步  
4. 基础控件的使用  
5. 控件的生命周期  
6. 布局文件storyboard,xib   
7. 代码自动布局的实现，这块相对来说比较的麻烦.特别是在一个view controller中有多个高度不定的控件的时候.  
在整个开发的过程中. 最好采用分层开发,这样的话可以加快开发进度,如果只是项目分开了，而实际开发没有实际分开的话。那么整个开发过程是低效并且充满折磨的过程.  
在2月6号左右，我们就完成了开发，提交到了应用商店.由于苹果审核还没下来，测试版地址:  
[行动派-轻松自驾.旅游][xdpie_app_ios_link]  
新的应用审核通过了,应用appstore下载地址:  
[行动派-轻松自驾.旅游][xdpie_app_store_link]


[iOS_BOOK_STARTUP_GUID]:http://book.douban.com/subject/24846574/
[oschina_net_link]:http://git.oschina.net
[github_link]:http://www.github.com
[smartsvn_link]:http://www.smartsvn.com
[asihttprequest_link]:http://allseeing-i.com/ASIHTTPRequest/
[xdpie_app_ios_link]:http://fir.im/rvqc
[xdpie_app_store_link]:https://itunes.apple.com/us/app/xing-dong-pai-qing-song-zi/id964439381?l=zh&ls=1&mt=8
