import 'package:flutter/material.dart';

import '../../cubit/admin_state.dart';
import '../../widgets/reports/stat_card.dart';

class ReportsStatsSection extends StatelessWidget {
  final AdminLoaded state;
  final bool isRtl;
  final bool isMobile;

  const ReportsStatsSection({
    super.key,
    required this.state,
    required this.isRtl,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRtl ? 'الإحصائيات' : 'Statistics',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ..._buildStatCards(),
      ],
    );
  }

  List<Widget> _buildStatCards() {
    final s = state.stats;
    return [
      StatCard(
        icon: Icons.people,
        title: isRtl ? 'العملاء' : 'Customers',
        value: '${s.totalCustomers}',
        color: Colors.blue,
        isMobile: isMobile,
      ),
      StatCard(
        icon: Icons.store,
        title: isRtl ? 'التجار' : 'Merchants',
        value: '${s.totalMerchants}',
        color: Colors.purple,
        isMobile: isMobile,
      ),
      StatCard(
        icon: Icons.inventory,
        title: isRtl ? 'المنتجات' : 'Products',
        value: '${s.totalProducts}',
        sub: '${s.activeProducts} ${isRtl ? 'نشط' : 'active'}',
        color: Colors.green,
        isMobile: isMobile,
      ),
      StatCard(
        icon: Icons.receipt_long,
        title: isRtl ? 'الطلبات' : 'Orders',
        value: '${s.totalOrders}',
        sub: '${s.pendingOrders} ${isRtl ? 'معلق' : 'pending'}',
        color: Colors.orange,
        isMobile: isMobile,
      ),
      StatCard(
        icon: Icons.attach_money,
        title: isRtl ? 'الإيرادات' : 'Revenue',
        value: s.totalRevenue.toStringAsFixed(0),
        color: Colors.teal,
        isMobile: isMobile,
      ),
      StatCard(
        icon: Icons.today,
        title: isRtl ? 'اليوم' : 'Today',
        value: '${s.todayOrders}',
        sub: s.todayRevenue.toStringAsFixed(0),
        color: Colors.indigo,
        isMobile: isMobile,
      ),
    ];
  }
}
