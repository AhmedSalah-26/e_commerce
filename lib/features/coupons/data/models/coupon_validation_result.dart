class CouponValidationResult {
  final bool isValid;
  final String? couponId;
  final String? code;
  final String? nameAr;
  final String? nameEn;
  final String? discountType;
  final double? discountValue;
  final double? discountAmount;
  final double? finalAmount;
  final String? errorCode;
  final String? errorAr;
  final String? errorEn;

  const CouponValidationResult({
    required this.isValid,
    this.couponId,
    this.code,
    this.nameAr,
    this.nameEn,
    this.discountType,
    this.discountValue,
    this.discountAmount,
    this.finalAmount,
    this.errorCode,
    this.errorAr,
    this.errorEn,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    return CouponValidationResult(
      isValid: json['valid'] as bool,
      couponId: json['coupon_id'] as String?,
      code: json['code'] as String?,
      nameAr: json['name_ar'] as String?,
      nameEn: json['name_en'] as String?,
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      finalAmount: (json['final_amount'] as num?)?.toDouble(),
      errorCode: json['error_code'] as String?,
      errorAr: json['error_ar'] as String?,
      errorEn: json['error_en'] as String?,
    );
  }

  String? getError(String locale) => locale == 'ar' ? errorAr : errorEn;
  String? getName(String locale) => locale == 'ar' ? nameAr : nameEn;
}
