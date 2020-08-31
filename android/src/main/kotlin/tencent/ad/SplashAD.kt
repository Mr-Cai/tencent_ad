package tencent.ad

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.pm.ActivityInfo
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.FrameLayout.LayoutParams
import android.widget.FrameLayout.LayoutParams.MATCH_PARENT
import com.qq.e.ads.splash.SplashAD
import com.qq.e.ads.splash.SplashADListener
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import tencent.ad.O.TAG
import tencent.ad.TencentADPlugin.Companion.activity

class SplashAD(
    context: Context,
    messenger: BinaryMessenger?,
    private val posID: String,
    private var instance: SplashAD?
) : SplashADListener {
    private val methodChannel = MethodChannel(messenger, "${O.splashID}_$posID")
    private val container = FrameLayout(context)

    fun showAD() = fetchSplashAD(activity, null, posID, this, 0)

    private fun closeAD() {
        val parent = container.parent as ViewGroup
        parent.removeView(container)
        instance = null
    }

    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考文档。
     * @param activity        展示广告的activity
     * @param skipContainer   自定义的跳过按钮：只需绘制样式
     * @param posID           广告位ID
     * @param adListener      广告状态监听器
     * @param fetchDelay      拉取广告的超时时长：[3000, 5000]，0为默认
     */
    @SuppressLint("SourceLockedOrientationActivity")
    @Suppress("SameParameterValue")
    private fun fetchSplashAD(
        activity: Activity,
        skipContainer: View?,
        posID: String,
        adListener: SplashADListener,
        fetchDelay: Int
    ) {
        Log.i(TAG, "fetchSplashAD: ${O.splashID}_$posID")
        if (instance != null) return
        instance = skipContainer?.let {
            SplashAD(activity, it, posID, adListener, fetchDelay)
        } ?: SplashAD(activity, posID, adListener, fetchDelay)
        instance!!.fetchAndShowIn(container)
        @Suppress("DEPRECATION")
        activity.window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN
        activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    }

    init {
        container.setBackgroundColor(Color.WHITE)
        activity.addContentView(container, LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    override fun onADExposure() = methodChannel.invokeMethod("onADExposure", null)
    override fun onADPresent() = methodChannel.invokeMethod("onADPresent", null)
    override fun onADLoaded(time: Long) = methodChannel.invokeMethod("onADLoaded", null)
    override fun onADClicked() = methodChannel.invokeMethod("onADClicked", null)
    override fun onADTick(time: Long) = methodChannel.invokeMethod("onADTick", null)

    override fun onADDismissed() {
        closeAD()
        methodChannel.invokeMethod("onADDismissed", null)
        activity.requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED
    }

    override fun onNoAD(error: AdError) {
        methodChannel.invokeMethod("onNoAD", null)
        Log.i(TAG, "SplashAD onNoAD: 无广告 错误码:${error.errorCode} ${error.errorMsg}")
        closeAD()
    }
}