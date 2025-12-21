import '../../domain/entities/shipping_price_entity.dart';
import 'governorate_model.dart';

class ShippingPriceModel extends ShippingPriceEntity {
  const ShippingPriceModel({
    required super.id,
    required super.merchantId,
    required super.governorateId,
    required super.price,
    super.isActive,
    super.governorate,
  });

  factory ShippingPriceModel.fromJson(Map<String, dynamic> json) {
    return ShippingPriceModel(
      id: json['id'] as String,
      merchantId: json['merchant_id'] as String,
      governorateId: json['governorate_id'] as String,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      governorate: json['governorates'] != null
          ? GovernorateModel.fromJson(
              json['governorates'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'governorate_id': governorateId,
      'price': price,
      'is_active': isActive,
    };
  }
}
