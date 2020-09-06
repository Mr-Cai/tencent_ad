import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';

/// 原生模板广告
class NativeADExpress extends StatefulWidget {
  const NativeADExpress({
    Key key,
    this.posID,
    this.adCount: 5,
    this.callback,
    this.adIndex: 0,
  }) : super(key: key);

  final String posID;
  final int adCount; // 默认请求次数: 5
  final int adIndex; // 广告集合索引: 0
  final NativeADEventCallback callback;

  @override
  NativeADExpressState createState() => NativeADExpressState();
}

class NativeADExpressState extends State<NativeADExpress> {
  MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: '$nativeExpressID',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: {
            'posID': widget.posID,
            'adCount': widget.adCount,
            'adIndex': widget.adIndex,
          },
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: '$nativeExpressID',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: {
            'posID': widget.posID,
            'adCount': widget.adCount,
            'adIndex': widget.adIndex,
          },
          creationParamsCodec: StandardMessageCodec(),
        );
        break;
      default:
        return Container();
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('$nativeExpressID\_$id');
    _channel.setMethodCallHandler(_handleMethodCall);
    loadAD();
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    NativeADEvent event;
    switch (call.method) {
      case 'onNoAD':
        event = NativeADEvent.onNoAD;
        onNoAD();
        break;
      case 'onLoadSuccess':
        event = NativeADEvent.onLoadSuccess;
        break;
    }
    widget.callback(event, call.arguments);
  }

  Future<void> loadAD() async {
    await _channel.invokeMethod('loadAD', {
      'adCount': widget.adCount,
    });
  }

  Future<void> closeAD() async => await _channel.invokeMethod('closeAD');

  Future<String> onNoAD() async => await _channel.invokeMethod('onNoAD');
}

enum NativeADEvent {
  onNoAD,
  onLoadSuccess,
}

typedef NativeADEventCallback = Function(NativeADEvent event, Map arguments);
