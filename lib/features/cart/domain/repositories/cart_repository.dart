import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cart_item_entity.dart';

/// Abstract repository interface for cart
abstract class CartRepository {
  /// Get cart items for a user
  Future<Either<Failure, List<CartItemEntity>>> getCartItems(String userId);

  /// Add item to cart
  Future<Either<Failure, void>> addToCart(
      String userId, String productId, int quantity);

  /// Update item quantity
  Future<Either<Failure, void>> updateQuantity(String cartItemId, int quantity);

  /// Remove item from cart
  Future<Either<Failure, void>> removeFromCart(String cartItemId);

  /// Clear all items from cart
  Future<Either<Failure, void>> clearCart(String userId);

  /// Watch cart items stream
  Stream<List<CartItemEntity>> watchCartItems(String userId);
}
