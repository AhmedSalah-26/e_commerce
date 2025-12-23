import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../cart/presentation/pages/cart_screen.dart';
import '../../../favorites/presentation/pages/favorites_screen.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  late final List<Widget> screens;
  int _bottomNavIndex = 0;
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    screens = [
      HomeScreen(key: _homeScreenKey),
      const CartScreen(),
      const FavoritesScreen(),
      const SettingsScreen(),
    ];
  }

  /// Handle back button press - returns true if should exit app
  bool _handleBackPress() {
    // If on home tab and in search mode, exit search mode first
    if (_bottomNavIndex == 0) {
      final homeState = _homeScreenKey.currentState;
      if (homeState != null && homeState.isInSearchMode) {
        homeState.exitSearchMode();
        return false;
      }
    }

    // If not on home tab, go to home
    if (_bottomNavIndex != 0) {
      setState(() => _bottomNavIndex = 0);
      return false;
    }

    // If on home tab, check for double tap to exit
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اضغط مرة أخرى للخروج'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }

    // Exit app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = _handleBackPress();
        if (shouldExit) {
          SystemNavigator.pop();
        }
        return false; // Never allow default back behavior
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // Use IndexedStack to keep screens alive and avoid rebuilds
        body: IndexedStack(
          index: _bottomNavIndex,
          children: screens,
        ),
        bottomNavigationBar: BlocSelector<CartCubit, CartState, int>(
          selector: (state) => state is CartLoaded
              ? state.items.fold<int>(0, (sum, item) => sum + item.quantity)
              : 0,
          builder: (context, cartItemCount) {
            return Container(
              decoration: BoxDecoration(
                color: AppColours.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 65,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.home_outlined, Icons.home),
                        _buildNavItemWithBadge(
                          1,
                          Icons.shopping_cart_outlined,
                          Icons.shopping_cart,
                          cartItemCount,
                        ),
                        _buildNavItem(
                          2,
                          Icons.favorite_border,
                          Icons.favorite,
                        ),
                        _buildNavItem(
                          3,
                          Icons.settings_outlined,
                          Icons.settings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    final isSelected = _bottomNavIndex == index;
    return IconButton(
      onPressed: () => setState(() => _bottomNavIndex = index),
      icon: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected ? AppColours.primary : AppColours.greyMedium,
        size: 26,
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    int index,
    IconData icon,
    IconData activeIcon,
    int badgeCount,
  ) {
    final isSelected = _bottomNavIndex == index;
    return IconButton(
      onPressed: () => setState(() => _bottomNavIndex = index),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColours.primary : AppColours.greyMedium,
            size: 26,
          ),
          if (badgeCount > 0)
            Positioned(
              right: -8,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
