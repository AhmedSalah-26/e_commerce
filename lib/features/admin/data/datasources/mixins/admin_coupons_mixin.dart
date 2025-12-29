import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

mixin AdminCouponsMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getMerchantCouponsImpl(
      String merchantId) async {
    try {
      // Get merchant's store first
      final storeResponse = await client
          .from('stores')
          .select('id')
          .eq('merchant_id', merchantId)
          .maybeSingle();

      if (storeResponse == null) return [];

      final storeId = storeResponse['id'];

      final response = await client
          .from('coupons')
          .select('*')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get merchant coupons: $e');
    }
  }

  Future<void> toggleCouponStatusImpl(String couponId, bool isActive) async {
    try {
      await client
          .from('coupons')
          .update({'is_active': isActive}).eq('id', couponId);
    } catch (e) {
      throw ServerException('Failed to toggle coupon status: $e');
    }
  }

  Future<void> suspendCouponImpl(String couponId, String reason) async {
    try {
      final adminId = client.auth.currentUser?.id;
      await client.from('coupons').update({
        'is_active': false,
        'is_suspended': true,
        'suspension_reason': reason,
        'suspended_at': DateTime.now().toIso8601String(),
        'suspended_by': adminId,
      }).eq('id', couponId);
    } catch (e) {
      throw ServerException('Failed to suspend coupon: $e');
    }
  }

  Future<void> unsuspendCouponImpl(String couponId) async {
    try {
      await client.from('coupons').update({
        'is_suspended': false,
        'suspension_reason': null,
        'suspended_at': null,
        'suspended_by': null,
      }).eq('id', couponId);
    } catch (e) {
      throw ServerException('Failed to unsuspend coupon: $e');
    }
  }

  Future<void> suspendAllMerchantCouponsImpl(
      String merchantId, String reason) async {
    try {
      final storeResponse = await client
          .from('stores')
          .select('id')
          .eq('merchant_id', merchantId)
          .maybeSingle();

      if (storeResponse == null) return;

      final storeId = storeResponse['id'];
      final adminId = client.auth.currentUser?.id;

      await client.from('coupons').update({
        'is_active': false,
        'is_suspended': true,
        'suspension_reason': reason,
        'suspended_at': DateTime.now().toIso8601String(),
        'suspended_by': adminId,
      }).eq('store_id', storeId);
    } catch (e) {
      throw ServerException('Failed to suspend all merchant coupons: $e');
    }
  }

  Future<void> unsuspendAllMerchantCouponsImpl(String merchantId) async {
    try {
      final storeResponse = await client
          .from('stores')
          .select('id')
          .eq('merchant_id', merchantId)
          .maybeSingle();

      if (storeResponse == null) return;

      final storeId = storeResponse['id'];

      await client.from('coupons').update({
        'is_suspended': false,
        'suspension_reason': null,
        'suspended_at': null,
        'suspended_by': null,
      }).eq('store_id', storeId);
    } catch (e) {
      throw ServerException('Failed to unsuspend all merchant coupons: $e');
    }
  }
}
