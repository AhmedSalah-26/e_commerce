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

  /// Orders query with governorate JOIN
  String get _ordersWithGovernorate =>
      '*, governorates:governorate_id(id, name_ar, name_en)';

  /// Fetch parent order data for coupon/payment info
  Future<Map<String, dynamic>?> _fetchParentOrderData(
      String? parentOrderId) async {
    if (parentOrderId == null) {
      logger.d('No parent_order_id provided');
      return null;
    }
    try {
      logger.d('Fetching parent order data for: $parentOrderId');
      final response = await client
          .from('parent_orders')
          .select('payment_method, coupon_code, coupon_discount, subtotal')
          .eq('id', parentOrderId)
          .maybeSingle();
      logger.d('Parent order data: $response');
      return response;
    } catch (e) {
      logger.w('Could not fetch parent order data: $e');
      return null;
    }
  }

  /// Calculate merchant's share of coupon discount
  Map<String, dynamic> _calculateMerchantDiscount(
    Map<String, dynamic> order,
    Map<String, dynamic>? parentOrder,
  ) {
    if (parentOrder == null) {
      return {
        'payment_method': order['payment_method'],
        'coupon_code': null,
        'coupon_discount': 0.0,
      };
    }

    final paymentMethod = parentOrder['payment_method'] as String?;
    final couponCode = parentOrder['coupon_code'] as String?;
    final totalCouponDiscount =
        (parentOrder['coupon_discount'] as num?)?.toDouble() ?? 0.0;
    final parentSubtotal = (parentOrder['subtotal'] as num?)?.toDouble() ?? 0.0;
    final merchantSubtotal = (order['subtotal'] as num?)?.toDouble() ?? 0.0;

    // Calculate merchant's proportional share of discount
    double merchantDiscount = 0.0;
    if (totalCouponDiscount > 0 && parentSubtotal > 0) {
      merchantDiscount =
          (merchantSubtotal / parentSubtotal) * totalCouponDiscount;
    }

    return {
      'payment_method': paymentMethod,
      'coupon_code': couponCode,
      'coupon_discount': merchantDiscount,
    };
  }

  Future<List<OrderModel>> getOrdersByMerchant(String merchantId) async {
    try {
      logger.i('📦 Getting orders for merchant: $merchantId');

      final ordersResponse = await client
          .from('orders')
          .select(_ordersWithGovernorate)
          .eq('merchant_id', merchantId)
          .order('created_at', ascending: false);

      logger.d('Found ${(ordersResponse as List).length} orders');

      final orders = <OrderModel>[];

      for (final order in ordersResponse) {
        final itemsResponse = await client
            .from('order_items')
            .select(_orderItemsWithProduct)
            .eq('order_id', order['id']);

        // Fetch parent order data for payment/coupon info
        final parentOrderData =
            await _fetchParentOrderData(order['parent_order_id'] as String?);
        final discountInfo = _calculateMerchantDiscount(order, parentOrderData);

        logger.d(
            'Order ${order['id']} has ${(itemsResponse as List).length} items');

        orders.add(OrderModel.fromJson({
          ...order,
          'order_items': itemsResponse,
          ...discountInfo,
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
    logger.i('👀 Watching orders for merchant: $merchantId');
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('merchant_id', merchantId)
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          logger.d('📦 Real-time update: ${data.length} orders');
          final orders = <OrderModel>[];
          for (final order in data) {
            final itemsResponse = await client
                .from('order_items')
                .select(_orderItemsWithProduct)
                .eq('order_id', order['id']);

            // Fetch parent order data for payment/coupon info
            final parentOrderData = await _fetchParentOrderData(
                order['parent_order_id'] as String?);
            final discountInfo =
                _calculateMerchantDiscount(order, parentOrderData);

            orders.add(OrderModel.fromJson({
              ...order,
              'order_items': itemsResponse,
              ...discountInfo,
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
          final filteredData =
              data.where((order) => order['status'] == status).toList();
          logger
              .d('📦 Real-time update: ${filteredData.length} $status orders');
          final orders = <OrderModel>[];
          for (final order in filteredData) {
            final itemsResponse = await client
                .from('order_items')
                .select(_orderItemsWithProduct)
                .eq('order_id', order['id']);

            // Fetch parent order data for payment/coupon info
            final parentOrderData = await _fetchParentOrderData(
                order['parent_order_id'] as String?);
            final discountInfo =
                _calculateMerchantDiscount(order, parentOrderData);

            orders.add(OrderModel.fromJson({
              ...order,
              'order_items': itemsResponse,
              ...discountInfo,
            }));
          }
          return orders;
        });
  }

  Future<Map<String, int>> getMerchantOrdersCount(String merchantId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final allPendingResponse = await client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .eq('status', 'pending');

      // Use updated_at for delivered orders (when status changed to delivered)
      final todayDeliveredResponse = await client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .eq('status', 'delivered')
          .gte('updated_at', startOfDay.toIso8601String());

      return {
        'todayPending': (allPendingResponse as List).length,
        'todayDelivered': (todayDeliveredResponse as List).length,
      };
    } catch (e) {
      logger.e('❌ Error getting order counts', error: e);
      return {'todayPending': 0, 'todayDelivered': 0};
    }
  }

  Future<List<OrderModel>> getMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      logger
          .i('📦 Getting $status orders page $page for merchant: $merchantId');

      final ordersResponse = await client
          .from('orders')
          .select()
          .eq('merchant_id', merchantId)
          .eq('status', status)
          .order('created_at', ascending: false)
          .range(from, to);

      final orders = <OrderModel>[];
      for (final order in (ordersResponse as List)) {
        final itemsResponse = await client
            .from('order_items')
            .select(_orderItemsWithProduct)
            .eq('order_id', order['id']);

        // Fetch parent order data for payment/coupon info
        final parentOrderData =
            await _fetchParentOrderData(order['parent_order_id'] as String?);
        final discountInfo = _calculateMerchantDiscount(order, parentOrderData);

        orders.add(OrderModel.fromJson({
          ...order,
          'order_items': itemsResponse,
          ...discountInfo,
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
