import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category_entity.dart';

class InventoryFilters extends StatelessWidget {
  final bool isRtl;
  final TextEditingController searchController;
  final String searchQuery;
  final String activityFilter;
  final String? selectedCategoryId;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onActivityFilterChanged;
  final VoidCallback onCategoryTap;

  const InventoryFilters({
    super.key,
    required this.isRtl,
    required this.searchController,
    required this.searchQuery,
    required this.activityFilter,
    required this.selectedCategoryId,
    required this.categories,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onActivityFilterChanged,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildSearchBar(theme),
          const SizedBox(height: 12),
          _buildActivityChips(theme),
          const SizedBox(height: 12),
          _buildCategorySelector(theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: isRtl ? 'البحث عن منتج...' : 'Search products...',
        prefixIcon: Icon(Icons.search,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                onPressed: onClearSearch,
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActivityChips(ThemeData theme) {
    return Row(
      children: [
        _buildActivityChip(isRtl ? 'الكل' : 'All', 'all', theme),
        const SizedBox(width: 8),
        _buildActivityChip(isRtl ? 'نشط' : 'Active', 'active', theme),
        const SizedBox(width: 8),
        _buildActivityChip(isRtl ? 'غير نشط' : 'Inactive', 'inactive', theme),
      ],
    );
  }

  Widget _buildActivityChip(String label, String value, ThemeData theme) {
    final isSelected = activityFilter == value;
    Color chipColor;
    if (value == 'active') {
      chipColor = Colors.green;
    } else if (value == 'inactive') {
      chipColor = Colors.grey;
    } else {
      chipColor = theme.colorScheme.primary;
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onActivityFilterChanged(value),
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: theme.colorScheme.primary, width: 1),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    final selectedCategory = selectedCategoryId != null
        ? categories.where((c) => c.id == selectedCategoryId).firstOrNull
        : null;

    return GestureDetector(
      onTap: onCategoryTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Row(
          children: [
            Icon(Icons.category_outlined,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCategory?.name ??
                    (isRtl ? 'جميع التصنيفات' : 'All Categories'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
