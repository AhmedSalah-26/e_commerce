import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/governorate_entity.dart';
import '../entities/shipping_price_entity.dart';

abstract class ShippingRepository {
  Future<Either<Failure, List<GovernorateEntity>>> getGovernorates();
  Future<Either<Failure, List<ShippingPriceEntity>>> getMerchantShippingPrices(
      String merchantId);
  Future<Either<Failure, double>> getShippingPrice(
      String merchantId, String governorateId);
  Future<Either<Failure, void>> setShippingPrice(
      String merchantId, String governorateId, double price);
  Future<Either<Failure, void>> deleteShippingPrice(
      String merchantId, String governorateId);

  /// Get total shipping price for multiple merchants
  Future<Either<Failure, Map<String, double>>>
      getMultipleMerchantsShippingPrices(
          List<String> merchantIds, String governorateId);
}
