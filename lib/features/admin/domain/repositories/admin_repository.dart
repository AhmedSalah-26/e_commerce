import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../entities/admin_stats_entity.dart';

/// Admin repository interface
abstract class AdminRepository {
  /// Get dashboard statistics
  Future<Either<Failure, AdminStatsEntity>> getStats();

  /// Get recent orders (all merchants)
  Future<Either<Failure, List<OrderEntity>>> getRecentOrders({int limit = 10});

  /// Get top selling products
  Future<Either<Failure, List<ProductEntity>>> getTopProducts({int limit = 5});

  /// Get all users with filters
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  });

  /// Toggle user status
  Future<Either<Failure, void>> toggleUserStatus(String userId, bool isActive);

  /// Check if user is admin
  Future<bool> isAdmin(String userId);

  // Phase 2: Orders
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllOrders({
    String? status,
    String? priority,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<Either<Failure, void>> updateOrderStatus(
      String orderId, String status);
  Future<Either<Failure, void>> updateOrderPriority(
      String orderId, String priority);
  Future<Either<Failure, void>> updateOrderDetails(
      String orderId, Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> getOrderDetails(String orderId);

  // Phase 3: Products
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  });
  Future<Either<Failure, void>> toggleProductStatus(
      String productId, bool isActive);
  Future<Either<Failure, void>> deleteProduct(String productId);

  // Phase 4: Categories
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCategories(
      {bool? isActive});
  Future<Either<Failure, void>> toggleCategoryStatus(
      String categoryId, bool isActive);

  // Product Suspension (Admin only)
  Future<Either<Failure, void>> suspendProduct(String productId, String reason);
  Future<Either<Failure, void>> unsuspendProduct(String productId);

  // User Ban (Admin only - Supabase Auth)
  Future<Either<Failure, Map<String, dynamic>>> banUser(
      String userId, String duration);
  Future<Either<Failure, Map<String, dynamic>>> unbanUser(String userId);

  // Rankings & Reports
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopSellingMerchants(
      {int limit = 20});
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopOrderingCustomers(
      {int limit = 20});
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getMerchantsCancellationStats({int limit = 20});
}
