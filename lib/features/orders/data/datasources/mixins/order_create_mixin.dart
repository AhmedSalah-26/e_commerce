import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/app_logger.dart';
import '../../models/order_model.dart';

/// Mixin for creating orders
mixin OrderCreateMixin {
  SupabaseClient get client;

  Future<String> createOrder(
      OrderModel order, List<OrderItemModel> items) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('🛒 CREATE ORDER - Direct Insert');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Order Data:', order.toJson());
      AppLogger.d('Items Count:', items.length);

      final orderResponse =
          await client.from('orders').insert(order.toJson()).select().single();

      final orderId = orderResponse['id'] as String;
      AppLogger.step(1, 'Order created', {'orderId': orderId});

      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        await client.from('order_items').insert({
          ...item.toJson(),
          'order_id': orderId,
        });
        AppLogger.d('Item ${i + 1}/${items.length} inserted');
      }

      AppLogger.success('ORDER CREATED SUCCESSFULLY!', {'orderId': orderId});
      AppLogger.i('═══════════════════════════════════════');
      return orderId;
    } catch (e, stackTrace) {
      AppLogger.e('❌ CREATE ORDER FAILED!', e, stackTrace);
      throw ServerException('فشل في إنشاء الطلب: ${e.toString()}');
    }
  }

  Future<String> createOrderFromCart(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
  }) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('🛒 CREATE ORDER FROM CART');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Request Params:', {
        'userId': userId,
        'deliveryAddress': deliveryAddress,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
        'shippingCost': shippingCost,
        'governorateId': governorateId,
      });

      final response = await client.rpc('create_order_from_cart', params: {
        'p_user_id': userId,
        'p_delivery_address': deliveryAddress,
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_notes': notes,
        'p_shipping_cost': shippingCost ?? 0,
        'p_governorate_id': governorateId,
      });

      final orderId = response as String;
      AppLogger.success('ORDER FROM CART CREATED!', {'orderId': orderId});
      AppLogger.i('═══════════════════════════════════════');
      return orderId;
    } catch (e, stackTrace) {
      AppLogger.e('❌ CREATE ORDER FROM CART FAILED!', e, stackTrace);
      throw ServerException('فشل في إنشاء الطلب من السلة: ${e.toString()}');
    }
  }

  /// Create multi-vendor order (splits cart by merchant)
  Future<String> createMultiVendorOrder(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
    String? paymentMethod,
    String? couponId,
    String? couponCode,
    double? couponDiscount,
  }) async {
    try {
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.i('🛒 CREATE MULTI-VENDOR ORDER');
      AppLogger.i('═══════════════════════════════════════');
      AppLogger.d('Request Params:', {
        'userId': userId,
        'deliveryAddress': deliveryAddress,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'notes': notes,
        'shippingCost': shippingCost,
        'governorateId': governorateId,
        'paymentMethod': paymentMethod,
        'couponId': couponId,
        'couponCode': couponCode,
        'couponDiscount': couponDiscount,
      });

      AppLogger.step(1, 'Calling RPC: create_multi_vendor_order');

      final response = await client.rpc('create_multi_vendor_order', params: {
        'p_user_id': userId,
        'p_delivery_address': deliveryAddress,
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_notes': notes,
        'p_shipping_cost': shippingCost ?? 0,
        'p_governorate_id': governorateId,
        'p_payment_method': paymentMethod ?? 'cash_on_delivery',
        'p_coupon_id': couponId,
        'p_coupon_code': couponCode,
        'p_coupon_discount': couponDiscount ?? 0,
      });

      final parentOrderId = response as String;
      AppLogger.success('MULTI-VENDOR ORDER CREATED!', {
        'parentOrderId': parentOrderId,
        'hasCoupon': couponId != null,
        'couponDiscount': couponDiscount,
      });
      AppLogger.i('═══════════════════════════════════════');
      return parentOrderId;
    } catch (e, stackTrace) {
      AppLogger.e('❌ CREATE MULTI-VENDOR ORDER FAILED!', e, stackTrace);
      throw ServerException('فشل في إنشاء الطلب المجمع: ${e.toString()}');
    }
  }
}
