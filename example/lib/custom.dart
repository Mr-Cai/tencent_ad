import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toast(String value) {
  Fluttertoast.showToast(
    msg: value,
    gravity: ToastGravity.CENTER,
    backgroundColor: Colors.white,
    textColor: Colors.black,
  );
}

