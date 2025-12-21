import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

/// Abstract interface for order remote data source
abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel> getOrderById(String orderId);
  Future<String> createOrder(OrderModel order, List<OrderItemModel> items);
  Future<String> createOrderFromCart(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
  );
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Stream<List<OrderModel>> watchOrders();
  Stream<List<OrderModel>> watchUserOrders(String userId);
  Future<List<OrderModel>> getOrdersByMerchant(String merchantId);
  Stream<List<OrderModel>> watchMerchantOrders(String merchantId);
  Stream<List<OrderModel>> watchMerchantOrdersByStatus(
      String merchantId, String status);
  Future<Map<String, int>> getMerchantOrdersCount(String merchantId);
  Future<List<OrderModel>> getMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize);
  Future<Map<String, dynamic>> getMerchantStatistics(
      String merchantId, DateTime? startDate, DateTime? endDate);
}

/// Implementation of order remote data source using Supabase
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient _client;

  OrderRemoteDataSourceImpl(this._client);

  @override
  Future<List<OrderModel>> getOrders(String userId) async {
    logger.i('📦 Getting orders for user: $userId');
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      logger.d('✅ Got ${(response as List).length} orders');
      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      logger.e('❌ Error getting orders', error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _client
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

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw ServerException('فشل في جلب الطلب: ${e.toString()}');
    }
  }

  @override
  Future<String> createOrder(
      OrderModel order, List<OrderItemModel> items) async {
    try {
      // Create order
      final orderResponse =
          await _client.from('orders').insert(order.toJson()).select().single();

      final orderId = orderResponse['id'] as String;

      // Create order items
      for (final item in items) {
        await _client.from('order_items').insert({
          ...item.toJson(),
          'order_id': orderId,
        });
      }

      return orderId;
    } catch (e) {
      throw ServerException('فشل في إنشاء الطلب: ${e.toString()}');
    }
  }

  @override
  Future<String> createOrderFromCart(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes,
  ) async {
    try {
      final response = await _client.rpc('create_order_from_cart', params: {
        'p_user_id': userId,
        'p_delivery_address': deliveryAddress,
        'p_customer_name': customerName,
        'p_customer_phone': customerPhone,
        'p_notes': notes,
      });

      return response as String;
    } catch (e) {
      throw ServerException('فشل في إنشاء الطلب من السلة: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _client
          .from('orders')
          .update({'status': status.name}).eq('id', orderId);
    } catch (e) {
      throw ServerException('فشل في تحديث حالة الطلب: ${e.toString()}');
    }
  }

  @override
  Stream<List<OrderModel>> watchOrders() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final orders = <OrderModel>[];
          for (final order in data) {
            final itemsResponse = await _client
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

  @override
  Stream<List<OrderModel>> watchUserOrders(String userId) {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final orders = <OrderModel>[];
          for (final order in data) {
            final itemsResponse = await _client
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

  @override
  Future<List<OrderModel>> getOrdersByMerchant(String merchantId) async {
    try {
      logger.i('📦 Getting orders for merchant: $merchantId');

      // Get orders for this merchant
      final ordersResponse = await _client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false);

      logger.d('Found ${(ordersResponse as List).length} orders');

      final orders = <OrderModel>[];

      for (final order in ordersResponse) {
        // Get order items for each order
        final itemsResponse = await _client
            .from('order_items')
            .select()
            .eq('order_id', order['id']);

        logger.d(
            'Order ${order['id']} has ${(itemsResponse as List).length} items');

        orders.add(OrderModel.fromJson({
          ...order,
          'order_items': itemsResponse,
        }));
      }

      logger.i('✅ Loaded ${orders.length} merchant orders');
      return orders;
    } catch (e, stackTrace) {
      logger.e('❌ Error getting merchant orders',
          error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب طلبات التاجر: ${e.toString()}');
    }
  }

  @override
  Stream<List<OrderModel>> watchMerchantOrders(String merchantId) {
    logger.i('👀 Watching orders for merchant: $merchantId');
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          logger.d('📦 Real-time update: ${data.length} orders');
          final orders = <OrderModel>[];
          for (final order in data) {
            final itemsResponse = await _client
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

  @override
  Stream<List<OrderModel>> watchMerchantOrdersByStatus(
      String merchantId, String status) {
    logger.i('👀 Watching $status orders for merchant: $merchantId');
    // Supabase stream only supports one eq filter, so we filter locally
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          // Filter by status locally
          final filteredData =
              data.where((order) => order['status'] == status).toList();
          logger
              .d('📦 Real-time update: ${filteredData.length} $status orders');
          final orders = <OrderModel>[];
          for (final order in filteredData) {
            final itemsResponse = await _client
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

  @override
  Future<Map<String, int>> getMerchantOrdersCount(String merchantId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Get today's counts
      final todayPendingResponse = await _client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .eq('status', 'pending')
          .gte('created_at', startOfDay.toIso8601String());

      final todayDeliveredResponse = await _client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .eq('status', 'delivered')
          .gte('created_at', startOfDay.toIso8601String());

      return {
        'todayPending': (todayPendingResponse as List).length,
        'todayDelivered': (todayDeliveredResponse as List).length,
      };
    } catch (e) {
      logger.e('❌ Error getting order counts', error: e);
      return {'todayPending': 0, 'todayDelivered': 0};
    }
  }

  @override
  Future<List<OrderModel>> getMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      logger
          .i('📦 Getting $status orders page $page for merchant: $merchantId');

      final ordersResponse = await _client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .eq('status', status)
          .order('created_at', ascending: false)
          .range(from, to);

      final orders = <OrderModel>[];
      for (final order in (ordersResponse as List)) {
        final itemsResponse = await _client
            .from('order_items')
            .select()
            .eq('order_id', order['id']);

        orders.add(OrderModel.fromJson({
          ...order,
          'order_items': itemsResponse,
        }));
      }

      logger.d('✅ Loaded ${orders.length} orders for page $page');
      return orders;
    } catch (e, stackTrace) {
      logger.e('❌ Error getting paginated orders',
          error: e, stackTrace: stackTrace);
      throw ServerException('فشل في جلب الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, dynamic>> getMerchantStatistics(
      String merchantId, DateTime? startDate, DateTime? endDate) async {
    try {
      logger.i('📊 Getting statistics for merchant: $merchantId');

      var query = _client.from('orders').select().eq('merchant_id', merchantId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at',
            endDate.add(const Duration(days: 1)).toIso8601String());
      }

      final ordersResponse = await query;
      final orders = ordersResponse as List;

      // Calculate statistics
      int pending = 0,
          processing = 0,
          shipped = 0,
          delivered = 0,
          cancelled = 0;
      double totalRevenue = 0;

      for (final order in orders) {
        switch (order['status']) {
          case 'pending':
            pending++;
            break;
          case 'processing':
            processing++;
            break;
          case 'shipped':
            shipped++;
            break;
          case 'delivered':
            delivered++;
            totalRevenue += (order['total'] as num).toDouble();
            break;
          case 'cancelled':
            cancelled++;
            break;
        }
      }

      return {
        'total': orders.length,
        'pending': pending,
        'processing': processing,
        'shipped': shipped,
        'delivered': delivered,
        'cancelled': cancelled,
        'revenue': totalRevenue,
      };
    } catch (e, stackTrace) {
      logger.e('❌ Error getting statistics', error: e, stackTrace: stackTrace);
      return {
        'total': 0,
        'pending': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
        'revenue': 0.0,
      };
    }
  }
}
