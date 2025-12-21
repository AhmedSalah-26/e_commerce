import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import 'orders_state.dart';

/// Cubit for managing orders state
class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository _repository;
  StreamSubscription<List<OrderEntity>>? _ordersSubscription;

  OrdersCubit(this._repository) : super(const OrdersInitial());

  /// Load orders for a user
  Future<void> loadOrders(String userId) async {
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

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final currentState = state;

    final result = await _repository.updateOrderStatus(orderId, status);

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (_) {
        // Refresh orders if we have a loaded state
        if (currentState is OrdersLoaded) {
          // The stream will automatically update
        }
      },
    );
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
