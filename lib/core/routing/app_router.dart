import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection_container.dart';
import '../../features/about/presentation/pages/about_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/help/presentation/pages/help_screen.dart';
import '../../features/merchant/presentation/pages/merchant_dashboard_page.dart';
import '../../features/navigation/presentation/pages/main_navigation_screen.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/onbording_screen/ui/onboarding_screen.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/settings/presentation/pages/edit_profile_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

class AppRouter {
  static bool? _onboardingCompleted;

  static Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  }

  static bool get isOnboardingCompleted => _onboardingCompleted ?? false;

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterPage(),
      ),
      GoRoute(
        path: '/merchant-dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const MerchantDashboardPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const MainNavigationScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (BuildContext context, GoRouterState state) =>
            const CheckoutPage(),
      ),
      GoRoute(
        path: '/orders',
        builder: (BuildContext context, GoRouterState state) =>
            const OrdersPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (BuildContext context, GoRouterState state) => BlocProvider(
          create: (_) => sl<NotificationsCubit>(),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/help',
        builder: (BuildContext context, GoRouterState state) =>
            const HelpScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (BuildContext context, GoRouterState state) =>
            const AboutScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (BuildContext context, GoRouterState state) =>
            const EditProfileScreen(),
      ),
    ],
  );
}
