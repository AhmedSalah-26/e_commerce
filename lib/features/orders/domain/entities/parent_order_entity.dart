import 'package:equatable/equatable.dart';
import 'order_entity.dart';

/// Parent order entity for multi-vendor orders
/// Groups multiple orders from the same checkout
class ParentOrderEntity extends Equatable {
  final String id;
  final String userId;
  final double total;
  final double subtotal;
  final double shippingCost;
  final String? deliveryAddress;
  final String? customerName;
  final String? customerPhone;
  final String? notes;
  final String? governorateId;
  final DateTime? createdAt;
  final List<OrderEntity> subOrders;

  // Payment & Coupon fields
  final String? paymentMethod;
  final String? paymentStatus;
  final String? couponId;
  final String? couponCode;
  final double couponDiscount;

  const ParentOrderEntity({
    required this.id,
    required this.userId,
    required this.total,
    required this.subtotal,
    this.shippingCost = 0,
    this.deliveryAddress,
    this.customerName,
    this.customerPhone,
    this.notes,
    this.governorateId,
    this.createdAt,
    this.subOrders = const [],
    this.paymentMethod,
    this.paymentStatus,
    this.couponId,
    this.couponCode,
    this.couponDiscount = 0,
  });

  /// Check if coupon was applied
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  /// Get unique merchants count
  int get merchantCount => subOrders.length;

  /// Check if all sub-orders are delivered
  bool get isFullyDelivered =>
      subOrders.isNotEmpty &&
      subOrders.every((o) => o.status == OrderStatus.delivered);

  /// Check if any sub-order is cancelled
  bool get hasAnyCancelled =>
      subOrders.any((o) => o.status == OrderStatus.cancelled);

  /// Check if all sub-orders are cancelled
  bool get isFullyCancelled =>
      subOrders.isNotEmpty &&
      subOrders.every((o) => o.status == OrderStatus.cancelled);

  /// Get count of orders by status
  Map<OrderStatus, int> get statusCounts {
    final counts = <OrderStatus, int>{};
    for (final order in subOrders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    return counts;
  }

  /// Check if any sub-order has payment failed
  bool get hasPaymentFailed =>
      subOrders.any((o) => o.status == OrderStatus.paymentFailed);

  /// Check if all sub-orders have payment failed
  bool get isFullyPaymentFailed =>
      subOrders.isNotEmpty &&
      subOrders.every((o) => o.status == OrderStatus.paymentFailed);

  /// Get overall status based on sub-orders
  String get overallStatus {
    if (subOrders.isEmpty) return 'pending';
    // Check payment failed first
    if (isFullyPaymentFailed) return 'payment_failed';
    if (isFullyDelivered) return 'delivered';
    if (isFullyCancelled) return 'cancelled';
    if (hasAnyCancelled &&
        subOrders.every((o) =>
            o.status == OrderStatus.cancelled ||
            o.status == OrderStatus.delivered)) {
      return 'partially_cancelled';
    }
    if (subOrders.any((o) => o.status == OrderStatus.shipped)) {
      return 'shipped';
    }
    if (subOrders.any((o) => o.status == OrderStatus.processing)) {
      return 'processing';
    }
    // If any has payment failed but not all, still show pending
    if (hasPaymentFailed) return 'payment_failed';
    return 'pending';
  }

  /// Get status summary text (e.g., "2 delivered, 1 pending")
  String getStatusSummary(String Function(String) tr) {
    final counts = statusCounts;
    if (counts.isEmpty) return tr('pending');

    final parts = <String>[];
    for (final entry in counts.entries) {
      parts.add('${entry.value} ${entry.key.displayName}');
    }
    return parts.join(' • ');
  }

  /// Group sub-orders by merchant
  Map<String?, List<OrderEntity>> get ordersByMerchant {
    final Map<String?, List<OrderEntity>> grouped = {};
    for (final order in subOrders) {
      final merchantId = order.merchantId;
      if (!grouped.containsKey(merchantId)) {
        grouped[merchantId] = [];
      }
      grouped[merchantId]!.add(order);
    }
    return grouped;
  }

  /// Get first product image from all sub-orders
  String? get firstProductImage {
    for (final order in subOrders) {
      for (final item in order.items) {
        if (item.productImage != null && item.productImage!.isNotEmpty) {
          return item.productImage;
        }
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        total,
        subtotal,
        shippingCost,
        deliveryAddress,
        customerName,
        customerPhone,
        notes,
        governorateId,
        createdAt,
        subOrders,
        paymentMethod,
        paymentStatus,
        couponId,
        couponCode,
        couponDiscount,
      ];
}
