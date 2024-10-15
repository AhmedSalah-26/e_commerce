import 'package:e_commerce/feature/favorite_page_screen/Domain/favorite_screen_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../feature/SplachScreen/ui/SplachScreen.dart';
import '../../feature/cart_screen/Domain/CartScreenProvider.dart';
import '../../feature/cart_screen/ui/cart_screen.dart';
import '../../feature/forget_password/ui/ForgetPasswordScreen.dart';
import '../../feature/forget_password/ui/ForgetPasswordUsingNUmberScreen.dart';
import '../../feature/forget_password/ui/ResetPasswordScreen.dart';
import '../../feature/home_screen/Domain/home_screen_provider.dart';
import '../../feature/home_screen/ui/home_screen.dart';
import '../../feature/navigation_screen/ui/HomeNavigationScreen.dart';
import '../../feature/onbording_screen/ui/OnBording.dart';
import '../../feature/otp_screen/ui/OtpPageScreen.dart';
import '../../feature/product_screen/ui/product_screen.dart';
import '../../feature/registration/ui/LoginScreen.dart';
import '../../feature/registration/ui/SignupScreen.dart';

class Routing {

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return SplachScreen();
        },
      ),
      GoRoute(
        path: '/HomeNavigationScreen',
        builder: (BuildContext context, GoRouterState state) {
          return HomeNavigationscreen();
        },
      ),
      GoRoute(
        path: '/HomeScreen',
        builder: (BuildContext context, GoRouterState state) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => HomeScreenProvider()),
            ],
            child: HomeScreen(),
          );
        },
      ),
      GoRoute(
        path: '/LoginScreen',
        builder: (BuildContext context, GoRouterState state) {
          return Loginscreen();
        },
      ),
      GoRoute(
        path: '/SignupScreen',
        builder: (BuildContext context, GoRouterState state) {
          return Signupscreen();
        },
      ),
      GoRoute(
        path: '/ForgetPasswordScreen',
        builder: (BuildContext context, GoRouterState state) {
          return Forgetpasswordscreen();
        },
      ),
      GoRoute(
        path: '/ResetPasswordScreen',
        builder: (BuildContext context, GoRouterState state) {
          return Resetpasswordscreen();
        },
      ),
      GoRoute(
        path: '/OnBoardingScreen',
        builder: (BuildContext context, GoRouterState state) {
          return Onboarding();
        },
      ),
      GoRoute(
        path: '/ForgetPasswordUsingNUmberScreen',
        builder: (BuildContext context, GoRouterState state) {
          return ForgetPasswordUsingNumberScreen();
        },
      ),
      GoRoute(
        path: '/OtpScreen',
        builder: (BuildContext context, GoRouterState state) {
          return OtpScreen();
        },
      ),
      GoRoute(
        path: '/cartScreen',
        builder: (BuildContext context, GoRouterState state) {
           return CartScreen();
        }),
    ],
  );

  static GoRouter get router => _router;
}
