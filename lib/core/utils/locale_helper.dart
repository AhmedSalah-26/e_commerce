import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Helper class for locale-aware operations
class LocaleHelper {
  /// Check if current locale is Arabic
  static bool isArabic(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  /// Get current locale code
  static String getLocaleCode(BuildContext context) {
    return context.locale.languageCode;
  }
}
