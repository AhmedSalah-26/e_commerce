import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyData {
  final String month;
  final double sales;
  final int customers;
  final int orders;
  final int cancelled;

  MonthlyData({
    required this.month,
    required this.sales,
    required this.customers,
    required this.orders,
    required this.cancelled,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      month: json['month_name'] as String? ?? '',
      sales: (json['total_sales'] as num?)?.toDouble() ?? 0,
      customers: (json['new_customers'] as num?)?.toInt() ?? 0,
      orders: (json['total_orders'] as num?)?.toInt() ?? 0,
      cancelled: (json['cancelled_orders'] as num?)?.toInt() ?? 0,
    );
  }
}

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
        _ProfessionalChartCard(
          title: isRtl ? 'المبيعات' : 'Sales Revenue',
          subtitle: isRtl ? 'إجمالي المبيعات بالجنيه' : 'Total sales in EGP',
          icon: Icons.trending_up_rounded,
          gradient: const [Color(0xFF00C853), Color(0xFF69F0AE)],
          isMobile: isMobile,
          child: SalesAreaChart(data: data, isRtl: isRtl),
        ),
        const SizedBox(height: 20),
        // Orders & Customers
        _ProfessionalChartCard(
          title: isRtl ? 'الطلبات والعملاء الجدد' : 'Orders & New Customers',
          subtitle: isRtl ? 'مقارنة شهرية' : 'Monthly comparison',
          icon: Icons.people_alt_rounded,
          gradient: const [Color(0xFF2196F3), Color(0xFF64B5F6)],
          legend: [
            _LegendItem(isRtl ? 'الطلبات' : 'Orders', const Color(0xFF2196F3)),
            _LegendItem(
                isRtl ? 'عملاء جدد' : 'New Customers', const Color(0xFF9C27B0)),
          ],
          isMobile: isMobile,
          child: OrdersCustomersChart(data: data, isRtl: isRtl),
        ),
        const SizedBox(height: 20),
        // Cancelled Orders
        _ProfessionalChartCard(
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

class _LegendItem {
  final String label;
  final Color color;
  _LegendItem(this.label, this.color);
}

class _ProfessionalChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Widget child;
  final bool isMobile;
  final List<_LegendItem>? legend;

  const _ProfessionalChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.child,
    required this.isMobile,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient accent
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  gradient[0].withValues(alpha: isDark ? 0.2 : 0.1),
                  gradient[1].withValues(alpha: isDark ? 0.1 : 0.05),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (legend != null) ...[
                  Wrap(
                    spacing: 16,
                    children: legend!
                        .map((item) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          // Chart
          Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 8 : 16,
              16,
              isMobile ? 16 : 24,
              isMobile ? 16 : 20,
            ),
            child: SizedBox(
              height: isMobile ? 200 : 240,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class SalesAreaChart extends StatelessWidget {
  final List<MonthlyData> data;
  final bool isRtl;

  const SalesAreaChart({super.key, required this.data, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState(context);
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxY = data.map((e) => e.sales).reduce((a, b) => a > b ? a : b);
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.sales);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: _buildTitles(isDark),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: const LinearGradient(
              colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: const Color(0xFF00C853),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00C853).withValues(alpha: 0.3),
                  const Color(0xFF00C853).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.all(12),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final monthData = data[spot.x.toInt()];
                return LineTooltipItem(
                  '${monthData.month}\n',
                  TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text: '${_formatNumber(spot.y)} ${isRtl ? 'ج.م' : 'EGP'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  FlTitlesData _buildTitles(bool isDark) {
    // Show label every 5 days to avoid crowding
    final interval = (data.length / 6).ceil();

    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                _formatNumber(value),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: interval.toDouble(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < data.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  data[index].month,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 48, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(
            isRtl ? 'لا توجد بيانات' : 'No data available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}

class OrdersCustomersChart extends StatelessWidget {
  final List<MonthlyData> data;
  final bool isRtl;

  const OrdersCustomersChart(
      {super.key, required this.data, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.all(10),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final monthData = data[groupIndex];
              final label = rodIndex == 0
                  ? (isRtl ? 'طلبات' : 'Orders')
                  : (isRtl ? 'عملاء جدد' : 'New Customers');
              final value =
                  rodIndex == 0 ? monthData.orders : monthData.customers;
              return BarTooltipItem(
                '${monthData.month}\n$label: $value',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (data.length / 6).ceil().toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      data[index].month,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: e.value.orders.toDouble(),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF1976D2), Color(0xFF64B5F6)],
                ),
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
              BarChartRodData(
                toY: e.value.customers.toDouble(),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
                ),
                width: 14,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 48, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(
            isRtl ? 'لا توجد بيانات' : 'No data available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class CancelledLineChart extends StatelessWidget {
  final List<MonthlyData> data;
  final bool isRtl;

  const CancelledLineChart(
      {super.key, required this.data, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxY = data.map((e) => e.cancelled).reduce((a, b) => a > b ? a : b);
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.cancelled.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.15),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (data.length / 6).ceil().toDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      data[index].month,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF8A80)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: const Color(0xFFE53935),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE53935).withValues(alpha: 0.25),
                  const Color(0xFFE53935).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.all(12),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final monthData = data[spot.x.toInt()];
                return LineTooltipItem(
                  '${monthData.month}\n',
                  TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${spot.y.toInt()} ${isRtl ? 'طلب ملغي' : 'cancelled'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded,
              size: 48, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text(
            isRtl ? 'لا توجد بيانات' : 'No data available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
