import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';
import 'tencent_ad_plugin.dart';

/// 原生自渲染广告
class NativeUnified {
  final String posID;
  final NativeRenderCallback adEventCallback;
  MethodChannel _channel;

  NativeUnified({this.posID, this.adEventCallback}) {
    _channel = MethodChannel('$nativeUnifiedID\_$posID');
    _channel.setMethodCallHandler(_handleCall);
    TencentADPlugin.createNativeRender(posID: posID);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (adEventCallback != null) {
      NativeRenderEvent event;
      switch (call.method) {
        case 'onNoAD':
          event = NativeRenderEvent.onNoAD;
          break;
        case 'onADLoaded':
          event = NativeRenderEvent.onADLoaded;
          break;
        default:
      }
      adEventCallback(event, call.arguments);
    }
  }

  Future<Object> loadAD() async {
    return await _channel.invokeMethod('load');
  }

  Future<void> destroyAD() async {
    await _channel.invokeMethod('destory');
  }
}

typedef NativeRenderCallback = Function(NativeRenderEvent event, Map args);

enum NativeRenderEvent { onNoAD, onADLoaded }
