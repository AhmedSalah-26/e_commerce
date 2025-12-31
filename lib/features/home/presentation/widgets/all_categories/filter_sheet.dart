import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../categories/domain/entities/category_entity.dart';

class AllCategoriesFilterSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final Function(String?, RangeValues) onApply;

  const AllCategoriesFilterSheet({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<AllCategoriesFilterSheet> createState() =>
      _AllCategoriesFilterSheetState();
}

class _AllCategoriesFilterSheetState extends State<AllCategoriesFilterSheet> {
  late String? _selectedCategoryId;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _priceRange = widget.priceRange;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(theme),
            const SizedBox(height: 20),
            _buildHeader(theme),
            const SizedBox(height: 20),
            _buildCategoryFilter(theme),
            const SizedBox(height: 24),
            _buildPriceFilter(theme),
            const SizedBox(height: 24),
            _buildApplyButton(theme),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'filters'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            _selectedCategoryId = null;
            _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
          }),
          child:
              Text('clear_all'.tr(), style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'categories'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCategoryChip(
                  'all'.tr(),
                  _selectedCategoryId == null,
                  () => setState(() => _selectedCategoryId = null),
                  theme,
                );
              }
              final category = widget.categories[index - 1];
              return _buildCategoryChip(
                category.name,
                _selectedCategoryId == category.id,
                () => setState(() => _selectedCategoryId = category.id),
                theme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
      String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.primary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'price'.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_priceRange.start.toInt()} ${'egp'.tr()}'),
            Text('${_priceRange.end.toInt()} ${'egp'.tr()}'),
          ],
        ),
        RangeSlider(
          values: _priceRange,
          min: widget.minPrice,
          max: widget.maxPrice,
          divisions: 100,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.outline.withValues(alpha: 0.3),
          onChanged: (values) => setState(() => _priceRange = values),
        ),
      ],
    );
  }

  Widget _buildApplyButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => widget.onApply(_selectedCategoryId, _priceRange),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('apply'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
