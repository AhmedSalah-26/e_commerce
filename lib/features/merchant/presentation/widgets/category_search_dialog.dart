import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category_entity.dart';

class CategorySearchDialog extends StatefulWidget {
  final bool isRtl;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const CategorySearchDialog({
    super.key,
    required this.isRtl,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  static Future<void> show({
    required BuildContext context,
    required bool isRtl,
    required List<CategoryEntity> categories,
    required String? selectedCategoryId,
    required ValueChanged<String?> onCategorySelected,
  }) {
    return showDialog(
      context: context,
      builder: (_) => CategorySearchDialog(
        isRtl: isRtl,
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        onCategorySelected: onCategorySelected,
      ),
    );
  }

  @override
  State<CategorySearchDialog> createState() => _CategorySearchDialogState();
}

class _CategorySearchDialogState extends State<CategorySearchDialog> {
  String _searchQuery = '';

  List<CategoryEntity> get _filteredCategories {
    if (_searchQuery.isEmpty) return widget.categories;
    return widget.categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            _buildSearchField(theme),
            _buildCategoriesList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Text(
            widget.isRtl ? 'اختر التصنيف' : 'Select Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: widget.isRtl ? 'البحث عن تصنيف...' : 'Search category...',
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(ThemeData theme) {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: [
          _buildAllCategoriesOption(theme),
          const Divider(height: 1),
          ..._filteredCategories.map((c) => _buildCategoryItem(c, theme)),
        ],
      ),
    );
  }

  Widget _buildAllCategoriesOption(ThemeData theme) {
    final isSelected = widget.selectedCategoryId == null;
    return ListTile(
      leading: Icon(Icons.all_inclusive, color: theme.colorScheme.primary),
      title: Text(
        widget.isRtl ? 'جميع التصنيفات' : 'All Categories',
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        widget.onCategorySelected(null);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCategoryItem(CategoryEntity category, ThemeData theme) {
    final isSelected = widget.selectedCategoryId == category.id;
    return ListTile(
      leading: Icon(
        Icons.category,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
      title: Text(
        category.name,
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        widget.onCategorySelected(category.id);
        Navigator.pop(context);
      },
    );
  }
}
