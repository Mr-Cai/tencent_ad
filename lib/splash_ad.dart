import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tencent_ad_plugin.dart';
import 'o.dart';

/// 闪屏广告
class SplashAD {
  MethodChannel _channel;

  final String posID;
  final SplashADEventCallback callBack;

  SplashAD({@required this.posID, this.callBack}) {
    _channel = MethodChannel('$splashID\_$posID');
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (callBack != null) {
      SplashADEvent event;
      switch (call.method) {
        case 'onADExposure':
          event = SplashADEvent.onADExposure;
          break;
        case 'onADPresent':
          event = SplashADEvent.onADExposure;
          break;
        case 'onADLoaded':
          event = SplashADEvent.onADLoaded;
          break;
        case 'onADClicked':
          event = SplashADEvent.onADClicked;
          break;
        case 'onADTick':
          event = SplashADEvent.onADTick;
          break;
        case 'onADDismissed':
          event = SplashADEvent.onADDismissed;
          break;
        case 'onNoAD':
          event = SplashADEvent.onNoAD;
          break;
      }
      callBack(event, call.arguments);
    }
  }

  Future<void> showAD() async {
    await TencentADPlugin.channel.invokeMethod('showSplash', {'posID': posID});
  }
}

enum SplashADEvent {
  onADExposure,
  onADPresent,
  onADLoaded,
  onADClicked,
  onADTick,
  onADDismissed,
  onNoAD,
}

typedef SplashADEventCallback = Function(
  SplashADEvent event,
  dynamic arguments,
);
