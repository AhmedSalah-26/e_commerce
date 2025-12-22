import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../models/order_model.dart';

/// Mixin for creating orders
mixin OrderCreateMixin {
  SupabaseClient get client;

  Future<String> createOrder(
      OrderModel order, List<OrderItemModel> items) async {
    try {
      final orderResponse =
          await client.from('orders').insert(order.toJson()).select().single();

      final orderId = orderResponse['id'] as String;

      for (final item in items) {
        await client.from('order_items').insert({
          ...item.toJson(),
          'order_id': orderId,
        });
      }

      return orderId;
    } catch (e) {
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
      final response = await client.rpc('create_order_from_cart', params: {
        'p_user_id': userId,
        'p_delivery_address': deliveryAddress,
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_notes': notes,
        'p_shipping_cost': shippingCost ?? 0,
        'p_governorate_id': governorateId,
      });

      return response as String;
    } catch (e) {
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
  }) async {
    try {
      final response = await client.rpc('create_multi_vendor_order', params: {
        'p_user_id': userId,
        'p_delivery_address': deliveryAddress,
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_notes': notes,
        'p_shipping_cost': shippingCost ?? 0,
        'p_governorate_id': governorateId,
      });

      return response as String;
    } catch (e) {
      throw ServerException('فشل في إنشاء الطلب المجمع: ${e.toString()}');
    }
  }
}
