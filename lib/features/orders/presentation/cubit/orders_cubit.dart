import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/parent_order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

/// Cubit for managing orders state
class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _repository;
  StreamSubscription<List<OrderEntity>>? _ordersSubscription;
  StreamSubscription<List<ParentOrderEntity>>? _parentOrdersSubscription;

  OrdersCubit(this._repository) : super(const OrdersInitial());

  /// Helper to refresh token if needed
  Future<void> _refreshTokenIfNeeded() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        final expiresAt = session.expiresAt;
        if (expiresAt != null) {
          final expiryTime =
              DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
          // Refresh if token expires in less than 5 minutes
          if (expiryTime.difference(DateTime.now()).inMinutes < 5) {
            await Supabase.instance.client.auth.refreshSession();
          }
        }
      }
    } catch (_) {
      // Silently fail - auto refresh should handle it
    }
  }

  /// Load orders for a user
  Future<void> loadOrders(String userId) async {
    await _refreshTokenIfNeeded();
    emit(const OrdersLoading());

    final result = await _repository.getOrders(userId);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Load all orders (for merchant)
  Future<void> loadAllOrders() async {
    emit(const OrdersLoading());

    final result = await _repository.getAllOrders();

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Load orders by merchant ID
  Future<void> loadMerchantOrders(String merchantId) async {
    emit(const OrdersLoading());

    final result = await _repository.getOrdersByMerchant(merchantId);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Watch merchant orders (real-time)
  void watchMerchantOrders(String merchantId) {
    _ordersSubscription?.cancel();
    emit(const OrdersLoading());
    _ordersSubscription = _repository.watchMerchantOrders(merchantId).listen(
      (orders) {
        emit(OrdersLoaded(orders));
      },
      onError: (error) {
        emit(OrdersError(error.toString()));
      },
    );
  }

  /// Watch merchant orders by status (real-time)
  void watchMerchantOrdersByStatus(String merchantId, String status) {
    _ordersSubscription?.cancel();
    emit(const OrdersLoading());
    _ordersSubscription =
        _repository.watchMerchantOrdersByStatus(merchantId, status).listen(
      (orders) {
        emit(OrdersLoaded(orders, currentStatus: status));
      },
      onError: (error) {
        emit(OrdersError(error.toString()));
      },
    );
  }

  /// Get merchant orders count for today
  Future<Map<String, int>> getMerchantOrdersCount(String merchantId) async {
    final result = await _repository.getMerchantOrdersCount(merchantId);
    return result.fold(
      (failure) => {'todayPending': 0, 'todayDelivered': 0},
      (counts) => counts,
    );
  }

  /// Load merchant orders by status with pagination
  Future<void> loadMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize,
      {bool append = false}) async {
    if (!append) {
      emit(const OrdersLoading());
    }

    final result = await _repository.getMerchantOrdersByStatusPaginated(
        merchantId, status, page, pageSize);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (newOrders) {
        if (append && state is OrdersLoaded) {
          final currentState = state as OrdersLoaded;
          // Only append if same status
          if (currentState.currentStatus == status) {
            emit(OrdersLoaded([...currentState.orders, ...newOrders],
                hasMore: newOrders.length == pageSize, currentStatus: status));
          } else {
            emit(OrdersLoaded(newOrders,
                hasMore: newOrders.length == pageSize, currentStatus: status));
          }
        } else {
          emit(OrdersLoaded(newOrders,
              hasMore: newOrders.length == pageSize, currentStatus: status));
        }
      },
    );
  }

  /// Get merchant statistics
  Future<Map<String, dynamic>> getMerchantStatistics(
      String merchantId, DateTime? startDate, DateTime? endDate) async {
    final result =
        await _repository.getMerchantStatistics(merchantId, startDate, endDate);
    return result.fold(
      (failure) => {
        'total': 0,
        'pending': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
        'revenue': 0.0,
      },
      (stats) => stats,
    );
  }

  /// Watch all orders (for merchant)
  void watchAllOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.watchOrders().listen(
      (orders) {
        emit(OrdersLoaded(orders));
      },
      onError: (error) {
        emit(OrdersError(error.toString()));
      },
    );
  }

  /// Watch user orders
  void watchUserOrders(String userId) {
    _ordersSubscription?.cancel();
    emit(const OrdersLoading());
    _ordersSubscription = _repository.watchUserOrders(userId).listen(
      (orders) {
        emit(OrdersLoaded(orders));
      },
      onError: (error) {
        emit(OrdersError(error.toString()));
      },
    );
  }

  /// Create order from cart
  Future<void> createOrderFromCart(
    String userId, {
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
    double? shippingCost,
    String? governorateId,
  }) async {
    emit(const OrderCreating());

    final result = await _repository.createOrderFromCart(
      userId,
      deliveryAddress,
      customerName,
      customerPhone,
      notes,
      shippingCost: shippingCost,
      governorateId: governorateId,
    );

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orderId) => emit(OrderCreated(orderId)),
    );
  }

  /// Create multi-vendor order from cart (splits by merchant)
  Future<void> createMultiVendorOrder(
    String userId, {
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
    double? shippingCost,
    String? governorateId,
    String? couponId,
    String? couponCode,
    double? couponDiscount,
  }) async {
    emit(const OrderCreating());

    final result = await _repository.createMultiVendorOrder(
      userId,
      deliveryAddress,
      customerName,
      customerPhone,
      notes,
      shippingCost: shippingCost,
      governorateId: governorateId,
      couponId: couponId,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
    );

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (parentOrderId) => emit(MultiVendorOrderCreated(parentOrderId)),
    );
  }

  /// Load parent order details
  Future<void> loadParentOrderDetails(String parentOrderId) async {
    emit(const OrdersLoading());

    final result = await _repository.getParentOrderDetails(parentOrderId);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (parentOrder) => emit(ParentOrderLoaded(parentOrder)),
    );
  }

  /// Load user's parent orders
  Future<void> loadUserParentOrders(String userId) async {
    await _refreshTokenIfNeeded();
    emit(const OrdersLoading());

    final result = await _repository.getUserParentOrders(userId);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (parentOrders) => emit(ParentOrdersLoaded(parentOrders)),
    );
  }

  /// Watch user's parent orders (real-time)
  void watchUserParentOrders(String userId) {
    _parentOrdersSubscription?.cancel();
    emit(const OrdersLoading());

    // Refresh token before starting stream
    _refreshTokenIfNeeded().then((_) {
      _parentOrdersSubscription =
          _repository.watchUserParentOrders(userId).listen(
        (parentOrders) {
          emit(ParentOrdersLoaded(parentOrders));
        },
        onError: (error) async {
          final errorStr = error.toString();
          // Handle JWT errors by refreshing and retrying
          if (errorStr.contains('JWT') || errorStr.contains('token')) {
            try {
              await Supabase.instance.client.auth.refreshSession();
              // Retry watching after refresh
              watchUserParentOrders(userId);
            } catch (_) {
              emit(OrdersError(errorStr));
            }
          } else {
            emit(OrdersError(errorStr));
          }
        },
      );
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final currentState = state;

    // Show updating state with shimmer
    if (currentState is OrdersLoaded) {
      emit(OrderStatusUpdating(currentState.orders,
          currentStatus: currentState.currentStatus));
    }

    final result = await _repository.updateOrderStatus(orderId, status);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (_) {
        // The stream will automatically update with new data
        // Keep the updating state until stream updates
      },
    );
  }

  /// Reset state - used when language changes
  void reset() {
    _ordersSubscription?.cancel();
    _parentOrdersSubscription?.cancel();
    emit(const OrdersInitial());
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    _parentOrdersSubscription?.cancel();
    return super.close();
  }
}
