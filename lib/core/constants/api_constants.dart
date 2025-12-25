/// API-related constants
class ApiConstants {
  ApiConstants._();

  // Table Names
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String parentOrdersTable = 'parent_orders';
  static const String cartTable = 'cart_items';
  static const String favoritesTable = 'favorites';
  static const String reviewsTable = 'reviews';
  static const String usersTable = 'users';
  static const String couponsTable = 'coupons';
  static const String shippingTable = 'shipping_prices';

  // Storage Buckets
  static const String productImagesBucket = 'product-images';
  static const String categoryImagesBucket = 'category-images';
  static const String userAvatarsBucket = 'user-avatars';

  // RPC Functions
  static const String createMultiVendorOrder = 'create_multi_vendor_order';
  static const String validateCoupon = 'validate_coupon';
  static const String applyCoupon = 'apply_coupon';
}
