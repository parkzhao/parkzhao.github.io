title: 学习nodejs第一课
date: 2015-11-10 07:28:02
tags:
---
# 一步一步学习nodejs-startup  
  
讲解点:  

* nodejs特点
* nodejs与v8
* nodejs与libuv
* nodejs的应用场景

## 概要 
我们已经有许多web容器，为什么还需要有nodejs呢？

* IIS  
* Apache  
* Tomcat  
* nginx
* ...  

因为nodejs具有以下特点:

* 异步I/O  
* 事件与回调  
* 跨平台  
* 单线程  


## nodejs特点   
    
* 异步I/O  {:&.moveIn}   

这个是经典前端的异步I/O  

!["前端异步调用"](http://7xlp7m.com1.z0.glb.clouddn.com/前端异步调用.png "前端异步调用")

**查看代码 N**

```
$.post('/url', {title: 'Parkpang讲Node.js'}, function (data) { 
	console.log('收到讲课请求');}); 
console.log('发送讲课请求完毕');
```

这个是后端的异步操作
!["后端异步调用"](http://7xlp7m.com1.z0.glb.clouddn.com/服务器端异步调用.png "后端异步调用")
**查看代码 N**

```
var fs = require('fs');
var path = /home/parkpang.png;fs.readFile('path', function (err, file) { 
	console.log('读取parkpang的照片成功')}); 
console.log('发起读取parkpang的照片');
```

* 事件与回调函数  

```
var http = require('http');var querystring = require('querystring');//   服务器的request事件 
http.createServer(
	function (req, res) {		var postData = ''; req.setEncoding('utf8');		//   请求的data事件 
		req.on('data', function (trunk) {			postData += trunk; });//   请求的end事件 
		req.on('end', function () {		res.end(postData); 
	});}).listen(8080); 
console.log('服务器启动成功');
```

* 跨平台

* 单线程 **N**     
 
单线程的优点:    
（1） 不用像多线程编程那样处处在意状态的同步问题  
（2） 没有死锁的存在  
（3） 没有线程上下文交换所带来的性能上的开销  
单线程的缺点:  
（1） 无法利用多核CPU  ？    
（2） 错误会引起整个应用退出,应用的健壮性值得考验    
（3） 大量计算占用CPU导致无法继续调用异步I/O   

## nodejs历史  

* 2009年3月,Ryan Dahl在其博客上宣布准备基于V8创建一个轻量级的Web服务器并提供一套库  {:&.moveIn}
* 2009年5月,Ryan Dahl在GitHub上发布了最初的版本  
* 2009年12月和2010年4月,两届JSConf大会都安排了Node的讲座  
* 2010年年底,Node获得硅谷云计算服务商Joyent公司的资助,其创始人Ryan Dahl加入Joyent公司全职负责Node的发展  
* **2011年7月,Node在微软的支持下发布了其Windows版本**  
* 2011年11月,Node超越Ruby on Rails,成为GitHub上关注度最高的项目(随后被Bootstrap 7 项目超越,目前仍居第二）  
* 2012年1月底,Ryan Dahl在对Node架构设计满意的情况下,将掌门人的身份转交给Isaac Z. Schlueter,自己转向一些研究项目。Isaac Z. Schlueter是Node的包管理器[NPM](https://npmjs.org)的作者,之 后Node的版本发布和bug修复等工作由他接手  {:&.moveIn}  
* **2014年12月份左右，iojs从nodejs分裂出来**  
* **2015年9月份左右，iojs又回归到nodejs**  



## v8引擎

* chrome与v8组件图  

![chrome与v8组件图](http://7xlp7m.com1.z0.glb.clouddn.com/chrome组件图.png "chrome与v8组件图")

### nodejs与v8  
---
* nodejs与v8组件图  
![nodejs与v8组件图](http://7xlp7m.com1.z0.glb.clouddn.com/node组件图.png "chrome与v8组件图")

### 什么是v8引擎?  
 
[V8][v8_link]是一个由美国Google开发的开源JavaScript引擎，用于Google Chrome中。  
V8在运行之前将JavaScript编译成了机器码，而非字节码或是解释执行它，以此提升性能。更进一步，使用了如内联缓存（inline caching）等方法来提高性能。有了这些功能，JavaScript程序与V8引擎的速度媲美二进制编译。  

[v8_link]:https://zh.wikipedia.org/wiki/V8_(JavaScript引擎)


## nodejs如何实现跨平台  

* nodejs最初的跨平台方案   
   
![nodejs最初的跨平台方案](http://7xlp7m.com1.z0.glb.clouddn.com/node跨平台_origin.png "nodejs最初的跨平台方案")

* nodejs是通过libuv实现跨平台  

![nodejs是通过libuv实现跨平台](http://7xlp7m.com1.z0.glb.clouddn.com/nodejs跨平台_v0.6.0.png "nodejs是通过libuv实现跨平台")  

>libuv 是 Node 的新跨平台抽象层，用于抽象 Windows 的 IOCP 及 *nix 的 libev。作者打算在这个库的包含所有平台的差异性。

![libuv与系统](http://7xlp7m.com1.z0.glb.clouddn.com/libuv.png "libuv与系统")


http://blog.codingnow.com/2012/01/libuv.html
http://baike.baidu.com/view/1256215.htm

![IOCP](http://7xlp7m.com1.z0.glb.clouddn.com/IOCP模型.png "IOCP")

**IOCP定义 N**

>IOCP（I/O Completion Port）,常称I/O完成端口。 IOCP模型属于一种通讯模型，适用于(能控制并发执行的)高负载服务器的一个技术。 通俗一点说，就是用于高效处理很多很多的客户端进行数据交换的一个模型。或者可以说，就是能异步I/O操作的模型。  


## nodejs如何突破单线程  

* HTML5如何解决前端javascript大计算阻塞UI渲染的问题？  
html5是采用**Web Workers**来解决js大计算阻塞ui的问题 
demo_workers.js源码  

```
var i=0;

function timedCount()
{
	i=i+1;
	postMessage(i);
	setTimeout("timedCount()",500);
}

timedCount();  
```
  
index.html源码

```
var w;
function startWorker()
{
	if(typeof(Worker)!=="undefined")
	{
	  if(typeof(w)=="undefined")
	    {
	    w=new Worker("demo_workers.js");
	    }
	  w.onmessage = function (event) {
	    document.getElementById("result").innerHTML=event.data;
	  };
	}
	else
	{
		document.getElementById("result").innerHTML="Sorry, your browser
		 does not support Web Workers...";
	}
}
function stopWorker()
{
	w.terminate();
}
```  

* nodejs是如何解决javascript大计算阻塞的呢？
node采用了与Web Workers相同的思路来解决单线程中大计算量的问题，使用Nodejs的一个十分重要的模块child_process，通过它可以创建多进程，以利用多核计算资源。

## child_process介绍  
child_process创建子进程的四个函数  

spawn,exec,execFile,fork

![](http://7xlp7m.com1.z0.glb.clouddn.com/子进程.png "")

* spawn

```
child_process = require ('child_process');  
options ={stdio: ['ipc'] };  
child = child_process.spawn('coffee', ['./child.coffee'], options);   

注解:  

IPC（Inter-Process Communication，进程间通信）
```

* exec  

```require('child_process').exec( 'ls -lh /home' , function(err, stdout , stderr ) {
   console.log( stdout );
});
```

* execFile **N**

```var childProcess = require('child_process');
var path = "/home";
childProcess.execFile('/bin/ls', ['-l', path], function (err, result) {
    console.log(result)
});
```

* fork

```var n = require('child_process').fork( './child.js'); 
n.on ( 'message', function(m) { 
  console. log ( 'ParkPang got message:', m);
});
n.send({ ToChildProcess: '讨论需求' });

child.js:

process.on ( 'message', function(m) { 
   console.log ( 'Homer got message:', m);
});
process.send({ ToParentProcess: '正在进行需求讨论' });
```   


## nodejs的应用场景  

* I/O密集型  
* 兼容已有系统  
* 分布式应用  
* 计算密集???  

## FAQ？
* nodejs是通过什么跨平台的？
* nodejs有哪些特点?
