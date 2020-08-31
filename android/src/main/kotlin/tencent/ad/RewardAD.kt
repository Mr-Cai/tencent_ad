package tencent.ad

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.qq.e.ads.rewardvideo.RewardVideoAD
import com.qq.e.ads.rewardvideo.RewardVideoADListener
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import tencent.ad.TencentADPlugin.Companion.activity

class RewardAD(
        private val posID: String,
        messenger: BinaryMessenger
) : MethodCallHandler, RewardVideoADListener {
    private val methodChannel = MethodChannel(messenger, "${O.rewardID}_$posID")
    private lateinit var rewardVideoAD: RewardVideoAD

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "load" -> {
                loadRewardVideo().loadAD()
                result.success(true)
            }
            "show" -> {
                rewardVideoAD.showAD(activity)
                result.success(true)
            }
        }
    }

    fun closeAD() {
        methodChannel.setMethodCallHandler(null)
        TencentADPlugin.removeReward(posID)
    }

    private fun loadRewardVideo(isOpenVolume: Boolean = false): RewardVideoAD {
        rewardVideoAD = RewardVideoAD(activity, posID, this, isOpenVolume)
        return rewardVideoAD
    }

    override fun onADExpose() = methodChannel.invokeMethod("onADExpose", null)
    override fun onADClick() = methodChannel.invokeMethod("onADClick", null)
    override fun onVideoCached() = methodChannel.invokeMethod("onVideoCached", null)
    override fun onReward() = methodChannel.invokeMethod("onReward", null)
    override fun onADClose() = methodChannel.invokeMethod("onADClose", null)
    override fun onADLoad() = methodChannel.invokeMethod("onADLoad", null)
    override fun onVideoComplete() = methodChannel.invokeMethod("onVideoComplete", null)
    override fun onADShow() = methodChannel.invokeMethod("onADShow", null)

    override fun onError(error: AdError) {
        methodChannel.invokeMethod("onError", null)
        Handler(Looper.getMainLooper()).postDelayed({
            loadRewardVideo().loadAD()
        }, 2000)
        Log.i(O.TAG, "RewardAD onNoAD:无广告 错误码:${error.errorCode} ${error.errorMsg}")
    }
}