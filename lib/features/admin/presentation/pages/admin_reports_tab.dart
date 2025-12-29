import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import 'admin_rankings_page.dart';

class AdminReportsTab extends StatelessWidget {
  final bool isRtl;
  const AdminReportsTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme, isRtl ? 'الترتيبات' : 'Rankings'),
                const SizedBox(height: 12),
                _buildRankingsGrid(context, isMobile),
                const SizedBox(height: 24),
                _buildTitle(theme, isRtl ? 'الإحصائيات' : 'Statistics'),
                const SizedBox(height: 12),
                ..._buildStatCards(state, isMobile),
              ],
            ),
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildTitle(ThemeData theme, String text) {
    return Text(text,
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildRankingsGrid(BuildContext context, bool isMobile) {
    final items = [
      (
        Icons.trending_up,
        isRtl ? 'التجار الأكثر مبيعاً' : 'Top Selling',
        Colors.green,
        'top_selling'
      ),
      (
        Icons.shopping_cart,
        isRtl ? 'العملاء الأكثر طلباً' : 'Top Customers',
        Colors.blue,
        'top_customers'
      ),
      (
        Icons.cancel,
        isRtl ? 'الأكثر إلغاءً' : 'Most Cancellations',
        Colors.orange,
        'most_cancellations'
      ),
      (
        Icons.warning,
        isRtl ? 'تجار مشكلة' : 'Problematic',
        Colors.red,
        'problematic'
      ),
    ];

    final cards = items
        .map((i) => _RankingButton(
              icon: i.$1,
              title: i.$2,
              color: i.$3,
              onTap: () => _openRankings(context, i.$4, i.$2),
              isRtl: isRtl,
            ))
        .toList();

    if (isMobile) return Column(children: cards);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: cards,
    );
  }

  void _openRankings(BuildContext context, String type, String title) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AdminCubit>(),
            child: AdminRankingsPage(type: type, title: title, isRtl: isRtl),
          ),
        ));
  }

  List<Widget> _buildStatCards(AdminLoaded state, bool isMobile) {
    final s = state.stats;
    return [
      _StatCard(
          icon: Icons.people,
          title: isRtl ? 'العملاء' : 'Customers',
          value: '${s.totalCustomers}',
          color: Colors.blue,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.store,
          title: isRtl ? 'التجار' : 'Merchants',
          value: '${s.totalMerchants}',
          color: Colors.purple,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.inventory,
          title: isRtl ? 'المنتجات' : 'Products',
          value: '${s.totalProducts}',
          sub: '${s.activeProducts} ${isRtl ? 'نشط' : 'active'}',
          color: Colors.green,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.receipt_long,
          title: isRtl ? 'الطلبات' : 'Orders',
          value: '${s.totalOrders}',
          sub: '${s.pendingOrders} ${isRtl ? 'معلق' : 'pending'}',
          color: Colors.orange,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.attach_money,
          title: isRtl ? 'الإيرادات' : 'Revenue',
          value: s.totalRevenue.toStringAsFixed(0),
          color: Colors.teal,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.today,
          title: isRtl ? 'اليوم' : 'Today',
          value: '${s.todayOrders}',
          sub: s.todayRevenue.toStringAsFixed(0),
          color: Colors.indigo,
          isMobile: isMobile),
    ];
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AdminCubit>().loadDashboard(),
            child: Text(isRtl ? 'تحديث' : 'Refresh'),
          ),
        ],
      ),
    );
  }
}

class _RankingButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isRtl;

  const _RankingButton(
      {required this.icon,
      required this.title,
      required this.color,
      required this.onTap,
      required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              Icon(isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? sub;
  final Color color;
  final bool isMobile;

  const _StatCard(
      {required this.icon,
      required this.title,
      required this.value,
      this.sub,
      required this.color,
      required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: isMobile ? 13 : 14, color: Colors.grey)),
                  Text(value,
                      style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold)),
                  if (sub != null)
                    Text(sub!,
                        style: TextStyle(
                            fontSize: isMobile ? 11 : 12, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
