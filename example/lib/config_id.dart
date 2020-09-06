import 'package:flutter/foundation.dart';

Map<String, String> get configID {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return {
        'appID': '1101152570',
        'splashID': '8863364436303842593',
        'bannerID': '4080052898050840',
        'intersID': '4080298282218338',
        'rewardID': '6040295592058680',
        'nativeExpressID': '9061615683013706',
        'nativeUnifiedID': '4090398440079274',
      };
      break;
    case TargetPlatform.iOS:
      return {
        'appID': '1105344611',
        'splashID': '9040714184494018',
        'bannerID': '1080958885885321',
        'intersID': '1050652855580392',
        'rewardID': '9040714184494018',
        'nativeExpressID': '1020922903364636',
        'nativeUnifiedID': '',
      };
      break;
    default:
      return {'': ''};
  }
}
