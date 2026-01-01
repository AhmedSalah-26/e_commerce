import 'package:flutter/material.dart';

import '../../../domain/entities/inventory_insight_entity.dart';
import 'product_inventory_card.dart';

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
          (context, index) => ProductInventoryCard(
            product: products[index],
            isRtl: isRtl,
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}
