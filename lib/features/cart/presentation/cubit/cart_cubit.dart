import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/network_error_handler.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_state.dart';

/// Cubit for managing cart state
class CartCubit extends Cubit<CartState> {
  final CartRepository _repository;
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

  /// Load cart items for a user
  Future<void> loadCart(String userId, {bool silent = false}) async {
    logger.i('🛒 Loading cart for user: $userId (silent: $silent)');
    _currentUserId = userId;

    // Always show loading unless silent mode is requested
    if (!silent) {
      emit(const CartLoading());
    }

    final result = await _repository.getCartItems(userId);

    result.fold(
      (failure) {
        logger.e('❌ Failed to load cart: ${failure.message}');
        // Show network error toast if applicable
        if (!silent) {
          NetworkErrorHandler.handleError(failure.message);
        }
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

  /// Subscribe to cart changes (kept for compatibility but simplified)
  void watchCart(String userId) {
    _currentUserId = userId;
    loadCart(userId);
  }

  /// Add item to cart
  /// Returns true if successful, false otherwise
  Future<bool> addToCart(String productId,
      {int quantity = 1, ProductEntity? product}) async {
    logger.i(
        '🛒 Adding to cart: productId=$productId, qty=$quantity, userId=$_currentUserId');

    if (_currentUserId == null) {
      logger.e('❌ Cannot add to cart: No user ID set');
      emit(const CartError('يجب تسجيل الدخول أولاً'));
      return false;
    }

    final result = await _repository.addToCart(
      _currentUserId!,
      productId,
      quantity,
    );

    return result.fold(
      (failure) {
        logger.e('❌ Failed to add to cart: ${failure.message}');
        return false;
      },
      (_) async {
        logger.i('✅ Added to cart successfully');
        await loadCart(_currentUserId!, silent: true);
        return true;
      },
    );
  }

  /// Update item quantity - returns true if successful
  Future<bool> updateQuantityDirect(String cartItemId, int quantity) async {
    if (_currentUserId == null) return false;

    final currentState = state;
    if (currentState is! CartLoaded) return false;

    if (quantity <= 0) {
      return removeFromCartDirect(cartItemId);
    }

    // Optimistic update
    final updatedItems = currentState.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    emit(CartLoaded(
      items: updatedItems,
      total: _calculateTotal(updatedItems),
    ));

    final result = await _repository.updateQuantity(cartItemId, quantity);

    return result.fold(
      (failure) {
        logger.e('❌ Failed to update quantity: ${failure.message}');
        loadCart(_currentUserId!, silent: true);
        return false;
      },
      (_) {
        logger.i('✅ Quantity updated successfully');
        return true;
      },
    );
  }

  /// Remove item from cart - returns true if successful
  Future<bool> removeFromCartDirect(String cartItemId) async {
    if (_currentUserId == null) return false;

    final currentState = state;
    if (currentState is! CartLoaded) return false;

    // Optimistic update
    final updatedItems =
        currentState.items.where((item) => item.id != cartItemId).toList();

    emit(CartLoaded(
      items: updatedItems,
      total: _calculateTotal(updatedItems),
    ));

    final result = await _repository.removeFromCart(cartItemId);

    return result.fold(
      (failure) {
        logger.e('❌ Failed to remove from cart: ${failure.message}');
        loadCart(_currentUserId!, silent: true);
        return false;
      },
      (_) {
        logger.i('✅ Removed from cart successfully');
        return true;
      },
    );
  }

  /// Update item quantity (optimistic update - no flickering)
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is! CartLoaded) return;

    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    final updatedItems = currentState.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    emit(CartLoaded(
      items: updatedItems,
      total: _calculateTotal(updatedItems),
    ));

    _repository.updateQuantity(cartItemId, quantity).then((result) {
      result.fold(
        (failure) {
          logger.e('❌ Failed to update quantity: ${failure.message}');
          if (NetworkErrorHandler.isNetworkError(failure.message)) {
            NetworkErrorHandler.showNetworkError();
          }
          loadCart(_currentUserId!, silent: true);
        },
        (_) {
          logger.i('✅ Quantity updated successfully');
        },
      );
    });
  }

  /// Remove item from cart
  Future<void> removeFromCart(String cartItemId) async {
    if (_currentUserId == null) return;

    final currentState = state;
    if (currentState is! CartLoaded) return;

    final updatedItems =
        currentState.items.where((item) => item.id != cartItemId).toList();

    emit(CartLoaded(
      items: updatedItems,
      total: _calculateTotal(updatedItems),
    ));

    _repository.removeFromCart(cartItemId).then((result) {
      result.fold(
        (failure) {
          logger.e('❌ Failed to remove from cart: ${failure.message}');
          if (NetworkErrorHandler.isNetworkError(failure.message)) {
            NetworkErrorHandler.showNetworkError();
          }
          loadCart(_currentUserId!, silent: true);
        },
        (_) {
          logger.i('✅ Removed from cart successfully');
        },
      );
    });
  }

  /// Clear cart
  Future<void> clearCart() async {
    if (_currentUserId == null) return;

    emit(const CartLoaded(items: [], total: 0));

    final result = await _repository.clearCart(_currentUserId!);

    result.fold(
      (failure) {
        logger.e('❌ Failed to clear cart: ${failure.message}');
        loadCart(_currentUserId!, silent: true);
      },
      (_) {
        logger.i('✅ Cart cleared successfully');
      },
    );
  }

  double _calculateTotal(List<CartItemEntity> items) {
    return items.fold(0.0, (sum, item) => sum + item.itemTotal);
  }

  double get total {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.total;
    }
    return 0;
  }

  int get itemCount {
    final currentState = state;
    if (currentState is CartLoaded) {
      return currentState.itemCount;
    }
    return 0;
  }

  Future<void> reset() async {
    emit(const CartInitial());
    if (_currentUserId != null) {
      await loadCart(_currentUserId!);
    }
  }
}
