import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tencent_ad/tencent_ad_plugin.dart';

void main() {
  runApp(TencentADApp());
}

class TencentADApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TencentADAppState();
}

class _TencentADAppState extends State<TencentADApp> {
  @override
  void initState() {
    // 闪屏广告示例
    TencentADPlugin.config(appID: '1109716769').then(
      (_) => SplashAD(
          posID: configID['splashID'],
          callBack: (event, args) {
            switch (event) {
              case SplashADEvent.onNoAD:
              case SplashADEvent.onADDismissed:
                SystemChrome.setEnabledSystemUIOverlays([
                  SystemUiOverlay.top,
                  SystemUiOverlay.bottom,
                ]);
                SystemChrome.setSystemUIOverlayStyle(
                  SystemUiOverlayStyle(statusBarColor: Colors.transparent),
                );
                break;
              default:
            }
          }).showAD(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          '腾讯广告',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.values[0],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onPressed: () {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(1.0, 80.0, 0.0, 32.0),
                items: [
                  PopupMenuItem(
                    child: Text('退出'),
                    value: 0,
                  ),
                ],
              ).then((value) {
                switch (value) {
                  case 0:
                    SystemNavigator.pop();
                    exit(0);
                    break;
                  default:
                }
              });
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          ItemIcon(
            icon: 'splash_ad',
            name: '闪屏广告',
            onTap: () {
              SplashAD(
                  posID: configID['splashID'],
                  callBack: (event, args) {
                    switch (event) {
                      case SplashADEvent.onNoAD:
                      case SplashADEvent.onADDismissed:
                        SystemChrome.setEnabledSystemUIOverlays([
                          SystemUiOverlay.top,
                          SystemUiOverlay.bottom,
                        ]);
                        SystemChrome.setSystemUIOverlayStyle(
                          SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent),
                        );
                        break;
                      default:
                    }
                  }).showAD();
            },
          ),
          ItemIcon(
            icon: 'banner_ad',
            name: '横幅广告',
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                enableDrag: true,
                builder: (context) {
                  return _buildBanner();
                },
              );
            },
          ),
          ItemIcon(
            icon: 'inters_ad',
            name: '插屏广告',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => IntersADWidget(
                  configID['intersID'],
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'reward_ad',
            name: '激励视频广告',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => RewardADWidget(
                  configID['rewardID'],
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'native_ad_express',
            name: '原生模板广告',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return NativeExpressPage();
                  },
                ),
              );
            },
          ),
          ItemIcon(
            icon: 'native_ad_unified',
            name: '原生自渲染广告',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return NativeUnifiedPage();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 横幅广告示例
  Widget _buildBanner() {
    final _adKey = GlobalKey<BannerADState>();
    final size = MediaQuery.of(context).size;
    return BannerAD(
      posID: configID['bannerID'],
      key: _adKey,
      callBack: (event, args) {
        switch (event) {
          case BannerEvent.onADClosed:
          case BannerEvent.onADCloseOverlay:
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(1.0, size.height * .82, 0.0, 0.0),
              items: [
                PopupMenuItem(
                  child: Text('刷新'),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text('关闭'),
                  value: 1,
                ),
              ],
            ).then((value) {
              switch (value) {
                case 0:
                  _adKey.currentState.loadAD();
                  break;
                case 1:
                  _adKey.currentState.closeAD();
                  Navigator.pop(context);
                  break;
                default:
              }
            });
            break;
          default:
        }
      },
      refresh: true,
    );
  }
}

class ItemIcon extends StatelessWidget {
  const ItemIcon({
    @required this.icon,
    @required this.name,
    @required this.onTap,
  });

  final String icon;
  final String name;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset(
              'assets/svg/$icon.svg',
              width: 88.0,
              height: 88.0,
              fit: BoxFit.cover,
            ),
          ),
          Text('$name'),
        ],
      ),
    );
  }
}

class IntersADWidget extends StatefulWidget {
  final String posID;

  IntersADWidget(this.posID);

  @override
  State<StatefulWidget> createState() => IntersADWidgetState();
}

class IntersADWidgetState extends State<IntersADWidget> {
  IntersAD intersAD;

  @override
  void initState() {
    super.initState();
    intersAD = IntersAD(posID: widget.posID, adEventCallback: _adEventCallback);
    intersAD.loadAD();
  }

  @override
  Widget build(BuildContext context) => Container();

  void _adEventCallback(IntersADEvent event, Map params) {
    switch (event) {
      case IntersADEvent.onADReceived:
        intersAD.showAD();
        break;
      case IntersADEvent.onADClosed:
        Navigator.of(context).pop();
        break;
      default:
    }
  }
}

class RewardADWidget extends StatefulWidget {
  final String posID;

  RewardADWidget(this.posID);

  @override
  State<StatefulWidget> createState() => RewardADWidgetState();
}

class RewardADWidgetState extends State<RewardADWidget> {
  RewardAD rewardAD;
  num money = 0.00;

  @override
  void initState() {
    super.initState();
    rewardAD = RewardAD(posID: widget.posID, adEventCallback: _adEventCallback);
    rewardAD.loadAD();
    money = Random().nextDouble() + Random().nextInt(100);
  }

  @override
  Widget build(BuildContext context) => Container();

  void _adEventCallback(RewardADEvent event, Map params) {
    switch (event) {
      case RewardADEvent.onADLoad:
        rewardAD.showAD();
        break;
      case RewardADEvent.onADClose:
      case RewardADEvent.onVideoComplete:
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: ClipRRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: BorderRadius.circular(32.0),
                  child: Card(
                    child: Container(
                      width: 320.0,
                      height: 280.0,
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: Text(
                        '恭喜你获得${money.toStringAsFixed(2)}元',
                        textScaleFactor: 2.1,
                      ),
                    ),
                  ),
                ),
              );
            });
        break;
      default:
    }
  }
}

class NativeExpressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NativeExpressPageState();
}

class _NativeExpressPageState extends State<NativeExpressPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class NativeUnifiedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NativeUnifiedPageState();
}

class _NativeUnifiedPageState extends State<NativeUnifiedPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

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
