import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit(this._repository) : super(const AdminInitial());

  /// Load dashboard data
  Future<void> loadDashboard() async {
    emit(const AdminLoading());

    final statsResult = await _repository.getStats();

    await statsResult.fold(
      (failure) async => emit(AdminError(failure.message)),
      (stats) async {
        final ordersResult = await _repository.getRecentOrders();
        final productsResult = await _repository.getTopProducts();

        emit(AdminLoaded(
          stats: stats,
          recentOrders: ordersResult.fold((f) => [], (orders) => orders),
          topProducts: productsResult.fold((f) => [], (products) => products),
        ));
      },
    );
  }

  /// Load users
  Future<void> loadUsers({String? role, String? search}) async {
    emit(const AdminUsersLoading());

    final result = await _repository.getUsers(role: role, search: search);

    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (users) => emit(AdminUsersLoaded(users, currentRole: role)),
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
  Future<void> loadOrders(
      {String? status, String? priority, String? search}) async {
    emit(const AdminOrdersLoading());
    final result = await _repository.getAllOrders(
        status: status, priority: priority, search: search);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (orders) => emit(AdminOrdersLoaded(orders, currentStatus: status)),
    );
  }

  Future<bool> updateOrderStatus(String orderId, String status) async {
    final result = await _repository.updateOrderStatus(orderId, status);
    return result.isRight();
  }

  Future<bool> updateOrderPriority(String orderId, String priority) async {
    final result = await _repository.updateOrderPriority(orderId, priority);
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
  Future<void> loadProducts(
      {String? categoryId, bool? isActive, String? search}) async {
    emit(const AdminProductsLoading());
    final result = await _repository.getAllProducts(
      categoryId: categoryId,
      isActive: isActive,
      search: search,
    );
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (products) => emit(AdminProductsLoaded(products, isActive: isActive)),
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
    final result = await _repository.suspendProduct(productId, reason);
    return result.isRight();
  }

  Future<bool> unsuspendProduct(String productId) async {
    final result = await _repository.unsuspendProduct(productId);
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
  Future<List<Map<String, dynamic>>> getTopSellingMerchants() async {
    final result = await _repository.getTopSellingMerchants();
    return result.fold((f) => [], (data) => data);
  }

  Future<List<Map<String, dynamic>>> getTopOrderingCustomers() async {
    final result = await _repository.getTopOrderingCustomers();
    return result.fold((f) => [], (data) => data);
  }

  Future<List<Map<String, dynamic>>> getMerchantsCancellationStats() async {
    final result = await _repository.getMerchantsCancellationStats();
    return result.fold((f) => [], (data) => data);
  }
}
