import 'package:equatable/equatable.dart';
import 'governorate_entity.dart';

class ShippingPriceEntity extends Equatable {
  final String id;
  final String merchantId;
  final String governorateId;
  final double price;
  final bool isActive;
  final GovernorateEntity? governorate;

  const ShippingPriceEntity({
    required this.id,
    required this.merchantId,
    required this.governorateId,
    required this.price,
    this.isActive = true,
    this.governorate,
  });

  @override
  List<Object?> get props =>
      [id, merchantId, governorateId, price, isActive, governorate];
}
