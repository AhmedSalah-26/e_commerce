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
    String? role, // customer, merchant, admin
    String? search,
    int page = 0,
    int pageSize = 20,
  });

  /// Toggle user status
  Future<Either<Failure, void>> toggleUserStatus(String userId, bool isActive);

  /// Check if user is admin
  Future<bool> isAdmin(String userId);
}
