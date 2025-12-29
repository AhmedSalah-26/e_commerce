import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/admin_stats_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final AdminStatsEntity stats;
  final List<OrderEntity> recentOrders;
  final List<ProductEntity> topProducts;

  const AdminLoaded({
    required this.stats,
    this.recentOrders = const [],
    this.topProducts = const [],
  });

  @override
  List<Object?> get props => [stats, recentOrders, topProducts];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

// Users states
class AdminUsersLoading extends AdminState {
  const AdminUsersLoading();
}

class AdminUsersLoaded extends AdminState {
  final List<Map<String, dynamic>> users;
  final String? currentRole;

  const AdminUsersLoaded(this.users, {this.currentRole});

  @override
  List<Object?> get props => [users, currentRole];
}

// Orders states
class AdminOrdersLoading extends AdminState {
  const AdminOrdersLoading();
}

class AdminOrdersLoaded extends AdminState {
  final List<Map<String, dynamic>> orders;
  final String? currentStatus;

  const AdminOrdersLoaded(this.orders, {this.currentStatus});

  @override
  List<Object?> get props => [orders, currentStatus];
}

// Products states
class AdminProductsLoading extends AdminState {
  const AdminProductsLoading();
}

class AdminProductsLoaded extends AdminState {
  final List<Map<String, dynamic>> products;
  final bool? isActive;

  const AdminProductsLoaded(this.products, {this.isActive});

  @override
  List<Object?> get props => [products, isActive];
}

// Categories states
class AdminCategoriesLoading extends AdminState {
  const AdminCategoriesLoading();
}

class AdminCategoriesLoaded extends AdminState {
  final List<Map<String, dynamic>> categories;
  final bool? isActive;

  const AdminCategoriesLoaded(this.categories, {this.isActive});

  @override
  List<Object?> get props => [categories, isActive];
}
