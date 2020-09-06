package tencent.ad

import android.util.Log
import com.qq.e.comm.managers.GDTADManager
import com.qq.e.comm.managers.status.SDKStatus
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import tencent.ad.O.TAG
import tencent.ad.O.appID
import tencent.ad.O.bannerID
import tencent.ad.O.nativeExpressID
import java.util.*

@Suppress("SpellCheckingInspection")
class TencentADPlugin : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as Map<*, *>
        when (call.method) {
            "config" -> {
                appID = "${arguments["appID"]}"
                GDTADManager.getInstance().initWith(activity, appID)
                result.success(true)
            }
            "getADVersion" -> {
                Log.i(TAG, "getADVersion: ${SDKStatus.getIntegrationSDKVersion()}")
                result.success(SDKStatus.getIntegrationSDKVersion())
            }
            "showSplash" -> {
                val posID = "${arguments["posID"]}"
                SplashAD(
                    registrar.activity(),
                    registrar.messenger(),
                    posID,
                    null
                ).showAD()
                result.success(true)
            }
            "loadIntersAD" -> {
                val posID = "${arguments["posID"]}"
                if (intersMap.containsKey(posID)) intersMap[posID]?.closeAD()
                intersMap[posID] = IntersAD(posID, registrar.messenger())
                result.success(true)
            }
            "loadRewardAD" -> {
                val posID = "${arguments["posID"]}"
                if (rewardMap.containsKey(posID)) rewardMap[posID]?.closeAD()
                rewardMap[posID] = RewardAD(posID, registrar.messenger())
                result.success(true)
            }
            "loadNativeRender" -> {
                val posID = "${arguments["posID"]}"
                if (rewardMap.containsKey(posID)) rewardMap[posID]?.closeAD()
                renderMap[posID] = NativeADUnified(activity, posID, registrar.messenger())
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        private lateinit var registrar: Registrar
        private lateinit var instance: TencentADPlugin
        internal val activity get() = registrar.activity()

        private val intersMap = HashMap<String, IntersAD>()
        private val rewardMap = HashMap<String, RewardAD>()
        private val renderMap = HashMap<String, NativeADUnified>()

        fun removeInterstitial(posID: String?) {
            intersMap.remove(posID)
        }

        fun removeReward(posID: String?) {
            rewardMap.remove(posID)
        }

        // 插件注册
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            Companion.registrar = registrar
            instance = TencentADPlugin()
            MethodChannel(registrar.messenger(), O.pluginID).setMethodCallHandler(instance)
            registrar.platformViewRegistry().registerViewFactory(
                bannerID,
                BannerAD.BannerADFactory(registrar.messenger())
            )
            registrar.platformViewRegistry().registerViewFactory(
                nativeExpressID,
                NativeADExpress.NativeADExpressFactory(registrar.messenger())
            )
        }
    }
}