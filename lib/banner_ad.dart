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
    this.autoRefresh: true,
    this.width,
  }) : super(key: key);

  final String posID;
  final bool autoRefresh;
  final double width;
  final BannerCallback callBack;

  @override
  BannerADState createState() => BannerADState();
}

class BannerADState extends State<BannerAD> {
  MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: 64.0,
    );
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('$bannerID\_$id');
    _channel.setMethodCallHandler(_handleMethodCall);
    if (widget.autoRefresh == true) {
      loadAD();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    BannerEvent event;
    switch (call.method) {
      case 'onNoAD':
        event = BannerEvent.onNoAD;
        onNoAD();
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

  Future<void> loadAD() async => await _channel.invokeMethod('loadAD');
  Future<void> closeAD() async => await _channel.invokeMethod('closeAD');
  Future<String> onNoAD() async => await _channel.invokeMethod('onNoAD');
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
