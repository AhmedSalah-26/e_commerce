class CouponEntity {
  final String id;
  final String code;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final int? usageLimit;
  final int usageCount;
  final int usageLimitPerUser;
  final DateTime startDate;
  final DateTime? endDate;
  final String scope; // 'all', 'products', 'categories'
  final bool isActive;
  final String? storeId;
  final DateTime createdAt;
  final List<String> productIds; // Products this coupon applies to
  final List<String> categoryIds; // Categories this coupon applies to

  const CouponEntity({
    required this.id,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minOrderAmount = 0,
    this.usageLimit,
    this.usageCount = 0,
    this.usageLimitPerUser = 1,
    required this.startDate,
    this.endDate,
    this.scope = 'all',
    this.isActive = true,
    this.storeId,
    required this.createdAt,
    this.productIds = const [],
    this.categoryIds = const [],
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : descriptionEn;

  bool get isPercentage => discountType == 'percentage';
  bool get isExpired => endDate != null && endDate!.isBefore(DateTime.now());
  bool get isStarted => startDate.isBefore(DateTime.now());
  bool get isValid => isActive && isStarted && !isExpired;
  bool get isProductSpecific => scope == 'products' && productIds.isNotEmpty;
  bool get isCategorySpecific =>
      scope == 'categories' && categoryIds.isNotEmpty;

  double calculateDiscount(double orderAmount) {
    if (orderAmount < minOrderAmount) return 0;

    double discount;
    if (isPercentage) {
      discount = orderAmount * (discountValue / 100);
      if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
        discount = maxDiscountAmount!;
      }
    } else {
      discount = discountValue;
    }

    return discount > orderAmount ? orderAmount : discount;
  }
}
