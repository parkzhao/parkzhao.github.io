---
layout: post
title: "iOS 百度SDK离线地图下载"
date: 2015-01-22 21:51:13 +0800
comments: true
categories: iOSDevTips 
---
在进行集成百度iOS sdk的时候，进行离线地图下载的时候，会出现错误:  

availableDiskSpace方法找不到，但是如何解决呢，需要对UIDevice进行扩展:
具体的代码片段:
"UIDevice+Manager.h"  

```
//
//  UIDevice+Manager.h
//
//

#import <UIKit/UIKit.h>
#import <mach/mach.h>

@interface UIDevice (DiskManager)

- (BOOL)availableDiskSpace;

@end
```
"UIDevice+Manager.m"
```
//
//  UIDevice+DiskManager.m

#import "UIDevice+Manager.h"

@implementation UIDevice (DiskManager)

- (BOOL)availableDiskSpace{
    if ([self availableMemory] > 0) {
        return TRUE;
    }
    return FALSE;
}


- (double)availableMemory{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS ) {
        return NSNotFound;
    }
    double availableMem = ((vm_page_size* vmStats.free_count) / 1024.0)/1024.0;
    NSLog(@"可使用内存大小为: %f",availableMem);
    return availableMem;
}



@end

```

