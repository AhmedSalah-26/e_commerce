import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/network_error_handler.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
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
    // Just load cart instead of watching
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

    // Add to server
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
        // Reload cart to get updated data
        await loadCart(_currentUserId!, silent: true);
        return true;
      },
    );
  }

  /// Update item quantity with full screen error on failure
  /// Returns true if successful
  Future<bool> updateQuantityWithRetry(
      String cartItemId, int quantity, BuildContext context) async {
    if (_currentUserId == null) return false;

    final currentState = state;
    if (currentState is! CartLoaded) return false;

    if (quantity <= 0) {
      return removeFromCartWithRetry(cartItemId, context);
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
        if (NetworkErrorHandler.isNetworkError(failure.message)) {
          // Show full screen error
          NetworkErrorWidget.showFullScreen(
            context,
            onRetry: () =>
                updateQuantityWithRetry(cartItemId, quantity, context),
          );
        }
        loadCart(_currentUserId!, silent: true);
        return false;
      },
      (_) {
        logger.i('✅ Quantity updated successfully');
        return true;
      },
    );
  }

  /// Remove item from cart with full screen error on failure
  /// Returns true if successful
  Future<bool> removeFromCartWithRetry(
      String cartItemId, BuildContext context) async {
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
        if (NetworkErrorHandler.isNetworkError(failure.message)) {
          // Show full screen error
          NetworkErrorWidget.showFullScreen(
            context,
            onRetry: () => removeFromCartWithRetry(cartItemId, context),
          );
        }
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

    // If quantity is 0 or less, remove the item instead
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }

    // Optimistic update - update local state immediately
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

    // Update on server in background (no await, no reload)
    _repository.updateQuantity(cartItemId, quantity).then((result) {
      result.fold(
        (failure) {
          logger.e('❌ Failed to update quantity: ${failure.message}');
          // Check for network error
          if (NetworkErrorHandler.isNetworkError(failure.message)) {
            NetworkErrorHandler.showNetworkError();
          }
          // Reload on error to sync with server
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

    // Optimistic update - remove from local state immediately
    final updatedItems =
        currentState.items.where((item) => item.id != cartItemId).toList();

    emit(CartLoaded(
      items: updatedItems,
      total: _calculateTotal(updatedItems),
    ));

    // Remove from server in background (no await, no reload)
    _repository.removeFromCart(cartItemId).then((result) {
      result.fold(
        (failure) {
          logger.e('❌ Failed to remove from cart: ${failure.message}');
          // Check for network error
          if (NetworkErrorHandler.isNetworkError(failure.message)) {
            NetworkErrorHandler.showNetworkError();
          }
          // Reload on error to sync with server
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
        // Reload to get actual state
        loadCart(_currentUserId!, silent: true);
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
}
