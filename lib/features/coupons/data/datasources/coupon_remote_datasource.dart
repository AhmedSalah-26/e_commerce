import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coupon_model.dart';
import '../models/coupon_validation_result.dart';

class CouponRemoteDatasource {
  final SupabaseClient _client;

  CouponRemoteDatasource(this._client);

  /// التحقق من صلاحية الكوبون
  Future<CouponValidationResult> validateCoupon({
    required String code,
    required String userId,
    required double orderAmount,
    String? storeId,
    List<String>? productIds,
  }) async {
    final response = await _client.rpc('validate_coupon', params: {
      'p_coupon_code': code.toUpperCase(),
      'p_user_id': userId,
      'p_order_amount': orderAmount,
      'p_store_id': storeId,
      'p_product_ids': productIds,
    });

    return CouponValidationResult.fromJson(response as Map<String, dynamic>);
  }

  /// تطبيق الكوبون على الطلب
  Future<bool> applyCouponToOrder({
    required String couponId,
    required String userId,
    required String orderId,
    required double discountAmount,
  }) async {
    final response = await _client.rpc('apply_coupon_to_order', params: {
      'p_coupon_id': couponId,
      'p_user_id': userId,
      'p_order_id': orderId,
      'p_discount_amount': discountAmount,
    });

    return response as bool;
  }

  /// جلب كوبونات المتجر (للتاجر)
  Future<List<CouponModel>> getStoreCoupons(String storeId) async {
    final response = await _client
        .from('coupons')
        .select(
            '*, coupon_products(product_id), coupon_categories(category_id)')
        .eq('store_id', storeId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CouponModel.fromJson(json))
        .toList();
  }

  /// جلب الكوبونات العامة (للأدمن)
  Future<List<CouponModel>> getGlobalCoupons() async {
    final response = await _client
        .from('coupons')
        .select(
            '*, coupon_products(product_id), coupon_categories(category_id)')
        .isFilter('store_id', null)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CouponModel.fromJson(json))
        .toList();
  }

  /// إنشاء كوبون جديد
  Future<CouponModel> createCoupon(
    CouponModel coupon, {
    List<String>? productIds,
    List<String>? categoryIds,
  }) async {
    final response = await _client
        .from('coupons')
        .insert(coupon.toInsertJson())
        .select()
        .single();

    final couponId = response['id'] as String;

    // Add product associations if scope is 'products'
    if (productIds != null && productIds.isNotEmpty) {
      try {
        await _client.from('coupon_products').insert(
              productIds
                  .map((pid) => {'coupon_id': couponId, 'product_id': pid})
                  .toList(),
            );
      } catch (e) {
        debugPrint('Error inserting coupon_products: $e');
      }
    }

    // Add category associations if scope is 'categories'
    if (categoryIds != null && categoryIds.isNotEmpty) {
      try {
        await _client.from('coupon_categories').insert(
              categoryIds
                  .map((cid) => {'coupon_id': couponId, 'category_id': cid})
                  .toList(),
            );
      } catch (e) {
        debugPrint('Error inserting coupon_categories: $e');
      }
    }

    return CouponModel.fromJson(response);
  }

  /// تحديث كوبون
  Future<CouponModel> updateCoupon(
    CouponModel coupon, {
    List<String>? productIds,
    List<String>? categoryIds,
  }) async {
    final response = await _client
        .from('coupons')
        .update(coupon.toInsertJson())
        .eq('id', coupon.id)
        .select()
        .single();

    // Update product associations
    await _client.from('coupon_products').delete().eq('coupon_id', coupon.id);
    if (productIds != null && productIds.isNotEmpty) {
      await _client.from('coupon_products').insert(
            productIds
                .map((pid) => {'coupon_id': coupon.id, 'product_id': pid})
                .toList(),
          );
    }

    // Update category associations
    await _client.from('coupon_categories').delete().eq('coupon_id', coupon.id);
    if (categoryIds != null && categoryIds.isNotEmpty) {
      await _client.from('coupon_categories').insert(
            categoryIds
                .map((cid) => {'coupon_id': coupon.id, 'category_id': cid})
                .toList(),
          );
    }

    return CouponModel.fromJson(response);
  }

  /// حذف كوبون
  Future<void> deleteCoupon(String couponId) async {
    await _client.from('coupons').delete().eq('id', couponId);
  }

  /// تفعيل/تعطيل كوبون
  Future<void> toggleCouponStatus(String couponId, bool isActive) async {
    await _client.from('coupons').update({
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String()
    }).eq('id', couponId);
  }
}
