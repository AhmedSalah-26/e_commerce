import 'package:get_it/get_it.dart';

// Injection modules
import 'injections/core_injection.dart';
import 'injections/auth_injection.dart';
import 'injections/products_injection.dart';
import 'injections/categories_injection.dart';
import 'injections/cart_injection.dart';
import 'injections/orders_injection.dart';
import 'injections/favorites_injection.dart';
import 'injections/notifications_injection.dart';
import 'injections/reviews_injection.dart';
import 'injections/shipping_injection.dart';
import 'injections/coupons_injection.dart';
import 'injections/admin_injection.dart';
import 'injections/product_reports_injection.dart';
import 'injections/review_reports_injection.dart';
import 'injections/merchant_injection.dart';
import 'injections/banners_injection.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core Services (must be first)
  await registerCoreDependencies(sl);

  // Feature Dependencies
  registerAuthDependencies(sl);
  registerProductsDependencies(sl);
  registerCategoriesDependencies(sl);
  registerCartDependencies(sl);
  registerOrdersDependencies(sl);
  registerFavoritesDependencies(sl);
  registerNotificationsDependencies(sl);
  registerReviewsDependencies(sl);
  registerShippingDependencies(sl);
  registerCouponsDependencies(sl);
  registerAdminDependencies(sl);
  registerProductReportsDependencies(sl);
  registerReviewReportsDependencies(sl);
  registerMerchantDependencies(sl);
  registerBannersDependencies(sl);
}
