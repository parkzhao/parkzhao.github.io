---
layout: post
title: grunt打包实践
date: 2016-04-10 14:29:25
comments: true
tags:
  - 工具  
  - grunt
categories:
  - 工具
---
# 目的  
学会grunt打包  
并将grunt打包运用于项目实践  

# 前提  
- 了解 `grunt` 的作用与用途  
- 熟悉 `nodejs`  
- 熟悉npm的用法  

# 工具链  
## `grunt` 安装  
由于我们在开发web项目的时候，都要用 `grunt` 打包，为了减少重复操作，所以需要安装 `grunt` 到全局，具体的安装脚本如下:  
```
npm i grunt grunt-cli -g //安装grunt到全局
```

## `less` 安装  
由于在项目开发的过程中，我们用到了less,所以提交安装less到全局，具体的安装脚本:

```
npm i less@latest -g //安装less到全局
```

# 流程  
![打包流程](http://qiniu1.kopbit.com/c8616dc12375f991cd17c3e61b93084e.png)

# 配置  
## 准备 `Grunt` 项目  
一般需要在你的项目中添加两份文件：`package.json` 和 `Gruntfile`。
**package.json**: 此文件被`npm`用于存储项目的元数据，以便将此项目发布为`npm`模块。你可以在此文件中列出项目依赖的`grunt`和`Grunt插件`，放置于`devDependencies`配置段内。  
**Gruntfile**: 此文件被命名为 `Gruntfile.js` 或 `Gruntfile.coffee`，用来配置或定义任务（`task`）并加载`Grunt`插件的。 此文档中提到的 `Gruntfile` 其实说的是一个文件，文件名是 `Gruntfile.js` 或 `Gruntfile.coffee`.  

## 配置 `package.json`  
```
{
  "name": "angularjs-e2e-showcase",     //项目名称             
  "version": "1.0.0",                   //版本号
  "private": true,                      //
  "devDependencies": {                  //开发依赖
    "grunt-contrib-clean": "0.6.0",     //清楚目录或者文件
    "grunt-contrib-jshint": "0.11.0",   //js语法检查
    "grunt-contrib-concat": "0.5.1",    //合并
    "grunt-contrib-uglify": "0.8.0",    //js压缩
    "grunt-contrib-watch": "0.6.1",     //监听
    "grunt-contrib-cssmin": "0.13.0",   //css严肃哦
    "grunt-filerev": "2.3.1",           //文件重命名
    "load-grunt-tasks": "3.2.0",        //加载grunt任务
    "grunt-usemin": "3.0.0",            //
    "grunt-contrib-copy": "0.8.0",      //拷贝
    "grunt-contrib-imagemin": "0.9.4",  //生成雪碧图，并对css相关样式做出调整
    "karma-coverage": "0.4.2",          //
    "grunt-lesslint": "1.4.1",          //less检查
    "grunt-contrib-less": "~1.0.1",     //less生成工具
    "grunt-contrib-htmlmin": "0.6.0",   //html压缩
    "karma-jasmine": "0.3.6",           //
    "busboy": "^0.2.9",                 //
    "fs-extra": "^0.16.4"               //
  }                                     //
```

## 建立 `Gruntfile` 文件结构  
```
/**
 * Created by david on 4/10/2016.
 */
module.exports = function (grunt) {
    require('load-grunt-tasks')(grunt); //加载 load-grunt-tasks grunt插件

    //定义路径变量
    var path = {
        tmp: '.tmp',                        //临时目录
        dest: '.publish',                   //发布目录
        web: ''  //项目站点
    };

    //项目配置文件
    grunt.initConfig({

      pkg: grunt.file.readJSON('package.json'),
      path: path, //申明变量


        //清楚文件和目录
        clean:{

        },

        //编译less文件为css
        less:{

        },

        //生成雪碧图，并修改相应的css文件
        sprite:{

        },

        //拷贝文件
        copy:{

        },

        //合并文件
        concat:{

        },

        //压缩css
        cssmin:{

        },

        //压缩Js
        uglify:{

        },

        //文件重命名
        filerev:{

        },

        //替换文件前准备
        useminPrepare:{

        },

        //替换文件
        usemin:{

        }
    });

    grunt.registerTask(
        'build', //分组名称
        [        //该分组包含的任务
            'clean:beforebuild',
            'less',
            'sprite',
            'copy',
            'concat',
            'cssmin',
            'uglify',
            'filerev',
            'useminPrepare',
            'usemin',
            'clean:afterbuild'
        ]
    );
};
```

### 清除文件目录  
该任务包含两个子任务:  
- 构建前执行脚本  
清除 `dest`，与 `tmp` 相关目录与文件
```
beforebuild: {
    files: [{
        src: ['<%= path.dest %>/', '<%= path.tmp %>/']
    }]
},
```

- 构建后执行脚本  
清除 `tmp` 相关目录与文件
```
afterbuild: {
     files: [{
         src: ['<%= path.tmp %>/']
     }]
 }
```

### 编译less文件  

```
baseStyleCss: {
     options: {
         strictMath: true,
         sourceMap: true,
         outputSourceFiles: true
     },
     src: 'content/stylesheet/less/config.less', //该less文件将导入其他的less文件
     dest: 'content/stylesheet/css/config.css'
 }
```

### 生成雪碧图  
```
options: {
    // 给雪碧图追加时间戳，默认不追加
    spritestamp: true
},
// image-set 示例
imageKityMinderSprite: {
    options: {
        useimageset: true,
        imagepath: "content/images/slice/",         //less文件应用图片的目录地址
        spritedest: '<%= path.tmp%>/images/slice/'  //生成后的雪碧图目录地址
    },
    files: [{
        // 启用动态扩展
        expand: true,
        // css文件源的文件夹
        cwd: 'content/stylesheet/css',
        // 匹配规则
        src: '*.css',
        // 导出css和sprite的路径地址
        dest: '<%= path.tmp%>/css/',
        // 导出的css名
        ext: '.sprite.css'
    }]
}
```
### 拷贝文件  
```
fonts: {                                     //拷贝字体
     expand: true,                           //展开
     cwd: 'content/fonts/',                  //改变当前路径
     src: ['**'],                            //匹配文件的正则表达式
     dest: '<%= path.dest %>/fonts/',        //
     flatten: false                          //
 },                                          //拷贝图片
 images: {                                   //
     expand: true,                           //
     cwd: 'content/images/other',            //
     src: ['**'],                            //
     dest: '<%= path.dest%>/images/other',   //
     flatten: false                          //
 },                                          //拷贝雪碧图
 spriteImages: {                             //
     expand: true,                           //
     cwd: '<%= path.tmp%>/images/slice',     //
     src: ['**'],                            //
     dest: '<%= path.dest%>/images/slice',   //
     flatten: false                          //
 },                                          //拷贝站点小图标
 ico: {                                      //
     src: 'favicon.ico',                     //
     dest: '<%= path.dest%>/'                //
 },                                          //
 indexCopy: {                                //拷贝index.html
     expand: true,                           //
     src: ['index.html'],                    //
     dest: '<%= path.dest%>/',               //
     flatten: false                          //
 },                                          //
 appViewsCopy: {                             //拷贝应用相关html文件
     expand: true,                           //
     cwd: 'app/',                            //
     src: ['**/**.html'],                    //
     dest: '<%= path.dest%>/app/',           //
     flatten: false                          //
 }                                           //
```

### 合并文件  
```
baseCss: { //合并css
    src: [
        "bower_components/bootstrap/dist/css/bootstrap.css",
        "bower_components/angular/angular-csp.css",
        "bower_components/color-picker/dist/color-picker.css",
        "bower_components/codemirror/lib/codemirror.css",
        "bower_components/hotbox/hotbox.css",
        ".tmp/css/config.sprite.css"
    ],
    dest: "<%= path.tmp%>/css/showcase.css"
},
kityminderJs: {
    src: [ //合并js
        "bower_components/angular/angular.js",
        "bower_components/jquery/dist/jquery.js",
        "bower_components/bootstrap/dist/js/bootstrap.js",
        "bower_components/angular-bootstrap/ui-bootstrap.js",
        "bower_components/angular-bootstrap/ui-bootstrap-tpls.js",
        "bower_components/seajs/dist/sea-debug.js",
        "bower_components/color-picker/src/color-picker.js",
        "bower_components/codemirror/lib/codemirror.js",
        "bower_components/codemirror/mode/xml/xml.js",
        "bower_components/codemirror/mode/javascript/javascript.js",
        "bower_components/codemirror/mode/css/css.js",
        "bower_components/codemirror/mode/htmlmixed/htmlmixed.js",
        "bower_components/codemirror/mode/markdown/markdown.js",
        "bower_components/codemirror/addon/mode/overlay.js",
        "bower_components/codemirror/mode/gfm/gfm.js",
        "bower_components/angular-ui-codemirror/ui-codemirror.js",
        "bower_components/kity/dist/kity.js",
        "bower_components/hotbox/hotbox.js",
        "lib/kityminder/src/kityminder.js",
        "bower_components/marked/lib/marked.js",
        "app/kityminder/kityminder.app.js",
        "app/kityminder/templates.js",
        "app/kityminder/service/commandBinder.service.js",
        "app/kityminder/service/config.service.js",
        "app/kityminder/service/memory.service.js",
        "app/kityminder/service/lang.zh-cn.service.js",
        "app/kityminder/service/valueTransfer.service.js",
        "app/kityminder/service/minder.service.js",
        "app/kityminder/service/resource.service.js",
        "app/kityminder/service/revokeDialog.service.js",
        "app/_filter/lang.filter.js",
        "app/_directive/kityminder/topTab/topTab.directive.js",
        "app/_directive/kityminder/undoRedo/undoRedo.directive.js",
        "app/_directive/kityminder/appendNode/appendNode.directive.js",
        "app/_directive/kityminder/arrange/arrange.directive.js",
        "app/_directive/kityminder/operation/operation.directive.js",
        "app/_directive/kityminder/hyperLink/hyperLink.directive.js",
        "app/_directive/kityminder/imageBtn/imageBtn.directive.js",
        "app/_directive/kityminder/noteBtn/noteBtn.directive.js",
        "app/_directive/kityminder/resourceEditor/resourceEditor.directive.js",
        "app/_directive/kityminder/priorityEditor/priorityEditor.directive.js",
        "app/_directive/kityminder/progressEditor/progressEditor.directive.js",
        "app/_directive/kityminder/noteEditor/noteEditor.directive.js",
        "app/_directive/kityminder/notePreviewer/notePreviewer.directive.js",
        "app/_directive/kityminder/templateList/templateList.directive.js",
        "app/_directive/kityminder/themeList/themeList.directive.js",
        "app/_directive/kityminder/layout/layout.directive.js",
        "app/_directive/kityminder/styleOperator/styleOperator.directive.js",
        "app/_directive/kityminder/fontOperator/fontOperator.directive.js",
        "app/_directive/kityminder/expandLevel/expandLevel.directive.js",
        "app/_directive/kityminder/selectAll/selectAll.directive.js",
        "app/_directive/kityminder/colorPanel/colorPanel.directive.js",
        "app/_directive/kityminder/navigator/navigator.directive.js",
        "app/_directive/kityminder/searchBox/searchBox.directive.js",
        "app/_directive/kityminder/searchBtn/searchBtn.directive.js",
        "app/kityminder/dialog/hyperlink/hyperlink.ctrl.js",
        "app/kityminder/dialog/image/image.ctrl.js",
        "app/kityminder/dialog/im-export-node/imExportNode.ctrl.js",
        "app/_directive/kityminder/kityminderEditor/kityminderEditor.directive.js",
        "lib/kityminder/src/expose-kityminder.js",
        "app/app.module.js",
        "app/kityminder/kityminder-main-controller.js"
    ],
    dest: "<%= path.tmp%>/js/showcase.js"
}
```

### 压缩css  
```
kopBaseCss: {
    src: ["<%= path.tmp%>/css/showcase.css"],
    dest: "<%= path.dest %>/css/showcase.css"
}
```

### 压缩Js  
```
baseJs: {
    src: "<%= path.tmp%>/js/showcase.js",
    dest: "<%= path.dest%>/js/showcase.js"
}
```


### 文件重命名  
```
build: {
    files: [{
        src: ['<%= path.dest %>/js/**.js', '<%= path.dest %>/css/**'] //只是对js于css重新命名
    }]
}
```


### 替换文件前准备  
```
html: '<%= path.dest %/**/*.html',
 options: {
     dest: './<%= path.dest %>',
     root: './<%= path.dest %>'
 }
```


### 替换文件  
```
html: {
    files: [{
        src: '<%= path.dest %>/**/*.html'
    }]
},
options: {
    assetsDirs: ['<%= path.dest %>']
}
```

# 实例  
项目地址传送门:  
https://github.com/haibinpark/angular-e2etest-showcase.git

# 参考  
[Gruntjs官方网站](http://gruntjs.com/)  
[Gruntjs中文网站](http://www.gruntjs.net/)
