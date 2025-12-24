import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/coupon_entity.dart';

class CouponModel extends CouponEntity {
  const CouponModel({
    required super.id,
    required super.code,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.discountType,
    required super.discountValue,
    super.maxDiscountAmount,
    super.minOrderAmount,
    super.usageLimit,
    super.usageCount,
    super.usageLimitPerUser,
    required super.startDate,
    super.endDate,
    super.scope,
    super.isActive,
    super.storeId,
    required super.createdAt,
    super.productIds,
    super.categoryIds,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    // Parse product IDs from coupon_products relation
    List<String> productIds = [];
    if (json['coupon_products'] != null) {
      productIds = (json['coupon_products'] as List)
          .map((cp) => cp['product_id'] as String)
          .toList();
    }

    // Parse category IDs from coupon_categories relation
    List<String> categoryIds = [];
    if (json['coupon_categories'] != null) {
      categoryIds = (json['coupon_categories'] as List)
          .map((cc) => cc['category_id'] as String)
          .toList();
    }

    return CouponModel(
      id: json['id'] as String,
      code: json['code'] as String,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toDouble(),
      maxDiscountAmount: json['max_discount_amount'] != null
          ? (json['max_discount_amount'] as num).toDouble()
          : null,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      usageLimit: json['usage_limit'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      usageLimitPerUser: json['usage_limit_per_user'] as int? ?? 1,
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String).toLocal()
          : null,
      scope: json['scope'] as String? ?? 'all',
      isActive: json['is_active'] as bool? ?? true,
      storeId: json['store_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      productIds: productIds,
      categoryIds: categoryIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount_amount': maxDiscountAmount,
      'min_order_amount': minOrderAmount,
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'usage_limit_per_user': usageLimitPerUser,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'scope': scope,
      'is_active': isActive,
      'store_id': storeId,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'code': code.toUpperCase(),
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount_amount': maxDiscountAmount,
      'min_order_amount': minOrderAmount,
      'usage_limit': usageLimit,
      'usage_limit_per_user': usageLimitPerUser,
      'start_date': AppDateUtils.toEgyptIsoString(startDate),
      'end_date': AppDateUtils.toEgyptIsoString(endDate),
      'scope': scope,
      'is_active': isActive,
      'store_id': storeId,
    };
  }
}
