import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // If not on home tab, go to home
        if (navigationShell.currentIndex != 0) {
          context.go('/home');
        } else {
          // Exit app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: navigationShell,
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
    final isSelected = navigationShell.currentIndex == index;
    return IconButton(
      onPressed: () => _onTap(index),
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
    final isSelected = navigationShell.currentIndex == index;
    return IconButton(
      onPressed: () => _onTap(index),
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
