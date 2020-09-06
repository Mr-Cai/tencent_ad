import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';
import 'tencent_ad_plugin.dart';

/// 原生自渲染广告
class NativeADUnified {
  final String posID;
  final NativeUnifiedCallback callback;
  MethodChannel _channel;

  NativeADUnified({this.posID, this.callback}) {
    _channel = MethodChannel('$nativeUnifiedID\_$posID');
    _channel.setMethodCallHandler(_handleCall);
    TencentADPlugin.loadNativeADUnified(posID: posID);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (callback != null) {
      NativeUnifiedEvent event;
      switch (call.method) {
        case 'onNoAD':
          event = NativeUnifiedEvent.onNoAD;
          break;
        case 'onADLoaded':
          event = NativeUnifiedEvent.onADLoaded;
          break;
        default:
      }
      callback(event, call.arguments);
    }
  }

  Future<void> loadAD() async => await _channel.invokeMethod('loadAD');
  Future<void> showAD() async => await _channel.invokeMethod('showAD');
  Future<void> closeAD() async => await _channel.invokeMethod('closeAD');
}

typedef NativeUnifiedCallback = Function(NativeUnifiedEvent event, Map args);

enum NativeUnifiedEvent { onNoAD, onADLoaded }
