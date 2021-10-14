---
layout: android解压文件并读取文件内容
title: android解压文件并读取文件内容
date: 2020-07-02 10:38:14
tags: [Android,解压,文件读取]
---
# 背景
在进行地图的地理位置轨迹开发的时候，由于坐标位置的数量比较的大，所以每天对地理位置进行归档，手机端要显示的话，就通过连接地址进行下载,解压后转换为对象进行展示。
# 样本文件
```
104.0716,30.553305|测试点0|1593592450986
104.071083,30.553313|测试点1|1593592451986
104.071061,30.553608|测试点2|1593592452986
104.070863,30.553632|测试点3|1593592453986
104.070737,30.553997|测试点4|1593592454986
104.07063,30.554355|测试点5|1593592450586
104.071137,30.554409|测试点6|1593592456986
104.071366,30.554417|测试点7|1593592457986
104.071636,30.554254|测试点8|1593592458986
104.07164,30.554118|测试点9|1593592459986
```
# 核心代码
## 下载zip文件
```
fun downLoadFile(url: String, context: Context) {
        try {
            val downLoadDicrectory = "/data/data/${AppUtil.getPackageName(context)}/files"
            val fileName = getFileName(url)
            val zipFileName = if (fileName.indexOf(".") > 0) {
                fileName
            } else {
                "$fileName.zip"
            }
            val outputFile = File(downLoadDicrectory, zipFileName)
            val requestUrl = URL(url)
            outputFile.writeBytes(requestUrl.readBytes())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun getFileName(url: String): String {
        if (url.isEmpty()) return ""
        return url.substring(url.lastIndexOf("/") + 1)
    }

    fun getPackageName(context: Context): String? {
        try {
            val packageManager = context.packageManager
            val packageInfo = packageManager.getPackageInfo(
                context.packageName, 0
            )
            return packageInfo.packageName;
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
```
## 解压文件  
```
fun unzipFolder(zipFileString: String?, outPathString: String) {
        val inZip = ZipInputStream(FileInputStream(zipFileString))
        var zipEntry: ZipEntry? = null
        var szName = ""

        while (inZip.nextEntry?.also { zipEntry = it } != null) {
            szName = zipEntry?.name ?: ""
            if (zipEntry?.isDirectory == true) {
                // get the folder name of the widget
                szName = szName.substring(0, szName.length - 1)
                val folder = File(outPathString + File.separator.toString() + szName)
                folder.mkdirs()
            } else {
                val file = File(outPathString + File.separator.toString() + szName)
                file.createNewFile()
                // get the output stream of the file
                val out = FileOutputStream(file)
                var len: Int
                val buffer = ByteArray(1024)
                // read (len) bytes into buffer
                while (inZip.read(buffer).also { len = it } != -1) {
                    // write (len) byte from buffer at the position 0
                    out.write(buffer, 0, len)
                    out.flush()
                }
                out.close()
            }
        }
        inZip.close()
    }
```
## 文件转对象
```
fun getTarilListByZip(context: Context): List<RealTimeLocationResp> {
        val datas = ArrayList<RealTimeLocationResp>()
        try {
            val directory = "/data/data/${AppUtil.getPackageName(context)}/files"
            val zipFile = File("${directory}/location.text.zip")
            if (!zipFile.exists()) {
                return datas
            }
            Zip.unzipFolder(
                "${directory}/location.text.zip",
                directory
            )
            val file = File("${DirectoryUtils.filesDir(context)}/location.text")
            if (file.exists()) {
                val results = file.readLines()
                datas.addAll(results.asSequence().mapIndexed { index, s ->
                    val items = s.split("|")
                    val lnglat = items[0].split(",")
                    val lng = lnglat[0]
                    val lat = lnglat[1]
                    val location = items[1]
                    val timestamp = items[2]
                    RealTimeLocationResp(
                        timestamp,
                        lat,
                        location,
                        lng,
                        ""
                    )
                }.toList())
                LogUtil.d(results.joinToString("||"))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return datas
    }
```
# 结果展示  
![](https://tp.linqmind.com/2020-07-02-032632.png)

# 相关引用
https://liangchicun.com/977