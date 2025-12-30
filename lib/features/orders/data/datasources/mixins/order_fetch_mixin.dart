import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/logger_service.dart';
import '../../models/order_model.dart';
import '../../models/parent_order_model.dart';
import '../helpers/order_mapper.dart';

/// Mixin for fetching orders
mixin OrderFetchMixin {
  SupabaseClient get client;

  /// Order items query with product JOIN for translations
  String get _orderItemsWithProduct =>
      'order_items(*, products(name_ar, name_en, description_ar, description_en, images))';

  OrderMapper get _mapper => OrderMapper(client);

  Future<List<OrderModel>> getOrders(String userId) async {
    logger.i('📦 Getting orders for user: $userId');
    try {
      // Optimized: Single query with store JOIN instead of N+1 queries
      final response = await client
          .from('orders')
          .select(
              '*, $_orderItemsWithProduct, stores:merchant_id(name, phone, address)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      logger.d('✅ Got ${(response as List).length} orders');

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      logger.e('❌ Error getting orders', error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      // Optimized: Include store info in single query
      final response = await client
          .from('orders')
          .select(
              '*, $_orderItemsWithProduct, stores:merchant_id(name, phone, address)')
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
      // Optimized: Include store info in single query
      final response = await client
          .from('orders')
          .select(
              '*, $_orderItemsWithProduct, stores:merchant_id(name, phone, address)')
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
          if (data.isEmpty) return <OrderModel>[];

          // Optimized: Batch fetch all order items in one query
          final orderIds = data.map((o) => o['id'] as String).toList();

          final itemsResponse = await client
              .from('order_items')
              .select(
                  '*, products(name_ar, name_en, description_ar, description_en, images)')
              .inFilter('order_id', orderIds);

          // Group items by order_id for O(1) lookup
          final itemsByOrder = <String, List<Map<String, dynamic>>>{};
          for (final item in itemsResponse) {
            final orderId = item['order_id'] as String;
            itemsByOrder.putIfAbsent(orderId, () => []).add(item);
          }

          return data.map((order) {
            final items = itemsByOrder[order['id']] ?? [];
            return _mapper.mapOrderWithItems(order, items);
          }).toList();
        });
  }

  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          if (data.isEmpty) return <OrderModel>[];

          // Optimized: Batch fetch all data in parallel
          final orderIds = data.map((o) => o['id'] as String).toList();
          final merchantIds = data
              .map((o) => o['merchant_id'] as String?)
              .where((id) => id != null)
              .cast<String>()
              .toSet()
              .toList();

          // Parallel fetch: items and stores
          final futures = await Future.wait([
            client
                .from('order_items')
                .select(
                    '*, products(name_ar, name_en, description_ar, description_en, images)')
                .inFilter('order_id', orderIds),
            if (merchantIds.isNotEmpty)
              client
                  .from('stores')
                  .select('merchant_id, name, phone, address')
                  .inFilter('merchant_id', merchantIds)
            else
              Future.value(<Map<String, dynamic>>[]),
          ]);

          final itemsResponse = futures[0] as List;
          final storesResponse = futures[1] as List;

          // Create lookup maps for O(1) access
          final itemsByOrder = <String, List<Map<String, dynamic>>>{};
          for (final item in itemsResponse) {
            final orderId = item['order_id'] as String;
            itemsByOrder.putIfAbsent(orderId, () => []).add(item);
          }

          final storesByMerchant = <String, Map<String, dynamic>>{};
          for (final store in storesResponse) {
            storesByMerchant[store['merchant_id'] as String] = store;
          }

          return data.map((order) {
            final items = itemsByOrder[order['id']] ?? [];
            final storeInfo = order['merchant_id'] != null
                ? storesByMerchant[order['merchant_id']]
                : null;
            return _mapper.mapOrderWithItems(order, items, storeInfo);
          }).toList();
        });
  }

  /// Get parent order with all sub-orders and their items
  Future<ParentOrderModel> getParentOrderDetails(String parentOrderId) async {
    try {
      final parentResponse = await client
          .from('parent_orders')
          .select()
          .eq('id', parentOrderId)
          .single();

      final ordersResponse = await client
          .from('orders')
          .select('*, $_orderItemsWithProduct, stores(name, phone, address)')
          .eq('parent_order_id', parentOrderId)
          .order('created_at');

      final orders = (ordersResponse as List)
          .map((order) => OrderModel.fromJson(order))
          .toList();

      return _mapper.mapParentOrder(parentResponse, orders);
    } catch (e) {
      throw ServerException('فشل في جلب تفاصيل الطلب المجمع: ${e.toString()}');
    }
  }

  /// Get user's parent orders
  Future<List<ParentOrderModel>> getUserParentOrders(String userId) async {
    try {
      // Single query with all joins including product translations
      final response = await client
          .from('parent_orders')
          .select('''
            *,
            orders(
              *,
              order_items(*, products(name_ar, name_en, description_ar, description_en, images)),
              stores(name, phone, address)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List)
          .map((json) => ParentOrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب الطلبات المجمعة: ${e.toString()}');
    }
  }

  /// Watch user's parent orders - optimized version
  Stream<List<ParentOrderModel>> watchUserParentOrders(String userId) {
    return client
        .from('parent_orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((parentOrdersData) async {
          if (parentOrdersData.isEmpty) return <ParentOrderModel>[];

          final parentOrderIds =
              parentOrdersData.map((p) => p['id'] as String).toList();

          final ordersResponse = await client
              .from('orders')
              .select(
                  '*, $_orderItemsWithProduct, stores(name, phone, address)')
              .inFilter('parent_order_id', parentOrderIds);

          final ordersByParent = _mapper.groupOrdersByParent(ordersResponse);

          return parentOrdersData
              .map((p) =>
                  _mapper.mapParentOrder(p, ordersByParent[p['id']] ?? []))
              .toList();
        });
  }
}
