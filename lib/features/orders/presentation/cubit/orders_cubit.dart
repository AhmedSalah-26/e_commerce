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
    if (isClosed) return;
    await _refreshTokenIfNeeded();
    if (isClosed) return;
    emit(const OrdersLoading());

    final result = await _repository.getOrders(userId);

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Load all orders (for merchant)
  Future<void> loadAllOrders() async {
    if (isClosed) return;
    emit(const OrdersLoading());

    final result = await _repository.getAllOrders();

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Load orders by merchant ID
  Future<void> loadMerchantOrders(String merchantId) async {
    if (isClosed) return;
    emit(const OrdersLoading());

    final result = await _repository.getOrdersByMerchant(merchantId);

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) => emit(OrdersLoaded(orders)),
    );
  }

  /// Watch merchant orders (real-time)
  void watchMerchantOrders(String merchantId) {
    if (isClosed) return;
    _ordersSubscription?.cancel();
    emit(const OrdersLoading());
    _ordersSubscription = _repository.watchMerchantOrders(merchantId).listen(
      (orders) {
        if (!isClosed) emit(OrdersLoaded(orders));
      },
      onError: (error) {
        if (!isClosed) emit(OrdersError(error.toString()));
      },
    );
  }

  /// Watch merchant orders by status (real-time)
  void watchMerchantOrdersByStatus(String merchantId, String status) {
    if (isClosed) return;
    _ordersSubscription?.cancel();
    emit(const OrdersLoading());
    _ordersSubscription =
        _repository.watchMerchantOrdersByStatus(merchantId, status).listen(
      (orders) {
        if (!isClosed) emit(OrdersLoaded(orders, currentStatus: status));
      },
      onError: (error) {
        if (!isClosed) emit(OrdersError(error.toString()));
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
    if (isClosed) return;
    if (!append) {
      emit(const OrdersLoading());
    }

    final result = await _repository.getMerchantOrdersByStatusPaginated(
        merchantId, status, page, pageSize);

    if (isClosed) return;
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
    if (isClosed) return;
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.watchOrders().listen(
      (orders) {
        if (!isClosed) emit(OrdersLoaded(orders));
      },
      onError: (error) {
        if (!isClosed) emit(OrdersError(error.toString()));
      },
    );
  }

  /// Watch user orders
  void watchUserOrders(String userId) {
    if (isClosed) return;
    _ordersSubscription?.cancel();
    emit(const OrdersLoading());
    _ordersSubscription = _repository.watchUserOrders(userId).listen(
      (orders) {
        if (!isClosed) emit(OrdersLoaded(orders));
      },
      onError: (error) {
        if (!isClosed) emit(OrdersError(error.toString()));
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
    if (isClosed) return;
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

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orderId) => emit(OrderCreated(orderId)),
    );
  }

  /// Create multi-vendor order from cart (splits by merchant)
  /// [paymentMethod] can be 'cash_on_delivery' or 'card' (pending payment)
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
    String? paymentMethod,
  }) async {
    if (isClosed) return;
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
      paymentMethod: paymentMethod,
    );

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (parentOrderId) => emit(MultiVendorOrderCreated(parentOrderId)),
    );
  }

  /// Load parent order details
  Future<void> loadParentOrderDetails(String parentOrderId) async {
    if (isClosed) return;
    emit(const OrdersLoading());

    final result = await _repository.getParentOrderDetails(parentOrderId);

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (parentOrder) => emit(ParentOrderLoaded(parentOrder)),
    );
  }

  /// Load user's parent orders
  Future<void> loadUserParentOrders(String userId) async {
    if (isClosed) return;
    await _refreshTokenIfNeeded();
    if (isClosed) return;
    emit(const OrdersLoading());

    final result = await _repository.getUserParentOrders(userId);

    if (isClosed) return;
    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (parentOrders) => emit(ParentOrdersLoaded(parentOrders)),
    );
  }

  /// Watch user's parent orders (real-time)
  void watchUserParentOrders(String userId) {
    if (isClosed) return;
    _parentOrdersSubscription?.cancel();
    emit(const OrdersLoading());

    // Refresh token before starting stream
    _refreshTokenIfNeeded().then((_) {
      if (isClosed) return;
      _parentOrdersSubscription =
          _repository.watchUserParentOrders(userId).listen(
        (parentOrders) {
          if (!isClosed) emit(ParentOrdersLoaded(parentOrders));
        },
        onError: (error) async {
          if (isClosed) return;
          final errorStr = error.toString();
          // Handle JWT errors by refreshing and retrying
          if (errorStr.contains('JWT') || errorStr.contains('token')) {
            try {
              await Supabase.instance.client.auth.refreshSession();
              // Retry watching after refresh
              if (!isClosed) watchUserParentOrders(userId);
            } catch (_) {
              if (!isClosed) emit(OrdersError(errorStr));
            }
          } else {
            if (!isClosed) emit(OrdersError(errorStr));
          }
        },
      );
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    if (isClosed) return;
    final currentState = state;

    // Show updating state with shimmer
    if (currentState is OrdersLoaded) {
      emit(OrderStatusUpdating(currentState.orders,
          currentStatus: currentState.currentStatus));
    }

    final result = await _repository.updateOrderStatus(orderId, status);

    if (isClosed) return;
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
