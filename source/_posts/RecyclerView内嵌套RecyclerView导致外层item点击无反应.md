---
layout: recyclerview内嵌套recyclerview导致外层item点击无反应
title: RecyclerView内嵌套RecyclerView导致外层item点击无反应
date: 2020-05-28 16:20:03
tags: [Android,RecyclerView,点击无效]
---

`recyclerView` 嵌套一个显示子项的`recyclerView`，外层`recyclerView`需要响应`item`的点击进行跳转，在嵌套的`RecyclerView`中点击无效。
首先，需要知道触摸事件的响应机制是由上至下，当最下层不消费后，则由下至上；然后需要了解其中的这三个方法：`dispatchTouchEvent`、`onInterceptTouchEvent`、`onTouchEvent`。
`dispatchTouchEvent`：事件分发，一般不处理，返回`false`，事件到`onInterceptTouchEvent`中处理。
`onInterceptTouchEvent`：事件拦截，返回`true`的话，则不向下传递，事件到`onTouchEvent`，返回false事件往下传递
`onTouchEvent`：返回`true`代表事件消费，返回`false`不消费，事件往上传递。
那么在我只需要内部`RecyclerView`用于显示，不需要任何操作的情况下，为了使外层RecyclerView的item响应，把嵌入的RecyclerView触摸事件拦截，并且不消费就行了，事件就会传递到上一层，重写嵌套的RecyclerView。
请参考具体的源码

```
import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.recyclerview.widget.RecyclerView

class NoTouchRecyclerView : RecyclerView {

    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(
        context,
        attrs,
        defStyleAttr
    )

    override fun onTouchEvent(e: MotionEvent?): Boolean {
        return false
    }

    override fun onInterceptTouchEvent(e: MotionEvent?): Boolean {
        return true
    }

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        return super.dispatchTouchEvent(ev)
    }
}
```
