import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../products/domain/entities/product_entity.dart';

class SearchResultsWidget extends StatelessWidget {
  final bool isSearching;
  final String currentQuery;
  final List<ProductEntity> searchResults;
  final bool isLoadingMore;
  final bool hasMore;

  const SearchResultsWidget({
    super.key,
    required this.isSearching,
    required this.currentQuery,
    required this.searchResults,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSearching) {
      return const SliverToBoxAdapter(
        child: ProductsGridSkeleton(itemCount: 4),
      );
    }

    if (currentQuery.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'search_products'.tr(),
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 400,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  '${'no_results_for'.tr()} "$currentQuery"',
                  style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${'search_results'.tr()} (${searchResults.length})',
              style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return ProductGridCard(product: searchResults[index]);
              },
            ),
          ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!hasMore && searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'no_more_results'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
