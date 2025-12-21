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
      return 'خطأ في الاتصال بالإنترنت';
    }

    // Auth errors - Invalid credentials (most common)
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid_credentials') ||
        lowerError.contains('invalid credentials') ||
        lowerError.contains('البريد الإلكتروني أو كلمة المرور غير صحيحة')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    // User not found
    if (lowerError.contains('user not found') ||
        lowerError.contains('no user found') ||
        lowerError.contains('email not found') ||
        lowerError.contains('المستخدم غير موجود')) {
      return 'هذا الحساب غير موجود';
    }

    // Email not confirmed
    if (lowerError.contains('email not confirmed') ||
        lowerError.contains('confirm your email')) {
      return 'يرجى تأكيد البريد الإلكتروني';
    }

    // User already registered
    if (lowerError.contains('user already registered') ||
        lowerError.contains('already exists') ||
        lowerError.contains('already registered') ||
        lowerError.contains('email already') ||
        lowerError.contains('البريد الإلكتروني مستخدم')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً';
    }

    // Invalid email
    if (lowerError.contains('invalid email') ||
        lowerError.contains('email invalid') ||
        lowerError.contains('البريد الإلكتروني غير صالح')) {
      return 'البريد الإلكتروني غير صالح';
    }

    // Password errors
    if (lowerError.contains('weak password') ||
        lowerError.contains('كلمة المرور ضعيفة')) {
      return 'كلمة المرور ضعيفة جداً';
    }

    if (lowerError.contains('password') &&
        !lowerError.contains('invalid login')) {
      return 'كلمة المرور غير صحيحة';
    }

    // Timeout errors
    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return 'انتهت مهلة الاتصال، حاول مرة أخرى';
    }

    // Server errors
    if (lowerError.contains('500') ||
        lowerError.contains('internal server') ||
        lowerError.contains('server error')) {
      return 'خطأ في الخادم، حاول لاحقاً';
    }

    // Permission errors
    if (lowerError.contains('permission') ||
        lowerError.contains('denied') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('forbidden')) {
      return 'ليس لديك صلاحية لهذا الإجراء';
    }

    // Not found errors
    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'البيانات غير موجودة';
    }

    // Rate limit
    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many requests') ||
        lowerError.contains('too many')) {
      return 'محاولات كثيرة، انتظر قليلاً';
    }

    // If error is already in Arabic, return it
    if (_isArabic(error)) {
      return error;
    }

    // Default error
    return 'حدث خطأ، حاول مرة أخرى';
  }

  static bool _isArabic(String text) {
    // Check if text contains Arabic characters
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }
}
