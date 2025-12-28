import 'package:app_links/app_links.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/deep_link_service.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/products/presentation/cubit/products_cubit.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/notifications/data/services/order_status_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await EasyLocalization.ensureInitialized();

  // Initialize ChottuLink SDK (for analytics only, not for deep link handling)
  await ChottuLink.init(apiKey: "c_app_aj45jOSPqhk4Ea4M2v9cY6k6a1CeSMgt");

  // Initialize dependencies (Supabase, etc.)
  await di.initializeDependencies();

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
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Initialize deep links listener using app_links package
  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Handle initial link (app opened from link)
    // Save it for processing after splash screen completes
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('🔗 INITIAL DEEP LINK (saving for later)');
        debugPrint('URI: $uri');
        debugPrint('═══════════════════════════════════════════════════════');
        // Save for processing after splash screen navigation
        DeepLinkService().saveInitialDeepLink(uri);
      }
    });

    // Handle links while app is running (not initial launch)
    _appLinks.uriLinkStream.listen((Uri uri) {
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
          DeepLinkService().navigateToPendingDeepLink();
        } else if (state is AuthUnauthenticated) {
          // Stop listening when user logs out
          di.sl<OrderStatusListener>().stopListening();
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
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
