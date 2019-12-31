---
layout: Flutter通过Mqtt消费ActivieMQ
title: Flutter通过Mqtt消费ActivieMQ
date: 2019-12-31 11:22:13
tags:
---
Flutter通过mqtt消费activemq，在android端主要使用插件的方式进行
# 处理流程
![](http://tp.linqmind.com/2019-12-31-042856.jpg)

# Android端连接MQTT
## 插件端业务处理
### step1:配置插件依赖包
```

    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.google.code.gson:gson:2.8.5'
    implementation 'org.eclipse.paho:org.eclipse.paho.client.mqttv3:1.1.0'
    implementation 'org.eclipse.paho:org.eclipse.paho.android.service:1.1.1'
    implementation 'androidx.legacy:legacy-support-v4:1.0.0'
    implementation 'androidx.appcompat:appcompat:1.1.0-rc01'
    implementation 'androidx.constraintlayout:constraintlayout:1.1.3'
    implementation 'androidx.recyclerview:recyclerview:1.0.0'
    implementation 'androidx.multidex:multidex:2.0.1'
    implementation 'androidx.multidex:multidex-instrumentation:2.0.0'
    implementation 'com.google.android.material:material:1.1.0-alpha08'
```

### step2 实现连接方法
```
class MqttClientPlugin : MethodCallHandler {
    override fun onMethodCall(call: MethodCall,     result: Result) {
        when (call.method) {
            "connectMq" -> {
                    try {
                        connectToService()
                        result.success(true)
                    } catch (e: Exception) {
                        e.printStackTrace()
                        result.success(false)
                    }
                }
        }
    }
    private fun connectToService() {
        val intent = Intent(context, MqttClientService::class.java)
        this.context?.startService(intent)
    }
}
```

### step3 实现mqttclient服务
```
class MqTTClientService : Service {

    private val TAG = "ActiveMQ"
    val clientId = "any_client_name"
    val serverURI = "tcp://192.168.0.201:1883" //replace with your ip
    val publishTopic = "outbox"
    val subscribeTopic = "TJ Test"
    var client: MqttAndroidClient? = null

    constructor() : super()

    val MY_ACTION = "MY_ACTION"

    var _currentV: Int = 0


    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val myThread = MyThrad()
        myThread.start()
        return super.onStartCommand(intent, flags, startId)
    }

    private fun subscribe() {
        try {
            client?.subscribe(subscribeTopic, 0, IMqttMessageListener { topic, message ->
                Log.i("接收到监听的消息:", "${message.payload}")
            })
        } catch (e: MqttException) {
            e.printStackTrace()
        }

    }

    inner class MyThrad : Thread() {

        override fun run() {
            val connectOptions = MqttConnectOptions()
            connectOptions.isAutomaticReconnect = true

            client = MqttAndroidClient(this@MqTTClientService.applicationContext, serverURI, clientId)
            try {
                client?.connect(connectOptions, object : IMqttActionListener {
                    override fun onSuccess(asyncActionToken: IMqttToken) {
                        subscribe()
                    }

                    override fun onFailure(asyncActionToken: IMqttToken, e: Throwable) {
                        Log.i("连接错误:", "${e.message}")
                    }
                })
            } catch (e: MqttException) {
                e.printStackTrace()
            }
        }

        private fun subscribe() {
            try {
                client?.subscribe(subscribeTopic, 0) { topic, message ->
                    //通过广播发送监听到的消息
                    val intent = Intent()
                    intent.action = MY_ACTION
                    intent.putExtra("DATAPASSED", message.toString())
                    sendBroadcast(intent)
                }
            } catch (e: MqttException) {
                e.printStackTrace()
            }

        }

    }
}

```

### step4监听广播
```
class DevicemanagerPlugin : MethodCallHandler {
    constructor(context: Context?, channel: MethodChannel) {
            this.context = context
            this.channel = channel
            initMqtt()
            register()
        }
    private fun register() {
            myReceiver = MyReceiver()
            val intentFilter = IntentFilter()
            intentFilter.addAction("MY_ACTION")
            this.context?.registerReceiver(myReceiver, intentFilter)
        }

    inner class MyReceiver : BroadcastReceiver() {

        override fun onReceive(context: Context?, intent: Intent?) {
            try {
                val value = intent?.getStringExtra("DATAPASSED")
                //将监听到的消息，通过methchannel传给flutter
                channel?.invokeMethod("receiveMsg", value)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }    
}
```
## Flutter端业务处理

### 实现receiveMsg方法
```
const channel = const MethodChannel("mqttclient");
class _MyHomePageState extends State<MyHomePage> {
    @override
  void initState() {
      registerMethod()
      connectActiveMq()
  }

  void connectActiveMq() async{
    if (Platform.isAndroid) {
      var result = await Devicemanager.connectMq(API.MQ_URI);
      if (result) {
         print("mq链接成功");
      } else {
         print("mq链接失败");
      }
    }
  }

  void registerMethod() {
    channel.setMethodCallHandler((handler) {
      var completer = new Completer<String>();
      try {
        switch (handler.method) {
          case "receiveMsg":
            //接收到的消息
            var v = handler.arguments;
            break;
          default:
            break;
        }
      } catch (e) {
        print(e);
      }
      return completer.future;
    });
  }

}
```
