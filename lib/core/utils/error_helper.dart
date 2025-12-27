import 'package:easy_localization/easy_localization.dart';

/// Helper class to convert technical errors to user-friendly messages
class ErrorHelper {
  static String getUserFriendlyMessage(String error) {
    final lowerError = error.toLowerCase();

    // Network errors
    if (lowerError.contains('socketexception') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network') ||
        lowerError.contains('connection refused') ||
        lowerError.contains('no internet')) {
      return 'error_network'.tr();
    }

    // Auth errors - Invalid credentials (most common)
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid_credentials') ||
        lowerError.contains('invalid credentials') ||
        lowerError.contains('البريد الإلكتروني أو كلمة المرور غير صحيحة')) {
      return 'error_invalid_credentials'.tr();
    }

    // User not found
    if (lowerError.contains('user not found') ||
        lowerError.contains('no user found') ||
        lowerError.contains('email not found') ||
        lowerError.contains('المستخدم غير موجود')) {
      return 'error_user_not_found'.tr();
    }

    // Email not confirmed
    if (lowerError.contains('email not confirmed') ||
        lowerError.contains('confirm your email')) {
      return 'error_email_not_confirmed'.tr();
    }

    // User already registered
    if (lowerError.contains('user already registered') ||
        lowerError.contains('already exists') ||
        lowerError.contains('already registered') ||
        lowerError.contains('email already') ||
        lowerError.contains('البريد الإلكتروني مستخدم')) {
      return 'error_email_exists'.tr();
    }

    // Invalid email
    if (lowerError.contains('invalid email') ||
        lowerError.contains('email invalid') ||
        lowerError.contains('البريد الإلكتروني غير صالح')) {
      return 'error_invalid_email'.tr();
    }

    // Password errors
    if (lowerError.contains('weak password') ||
        lowerError.contains('كلمة المرور ضعيفة')) {
      return 'error_weak_password'.tr();
    }

    if (lowerError.contains('password') &&
        !lowerError.contains('invalid login')) {
      return 'error_wrong_password'.tr();
    }

    // Timeout errors
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return 'error_timeout'.tr();
    }

    // Server errors
    if (lowerError.contains('500') ||
        lowerError.contains('internal server') ||
        lowerError.contains('server error')) {
      return 'error_server'.tr();
    }

    // Permission errors
    if (lowerError.contains('permission') ||
        lowerError.contains('denied') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('forbidden')) {
      return 'error_permission'.tr();
    }

    // Not found errors
    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'error_not_found'.tr();
    }

    // Rate limit
    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many requests') ||
        lowerError.contains('too many')) {
      return 'error_rate_limit'.tr();
    }

    // If error is already in Arabic, return it
    if (_isArabic(error)) {
      return error;
    }

    // Default error
    return 'error_generic'.tr();
  }

  static bool _isArabic(String text) {
    // Check if text contains Arabic characters
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
