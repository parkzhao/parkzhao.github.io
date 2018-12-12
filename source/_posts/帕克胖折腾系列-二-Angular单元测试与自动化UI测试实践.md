title: Angular单元测试与自动化UI测试实践
date: 2016-05-23 08:13:09
tags:
---
>关于本文：介绍通过karma与jsmine框架对angular开发的应用程序进行单元与E2E测试。这篇文章并非原创，具体的原作者 [vipyoumay][vipyoumay_link]

[vipyoumay_link]:http://my.csdn.net/vipyoumay

## 一、先决条件
* nodejs
* webstorm

## 二、创建项目

### 1、webstorm中创建空白web项目
![空白项目](http://7xlh63.com1.z0.glb.clouddn.com/bef67a6853ce62867604126f123d68aa.png)

### 2、创建html、js文件夹
在项目中创建2个文件夹分别用于存放项目中用到的html、js文件。

## 三、安装框架
### 1、安装前端框架
项目中所用框架是angularjs,为了安装框架方便可安装bower包管理器。
#### 1) 安装bower包管理器
在webstorm的terminal中执行脚本
```
npm install bower -g
```

#### 2) 安装angular等框架
angular、angular-mocks框架

```
bower i
```

### 2、安装服务器端框架及依赖模块
服务器依赖于nodejs，需要安装nodejs的包，首先在根目录下创建package.json文件。
* **http-server** 模块
* **jasmine-core**:javascript单元测试框架；
* **karma**:模拟javascript脚本在各种浏览器执行的工具；
* **karma-chrome-launcher**: 在chrome浏览器执行的工具；
* **karma-jasmine**: jasmine-core在karma中的适配器；
* **karma-junit-reporter**: 生成junit报告；
* **protractor**:E2E测试框架
安装模块
```
npm i
```
### 3、启动服务器
要启动node服务器需要在package.json中配置script节点,dependencies中定义依赖包，在script配置start节点用于启动服务器，test节点的内容会在后面讲解。
```json
"name": "angularjs-test",
  "version": "0.0.1",
  "dependencies": {
    "bower": "^1.7.7",
    "http-server": "^0.9.0",
    "jasmine-core": "^2.4.1",
    "karma": "^0.13.22",
    "karma-chrome-launcher": "^0.2.3",
    "karma-jasmine": "^0.3.8",
    "karma-junit-reporter": "^0.4.1",
    "protractor": "^3.2.1"
  },
  "scripts": {
    "postinstall": "bower install",
    "prestart": "npm install",
    "start": "http-server -a localhost -p 8000 -c-1",
    "pretest": "npm install",
    "test": "karma start karma.conf.js",
    "test-single-run": "karma start karma.conf.js  --single-run"
  }
```
配置后运行命令,启动服务器，浏览器上输入http://localhost:8000
```
npm start
```

## 四、开始单元测试
### 1、编写功能代码
在文件js中新建js文件index.js。在index.js中定义congroller,实现简单累加方法add,代码如下:
```javascript
/**
 * Created by stephen on 2016/3/24.
 */

(function (angular) {
    angular.module('app', []).
    controller('indexCtrl', function ($scope) {
        $scope.add = function (a, b) {
            if(a&&b)
            return Number(a) + Number(b)
            return 0;
        }
    });
})(window.angular);
```
在文件html中新建html文件index.html，加入两个输入框用户获取输入，当输入后绑定controller中的add方法实现计算器功能，代码如下:
```javascript
<!DOCTYPE html>
<html lang="en" ng-app="app">
<head>
    <meta charset="UTF-8">
    <title>index</title>

</head>
<body>
<div ng-controller="indexCtrl">
    <input type="text" ng-model="a" value="0">
    +
    <input type="text" ng-model="b" value="0">
    =<span id='result'>{{add(a,b)}}</span>
</div>
</body>
</html>
<script src="/bower_components/angular/angular.min.js"></script>
<script src="/bower_components/angular-mocks/angular-mocks.js"></script>
<script src="/js/index.js"></script>
```
启动服务器看到下图效果

![效果](http://7xlh63.com1.z0.glb.clouddn.com/bfa862850c4b224e77e8e4f89117c657.png)
### 2、编写测试代码
在test文件夹中新建文件index-test.js用于编写index.js的单元测试。
```javascript
'use strict';
describe('app', function () {
    beforeEach(module('app'));
    describe('indexCtrl', function () {
        it('add 测试', inject(function ($controller) {
            var $scope = {};
            //spec body
            var indexCtrl = $controller('indexCtrl', {$scope: $scope});
            expect(indexCtrl).toBeDefined();
            expect($scope.add(2, 3)).toEqual(5);
        }));

    });
});
```
### 3、单元测试配置
初始化karma配置文件,用于配置karma，执行命令
```
karma init
```
在karma配置文件代码中每个节点都有默认注释请参看
```javascript
module.exports = function (config) {
    config.set({

        // base path that will be used to resolve all patterns (eg. files, exclude)
        basePath: './',


        // frameworks to use
        // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
        frameworks: ['jasmine'],


        // list of files / patterns to load in the browser
        files: [
            'bower_components/angular/angular.min.js',
            'bower_components/angular-mocks/angular-mocks.js',
            'js/index.js',
            'test/index-test.js'
        ],

        // test results reporter to use
        // possible values: 'dots', 'progress'
        // available reporters: https://npmjs.org/browse/keyword/karma-reporter
        reporters: ['progress'],


        // web server port
        port: 9876,


        // enable / disable colors in the output (reporters and logs)
        colors: true,


        // level of logging
        // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
        logLevel: config.LOG_INFO,


        // enable / disable watching file and executing tests whenever any file changes
        autoWatch: true,


        // start these browsers
        // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
        browsers: ['Chrome'],


        // Continuous Integration mode
        // if true, Karma captures browsers, runs the tests and exits
        singleRun: false,

        plugins: [
            'karma-chrome-launcher',
            'karma-jasmine',
            'karma-junit-reporter'
        ],

        junitReporter: {
            outputFile: '/test_out/unit.xml',
            suite: 'unit'
        }
    })
}
```
在package.json scripts 配置测试信息,指定karma文件地址
``` json
"test": "karma start karma.conf.js",
```
### 4、运行单元测试
运行命令，执行测试
```
npm test
```
运行结果如下，可以看到通过测试：

![测试运行结果](http://7xlh63.com1.z0.glb.clouddn.com/f675c4b60d832e1d407377c62203e40f.png)

### 5、调试单元测试
除了运行测试外，很多时候需要调试测试，在karma弹出网页中点击debug,进入http://localhost:9876/debug.html页面，就可以用chrome自带的调试工具调试代码了：

![debug点击](http://7xlh63.com1.z0.glb.clouddn.com/4c90f7283a25b91e4ec76835d8698127.png)

![debug code](http://7xlh63.com1.z0.glb.clouddn.com/aa81509c780345df954477bc2fbf6d88.png)

### 单元测试覆盖率
如果需要对单元测试覆盖率进行统计，可以安装karma-coverage并配置karma文件。这样在单元测试完成后，会生成测试覆盖率报告文档。
```
npm install karma-coverage -save
```
在karma.conf.js文件中加入节点
``` javascript

// 新增节点用于配置输出文件夹
coverageReporter: {
           type: 'html',
           dir: 'coverage'
       },
// 新增节点用于配置需要测试的文件地址（这里是controller地址）
preprocessors: {'js/*.js': ['coverage']}

// 新增元素'karma-coverage'
plugins: [
          'karma-chrome-launcher',
          'karma-jasmine',
          'karma-junit-reporter',
          'karma-coverage',
      ],
// 新增元素 coverage
reporters: ['progress', 'coverage'],
```
运行单元测试后在目录中生成coverage文件夹，点击index.html可以查看测试覆盖率。

![测试覆盖率](http://qiniu.xdpie.com/fb0ce841d8781d287d5bc74b49a09091.png?imageView2/2/w/700)


## 五、E2E测试
e2e或者端到端（end-to-end）或者UI测试是一种测试方法，它用来测试一个应用从头到尾的流程是否和设计时候所想的一样。简而言之，它从一个用户的角度出发，认为整个系统都是一个黑箱，只有UI会暴露给用户。
### 1、配置E2E测试
新建文件夹e2e-test新建protractor.conf.js文件,用于配置protractor框架，代码如下。
```javascript
exports.config = {

    allScriptsTimeout: 11000,

    baseUrl: 'http://localhost:8000/app/',

    // Capabilities to be passed to the webdriver instance.
    capabilities: {
        'browserName': 'chrome'
    },

    framework: 'jasmine',

    // Spec patterns are relative to the configuration file location passed
    // to protractor (in this example conf.js).
    // They may include glob patterns.
    specs: ['*.js'],

    // Options to be passed to Jasmine-node.
    jasmineNodeOpts: {
        showColors: true, // Use colors in the command line report.
    },

    defaultTimeoutInterval: 30000
};
```
配置package.json scripts脚本节点
```json
"preupdate-webdriver": "npm install",
"update-webdriver": "webdriver-manager update",
"preprotractor": "npm run update-webdriver",
"protractor": "protractor e2e-test/protractor.conf.js"
```
### 2、编写e2e测试脚本
设计测试用例：文本框a的值录入1，文本框b录入2，期望结果3
```javascript
describe('index.html', function() {

    beforeEach(function() {
        browser.get('http://localhost:8000/html');
    });

    it('get index html', function() {

        var a = element(by.model('a'));
        var b = element(by.model('b'));
        a.sendKeys(1);
        b.sendKeys(2);
        var result = element(by.id('result'));
        expect(result.getText()).toEqual('3');
    });
});
```
### 3、执行测试查看测试结果
需要执行命名,查看是否更新webdriver(什么是webdriver http://sentsin.com/web/658.html),
手动安装protractor至全局  
`npm i -g protractor`

**注:安装或更新webdriver需要翻墙，请在webstrom中设置代理地址**。  
在`webstrom`中切换至`Terminal`窗口，在`Terminal`窗口通过以下方式设置代理:    
```
set PROXY=http://localhost:1080
set HTTP_PROXY=%PROXY%
set HTTPS_PROXY=%PROXY%
```
代理设置成功后，运行以下命令  
```
npm run update-webdriver
```
手动安装webdriver  

1. 下载protractor  
下载的网盘地址:  
`http://pan.baidu.com/s/1hr7oYva`

2. 将下载的protractor拷贝到用户的目录下  
`C:\Users\laura\AppData\Roaming\npm\node_modules` 文件目录中
第二步：将webstorm原来项目中node文件删除，
第三步：在terminal中输入 nrm ls 显示不报错时执行npm i 命令，报错时执行npm i nrm –g命令，后执行nrm use taobao命令
第四步：执行npm i命令，
第五步：执行bower i命令如果报错，看项目有没有bower文件，没有的话安装，执行npm I bower -g后执行bower i命令
第六步：执行npm start命令，完成后，点击新建窗口“＋”新增窗口执行npm run protractor 命令


执行e2e测试,这是会弹出浏览器，自动点击浏览器，录入脚本输入完成自动化e2e测试，其本质还是调用selenium测试。
```
npm run protractor
```
![自动化ui测试结果](http://7xlh63.com1.z0.glb.clouddn.com/84b941fef69af1c6767156b68f069732.png)




## 执行构建  
### 构建docker镜像  
```
docker build --no-cache=true --rm=true -t angular-e2etest-showcase .
```
### 运行docker镜像  
```
sh wrapper_docker.sh_
```

---
## 参考资料
[1] 官方测试demo https://github.com/angular/angular-seed

[2] protractor 官方文档 http://angular.github.io/protractor/#/tutorial

[3] 自动化E2E测试 http://sentsin.com/web/658.html

[4] karma官方文档 https://karma-runner.github.io/latest/intro/configuration.html

[5] angular单元测试官方文档 https://docs.angularjs.org/guide/unit-testing    

[6] 示例项目代码 https://github.com/haibinpark/angular-e2etest-showcase  

[7] 原文地址 http://blog.csdn.net/vipyoumay/article/details/50978887
