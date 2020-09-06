package tencent.ad

import android.content.Context
import android.util.Log
import com.qq.e.ads.banner2.UnifiedBannerADListener
import com.qq.e.ads.banner2.UnifiedBannerView
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import tencent.ad.O.TAG
import tencent.ad.TencentADPlugin.Companion.activity

/**
 * @param posID 调用次数
 * @param messenger 二进制异步消息通信器
 * */
class BannerAD(
    messenger: BinaryMessenger,
    posID: Int,
    params: Map<String, Any>
) : PlatformView, MethodCallHandler, UnifiedBannerADListener {
    private val posID = "${params["posID"]}"
    private val bannerView = UnifiedBannerView(activity, this.posID, this)
    private val methodChannel = MethodChannel(messenger, "${O.bannerID}_$posID")
    private lateinit var errorMsg: String

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView() = bannerView

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        bannerView.destroy()
    }

    override fun onMethodCall(methodCall: MethodCall, result: Result) =
        when (methodCall.method) {
            "loadAD" -> {
                bannerView.setRefresh(30)
                bannerView.loadAD()
                result.success(true)
            }
            "closeAD" -> {
                bannerView.destroy()
                result.success(true)
            }
            "onNoAD" -> result.success(errorMsg)
            else -> result.notImplemented()
        }

    override fun onNoAD(error: AdError) {
        methodChannel.invokeMethod("onNoAD", null)
        errorMsg = "BannerAD->onNoAD:${error.errorCode} ${error.errorMsg}"
        Log.i(TAG, errorMsg)
    }

    override fun onADReceive() = methodChannel.invokeMethod("onADReceive", null)
    override fun onADExposure() = methodChannel.invokeMethod("onADExposure", null)
    override fun onADClosed() = methodChannel.invokeMethod("onADClosed", null)
    override fun onADClicked() = methodChannel.invokeMethod("onADClicked", null)
    override fun onADLeftApplication() = methodChannel.invokeMethod("onADLeftApplication", null)
    override fun onADOpenOverlay() = methodChannel.invokeMethod("onADOpenOverlay", null)
    override fun onADCloseOverlay() = methodChannel.invokeMethod("onADCloseOverlay", null)

    class BannerADFactory(private val messenger: BinaryMessenger) :
        PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        @Suppress("UNCHECKED_CAST")
        override fun create(context: Context, id: Int, params: Any) = BannerAD(
            messenger, id, params as Map<String, Any>
        )
    }
}