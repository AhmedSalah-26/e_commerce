import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../categories/domain/entities/category_entity.dart';

/// Enum for home tab types
enum HomeTabType {
  bestSellers,
  topRated,
  allProducts,
  offers,
  more,
}

class HorizontalCategoriesView extends StatelessWidget {
  final Function(String?) onCategorySelected;
  final VoidCallback? onOffersSelected;
  final VoidCallback? onBestSellersSelected;
  final VoidCallback? onTopRatedSelected;
  final VoidCallback? onAllProductsSelected;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final bool isOffersSelected;
  final bool isBestSellersSelected;
  final bool isTopRatedSelected;
  final bool isAllProductsSelected;

  const HorizontalCategoriesView({
    required this.onCategorySelected,
    this.onOffersSelected,
    this.onBestSellersSelected,
    this.onTopRatedSelected,
    this.onAllProductsSelected,
    required this.categories,
    this.selectedCategoryId,
    this.isOffersSelected = false,
    this.isBestSellersSelected = false,
    this.isTopRatedSelected = false,
    this.isAllProductsSelected = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 16.0 : 6.0;

    final tabs = [
      _TabItem(
        type: HomeTabType.bestSellers,
        title: 'best_sellers'.tr(),
        icon: Icons.trending_up,
        isSelected: isBestSellersSelected,
        onTap: () => onBestSellersSelected?.call(),
      ),
      _TabItem(
        type: HomeTabType.topRated,
        title: 'top_rated'.tr(),
        icon: Icons.star,
        isSelected: isTopRatedSelected,
        onTap: () => onTopRatedSelected?.call(),
      ),
      _TabItem(
        type: HomeTabType.allProducts,
        title: 'all_products'.tr(),
        icon: Icons.grid_view,
        isSelected: isAllProductsSelected,
        onTap: () => onAllProductsSelected?.call(),
      ),
      _TabItem(
        type: HomeTabType.offers,
        title: 'offers'.tr(),
        icon: Icons.local_offer,
        isSelected: isOffersSelected,
        onTap: () => onOffersSelected?.call(),
      ),
      _TabItem(
        type: HomeTabType.more,
        title: 'more'.tr(),
        icon: Icons.more_horiz,
        isSelected: false,
        onTap: () => _openCategoriesPage(context),
      ),
    ];

    return SizedBox(
      height: 50,
      width: screenWidth,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        addAutomaticKeepAlives: false,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: CategoryCard(
              title: tab.title,
              isSelected: tab.isSelected,
              onPressed: tab.onTap,
              icon: tab.icon,
              isSpecial: tab.type == HomeTabType.offers ||
                  tab.type == HomeTabType.more,
            ),
          );
        },
      ),
    );
  }

  void _openCategoriesPage(BuildContext context) {
    context.push('/all-categories');
  }
}

class _TabItem {
  final HomeTabType type;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  _TabItem({
    required this.type,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
}

class CategoryCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isSpecial;

  const CategoryCard({
    required this.title,
    required this.isSelected,
    required this.onPressed,
    this.icon,
    this.isSpecial = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth > 600 ? 16.0 : 14.0;

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextButton(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
          minimumSize: WidgetStateProperty.all(Size.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet showing all categories
class CategoriesBottomSheet extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoriesBottomSheet({
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.category, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'all_categories'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategoryId == category.id;

                return InkWell(
                  onTap: () => onCategorySelected(category.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (category.imageUrl != null &&
                            category.imageUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              category.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.category,
                                size: 32,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.category,
                            size: 32,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                          ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
