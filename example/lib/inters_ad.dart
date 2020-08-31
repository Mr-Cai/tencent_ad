import 'package:flutter/material.dart';
import 'package:tencent_ad/inters_ad.dart';

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
    intersAD = IntersAD(posID: widget.posID, callback: _callback);
    intersAD.loadAD();
  }

  @override
  Widget build(BuildContext context) => Container();

  void _callback(IntersADEvent event, Map params) {
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
