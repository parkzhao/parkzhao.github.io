---
layout: post
title: fedora下代理上网
date: 2014-02-01 21:11:07 +0800
comments: true
categories: 工具 
---
以前是使用[goagent][goagent_link]代理上网，由于需要看youtube视频，所以就更改为[wallproxy][wallproxy_link]。  
[wallproxy][wallproxy_link]设置好了后，会出现[youtube][youtube_link]无法访问，所以需要导入证书。  
```
sudo yum install nss-tools  
certutil -d sql:$HOME/.pki/nssdb -A -t TC -n "goagent" -i <my wallproxy path>/wallproxy/local/cert/missing/CA.crt  
``` 
记录下来，方便以后查找.  
[goagent_link]:https://code.google.com/p/goagent
[wallproxy_link]:https://github.com/wallproxy/wallproxy
[youtube_link]:https://www.youtube.com
