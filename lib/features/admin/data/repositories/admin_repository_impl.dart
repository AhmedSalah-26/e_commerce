import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/data/models/product_model.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource _datasource;

  AdminRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, AdminStatsEntity>> getStats({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final stats = await _datasource.getStats(
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getRecentOrders(
      {int limit = 10}) async {
    try {
      final data = await _datasource.getRecentOrders(limit: limit);
      final orders = data.map((json) => OrderModel.fromJson(json)).toList();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getTopProducts(
      {int limit = 5}) async {
    try {
      final data = await _datasource.getTopProducts(limit: limit);
      final products = data.map((json) => ProductModel.fromJson(json)).toList();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({
    String? role,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final users = await _datasource.getUsers(
        role: role,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleUserStatus(
      String userId, bool isActive) async {
    try {
      await _datasource.toggleUserStatus(userId, isActive);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<bool> isAdmin(String userId) async {
    return await _datasource.isAdmin(userId);
  }

  // Phase 2: Orders
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllOrders({
    String? status,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final orders = await _datasource.getAllOrders(
        status: status,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
      String orderId, String status) async {
    try {
      await _datasource.updateOrderStatus(orderId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderDetails(
      String orderId, Map<String, dynamic> data) async {
    try {
      await _datasource.updateOrderDetails(orderId, data);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getOrderDetails(
      String orderId) async {
    try {
      final order = await _datasource.getOrderDetails(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // Phase 3: Products
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllProducts({
    String? categoryId,
    bool? isActive,
    String? search,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final products = await _datasource.getAllProducts(
        categoryId: categoryId,
        isActive: isActive,
        search: search,
        page: page,
        pageSize: pageSize,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleProductStatus(
      String productId, bool isActive) async {
    try {
      await _datasource.toggleProductStatus(productId, isActive);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await _datasource.deleteProduct(productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // Phase 4: Categories
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCategories(
      {bool? isActive}) async {
    try {
      final categories = await _datasource.getAllCategories(isActive: isActive);
      return Right(categories);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCategoryStatus(
      String categoryId, bool isActive) async {
    try {
      await _datasource.toggleCategoryStatus(categoryId, isActive);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // Product Suspension (Admin only)
  @override
  Future<Either<Failure, void>> suspendProduct(
      String productId, String reason) async {
    print('🔴 Repository.suspendProduct CALLED: $productId');
    try {
      await _datasource.suspendProduct(productId, reason);
      print('🔴 Repository.suspendProduct SUCCESS');
      return const Right(null);
    } on ServerException catch (e) {
      print('🔴 Repository.suspendProduct ERROR: ${e.message}');
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unsuspendProduct(String productId) async {
    print('🟢 Repository.unsuspendProduct CALLED: $productId');
    try {
      await _datasource.unsuspendProduct(productId);
      print('🟢 Repository.unsuspendProduct SUCCESS');
      return const Right(null);
    } on ServerException catch (e) {
      print('🟢 Repository.unsuspendProduct ERROR: ${e.message}');
      return Left(ServerFailure(e.message));
    }
  }

  // User Ban (Admin only - Supabase Auth)
  @override
  Future<Either<Failure, Map<String, dynamic>>> banUser(
      String userId, String duration) async {
    try {
      final result = await _datasource.banUser(userId, duration);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> unbanUser(String userId) async {
    try {
      final result = await _datasource.unbanUser(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // Rankings & Reports
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopSellingMerchants(
      {int limit = 20}) async {
    try {
      final result = await _datasource.getTopSellingMerchants(limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopOrderingCustomers(
      {int limit = 20}) async {
    try {
      final result = await _datasource.getTopOrderingCustomers(limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getMerchantsCancellationStats({int limit = 20}) async {
    try {
      final result =
          await _datasource.getMerchantsCancellationStats(limit: limit);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // Coupons
  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMerchantCoupons(
      String merchantId) async {
    try {
      final result = await _datasource.getMerchantCoupons(merchantId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCouponStatus(
      String couponId, bool isActive) async {
    try {
      await _datasource.toggleCouponStatus(couponId, isActive);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> suspendCoupon(
      String couponId, String reason) async {
    try {
      await _datasource.suspendCoupon(couponId, reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unsuspendCoupon(String couponId) async {
    try {
      await _datasource.unsuspendCoupon(couponId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> suspendAllMerchantCoupons(
      String merchantId, String reason) async {
    try {
      await _datasource.suspendAllMerchantCoupons(merchantId, reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unsuspendAllMerchantCoupons(
      String merchantId) async {
    try {
      await _datasource.unsuspendAllMerchantCoupons(merchantId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
