import 'package:flutter/material.dart';
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
  final List<Widget> screens = const [
    HomeScreen(),
    CartScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    const navBarHeight = 65.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content - extends behind navbar
          Positioned.fill(
            child: screens[_bottomNavIndex],
          ),
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final cartItemCount = cartState is CartLoaded
                    ? cartState.items
                        .fold<int>(0, (sum, item) => sum + item.quantity)
                    : 0;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColours.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: navBarHeight,
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
        ],
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
