import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';
import 'package:tencent_ad/tencent_ad_plugin.dart';

/// 插屏广告
class IntersAD {
  final String posID;
  final IntersADCallback callback;

  MethodChannel _channel;

  IntersAD({@required this.posID, this.callback}) {
    _channel = MethodChannel('$intersID\_$posID');
    _channel.setMethodCallHandler(_handleCall);
    TencentADPlugin.loadIntersAD(posID: posID);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (callback != null) {
      IntersADEvent event;
      switch (call.method) {
        case 'onNoAD':
          event = IntersADEvent.onNoAD;
          break;
        case 'onADReceived':
          event = IntersADEvent.onADReceived;
          break;
        case 'onADExposure':
          event = IntersADEvent.onADExposure;
          break;
        case 'onADClosed':
          event = IntersADEvent.onADClosed;
          break;
        case 'onADClicked':
          event = IntersADEvent.onADClicked;
          break;
        case 'onADLeftApplication':
          event = IntersADEvent.onADLeftApplication;
          break;
        case 'onADOpened':
          event = IntersADEvent.onADOpened;
          break;
      }
      callback(event, call.arguments);
    }
  }

  Future<void> loadAD() async => await _channel.invokeMethod('loadAD');
  Future<void> showAD() async => await _channel.invokeMethod('showAD');
  Future<void> closeAD() async => await _channel.invokeMethod('closeAD');
}

typedef IntersADCallback = Function(IntersADEvent event, Map args);

enum IntersADEvent {
  onNoAD,
  onADReceived,
  onADExposure,
  onADClosed,
  onADClicked,
  onADLeftApplication,
  onADOpened,
}
