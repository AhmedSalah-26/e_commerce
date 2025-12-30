import 'package:flutter/material.dart';
import '../../../domain/entities/inventory_insight_entity.dart';

class InventoryAlertsSection extends StatelessWidget {
  final InventoryInsightsSummary summary;
  final bool isRtl;
  final Function(String) onFilterTap;
  final String currentFilter;

  const InventoryAlertsSection({
    super.key,
    required this.summary,
    required this.isRtl,
    required this.onFilterTap,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 20),
            const SizedBox(width: 8),
            Text(
              isRtl ? 'تنبيهات المخزون' : 'Stock Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (summary.alertsCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${summary.alertsCount} ${isRtl ? 'تنبيه' : 'alerts'}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _AlertChip(
                label: isRtl ? 'الكل' : 'All',
                count: summary.totalProducts,
                color: theme.colorScheme.primary,
                isSelected: currentFilter == 'all',
                onTap: () => onFilterTap('all'),
              ),
              const SizedBox(width: 8),
              _AlertChip(
                label: isRtl ? 'نفذ' : 'Out',
                count: summary.outOfStockCount,
                color: Colors.red,
                isSelected: currentFilter == 'out_of_stock',
                onTap: () => onFilterTap('out_of_stock'),
              ),
              const SizedBox(width: 8),
              _AlertChip(
                label: isRtl ? 'منخفض' : 'Low',
                count: summary.lowStockCount,
                color: Colors.orange,
                isSelected: currentFilter == 'low_stock',
                onTap: () => onFilterTap('low_stock'),
              ),
              const SizedBox(width: 8),
              _AlertChip(
                label: isRtl ? 'راكد' : 'Dead',
                count: summary.deadStockCount,
                color: Colors.grey,
                isSelected: currentFilter == 'dead_stock',
                onTap: () => onFilterTap('dead_stock'),
              ),
              const SizedBox(width: 8),
              _AlertChip(
                label: isRtl ? 'فائض' : 'Over',
                count: summary.overstockCount,
                color: Colors.purple,
                isSelected: currentFilter == 'overstock',
                onTap: () => onFilterTap('overstock'),
              ),
            ],
          ),
        ),
        if (summary.alertsCount > 0) ...[
          const SizedBox(height: 16),
          _buildAlertsList(theme),
        ],
      ],
    );
  }

  Widget _buildAlertsList(ThemeData theme) {
    final alerts = <_AlertInfo>[];

    if (summary.outOfStockCount > 0) {
      alerts.add(_AlertInfo(
        icon: Icons.remove_shopping_cart,
        color: Colors.red,
        title: isRtl ? 'نفاد المخزون' : 'Out of Stock',
        subtitle: isRtl
            ? '${summary.outOfStockCount} منتج نفذ من المخزون'
            : '${summary.outOfStockCount} products out of stock',
        severity: 3,
      ));
    }

    if (summary.lowStockCount > 0) {
      alerts.add(_AlertInfo(
        icon: Icons.trending_down,
        color: Colors.orange,
        title: isRtl ? 'مخزون منخفض' : 'Low Stock',
        subtitle: isRtl
            ? '${summary.lowStockCount} منتج يحتاج إعادة طلب'
            : '${summary.lowStockCount} products need reorder',
        severity: 2,
      ));
    }

    if (summary.deadStockCount > 0) {
      alerts.add(_AlertInfo(
        icon: Icons.inventory,
        color: Colors.grey,
        title: isRtl ? 'مخزون راكد' : 'Dead Stock',
        subtitle: isRtl
            ? '${summary.deadStockCount} منتج لم يُبع منذ 90 يوم'
            : '${summary.deadStockCount} products not sold in 90 days',
        severity: 1,
      ));
    }

    if (summary.overstockCount > 0) {
      alerts.add(_AlertInfo(
        icon: Icons.warehouse,
        color: Colors.purple,
        title: isRtl ? 'فائض مخزون' : 'Overstock',
        subtitle: isRtl
            ? '${summary.overstockCount} منتج مخزون عالي ومبيعات قليلة'
            : '${summary.overstockCount} products with high stock, low sales',
        severity: 1,
      ));
    }

    alerts.sort((a, b) => b.severity.compareTo(a.severity));

    return Column(
      children: alerts
          .map((alert) => _AlertTile(alert: alert, theme: theme))
          .toList(),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlertChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.3)
                    : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int severity;

  const _AlertInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.severity,
  });
}

class _AlertTile extends StatelessWidget {
  final _AlertInfo alert;
  final ThemeData theme;

  const _AlertTile({required this.alert, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alert.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: alert.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(alert.icon, color: alert.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: alert.color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
