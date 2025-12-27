import 'package:flutter/material.dart';

class InventoryHeader extends StatelessWidget {
  final bool isRtl;
  final int totalProducts;
  final int activeProducts;
  final VoidCallback onAddProduct;

  const InventoryHeader({
    super.key,
    required this.isRtl,
    required this.totalProducts,
    required this.activeProducts,
    required this.onAddProduct,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRtl ? 'إدارة المخزون' : 'Manage Inventory',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(isRtl ? 'المنتجات' : 'Products',
                      totalProducts.toString(), Icons.inventory_2)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(isRtl ? 'المنتجات النشطة' : 'Active',
                      activeProducts.toString(), Icons.check_circle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
