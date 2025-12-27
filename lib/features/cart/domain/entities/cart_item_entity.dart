import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Cart item entity representing the domain model
class CartItemEntity extends Equatable {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final ProductEntity? product;
  final DateTime? createdAt;

  const CartItemEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
    this.createdAt,
  });

  /// Create a copy with updated fields
  CartItemEntity copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    ProductEntity? product,
    DateTime? createdAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Calculate item total
  double get itemTotal {
    if (product == null) return 0;
    return product!.effectivePrice * quantity;
  }

  @override
  List<Object?> get props =>
      [id, userId, productId, quantity, product, createdAt];
}
