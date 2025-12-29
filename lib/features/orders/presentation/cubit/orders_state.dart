import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/parent_order_entity.dart';

/// Base class for all orders states
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Loading state
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Loaded state with orders
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final bool hasMore;
  final String? currentStatus;

  const OrdersLoaded(this.orders, {this.hasMore = false, this.currentStatus});

  @override
  List<Object?> get props => [orders, hasMore, currentStatus];

  /// Get orders by status
  List<OrderEntity> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Get pending orders count
  int get pendingCount => getOrdersByStatus(OrderStatus.pending).length;
}

/// Parent orders loaded state
class ParentOrdersLoaded extends OrdersState {
  final List<ParentOrderEntity> parentOrders;

  const ParentOrdersLoaded(this.parentOrders);

  @override
  List<Object?> get props => [parentOrders];
}

/// Single parent order loaded state
class ParentOrderLoaded extends OrdersState {
  final ParentOrderEntity parentOrder;

  const ParentOrderLoaded(this.parentOrder);

  @override
  List<Object?> get props => [parentOrder];
}

/// Error state
class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Order creation in progress
class OrderCreating extends OrdersState {
  const OrderCreating();
}

/// Order status updating
class OrderStatusUpdating extends OrdersState {
  final List<OrderEntity> orders;
  final String? currentStatus;

  const OrderStatusUpdating(this.orders, {this.currentStatus});

  @override
  List<Object?> get props => [orders, currentStatus];
}

/// Order created successfully
class OrderCreated extends OrdersState {
  final String orderId;

  const OrderCreated(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Multi-vendor order created successfully
class MultiVendorOrderCreated extends OrdersState {
  final String parentOrderId;

  const MultiVendorOrderCreated(this.parentOrderId);

  @override
  List<Object?> get props => [parentOrderId];
}
