import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/governorate_model.dart';
import '../models/shipping_price_model.dart';

abstract class ShippingRemoteDataSource {
  Future<List<GovernorateModel>> getGovernorates();
  Future<List<ShippingPriceModel>> getMerchantShippingPrices(String merchantId);
  Future<double> getShippingPrice(String merchantId, String governorateId);
  Future<void> setShippingPrice(
      String merchantId, String governorateId, double price);
  Future<void> deleteShippingPrice(String merchantId, String governorateId);
}

class ShippingRemoteDataSourceImpl implements ShippingRemoteDataSource {
  final SupabaseClient _client;
  final _logger = Logger();

  ShippingRemoteDataSourceImpl(this._client);

  @override
  Future<List<GovernorateModel>> getGovernorates() async {
    try {
      _logger.d('🔍 Getting governorates');

      final response = await _client
          .from('governorates')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      final governorates = (response as List)
          .map((json) => GovernorateModel.fromJson(json))
          .toList();

      _logger.d('✅ Found ${governorates.length} governorates');
      return governorates;
    } catch (e) {
      _logger.e('❌ Error getting governorates: $e');
      rethrow;
    }
  }

  @override
  Future<List<ShippingPriceModel>> getMerchantShippingPrices(
      String merchantId) async {
    try {
      _logger.d('🔍 Getting shipping prices for merchant: $merchantId');

      final response = await _client
          .from('merchant_shipping_prices')
          .select('*, governorates(*)')
          .eq('merchant_id', merchantId)
          .eq('is_active', true);

      final prices = (response as List)
          .map((json) => ShippingPriceModel.fromJson(json))
          .toList();

      _logger.d('✅ Found ${prices.length} shipping prices');
      return prices;
    } catch (e) {
      _logger.e('❌ Error getting shipping prices: $e');
      rethrow;
    }
  }

  @override
  Future<double> getShippingPrice(
      String merchantId, String governorateId) async {
    try {
      _logger.d(
          '🔍 Getting shipping price for merchant: $merchantId, governorate: $governorateId');

      final response = await _client
          .from('merchant_shipping_prices')
          .select('price')
          .eq('merchant_id', merchantId)
          .eq('governorate_id', governorateId)
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        final price = (response['price'] as num).toDouble();
        _logger.d('✅ Shipping price: $price');
        return price;
      }

      _logger.d('⚠️ No shipping price found, returning 0');
      return 0;
    } catch (e) {
      _logger.e('❌ Error getting shipping price: $e');
      return 0;
    }
  }

  @override
  Future<void> setShippingPrice(
      String merchantId, String governorateId, double price) async {
    try {
      _logger.d(
          '💾 Setting shipping price: $price for governorate: $governorateId');

      await _client.from('merchant_shipping_prices').upsert({
        'merchant_id': merchantId,
        'governorate_id': governorateId,
        'price': price,
        'is_active': true,
      }, onConflict: 'merchant_id,governorate_id');

      _logger.d('✅ Shipping price set successfully');
    } catch (e) {
      _logger.e('❌ Error setting shipping price: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteShippingPrice(
      String merchantId, String governorateId) async {
    try {
      _logger.d('🗑️ Deleting shipping price for governorate: $governorateId');

      await _client
          .from('merchant_shipping_prices')
          .delete()
          .eq('merchant_id', merchantId)
          .eq('governorate_id', governorateId);

      _logger.d('✅ Shipping price deleted successfully');
    } catch (e) {
      _logger.e('❌ Error deleting shipping price: $e');
      rethrow;
    }
  }
}
