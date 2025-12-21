import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/products/presentation/cubit/products_cubit.dart';
import 'features/categories/presentation/cubit/categories_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/favorites/presentation/cubit/favorites_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize dependencies (Supabase, etc.)
  await di.initializeDependencies();

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
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _lastLocale;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated and set userId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
      _updateLocale();
    });
  }

  void _initializeUserData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<FavoritesCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().setUserId(authState.user.id);
      context.read<CartCubit>().loadCart(authState.user.id);
    }
  }

  void _updateLocale() {
    final currentLocale = context.locale.languageCode;
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
      // Set locale for products, categories, and cart cubits
      context.read<ProductsCubit>().setLocale(currentLocale);
      context.read<CategoriesCubit>().setLocale(currentLocale);
      context.read<CartCubit>().setLocale(currentLocale);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateLocale();
  }

  @override
  Widget build(BuildContext context) {
    // Update locale when it changes
    _updateLocale();

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // When user logs in, set userId for favorites and cart
        if (state is AuthAuthenticated) {
          context.read<FavoritesCubit>().setUserId(state.user.id);
          context.read<CartCubit>().setUserId(state.user.id);
          context.read<CartCubit>().loadCart(state.user.id);
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
