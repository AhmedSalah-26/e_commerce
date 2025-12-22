import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/logger_service.dart';
import '../../models/order_model.dart';
import '../../models/parent_order_model.dart';

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

  /// Get parent order with all sub-orders and their items
  Future<ParentOrderModel> getParentOrderDetails(String parentOrderId) async {
    try {
      // Get parent order
      final parentResponse = await client
          .from('parent_orders')
          .select()
          .eq('id', parentOrderId)
          .single();

      // Get sub-orders with items
      final ordersResponse = await client
          .from('orders')
          .select('*, order_items(*)')
          .eq('parent_order_id', parentOrderId)
          .order('created_at');

      // Fetch store info for each order
      final orders = <OrderModel>[];
      for (final order in ordersResponse) {
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

      return ParentOrderModel(
        id: parentResponse['id'] as String,
        userId: parentResponse['user_id'] as String,
        total: (parentResponse['total'] as num).toDouble(),
        subtotal: (parentResponse['subtotal'] as num).toDouble(),
        shippingCost:
            (parentResponse['shipping_cost'] as num?)?.toDouble() ?? 0,
        deliveryAddress: parentResponse['delivery_address'] as String?,
        customerName: parentResponse['customer_name'] as String?,
        customerPhone: parentResponse['customer_phone'] as String?,
        notes: parentResponse['notes'] as String?,
        governorateId: parentResponse['governorate_id'] as String?,
        createdAt: parentResponse['created_at'] != null
            ? DateTime.parse(parentResponse['created_at'] as String)
            : null,
        subOrders: orders,
      );
    } catch (e) {
      throw ServerException('فشل في جلب تفاصيل الطلب المجمع: ${e.toString()}');
    }
  }

  /// Get user's parent orders
  Future<List<ParentOrderModel>> getUserParentOrders(String userId) async {
    try {
      final response = await client
          .from('parent_orders')
          .select(
              '*, orders(*, order_items(*), stores:merchant_id(name, phone, address))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ParentOrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب الطلبات المجمعة: ${e.toString()}');
    }
  }

  /// Watch user's parent orders - listens to orders table for status changes
  Stream<List<ParentOrderModel>> watchUserParentOrders(String userId) {
    // Listen to orders table to catch status changes
    return client
        .from('orders')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .asyncMap((ordersData) async {
          // Group orders by parent_order_id
          final Map<String, List<Map<String, dynamic>>> ordersByParent = {};
          final Set<String> parentOrderIds = {};

          for (final order in ordersData) {
            final parentId = order['parent_order_id'] as String?;
            if (parentId != null) {
              parentOrderIds.add(parentId);
              if (!ordersByParent.containsKey(parentId)) {
                ordersByParent[parentId] = [];
              }
              ordersByParent[parentId]!.add(order);
            }
          }

          if (parentOrderIds.isEmpty) {
            return <ParentOrderModel>[];
          }

          // Fetch parent orders data
          final parentOrdersResponse = await client
              .from('parent_orders')
              .select()
              .inFilter('id', parentOrderIds.toList())
              .order('created_at', ascending: false);

          final parentOrders = <ParentOrderModel>[];
          for (final parentOrder in parentOrdersResponse) {
            final parentId = parentOrder['id'] as String;
            final subOrdersData = ordersByParent[parentId] ?? [];

            // Fetch order items and store info for each sub-order
            final orders = <OrderModel>[];
            for (final order in subOrdersData) {
              // Fetch order items
              final itemsResponse = await client
                  .from('order_items')
                  .select()
                  .eq('order_id', order['id']);

              // Fetch store info
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

            parentOrders.add(ParentOrderModel(
              id: parentId,
              userId: parentOrder['user_id'] as String,
              total: (parentOrder['total'] as num).toDouble(),
              subtotal: (parentOrder['subtotal'] as num).toDouble(),
              shippingCost:
                  (parentOrder['shipping_cost'] as num?)?.toDouble() ?? 0,
              deliveryAddress: parentOrder['delivery_address'] as String?,
              customerName: parentOrder['customer_name'] as String?,
              customerPhone: parentOrder['customer_phone'] as String?,
              notes: parentOrder['notes'] as String?,
              governorateId: parentOrder['governorate_id'] as String?,
              createdAt: parentOrder['created_at'] != null
                  ? DateTime.parse(parentOrder['created_at'] as String)
                  : null,
              subOrders: orders,
            ));
          }

          return parentOrders;
        });
  }
}
