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
  Future<Either<Failure, AdminStatsEntity>> getStats() async {
    try {
      final stats = await _datasource.getStats();
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
}
