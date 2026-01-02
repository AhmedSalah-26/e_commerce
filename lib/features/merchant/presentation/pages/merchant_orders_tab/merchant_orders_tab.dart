import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';
import '../../../../orders/presentation/cubit/orders_cubit.dart';
import '../../widgets/orders_header.dart';
import '../../widgets/orders_statistics_tab.dart';
import 'merchant_orders_tab_bar.dart';
import 'merchant_orders_list.dart';

class MerchantOrdersTab extends StatefulWidget {
  const MerchantOrdersTab({super.key});

  @override
  State<MerchantOrdersTab> createState() => _MerchantOrdersTabState();
}

class _MerchantOrdersTabState extends State<MerchantOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  int _todayPending = 0;
  int _todayDelivered = 0;
  String? _merchantId;

  final Map<String, int> _currentPage = {};
  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length + 1, vsync: this);
    _tabController.addListener(_onTabChanged);

    for (final status in _statuses) {
      _currentPage[status] = 0;
      _scrollControllers[status] = ScrollController()
        ..addListener(() => _onScroll(status));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    for (final controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onScroll(String status) {
    final controller = _scrollControllers[status];
    if (controller == null) return;
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _loadMoreOrders(status);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging &&
        _tabController.index < _statuses.length) {
      final status = _statuses[_tabController.index];
      if (_currentPage[status] == 0) {
        _loadOrdersForStatus(status);
      }
    }
  }

  void _loadInitialData() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _merchantId = authState.user.id;
      _loadTodayCounts(_merchantId!);
      _loadOrdersForStatus(_statuses[0]);
    }
  }

  Future<void> _loadTodayCounts(String merchantId) async {
    final counts =
        await context.read<OrdersCubit>().getMerchantOrdersCount(merchantId);
    if (mounted) {
      setState(() {
        _todayPending = counts['todayPending'] ?? 0;
        _todayDelivered = counts['todayDelivered'] ?? 0;
      });
    }
  }

  void _loadOrdersForStatus(String status) {
    if (_merchantId == null) return;
    _currentPage[status] = 0;
    context
        .read<OrdersCubit>()
        .watchMerchantOrdersByStatus(_merchantId!, status);
  }

  void _loadMoreOrders(String status) {
    // Pagination disabled when using real-time streams
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _merchantId = authState.user.id;
          _loadTodayCounts(_merchantId!);
          _loadOrdersForStatus(_statuses[_tabController.index]);
        }
      },
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                OrdersHeader(
                  isRtl: isRtl,
                  totalPending: _todayPending,
                  todayDelivered: _todayDelivered,
                ),
                MerchantOrdersTabBar(
                  controller: _tabController,
                  isRtl: isRtl,
                  theme: theme,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ..._statuses.map((status) => MerchantOrdersList(
                            status: status,
                            scrollController: _scrollControllers[status]!,
                            isRtl: isRtl,
                            theme: theme,
                          )),
                      _merchantId != null
                          ? OrdersStatisticsTab(merchantId: _merchantId!)
                          : const Center(child: CircularProgressIndicator()),
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
}
