---
layout: android手机通讯录读取
title: android手机通讯录读取
date: 2019-08-22 15:46:27
tags: [Java,kotlin,rxjava,通讯录,Android]
---
# 背景
在App开发过程中，如果要实现电话号码的选择，但是默认的通讯录选择又不满足我们需求的时候，我们就需要对用户的通讯录进行读取。
# 相关知识点
`Java` `kotlin` `Rxjava`

# 步骤
## 权限配置 `AndroidManifest.xml`
```
<uses-permission android:name="android.permission.READ_CONTACTS"/>
<uses-permission android:name="android.permission.WRITE_CONTACTS"/>
```
## 代码实现片段
```
 /**
     * 获取通讯录
     */
    fun getContacts(context: Context): Observable<List<ContactBean>> {
        return Observable.create(object : ObservableOnSubscribe<List<ContactBean>> {
            override fun subscribe(emitter: ObservableEmitter<List<ContactBean>>) {
                val contactBeen = ArrayList<ContactBean>()
                try {
                    //得到ContentResolver对象
                    val cr = context.contentResolver
                    //取得电话本中开始一项的光标
                    val cursor = cr.query(ContactsContract.Contacts.CONTENT_URI, null, null, null, null)
                    if (cursor == null) {
                        emitter.onError(AppException("无法获取通讯录"))
                        return
                    }
                    //向下移动光标
                    while (cursor.moveToNext()) {
                        //取得联系人名字
                        val nameFieldColumnIndex = cursor.getColumnIndex(ContactsContract.PhoneLookup.DISPLAY_NAME)
                        val contact = cursor.getString(nameFieldColumnIndex)
                        // 获得联系人的ID号
                        val contactId = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID))
                        //取得电话号码
                        val phone = cr.query(
                            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                            null,
                            ContactsContract.CommonDataKinds.Phone.CONTACT_ID + "=" + contactId,
                            null,
                            null
                        )
                        val phones = ArrayList<String>()
                        while (phone!!.moveToNext()) {
                            var phoneNumber =
                                phone.getString(phone.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))
                            //格式化手机号
                            phoneNumber = phoneNumber.replace("-", "")
                            phoneNumber = phoneNumber.replace(" ", "")
                            phones.add(phoneNumber)
                        }
                        // 获取备注信息
                        val notes = context.contentResolver.query(
                            ContactsContract.Data.CONTENT_URI,
                            arrayOf(ContactsContract.Data._ID, ContactsContract.CommonDataKinds.Note.NOTE),
                            ContactsContract.Data.CONTACT_ID + "=?" + " AND " + ContactsContract.Data.MIMETYPE + "='"
                                    + ContactsContract.CommonDataKinds.Note.CONTENT_ITEM_TYPE + "'",
                            arrayOf(contactId),
                            null
                        )
                        var noteInfo: String? = null
                        if (notes!!.moveToFirst()) {
                            do {
                                noteInfo =
                                    notes.getString(notes.getColumnIndex(ContactsContract.CommonDataKinds.Note.NOTE))
                            } while (notes.moveToNext())
                        }
                        notes.close()
                        contactBeen.add(ContactBean(contact, phones, noteInfo))
                    }
                } catch (e: java.lang.Exception) {
                    e.printStackTrace()
                }
                emitter.onNext(contactBeen)
                emitter.onComplete()
            }
        })
    }
```
# 结语
对于读取用户的私密信息，如非必要，千万不能滥用。