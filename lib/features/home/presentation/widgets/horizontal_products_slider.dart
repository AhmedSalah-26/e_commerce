import 'package:flutter/material.dart';

import '../../../../core/shared_widgets/section_header.dart';
import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../products/domain/entities/product_entity.dart';

class HorizontalProductsSlider extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<ProductEntity> products;
  final bool isLoading;
  final Color? backgroundColor;
  final VoidCallback? onViewAll;

  const HorizontalProductsSlider({
    super.key,
    required this.title,
    this.subtitle,
    required this.products,
    this.isLoading = false,
    this.backgroundColor,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildSkeleton(theme);
    }

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Section header with capsule "عرض الكل <" button
          SectionHeader(
            title: title,
            subtitle: subtitle,
            onViewAll: onViewAll,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          ),
          SizedBox(
            height: 195,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              itemCount: products.length,
              addAutomaticKeepAlives: false,
              addRepaintBoundaries: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: SizedBox(
                    width: 88,
                    child: ProductGridCard(
                        product: products[index], compact: true),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              width: 120,
              height: 22,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(
            height: 195,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 88,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
