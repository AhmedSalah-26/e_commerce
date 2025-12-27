import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../home/presentation/cubit/home_sliders_cubit.dart';
import '../../../home/presentation/pages/home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  void _onTap(int index) {
    // If tapping on Home tab while already on Home, scroll to top
    if (index == 0 && widget.navigationShell.currentIndex == 0) {
      HomeScreen.globalKey.currentState?.scrollToTop();
      return;
    }
    if (index == widget.navigationShell.currentIndex) return;
    widget.navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<CategoriesCubit>(
          create: (_) => sl<CategoriesCubit>(),
        ),
        BlocProvider<HomeSlidersCubit>(
          create: (_) => sl<HomeSlidersCubit>(),
        ),
      ],
      child: BackButtonListener(
        onBackButtonPressed: () async {
          if (context.canPop()) {
            return false;
          }
          if (widget.navigationShell.currentIndex != 0) {
            widget.navigationShell.goBranch(0, initialLocation: true);
            return true;
          }
          SystemNavigator.pop();
          return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: widget.navigationShell,
          bottomNavigationBar: BlocSelector<CartCubit, CartState, int>(
            selector: (state) => state is CartLoaded
                ? state.items.fold<int>(0, (sum, item) => sum + item.quantity)
                : 0,
            builder: (context, cartItemCount) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
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
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon) {
    final theme = Theme.of(context);
    final isSelected = widget.navigationShell.currentIndex == index;
    return IconButton(
      onPressed: () => _onTap(index),
      icon: Icon(
        isSelected ? activeIcon : icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
    final theme = Theme.of(context);
    final isSelected = widget.navigationShell.currentIndex == index;
    return IconButton(
      onPressed: () => _onTap(index),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
