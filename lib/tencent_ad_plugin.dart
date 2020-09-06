import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:tencent_ad/o.dart';
export 'tencent_ad_plugin.dart';
export 'native_ad_unified.dart';
export 'native_ad_express.dart';
export 'splash_ad.dart';
export 'banner_ad.dart';
export 'inters_ad.dart';
export 'reward_ad.dart';

/// 插件桥接方法全局类
class TencentADPlugin {
  static const MethodChannel channel = const MethodChannel(pluginID);

  // 配置广告应用ID
  static Future<bool> config({@required String appID}) async {
    return await channel.invokeMethod('config', {'appID': appID});
  }

  // 获取广告SDK版本
  static Future<String> tencentADVersion() async {
    return await channel.invokeMethod('getADVersion', {});
  }

  // 加载插屏广告
  static Future<bool> loadIntersAD({@required String posID}) async {
    return await channel.invokeMethod('loadIntersAD', {'posID': posID});
  }

  // 加载激励视频广告
  static Future<bool> loadRewardAD({@required String posID}) async {
    return await channel.invokeMethod('loadRewardAD', {'posID': posID});
  }

  // 加载原生自渲染广告
  static Future<bool> loadNativeADUnified({@required String posID}) async {
    return await channel.invokeMethod('loadNativeADUnified', {'posID': posID});
  }
}
