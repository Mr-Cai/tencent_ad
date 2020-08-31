import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tencent_ad/reward_ad.dart';

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
    rewardAD = RewardAD(posID: widget.posID, callback: _callback);
    rewardAD.loadAD();
    money = Random().nextDouble() + Random().nextInt(100);
  }

  @override
  Widget build(BuildContext context) => Container();

  void _callback(RewardADEvent event, Map params) {
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
