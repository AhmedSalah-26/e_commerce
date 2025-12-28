import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../cubit/merchant_products_cubit.dart';
import 'merchant_orders_tab.dart';
import 'merchant_inventory_tab.dart';
import 'merchant_categories_tab.dart';
import 'merchant_settings_tab.dart';

class MerchantDashboardPage extends StatefulWidget {
  const MerchantDashboardPage({super.key});

  @override
  State<MerchantDashboardPage> createState() => _MerchantDashboardPageState();
}

class _MerchantDashboardPageState extends State<MerchantDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MerchantOrdersTab(),
    MerchantInventoryTab(),
    MerchantCategoriesTab(),
    MerchantSettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<OrdersCubit>()),
        BlocProvider(create: (_) => sl<MerchantProductsCubit>()),
        BlocProvider(create: (_) => sl<CategoriesCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.colorScheme.surface,
              selectedItemColor: theme.colorScheme.primary,
              unselectedItemColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt_long),
                  label: Localizations.localeOf(context).languageCode == 'ar'
                      ? 'الطلبات'
                      : 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.inventory),
                  label: Localizations.localeOf(context).languageCode == 'ar'
                      ? 'المخزون'
                      : 'Inventory',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.category),
                  label: Localizations.localeOf(context).languageCode == 'ar'
                      ? 'التصنيفات'
                      : 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: Localizations.localeOf(context).languageCode == 'ar'
                      ? 'الإعدادات'
                      : 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
