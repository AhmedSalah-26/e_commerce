class EmailValidationHelper {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'ادخل بريدك الالكتروني';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'بريدك الالكتروني غير صالح';
    }
    return null;
  }
}
