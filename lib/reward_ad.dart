import 'package:flutter/services.dart';
import 'package:tencent_ad/o.dart';
import 'tencent_ad_plugin.dart';

/// 激励视频广告
class RewardAD {
  final String posID;
  final RewardADCallback callback;

  MethodChannel _channel;

  RewardAD({this.posID, this.callback}) {
    _channel = MethodChannel('$rewardID\_$posID');
    _channel.setMethodCallHandler(_handleCall);
    TencentADPlugin.loadRewardAD(posID: posID);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (callback != null) {
      RewardADEvent event;
      switch (call.method) {
        case 'onADExpose':
          event = RewardADEvent.onADExpose;
          break;
        case 'onADClick':
          event = RewardADEvent.onADClick;
          break;
        case 'onVideoCached':
          event = RewardADEvent.onVideoCached;
          break;
        case 'onReward':
          event = RewardADEvent.onReward;
          break;
        case 'onADClose':
          event = RewardADEvent.onADClose;
          break;
        case 'onADLoad':
          event = RewardADEvent.onADLoad;
          break;
        case 'onVideoComplete':
          event = RewardADEvent.onVideoComplete;
          break;
        case 'onADShow':
          event = RewardADEvent.onADShow;
          break;
        case 'onError':
          event = RewardADEvent.onError;
          break;
      }
      callback(event, call.arguments);
    }
  }

  Future<void> loadAD() async {
    await _channel.invokeMethod('load');
  }

  Future<void> showAD() async {
    await _channel.invokeMethod('show');
  }
}

typedef RewardADCallback = Function(RewardADEvent event, Map args);

enum RewardADEvent {
  onADExpose,
  onADClick,
  onVideoCached,
  onReward,
  onADClose,
  onADLoad,
  onVideoComplete,
  onADShow,
  onError,
}
