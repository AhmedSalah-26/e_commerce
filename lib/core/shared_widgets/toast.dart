import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Tost {
  static void showCustomToast(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    toastification.show(
      context: context,
      title: Text(message, style: TextStyle(color: textColor)),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      style: ToastificationStyle.flat,
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      primaryColor: textColor,
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      icon: Icon(
        backgroundColor == Colors.green
            ? Icons.check_circle
            : backgroundColor == Colors.red
                ? Icons.error
                : backgroundColor == Colors.orange
                    ? Icons.warning
                    : Icons.info,
        color: textColor,
      ),
    );
  }

  static void showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text(message, style: const TextStyle(color: Colors.white)),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      primaryColor: Colors.white,
      closeButtonShowType: CloseButtonShowType.none,
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text(message, style: const TextStyle(color: Colors.white)),
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topCenter,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      primaryColor: Colors.white,
      closeButtonShowType: CloseButtonShowType.none,
    );
  }
}
