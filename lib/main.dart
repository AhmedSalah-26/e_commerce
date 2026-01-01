import 'package:app_links/app_links.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/deep_link_service.dart';
import 'core/config/paymob_config.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/products/presentation/cubit/products_cubit.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/notifications/data/services/order_status_listener.dart';
import 'features/payment/data/services/paymob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only (not supported on web)
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await EasyLocalization.ensureInitialized();

  // Initialize ChottuLink SDK (for analytics only, not for deep link handling)
  // Only on mobile platforms, not on web
  if (!kIsWeb) {
    await ChottuLink.init(apiKey: "c_app_aj45jOSPqhk4Ea4M2v9cY6k6a1CeSMgt");
  }

  // Initialize dependencies (Supabase, etc.)
  await di.initializeDependencies();

  /// Initialize Paymob (only if configured)
  if (PaymobConfig.isConfigured) {
    await PaymobService.initialize(
      apiKey: PaymobConfig.apiKey,
      integrationId: PaymobConfig.integrationId,
      iFrameId: PaymobConfig.iFrameId,
    );
  }

  // Get initial deep link BEFORE app starts (important for cold start)
  // Only on mobile platforms
  if (!kIsWeb) {
    final appLinks = AppLinks();
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔗 INITIAL DEEP LINK (in main, before app starts)');
      debugPrint('URI: $initialUri');
      debugPrint('═══════════════════════════════════════════════════════');
      DeepLinkService().saveInitialDeepLink(initialUri);
    }
  }

  // Cleanup expired flash sales on app start
  _cleanupExpiredFlashSales();

  // Check onboarding status
  await AppRouter.checkOnboardingStatus();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (_) => ThemeCubit(),
          ),
          BlocProvider<AuthCubit>(
            create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
          ),
          BlocProvider<ProductsCubit>(
            create: (_) => di.sl<ProductsCubit>(),
          ),
          BlocProvider<CartCubit>(
            create: (_) => di.sl<CartCubit>(),
          ),
          BlocProvider<FavoritesCubit>(
            create: (_) => di.sl<FavoritesCubit>(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// Cleanup expired flash sales in background
void _cleanupExpiredFlashSales() {
  try {
    final datasource = di.sl<ProductRemoteDataSource>();
    datasource.cleanupExpiredFlashSales();
  } catch (_) {
    // Silently fail - not critical
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLinks? _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Initialize deep links listener for links while app is running
  void _initDeepLinks() {
    // Skip deep links on web
    if (kIsWeb) return;

    _appLinks = AppLinks();

    // Only listen for links while app is running (not initial launch)
    // Initial link is handled in main() before app starts
    _appLinks!.uriLinkStream.listen((Uri uri) {
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔗 DEEP LINK RECEIVED (app running)');
      debugPrint('URI: $uri');
      debugPrint('  HOST: ${uri.host}');
      debugPrint('  PATH: ${uri.path}');
      debugPrint('  QUERY: ${uri.query}');
      debugPrint('  QUERY PARAMS: ${uri.queryParameters}');
      debugPrint('═══════════════════════════════════════════════════════');
      DeepLinkService().handleDeepLink(uri);
    });
  }

  void _initializeApp() {
    final locale = context.locale.languageCode;

    // Set locale for global cubits
    context.read<ProductsCubit>().setLocale(locale);
    context.read<CartCubit>().setLocale(locale);
    context.read<FavoritesCubit>().setLocale(locale);

    // Initialize user data if authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoritesCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().loadCart(authState.user.id);

      // Start listening for order status changes
      di.sl<OrderStatusListener>().startListening(
            authState.user.id,
            locale: locale,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        final locale = context.locale.languageCode;

        if (state is AuthAuthenticated) {
          context.read<FavoritesCubit>().setUserId(state.user.id);
          context.read<CartCubit>().setUserId(state.user.id);
          context.read<CartCubit>().loadCart(state.user.id);

          // Start listening for order status changes
          di.sl<OrderStatusListener>().startListening(
                state.user.id,
                locale: locale,
              );

          // Navigate to pending deep link after login
          // But NOT if user is on address-onboarding or register page
          // (register page handles its own navigation)
          final currentPath =
              AppRouter.router.routerDelegate.currentConfiguration.uri.path;
          if (currentPath != '/address-onboarding' &&
              currentPath != '/register') {
            DeepLinkService().navigateToPendingDeepLink();
          }
        } else if (state is AuthUnauthenticated) {
          // Stop listening when user logs out
          di.sl<OrderStatusListener>().stopListening();

          // Navigate to login page when session expires
          // Only if we're not already on auth pages
          final currentPath =
              AppRouter.router.routerDelegate.currentConfiguration.uri.path;
          if (currentPath != '/login' &&
              currentPath != '/register' &&
              currentPath != '/splash' &&
              currentPath != '/onboarding') {
            debugPrint('🔐 Session expired - redirecting to login');
            AppRouter.router.go('/login');
          }
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return ToastificationWrapper(
            child: MaterialApp.router(
              theme: themeState.themeData,
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
            ),
          );
        },
      ),
    );
  }
}
