package tencent.ad

import android.util.Log
import com.qq.e.ads.interstitial2.UnifiedInterstitialAD
import com.qq.e.ads.interstitial2.UnifiedInterstitialADListener
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class IntersAD(
        private val posID: String,
        messenger: BinaryMessenger?
) : MethodCallHandler, UnifiedInterstitialADListener {
    private var intersAD: UnifiedInterstitialAD? = null
    private val methodChannel = MethodChannel(messenger, "${O.intersID}_$posID")

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "loadAD" -> {
                iAD.loadAD()
                result.success(true)
            }
            "showAD" -> {
                showAD()
                result.success(true)
            }
            "closeAD" -> {
                closeAD()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun closeAD() {
        if (intersAD != null) {
            intersAD!!.destroy()
            intersAD = null
        }
        methodChannel.setMethodCallHandler(null)
        TencentADPlugin.removeInterstitial(posID)
    }

    private val iAD: UnifiedInterstitialAD
        get() {
            if (intersAD != null) {
                return intersAD!!
            }
            intersAD = UnifiedInterstitialAD(TencentADPlugin.activity, posID, this)
            return intersAD!!
        }

    private fun showAD() {
        iAD.showAsPopupWindow()
    }

    override fun onNoAD(error: AdError) {
        intersAD = null
        methodChannel.invokeMethod("onNoAD", null)
        Log.i(O.TAG, "IntersAD onNoAD:无广告 错误码:${error.errorCode} ${error.errorMsg}")
    }

    override fun onADClosed() {
        intersAD = null
        methodChannel.invokeMethod("onADClosed", null)
    }

    override fun onADReceive() = methodChannel.invokeMethod("onADReceived", null)
    override fun onADExposure() = methodChannel.invokeMethod("onADExposure", null)
    override fun onADClicked() = methodChannel.invokeMethod("onADClicked", null)
    override fun onADLeftApplication() = methodChannel.invokeMethod("onADLeftApplication", null)
    override fun onADOpened() = methodChannel.invokeMethod("onADOpened", null)
    override fun onVideoCached() = methodChannel.invokeMethod("onVideoCached", null)

}