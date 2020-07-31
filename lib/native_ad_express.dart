import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';

/// 原生模板广告
class NativeExpress extends StatefulWidget {
  const NativeExpress({
    Key key,
    this.posID,
    this.requestCount: 5,
    this.adEventCallback,
    this.refreshOnCreate,
  }) : super(key: key);

  final String posID;
  final int requestCount; // 默认请求次数: 5
  final NativeADEventCallback adEventCallback;
  final bool refreshOnCreate;

  @override
  NativeExpressState createState() => NativeExpressState();
}

class NativeExpressState extends State<NativeExpress> {
  MethodChannel _methodChannel;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: '$nativeExpressID',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: {'posID': widget.posID, 'count': widget.requestCount},
        creationParamsCodec: StandardMessageCodec(),
      );
    }
    return AndroidView(
      viewType: '$nativeExpressID',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posID': widget.posID, 'count': widget.requestCount},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    this._methodChannel = MethodChannel('$nativeExpressID\_$id');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
    if (this.widget.refreshOnCreate == true) {
      this.refreshAD();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (widget.adEventCallback != null) {
      NativeADEvent event;
      switch (call.method) {
        case 'onLayoutChange':
          event = NativeADEvent.onLayoutChange;
          break;
        case 'onNoAD':
          event = NativeADEvent.onNoAD;
          break;
        case 'onADLoaded':
          event = NativeADEvent.onADLoaded;
          break;
        case 'onRenderFail':
          event = NativeADEvent.onRenderFail;
          break;
        case 'onRenderSuccess':
          event = NativeADEvent.onRenderSuccess;
          break;
        case 'onADExposure':
          event = NativeADEvent.onADExposure;
          break;
        case 'onADClicked':
          event = NativeADEvent.onADClicked;
          break;
        case 'onADClosed':
          event = NativeADEvent.onADClosed;
          break;
        case 'onADLeftApplication':
          event = NativeADEvent.onADLeftApplication;
          break;
        case 'onADOpenOverlay':
          event = NativeADEvent.onADOpenOverlay;
          break;
        case 'onADCloseOverlay':
          event = NativeADEvent.onADCloseOverlay;
          break;
      }
      widget.adEventCallback(event, call.arguments);
    }
  }

  Future<void> closeAD() async {
    if (_methodChannel != null) {
      await _methodChannel.invokeMethod('close');
    }
  }

  Future<void> refreshAD() async {
    if (_methodChannel != null) {
      await _methodChannel.invokeMethod('refresh');
    }
  }
}

class NativeADWidget extends StatefulWidget {
  final String posID;
  final int requestCount;
  final GlobalKey<NativeExpressState> adKey;
  final NativeADEventCallback adEventCallback;
  final double loadingHeight;

  NativeADWidget({
    GlobalKey<NativeExpressState> adKey,
    this.posID,
    this.requestCount,
    this.adEventCallback,
    this.loadingHeight: 1.0,
  }) : adKey = adKey ?? GlobalKey();

  @override
  NativeADWidgetState createState() =>
      NativeADWidgetState(height: loadingHeight);
}

class NativeADWidgetState extends State<NativeADWidget> {
  double _height;
  NativeExpress _ad;

  NativeADWidgetState({double height}) : _height = height;

  @override
  void initState() {
    super.initState();
    _ad = NativeExpress(
      posID: widget.posID,
      key: widget.adKey,
      requestCount: widget.requestCount,
      adEventCallback: _adEventCallback,
      refreshOnCreate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: _ad,
    );
  }

  void _adEventCallback(NativeADEvent event, dynamic arguments) async {
    if (widget.adEventCallback != null) {
      widget.adEventCallback(event, arguments);
    }
    if (event == NativeADEvent.onLayoutChange && this.mounted) {
      this.setState(() {
        _height = MediaQuery.of(context).size.width *
            arguments['height'] /
            arguments['width'];
      });
      return;
    }
  }
}

enum NativeADEvent {
  onLayoutChange,
  onNoAD,
  onADLoaded,
  onRenderFail,
  onRenderSuccess,
  onADExposure,
  onADClicked,
  onADClosed,
  onADLeftApplication,
  onADOpenOverlay,
  onADCloseOverlay,
}

typedef NativeADEventCallback = Function(NativeADEvent event, Map arguments);
