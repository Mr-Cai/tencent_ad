import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'o.dart';

/// 横幅广告
class BannerAD extends StatefulWidget {
  const BannerAD({
    Key key,
    @required this.posID,
    this.callBack,
    this.refresh,
    this.width,
    this.height,
  }) : super(key: key);

  final String posID;
  final bool refresh;
  final double width;
  final double height;
  final BannerCallback callBack;

  @override
  BannerADState createState() => BannerADState();
}

class BannerADState extends State<BannerAD> {
  MethodChannel _methodChannel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 64.0,
      child: defaultTargetPlatform == TargetPlatform.iOS
          ? UiKitView(
              viewType: '$bannerID',
              onPlatformViewCreated: _onPlatformViewCreated,
              creationParams: {'posID': widget.posID},
              creationParamsCodec: StandardMessageCodec(),
            )
          : AndroidView(
              viewType: '$bannerID',
              onPlatformViewCreated: _onPlatformViewCreated,
              creationParams: {'posID': widget.posID},
              creationParamsCodec: StandardMessageCodec(),
            ),
    );
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('$bannerID\_$id');
    _methodChannel.setMethodCallHandler(_handleMethodCall);
    if (widget.refresh == true) {
      loadAD();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (widget.callBack != null) {
      BannerEvent event;
      switch (call.method) {
        case 'onNoAD':
          event = BannerEvent.onNoAD;
          break;
        case 'onADReceived':
          event = BannerEvent.onADReceive;
          break;
        case 'onADExposure':
          event = BannerEvent.onADExposure;
          break;
        case 'onADClosed':
          event = BannerEvent.onADClosed;
          break;
        case 'onADClicked':
          event = BannerEvent.onADClicked;
          break;
        case 'onADLeftApplication':
          event = BannerEvent.onADLeftApplication;
          break;
        case 'onADOpenOverlay':
          event = BannerEvent.onADOpenOverlay;
          break;
        case 'onADCloseOverlay':
          event = BannerEvent.onADCloseOverlay;
          break;
      }
      widget.callBack(event, call.arguments);
    }
  }

  Future<void> closeAD() async => await _methodChannel.invokeMethod('destroy');
  Future<void> loadAD() async => await _methodChannel.invokeMethod('loadAD');
}

enum BannerEvent {
  onNoAD,
  onADReceive,
  onADExposure,
  onADClosed,
  onADClicked,
  onADLeftApplication,
  onADOpenOverlay,
  onADCloseOverlay,
}

typedef BannerCallback = Function(BannerEvent event, Map args);
