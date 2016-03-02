# ATOM 快速上手文档

## 安装nodejs  
略  

## 安装 atom  
略  

## 代理设置
>由于我们伟大的墙，所以我们需要进行代理设置  
代理我们可以使用shadowsocks    

安装Atom后,打开C:\Users\xxx\下的.atom文件夹里的.apmrc文件,添加以下三行配置即可:  

```
http-proxy=http://127.0.0.1:1080
https-proxy=http://127.0.0.1:1080
strict-ssl=false
```

如果找不到.apmrc文件,就从.apm文件夹里复制一个出来.

## 安装常用插件  

> 这些插件写文档基本够用了  

- Markdown Assistant  
- Qiniu-uploader  
- Git-Plus  
- Merge Conflicts  
- Markdown preview plus

## 如何安装插件  
按住ctrl+, 这个组合键，即可进入atom配置界面  
选择`+Install`  

![安装相关插件页面](http://7xphqb.com1.z0.glb.clouddn.com/cfbdd3816740380930fdb1b7ff5b2f7e.png)

## atom配置  

### 配置七牛  

由于我们使用的是qiniu的图床，所以要配置qiniu-uploader  

具体参数的获取方法，上面都有相对应的说明  

![七牛相关配置信息](http://7xphqb.com1.z0.glb.clouddn.com/0ac312cde75753f7416f082a42369220.png)


### 修改源码文件  
由于复制粘贴有些问题，所以需要对markdown-assistant源码做少许修改  
修改路径  
`C:\Users\xxx\.atom\packages\markdown-assistant\lib\main.coffee`  
将33行的`e.mataKey`替换为`e.ctrKey`  


## atom 使用小技巧  

### tips1
ctrl+shift+a 快捷键添加单个文件  

## tips2
ctrl+shift+x 快捷键提交当前修改  

### tips3
ctrl+shift+h 快捷键打开git命令窗口  

### tip4  
使用`unset!`取消快捷键  
```
'atom-workspace, atom-workspace atom-text-editor':
  'ctrl-shift-X': 'unset!'
```
## 参考链接  
http://www.jianshu.com/p/85b11364fa1c  
http://blog.csdn.net/crper/article/details/48056435  
