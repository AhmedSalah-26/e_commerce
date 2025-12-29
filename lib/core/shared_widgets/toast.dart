import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Tost {
  static DateTime? _lastToastTime;
  static const _toastDebounce = Duration(seconds: 2);

  static bool _canShowToast() {
    final now = DateTime.now();
    if (_lastToastTime != null &&
        now.difference(_lastToastTime!) < _toastDebounce) {
      return false;
    }
    _lastToastTime = now;
    return true;
  }

  static void showCustomToast(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    if (!_canShowToast()) return;

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
    if (!_canShowToast()) return;

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
    if (!_canShowToast()) return;

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
