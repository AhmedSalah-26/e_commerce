import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'monthly_data.dart';

class OrdersCustomersChart extends StatelessWidget {
  final List<MonthlyData> data;
  final bool isRtl;

  const OrdersCustomersChart({
    super.key,
    required this.data,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyState();

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
        titlesData: _buildTitles(isDark),
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
        barGroups: _buildBarGroups(),
      ),
    );
  }

  FlTitlesData _buildTitles(bool isDark) {
    return FlTitlesData(
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
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return data.asMap().entries.map((e) {
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
          BarChartRodData(
            toY: e.value.customers.toDouble(),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFF7B1FA2), Color(0xFFBA68C8)],
            ),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
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
