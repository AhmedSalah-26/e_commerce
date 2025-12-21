import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

/// Base class for all cart states
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CartInitial extends CartState {
  const CartInitial();
}

/// Loading state
class CartLoading extends CartState {
  const CartLoading();
}

/// Loaded state with cart items
class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double total;

  const CartLoaded({
    required this.items,
    required this.total,
  });

  @override
  List<Object?> get props => [items, total];

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Get total items count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  CartLoaded copyWith({
    List<CartItemEntity>? items,
    double? total,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

/// Error state
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Operation in progress state (for add/update/remove)
class CartOperationInProgress extends CartState {
  const CartOperationInProgress();
}
