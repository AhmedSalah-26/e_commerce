import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/products/presentation/cubit/products_cubit.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/categories/presentation/cubit/categories_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';
import 'features/home/presentation/cubit/home_sliders_cubit.dart';
import 'features/notifications/data/services/order_status_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
          BlocProvider<AuthCubit>(
            create: (_) => di.sl<AuthCubit>()..checkAuthStatus(),
          ),
          BlocProvider<ProductsCubit>(
            create: (_) => di.sl<ProductsCubit>(),
          ),
          BlocProvider<CategoriesCubit>(
            create: (_) => di.sl<CategoriesCubit>(),
          ),
          BlocProvider<CartCubit>(
            create: (_) => di.sl<CartCubit>(),
          ),
          BlocProvider<OrdersCubit>(
            create: (_) => di.sl<OrdersCubit>(),
          ),
          BlocProvider<FavoritesCubit>(
            create: (_) => di.sl<FavoritesCubit>(),
          ),
          BlocProvider<HomeSlidersCubit>(
            create: (_) => di.sl<HomeSlidersCubit>(),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initializeApp() {
    final locale = context.locale.languageCode;

    // Set locale for all cubits
    context.read<ProductsCubit>().setLocale(locale);
    context.read<CategoriesCubit>().setLocale(locale);
    context.read<CartCubit>().setLocale(locale);
    context.read<FavoritesCubit>().setLocale(locale);
    context.read<HomeSlidersCubit>().setLocale(locale);

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
        } else if (state is AuthUnauthenticated) {
          // Stop listening when user logs out
          di.sl<OrderStatusListener>().stopListening();
        }
      },
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
      ),
    );
  }
}
