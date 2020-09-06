package tencent.ad

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup.LayoutParams.MATCH_PARENT
import android.view.ViewGroup.LayoutParams.WRAP_CONTENT
import android.widget.FrameLayout
import com.qq.e.ads.nativ.express2.*
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import tencent.ad.O.TAG

class NativeADExpress(
    private val context: Context,
    messenger: BinaryMessenger,
    posID: Int,
    params: Map<String, Any?>
) : PlatformView, MethodChannel.MethodCallHandler,
    NativeExpressAD2.AdLoadListener {
    private val methodChannel = MethodChannel(messenger, "${O.nativeExpressID}_$posID")
    private val container: FrameLayout
    private val posID: String = "${params["posID"]}"
    private var adCount: Int = params["adCount"] as Int
    private var adIndex: Int = params["adIndex"] as Int

    private lateinit var adData: NativeExpressADData2
    private lateinit var errorMsg: String

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAD" -> {
                NativeExpressAD2(context, posID, this)
                    .run {
                        setAdSize(420, 0) // 单位: dp
                        setVideoOption2(
                            VideoOption2.Builder()
                                .setAutoPlayPolicy(VideoOption2.AutoPlayPolicy.ALWAYS)
                                .setAutoPlayMuted(true)     // 自动播放时是否为静音
                                .setDetailPageMuted(false)  // 视频详情页是否为静音
                                // 设置广告最大(小)时长 5s<=time<=60s (0:无限制)
                                .setMaxVideoDuration(0)
                                .setMinVideoDuration(0)
                                .build()
                        )
                        loadAd(adCount)
                    }
                result.success(true)
            }
            "closeAD" -> {
                adData.destroy()
                result.success(true)
            }
            "onNoAD" -> result.success(errorMsg)
            else -> result.notImplemented()
        }
    }

    init {
        methodChannel.setMethodCallHandler(this)
        container = FrameLayout(context)
        container.layoutParams = FrameLayout.LayoutParams(MATCH_PARENT, WRAP_CONTENT)
    }

    override fun getView(): View = container
    override fun dispose() = methodChannel.setMethodCallHandler(null)

    override fun onNoAD(error: AdError) {
        methodChannel.invokeMethod("onNoAD", null)
        errorMsg = "NativeADExpress->onNoAD:${error.errorCode} ${error.errorMsg}"
        Log.i(TAG, errorMsg)
    }

    override fun onLoadSuccess(nativeExpressADData: MutableList<NativeExpressADData2>) {
        renderAD(nativeExpressADData)
    }

    private fun renderAD(adSet: MutableList<NativeExpressADData2>) {
        container.removeAllViews()
        adData = adSet[adIndex]
        Log.i(TAG, "renderAD: $adIndex")
        adData.run {
            setAdEventListener(object : AdEventListener {
                override fun onClick() {}
                override fun onExposed() {}
                override fun onRenderFail() {}
                override fun onRenderSuccess() {
                    Log.i(TAG, "onRenderSuccess: $this")
                    container.removeAllViews()
                    container.addView(adView)
                }

                override fun onAdClosed() {
                    Log.i(TAG, "onAdClosed: $this")
                    container.removeAllViews()
                    destroy()
                }
            })
            setMediaListener(object : MediaEventListener {
                override fun onVideoCache() {}
                override fun onVideoStart() {}
                override fun onVideoResume() {}
                override fun onVideoPause() {}
                override fun onVideoComplete() {}
                override fun onVideoError() {}
            })
            render()
        }
        Log.i(TAG, "renderAD: eCPM级别: ${adData.ecpmLevel} 广告时长: ${adData.videoDuration}")
    }

    @Suppress("UNCHECKED_CAST")
    class NativeADExpressFactory(private val messenger: BinaryMessenger) :
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, id: Int, params: Any): PlatformView {
            return NativeADExpress(context, messenger, id, params as Map<String, Any>)
        }
    }
}