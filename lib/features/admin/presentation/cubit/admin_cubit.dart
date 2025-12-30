import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import '../widgets/admin_charts.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(const AdminInitial());

  /// Load dashboard data with optional date filter
  Future<void> loadDashboard({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    emit(const AdminLoading());

    final statsResult = await _repository.getStats(
      fromDate: fromDate,
      toDate: toDate,
    );

    await statsResult.fold(
      (failure) async => emit(AdminError(failure.message)),
      (stats) async {
        final ordersResult = await _repository.getRecentOrders();
        final productsResult = await _repository.getTopProducts();
        final monthlyStatsResult = await _repository.getMonthlyStats();

        // Convert monthly stats to MonthlyData objects
        final monthlyStats = monthlyStatsResult.fold(
          (f) => <MonthlyData>[],
          (data) => data.map((e) => MonthlyData.fromJson(e)).toList(),
        );

        emit(AdminLoaded(
          stats: stats,
          recentOrders: ordersResult.fold((f) => [], (orders) => orders),
          topProducts: productsResult.fold((f) => [], (products) => products),
          monthlyStats: monthlyStats,
          fromDate: fromDate,
          toDate: toDate,
        ));
      },
    );
  }

  static const int _pageSize = 20;

  /// Load users
  Future<void> loadUsers(
      {String? role, String? search, bool loadMore = false}) async {
    final currentState = state;
    int page = 0;
    List<Map<String, dynamic>> existingUsers = [];

    if (loadMore && currentState is AdminUsersLoaded) {
      if (currentState.isLoadingMore || !currentState.hasMore) return;
      page = currentState.currentPage + 1;
      existingUsers = currentState.users;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const AdminUsersLoading());
    }

    final result = await _repository.getUsers(
      role: role,
      search: search,
      page: page,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (users) {
        final allUsers = loadMore ? [...existingUsers, ...users] : users;
        emit(AdminUsersLoaded(
          allUsers,
          currentRole: role,
          currentPage: page,
          hasMore: users.length >= _pageSize,
        ));
      },
    );
  }

  /// Toggle user status
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    final result = await _repository.toggleUserStatus(userId, isActive);
    return result.isRight();
  }

  /// Check if user is admin
  Future<bool> isAdmin(String userId) async {
    return await _repository.isAdmin(userId);
  }

  // Phase 2: Orders
  Future<void> loadOrders({
    String? status,
    String? search,
    bool loadMore = false,
  }) async {
    final currentState = state;
    int page = 0;
    List<Map<String, dynamic>> existingOrders = [];

    if (loadMore && currentState is AdminOrdersLoaded) {
      if (currentState.isLoadingMore || !currentState.hasMore) return;
      page = currentState.currentPage + 1;
      existingOrders = currentState.orders;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const AdminOrdersLoading());
    }

    final result = await _repository.getAllOrders(
      status: status,
      search: search,
      page: page,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (orders) {
        final allOrders = loadMore ? [...existingOrders, ...orders] : orders;
        emit(AdminOrdersLoaded(
          allOrders,
          currentStatus: status,
          currentPage: page,
          hasMore: orders.length >= _pageSize,
        ));
      },
    );
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final result = await _repository.updateOrderStatus(orderId, status);
    return result.isRight();
  }

  Future<bool> updateOrderDetails(
      String orderId, Map<String, dynamic> data) async {
    final result = await _repository.updateOrderDetails(orderId, data);
    return result.isRight();
  }

  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    final result = await _repository.getOrderDetails(orderId);
    return result.fold((f) => null, (order) => order);
  }

  // Phase 3: Products
  Future<void> loadProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    bool loadMore = false,
  }) async {
    final currentState = state;
    int page = 0;
    List<Map<String, dynamic>> existingProducts = [];

    if (loadMore && currentState is AdminProductsLoaded) {
      if (currentState.isLoadingMore || !currentState.hasMore) return;
      page = currentState.currentPage + 1;
      existingProducts = currentState.products;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      emit(const AdminProductsLoading());
    }

    final result = await _repository.getAllProducts(
      categoryId: categoryId,
      isActive: isActive,
      search: search,
      page: page,
      pageSize: _pageSize,
    );

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (products) {
        final allProducts =
            loadMore ? [...existingProducts, ...products] : products;
        emit(AdminProductsLoaded(
          allProducts,
          isActive: isActive,
          currentPage: page,
          hasMore: products.length >= _pageSize,
        ));
      },
    );
  }

  Future<bool> toggleProductStatus(String productId, bool isActive) async {
    final result = await _repository.toggleProductStatus(productId, isActive);
    return result.isRight();
  }

  Future<bool> deleteProduct(String productId) async {
    final result = await _repository.deleteProduct(productId);
    return result.isRight();
  }

  // Phase 4: Categories
  Future<void> loadCategories({bool? isActive}) async {
    emit(const AdminCategoriesLoading());
    final result = await _repository.getAllCategories(isActive: isActive);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (categories) =>
          emit(AdminCategoriesLoaded(categories, isActive: isActive)),
    );
  }

  Future<bool> toggleCategoryStatus(String categoryId, bool isActive) async {
    final result = await _repository.toggleCategoryStatus(categoryId, isActive);
    return result.isRight();
  }

  // Product Suspension (Admin only)
  Future<bool> suspendProduct(String productId, String reason) async {
    debugPrint('🔴 AdminCubit.suspendProduct: $productId, reason: $reason');
    final result = await _repository.suspendProduct(productId, reason);
    debugPrint('🔴 AdminCubit.suspendProduct result: ${result.isRight()}');
    return result.isRight();
  }

  Future<bool> unsuspendProduct(String productId) async {
    debugPrint('🟢 AdminCubit.unsuspendProduct: $productId');
    final result = await _repository.unsuspendProduct(productId);
    debugPrint('🟢 AdminCubit.unsuspendProduct result: ${result.isRight()}');
    return result.isRight();
  }

  // User Ban (Admin only - Supabase Auth)
  Future<Map<String, dynamic>?> banUser(String userId, String duration) async {
    final result = await _repository.banUser(userId, duration);
    return result.fold((f) => null, (data) => data);
  }

  Future<Map<String, dynamic>?> unbanUser(String userId) async {
    final result = await _repository.unbanUser(userId);
    return result.fold((f) => null, (data) => data);
  }

  // Rankings & Reports
  Future<List<Map<String, dynamic>>> getTopSellingMerchants(
      {int limit = 20}) async {
    final result = await _repository.getTopSellingMerchants(limit: limit);
    return result.fold((f) => [], (data) => data);
  }

  Future<List<Map<String, dynamic>>> getTopOrderingCustomers(
      {int limit = 20}) async {
    final result = await _repository.getTopOrderingCustomers(limit: limit);
    return result.fold((f) => [], (data) => data);
  }

  Future<List<Map<String, dynamic>>> getMerchantsCancellationStats(
      {int limit = 20}) async {
    final result =
        await _repository.getMerchantsCancellationStats(limit: limit);
    return result.fold((f) => [], (data) => data);
  }

  // Coupons
  Future<List<Map<String, dynamic>>> getMerchantCoupons(
      String merchantId) async {
    final result = await _repository.getMerchantCoupons(merchantId);
    return result.fold((f) => [], (data) => data);
  }

  Future<bool> toggleCouponStatus(String couponId, bool isActive) async {
    final result = await _repository.toggleCouponStatus(couponId, isActive);
    return result.isRight();
  }

  Future<bool> suspendCoupon(String couponId, String reason) async {
    final result = await _repository.suspendCoupon(couponId, reason);
    return result.isRight();
  }

  Future<bool> unsuspendCoupon(String couponId) async {
    final result = await _repository.unsuspendCoupon(couponId);
    return result.isRight();
  }

  Future<bool> suspendAllMerchantCoupons(
      String merchantId, String reason) async {
    final result =
        await _repository.suspendAllMerchantCoupons(merchantId, reason);
    return result.isRight();
  }

  Future<bool> unsuspendAllMerchantCoupons(String merchantId) async {
    final result = await _repository.unsuspendAllMerchantCoupons(merchantId);
    return result.isRight();
  }
}
