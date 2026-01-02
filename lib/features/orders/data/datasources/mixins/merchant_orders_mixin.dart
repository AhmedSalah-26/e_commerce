import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/logger_service.dart';
import '../../models/order_model.dart';

/// Mixin for merchant order operations
mixin MerchantOrdersMixin {
  SupabaseClient get client;

  /// Order items query with product JOIN for translations
  String get _orderItemsWithProduct =>
      '*, products(name_ar, name_en, description_ar, description_en, images)';

  Future<List<OrderModel>> getOrdersByMerchant(String merchantId) async {
    try {
      logger.i('📦 Getting filtered orders for merchant: $merchantId');

      // Use database function for filtered query - only returns valid payment orders
      final ordersResponse = await client.rpc(
        'get_merchant_orders_filtered',
        params: {
          'p_merchant_id': merchantId,
          'p_limit': 100,
          'p_offset': 0,
        },
      );

      logger.d('Found ${(ordersResponse as List).length} filtered orders');

      final orders = <OrderModel>[];

      for (final order in ordersResponse) {
        final itemsResponse = await client
            .from('order_items')
            .select(_orderItemsWithProduct)
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

  Stream<List<OrderModel>> watchMerchantOrders(String merchantId) {
    logger.i('👀 Watching filtered orders for merchant: $merchantId');

    // Filter directly in database: cash_on_delivery OR (card AND paid)
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          // Filter: only show cash_on_delivery or paid card payments
          final filteredData = data.where((order) {
            final paymentMethod = order['payment_method'] as String?;
            final paymentStatus = order['payment_status'] as String?;

            // Cash on delivery - always show
            if (paymentMethod == null ||
                paymentMethod == 'cash_on_delivery' ||
                paymentMethod == 'pending') {
              return true;
            }

            // Card payment - only show if paid
            if (paymentMethod == 'card') {
              return paymentStatus == 'paid';
            }

            return true;
          }).toList();

          logger.d(
              '📦 Real-time update: ${filteredData.length}/${data.length} orders after filter');

          final orders = <OrderModel>[];
          for (final order in filteredData) {
            final itemsResponse = await client
                .from('order_items')
                .select(_orderItemsWithProduct)
                .eq('order_id', order['id']);

            orders.add(OrderModel.fromJson({
              ...order,
              'order_items': itemsResponse,
            }));
          }
          return orders;
        });
  }

  Stream<List<OrderModel>> watchMerchantOrdersByStatus(
      String merchantId, String status) {
    logger.i('👀 Watching $status orders for merchant: $merchantId');
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          // Filter by status AND payment validity
          final filteredData = data.where((order) {
            // First check status
            if (order['status'] != status) return false;

            // Then check payment
            final paymentMethod = order['payment_method'] as String?;
            final paymentStatus = order['payment_status'] as String?;

            // Cash on delivery - always show
            if (paymentMethod == null ||
                paymentMethod == 'cash_on_delivery' ||
                paymentMethod == 'pending') {
              return true;
            }

            // Card payment - only show if paid
            if (paymentMethod == 'card') {
              return paymentStatus == 'paid';
            }

            return true;
          }).toList();

          logger.d(
              '📦 Real-time update: ${filteredData.length} $status orders after filter');

          final orders = <OrderModel>[];
          for (final order in filteredData) {
            final itemsResponse = await client
                .from('order_items')
                .select(_orderItemsWithProduct)
                .eq('order_id', order['id']);

            orders.add(OrderModel.fromJson({
              ...order,
              'order_items': itemsResponse,
            }));
          }
          return orders;
        });
  }

  Future<Map<String, int>> getMerchantOrdersCount(String merchantId) async {
    try {
      // Use database function for filtered count
      final response = await client.rpc(
        'get_merchant_orders_count_filtered',
        params: {'p_merchant_id': merchantId},
      );

      if (response != null && (response as List).isNotEmpty) {
        final data = response[0];
        return {
          'todayPending': (data['total_pending'] as num?)?.toInt() ?? 0,
          'todayDelivered': (data['today_delivered'] as num?)?.toInt() ?? 0,
        };
      }

      return {'todayPending': 0, 'todayDelivered': 0};
    } catch (e) {
      logger.e('❌ Error getting order counts', error: e);
      return {'todayPending': 0, 'todayDelivered': 0};
    }
  }

  Future<List<OrderModel>> getMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize) async {
    try {
      final offset = page * pageSize;

      logger
          .i('📦 Getting $status orders page $page for merchant: $merchantId');

      // Use database function for filtered query
      final ordersResponse = await client.rpc(
        'get_merchant_orders_filtered',
        params: {
          'p_merchant_id': merchantId,
          'p_status': status,
          'p_limit': pageSize,
          'p_offset': offset,
        },
      );

      final orders = <OrderModel>[];
      for (final order in (ordersResponse as List)) {
        final itemsResponse = await client
            .from('order_items')
            .select(_orderItemsWithProduct)
            .eq('order_id', order['id']);

        orders.add(OrderModel.fromJson({
          ...order,
          'order_items': itemsResponse,
          'governorates': order['governorate_id'] != null
              ? {
                  'id': order['governorate_id'],
                  'name_ar': order['governorate_name_ar'],
                  'name_en': order['governorate_name_en'],
                }
              : null,
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

  Future<Map<String, dynamic>> getMerchantStatistics(
      String merchantId, DateTime? startDate, DateTime? endDate) async {
    try {
      logger.i('📊 Getting statistics for merchant: $merchantId');

      var query = client.from('orders').select().eq('merchant_id', merchantId);

      // Use updated_at for filtering (when order status was last changed)
      if (startDate != null) {
        query = query.gte('updated_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('updated_at',
            endDate.add(const Duration(days: 1)).toIso8601String());
      }

      final ordersResponse = await query;
      final orders = ordersResponse as List;

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
