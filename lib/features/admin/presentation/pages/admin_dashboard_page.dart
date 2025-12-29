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
import 'admin_placeholder_tab.dart';

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
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: Directionality(
          textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: isDesktop ? null : _buildDrawer(isRtl),
            body: Row(
              children: [
                if (isDesktop)
                  AdminSidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) =>
                        setState(() => _selectedIndex = index),
                    isCollapsed: _sidebarCollapsed,
                    onToggleCollapse: () =>
                        setState(() => _sidebarCollapsed = !_sidebarCollapsed),
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
    );
  }

  Widget _buildDrawer(bool isRtl) {
    return Drawer(
      child: AdminSidebar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        isCollapsed: false,
        onToggleCollapse: () {},
        isRtl: isRtl,
      ),
    );
  }

  Widget _buildContent(bool isRtl) {
    switch (_selectedIndex) {
      case 0:
        return AdminHomeTab(isRtl: isRtl);
      case 1:
        return AdminUsersTab(isRtl: isRtl);
      case 2:
        return AdminPlaceholderTab(
          title: isRtl ? 'الطلبات' : 'Orders',
          icon: Icons.receipt_long,
          isRtl: isRtl,
        );
      case 3:
        return AdminPlaceholderTab(
          title: isRtl ? 'المنتجات' : 'Products',
          icon: Icons.inventory,
          isRtl: isRtl,
        );
      case 4:
        return AdminPlaceholderTab(
          title: isRtl ? 'التصنيفات' : 'Categories',
          icon: Icons.category,
          isRtl: isRtl,
        );
      case 5:
        return AdminPlaceholderTab(
          title: isRtl ? 'الكوبونات' : 'Coupons',
          icon: Icons.local_offer,
          isRtl: isRtl,
        );
      case 6:
        return AdminPlaceholderTab(
          title: isRtl ? 'الشحن' : 'Shipping',
          icon: Icons.local_shipping,
          isRtl: isRtl,
        );
      case 7:
        return AdminPlaceholderTab(
          title: isRtl ? 'التقارير' : 'Reports',
          icon: Icons.analytics,
          isRtl: isRtl,
        );
      case 8:
        return AdminPlaceholderTab(
          title: isRtl ? 'الإعدادات' : 'Settings',
          icon: Icons.settings,
          isRtl: isRtl,
        );
      default:
        return AdminHomeTab(isRtl: isRtl);
    }
  }
}
