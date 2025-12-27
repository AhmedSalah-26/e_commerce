import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/logger_service.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

/// Cubit for managing cart state
class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
  StreamSubscription<List<CartItemEntity>>? _cartSubscription;
  String? _currentUserId;

  CartCubit(this._repository) : super(const CartInitial());

  /// Set user ID for cart operations
  void setUserId(String userId) {
    logger.d('🛒 CartCubit: Setting user ID: $userId');
    _currentUserId = userId;
  }

  /// Set the locale for fetching cart items
  void setLocale(String locale) {
    if (_repository is CartRepositoryImpl) {
      (_repository).setLocale(locale);
    }
  }

  /// Load cart items for a user (silent reload if data exists)
  Future<void> loadCart(String userId, {bool silent = false}) async {
    logger.i('🛒 Loading cart for user: $userId (silent: $silent)');
    _currentUserId = userId;

    // Only show loading if no data exists and not silent
    if (!silent && state is! CartLoaded) {
      emit(const CartLoading());
    }

    final result = await _repository.getCartItems(userId);

    result.fold(
      (failure) {
        logger.e('❌ Failed to load cart: ${failure.message}');
        emit(CartError(failure.message));
      },
      (items) {
        logger.i('✅ Cart loaded: ${items.length} items');
        emit(CartLoaded(
          items: items,
          total: _calculateTotal(items),
        ));
      },
    );
  }

  /// Subscribe to cart changes
  void watchCart(String userId) {
    _currentUserId = userId;
    _cartSubscription?.cancel();
    _cartSubscription = _repository.watchCartItems(userId).listen(
      (items) {
        emit(CartLoaded(
          items: items,
          total: _calculateTotal(items),
        ));
      },
      onError: (error) {
        emit(CartError(error.toString()));
      },
    );
  }

  /// Add item to cart (optimistic update - no flickering)
  Future<void> addToCart(String productId,
      {int quantity = 1, ProductEntity? product}) async {
    logger.i(
        '🛒 Adding to cart: productId=$productId, qty=$quantity, userId=$_currentUserId');

    if (_currentUserId == null) {
      logger.e('❌ Cannot add to cart: No user ID set');
      emit(const CartError('يجب تسجيل الدخول أولاً'));
      return;
    }

    final currentState = state;

    // Check if item already exists - just update quantity
    if (currentState is CartLoaded) {
      final existingItem = currentState.items
          .where((item) => item.productId == productId)
          .firstOrNull;

      if (existingItem != null) {
        // Item exists - update quantity optimistically
        final newQuantity = existingItem.quantity + quantity;
        final updatedItems = currentState.items.map((item) {
          if (item.productId == productId) {
            return CartItemModel(
              id: item.id,
              userId: item.userId,
              productId: item.productId,
              quantity: newQuantity,
              product: item.product,
              createdAt: item.createdAt,
            );
          }
          return item;
        }).toList();

        emit(CartLoaded(
          items: updatedItems,
          total: _calculateTotal(updatedItems),
        ));

        // Update on server
        final result = await _repository.addToCart(
          _currentUserId!,
          productId,
          quantity,
        );

        result.fold(
          (failure) {
            logger.e('❌ Failed to add to cart: ${failure.message}');
            emit(CartError(failure.message));
            emit(currentState);
          },
          (_) => logger.i('✅ Added to cart successfully'),
        );
        return;
      }
    }

    // New item - add to server first then silent reload
    final result = await _repository.addToCart(
      _currentUserId!,
      productId,
      quantity,
    );

    result.fold(
      (failure) {
        logger.e('❌ Failed to add to cart: ${failure.message}');
        emit(CartError(failure.message));
        if (currentState is CartLoaded) {
          emit(currentState);
        }
      },
      (_) async {
        logger.i('✅ Added to cart, reloading silently...');
        // Silent reload - won't show loading state
        await loadCart(_currentUserId!, silent: true);
      },
    );
  }

  /// Update item quantity (optimistic update - no flickering)
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is! CartLoaded) return;

    // Optimistic update - update UI immediately
    if (quantity <= 0) {
      // Remove item locally
      final updatedItems =
          currentState.items.where((item) => item.id != cartItemId).toList();
      emit(CartLoaded(
        items: updatedItems,
        total: _calculateTotal(updatedItems),
      ));
    } else {
      // Update quantity locally
      final updatedItems = currentState.items.map((item) {
        if (item.id == cartItemId) {
          return CartItemModel(
            id: item.id,
            userId: item.userId,
            productId: item.productId,
            quantity: quantity,
            product: item.product,
            createdAt: item.createdAt,
          );
        }
        return item;
      }).toList();
      emit(CartLoaded(
        items: updatedItems,
        total: _calculateTotal(updatedItems),
      ));
    }

    // Then update on server
    final result = await _repository.updateQuantity(cartItemId, quantity);

    result.fold(
      (failure) {
        // Revert on failure
        emit(CartError(failure.message));
        emit(currentState);
      },
      (_) {
        // Success - state already updated
        logger.i('✅ Quantity updated successfully');
      },
    );
  }

  /// Remove item from cart (optimistic update - no flickering)
  Future<void> removeFromCart(String cartItemId) async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is! CartLoaded) return;

    // Optimistic update - remove from UI immediately
    final updatedItems =
        currentState.items.where((item) => item.id != cartItemId).toList();
    emit(CartLoaded(
      items: updatedItems,
      total: _calculateTotal(updatedItems),
    ));

    // Then remove from server
    final result = await _repository.removeFromCart(cartItemId);

    result.fold(
      (failure) {
        // Revert on failure
        emit(CartError(failure.message));
        emit(currentState);
      },
      (_) {
        // Success - state already updated
        logger.i('✅ Item removed successfully');
      },
    );
  }

  /// Clear cart
  Future<void> clearCart() async {
    if (_currentUserId == null) return;

    final currentState = state;

    // Optimistic update
    emit(const CartLoaded(items: [], total: 0));

    final result = await _repository.clearCart(_currentUserId!);

    result.fold(
      (failure) {
        emit(CartError(failure.message));
        if (currentState is CartLoaded) {
          emit(currentState);
        }
      },
      (_) {
        logger.i('✅ Cart cleared successfully');
      },
    );
  }

  /// Calculate total from items
  double _calculateTotal(List<CartItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  /// Get current cart total
  double get total {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.total;
    }
    return 0;
  }

  /// Get current cart items count
  int get itemCount {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.itemCount;
    }
    return 0;
  }

  /// Reset state and force reload - used when language changes
  Future<void> reset() async {
    emit(const CartInitial());
    if (_currentUserId != null) {
      await loadCart(_currentUserId!);
    }
  }

  @override
  Future<void> close() {
    _cartSubscription?.cancel();
    return super.close();
  }
}
