import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../widgets/merchant_empty_state.dart';
import '../widgets/order_card.dart';
import '../widgets/order_details_sheet.dart';
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
  static const int _pageSize = 20;

  int _todayPending = 0;
  int _todayDelivered = 0;
  String? _merchantId;

  // Pagination state per tab
  final Map<String, int> _currentPage = {};
  final Map<String, ScrollController> _scrollControllers = {};

  // Search and filter state for delivered and cancelled tabs
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _deliveredPeriod = 'week';
  String _cancelledPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: _statuses.length + 1, vsync: this); // +1 for statistics
    _tabController.addListener(_onTabChanged);

    // Initialize scroll controllers for each status tab
    for (final status in _statuses) {
      _currentPage[status] = 0;
      _scrollControllers[status] = ScrollController()
        ..addListener(() => _onScroll(status));
    }

    // Set default date ranges for delivered and cancelled
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
    context.read<OrdersCubit>().loadMerchantOrdersByStatusPaginated(
        _merchantId!, status, 0, _pageSize);
  }

  void _loadMoreOrders(String status) {
    final state = context.read<OrdersCubit>().state;
    if (state is OrdersLoaded &&
        state.hasMore &&
        state.currentStatus == status &&
        _merchantId != null) {
      final nextPage = (_currentPage[status] ?? 0) + 1;
      _currentPage[status] = nextPage;
      context.read<OrdersCubit>().loadMerchantOrdersByStatusPaginated(
          _merchantId!, status, nextPage, _pageSize,
          append: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

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
          backgroundColor: AppColours.white,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(isRtl),
                _buildTabBar(isRtl),
                Expanded(child: _buildTabContent(isRtl)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColours.primary, AppColours.brownLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isRtl ? 'إدارة الطلبات' : 'Manage Orders',
                  style: AppTextStyle.semiBold_22_white),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(isRtl ? 'اليوم' : 'Today',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(isRtl ? 'قيد الانتظار' : 'Pending',
                      _todayPending.toString(), Icons.pending_actions)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(isRtl ? 'تم التوصيل' : 'Delivered',
                      _todayDelivered.toString(), Icons.check_circle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isRtl) {
    return Container(
      color: AppColours.greyLighter,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelColor: AppColours.primary,
        unselectedLabelColor: AppColours.greyDark,
        indicatorColor: AppColours.primary,
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

  Widget _buildTabContent(bool isRtl) {
    return TabBarView(
      controller: _tabController,
      children: [
        ..._statuses.map((status) => _buildOrdersListForStatus(status, isRtl)),
        // Statistics tab
        _merchantId != null
            ? OrdersStatisticsTab(merchantId: _merchantId!)
            : const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildOrdersListForStatus(String status, bool isRtl) {
    // Add filter and search for delivered and cancelled tabs
    final showFilters = status == 'delivered' || status == 'cancelled';

    return Column(
      children: [
        if (showFilters) _buildFilterSection(status, isRtl),
        Expanded(
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) {
              if (state is OrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is OrdersError) {
                return _buildErrorState(state.message, isRtl, status);
              } else if (state is OrdersLoaded) {
                // Only show orders if they match the current tab's status
                if (state.currentStatus != status) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter by search query if provided
                var filteredOrders = state.orders;
                if (_searchQuery.isNotEmpty && showFilters) {
                  filteredOrders = filteredOrders
                      .where((order) => order.id
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
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
                    itemCount: filteredOrders.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredOrders.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final order = filteredOrders[index];
                      return OrderCard(
                        order: order,
                        onTap: () =>
                            OrderDetailsSheet.show(context, order, isRtl),
                      );
                    },
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(String status, bool isRtl) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColours.greyLighter,
      child: Column(
        children: [
          // Search by order ID
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: isRtl ? 'بحث برقم الطلب...' : 'Search by order ID...',
              prefixIcon: Icon(Icons.search, color: AppColours.primary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppColours.greyDark),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Period filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(isRtl ? 'يوم' : 'Day', 'day', status, isRtl),
                const SizedBox(width: 8),
                _buildFilterChip(
                    isRtl ? 'أسبوع' : 'Week', 'week', status, isRtl),
                const SizedBox(width: 8),
                _buildFilterChip(
                    isRtl ? 'شهر' : 'Month', 'month', status, isRtl),
                const SizedBox(width: 8),
                _buildFilterChip(
                    isRtl ? '3 شهور' : '3 Months', '3months', status, isRtl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      String label, String period, String status, bool isRtl) {
    final selectedPeriod =
        status == 'delivered' ? _deliveredPeriod : _cancelledPeriod;
    final isSelected = selectedPeriod == period;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        _setFilterPeriod(status, period);
      },
      selectedColor: AppColours.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColours.greyDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColours.primary : AppColours.primary,
        width: isSelected ? 2 : 1,
      ),
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

    // Reload orders for this status
    _loadOrdersForStatus(status);
  }

  Widget _buildErrorState(String message, bool isRtl, String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColours.greyLight),
          const SizedBox(height: 16),
          Text(message,
              style: AppTextStyle.normal_16_greyDark,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _loadOrdersForStatus(status),
            child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }
}
