import 'package:flutter/material.dart';

import '../../../domain/entities/inventory_insight_entity.dart';
import 'stat_item.dart';

class ProductInventoryStats extends StatelessWidget {
  final ProductInventoryDetail product;
  final bool isRtl;

  const ProductInventoryStats({
    super.key,
    required this.product,
    required this.isRtl,
  });

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    return Colors.green;
  }

  Color _getDaysColor(int days) {
    if (days <= 7) return Colors.red;
    if (days <= 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatItem(
          icon: Icons.inventory,
          label: isRtl ? 'المخزون' : 'Stock',
          value: '${product.stock}',
          color: _getStockColor(product.stock),
        ),
        StatItem(
          icon: Icons.shopping_cart,
          label: isRtl ? 'المبيعات' : 'Sales',
          value: '${product.salesLastPeriod}',
          subtitle: isRtl ? '30 يوم' : '30d',
          color: Colors.blue,
        ),
        StatItem(
          icon: Icons.speed,
          label: isRtl ? 'معدل الدوران' : 'Turnover',
          value: '${product.turnoverRate}x',
          color: Colors.purple,
        ),
        StatItem(
          icon: Icons.calendar_today,
          label: isRtl ? 'أيام متبقية' : 'Days Left',
          value: product.daysOfStock >= 999 ? '∞' : '${product.daysOfStock}',
          color: _getDaysColor(product.daysOfStock),
        ),
      ],
    );
  }
}
