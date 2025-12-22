import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';
import '../models/parent_order_model.dart';

/// Abstract interface for order remote data source
abstract class OrderRemoteDataSource {
  // User orders
  Future<List<OrderModel>> getOrders(String userId);
  Future<List<OrderModel>> getAllOrders();
  Future<OrderModel> getOrderById(String orderId);
  Stream<List<OrderModel>> watchOrders();
  Stream<List<OrderModel>> watchUserOrders(String userId);

  // Create orders
  Future<String> createOrder(OrderModel order, List<OrderItemModel> items);
  Future<String> createOrderFromCart(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
  });

  // Multi-vendor orders
  Future<String> createMultiVendorOrder(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
  });
  Future<ParentOrderModel> getParentOrderDetails(String parentOrderId);
  Future<List<ParentOrderModel>> getUserParentOrders(String userId);
  Stream<List<ParentOrderModel>> watchUserParentOrders(String userId);

  // Update orders
  Future<void> updateOrderStatus(String orderId, OrderStatus status);

  // Merchant orders
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
