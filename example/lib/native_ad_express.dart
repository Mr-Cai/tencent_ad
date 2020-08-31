import 'package:flutter/material.dart';
import 'package:tencent_ad/native_ad_express.dart';

class NativeExpressPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NativeExpressPageState();
}

class _NativeExpressPageState extends State<NativeExpressPage> {
  final adKey = GlobalKey<NativeADExpressState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          '腾讯广告',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.values[0],
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: 10,
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if (index % 3 == 0) {
            // return NativeADWidget(
            //   adKey: adKey,
            //   adHeight: 300.0,
            //   posID: configID['nativeExpressID'],
            //   adCount: 10,
            //   adIndex: index,
            //   callback: (event, arguments) {
            //     switch (event) {
            //       case NativeADEvent.onNoAD:
            //         adKey.currentState.onNoAD().then((value) => toast(value));
            //         break;
            //       default:
            //     }
            //   },
            // );
          }
          return Container(
            height: 240.0,
            margin: const EdgeInsets.all(8.0),
            color: Colors.orange,
          );
        },
      ),
    );
  }
}
