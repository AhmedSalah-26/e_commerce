import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/parent_order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

/// Implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders(String userId) async {
    try {
      final orders = await _remoteDataSource.getOrders(userId);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    try {
      final orders = await _remoteDataSource.getAllOrders();
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    try {
      final order = await _remoteDataSource.getOrderById(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createOrderFromCart(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
  }) async {
    try {
      final orderId = await _remoteDataSource.createOrderFromCart(
        userId,
        deliveryAddress,
        customerName,
        customerPhone,
        notes,
        shippingCost: shippingCost,
        governorateId: governorateId,
      );
      return Right(orderId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createMultiVendorOrder(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
    String? couponId,
    String? couponCode,
    double? couponDiscount,
  }) async {
    try {
      final parentOrderId = await _remoteDataSource.createMultiVendorOrder(
        userId,
        deliveryAddress,
        customerName,
        customerPhone,
        notes,
        shippingCost: shippingCost,
        governorateId: governorateId,
        couponId: couponId,
        couponCode: couponCode,
        couponDiscount: couponDiscount,
      );
      return Right(parentOrderId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParentOrderEntity>> getParentOrderDetails(
      String parentOrderId) async {
    try {
      final parentOrder =
          await _remoteDataSource.getParentOrderDetails(parentOrderId);
      return Right(parentOrder);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParentOrderEntity>>> getUserParentOrders(
      String userId) async {
    try {
      final parentOrders = await _remoteDataSource.getUserParentOrders(userId);
      return Right(parentOrders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<ParentOrderEntity>> watchUserParentOrders(String userId) {
    return _remoteDataSource.watchUserParentOrders(userId);
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(
      String orderId, OrderStatus status) async {
    try {
      await _remoteDataSource.updateOrderStatus(orderId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<OrderEntity>> watchOrders() {
    return _remoteDataSource.watchOrders();
  }

  @override
  Stream<List<OrderEntity>> watchUserOrders(String userId) {
    return _remoteDataSource.watchUserOrders(userId);
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrdersByMerchant(
      String merchantId) async {
    try {
      final orders = await _remoteDataSource.getOrdersByMerchant(merchantId);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<OrderEntity>> watchMerchantOrders(String merchantId) {
    return _remoteDataSource.watchMerchantOrders(merchantId);
  }

  @override
  Stream<List<OrderEntity>> watchMerchantOrdersByStatus(
      String merchantId, String status) {
    return _remoteDataSource.watchMerchantOrdersByStatus(merchantId, status);
  }

  @override
  Future<Either<Failure, Map<String, int>>> getMerchantOrdersCount(
      String merchantId) async {
    try {
      final counts = await _remoteDataSource.getMerchantOrdersCount(merchantId);
      return Right(counts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize) async {
    try {
      final orders = await _remoteDataSource.getMerchantOrdersByStatusPaginated(
          merchantId, status, page, pageSize);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMerchantStatistics(
      String merchantId, DateTime? startDate, DateTime? endDate) async {
    try {
      final stats = await _remoteDataSource.getMerchantStatistics(
          merchantId, startDate, endDate);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
