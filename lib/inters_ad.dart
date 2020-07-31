import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';
import 'package:tencent_ad/tencent_ad_plugin.dart';

/// 插屏广告
class IntersAD {
  final String posID;
  final IntersADCallback adEventCallback;

  MethodChannel _methodChannel;

  IntersAD({@required this.posID, this.adEventCallback}) {
    _methodChannel = MethodChannel('$intersID\_$posID');
    _methodChannel.setMethodCallHandler(_handleCall);
    TencentADPlugin.toastIntersAD(posID: posID);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (adEventCallback != null) {
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
      adEventCallback(event, call.arguments);
    }
  }

  Future<void> loadAD() async {
    await _methodChannel.invokeMethod('load');
  }

  Future<void> showAD() async {
    await _methodChannel.invokeMethod('show');
  }
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
