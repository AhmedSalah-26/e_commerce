import '../../domain/entities/parent_order_entity.dart';
import '../../domain/entities/order_entity.dart';
import 'order_model.dart';

/// Parent order model for data layer operations
class ParentOrderModel extends ParentOrderEntity {
  const ParentOrderModel({
    required super.id,
    required super.userId,
    required super.total,
    required super.subtotal,
    super.shippingCost,
    super.deliveryAddress,
    super.customerName,
    super.customerPhone,
    super.notes,
    super.governorateId,
    super.createdAt,
    super.subOrders,
    super.paymentMethod,
    super.paymentStatus,
    super.couponId,
    super.couponCode,
    super.couponDiscount,
  });

  factory ParentOrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderEntity> subOrders = [];
    if (json['orders'] != null) {
      subOrders = (json['orders'] as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();
    }

    return ParentOrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      total: (json['total'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
      deliveryAddress: json['delivery_address'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      notes: json['notes'] as String?,
      governorateId: json['governorate_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      subOrders: subOrders,
      paymentMethod: json['payment_method'] as String? ?? 'cash_on_delivery',
      paymentStatus: json['payment_status'] as String? ?? 'cash_on_delivery',
      couponId: json['coupon_id'] as String?,
      couponCode: json['coupon_code'] as String?,
      couponDiscount: (json['coupon_discount'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Create from RPC response (get_parent_order_details)
  static ParentOrderModel fromRpcResponse(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      throw Exception('No data found');
    }

    final firstRow = rows.first;

    // Build sub-orders from rows
    final List<OrderEntity> subOrders = rows
        .where((row) => row['order_id'] != null)
        .map((row) => OrderModel(
              id: row['order_id'] as String,
              userId: '', // Not returned from RPC
              total: (row['order_total'] as num).toDouble(),
              subtotal: (row['order_subtotal'] as num).toDouble(),
              shippingCost:
                  (row['order_shipping_cost'] as num?)?.toDouble() ?? 0,
              status: OrderStatus.fromString(
                  row['order_status'] as String? ?? 'pending'),
              merchantId: row['merchant_id'] as String?,
              merchantName: row['merchant_name'] as String?,
              merchantPhone: row['merchant_phone'] as String?,
              createdAt: row['order_created_at'] != null
                  ? DateTime.parse(row['order_created_at'] as String)
                  : null,
            ))
        .toList();

    return ParentOrderModel(
      id: firstRow['parent_order_id'] as String,
      userId: '', // Not returned from RPC
      total: (firstRow['parent_total'] as num).toDouble(),
      subtotal: (firstRow['parent_subtotal'] as num).toDouble(),
      shippingCost: (firstRow['parent_shipping_cost'] as num?)?.toDouble() ?? 0,
      deliveryAddress: firstRow['delivery_address'] as String?,
      customerName: firstRow['customer_name'] as String?,
      customerPhone: firstRow['customer_phone'] as String?,
      notes: firstRow['notes'] as String?,
      createdAt: firstRow['parent_created_at'] != null
          ? DateTime.parse(firstRow['parent_created_at'] as String)
          : null,
      subOrders: subOrders,
      paymentMethod:
          firstRow['payment_method'] as String? ?? 'cash_on_delivery',
      paymentStatus:
          firstRow['payment_status'] as String? ?? 'cash_on_delivery',
      couponId: firstRow['coupon_id'] as String?,
      couponCode: firstRow['coupon_code'] as String?,
      couponDiscount: (firstRow['coupon_discount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total': total,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'delivery_address': deliveryAddress,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'notes': notes,
      'governorate_id': governorateId,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'coupon_id': couponId,
      'coupon_code': couponCode,
      'coupon_discount': couponDiscount,
    };
  }

  ParentOrderModel copyWith({
    String? id,
    String? userId,
    double? total,
    double? subtotal,
    double? shippingCost,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
    String? governorateId,
    DateTime? createdAt,
    List<OrderEntity>? subOrders,
    String? paymentMethod,
    String? paymentStatus,
    String? couponId,
    String? couponCode,
    double? couponDiscount,
  }) {
    return ParentOrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      governorateId: governorateId ?? this.governorateId,
      createdAt: createdAt ?? this.createdAt,
      subOrders: subOrders ?? this.subOrders,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      couponId: couponId ?? this.couponId,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
    );
  }
}
