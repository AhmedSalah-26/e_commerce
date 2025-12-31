import 'package:flutter/material.dart';

import '../../../../categories/domain/entities/category_entity.dart';

class CategoriesHeader extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final bool darkMode;

  const CategoriesHeader({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategoryId == category.id;

            return _CategoryItem(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category.id),
              darkMode: darkMode,
            );
          },
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool darkMode;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor =
        darkMode ? const Color(0xFFD4A574) : theme.colorScheme.primary;
    final textColor = darkMode ? Colors.white : theme.colorScheme.onSurface;
    // Use darker background for category containers in darkMode
    final containerBg =
        darkMode ? const Color(0xFF1A1A1A) : theme.colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.15)
                    : containerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : (darkMode
                          ? Colors.white
                          : theme.colorScheme.outline.withValues(alpha: 0.2)),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    category.imageUrl != null && category.imageUrl!.isNotEmpty
                        ? Image.network(
                            category.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.category,
                              size: 28,
                              color: primaryColor,
                            ),
                          )
                        : Icon(
                            Icons.category,
                            size: 28,
                            color: isSelected
                                ? primaryColor
                                : textColor.withValues(alpha: 0.6),
                          ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
