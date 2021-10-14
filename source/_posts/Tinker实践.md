title: Tinker实践
date: 2016-11-21 17:46:50
tags:
 - android
 - tinker
 - hotfix
categories:
 - android
---
# 什么是Tinker  
Tinker是腾讯开源的热更新方案，通过热更新，可以使android应用的bug得到及时修复，并让用户得到无感升级，tinker的热更新方案，并不能够替代版本发布。但他非常适合紧急且重要的BUG修复。  

# 准备   
## 准备Android工程  
准备一个项目`TinkerPractice`  
![创建项目](https://tp.linqmind.com/2016-11-21-tinker_create_project.png)  
![](https://tp.linqmind.com/2016-11-21-tinker_create_project2.png)
# 配置  
配置包含两个方面  
- `Tinker` 集成配置
- `TinkerPatch SDK` 集成配置  
## `Tinker` 集成配置  
现在`Tinker`接入有两种方式，`gradle`接入与命令行接入，再这里我们只实践`gradle`接入，因为在`gradle`接入方式中，`gradle`插件`tinker-patch-gradle-plugin`中我们帮你完成`proguard、multiDex`以及`Manifest`处理等工作。  
### 添加 `Gradle` 依赖  
在项目的`build.gradle`中，添加`tinker-patch-gradle-plugin`的依赖  
```
buildscript {
    dependencies {
      ......
        classpath ('com.tencent.tinker:tinker-patch-gradle-plugin:1.7.5')
      ......
    }
}
```

然后在app的gradle文件app/build.gradle，我们需要添加tinker的库依赖以及apply tinker的gradle插件.  
```
dependencies {
    //可选，用于生成application类
    provided('com.tencent.tinker:tinker-android-anno:1.7.5')
    //tinker的核心库
    compile('com.tencent.tinker:tinker-android-lib:1.7.5')
}
...
...
//apply tinker插件
apply plugin: 'com.tencent.tinker.patch'
```
### `app/build.gradle` 参数说明
```
apply plugin: 'com.android.application'
apply plugin: 'com.tencent.tinker.patch'


dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
        exclude group: 'com.android.support', module: 'support-annotations'
    })
    compile 'com.android.support:appcompat-v7:25.0.1'
    testCompile 'junit:junit:4.12'
    //optional, help to generate the final application
    provided('com.tencent.tinker:tinker-android-anno:1.7.5')
    //tinker's main Android lib
    compile('com.tencent.tinker:tinker-android-lib:1.7.5')

    //该参数解决Dex方法数的超出限制问题。
    compile "com.android.support:multidex:1.0.1"

}

//获得git版本头部信息，后面赋值给thinkerId
def gitSha() {
    try {
        String gitRev = 'git rev-parse --short HEAD'.execute(null, project.rootDir).text.trim()
        if (gitRev == null) {
            throw new GradleException("can't get git rev, you should add git to system path or just input test value, such as 'testTinkerId'")
        }
        return gitRev
    } catch (Exception e) {
        throw new GradleException("can't get git rev, you should add git to system path or just input test value, such as 'testTinkerId'")
    }
}

def javaVersion = JavaVersion.VERSION_1_7


android {
    compileSdkVersion 25
    buildToolsVersion "25.0.0"

    compileOptions {
        sourceCompatibility javaVersion
        targetCompatibility javaVersion
    }


    //recommend
    dexOptions {
      //忽略方法数限制的检查
        jumboMode = true
    }


    //签名设置
    signingConfigs {
        release {
            try {
                storeFile file("./keystore/release.jks")
                storePassword "11111111"
                keyAlias "LLM-TINKER"
                keyPassword "11111111"
            } catch (ex) {
                throw new InvalidUserDataException(ex.toString())
            }
        }

        debug {
            try {
                storeFile file("./keystore/debug.jks")
                storePassword "11111111"
                keyAlias "LLM-TINKER"
                keyPassword "11111111"
            } catch (ex) {
                throw new InvalidUserDataException(ex.toString())
            }
        }
    }


    defaultConfig {
        applicationId "com.wkllme.llmwithtinker"
        minSdkVersion 10
        targetSdkVersion 25
        versionCode 1
        versionName "1.0"

        /**
         * you can use multiDex and install it in your ApplicationLifeCycle implement
         * 分包
         */
        multiDexEnabled true
        /**
         * not like proguard, multiDexKeepProguard is not a list, so we can't just
         * add for you in our task. you can copy tinker keep rules at
         * build/intermediates/tinker_intermediates/tinker_multidexkeep.pro
         */
        multiDexKeepProguard file("keep_in_main_dex.txt")
        /**
         * buildConfig can change during patch!
         * we can use the newly value when patch
         */
        buildConfigField "String", "MESSAGE", "\"I am the base apk\""
//        buildConfigField "String", "MESSAGE", "\"I am the patch apk\""
        /**
         * client version would update with patch
         * so we can get the newly git version easily!
         * 设置编译参数TINKER_ID，PLATEFORM
         */
        buildConfigField "String", "TINKER_ID", "\"${getTinkerIdValue()}\""
        buildConfigField "String", "PLATFORM",  "\"all\""
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
    buildTypes {
        release {
            minifyEnabled true
            signingConfig signingConfigs.release
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
        debug {
            debuggable true
            minifyEnabled false
            signingConfig signingConfigs.debug
        }
    }
    sourceSets {
        main {
            jniLibs.srcDirs = ['libs']
        }
    }
}


//定义构建路径，这里其实可以放在最外面 `rootDir`
def bakPath = file("${buildDir}/bakApk/")

/**
 * you can use assembleRelease to build you base apk
 * use tinkerPatchRelease -POLD_APK=  -PAPPLY_MAPPING=  -PAPPLY_RESOURCE= to build patch
 * add apk from the build/bakApk
 */
ext {
    //for some reason, you may want to ignore tinkerBuild, such as instant run debug build?
    //true 启用tinker,false 禁用tinker,一般在调试的时候，可以将tinkerEnable 设置为false.
    tinkerEnabled = true

    //for normal build
    //old apk file to build patch apk
    tinkerOldApkPath = "${bakPath}/app-debug-1128-18-12-15.apk"
    //proguard mapping file to build patch apk
//    tinkerApplyMappingPath = "${bakPath}/app-debug-1018-17-32-47-mapping.txt"
    //resource R.txt to build patch apk, must input if there is resource changed
    tinkerApplyResourcePath = "${bakPath}/app-debug-1128-18-12-15-R.txt"

    //only use for build all flavor, if not, just ignore this field
    //tinkerBuildFlavorDirectory = "${bakPath}/app-1018-17-32-47"
}


def getOldApkPath() {
    return hasProperty("OLD_APK") ? OLD_APK : ext.tinkerOldApkPath
}

def getApplyMappingPath() {
    return hasProperty("APPLY_MAPPING") ? APPLY_MAPPING : ext.tinkerApplyMappingPath
}

def getApplyResourceMappingPath() {
    return hasProperty("APPLY_RESOURCE") ? APPLY_RESOURCE : ext.tinkerApplyResourcePath
}

def getTinkerIdValue() {
    return hasProperty("TINKER_ID") ? TINKER_ID : gitSha()
}

def buildWithTinker() {
    return hasProperty("TINKER_ENABLE") ? TINKER_ENABLE : ext.tinkerEnabled
}

def getTinkerBuildFlavorDirectory() {
    return ext.tinkerBuildFlavorDirectory
}

if (buildWithTinker()) {
    apply plugin: 'com.tencent.tinker.patch'

    tinkerPatch {
        /**
         * necessary，default 'null'
         * the old apk path, use to diff with the new apk to build
         * add apk from the build/bakApk
         */
        oldApk = getOldApkPath()
        /**
         * optional，default 'false'
         * there are some cases we may get some warnings
         * if ignoreWarning is true, we would just assert the patch process
         * case 1: minSdkVersion is below 14, but you are using dexMode with raw.
         *         it must be crash when load.
         * case 2: newly added Android Component in AndroidManifest.xml,
         *         it must be crash when load.
         * case 3: loader classes in dex.loader{} are not keep in the main dex,
         *         it must be let tinker not work.
         * case 4: loader classes in dex.loader{} changes,
         *         loader classes is ues to load patch dex. it is useless to change them.
         *         it won't crash, but these changes can't effect. you may ignore it
         * case 5: resources.arsc has changed, but we don't use applyResourceMapping to build
         */
        ignoreWarning = true

        /**
         * optional，default 'true'
         * whether sign the patch file
         * if not, you must do yourself. otherwise it can't check success during the patch loading
         * we will use the sign config with your build type
         */
        useSign = true

        /**
         * Warning, applyMapping will affect the normal android build!
         */
        buildConfig {
            /**
             * optional，default 'null'
             * if we use tinkerPatch to build the patch apk, you'd better to apply the old
             * apk mapping file if minifyEnabled is enable!
             * Warning:
             * you must be careful that it will affect the normal assemble build!
             */
//            applyMapping = getApplyMappingPath()
            /**
             * optional，default 'null'
             * It is nice to keep the resource id from R.txt file to reduce java changes
             */
            applyResourceMapping = getApplyResourceMappingPath()

            /**
             * necessary，default 'null'
             * because we don't want to check the base apk with md5 in the runtime(it is slow)
             * tinkerId is use to identify the unique base apk when the patch is tried to apply.
             * we can use git rev, svn rev or simply versionCode.
             * we will gen the tinkerId in your manifest automatic
             */
            tinkerId = getTinkerIdValue()
        }

        dex {
            /**
             * optional，default 'jar'
             * only can be 'raw' or 'jar'. for raw, we would keep its original format
             * for jar, we would repack dexes with zip format.
             * if you want to support below 14, you must use jar
             * or you want to save rom or check quicker, you can use raw mode also
             */
            dexMode = "jar"
            /**
             * optional，default 'false'
             * if usePreGeneratedPatchDex is true, tinker framework will generate auxiliary class
             * and insert auxiliary instruction when compiling base package using
             * assemble{Debug/Release} task to prevent class pre-verified issue in dvm.
             * Besides, a real dex file contains necessary class will be generated and packed into
             * patch package instead of any patch info files.
             *
             * Use this mode if you have to use any dex encryption solutions.
             *
             * Notice: If you change this value, please trigger clean task
             * and regenerate base package.
             */
            usePreGeneratedPatchDex = false
            /**
             * necessary，default '[]'
             * what dexes in apk are expected to deal with tinkerPatch
             * it support * or ? pattern.
             */
            pattern = ["classes*.dex",
                       "assets/secondary-dex-?.jar"]
            /**
             * necessary，default '[]'
             * Warning, it is very very important, loader classes can't change with patch.
             * thus, they will be removed from patch dexes.
             * you must put the following class into main dex.
             * Simply, you should add your own application {@code tinker.sample.android.SampleApplication}
             * own tinkerLoader, and the classes you use in them
             *
             */
            loader = ["com.tencent.tinker.loader.*",
                      //warning, you must change it with your application
                      "com.wkllme.llmwithtinker.app.LLMApplication",
                      //use sample, let BaseBuildInfo unchangeable with tinker
                      "com.wkllme.llmwithtinker.app.BaseBuildInfo"
            ]
        }

        lib {
            /**
             * optional，default '[]'
             * what library in apk are expected to deal with tinkerPatch
             * it support * or ? pattern.
             * for library in assets, we would just recover them in the patch directory
             * you can get them in TinkerLoadResult with Tinker
             */
            pattern = ["lib/armeabi/*.so"]
        }

        res {
            /**
             * optional，default '[]'
             * what resource in apk are expected to deal with tinkerPatch
             * it support * or ? pattern.
             * you must include all your resources in apk here,
             * otherwise, they won't repack in the new apk resources.
             */
            pattern = ["res/*", "assets/*", "resources.arsc", "AndroidManifest.xml"]

            /**
             * optional，default '[]'
             * the resource file exclude patterns, ignore add, delete or modify resource change
             * it support * or ? pattern.
             * Warning, we can only use for files no relative with resources.arsc
             */
            ignoreChange = ["assets/sample_meta.txt"]

            /**
             * default 100kb
             * for modify resource, if it is larger than 'largeModSize'
             * we would like to use bsdiff algorithm to reduce patch file size
             */
            largeModSize = 100
        }

        packageConfig {
            /**
             * optional，default 'TINKER_ID, TINKER_ID_VALUE' 'NEW_TINKER_ID, NEW_TINKER_ID_VALUE'
             * package meta file gen. path is assets/package_meta.txt in patch file
             * you can use securityCheck.getPackageProperties() in your ownPackageCheck method
             * or TinkerLoadResult.getPackageConfigByName
             * we will get the TINKER_ID from the old apk manifest for you automatic,
             * other config files (such as patchMessage below)is not necessary
             */
            configField("patchMessage", "tinker is sample to use")
            /**
             * just a sample case, you can use such as sdkVersion, brand, channel...
             * you can parse it in the SamplePatchListener.
             * Then you can use patch conditional!
             */
            configField("platform", "all")
            /**
             * patch version via packageConfig
             */
            configField("patchVersion", "1.0")
        }
        //or you can add config filed outside, or get meta value from old apk
        //project.tinkerPatch.packageConfig.configField("test1", project.tinkerPatch.packageConfig.getMetaDataFromOldApk("Test"))
        //project.tinkerPatch.packageConfig.configField("test2", "sample")

        /**
         * if you don't use zipArtifact or path, we just use 7za to try
         */
        sevenZip {
            /**
             * optional，default '7za'
             * the 7zip artifact path, it will use the right 7za with your platform
             */
            zipArtifact = "com.tencent.mm:SevenZip:1.1.10"
            /**
             * optional，default '7za'
             * you can specify the 7za path yourself, it will overwrite the zipArtifact value
             */
//        path = "/usr/local/bin/7za"
        }
    }

    List<String> flavors = new ArrayList<>();
    project.android.productFlavors.each {flavor ->
        flavors.add(flavor.name)
    }
    boolean hasFlavors = flavors.size() > 0
    /**
     * bak apk and mapping
     */
    android.applicationVariants.all { variant ->
        /**
         * task type, you want to bak
         */
        def taskName = variant.name
        def date = new Date().format("MMdd-HH-mm-ss")

        tasks.all {
            if ("assemble${taskName.capitalize()}".equalsIgnoreCase(it.name)) {

                it.doLast {
                    copy {
                        def fileNamePrefix = "${project.name}-${variant.baseName}"
                        def newFileNamePrefix = hasFlavors ? "${fileNamePrefix}" : "${fileNamePrefix}-${date}"

                        def destPath = hasFlavors ? file("${bakPath}/${project.name}-${date}/${variant.flavorName}") : bakPath
                        from variant.outputs.outputFile
                        into destPath
                        rename { String fileName ->
                            fileName.replace("${fileNamePrefix}.apk", "${newFileNamePrefix}.apk")
                        }

                        from "${buildDir}/outputs/mapping/${variant.dirName}/mapping.txt"
                        into destPath
                        rename { String fileName ->
                            fileName.replace("mapping.txt", "${newFileNamePrefix}-mapping.txt")
                        }

                        from "${buildDir}/intermediates/symbols/${variant.dirName}/R.txt"
                        into destPath
                        rename { String fileName ->
                            fileName.replace("R.txt", "${newFileNamePrefix}-R.txt")
                        }
                    }
                }
            }
        }
    }
    project.afterEvaluate {
        //sample use for build all flavor for one time
        if (hasFlavors) {
            task(tinkerPatchAllFlavorRelease) {
                group = 'tinker'
                def originOldPath = getTinkerBuildFlavorDirectory()
                for (String flavor : flavors) {
                    def tinkerTask = tasks.getByName("tinkerPatch${flavor.capitalize()}Release")
                    dependsOn tinkerTask
                    def preAssembleTask = tasks.getByName("process${flavor.capitalize()}ReleaseManifest")
                    preAssembleTask.doFirst {
                        String flavorName = preAssembleTask.name.substring(7, 8).toLowerCase() + preAssembleTask.name.substring(8, preAssembleTask.name.length() - 15)
                        project.tinkerPatch.oldApk = "${originOldPath}/${flavorName}/${project.name}-${flavorName}-release.apk"
                        project.tinkerPatch.buildConfig.applyMapping = "${originOldPath}/${flavorName}/${project.name}-${flavorName}-release-mapping.txt"
                        project.tinkerPatch.buildConfig.applyResourceMapping = "${originOldPath}/${flavorName}/${project.name}-${flavorName}-release-R.txt"

                    }

                }
            }

            task(tinkerPatchAllFlavorDebug) {
                group = 'tinker'
                def originOldPath = getTinkerBuildFlavorDirectory()
                for (String flavor : flavors) {
                    def tinkerTask = tasks.getByName("tinkerPatch${flavor.capitalize()}Debug")
                    dependsOn tinkerTask
                    def preAssembleTask = tasks.getByName("process${flavor.capitalize()}DebugManifest")
                    preAssembleTask.doFirst {
                        String flavorName = preAssembleTask.name.substring(7, 8).toLowerCase() + preAssembleTask.name.substring(8, preAssembleTask.name.length() - 13)
                        project.tinkerPatch.oldApk = "${originOldPath}/${flavorName}/${project.name}-${flavorName}-debug.apk"
                        project.tinkerPatch.buildConfig.applyMapping = "${originOldPath}/${flavorName}/${project.name}-${flavorName}-debug-mapping.txt"
                        project.tinkerPatch.buildConfig.applyResourceMapping = "${originOldPath}/${flavorName}/${project.name}-${flavorName}-debug-R.txt"
                    }

                }
            }
        }
    }
}

```
### 核心代码  
`application = "com.wkllme.llmwithtinker.app.LLMApplication"`  
需要定义应用名称，这里需要与AndroidManifest.xml的文件保持一致
```
    ......
<application
    android:name=".app.LLMApplication"
    ......
```

ApplicationLike.java  
```
@SuppressWarnings("unused")
@DefaultLifeCycle(
        application = "com.wkllme.llmwithtinker.app.LLMApplication",
        flags = ShareConstants.TINKER_ENABLE_ALL,
        loadVerifyFlag = false
)
public class LLMApplicationLike extends DefaultApplicationLike {
    public LLMApplicationLike(Application application, int tinkerFlags, boolean tinkerLoadVerifyFlag, long applicationStartElapsedTime, long applicationStartMillisTime, Intent tinkerResultIntent, Resources[] resources, ClassLoader[] classLoader, AssetManager[] assetManager) {
        super(application, tinkerFlags, tinkerLoadVerifyFlag, applicationStartElapsedTime, applicationStartMillisTime, tinkerResultIntent, resources, classLoader, assetManager);
    }


    @Override
    public void onBaseContextAttached(Context base) {
        super.onBaseContextAttached(base);
        MultiDex.install(base);
        LLMApplicationContext.application = getApplication();
        LLMApplicationContext.context = getApplication();

        TinkerManager.setTinkerApplicationLike(this);
        TinkerManager.initFastCrashProtect();
        //should set before tinker is installed
        TinkerManager.setUpgradeRetryEnable(true);

        //optional set logIml, or you can use default debug log
        TinkerInstaller.setLogIml(new MyLogImp());

        //installTinker after load multiDex
        //or you can put com.tencent.tinker.** to main dex
        TinkerManager.installTinker(this);
    }

    //一些初始化的操作可以放在这里面
    @Override
    public void onCreate() {
       super.onCreate();
    }
}
```

加载更新补丁  
```
  TinkerInstaller.onReceiveUpgradePatch(getApplicationContext(),
                              Environment.getExternalStorageDirectory().getAbsolutePath() + "/patch_signed_7zip.apk");
  Toast
          .makeText(MainActivity.this, "更新补丁成功", Toast.LENGTH_LONG)
          .show();
```
### 测试  
再项目目录下执行  
```
./gradlew assembleDebug
```
会生成以下目录  
![生成的apk目录](https://tp.linqmind.com/5d3fdfae7e351c76e70a5acfc4942185.png)
现在生成的目录在build目录下，清理了后就没有了，如果需要保存构建的版本，则可以把目录移出去
，具体设置位置，在`app/build.gralde` 的
```
def bakPath = file("${buildDir}/bakApk/")
```
通过命令行安装版本  
```
#!/bin/bash
adb -s LJJVBQ5HUG59T89D push /Users/Shared/code/LLMWithTinker/app/build/bakApk/app-debug-1212-14-55-66.apk /data/local/tmp/com.wkllme.llmwithtinker
adb -s LJJVBQ5HUG59T89D shell pm install -r "/data/local/tmp/com.wkllme.llmwithtinker"
```
>LJJVBQ5HUG59T89D 连接的设备名称，根据具体的情况进行设置。

安装了后，对这个安装包进行补丁操作，这里需要注意的是发的安装包与发补丁的包的tinkerid必须保持一致，即git的版本保持一致。
设置需要打补丁的app
```
/**
 * you can use assembleRelease to build you base apk
 * use tinkerPatchRelease -POLD_APK=  -PAPPLY_MAPPING=  -PAPPLY_RESOURCE= to build patch
 * add apk from the build/bakApk
 */
ext {
    //for some reason, you may want to ignore tinkerBuild, such as instant run debug build?
    tinkerEnabled = true

    //for normal build
    //old apk file to build patch apk
    tinkerOldApkPath = "${bakPath}/app-debug-1212-14-55-56.apk"
    //proguard mapping file to build patch apk
//    tinkerApplyMappingPath = "${bakPath}/app-debug-1212-14-55-56-mapping.txt"
    //resource R.txt to build patch apk, must input if there is resource changed
    tinkerApplyResourcePath = "${bakPath}/app-debug-1212-14-55-56-R.txt"

    //only use for build all flavor, if not, just ignore this field
    //tinkerBuildFlavorDirectory = "${bakPath}/app-1018-17-32-47"
}
```

设置完毕后，执行补丁命令  
```
./gradlew tinkerPatchDebug
```

会生成补丁信息  
![补丁信息](https://tp.linqmind.com/13168fd43b8e63cb49ed52a40349a18d.png)
上传补丁至设备  
```
#!/bin/bash
adb -s LJJVBQ5HUG59T89D  push /Users/Shared/code/LLMWithTinker/app/build/outputs/tinkerPatch/debug/patch_signed_7zip.apk /storage/emulated/0/

```
>LJJVBQ5HUG59T89D 连接的设备名称，根据具体的情况进行设置。

设置好后，启动应用，加载补丁，退出应用  
```
android.os.Process.killProcess(android.os.Process.myPid());

```
重新打开应用，则补丁已经修复。

# 附录  
示例地址: https://github.com/haibinpark/tinkerdemo  
wiki地址: https://github.com/Tencent/tinker/wiki  
