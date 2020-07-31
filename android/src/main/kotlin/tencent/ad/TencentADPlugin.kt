package tencent.ad

import com.qq.e.comm.managers.GDTADManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import tencent.ad.O.bannerID
import tencent.ad.O.nativeExpressID
import java.util.*

@Suppress("SpellCheckingInspection")
class TencentADPlugin : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as Map<*, *>
        when (call.method) {
            "config" -> {
                O.appID = "${arguments["appID"]}"
                GDTADManager.getInstance().initWith(activity, O.appID)
                result.success(true)
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

    init {
        checkNotNull(O.appID) { "拉取广告数据前需要配置好ID" }
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
                    NativeADExpress.NativeTemplateViewFactory(registrar.messenger())
            )
        }
    }
}