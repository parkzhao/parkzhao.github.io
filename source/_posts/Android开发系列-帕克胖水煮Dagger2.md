title: Android开发系列-帕克胖水煮Dagger2
date: 2016-08-15 09:28:28
tags:
 - Dagger2
 - Android
 - Linux
categories:
 - Android
 - Dagger2
---
# 目标
- dagger2中的Inject,Component,Module,Provides的含义，他们有什么作用?
- dagger2到底能带来哪些好处？
- 怎样把dagger2应用到具体项目中？


# 视频讲解  
>Dagger2讲解视频

<iframe height=498 width=800 src="http://player.youku.com/embed/XMTY5MTgyOTEwMA==" frameborder=0 allowfullscreen></iframe>



## 前置条件
### 知识点
- 依赖注入(Dependency Injection简称DI)
- java注解(Annotation)

依赖注入：就是目标类（目标类需要进行依赖初始化的类，下面都会用目标类一词来指代）中所依赖的其他的类的初始化过程，不是通过手动编码的方式创建，而是通过技术手段可以把其他的类的已经初始化好的实例自动注入到目标类中。
一般来说，依赖注入又叫控制反转。控制反转一般分为两种类型(依赖注入与依赖查找)，依赖注入比较常用。

```
public abstract class BaseFragment extends Fragment {

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupFragmentComponent(AppController.get(getActivity()).getAppServiceComponent());
    }

    protected abstract void setupFragmentComponent(AppServiceComponent appServiceComponent);
}
```

注解（Annotation），也叫元数据。一种代码级别的说明。它是JDK1.5及以后版本引入的一个特性，与类、接口、枚举是在同一个层次。它可以声明在包、类、字段、方法、局部变量、方法参数等的前面，用来对这些元素进行说明，注释。

## Inject  
- 普通写法
```
Class A {
  B b = new B();
}
```

- Inject写法
```
Class A{
  @Inject
  B b;
}
```
用注解(Annotation)来标注目标类中所依赖的其他类，同样用注解来标注所依赖的其他类的构造函数，那注解的名字就叫Inject

## Component  
Component也是一个注解类，一个类要想是Component，必须用Component注解来标注该类，并且该类是接口或抽象类。我们不讨论具体类的代码，我想从抽象概念的角度来讨论Component。上文中提到Component在目标类中所依赖的其他类与其他类的构造函数之间可以起到一个桥梁的作用。

`Component`的工作原理  
Component需要引用到目标类的实例，Component会查找目标类中用Inject注解标注的属性，查找到相应的属性后会接着查找该属性对应的用Inject标注的构造函数（这时候就发生联系了），剩下的工作就是初始化该属性的实例并把实例进行赋值。因此我们也可以给Component叫另外一个名字注入器（Injector）



## Module
问题：项目中使用到了第三方的类库，第三方类库又不能修改，所以根本不可能把Inject注解加入这些类中，这时我们的Inject就失效了。

那我们可以封装第三方的类库，封装的代码怎么管理呢，总不能让这些封装的代码散落在项目中的任何地方，总得有个好的管理机制，那Module就可以担当此任。
可以把封装第三方类库的代码放入Module中，像下面的例子：
```
@Module
public class ModuleClass{
      //A是第三方类库中的一个类
      A provideA(){
           return A();
      }
}
```

Module其实是一个简单工厂模式，Module里面的方法基本都是创建类实例的方法。接下来问题来了，因为Component是注入器（Injector），我们怎么能让Component与Module有联系呢？

Component是注入器，它一端连接目标类，另一端连接目标类依赖实例，它把目标类依赖实例注入到目标类中。上文中的Module是一个提供类实例的类，所以Module应该是属于Component的实例端的（连接各种目标类依赖实例的端），Component的新职责就是管理好Module，Component中的modules属性可以把Module加入Component，modules可以加入多个Module。


## Qualifier  

```
class A{
  private String param1;

  @Inject
  public A(){

  }

  @Inject
  public A(String param1){
    this.param1 = param1
  }
}



class B{
  @Inject
  A a;
}

```  

使用限定符

```
class A{
  private String param1;

  @Inject
  @NoParmas //Qualifier
  public A(){

  }

  @Inject
  @HasParams //Qualifier
  public A(String param1){
    this.param1 = param1
  }
}



class B{
  @Inject
  @Noparams
  A a;
}

```

限定符是解决依赖注入迷失的问题。

## Scope  

Scope的真正用处就在于Component的组织。


更好的管理Component之间的组织方式，不管是依赖方式还是包含方式，都有必要用自定义的Scope注解标注这些Component，这些注解最好不要一样了，不一样是为了能更好的体现出Component之间的组织方式。还有编译器检查有依赖关系或包含关系的Component，若发现有Component没有用自定义Scope注解标注，则会报错。

更好的管理Component与Module之间的匹配关系，编译器会检查 Component管理的Modules，若发现标注Component的自定义Scope注解与Modules中的标注创建类实例方法的注解不一样，就会报错。

可读性提高，如用Singleton标注全局类，这样让程序猿立马就能明白这类是全局单例类。





Inject，Component，Module，Provides是dagger2中的最基础最核心的知识点。奠定了dagger2的整个依赖注入框架。

Inject主要是用来标注目标类的依赖和依赖的构造函数
Component它是一个桥梁，一端是目标类，另一端是目标类所依赖类的实例，它也是注入器（Injector）负责把目标类所依赖类的实例注入到目标类中，同时它也管理Module。
Module和Provides是为解决第三方类库而生的，Module是一个简单工厂模式，Module可以包含创建类实例的方法，这些方法用Provides来标注

# dagger2的好处  
- 增加开发效率、省去重复的简单体力劳动，最明显的变化是不用一个一个的去new实例了。  
- 更好的管理类实例，Component，Module，整个app的类实例结构变的很清晰。让我们更好的管理管理项目  
- 解耦  
应为有了dagger2,一个类的new代码就不会出现在一个项目的任何一个地方，构造函数发生变化，只需要修改module中的代码即可。

- 方便测试

# 注意点  
- 写法
先考虑component,然后再建module,最好在考虑其他类。
- 调试
这里的错误不是很友好，如果你仔细看的话，还是会发现的。
- 用法
一个app必须要有一个Component（名字可以是ApplicationComponent）用来管理app的整个全局类实例
多个页面可以共享一个Component
不是说Component就一定要对应一个或多个Module，Component也可以不包含Module
自定义Scope注解最好使用上，虽然不使用也是可以让项目运行起来的，但是加上好处多多。
- Dagger2的注入流程  
步骤1：查找Module中是否存在创建该类的方法。
步骤2：若存在创建类方法，查看该方法是否存在参数
    步骤2.1：若存在参数，则按从**步骤1**开始依次初始化每个参数
    步骤2.2：若不存在参数，则直接初始化该类实例，一次依赖注入到此结束
步骤3：若不存在创建类方法，则查找Inject注解的构造函数，
           看构造函数是否存在参数
    步骤3.1：若存在参数，则从**步骤1**开始依次初始化每个参数
    步骤3.2：若不存在参数，则直接初始化该类实例，一次依赖注入到此结束  

# 使用dagger2
[视频讲解](#视频讲解)  


# 参考链接  
Android：dagger2让你爱不释手-基础依赖注入框架篇
http://www.jianshu.com/p/cd2c1c9f68d4

Android：dagger2让你爱不释手-重点概念讲解、融合篇
http://www.jianshu.com/p/1d42d2e6f4a5

Android：dagger2让你爱不释手-终结篇
http://www.jianshu.com/p/65737ac39c44

http://baike.baidu.com/view/1486379.htm

http://baike.baidu.com/link?url=aTMlLy_LOV3j6d9aszLbSOwUajGSL_CI1LagJ8bh--PxtOmrCI5vSwewTPCxLcVe07Q4BNoxqFX3TpsJ5B9yPq
