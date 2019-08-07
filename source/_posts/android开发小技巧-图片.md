---
layout: android开发小技巧_图片
title: android开发小技巧_图片
date: 2019-08-07 10:53:55
tags: [Android,图片,databinding,imageview]
---
在我们进行开发的时候，图片是常用布局控件之一。
在新的databinding中，`ImageView`使用上面还是有差异的。接下来的实例，我们将展示如何使用glide进行图片设置。

# 开发语言
`kotlin`,`Android`

# 使用方法
## 引入glide包
```
dependencies {
    //glide图片加载控件
    implementation "com.github.bumptech.glide:glide:$glideVersion"
    implementation "jp.wasabeef:glide-transformations:$glideTransformationVersion"
}
```

## 配置databingding
```
android {
    //dataBinding
    dataBinding {
        enabled true
    }
}
```

## 在bindadapter中配置图片控件属性
```
@BindingAdapter(value = ["app:imageUrl", "app:imageError", "app:placeHolderImg", "app:isCircle", "app:isLocal"], requireAll = false)
fun loadImage(
    imageView: ImageView,
    url: String?,
    errorDw: Int?,
    placeHolder: Int?,
    isCircle: Boolean? = false,
    isLocal: Boolean? = false
) {
        if (isCircle != null && isCircle) {
            if (isLocal == true) {
                Glide.with(imageView.context)
                    .load(url?.toInt())
                    .error(errorDw?:R.drawable.img_touxiang)
                    .placeholder(placeHolder ?: R.drawable.img_touxiang)
                    .transform(GlidCircleTransform(imageView.context))
                    .into(imageView)
            } else {
                Glide.with(imageView.context)
                    .load(url)
                    .error(errorDw?:R.drawable.img_touxiang)
                    .placeholder(placeHolder ?: R.drawable.img_touxiang)
                    .transform(GlidCircleTransform(imageView.context))
                    .into(imageView)
            }
        } else {
            if (isLocal == true) {
                Glide.with(imageView.context)
                    .load(url?.toInt())
                    .error(errorDw?:R.drawable.img_touxiang)
                    .placeholder(placeHolder ?: R.drawable.img_touxiang)
                    .into(imageView)
            } else {

                Glide.with(imageView.context)
                    .load(url)
                    .error(errorDw?:R.drawable.img_touxiang)
                    .placeholder(placeHolder ?: R.drawable.img_touxiang)
                    .into(imageView)
            }
        }
}
```

## 布局文件中使用bingadapter中定义的属性
```
<ImageView
    android:layout_marginLeft="@dimen/margin_left_some"
    android:layout_marginRight="@dmargin_right_some"
    tools:background="@drawable/img_background"
    app:imageUrl="@{vm.backgroundUrl}"
    app:imageError="@{vm.errorImg}"
    app:isLocal="@{true}"
    app:placeHolderImg="@{vm.placeHolderImg}"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"/>
```

## 在viewmodel中定义变量
```
val placeHolderImg = ObservableField<Int>(R.drawable.img_place_holder)
val errorImg = ObservableField<Int>(R.drawable.img_error)
val imageUrl = ObservableField<Int>(R.drawable.img_background)
```