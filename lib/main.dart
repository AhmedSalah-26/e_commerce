import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/routing/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_colors.dart';
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
        theme: ThemeData(
          fontFamily: 'Changa',
          primaryColor: AppColours.brownMedium,
          colorScheme: const ColorScheme.light(
            primary: AppColours.brownMedium,
            secondary: AppColours.brownLight,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Changa'),
            displayMedium: TextStyle(fontFamily: 'Changa'),
            displaySmall: TextStyle(fontFamily: 'Changa'),
            headlineLarge: TextStyle(fontFamily: 'Changa'),
            headlineMedium: TextStyle(fontFamily: 'Changa'),
            headlineSmall: TextStyle(fontFamily: 'Changa'),
            titleLarge: TextStyle(fontFamily: 'Changa'),
            titleMedium: TextStyle(fontFamily: 'Changa'),
            titleSmall: TextStyle(fontFamily: 'Changa'),
            bodyLarge: TextStyle(fontFamily: 'Changa'),
            bodyMedium: TextStyle(fontFamily: 'Changa'),
            bodySmall: TextStyle(fontFamily: 'Changa'),
            labelLarge: TextStyle(fontFamily: 'Changa'),
            labelMedium: TextStyle(fontFamily: 'Changa'),
            labelSmall: TextStyle(fontFamily: 'Changa'),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColours.brownMedium,
            selectionColor: AppColours.brownLight.withValues(alpha: 0.4),
            selectionHandleColor: AppColours.brownMedium,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(
              color: AppColours.brownMedium,
              fontFamily: 'Changa',
            ),
            floatingLabelStyle: const TextStyle(
              color: AppColours.brownMedium,
              fontFamily: 'Changa',
            ),
            hintStyle: const TextStyle(
              color: AppColours.greyMedium,
              fontFamily: 'Changa',
            ),
            errorStyle: const TextStyle(
              color: Colors.red,
              fontFamily: 'Changa',
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColours.brownLight, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColours.brownLight),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColours.brownLight),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
      ),
    );
  }
}
