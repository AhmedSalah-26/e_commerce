import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Cart item model for data layer operations
class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.userId,
    required super.productId,
    required super.quantity,
    super.product,
    super.createdAt,
  });

  /// Create CartItemModel from JSON (Supabase response) with locale
  factory CartItemModel.fromJson(Map<String, dynamic> json,
      {String locale = 'ar'}) {
    ProductEntity? product;
    if (json['products'] != null) {
      product = ProductModel.fromJson(
        json['products'] as Map<String, dynamic>,
        locale: locale,
      );
    }

    return CartItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      product: product,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert CartItemModel to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  /// Convert to JSON for insert (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
    };
  }

  /// Create a copy with updated fields
  @override
  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    ProductEntity? product,
    DateTime? createdAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
