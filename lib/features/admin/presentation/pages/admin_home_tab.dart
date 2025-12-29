import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/admin_error_widget.dart';

class AdminHomeTab extends StatefulWidget {
  final bool isRtl;

  const AdminHomeTab({super.key, required this.isRtl});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  @override
  void initState() {
    super.initState();
    // Load this month's stats on init
    _loadThisMonthStats();
  }

  void _loadThisMonthStats() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    context.read<AdminCubit>().loadDashboard(
          fromDate: startOfMonth,
          toDate: now,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return AdminErrorWidget(
            message: state.message,
            isRtl: widget.isRtl,
            onRetry: _loadThisMonthStats,
          );
        }
        if (state is AdminLoaded) {
          return _buildContent(context, state);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContent(BuildContext context, AdminLoaded state) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: () async => _loadThisMonthStats(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.isRtl ? 'نظرة عامة' : 'Overview',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isRtl ? 'هذا الشهر' : 'This Month',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatsGrid(context, state),
            const SizedBox(height: 24),
            _buildRecentOrders(context, state, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AdminLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return _buildMobileStats(state);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000 ? 4 : 3;
        final aspectRatio = constraints.maxWidth > 1000 ? 1.8 : 1.6;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: _buildStatCards(state, false),
        );
      },
    );
  }

  Widget _buildMobileStats(AdminLoaded state) {
    final cards = _buildStatCards(state, true);
    return Column(
      children: [
        for (int i = 0; i < cards.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: cards[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < cards.length ? cards[i + 1] : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildStatCards(AdminLoaded state, bool compact) {
    return [
      StatsCard(
        title: widget.isRtl ? 'العملاء' : 'Customers',
        value: '${state.stats.totalCustomers}',
        icon: Icons.people,
        color: Colors.blue,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'التجار' : 'Merchants',
        value: '${state.stats.totalMerchants}',
        icon: Icons.store,
        color: Colors.purple,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'المنتجات' : 'Products',
        value: '${state.stats.activeProducts}',
        icon: Icons.inventory,
        color: Colors.green,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'الطلبات' : 'Orders',
        value: '${state.stats.totalOrders}',
        subtitle:
            '${state.stats.pendingOrders} ${widget.isRtl ? 'معلق' : 'pending'}',
        icon: Icons.receipt_long,
        color: Colors.orange,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'اليوم' : 'Today',
        value: '${state.stats.todayOrders}',
        subtitle:
            '${state.stats.todayRevenue.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
        icon: Icons.today,
        color: Colors.teal,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'إيرادات الشهر' : 'Month Revenue',
        value: state.stats.totalRevenue.toStringAsFixed(0),
        subtitle: widget.isRtl ? 'ج.م' : 'EGP',
        icon: Icons.attach_money,
        color: Colors.green,
        compact: compact,
      ),
    ];
  }

  Widget _buildRecentOrders(
      BuildContext context, AdminLoaded state, ThemeData theme) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isRtl ? 'أحدث الطلبات' : 'Recent Orders',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: state.recentOrders.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child:
                        Text(widget.isRtl ? 'لا توجد طلبات' : 'No orders yet'),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.recentOrders.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: theme.dividerColor),
                  itemBuilder: (context, index) {
                    final order = state.recentOrders[index];
                    return ListTile(
                      dense: isMobile,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 4 : 8,
                      ),
                      leading: CircleAvatar(
                        radius: isMobile ? 16 : 20,
                        backgroundColor: _getStatusColor(order.status),
                        child: Icon(
                          Icons.receipt,
                          color: Colors.white,
                          size: isMobile ? 16 : 20,
                        ),
                      ),
                      title: Text(
                        '#${order.id.substring(0, 8)}',
                        style: TextStyle(fontSize: isMobile ? 13 : 14),
                      ),
                      subtitle: Text(
                        order.customerName ?? '',
                        style: TextStyle(fontSize: isMobile ? 11 : 12),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order.total.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            _getStatusText(order.status),
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: isMobile ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getStatusColor(dynamic status) {
    final s = status.toString().split('.').last;
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(dynamic status) {
    final s = status.toString().split('.').last;
    if (widget.isRtl) {
      switch (s) {
        case 'pending':
          return 'انتظار';
        case 'processing':
          return 'تجهيز';
        case 'shipped':
          return 'شحن';
        case 'delivered':
          return 'تم';
        case 'cancelled':
          return 'ملغي';
        default:
          return s;
      }
    }
    return s;
  }
}
