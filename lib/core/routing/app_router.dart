import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection_container.dart';
import '../../features/about/presentation/pages/about_screen.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_merchant_coupons_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/cart/presentation/pages/cart_screen.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/coupons/presentation/pages/merchant_coupons_page.dart';
import '../../features/coupons/presentation/pages/global_coupons_page.dart';
import '../../features/merchant/presentation/pages/merchant_categories_tab.dart';
import '../../features/merchant/presentation/pages/merchant_top_rated_products_page.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../features/help/presentation/pages/help_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/pages/search_screen.dart';
import '../../features/merchant/presentation/pages/merchant_dashboard_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_screen.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/shipping/presentation/cubit/shipping_cubit.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/parent_order_details_page.dart';
import '../../features/products/domain/entities/product_entity.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/products/presentation/pages/product_screen.dart';
import '../../features/products/presentation/pages/store_products_screen.dart';
import '../../features/settings/presentation/pages/edit_profile_screen.dart';
import '../../features/settings/presentation/pages/language_settings_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/settings/presentation/pages/theme_settings_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/product_reports/presentation/pages/my_reports_page.dart';
import '../../features/product_reports/presentation/pages/admin_product_reports_page.dart';
import '../../features/merchant/presentation/pages/merchant_inventory_insights_page.dart';
import '../../features/home/presentation/pages/all_categories_page.dart';
import '../../features/home/presentation/pages/offers_page.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';

class AppRouter {
  static bool? _onboardingCompleted;
  static bool _isAuthenticated = false;

  static Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  }

  static bool get isOnboardingCompleted => _onboardingCompleted ?? false;

  static void setAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.path;

      if (_isAuthenticated) {
        if (path == '/login' ||
            path == '/splash' ||
            path == '/onboarding' ||
            path == '/register') {
          return '/home';
        }
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ShippingCubit>()..loadGovernorates(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/merchant-dashboard',
        builder: (context, state) => const MerchantDashboardPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      // Shell route for bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => NoTransitionPage(
                    child: HomeScreen(key: HomeScreen.globalKey)),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (context, state) => const SearchScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Cart tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CartScreen()),
              ),
            ],
          ),
          // Favorites tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: FavoritesScreen()),
              ),
            ],
          ),
          // Settings tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<OrdersCubit>(),
          child: const CheckoutPage(),
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<OrdersCubit>(),
          child: const OrdersPage(),
        ),
      ),
      GoRoute(
        path: '/parent-order/:id',
        builder: (context, state) {
          final parentOrderId = state.pathParameters['id']!;
          return BlocProvider(
            create: (_) => sl<OrdersCubit>(),
            child: ParentOrderDetailsPage(parentOrderId: parentOrderId),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<NotificationsCubit>(),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/language-settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        path: '/theme-settings',
        builder: (context, state) => const ThemeSettingsScreen(),
      ),
      GoRoute(
        path: '/product',
        redirect: (context, state) => '/home',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return _ProductByIdScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/store/:merchantId',
        builder: (context, state) {
          final merchantId = state.pathParameters['merchantId']!;
          final storeName = state.uri.queryParameters['name'];
          return StoreProductsScreen(
            merchantId: merchantId,
            storeName: storeName,
          );
        },
      ),
      GoRoute(
        path: '/merchant-coupons',
        builder: (context, state) => const MerchantCouponsPage(),
      ),
      GoRoute(
        path: '/global-coupons',
        builder: (context, state) => const GlobalCouponsPage(),
      ),
      GoRoute(
        path: '/manage-categories',
        builder: (context, state) => const MerchantCategoriesTab(),
      ),
      GoRoute(
        path: '/merchant-top-rated',
        builder: (context, state) => const MerchantTopRatedProductsPage(),
      ),
      GoRoute(
        path: '/admin-merchant-coupons',
        builder: (context, state) => const AdminMerchantCouponsPage(),
      ),
      GoRoute(
        path: '/my-reports',
        builder: (context, state) => const MyReportsPage(),
      ),
      GoRoute(
        path: '/admin-product-reports',
        builder: (context, state) => const AdminProductReportsPage(),
      ),
      GoRoute(
        path: '/merchant-inventory-insights',
        builder: (context, state) => const MerchantInventoryInsightsPage(),
      ),
      GoRoute(
        path: '/all-categories',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['categoryId'];
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => sl<ProductsCubit>()),
              BlocProvider(
                  create: (_) => sl<CategoriesCubit>()..loadCategories()),
            ],
            child: AllCategoriesPage(initialCategoryId: categoryId),
          );
        },
      ),
      GoRoute(
        path: '/offers/:type',
        builder: (context, state) {
          final typeStr = state.pathParameters['type']!;
          OfferType offerType;
          switch (typeStr) {
            case 'flash-sale':
              offerType = OfferType.flashSale;
              break;
            case 'best-deals':
              offerType = OfferType.bestDeals;
              break;
            case 'new-arrivals':
              offerType = OfferType.newArrivals;
              break;
            default:
              offerType = OfferType.bestDeals;
          }
          return BlocProvider(
            create: (_) => sl<ProductsCubit>(),
            child: OffersPage(offerType: offerType),
          );
        },
      ),
    ],
  );
}

/// Screen that loads product by ID and shows ProductScreen
class _ProductByIdScreen extends StatefulWidget {
  final String productId;
  const _ProductByIdScreen({required this.productId});

  @override
  State<_ProductByIdScreen> createState() => _ProductByIdScreenState();
}

class _ProductByIdScreenState extends State<_ProductByIdScreen> {
  ProductEntity? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final productsCubit = sl<ProductsCubit>();
      final product = await productsCubit.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
          if (product == null) {
            _error = 'Product not found';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error ?? 'Product not found'),
            ],
          ),
        ),
      );
    }
    // Show product screen - it will handle inactive state internally
    return ProductScreen(product: _product!);
  }
}
