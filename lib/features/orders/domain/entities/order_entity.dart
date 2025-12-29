import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

/// Order status enum
enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'status_pending'.tr();
      case OrderStatus.processing:
        return 'status_processing'.tr();
      case OrderStatus.shipped:
        return 'status_shipped'.tr();
      case OrderStatus.delivered:
        return 'status_delivered'.tr();
      case OrderStatus.cancelled:
        return 'status_cancelled'.tr();
    }
  }
}

/// Order item entity
class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String? productNameEn;
  final String? productImage;
  final String? productDescription;
  final String? productDescriptionEn;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productNameEn,
    this.productImage,
    this.productDescription,
    this.productDescriptionEn,
    required this.quantity,
    required this.price,
  });

  double get itemTotal => price * quantity;

  /// Get localized product name based on locale
  String getLocalizedName(String locale) {
    if (locale == 'en' && productNameEn != null && productNameEn!.isNotEmpty) {
      return productNameEn!;
    }
    return productName;
  }

  /// Get localized product description based on locale
  String? getLocalizedDescription(String locale) {
    if (locale == 'en' &&
        productDescriptionEn != null &&
        productDescriptionEn!.isNotEmpty) {
      return productDescriptionEn;
    }
    return productDescription;
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        productNameEn,
        productImage,
        productDescription,
        productDescriptionEn,
        quantity,
        price,
      ];
}

/// Order entity representing the domain model
class OrderEntity extends Equatable {
  final String id;
  final String userId;
  final double total;
  final double subtotal;
  final double discount;
  final double shippingCost;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final List<OrderItemEntity> items;
  final DateTime? createdAt;
  // Merchant/Store info
  final String? merchantId;
  final String? merchantName;
  final String? merchantPhone;
  final String? merchantAddress;
  // Payment & Coupon info
  final String? paymentMethod;
  final String? couponCode;
  final double couponDiscount;
  // Governorate info
  final String? governorateId;
  final String? governorateNameAr;
  final String? governorateNameEn;

  const OrderEntity({
    required this.id,
    required this.userId,
    required this.total,
    required this.subtotal,
    this.discount = 0,
    this.shippingCost = 0,
    required this.status,
    this.deliveryAddress,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.items = const [],
    this.createdAt,
    this.merchantId,
    this.merchantName,
    this.merchantPhone,
    this.merchantAddress,
    this.paymentMethod,
    this.couponCode,
    this.couponDiscount = 0,
    this.governorateId,
    this.governorateNameAr,
    this.governorateNameEn,
  });

  bool get hasMerchantInfo => merchantName != null && merchantName!.isNotEmpty;
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  String? getGovernorateName(String locale) {
    if (locale == 'en') {
      return governorateNameEn ?? governorateNameAr;
    }
    return governorateNameAr ?? governorateNameEn;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        total,
        subtotal,
        discount,
        shippingCost,
        status,
        deliveryAddress,
        customerName,
        customerPhone,
        notes,
        items,
        createdAt,
        merchantId,
        merchantName,
        merchantPhone,
        merchantAddress,
        paymentMethod,
        couponCode,
        couponDiscount,
        governorateId,
        governorateNameAr,
        governorateNameEn,
      ];
}
