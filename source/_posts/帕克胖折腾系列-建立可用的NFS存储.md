title: 帕克胖折腾系列(-)建立可用的NFS存储
date: 2016-05-22 11:47:43
tags:
 - nfs
 - 存储
 - Linux
 - 折腾
 - 配置
 - ubuntu
categories:
 - Linux
 - NFS
 - 存储
---
# 需求
>生命不息，折腾不止!  

建立可用的NFS共享存储  
**建议通读一次后，再进行尝试！！**  

## 硬件  
1). 三张千兆网卡
2). 两根千兆网线
拓扑图
![网络拓扑图](http://7xlvqo.com1.z0.glb.clouddn.com/6652b89d89446a3a949d6986fb269ac8.png)  
# 基础系统  
## 分区，系统安装  
两台机器，分别安装ubuntu操作系统
具体的分区信息如下:  
```
swap  4G
/boot 1G
/        100G 安装系统
```
系统都通过卷管理  
```
pvcreate /dev/sda[3]

pvcreate /dev/sdb[1]
```
## 安装必要软件  
```
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:icamargo/drbd
sudo apt-get update
sudo apt-get upgrade

```
## 配置固定IP  
```
##server01##
# The primary network interface
auto eth1
iface eth1 inet static
        address 192.168.1.100
        netmask 255.255.255.0

##server02##
# The primary network interface
auto eth1
iface eth1 inet static
        address 192.168.1.100
        netmask 255.255.255.0
```
## 配置host  
```
sudo vi /etc/hosts

######
192.168.1.100   server01
192.168.1.101   server02
```
## 同步服务器时间  
```
sudo apt-get install ntp
//同步时间任务
sudo crontab -e
##Added the following line to the end.
1 * * * * root ntpdate au.pool.ntp.org
```
## 内核调试  
```
##Both##

sudo vi /etc/sysctl.conf.

# drbd tuning
net.ipv4.tcp_no_metrics_save = 1
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 87380 33554432
vm.dirty_ratio = 10
vm.dirty_background_ratio = 4
```
# DRBD  
## DRBD安装  
```
##Both
sudo apt-get install drbd8-utils heartbeat
```
## 文件配置  
```
##Both
sudo vi /etc/drbd.d/disk1.res
resource disk1 {

        protocol C;

        handlers {
                pri-on-incon-degr "echo o > /proc/sysrq-trigger ; halt -f";
                pri-lost-after-sb "echo o > /proc/sysrq-trigger ; halt -f";
                local-io-error "echo o > /proc/sysrq-trigger ; halt -f";
                outdate-peer "/usr/lib/heartbeat/drbd-peer-outdater -t 5";
        }

        startup {
                degr-wfc-timeout 120;
                wfc-timeout 30;
                outdated-wfc-timeout 20;
        }

        disk {
                on-io-error detach;
        }

        net {
                cram-hmac-alg sha1;
                shared-secret "password";
                after-sb-0pri disconnect;
                after-sb-1pri disconnect;
                after-sb-2pri disconnect;
                rr-conflict disconnect;
        }

        syncer {
                rate 100M;
                verify-alg sha1;
                al-extents 257;
        }

        on server01 {
                device  /dev/drbd0;
                disk    /dev/sdb1;
                address 192.168.0.211:7788;
                meta-disk internal;
        }

        on server02{
                device  /dev/drbd0;
                disk    /dev/sdb1;
                address 192.168.0.212:7788;
                meta-disk internal;
        }
}
```
## 更改DRDB权限  
```
##Both

sudo chgrp haclient /lib/drbd/drbdsetup-84
sudo chmod o-x /lib/drbd/drbdsetup-84
sudo chmod u+s /lib/drbd/drbdsetup-84
sudo chgrp haclient /sbin/drbdmeta
sudo chmod o-x /sbin/drbdmeta
sudo chmod u+s /sbin/drbdmeta
```
## 创建资源  
```
##Both
drbdadm create-md disk1
```
## 启动DRBD  
```
##Both
sudo service drbd start

```
## 初始化同步  
server01作为master,并且开始初始化同步  
```
##server01
drbdadm -- --overwrite-data-of-peer primary disk1
```
监视同步过程  
```
watch cat /proc/drbd
###
Every 2.0s: cat /proc/drbd                                                  Sun Jun  8 08:00:49 2014

version: 8.4.3 (api:1/proto:86-101)
srcversion: F97798065516C94BE0F27DC
0: cs:SyncTarget ro:Secondary/Secondary ds:Inconsistent/UpToDate C r-----
    ns:0 nr:90397696 dw:90389504 dr:0 al:0 bm:5516 lo:9 pe:6 ua:8 ap:0 ep:1 wo:f oos:1842345780
        [>....................] sync'ed:  4.7% (1799164/1887436)Mfinish: 14:11:31 speed: 36,044 (36,
168) want: 3,280 K/sec
```
## 测试同步  
```
##server01

sudo mkfs.ext4 /dev/drbd0
sudo mkdir -p /srv/data
sudo mount /dev/drbd0 /srv/data
```
创建磁盘块  
```
dd if=/dev/zero of=/srv/data/test.zeros bs=1M count=1000

##server01
sudo umount /srv/data
drbdadm secondary disk1
```
查看同步过程  
```
##server02
sudo mkdir -p /srv/data
sudo drbdadm primary disk1
sudo mount /dev/drbd0 /srv/data

sudo ls /srv/data
##Check for test.zeros file

sudo rm /srv/data/test.zeros
sudo umount /srv/data
sudo drbdadm secondary disk1

##server01
sudo drbdadm primary disk1
sudo mount /dev/drbd0 /srv/data

sudo ls /srv/data
##Check that the test.zeros file is no longer there
```
取消自启动  
```
sudo update-rc.d -f drbd remove
```
# NFS  
## 安装nfs kernel server  
```
##Both
sudo apt-get install nfs-kernel-server nfs-common
```
## 取消自启动  
```
##Both
sudo update-rc.d -f nfs-kernel-server remove
# sudo update-rc.d -f nfs-common remove
sudo update-rc.d nfs-kernel-server stop 20 0 1 2 3 4 5 6 .
# sudo update-rc.d nfs-common  stop 20 0 1 2 3 4 5 6 .
```
## 配置NFS到DRBD设备  
```
##server01
sudo mount /dev/drbd0 /srv/data
sudo mv /var/lib/nfs/ /srv/data/
sudo ln -s /srv/data/nfs/ /var/lib/nfs
sudo mv /etc/exports /srv/data
sudo ln -s /srv/data/exports /etc/exports

##server02
sudo rm -rf /var/lib/nfs
sudo ln -s /srv/data/nfs/ /var/lib/nfs
sudo rm /etc/exports
sudo ln -s /srv/data/exports /etc/exports
```
## 共享配置  
```
##server01
sudo mkdir /srv/data/sharet
sudo chmod 777 /srv/data/share
sudo vi /etc/exports

##Add to the bottom
sudo vi /etc/exports
/srv/data/share        192.168.0.*(rw,no_subtree_check,no_all_squash,no_root_squash)
```
配置完成后卸载掉/dev/drbd0  
```
sudo umount /dev/drbd0
```
# Corosync  
corosync 是用于处理心跳和上报节点信息的软件  
## 安装配置Corosync  
```
server01@server01:~# apt-get install -y corosync
server02@server02:~# apt-get install -y corosync
```
安装完成以后修改配置文件 /etc/corosync/corosync.conf 找到  
```
interface {
     # The following values need to be set based on your environment
     ringnumber: 0
     bindnetaddr: 127.0.0.1
     mcastaddr: 226.94.1.1
     mcastport: 5405
}
```
其中的 bindnetaddr 需要根据当前网络修改, 通过命令 (其中 eth1 根据实际的网络修改)  
`ip addr | grep "inet " | grep eth1 | awk '{print $4}' | sed s/255/0/`  
可以看到这里我们需要修成的值是 192.168.1.0. 于是我们把这段配置修改成  
```
interface {
        # The following values need to be set based on your environment
        ringnumber: 0
        bindnetaddr: 192.168.1.0
        mcastaddr: 226.94.1.1
        mcastport: 5405
}
```
接着找到  
```
server02@server02:~$ sudo cat /etc/corosync/service.d/pcmk
service {
        # Load the Pacemaker Cluster Resource Manager
        ver:       0
        name:      pacemaker
}
```
把其中的 ver: 0 修改成 1 也就是修改成:  
```
service {
        # Load the Pacemaker Cluster Resource Manager
        ver:      1
        name:      pacemaker
}
```
## 启动Corosync  
完成以上配置后还需要修改 /etc/default/corosync 将  
```
START=no

修改成

START=yes
```
接着通过命令, 启动 corosync  
```
server01@server01:~# sudo service corosync start
server02@server02:~# sudo service corosync start
```
# Pacemaker  
pacemaker 是一个群集资源管理器, 用于管理 corosync 的节点.  
## 安装和运行 pacemaker  
```
server01@server01:~#sudo apt-get install -y pacemaker

server02@server02:~#sudo apt-get install -y pacemaker

server01@server01:~#sudo service pacemaker start

server02@server02:~#sudo service pacemaker start
```
完成后就可以通过命令 crm status 查看节点状态了.  
```
server01@server01:~#sudo  crm status

============
Last updated: Mon Dec  2 16:45:30 2013
Last change: Mon Dec  2 16:41:35 2013 via crmd on db2
Stack: openais
Current DC: NONE
2 Nodes configured, 2 expected votes
0 Resources configured.
============

Node db1: UNCLEAN (offline)
Node db2: UNCLEAN (offline)
```
可以看到目前的2个节点 server01和 server02都是离线的. 接着就需要配置 pacemaker 了  
## 配置 pacemaker  
首先在 server01输入  
```
sudo crm configure property stonith-enabled=false
sudo  crm configure property no-quorum-policy=ignore

sudo  crm configure rsc_defaults resource-stickiness=100
```
这几条命令保证, 当 db1 宕机切换到 db2 后, db1 修复好重新上线也不会自动的把主机转移回 db1, 造成不必要的切换.  
## 配置 drbd  
继续再终端输入 crm configure 进入配置模式, 接着输入  
```
sudo crm configure
primitive drbd0 ocf:linbit:drbd \
    params drbd_resource="disk1" \
    op monitor interval="29s" role="Master" \
    op monitor interval="31s" role="Slave"

ms ms-drbd0 drbd0 \
    meta master-max="1" master-node-max="1" \
        clone-max="2" clone-node-max="1" \
        notify="true"

primitive db-fs ocf:heartbeat:Filesystem \
    params fstype=ext4 directory=/srv/data \
        device=/dev/drbd0

group db-ha-group db-fs

colocation db-ha-group-on-ms-drbd0 inf: db-ha-group ms-drbd0:Master
order db-ha-group-after-ms-drbd0 inf: ms-drbd0:promote db-ha-group:start

commit
exit
```
这时可以通过 crm status 查看到  
```
Online: [ db1 db2 ]

Master/Slave Set: ms-drbd0 [drbd0]
    Masters: [ db1 ]
    Slaves: [ db2 ]
Resource Group: db-ha-group
    db-fs      (ocf::heartbeat:Filesystem):    Started db1
```
当前的 drbd 已经在 server01 上启动并挂载到 /srv/data 下了.  
## 配置 vip  
```
sudo crm configure primitive db-ip ocf:heartbeat:IPaddr2 \
    params ip="192.168.0.250" nic="eth0" meta target-role=stopped
echo $(crm configure show db-ha-group) db-ip | crm configure load update -
crm resource start db-ip
```
以上命令就是新建了一个叫 db-ip 的资源, 并把他加入 db-ha-group 组并启动. 为了验证是否成功我们可以输入  
```
server01@server01:~#sudo  crm status

Online: [ db1 db2 ]

Master/Slave Set: ms-drbd0 [drbd0]
    Masters: [ db1 ]
    Slaves: [ db2 ]
Resource Group: db-ha-group
    db-fs      (ocf::heartbeat:Filesystem):    Started db1
    db-ip      (ocf::heartbeat:IPaddr2):      Started db1
```
看到 db-ip 已经在 db1 启动了. 接着验证这个 ip 的设置可以输入  
```
server01@server01:~#sudo ip addr show eth0

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 00:0c:29:0c:0d:69 brd ff:ff:ff:ff:ff:ff
    inet 192.168.37.51/24 brd 192.168.37.255 scope global eth0
    inet 192.168.37.50/32 brd 192.168.37.178 scope global eth0
    inet6 fe80::20c:29ff:fe0c:d69/64 scope link
      valid_lft forever preferred_lft forever
```
可以看到这个 192.168.0.250 已经被配置给了 eth0  
## 配置NFS  
配置 pacemaker 的资源  
```
sudo crm configure primitive db-nfs lsb:nfs-kernel-server \
    op monitor interval="30s" meta target-role=stopped
sudo echo $(sudo crm configure show db-ha-group) db-nfs |sudo crm configure load update -
sudo crm resource start db-nfs
```
最终输入 crm status  
```
Online: [ db1 db2 ]

Master/Slave Set: ms-drbd0 [drbd0]
    Masters: [ db1 ]
    Slaves: [ db2 ]
Resource Group: db-ha-group
    db-fs      (ocf::heartbeat:Filesystem):    Started db1
    db-ip      (ocf::heartbeat:IPaddr2):      Started db1
    db-pg      (ocf::heartbeat:pgsql): Started db1
    db-nfs    (lsb:nfs-kernel-server):        Started db1
```
可以看到所有的服务都已启动.  
# 迁移资源  
完成之前配置后, 可以通过 crm status 看到所有资源都在 server01上启动了, 现在我们测试能否将资源转移到 server02上并且根据设计他不应该自动迁移回server01, 我们输入  
```
sudo crm resource migrate db-ha-group server02
sudo crm resource unmigrate db-ha-group
```
先资源强制分配到 server02, 再取消强制分配. 然后输入 crm_mon, 应该就可以看到资源再慢慢的迁移到 server02, 等一会最终可以看到.  
```
Online: [ db1 db2 ]

Master/Slave Set: ms-drbd0 [drbd0]
    Masters: [ db2 ]
    Slaves: [ db1 ]
Resource Group: db-ha-group
    db-fs      (ocf::heartbeat:Filesystem):    Started db2
    db-ip      (ocf::heartbeat:IPaddr2):      Started db2
    db-pg      (ocf::heartbeat:pgsql): Started db2
    db-nfs    (lsb:nfs-kernel-server):        Started db2
```
所有的资源都运行于 server02 了. 然后把资源再迁回 server01 可以输入之前的迁移命令也可以简单的重启 pacemaker  
`sudo service pacemaker restart`  
不一会儿就可以通过 crm status 看到所有的资源又被迁移回了 server01

最后

至此基本的 HA 都已经配置完成了. 基本就是让 pacemaker 来负责程序的启动和调度. 另外还可以通过下列命令来设置 crm.  
```
crm resource show            # 显示所有的 resource
crm resource cleanup ${id}    # 清除失败的 action 日志
crm resource stop ${id}      # 停止某个 resource
crm configure delete ${id}    # 删除某个配置
crm configure edit            # 编辑现有的配置文件
```
# 故障恢复  
## 一般故障  
1）单机发生故障  
当server01发生故障，corosync就会切换资源到server02  
当server01修复了后，就要立即进行系统切换  
1> 启动服务  
启动server01->启动drbd->启动corosync->启动pacemaker  
2> 迁移数据（可选）  
当数据同步完成后，迁移资源到server01  
sudo crm resource migrate db-ha-group server01  
也可选择不迁移  

2)同时掉电  
启动server01->启动drbd->启动corosync->启动pacemaker  

启动server02->启动drbd->启动corosync->启动pacemaker  
## 脑裂故障  
1) 断开主(parmary)节点；关机、断开网络或重新配置其他的IP都可以；这里选择的是断开网络  

2)查看两节点状态  
```
[server02@server02 ~]# drbd-overview
  0:drbd/0  WFConnection Primary/Unknown UpToDate/DUnknown C r----- /mnt ext4 2.0G 68M 1.9G 4%
[root@nod1 ~]# drbd-overview
  0:drbd/0  StandAlone Secondary/Unknown UpToDate/DUnknown r-----
```
由上可以看到两个节点已经无法通信；server02为主节点，server01为备节点  

3)将server01节点升级为主(primary)节点并挂载资源  
```
[server01@server01~]# drbdadm primary drbd
[server01@server01~]# drbd-overview
  0:drbd/0  StandAlone Primary/Unknown UpToDate/DUnknown r-----
[server01@server01~]# mount /dev/drbd0 /srv/data
[server01@server01~]# mount | grep drbd0
/dev/drbd0 on /srv/data type ext4 (rw)
```
4)假如原来的主(primary)节点修复好重新上线了，这时出现了脑裂情况  

5)再次查看两节点的状态  
```
[server01@server01~]# drbdadm role drbd
Primary/Unknown
[server02@server02~]# drbdadm role drbd
Primary/Unknown
```
6)查看server01与server02连接状态  
```
[server01@server01 ~]# drbd-overview
  0:drbd/0  StandAlone Primary/Unknown UpToDate/DUnknown r----- /mnt ext4 2.0G 68M 1.9G 4%
[server02@server02 ~]# drbd-overview
  0:drbd/0  WFConnection Primary/Unknown UpToDate/DUnknown C r----- /mnt ext4 2.0G 68M 1.9G 4%
```
由上可见，状态为StandAlone时，主备节点是不会通信的  

7）查看DRBD的服务状态  
```
[server01@server01 ~]# service drbd status
drbd driver loaded OK; device status:
version: 8.4.3 (api:1/proto:86-101)
GIT-hash: 89a294209144b68adb3ee85a73221f964d3ee515 build by gardner@, 2013-05-27 04:30:21
m:res   cs          ro               ds                 p       mounted  fstype
0:drbd  StandAlone  Primary/Unknown  UpToDate/DUnknown  r-----  ext4
[server02@server02~]# service drbd status
drbd driver loaded OK; device status:
version: 8.4.3 (api:1/proto:86-101)
GIT-hash: 89a294209144b68adb3ee85a73221f964d3ee515 build by gardner@, 2013-05-27 04:30:21
m:res   cs            ro               ds                 p  mounted  fstype
0:drbd  WFConnection  Primary/Unknown  UpToDate/DUnknown  C  /mnt     ext4
```
8) 在server01备用节点处理办法  
```
[server01@server01 ~]# umount /mnt/
[server01@server01 ~]# drbdadm disconnect drbd
drbd: Failure: (162) Invalid configuration request
additional info from kernel:
unknown connection
Command 'drbdsetup disconnect ipv4:192.168.137.225:7789 ipv4:192.168.137.222:7789' terminated with exit code 10
[server01@server01 ~]# drbdadm secondary drbd
[server01@server01 ~]# drbd-overview
  0:drbd/0  StandAlone Secondary/Unknown UpToDate/DUnknown r-----
[server01@server01 ~]# drbdadm connect --discard-my-data drbd
######执行完以上三步后，你查看会发现还是不可用
[server01@server01 ~]# drbd-overview
  0:drbd/0  WFConnection Secondary/Unknown UpToDate/DUnknown C r-----
```
9） 需要在server02节点上重新建立连接资源  
`[server02@server02~]# drbdadm connect drbd`
查看节点连接状态  
```
[server02@server02~]# drbd-overview
  0:drbd/0  Connected Primary/Secondary UpToDate/UpToDate C r----- /mnt ext4 2.0G 68M 1.9G 4%
[server01@server01 ~]# drbd-overview
  0:drbd/0  Connected Secondary/Primary UpToDate/UpToDate C r-----
```
由上可见已经恢复到正常运行状态  

待恢复完成后  
卸载掉/srv/data  
然后启动服务：  
启动server01->启动drbd->启动corosync->启动pacemaker  
启动server02->启动drbd->启动corosync->启动pacemaker  

这里要考虑相关的服务的启动顺序。  
# 安全策略  
1）需进行ip地址权限设定，在交换机上面做安全策略  
2）建议配置双网卡，直接背对背连接  
# 测试  
## NFS Client  
```
In testing, I chose to use this command to mount NFS:

sudo mount -t nfs 192.168.0.250:/srv/data/share /mnt

sudo dd if=/dev/zero of=/mnt/test.zero bs=1M count=4000
```
生成一个4G的文件  
同时写入两个4G的文件，并且拷贝1G的文件  
第一个4G文件的写入速度为9M左右  
第二个4G文件的写入速度为80M左右
第三个1G文件的读取速度为80M左右  
具体是否满足性能要求还需要设置  

![NFS测试](http://7xlvqo.com1.z0.glb.clouddn.com/17b96fee66053e8a5c75e91e5a987d8d.png)  
# FAQ  
```
error:
server02@server02:~$ sudo drbdadm create-md disk1
md_offset 10736365568
al_offset 10736332800
bm_offset 10736005120

Found LVM2 physical volume signature
    10484736 kB data area apparently used
    10484380 kB left usable by current configuration

Device size would be truncated, which
would corrupt data and result in
'access beyond end of device' errors.
You need to either
   * use external meta data (recommended)
   * shrink that filesystem first
   * zero out the device (destroy the filesystem)
Operation refused.

Command 'drbdmeta 0 v08 /dev/sdb1 internal create-md' terminated with exit code 40
```  
解决:  
`sudo dd if=/dev/zero of=/dev/sdb1 bs=1M count=1`  
