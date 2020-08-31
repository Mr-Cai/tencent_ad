import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_ad/banner_ad.dart';
import 'custom.dart';

import 'config_id.dart';

// 横幅广告示例
void showBannerAD(BuildContext context) {
  final _adKey = GlobalKey<BannerADState>();
  showModalBottomSheet<void>(
    context: context,
    enableDrag: true,
    builder: (context) {
      return Container(
        height: 120.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  child: Text('刷新'),
                  onPressed: () {
                    _adKey.currentState.loadAD();
                  },
                ),
                CupertinoButton(
                  child: Text('关闭'),
                  onPressed: () {
                    _adKey.currentState.closeAD();
                  },
                ),
              ],
            ),
            // 创建横幅广告
            BannerAD(
              posID: configID['bannerID'],
              key: _adKey,
              autoRefresh: true,
              callBack: (event, args) {
                switch (event) {
                  case BannerEvent.onADClosed:
                  case BannerEvent.onADCloseOverlay:
                    _adKey.currentState.closeAD();
                    break;
                  case BannerEvent.onNoAD:
                    _adKey.currentState.onNoAD().then((value) => toast(value));
                    break;
                  case BannerEvent.onADReceive:
                    _adKey.currentState.loadAD();
                    break;
                  default:
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
