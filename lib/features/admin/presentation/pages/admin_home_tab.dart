import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/stats_card.dart';

class AdminHomeTab extends StatelessWidget {
  final bool isRtl;

  const AdminHomeTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminError) {
          return Center(child: Text(state.message));
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

    return RefreshIndicator(
      onRefresh: () => context.read<AdminCubit>().loadDashboard(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRtl ? 'نظرة عامة' : 'Overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildStatsGrid(state),
            const SizedBox(height: 32),
            _buildRecentOrders(context, state, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(AdminLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : constraints.maxWidth > 800
                ? 3
                : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: isRtl ? 'إجمالي العملاء' : 'Total Customers',
              value: '${state.stats.totalCustomers}',
              icon: Icons.people,
              color: Colors.blue,
            ),
            StatsCard(
              title: isRtl ? 'التجار' : 'Merchants',
              value: '${state.stats.totalMerchants}',
              icon: Icons.store,
              color: Colors.purple,
            ),
            StatsCard(
              title: isRtl ? 'المنتجات النشطة' : 'Active Products',
              value: '${state.stats.activeProducts}',
              icon: Icons.inventory,
              color: Colors.green,
            ),
            StatsCard(
              title: isRtl ? 'طلبات معلقة' : 'Pending Orders',
              value: '${state.stats.pendingOrders}',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
            StatsCard(
              title: isRtl ? 'طلبات اليوم' : 'Today Orders',
              value: '${state.stats.todayOrders}',
              icon: Icons.today,
              color: Colors.teal,
            ),
            StatsCard(
              title: isRtl ? 'إجمالي الإيرادات' : 'Total Revenue',
              value:
                  '${state.stats.totalRevenue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            StatsCard(
              title: isRtl ? 'إيرادات اليوم' : 'Today Revenue',
              value:
                  '${state.stats.todayRevenue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
              icon: Icons.trending_up,
              color: Colors.indigo,
            ),
            StatsCard(
              title: isRtl ? 'إجمالي الطلبات' : 'Total Orders',
              value: '${state.stats.totalOrders}',
              icon: Icons.receipt_long,
              color: Colors.brown,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentOrders(
      BuildContext context, AdminLoaded state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRtl ? 'أحدث الطلبات' : 'Recent Orders',
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: state.recentOrders.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(isRtl ? 'لا توجد طلبات' : 'No orders yet'),
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
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(order.status),
                        child:
                            Icon(Icons.receipt, color: Colors.white, size: 20),
                      ),
                      title: Text('#${order.id.substring(0, 8)}'),
                      subtitle: Text(order.customerName ?? ''),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order.total.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _getStatusText(order.status),
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontSize: 12,
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
    final statusStr = status.toString().split('.').last;
    switch (statusStr) {
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
    final statusStr = status.toString().split('.').last;
    if (isRtl) {
      switch (statusStr) {
        case 'pending':
          return 'انتظار';
        case 'processing':
          return 'تجهيز';
        case 'shipped':
          return 'شحن';
        case 'delivered':
          return 'تم التوصيل';
        case 'cancelled':
          return 'ملغي';
        default:
          return statusStr;
      }
    }
    return statusStr;
  }
}
