import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tencent_ad/tencent_ad_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pkg.dart';

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
  var version = '';
  var versionPic = 'https://pic.downk.cc/item/5f29e4a314195aa594a0152b.png';
  var errorCode = 'https://bit.ly/3iasdRb';
  var errorCode6000 = 'https://bit.ly/33vomdk';

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    TencentADPlugin.tencentADVersion().then(
      (value) => version = value,
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
                    child: Text('查看SDK版本'),
                    value: 0,
                  ),
                  PopupMenuItem(
                    child: Text('查看错误码'),
                    value: 1,
                  ),
                  PopupMenuItem(
                    child: Text('错误码6000'),
                    value: 2,
                  ),
                  PopupMenuItem(
                    child: Text('退出程序'),
                    value: 3,
                  ),
                ],
              ).then((value) {
                switch (value) {
                  case 0:
                    showCupertinoDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return Transform.scale(
                          scale: 1.3,
                          child: CupertinoAlertDialog(
                            title: Text('腾讯广告SDK: v$version'),
                            content: Image.network(versionPic),
                          ),
                        );
                      },
                    );
                    break;
                  case 1:
                    launch(errorCode);
                    break;
                  case 2:
                    launch(errorCode6000);
                    break;
                  case 3:
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
              showBannerAD(context);
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
