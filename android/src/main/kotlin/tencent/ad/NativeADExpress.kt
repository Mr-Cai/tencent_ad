package tencent.ad

import android.content.Context
import android.content.res.Resources
import android.util.Log
import android.view.View
import android.view.View.OnLayoutChangeListener
import android.widget.FrameLayout
import android.widget.FrameLayout.LayoutParams.MATCH_PARENT
import android.widget.FrameLayout.LayoutParams.WRAP_CONTENT
import com.qq.e.ads.cfg.VideoOption
import com.qq.e.ads.nativ.ADSize
import com.qq.e.ads.nativ.NativeExpressAD
import com.qq.e.ads.nativ.NativeExpressAD.NativeExpressADListener
import com.qq.e.ads.nativ.NativeExpressADView
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import tencent.ad.O.TAG
import java.util.*

class NativeADExpress(
        context: Context?,
        messenger: BinaryMessenger?,
        posID: Int,
        params: Map<String?, Any?>
) : PlatformView, MethodCallHandler, NativeExpressADListener, OnLayoutChangeListener {
    private var nativeExpressAD: NativeExpressAD? = null
    private var nativeExpressADView: NativeExpressADView? = null
    private val methodChannel: MethodChannel?
    private val container: FrameLayout
    private val posID: String?
    private var count = 5

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "refresh" -> {
                refreshAD()
                result.success(true)
            }
            "close" -> {
                if (nativeExpressADView != null) {
                    nativeExpressADView!!.destroy()
                    nativeExpressADView = null
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
        methodChannel!!.setMethodCallHandler(null)
        // 使用完了每一个NativeExpressADView之后都要释放掉资源
        if (nativeExpressADView != null) {
            nativeExpressADView!!.destroy()
        }
    }

    private fun refreshAD() {
        nativeExpressAD = NativeExpressAD(
                TencentADPlugin.activity,
                ADSize(ADSize.FULL_WIDTH, ADSize.AUTO_HEIGHT),
                posID,
                this
        )
        // 这里的Context必须为Activity
        nativeExpressAD!!.setVideoOption(VideoOption.Builder()
                .setAutoPlayPolicy(VideoOption.AutoPlayPolicy.WIFI) // 设置什么网络环境下可以自动播放视频
                .setAutoPlayMuted(true) // 设置自动播放视频时，是否静音
                .build())
        nativeExpressAD!!.loadAD(count)
    }

    override fun onLayoutChange(
            v: View,
            left: Int,
            top: Int,
            right: Int,
            bottom: Int,
            oldLeft: Int,
            oldTop: Int,
            oldRight: Int,
            oldBottom: Int
    ) {
        if (methodChannel != null) {
            val displayMetrics = Resources.getSystem().displayMetrics
            container.measure(View.MeasureSpec.makeMeasureSpec(displayMetrics.widthPixels,
                    View.MeasureSpec.EXACTLY),
                    View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED))
            val targetWidth = container.measuredWidth
            val targetHeight = container.measuredHeight
            val density = displayMetrics.density
            val params: MutableMap<String, Any> = HashMap()
            params["width"] = targetWidth / density
            params["height"] = targetHeight / density
            methodChannel.invokeMethod("onLayoutChange", params)
        }
    }

    override fun onNoAD(error: AdError) {
        methodChannel!!.invokeMethod("onNoAD", null)
        Log.i(TAG, "NativeADExpress onNoAD:无广告 错误码:${error.errorCode} ${error.errorMsg}")
    }

    override fun onADLoaded(adList: List<NativeExpressADView>) {
        // 释放前一个展示的NativeExpressADView的资源
        if (nativeExpressADView != null) {
            nativeExpressADView!!.destroy()
        }
        if (container.visibility != View.VISIBLE) {
            container.visibility = View.VISIBLE
        }
        if (container.childCount > 0) {
            container.removeAllViews()
        }
        nativeExpressADView = adList[0]
        nativeExpressADView!!.addOnLayoutChangeListener(this)
        // 广告可见才会产生曝光，否则将无法产生收益。
        container.addView(nativeExpressADView)
        nativeExpressADView!!.render()
        methodChannel!!.invokeMethod("onADLoaded", null)
    }

    override fun onRenderFail(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onRenderFail", null)
    }

    override fun onRenderSuccess(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onRenderSuccess", null)
    }

    override fun onADExposure(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onADExposure", null)
    }

    override fun onADClicked(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onADClicked", null)
    }

    override fun onADClosed(nativeExpressADView: NativeExpressADView) {
        // 当广告模板中的关闭按钮被点击时，广告将不再展示。NativeExpressADView也会被Destroy，释放资源，不可以再用来展示。
        if (container.childCount > 0) {
            container.removeAllViews()
            container.visibility = View.GONE
        }
        methodChannel!!.invokeMethod("onADClosed", null)
    }

    override fun onADLeftApplication(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onADLeftApplication", null)
    }

    override fun onADOpenOverlay(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onADOpenOverlay", null)
    }

    override fun onADCloseOverlay(nativeExpressADView: NativeExpressADView) {
        methodChannel!!.invokeMethod("onADCloseOverlay", null)
    }

    init {
        methodChannel = MethodChannel(messenger, "${O.nativeExpressID}_$posID")
        methodChannel.setMethodCallHandler(this)
        container = FrameLayout(context!!)
        container.layoutParams = FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT)
        this.posID = params["posID"] as String?
        if (params.containsKey("count") && params["count"] != null) {
            count = params["count"] as Int
        }
    }

    @Suppress("UNCHECKED_CAST")
    class NativeTemplateViewFactory(private val messenger: BinaryMessenger) :
            PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, id: Int, params: Any): PlatformView {
            return NativeADExpress(context, messenger, id, params as Map<String?, Any?>)
        }
    }
}