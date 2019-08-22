---
layout: android手机消息监听
title: android手机消息监听
date: 2019-08-16 16:36:29
tags: [Android,消息监听,通知栏消息,Java]
---
# 背景
以前做了个项目，客户要求对手机的消息进行监听，并通过监听的消息，推送到智能手环，要如何实现，经过查找发现，我们可以监听通知栏的消息，然后再根据通知栏的消息按照相关类型进行推送。

# 开发语言
java,kotlin,android,

# 相关代码
## 建立监听通知消息的`Service`
```
public class NotificationCollectorService extends NotificationListenerService {
    //来通知时的调用
    @Override
    public void onNotificationPosted(StatusBarNotification sbn) {
        super.onNotificationPosted(sbn);
        Notification notification = sbn.getNotification();
        if (notification == null) {
            return;
        }

        Bundle extras = notification.extras;
        String content = "";
        if (extras != null) {
            // 获取通知标题
            String title = extras.getString(Notification.EXTRA_TITLE, "");
            // 获取通知内容
            content = extras.getString(Notification.EXTRA_TEXT, "");
            Log.i("包名：", sbn.getPackageName() + "标题:" + title + "内容:" + content);
        }
        switch (sbn.getPackageName()) {
            case "com.tencent.mm":
                Log.i("微信", content);
                EventBus.getDefault().post(new BusEventExtBean<String>(BusEventType.WECHAT, content));
                break;
            case "com.android.mms":
                Log.i("短信信", content);
                EventBus.getDefault().post(new BusEventExtBean<String>(BusEventType.SMS, content));
                break;
            case "com.tencent.mobileqq":
                Log.i("qq", content);
                EventBus.getDefault().post(new BusEventExtBean<String>(BusEventType.QQ, content));
                break;
            case "com.tencent.tim":
                Log.i("tim", content);
                EventBus.getDefault().post(new BusEventExtBean<String>(BusEventType.TIM, content));
                break;
            case "com.android.incallui":
                Log.i("电话", content);
                EventBus.getDefault().post(new BusEventExtBean<String>(BusEventType.CALL, content));
                break;
        }

    }

    //删除通知时的调用
    @Override
    public void onNotificationRemoved(StatusBarNotification sbn) {
        super.onNotificationRemoved(sbn);
        Notification notification = sbn.getNotification();
        if (notification == null) {
            return;
        }
        Bundle extras = notification.extras;
        String content = "";
        if (extras != null) {
            // 获取通知标题
            String title = extras.getString(Notification.EXTRA_TITLE, "");
            // 获取通知内容
            content = extras.getString(Notification.EXTRA_TEXT, "");
            Log.i("删包名：", sbn.getPackageName() + "标题:" + title + "内容:" + content);
        }
        switch (sbn.getPackageName()) {
            case "com.tencent.mm":
                Log.i("删微信", content);
                break;
            case "com.android.mms":
                Log.i("删短信", content);
                break;
            case "com.tencent.mqq":
                Log.i("删qq", content);
                break;
            case "com.tencent.tim":
                Log.i("删tim", content);
                break;
            case "com.android.incallui":
                Log.i("删电话", content);
                break;
        }
    }
}
```

## 在`AndroidManifest.xml`中设置service
```
<service
                android:name=".service.NotificationCollectorService"
                android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService"/>
            </intent-filter>
        </service>
```

## 在相关页面设置监听
```
if (!isNotificationListenerEnabled(this)) {
    openNotificationListenSettings();
}
toggleNotificationListenerService();

public boolean isNotificationListenerEnabled(Context context) {
    Set<String> packageNames = NotificationManagerCompat.getEnabledListenerPackages(this);
    if (packageNames.contains(context.getPackageName())) {
        return true;
    }
    return false;
}

//把应用的NotificationListenerService实现类disable再enable，即可触发系统rebind操作
    private void toggleNotificationListenerService() {
        PackageManager pm = getPackageManager();
        pm.setComponentEnabledSetting(
                new ComponentName(this, NotificationCollectorService.class),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP);

        pm.setComponentEnabledSetting(
                new ComponentName(this, NotificationCollectorService.class),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP);
    }

    private void openNotificationListenSettings() {
        try {
            Intent intent;
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP_MR1) {
                intent = new Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS);
            } else {
                intent = new Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS");
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        } catch (ActivityNotFoundException e) {//普通情况下找不到的时候需要再特殊处理找一次
            try {
                Intent intent = new Intent();
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                ComponentName cn = new ComponentName("com.android.settings", "com.android.settings.Settings$NotificationAccessSettingsActivity");
                intent.setComponent(cn);
                intent.putExtra(":settings:show_fragment", "NotificationAccessSettings");
                startActivity(intent);
            } catch (Exception e1) {
                e1.printStackTrace();
            }
            Toast.makeText(this, "对不起，您的手机暂不支持", Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

```
这里要注意的是，这些设置添加了后，需要用户重新安装`App`