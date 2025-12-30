import 'package:equatable/equatable.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../widgets/admin_charts.dart';

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
  final List<MonthlyData>? monthlyStats;
  final DateTime? fromDate;
  final DateTime? toDate;

  const AdminLoaded({
    required this.stats,
    this.recentOrders = const [],
    this.topProducts = const [],
    this.monthlyStats,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props =>
      [stats, recentOrders, topProducts, monthlyStats, fromDate, toDate];
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
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const AdminUsersLoaded(
    this.users, {
    this.currentRole,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  AdminUsersLoaded copyWith({
    List<Map<String, dynamic>>? users,
    String? currentRole,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return AdminUsersLoaded(
      users ?? this.users,
      currentRole: currentRole ?? this.currentRole,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [users, currentRole, currentPage, hasMore, isLoadingMore];
}

// Orders states
class AdminOrdersLoading extends AdminState {
  const AdminOrdersLoading();
}

class AdminOrdersLoaded extends AdminState {
  final List<Map<String, dynamic>> orders;
  final String? currentStatus;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const AdminOrdersLoaded(
    this.orders, {
    this.currentStatus,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  AdminOrdersLoaded copyWith({
    List<Map<String, dynamic>>? orders,
    String? currentStatus,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return AdminOrdersLoaded(
      orders ?? this.orders,
      currentStatus: currentStatus ?? this.currentStatus,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [orders, currentStatus, currentPage, hasMore, isLoadingMore];
}

// Products states
class AdminProductsLoading extends AdminState {
  const AdminProductsLoading();
}

class AdminProductsLoaded extends AdminState {
  final List<Map<String, dynamic>> products;
  final bool? isActive;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const AdminProductsLoaded(
    this.products, {
    this.isActive,
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  AdminProductsLoaded copyWith({
    List<Map<String, dynamic>>? products,
    bool? isActive,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return AdminProductsLoaded(
      products ?? this.products,
      isActive: isActive ?? this.isActive,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [products, isActive, currentPage, hasMore, isLoadingMore];
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
