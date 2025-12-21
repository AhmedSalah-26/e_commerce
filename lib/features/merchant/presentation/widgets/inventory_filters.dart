import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColours.greyLighter,
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildActivityChips(),
          const SizedBox(height: 12),
          _buildCategorySelector(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: isRtl ? 'البحث عن منتج...' : 'Search products...',
        prefixIcon: const Icon(Icons.search, color: AppColours.greyDark),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColours.greyDark),
                onPressed: onClearSearch,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildActivityChips() {
    return Row(
      children: [
        _buildActivityChip(isRtl ? 'الكل' : 'All', 'all'),
        const SizedBox(width: 8),
        _buildActivityChip(isRtl ? 'نشط' : 'Active', 'active'),
        const SizedBox(width: 8),
        _buildActivityChip(isRtl ? 'غير نشط' : 'Inactive', 'inactive'),
      ],
    );
  }

  Widget _buildActivityChip(String label, String value) {
    final isSelected = activityFilter == value;
    Color chipColor;
    if (value == 'active') {
      chipColor = Colors.green;
    } else if (value == 'inactive') {
      chipColor = Colors.grey;
    } else {
      chipColor = AppColours.primary;
    }

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onActivityFilterChanged(value),
      selectedColor: chipColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColours.greyDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColours.primary, width: 1),
    );
  }

  Widget _buildCategorySelector() {
    final selectedCategory = selectedCategoryId != null
        ? categories.where((c) => c.id == selectedCategoryId).firstOrNull
        : null;

    return GestureDetector(
      onTap: onCategoryTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColours.primary),
        ),
        child: Row(
          children: [
            const Icon(Icons.category_outlined,
                color: AppColours.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCategory?.name ??
                    (isRtl ? 'جميع التصنيفات' : 'All Categories'),
                style: const TextStyle(color: AppColours.greyDark),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColours.primary),
          ],
        ),
      ),
    );
  }
}
