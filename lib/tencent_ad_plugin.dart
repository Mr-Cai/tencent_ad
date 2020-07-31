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

  static Future<bool> config({@required String appID}) async =>
      await channel.invokeMethod('config', {'appID': appID});

  static Future<String> get tencentADVersion async {
    final String version = await channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> toastIntersAD({@required String posID}) async {
    return await channel.invokeMethod('loadIntersAD', {'posID': posID});
  }

  static Future<bool> toastRewardAD({@required String posID}) async {
    return await channel.invokeMethod('loadRewardAD', {'posID': posID});
  }

  static Future<bool> createNativeRender({@required String posID}) async {
    return await channel.invokeMethod('loadNativeRender', {'posID': posID});
  }
}
