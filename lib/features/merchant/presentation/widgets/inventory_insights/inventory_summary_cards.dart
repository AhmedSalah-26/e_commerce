import 'package:flutter/material.dart';
import '../../../domain/entities/inventory_insight_entity.dart';

class InventorySummaryCards extends StatelessWidget {
  final InventoryInsightsSummary summary;
  final bool isRtl;

  const InventorySummaryCards({
    super.key,
    required this.summary,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRtl ? 'نظرة عامة على المخزون' : 'Inventory Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.inventory_2,
                label: isRtl ? 'إجمالي المنتجات' : 'Total Products',
                value: '${summary.totalProducts}',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.storage,
                label: isRtl ? 'إجمالي المخزون' : 'Total Stock',
                value: '${summary.totalStock}',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.attach_money,
                label: isRtl ? 'قيمة المخزون' : 'Stock Value',
                value:
                    '${summary.totalStockValue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.health_and_safety,
                label: isRtl ? 'صحة المخزون' : 'Stock Health',
                value: '${summary.healthyPercentage.toStringAsFixed(0)}%',
                color: _getHealthColor(summary.healthyPercentage),
                subtitle: isRtl
                    ? '${summary.healthyCount} منتج سليم'
                    : '${summary.healthyCount} healthy',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getHealthColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
