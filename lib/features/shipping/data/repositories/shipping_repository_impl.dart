import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/governorate_entity.dart';
import '../../domain/entities/shipping_price_entity.dart';
import '../../domain/repositories/shipping_repository.dart';
import '../datasources/shipping_remote_datasource.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingRemoteDataSource _remoteDataSource;

  ShippingRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<GovernorateEntity>>> getGovernorates() async {
    try {
      final governorates = await _remoteDataSource.getGovernorates();
      return Right(governorates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShippingPriceEntity>>> getMerchantShippingPrices(
      String merchantId) async {
    try {
      final prices =
          await _remoteDataSource.getMerchantShippingPrices(merchantId);
      return Right(prices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getShippingPrice(
      String merchantId, String governorateId) async {
    try {
      final price =
          await _remoteDataSource.getShippingPrice(merchantId, governorateId);
      return Right(price);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setShippingPrice(
      String merchantId, String governorateId, double price) async {
    try {
      await _remoteDataSource.setShippingPrice(
          merchantId, governorateId, price);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteShippingPrice(
      String merchantId, String governorateId) async {
    try {
      await _remoteDataSource.deleteShippingPrice(merchantId, governorateId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
