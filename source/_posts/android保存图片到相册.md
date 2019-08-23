---
layout: android保存图片到相册
title: android保存图片到相册
date: 2019-08-23 14:53:26
tags: [kotlin,java,android,相册,保存图片]
---
# 背景
我们在开发应用的时候，会有保存图片到相册的功能。

# 实现
## 授权 
```
 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
 <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```
## 关键代码
```
fun getGalleryPath(context: Context)  = buildString {
        append(Environment.getExternalStorageDirectory())
        append(File.separator)
        append(Environment.DIRECTORY_DCIM)
        append(File.separator)
        append("Camera")
        append(File.separator)
    }
AsyncTask.execute {
                    Runnable {
                        try {
                            val file = File(buildString {
                                append(DirectoryUtils.getGalleryPath(this@ChargeActivity))
                                append(imageName)
                            })
                            if (file.exists())
                                file.delete()
                            file.createNewFile()
                            val fos = FileOutputStream(file)
                            qrBitmap?.compress(Bitmap.CompressFormat.PNG, 100, fos)
                            fos.flush()
                            fos.close()
                            runOnUiThread {
                                ToastUtil.shortShow("图片${file}已经保存")
                            }
                            val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                            val uri = Uri.fromFile(file)
                            intent.data = uri
                            sendBroadcast(intent)
                        } catch (e: Exception) {
                            e.printStackTrace()
                            runOnUiThread {
                                ToastUtil.shortShow("保存图片失败")
                            }
                        }
                    }.run()
                }
```
# 结语  
有时候我们调用了保存图片到相册的方法，我们选择图片的时候，找不到相关图片，添加下面代码即可。这样在图片文件件中就可以看见了。
```
val intent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
val uri = Uri.fromFile(file)
intent.data = uri
sendBroadcast(intent)
```