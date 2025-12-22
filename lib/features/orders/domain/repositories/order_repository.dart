import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../entities/parent_order_entity.dart';

/// Abstract repository interface for orders
abstract class OrderRepository {
  /// Get orders for a user
  Future<Either<Failure, List<OrderEntity>>> getOrders(String userId);

  /// Get all orders (for merchant)
  Future<Either<Failure, List<OrderEntity>>> getAllOrders();

  /// Get order by ID
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId);

  /// Create order from cart
  Future<Either<Failure, String>> createOrderFromCart(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
  });

  /// Create multi-vendor order from cart (splits by merchant)
  Future<Either<Failure, String>> createMultiVendorOrder(
    String userId,
    String? deliveryAddress,
    String? customerName,
    String? customerPhone,
    String? notes, {
    double? shippingCost,
    String? governorateId,
  });

  /// Get parent order details with sub-orders
  Future<Either<Failure, ParentOrderEntity>> getParentOrderDetails(
      String parentOrderId);

  /// Get user's parent orders
  Future<Either<Failure, List<ParentOrderEntity>>> getUserParentOrders(
      String userId);

  /// Watch user's parent orders stream
  Stream<List<ParentOrderEntity>> watchUserParentOrders(String userId);

  /// Update order status
  Future<Either<Failure, void>> updateOrderStatus(
      String orderId, OrderStatus status);

  /// Watch all orders stream (for merchant)
  Stream<List<OrderEntity>> watchOrders();

  /// Watch user orders stream
  Stream<List<OrderEntity>> watchUserOrders(String userId);

  /// Get orders by merchant ID
  Future<Either<Failure, List<OrderEntity>>> getOrdersByMerchant(
      String merchantId);

  /// Watch merchant orders stream (real-time)
  Stream<List<OrderEntity>> watchMerchantOrders(String merchantId);

  /// Watch merchant orders by status (real-time)
  Stream<List<OrderEntity>> watchMerchantOrdersByStatus(
      String merchantId, String status);

  /// Get merchant orders count for today
  Future<Either<Failure, Map<String, int>>> getMerchantOrdersCount(
      String merchantId);

  /// Get merchant orders by status with pagination
  Future<Either<Failure, List<OrderEntity>>> getMerchantOrdersByStatusPaginated(
      String merchantId, String status, int page, int pageSize);

  /// Get merchant statistics
  Future<Either<Failure, Map<String, dynamic>>> getMerchantStatistics(
      String merchantId, DateTime? startDate, DateTime? endDate);
}
