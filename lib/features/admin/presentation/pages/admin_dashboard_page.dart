import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_header.dart';
import 'admin_home_tab.dart';
import 'admin_users_tab.dart';
import 'admin_orders_tab.dart';
import 'admin_products_tab.dart';
import 'admin_categories_tab.dart';
import 'admin_coupons_tab.dart';
import 'admin_shipping_tab.dart';
import 'admin_reports_tab.dart';
import 'admin_settings_tab.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      final isAdmin = await sl<AdminCubit>().isAdmin(authState.user.id);
      if (!isAdmin && mounted) {
        context.go('/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Access denied. Admin only.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return BlocProvider(
      create: (_) => sl<AdminCubit>()..loadDashboard(),
      child: Builder(
        builder: (blocContext) => BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              context.go('/login');
            }
          },
          child: Directionality(
            textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Scaffold(
              key: _scaffoldKey,
              drawer: isDesktop ? null : _buildDrawer(blocContext, isRtl),
              body: SafeArea(
                child: Row(
                  children: [
                    if (isDesktop)
                      AdminSidebar(
                        selectedIndex: _selectedIndex,
                        onItemSelected: (index) {
                          setState(() => _selectedIndex = index);
                          _loadTabData(blocContext, index);
                        },
                        isCollapsed: _sidebarCollapsed,
                        onToggleCollapse: () => setState(
                            () => _sidebarCollapsed = !_sidebarCollapsed),
                        isRtl: isRtl,
                      ),
                    Expanded(
                      child: Column(
                        children: [
                          AdminHeader(
                            isRtl: isRtl,
                            onMenuTap: isDesktop
                                ? null
                                : () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: _buildContent(isRtl)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext blocContext, bool isRtl) {
    return Drawer(
      child: AdminSidebar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
          _loadTabData(blocContext, index);
        },
        isCollapsed: false,
        onToggleCollapse: () {},
        isRtl: isRtl,
      ),
    );
  }

  void _loadTabData(BuildContext blocContext, int index) {
    final cubit = blocContext.read<AdminCubit>();
    switch (index) {
      case 0:
      case 7:
        cubit.loadDashboard();
        break;
      case 1:
        cubit.loadUsers(role: 'customer');
        break;
      case 2:
        cubit.loadOrders();
        break;
      case 3:
        cubit.loadProducts();
        break;
      case 4:
        cubit.loadCategories();
        break;
    }
  }

  Widget _buildContent(bool isRtl) {
    switch (_selectedIndex) {
      case 0:
        return AdminHomeTab(isRtl: isRtl);
      case 1:
        return AdminUsersTab(isRtl: isRtl);
      case 2:
        return AdminOrdersTab(isRtl: isRtl);
      case 3:
        return AdminProductsTab(isRtl: isRtl);
      case 4:
        return AdminCategoriesTab(isRtl: isRtl);
      case 5:
        return AdminCouponsTab(isRtl: isRtl);
      case 6:
        return AdminShippingTab(isRtl: isRtl);
      case 7:
        return AdminReportsTab(isRtl: isRtl);
      case 8:
        return AdminSettingsTab(isRtl: isRtl);
      default:
        return AdminHomeTab(isRtl: isRtl);
    }
  }
}
