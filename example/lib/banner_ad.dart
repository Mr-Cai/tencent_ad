import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_ad/banner_ad.dart';
import 'custom.dart';

import 'config_id.dart';

final bannerKey = GlobalKey<BannerADState>();
// 横幅广告示例
Widget $BannerAD(BuildContext context) {
  // 创建横幅广告
  return BannerAD(
    posID: configID['bannerID'],
    key: bannerKey,
    autoRefresh: true,
    callBack: (event, args) {
      switch (event) {
        case BannerEvent.onADClosed:
        case BannerEvent.onADCloseOverlay:
          bannerKey.currentState.closeAD();
          break;
        case BannerEvent.onNoAD:
          bannerKey.currentState.onNoAD().then((value) => toast(value));
          break;
        case BannerEvent.onADReceive:
          bannerKey.currentState.loadAD();
          break;
        default:
      }
    },
  );
}
