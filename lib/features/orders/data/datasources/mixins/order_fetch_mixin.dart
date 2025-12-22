import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/logger_service.dart';
import '../../models/order_model.dart';

/// Mixin for fetching orders
mixin OrderFetchMixin {
  SupabaseClient get client;

  Future<List<OrderModel>> getOrders(String userId) async {
    logger.i('📦 Getting orders for user: $userId');
    try {
      final response = await client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      logger.d('✅ Got ${(response as List).length} orders');

      final orders = <OrderModel>[];
      for (final order in response) {
        Map<String, dynamic>? storeInfo;
        if (order['merchant_id'] != null) {
          try {
            final storeResponse = await client
                .from('stores')
                .select('name, phone, address')
                .eq('merchant_id', order['merchant_id'])
                .maybeSingle();
            storeInfo = storeResponse;
          } catch (_) {}
        }
        orders.add(OrderModel.fromJson({
          ...order,
          if (storeInfo != null) 'stores': storeInfo,
        }));
      }
      return orders;
    } catch (e, stackTrace) {
      logger.e('❌ Error getting orders', error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await client
          .from('orders')
          .select('*, order_items(*)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب جميع الطلبات: ${e.toString()}');
    }
  }

  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw ServerException('فشل في جلب الطلب: ${e.toString()}');
    }
  }

  Stream<List<OrderModel>> watchOrders() {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final orders = <OrderModel>[];
          for (final order in data) {
            final itemsResponse = await client
                .from('order_items')
                .select()
                .eq('order_id', order['id']);

            orders.add(OrderModel.fromJson({
              ...order,
              'order_items': itemsResponse,
            }));
          }
          return orders;
        });
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final orders = <OrderModel>[];
          for (final order in data) {
            final itemsResponse = await client
                .from('order_items')
                .select()
                .eq('order_id', order['id']);

            Map<String, dynamic>? storeInfo;
            if (order['merchant_id'] != null) {
              try {
                final storeResponse = await client
                    .from('stores')
                    .select('name, phone, address')
                    .eq('merchant_id', order['merchant_id'])
                    .maybeSingle();
                storeInfo = storeResponse;
              } catch (_) {}
            }

            orders.add(OrderModel.fromJson({
              ...order,
              'order_items': itemsResponse,
              if (storeInfo != null) 'stores': storeInfo,
            }));
          }
          return orders;
        });
  }
}
