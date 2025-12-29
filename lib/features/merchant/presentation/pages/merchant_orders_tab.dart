import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/network_error_widget.dart';
import '../../../../core/utils/error_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../widgets/merchant_empty_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_details/order_details_sheet.dart';
import '../widgets/orders_header.dart';
import '../widgets/orders_filter_section.dart';
import '../widgets/orders_statistics_tab.dart';

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

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _deliveredPeriod = 'week';
  String _cancelledPeriod = 'week';

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
    _searchController.dispose();
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
    // Use real-time watching for orders
    context
        .read<OrdersCubit>()
        .watchMerchantOrdersByStatus(_merchantId!, status);
  }

  void _loadMoreOrders(String status) {
    // Pagination disabled when using real-time streams
    // All orders are loaded via the stream
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
                _buildTabBar(isRtl, theme),
                Expanded(child: _buildTabContent(isRtl, theme)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isRtl, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        tabs: [
          Tab(text: isRtl ? 'انتظار' : 'Pending'),
          Tab(text: isRtl ? 'تجهيز' : 'Processing'),
          Tab(text: isRtl ? 'شحن' : 'Shipped'),
          Tab(text: isRtl ? 'توصيل' : 'Delivered'),
          Tab(text: isRtl ? 'ملغي' : 'Cancelled'),
          Tab(
              icon: const Icon(Icons.analytics, size: 20),
              text: isRtl ? 'إحصائيات' : 'Stats'),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isRtl, ThemeData theme) {
    return TabBarView(
      controller: _tabController,
      children: [
        ..._statuses
            .map((status) => _buildOrdersListForStatus(status, isRtl, theme)),
        _merchantId != null
            ? OrdersStatisticsTab(merchantId: _merchantId!)
            : const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildOrdersListForStatus(String status, bool isRtl, ThemeData theme) {
    final showFilters = status == 'delivered' || status == 'cancelled';
    final selectedPeriod =
        status == 'delivered' ? _deliveredPeriod : _cancelledPeriod;

    return Column(
      children: [
        if (showFilters)
          OrdersFilterSection(
            isRtl: isRtl,
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedPeriod: selectedPeriod,
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            onPeriodChanged: (period) => _setFilterPeriod(status, period),
          ),
        Expanded(child: _buildOrdersList(status, isRtl, showFilters, theme)),
      ],
    );
  }

  Widget _buildOrdersList(
      String status, bool isRtl, bool showFilters, ThemeData theme) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listenWhen: (previous, current) {
        // Only listen when the status matches
        if (current is OrdersLoaded) {
          return current.currentStatus == status;
        }
        return true;
      },
      buildWhen: (previous, current) {
        // Only rebuild when:
        // 1. Loading state (show loading for this tab)
        // 2. Error state
        // 3. Loaded state with matching status
        // 4. Updating state with matching status
        if (current is OrdersLoading) return true;
        if (current is OrdersError) return true;
        if (current is OrderStatusUpdating) {
          return current.currentStatus == status;
        }
        if (current is OrdersLoaded) {
          return current.currentStatus == status;
        }
        return false;
      },
      listener: (context, state) {
        // Update pending count when pending orders list changes
        if (state is OrdersLoaded &&
            state.currentStatus == 'pending' &&
            status == 'pending') {
          setState(() {
            _todayPending = state.orders.length;
          });
        }
      },
      builder: (context, state) {
        if (state is OrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show shimmer when updating order status
        if (state is OrderStatusUpdating && state.currentStatus == status) {
          return _buildShimmerList(theme);
        }

        if (state is OrdersError) {
          return _buildErrorState(state.message, isRtl, status);
        }

        if (state is OrdersLoaded && state.currentStatus == status) {
          var filteredOrders = state.orders;
          if (_searchQuery.isNotEmpty && showFilters) {
            filteredOrders = filteredOrders
                .where((order) =>
                    order.id.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

          if (filteredOrders.isEmpty) {
            return MerchantEmptyState(
              icon: Icons.inbox_outlined,
              title: isRtl ? 'لا توجد طلبات' : 'No orders',
              subtitle: isRtl
                  ? 'لا توجد طلبات بهذه الحالة'
                  : 'No orders with this status',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadOrdersForStatus(status),
            child: ListView.builder(
              controller: _scrollControllers[status],
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () => OrderDetailsSheet.show(context, order, isRtl),
                );
              },
            ),
          );
        }

        // Show loading by default when status doesn't match
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildShimmerList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(theme, width: 100, height: 16),
                  _buildShimmerBox(theme, width: 80, height: 24),
                ],
              ),
              const SizedBox(height: 12),
              _buildShimmerBox(theme, width: 150, height: 14),
              const SizedBox(height: 8),
              _buildShimmerBox(theme, width: 200, height: 14),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShimmerBox(theme, width: 80, height: 14),
                  _buildShimmerBox(theme, width: 60, height: 14),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(ThemeData theme,
      {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const _ShimmerEffect(),
    );
  }

  void _setFilterPeriod(String status, String period) {
    setState(() {
      if (status == 'delivered') {
        _deliveredPeriod = period;
      } else {
        _cancelledPeriod = period;
      }
    });
    _loadOrdersForStatus(status);
  }

  Widget _buildErrorState(String message, bool isRtl, String status) {
    return NetworkErrorWidget(
      message: ErrorHelper.getUserFriendlyMessage(message),
      onRetry: () => _loadOrdersForStatus(status),
    );
  }
}

/// Shimmer effect widget for loading animation
class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect();

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colorScheme.onSurface.withValues(alpha: 0.05),
                theme.colorScheme.onSurface.withValues(alpha: 0.15),
                theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
