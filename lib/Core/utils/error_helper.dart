/// Helper class to convert technical errors to user-friendly messages
class ErrorHelper {
  static String getUserFriendlyMessage(String error) {
    final lowerError = error.toLowerCase();

    // Network errors
    if (lowerError.contains('socketexception') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network') ||
        lowerError.contains('connection')) {
      return 'خطأ في الاتصال بالإنترنت';
    }

    // Auth errors
    if (lowerError.contains('invalid login credentials') ||
        lowerError.contains('invalid_credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (lowerError.contains('email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني';
    }

    if (lowerError.contains('user already registered') ||
        lowerError.contains('already exists')) {
      return 'هذا البريد الإلكتروني مسجل مسبقاً';
    }

    if (lowerError.contains('password')) {
      return 'كلمة المرور غير صحيحة';
    }

    // Timeout errors
    if (lowerError.contains('timeout')) {
      return 'انتهت مهلة الاتصال، حاول مرة أخرى';
    }

    // Server errors
    if (lowerError.contains('500') || lowerError.contains('server')) {
      return 'خطأ في الخادم، حاول لاحقاً';
    }

    // Permission errors
    if (lowerError.contains('permission') || lowerError.contains('denied')) {
      return 'ليس لديك صلاحية لهذا الإجراء';
    }

    // Not found errors
    if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'البيانات غير موجودة';
    }

    // Default error
    return 'حدث خطأ، حاول مرة أخرى';
  }
}
