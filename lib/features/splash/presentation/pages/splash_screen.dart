import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/deep_link_service.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (!AppRouter.isOnboardingCompleted) {
      context.go('/onboarding');
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final hasInitialDeepLink = DeepLinkService().hasInitialDeepLink;

    if (authState is AuthAuthenticated) {
      AppRouter.setAuthenticated(true);

      // If there's a deep link, always go to home (user mode) to show the product
      // Even for merchants - they can switch to merchant mode later
      if (hasInitialDeepLink) {
        context.pushReplacement('/home');
        Future.delayed(const Duration(milliseconds: 100), () {
          DeepLinkService().processInitialDeepLink();
        });
      } else if (authState.user.isAdmin) {
        context.pushReplacement('/admin');
      } else if (authState.user.isMerchant) {
        context.pushReplacement('/merchant-dashboard');
      } else {
        context.pushReplacement('/home');
      }
    } else {
      AppRouter.setAuthenticated(false);
      context.pushReplacement('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/on_bording/logo-2.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
