import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException(this.message, {this.code});
}

class CacheException implements Exception {
  final String message;
  final String? code;
  const CacheException(this.message, {this.code});
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});

  factory AuthException.invalidCredentials() {
    return const AuthException(
      'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      code: 'invalid_credentials',
    );
  }

  factory AuthException.emailAlreadyInUse() {
    return const AuthException(
      'البريد الإلكتروني مستخدم بالفعل',
      code: 'email_already_in_use',
    );
  }

  factory AuthException.weakPassword() {
    return const AuthException(
      'كلمة المرور ضعيفة جداً',
      code: 'weak_password',
    );
  }

  factory AuthException.userNotFound() {
    return const AuthException(
      'المستخدم غير موجود',
      code: 'user_not_found',
    );
  }

  factory AuthException.fromSupabaseAuthError(supabase.AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return AuthException.invalidCredentials();
    }
    if (message.contains('email already registered') ||
        message.contains('already registered')) {
      return AuthException.emailAlreadyInUse();
    }
    if (message.contains('weak password')) {
      return AuthException.weakPassword();
    }
    if (message.contains('user not found')) {
      return AuthException.userNotFound();
    }
    return AuthException(error.message, code: 'auth_error');
  }

  @override
  String toString() => message;
}
