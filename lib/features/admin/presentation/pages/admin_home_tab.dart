import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/admin_error_widget.dart';
import '../widgets/admin_charts.dart';
import '../../domain/entities/admin_stats_entity.dart';

class AdminHomeTab extends StatefulWidget {
  final bool isRtl;

  const AdminHomeTab({super.key, required this.isRtl});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  // Cache dashboard data locally to persist across tab switches
  AdminStatsEntity? _cachedStats;
  List<MonthlyData>? _cachedMonthlyStats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    context
        .read<AdminCubit>()
        .loadDashboard(fromDate: startOfMonth, toDate: now);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminLoaded) {
          setState(() {
            _cachedStats = state.stats;
            _cachedMonthlyStats = state.monthlyStats;
            _isLoading = false;
            _error = null;
          });
        } else if (state is AdminError) {
          setState(() {
            _isLoading = false;
            _error = state.message;
          });
        } else if (state is AdminLoading) {
          // Only show loading if we don't have cached data
          if (_cachedStats == null) {
            setState(() => _isLoading = true);
          }
        }
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _cachedStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _cachedStats == null) {
      return AdminErrorWidget(
        message: _error!,
        isRtl: widget.isRtl,
        onRetry: _loadDashboard,
      );
    }

    if (_cachedStats != null) {
      return _buildContent(context);
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return RefreshIndicator(
      onRefresh: () async => _loadDashboard(),
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
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            _buildChartsSection(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return _buildMobileStats();
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
          children: _buildStatCards(false),
        );
      },
    );
  }

  Widget _buildMobileStats() {
    final cards = _buildStatCards(true);
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

  List<Widget> _buildStatCards(bool compact) {
    final stats = _cachedStats!;
    return [
      StatsCard(
        title: widget.isRtl ? 'العملاء' : 'Customers',
        value: '${stats.totalCustomers}',
        icon: Icons.people,
        color: Colors.blue,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'التجار' : 'Merchants',
        value: '${stats.totalMerchants}',
        icon: Icons.store,
        color: Colors.purple,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'المنتجات' : 'Products',
        value: '${stats.activeProducts}',
        icon: Icons.inventory,
        color: Colors.green,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'الطلبات' : 'Orders',
        value: '${stats.totalOrders}',
        subtitle: '${stats.pendingOrders} ${widget.isRtl ? 'معلق' : 'pending'}',
        icon: Icons.receipt_long,
        color: Colors.orange,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'اليوم' : 'Today',
        value: '${stats.todayOrders}',
        subtitle:
            '${stats.todayRevenue.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
        icon: Icons.today,
        color: Colors.teal,
        compact: compact,
      ),
      StatsCard(
        title: widget.isRtl ? 'إيرادات الشهر' : 'Month Revenue',
        value: stats.totalRevenue.toStringAsFixed(0),
        subtitle: widget.isRtl ? 'ج.م' : 'EGP',
        icon: Icons.attach_money,
        color: Colors.green,
        compact: compact,
      ),
    ];
  }

  Widget _buildChartsSection(BuildContext context, ThemeData theme) {
    final monthlyData = _cachedMonthlyStats ?? [];

    return AdminChartsSection(
      isRtl: widget.isRtl,
      data: monthlyData,
    );
  }
}
