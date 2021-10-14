---
layout: rxjava2.0常用方法使用
title: rxjava2.0常用方法使用
date: 2019-09-05 08:59:52
tags: [rxjava2.0,rxjava,java,android]
---
# zip的使用方法
## 概述
Zip通过一个函数将多个Observable发送的事件结合到一起，然后发送这些组合到一起的事件. 它按照严格的顺序应用这个函数。它只发射与发射数据项最少的那个Observable一样多的数据 
## 原理  
![Rxjava2 ZIP](https://tp.linqmind.com/2018-09-12-071734.jpg)
其中一根水管负责发送圆形事件 , 另外一根水管负责发送三角形事件 , 通过Zip操作符, 使得圆形事件 和三角形事件 合并为了一个矩形事件
## 使用场景  
一个界面需要展示用户的一些信息, 而这些信息分别要从两个服务器接口中获取, 而只有当两个都获取到了之后才能进行展示。
## 实例代码
```
fun getPledgeDetails(req: MortageDetailReq): Observable<PledgeDetail>? {
        return Observable.zip(httpHelper.getSupplementMortageDetail(req)
                .compose(RxUtil.rxSchedulerHelper())
                .compose(RxUtil.handleMyResult()),
                httpHelper.doQueryMortageDetail(req)
                        .compose(RxUtil.rxSchedulerHelper())
                        .compose(RxUtil.handleMyResult()), BiFunction<SupplementMortageDetailResp, MortageDetailResponse, PledgeDetail> { t1, t2 ->
            val pledgeDetail = PledgeDetail()
            pledgeDetail.mortageDetailResp = t2
            pledgeDetail.supplementMortageDetailResp = t1
            pledgeDetail
        })
    }
```
# filter的使用方法
## 概述
使用filter对消息进行过滤
## 原理  
![](https://tp.linqmind.com/2018-09-12-075120.jpg)
该操作符用于过滤掉一些不需要的数据
## 使用场景  
要对一个列表进行过滤操作，并将结果用户接下来的后续操作。
## 实例代码
```
private PublishSubject<Long> mCityPublish;

//监听网络变化
private registerBroadcast() {
    mReceiver = new BroadcastReceiver () {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (mNetStatusPublish != null) {
                mNetStatusPublish.onNext(isNetworkConnected());
            }
        }
    };
    IntentFilter filter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
    registerReceiver(mReceiver, filter);
}

//通过filter过滤掉网络未连接和未获取到缓存城市的列表
mNetStatusPublish.filter(new Predicate<Boolean>() {

            @Override
            public boolean test(Boolean aBoolean) throws Exception {
                return aBoolean && getCacheCity() > 0;
            }

        })


```

# map的使用方法  
## 概述  
对Observable发射的每一项数据应用一个函数，执行变换操作
- map返回的是结果集
- map被订阅时每传递一个事件执行一次onNext方法
- map只能单一转换，单一只的是只能一对一进行转换，指一个对象可以转化为另一个对象但是不能转换成对象数组（map返回结果集不能直接使用from/just再次进行事件分发，一旦转换成对象数组的话，再处理集合/数组的结果时需要利用for一一遍历取出，而使用RxJava就是为了剔除这样的嵌套结构，使得整体的逻辑性更强。）
## 原理  
![](https://tp.linqmind.com/2018-09-12-083105.jpg)
Map操作符对原始Observable发射的每一项数据应用一个你选择的函数，然后返回一个发射这些结果的Observable。
## 使用场景  
map适用于一对一转换
## 实例代码  
- 实例代码一
```
private Observable<Long> getNetStatusPublish() {
        return mNetStatusPublish.filter(new Predicate<Boolean>() {

            @Override
            public boolean test(Boolean aBoolean) throws Exception {
                return aBoolean && getCacheCity() > 0;
            }

        }).map(new Function<Boolean, Long>() {

            @Override
            public Long apply(Boolean aBoolean) throws Exception {
                return getCacheCity();
            }
            
        }).subscribeOn(Schedulers.io());
    }
```
- 实例代码二  
```
Action1<List<Course>> action1 = new Action1<List<Course>>() {
        @Override
        public void call(List<Course> courses) {
            //遍历courses，输出cuouses的name
             for (int i = 0; i < courses.size(); i++){
                Log.i(TAG, courses.get(i).getName());
            }
        }
    };
    Observable.from(students)
            .map(new Func1<Student, List<Course>>() {
                @Override
                public List<Course> call(Student student) {
                    //返回coursesList
                    return student.getCoursesList();
                }
            })
            .subscribe(action1);
```
# flatmap的使用方法 
## 概述  
FlatMap将一个发射数据的Observable变换为多个Observables，然后将它们发射的数据合并后放进一个单独的Observable
- flatmap返回的是包含结果集的Observable
- flatmap多用于多对多，一对多，再被转化为多个时，一般利用from/just进行一一分发，被订阅时将所有数据传递完毕汇总到一个Observable然后一一执行onNext方法（执行顺序不同）>>>>(如单纯用于一对一转换则和map相同)
- flatmap既可以单一转换也可以一对多/多对多转换，flatmap要求返回Observable，因此可以再内部进行from/just的再次事件分发，一一取出单一对象（转换对象的能力不同）
## 原理  
![](https://tp.linqmind.com/2018-09-12-084745.jpg)
FlatMap操作符使用一个指定的函数对原始Observable发射的每一项数据执行变换操作，这个函数返回一个本身也发射数据的Observable，然后FlatMap合并这些Observables发射的数据，最后将合并后的结果当做它自己的数据序列发射。
## 使用场景  
flatmap适用于一对多，多对多的场景
## 实例代码  
```
Observable.from(students)
            .flatMap(new Func1<Student, Observable<Course>>() {
                @Override
                public Observable<Course> call(Student student) {
                    return Observable.from(student.getCoursesList());
                }
            })
            .subscribe(new Action1<Course>() {
                @Override
                public void call(Course course) {
                    Log.i(TAG, course.getName());
                }
            });
```
# create的使用方法 
## 概述 
使用一个函数从头开始创建一个Observable
## 原理  
![](https://tp.linqmind.com/2018-09-12-090209.jpg)
Create操作符从头开始创建一个Observable，给这个操作符传递一个接受观察者作为参数的函数，编写这个函数让它的行为表现为一个Observable--恰当的调用观察者的onNext，onError和onCompleted方法。
一个形式正确的有限Observable必须尝试调用观察者的onCompleted正好一次或者它的onError正好一次，而且此后不能再调用观察者的任何其它方法。
## 使用场景  
图片压缩，视频压缩，封装成单独的方法，这样可以使用create方法，结果返回一个Observable
## 实例代码  
```
Observable.create(new Observable.OnSubscribe<Integer>() {
    @Override
    public void call(Subscriber<? super Integer> observer) {
        try {
            if (!observer.isUnsubscribed()) {
                for (int i = 1; i < 5; i++) {
                    observer.onNext(i);
                }
                observer.onCompleted();
            }
        } catch (Exception e) {
            observer.onError(e);
        }
    }
 } ).subscribe(new Subscriber<Integer>() {
        @Override
        public void onNext(Integer item) {
            System.out.println("Next: " + item);
        }

        @Override
        public void onError(Throwable error) {
            System.err.println("Error: " + error.getMessage());
        }

        @Override
        public void onCompleted() {
            System.out.println("Sequence complete.");
        }
    });
```
# from的使用方法 
## 概述 
将其它种类的对象和数据类型转换为Observable
## 原理  
![](https://tp.linqmind.com/2018-09-12-090954.jpg)

Iterable可以看成是同步的Observable；Future，可以看成是总是只发射单个数据的Observable。通过显式地将那些数据转换为Observables，你可以像使用Observable一样与它们交互。
因此，大部分ReactiveX实现都提供了将语言特定的对象和数据结构转换为Observables的方法
## 使用场景  
当你使用Observable时，如果你要处理的数据都可以转换成展现为Observables，而不是需要混合使用Observables和其它类型的数据，会非常方便。这让你在数据流的整个生命周期中，可以使用一组统一的操作符来管理它们。
## 实例代码  
```
Integer[] items = { 0, 1, 2, 3, 4, 5 };
Observable myObservable = Observable.from(items);

myObservable.subscribe(
    new Action1<Integer>() {
        @Override
        public void call(Integer item) {
            System.out.println(item);
        }
    },
    new Action1<Throwable>() {
        @Override
        public void call(Throwable error) {
            System.out.println("Error encountered: " + error.getMessage());
        }
    },
    new Action0() {
        @Override
        public void call() {
            System.out.println("Sequence complete");
        }
    }
);
```

# 参考链接  
- [ReactiveX/RxJava文档中文版](https://mcxiaoke.gitbooks.io/rxdocs/content/)
- [RxJava2 实战系列文章](https://www.jianshu.com/p/f00d9c51b65e)