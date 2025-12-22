import 'package:flutter/material.dart';

import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../products/domain/entities/product_entity.dart';

/// Optimized ProductsGrid with proper caching and minimal rebuilds
class ProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductsGrid({super.key, required this.products});

  // Fixed item height for better scroll performance
  static const double _itemHeight = 340.0;
  static const double _itemWidth = 180.0;
  static const double _aspectRatio = _itemWidth / _itemHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        clipBehavior: Clip.none,
        // Use prototypeItem for better performance estimation
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: _aspectRatio,
        ),
        itemCount: products.length,
        // Add cacheExtent for smoother scrolling
        cacheExtent: _itemHeight * 2,
        // Use addAutomaticKeepAlives and addRepaintBoundaries for optimization
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        itemBuilder: (context, index) {
          final product = products[index];
          // Use RepaintBoundary to isolate repaints
          return RepaintBoundary(
            child: ProductGridCard(
              key: ValueKey(product.id),
              product: product,
            ),
          );
        },
      ),
    );
  }
}

/// Sliver version for use in CustomScrollView - better for large lists
class ProductsGridSliver extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductsGridSliver({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: ProductsGrid._aspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return RepaintBoundary(
              child: ProductGridCard(
                key: ValueKey(product.id),
                product: product,
              ),
            );
          },
          childCount: products.length,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }
}
