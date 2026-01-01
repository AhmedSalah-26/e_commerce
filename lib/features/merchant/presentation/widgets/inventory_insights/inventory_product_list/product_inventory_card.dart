import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../domain/entities/inventory_insight_entity.dart';
import 'product_inventory_image.dart';
import 'product_inventory_info.dart';
import 'product_inventory_stats.dart';
import 'product_reorder_suggestion.dart';
import 'product_sell_through_rate.dart';

class ProductInventoryCard extends StatelessWidget {
  final ProductInventoryDetail product;
  final bool isRtl;

  const ProductInventoryCard({
    super.key,
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
                ProductInventoryImage(image: product.image),
                const SizedBox(width: 12),
                Expanded(
                  child: ProductInventoryInfo(
                    product: product,
                    locale: locale,
                    isRtl: isRtl,
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ProductInventoryStats(
              product: product,
              isRtl: isRtl,
            ),
            if (product.needsReorder)
              ProductReorderSuggestion(
                suggestedQty: product.suggestedReorderQty,
                isRtl: isRtl,
              ),
            const SizedBox(height: 12),
            ProductSellThroughRate(
              rate: product.sellThroughRate,
              isRtl: isRtl,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}
