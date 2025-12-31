import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'monthly_data.dart';

class CancelledLineChart extends StatelessWidget {
  final List<MonthlyData> data;
  final bool isRtl;

  const CancelledLineChart({
    super.key,
    required this.data,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyState();

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
        titlesData: _buildTitles(isDark),
        borderData: FlBorderData(show: false),
        lineBarsData: [_buildLineData(spots)],
        lineTouchData: _buildTouchData(),
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

  LineChartBarData _buildLineData(List<FlSpot> spots) {
    return LineChartBarData(
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
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
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
                  text: '${spot.y.toInt()} ${isRtl ? 'طلب ملغي' : 'cancelled'}',
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
