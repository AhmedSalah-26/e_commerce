class PasswordValidationHelper {
  static String? validatePassword(String? value) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]{8,}$',
    );

    if (value == null || value.isEmpty) {
      return 'الرقم السري مطلوب';
    } else if (value.length < 8) {
      return 'الرقم السري يجب ان يكون على الاقل 8 حروف';
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'الرقم السري يجب ان يحتوي علي حروف كبيرة';
    } else if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'الرقم السري يجب ان يحتوي علي رقم';
    } else if (!RegExp(r'(?=.*[\W_])').hasMatch(value)) {
      return 'الرقم السري يجب ان يحتوي علي حرف خاص';
    } else {
      return null;
    }

  }


}

