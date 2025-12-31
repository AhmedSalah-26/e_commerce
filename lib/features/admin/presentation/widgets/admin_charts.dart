import 'package:flutter/material.dart';

import 'charts/cancelled_line_chart.dart';
import 'charts/chart_card.dart';
import 'charts/monthly_data.dart';
import 'charts/orders_customers_chart.dart';
import 'charts/sales_area_chart.dart';

export 'charts/monthly_data.dart';

class AdminChartsSection extends StatelessWidget {
  final bool isRtl;
  final List<MonthlyData> data;

  const AdminChartsSection({
    super.key,
    required this.isRtl,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined,
                color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              isRtl ? 'إحصائيات آخر 6 شهور' : 'Last 6 Months Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Sales Chart
        ChartCard(
          title: isRtl ? 'المبيعات' : 'Sales Revenue',
          subtitle: isRtl ? 'إجمالي المبيعات بالجنيه' : 'Total sales in EGP',
          icon: Icons.trending_up_rounded,
          gradient: const [Color(0xFF00C853), Color(0xFF69F0AE)],
          isMobile: isMobile,
          child: SalesAreaChart(data: data, isRtl: isRtl),
        ),
        const SizedBox(height: 20),
        // Orders & Customers
        ChartCard(
          title: isRtl ? 'الطلبات والعملاء الجدد' : 'Orders & New Customers',
          subtitle: isRtl ? 'مقارنة شهرية' : 'Monthly comparison',
          icon: Icons.people_alt_rounded,
          gradient: const [Color(0xFF2196F3), Color(0xFF64B5F6)],
          legend: [
            LegendItem(isRtl ? 'الطلبات' : 'Orders', const Color(0xFF2196F3)),
            LegendItem(
                isRtl ? 'عملاء جدد' : 'New Customers', const Color(0xFF9C27B0)),
          ],
          isMobile: isMobile,
          child: OrdersCustomersChart(data: data, isRtl: isRtl),
        ),
        const SizedBox(height: 20),
        // Cancelled Orders
        ChartCard(
          title: isRtl ? 'الطلبات الملغية' : 'Cancelled Orders',
          subtitle:
              isRtl ? 'عدد الطلبات الملغية شهرياً' : 'Monthly cancellations',
          icon: Icons.cancel_rounded,
          gradient: const [Color(0xFFFF5252), Color(0xFFFF8A80)],
          isMobile: isMobile,
          child: CancelledLineChart(data: data, isRtl: isRtl),
        ),
      ],
    );
  }
}
