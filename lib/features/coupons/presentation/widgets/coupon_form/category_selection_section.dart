import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../categories/domain/entities/category_entity.dart';

class CategorySelectionSection extends StatelessWidget {
  final List<String> selectedCategoryIds;
  final List<CategoryEntity> categories;
  final VoidCallback onSelectCategories;
  final ValueChanged<String> onRemoveCategory;

  const CategorySelectionSection({
    super.key,
    required this.selectedCategoryIds,
    required this.categories,
    required this.onSelectCategories,
    required this.onRemoveCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('selected_categories'.tr(),
                style: const TextStyle(fontWeight: FontWeight.w500)),
            TextButton.icon(
              onPressed: onSelectCategories,
              icon: const Icon(Icons.add, size: 18),
              label: Text('select_categories'.tr()),
              style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selectedCategoryIds.isEmpty)
          _EmptySelectionBox(message: 'no_categories_selected'.tr())
        else
          _SelectedCategoriesList(
            categoryIds: selectedCategoryIds,
            categories: categories,
            onRemove: onRemoveCategory,
          ),
      ],
    );
  }
}

class _EmptySelectionBox extends StatelessWidget {
  final String message;

  const _EmptySelectionBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 18),
          const SizedBox(width: 8),
          Text(message,
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

class _SelectedCategoriesList extends StatelessWidget {
  final List<String> categoryIds;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onRemove;

  const _SelectedCategoriesList({
    required this.categoryIds,
    required this.categories,
    required this.onRemove,
  });

  CategoryEntity? _findCategory(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: categoryIds.length,
        itemBuilder: (context, index) {
          final categoryId = categoryIds[index];
          final category = _findCategory(categoryId);
          if (category == null) return const SizedBox.shrink();

          return ListTile(
            dense: true,
            leading: category.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      category.imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PlaceholderIcon(),
                    ),
                  )
                : _PlaceholderIcon(),
            title: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => onRemove(categoryId),
            ),
          );
        },
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.category, size: 20),
    );
  }
}
