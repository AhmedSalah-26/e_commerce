import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildSearchField(),
            _buildCategoriesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColours.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Text(
            widget.isRtl ? 'اختر التصنيف' : 'Select Category',
            style: AppTextStyle.semiBold_18_white,
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

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: widget.isRtl ? 'البحث عن تصنيف...' : 'Search category...',
          prefixIcon: const Icon(Icons.search, color: AppColours.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColours.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColours.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColours.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    return Flexible(
      child: ListView(
        shrinkWrap: true,
        children: [
          _buildAllCategoriesOption(),
          const Divider(height: 1),
          ..._filteredCategories.map(_buildCategoryItem),
        ],
      ),
    );
  }

  Widget _buildAllCategoriesOption() {
    final isSelected = widget.selectedCategoryId == null;
    return ListTile(
      leading: const Icon(Icons.all_inclusive, color: AppColours.primary),
      title: Text(
        widget.isRtl ? 'جميع التصنيفات' : 'All Categories',
        style: TextStyle(
          color: isSelected ? AppColours.primary : AppColours.greyDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColours.primary)
          : null,
      onTap: () {
        widget.onCategorySelected(null);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCategoryItem(CategoryEntity category) {
    final isSelected = widget.selectedCategoryId == category.id;
    return ListTile(
      leading: Icon(
        Icons.category,
        color: isSelected ? AppColours.primary : AppColours.greyDark,
      ),
      title: Text(
        category.name,
        style: TextStyle(
          color: isSelected ? AppColours.primary : AppColours.greyDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColours.primary)
          : null,
      onTap: () {
        widget.onCategorySelected(category.id);
        Navigator.pop(context);
      },
    );
  }
}
