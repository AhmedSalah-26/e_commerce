import 'package:flutter/material.dart';

import '../../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../../products/domain/entities/product_entity.dart';

/// Products grid for all categories page
class CategoryProductsGrid extends StatelessWidget {
  final List<ProductEntity> products;
  final ScrollController scrollController;
  final bool isLoadingMore;

  const CategoryProductsGrid({
    super.key,
    required this.products,
    required this.scrollController,
    this.isLoadingMore = false,
  });

  static const double _itemHeight = 340.0;
  static const double _itemWidth = 180.0;
  static const double _aspectRatio = _itemWidth / _itemHeight;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Handled by parent
      },
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Products grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: _aspectRatio,
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
          ),

          // Loading more indicator
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
