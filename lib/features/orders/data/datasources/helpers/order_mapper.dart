import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/order_model.dart';
import '../../models/parent_order_model.dart';

/// Helper class for mapping order data - reduces complexity in mixins
class OrderMapper {
  final SupabaseClient client;

  const OrderMapper(this.client);

  /// Fetch store info for a merchant
  Future<Map<String, dynamic>?> fetchStoreInfo(String? merchantId) async {
    if (merchantId == null) return null;

    try {
      return await client
          .from('stores')
          .select('name, phone')
          .eq('merchant_id', merchantId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  /// Fetch order items with product translations
  Future<List<dynamic>> fetchOrderItems(String orderId) async {
    return await client
        .from('order_items')
        .select(
            '*, products(name_ar, name_en, description_ar, description_en, images)')
        .eq('order_id', orderId);
  }

  /// Map order JSON to OrderModel with store info
  OrderModel mapOrderWithStore(
    Map<String, dynamic> order,
    Map<String, dynamic>? storeInfo,
  ) {
    return OrderModel.fromJson({
      ...order,
      if (storeInfo != null) 'stores': storeInfo,
    });
  }

  /// Map order JSON with items to OrderModel
  OrderModel mapOrderWithItems(
    Map<String, dynamic> order,
    List<dynamic> items, [
    Map<String, dynamic>? storeInfo,
  ]) {
    return OrderModel.fromJson({
      ...order,
      'order_items': items,
      if (storeInfo != null) 'stores': storeInfo,
    });
  }

  /// Map parent order data to ParentOrderModel
  ParentOrderModel mapParentOrder(
    Map<String, dynamic> parentOrder,
    List<OrderModel> subOrders,
  ) {
    return ParentOrderModel(
      id: parentOrder['id'] as String,
      userId: parentOrder['user_id'] as String,
      total: (parentOrder['total'] as num).toDouble(),
      subtotal: (parentOrder['subtotal'] as num).toDouble(),
      shippingCost: (parentOrder['shipping_cost'] as num?)?.toDouble() ?? 0,
      deliveryAddress: parentOrder['delivery_address'] as String?,
      customerName: parentOrder['customer_name'] as String?,
      customerPhone: parentOrder['customer_phone'] as String?,
      notes: parentOrder['notes'] as String?,
      governorateId: parentOrder['governorate_id'] as String?,
      createdAt: parentOrder['created_at'] != null
          ? DateTime.parse(parentOrder['created_at'] as String)
          : null,
      subOrders: subOrders,
      paymentMethod:
          parentOrder['payment_method'] as String? ?? 'cash_on_delivery',
      couponId: parentOrder['coupon_id'] as String?,
      couponCode: parentOrder['coupon_code'] as String?,
      couponDiscount: (parentOrder['coupon_discount'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Group orders by parent order ID
  Map<String, List<OrderModel>> groupOrdersByParent(List<dynamic> ordersData) {
    final Map<String, List<OrderModel>> ordersByParent = {};

    for (final order in ordersData) {
      final parentId = order['parent_order_id'] as String?;
      if (parentId != null) {
        ordersByParent.putIfAbsent(parentId, () => []);
        ordersByParent[parentId]!.add(OrderModel.fromJson(order));
      }
    }

    return ordersByParent;
  }
}
