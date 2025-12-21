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
        return 'قيد الانتظار';
      case OrderStatus.processing:
        return 'قيد المعالجة';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }
}

/// Order item entity
class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String? productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.price,
  });

  double get itemTotal => price * quantity;

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        productImage,
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
  });

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
      ];
}
