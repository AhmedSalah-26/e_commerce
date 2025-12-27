import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/product_card/product_grid_card.dart';
import '../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../products/domain/entities/product_entity.dart';

class HomeSearchContent extends StatelessWidget {
  final bool isSearching;
  final String currentQuery;
  final List<ProductEntity> searchResults;
  final bool isLoadingMore;
  final bool hasMore;
  final bool hasActiveFilters;
  final void Function(String categoryId, String categoryName)? onCategoryTap;

  const HomeSearchContent({
    super.key,
    required this.isSearching,
    required this.currentQuery,
    required this.searchResults,
    required this.isLoadingMore,
    required this.hasMore,
    this.hasActiveFilters = false,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSearching) return const ProductsGridSkeleton(itemCount: 4);

    if (currentQuery.isEmpty && searchResults.isEmpty && !hasActiveFilters) {
      return _CategoriesGrid(onCategoryTap: onCategoryTap);
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 80,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                currentQuery.isNotEmpty
                    ? '${'no_results_for'.tr()} "$currentQuery"'
                    : 'no_products'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${'search_results'.tr()} (${searchResults.length})',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: searchResults.length,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              return RepaintBoundary(
                child: ProductGridCard(
                    key: ValueKey(searchResults[index].id),
                    product: searchResults[index]),
              );
            },
          ),
        ),
        if (isLoadingMore)
          const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator())),
        if (!hasMore && searchResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Text('no_more_results'.tr(),
                    style: const TextStyle(color: Colors.grey))),
          ),
      ],
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final void Function(String categoryId, String categoryName)? onCategoryTap;

  const _CategoriesGrid({this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'categories'.tr(),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CategoriesRowSkeleton(),
                ),
              );
            }

            if (state is CategoriesLoaded) {
              final categories =
                  state.categories.where((c) => c.isActive).toList();

              if (categories.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('no_categories'.tr(),
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  addAutomaticKeepAlives: false,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryCard(
                      key: ValueKey(category.id),
                      category: category,
                      onTap: () =>
                          onCategoryTap?.call(category.id, category.name),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback? onTap;

  const _CategoryCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: category.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        memCacheWidth: 150,
                        memCacheHeight: 150,
                        placeholder: (_, __) => Container(
                          color: theme.scaffoldBackgroundColor,
                          child: const Icon(Icons.category,
                              size: 40, color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.scaffoldBackgroundColor,
                          child: const Icon(Icons.category,
                              size: 40, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: theme.scaffoldBackgroundColor,
                        child: const Icon(Icons.category,
                            size: 40, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                category.name,
                style: theme.textTheme.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
