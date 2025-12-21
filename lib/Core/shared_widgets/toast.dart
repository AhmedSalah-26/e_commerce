import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Tost {
  static void showCustomToast(
    String message, {
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: backgroundColor,
      textColor: textColor,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
