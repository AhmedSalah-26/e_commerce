import 'package:supabase_flutter/supabase_flutter.dart';
import 'mixins/admin_stats_mixin.dart';
import 'mixins/admin_users_mixin.dart';
import 'mixins/admin_orders_mixin.dart';
import 'mixins/admin_products_mixin.dart';
import 'mixins/admin_categories_mixin.dart';
import 'mixins/admin_reports_mixin.dart';
import 'mixins/admin_coupons_mixin.dart';
import '../models/admin_stats_model.dart';
import '../../presentation/widgets/admin_charts.dart';

/// Admin remote datasource interface
abstract class AdminRemoteDatasource {
  // Stats & Dashboard
  Future<AdminStatsModel> getStats({DateTime? fromDate, DateTime? toDate});
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10});
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5});
  Future<List<MonthlyData>> getMonthlyStats({int months = 6});

  // Users
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<void> toggleUserStatus(String userId, bool isActive);
  Future<bool> isAdmin(String userId);
  Future<Map<String, dynamic>> banUser(String userId, String duration);
  Future<Map<String, dynamic>> unbanUser(String userId);

  // Orders
  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> updateOrderDetails(String orderId, Map<String, dynamic> data);
  Future<Map<String, dynamic>> getOrderDetails(String orderId);

  // Products
  Future<List<Map<String, dynamic>>> getAllProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<void> toggleProductStatus(String productId, bool isActive);
  Future<void> deleteProduct(String productId);
  Future<void> suspendProduct(String productId, String reason);
  Future<void> unsuspendProduct(String productId);

  // Categories
  Future<List<Map<String, dynamic>>> getAllCategories({bool? isActive});
  Future<void> toggleCategoryStatus(String categoryId, bool isActive);

  // Coupons
  Future<List<Map<String, dynamic>>> getMerchantCoupons(String merchantId);
  Future<void> toggleCouponStatus(String couponId, bool isActive);
  Future<void> suspendCoupon(String couponId, String reason);
  Future<void> unsuspendCoupon(String couponId);
  Future<void> suspendAllMerchantCoupons(String merchantId, String reason);
  Future<void> unsuspendAllMerchantCoupons(String merchantId);

  // Rankings & Reports
  Future<List<Map<String, dynamic>>> getTopSellingMerchants({int limit = 20});
  Future<List<Map<String, dynamic>>> getTopOrderingCustomers({int limit = 20});
  Future<List<Map<String, dynamic>>> getMerchantsCancellationStats(
      {int limit = 20});
}

/// Admin remote datasource implementation
class AdminRemoteDatasourceImpl extends AdminRemoteDatasource
    with
        AdminStatsMixin,
        AdminUsersMixin,
        AdminOrdersMixin,
        AdminProductsMixin,
        AdminCategoriesMixin,
        AdminReportsMixin,
        AdminCouponsMixin {
  final SupabaseClient _client;

  AdminRemoteDatasourceImpl(this._client);

  @override
  SupabaseClient get client => _client;

  // Stats & Dashboard
  @override
  Future<AdminStatsModel> getStats({DateTime? fromDate, DateTime? toDate}) =>
      getStatsImpl(fromDate: fromDate, toDate: toDate);

  @override
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 10}) =>
      getRecentOrdersImpl(limit: limit);

  @override
  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) =>
      getTopProductsImpl(limit: limit);

  @override
  Future<List<MonthlyData>> getMonthlyStats({int months = 6}) =>
      getMonthlyStatsImpl(months: months);

  // Users
  @override
  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) =>
      getUsersImpl(role: role, search: search, page: page, pageSize: pageSize);

  @override
  Future<void> toggleUserStatus(String userId, bool isActive) =>
      toggleUserStatusImpl(userId, isActive);

  @override
  Future<bool> isAdmin(String userId) => isAdminImpl(userId);

  @override
  Future<Map<String, dynamic>> banUser(String userId, String duration) =>
      banUserImpl(userId, duration);

  @override
  Future<Map<String, dynamic>> unbanUser(String userId) =>
      unbanUserImpl(userId);

  // Orders
  @override
  Future<List<Map<String, dynamic>>> getAllOrders({
    String? status,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) =>
      getAllOrdersImpl(
          status: status, search: search, page: page, pageSize: pageSize);

  @override
  Future<void> updateOrderStatus(String orderId, String status) =>
      updateOrderStatusImpl(orderId, status);

  @override
  Future<void> updateOrderDetails(String orderId, Map<String, dynamic> data) =>
      updateOrderDetailsImpl(orderId, data);

  @override
  Future<Map<String, dynamic>> getOrderDetails(String orderId) =>
      getOrderDetailsImpl(orderId);

  // Products
  @override
  Future<List<Map<String, dynamic>>> getAllProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) =>
      getAllProductsImpl(
          categoryId: categoryId,
          isActive: isActive,
          search: search,
          page: page,
          pageSize: pageSize);

  @override
  Future<void> toggleProductStatus(String productId, bool isActive) =>
      toggleProductStatusImpl(productId, isActive);

  @override
  Future<void> deleteProduct(String productId) => deleteProductImpl(productId);

  @override
  Future<void> suspendProduct(String productId, String reason) =>
      suspendProductImpl(productId, reason);

  @override
  Future<void> unsuspendProduct(String productId) =>
      unsuspendProductImpl(productId);

  // Categories
  @override
  Future<List<Map<String, dynamic>>> getAllCategories({bool? isActive}) =>
      getAllCategoriesImpl(isActive: isActive);

  @override
  Future<void> toggleCategoryStatus(String categoryId, bool isActive) =>
      toggleCategoryStatusImpl(categoryId, isActive);

  // Rankings & Reports
  @override
  Future<List<Map<String, dynamic>>> getTopSellingMerchants({int limit = 20}) =>
      getTopSellingMerchantsImpl(limit: limit);

  @override
  Future<List<Map<String, dynamic>>> getTopOrderingCustomers(
          {int limit = 20}) =>
      getTopOrderingCustomersImpl(limit: limit);

  @override
  Future<List<Map<String, dynamic>>> getMerchantsCancellationStats(
          {int limit = 20}) =>
      getMerchantsCancellationStatsImpl(limit: limit);

  // Coupons
  @override
  Future<List<Map<String, dynamic>>> getMerchantCoupons(String merchantId) =>
      getMerchantCouponsImpl(merchantId);

  @override
  Future<void> toggleCouponStatus(String couponId, bool isActive) =>
      toggleCouponStatusImpl(couponId, isActive);

  @override
  Future<void> suspendCoupon(String couponId, String reason) =>
      suspendCouponImpl(couponId, reason);

  @override
  Future<void> unsuspendCoupon(String couponId) =>
      unsuspendCouponImpl(couponId);

  @override
  Future<void> suspendAllMerchantCoupons(String merchantId, String reason) =>
      suspendAllMerchantCouponsImpl(merchantId, reason);

  @override
  Future<void> unsuspendAllMerchantCoupons(String merchantId) =>
      unsuspendAllMerchantCouponsImpl(merchantId);
}
