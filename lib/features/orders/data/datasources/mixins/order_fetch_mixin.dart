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
      final response = await client
          .from('orders')
          .select('*, $_orderItemsWithProduct')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      logger.d('✅ Got ${(response as List).length} orders');

      return await _mapOrdersWithStoreInfo(response);
    } catch (e, stackTrace) {
      logger.e('❌ Error getting orders', error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  Future<List<OrderModel>> _mapOrdersWithStoreInfo(
      List<dynamic> response) async {
    final orders = <OrderModel>[];
    for (final order in response) {
      final storeInfo =
          await _mapper.fetchStoreInfo(order['merchant_id'] as String?);
      orders.add(_mapper.mapOrderWithStore(order, storeInfo));
    }
    return orders;
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await client
          .from('orders')
          .select('*, $_orderItemsWithProduct')
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
          .select('*, $_orderItemsWithProduct')
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
            final items = await _mapper.fetchOrderItems(order['id'] as String);
            orders.add(_mapper.mapOrderWithItems(order, items));
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
            final items = await _mapper.fetchOrderItems(order['id'] as String);
            final storeInfo =
                await _mapper.fetchStoreInfo(order['merchant_id'] as String?);
            orders.add(_mapper.mapOrderWithItems(order, items, storeInfo));
          }
          return orders;
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
