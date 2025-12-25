import '../../domain/entities/order_entity.dart';

/// Order item model for data layer operations
class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    super.productId,
    required super.productName,
    super.productNameEn,
    super.productImage,
    super.productDescription,
    super.productDescriptionEn,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // First try to get from order_items table directly (stored at order creation)
    String productName = json['product_name'] as String? ?? 'Unknown';
    String? productNameEn;
    String? productImage = json['product_image'] as String?;
    String? productDescription;
    String? productDescriptionEn;

    // If product data is available from JOIN, use it for translations
    final product = json['products'] as Map<String, dynamic>?;
    if (product != null) {
      // Get translations from products table
      productName = product['name_ar'] as String? ??
          product['name_en'] as String? ??
          json['product_name'] as String? ??
          'Unknown';
      productNameEn = product['name_en'] as String?;
      productDescription = product['description_ar'] as String?;
      productDescriptionEn = product['description_en'] as String?;

      // Get image from products if not in order_items
      if (productImage == null || productImage.isEmpty) {
        final images = product['images'] as List?;
        if (images != null && images.isNotEmpty) {
          productImage = images[0] as String?;
        }
      }
    }

    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: productName,
      productNameEn: productNameEn,
      productImage: productImage,
      productDescription: productDescription,
      productDescriptionEn: productDescriptionEn,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

/// Order model for data layer operations
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.total,
    required super.subtotal,
    super.discount,
    super.shippingCost,
    required super.status,
    super.deliveryAddress,
    super.customerName,
    super.customerPhone,
    super.notes,
    super.items,
    super.createdAt,
    super.merchantId,
    super.merchantName,
    super.merchantPhone,
    super.merchantAddress,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemEntity> items = [];
    if (json['order_items'] != null) {
      items = (json['order_items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList();
    }

    // Parse merchant/store info
    String? merchantName;
    String? merchantPhone;
    String? merchantAddress;

    // Try to get from stores join first
    if (json['stores'] != null) {
      final store = json['stores'];
      merchantName = store['name'] as String?;
      merchantPhone = store['phone'] as String?;
      merchantAddress = store['address'] as String?;
      // Debug: print store data
      print('🏪 Store data: $store');
    }
    // Fallback to profiles join
    else if (json['profiles'] != null) {
      final profile = json['profiles'];
      merchantName = profile['name'] as String?;
      merchantPhone = profile['phone'] as String?;
      merchantAddress = profile['address'] as String?;
    }

    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      total: (json['total'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      deliveryAddress: json['delivery_address'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      notes: json['notes'] as String?,
      items: items,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      merchantId: json['merchant_id'] as String?,
      merchantName: merchantName,
      merchantPhone: merchantPhone,
      merchantAddress: merchantAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total': total,
      'subtotal': subtotal,
      'discount': discount,
      'shipping_cost': shippingCost,
      'status': status.name,
      'delivery_address': deliveryAddress,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'notes': notes,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    double? total,
    double? subtotal,
    double? discount,
    double? shippingCost,
    OrderStatus? status,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
    List<OrderItemEntity>? items,
    DateTime? createdAt,
    String? merchantId,
    String? merchantName,
    String? merchantPhone,
    String? merchantAddress,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shippingCost: shippingCost ?? this.shippingCost,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      merchantPhone: merchantPhone ?? this.merchantPhone,
      merchantAddress: merchantAddress ?? this.merchantAddress,
    );
  }
}
