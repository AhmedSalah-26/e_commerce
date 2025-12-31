import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:toastification/toastification.dart';
import '../../../domain/entities/inventory_insight_entity.dart';

class InventoryProductList extends StatelessWidget {
  final List<ProductInventoryDetail> products;
  final bool isRtl;

  const InventoryProductList({
    super.key,
    required this.products,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  isRtl ? 'لا توجد منتجات' : 'No products found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ProductInventoryCard(
            product: products[index],
            isRtl: isRtl,
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}

class _ProductInventoryCard extends StatelessWidget {
  final ProductInventoryDetail product;
  final bool isRtl;

  const _ProductInventoryCard({
    required this.product,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = context.locale.languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.image != null
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child:
                              const Icon(Icons.inventory_2, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.getName(locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusBadge(
                            status: product.stockStatus,
                            isRtl: isRtl,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Product ID - copyable
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: product.id));
                          toastification.show(
                            context: context,
                            title: Text('product_id_copied'.tr()),
                            type: ToastificationType.success,
                            autoCloseDuration: const Duration(seconds: 2),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.copy,
                              size: 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'ID: ${product.id.length > 8 ? '${product.id.substring(0, 8)}...' : product.id}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.effectivePrice.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            // Stats Row
            Row(
              children: [
                _StatItem(
                  icon: Icons.inventory,
                  label: isRtl ? 'المخزون' : 'Stock',
                  value: '${product.stock}',
                  color: _getStockColor(product.stock),
                ),
                _StatItem(
                  icon: Icons.shopping_cart,
                  label: isRtl ? 'المبيعات' : 'Sales',
                  value: '${product.salesLastPeriod}',
                  subtitle: isRtl ? '30 يوم' : '30d',
                  color: Colors.blue,
                ),
                _StatItem(
                  icon: Icons.speed,
                  label: isRtl ? 'معدل الدوران' : 'Turnover',
                  value: '${product.turnoverRate}x',
                  color: Colors.purple,
                ),
                _StatItem(
                  icon: Icons.calendar_today,
                  label: isRtl ? 'أيام متبقية' : 'Days Left',
                  value: product.daysOfStock >= 999
                      ? '∞'
                      : '${product.daysOfStock}',
                  color: _getDaysColor(product.daysOfStock),
                ),
              ],
            ),
            // Reorder suggestion
            if (product.needsReorder) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isRtl
                            ? 'اقتراح: اطلب ${product.suggestedReorderQty} وحدة'
                            : 'Suggestion: Reorder ${product.suggestedReorderQty} units',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Sell-through rate bar
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isRtl ? 'معدل البيع' : 'Sell-through Rate',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${product.sellThroughRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getSellThroughColor(product.sellThroughRate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: product.sellThroughRate / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getSellThroughColor(product.sellThroughRate),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Color _getSellThroughColor(double rate) {
    if (rate >= 70) return Colors.green;
    if (rate >= 40) return Colors.orange;
    return Colors.red;
  }
}

class _StatusBadge extends StatelessWidget {
  final StockStatus status;
  final bool isRtl;

  const _StatusBadge({required this.status, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo() {
    switch (status) {
      case StockStatus.outOfStock:
        return (isRtl ? 'نفذ' : 'Out', Colors.red);
      case StockStatus.lowStock:
        return (isRtl ? 'منخفض' : 'Low', Colors.orange);
      case StockStatus.deadStock:
        return (isRtl ? 'راكد' : 'Dead', Colors.grey);
      case StockStatus.overstock:
        return (isRtl ? 'فائض' : 'Over', Colors.purple);
      case StockStatus.healthy:
        return (isRtl ? 'سليم' : 'OK', Colors.green);
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 9,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
        ],
      ),
    );
  }
}
