import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialCategoryId;
  final RangeValues initialPriceRange;
  final double minPrice;
  final double maxPrice;
  final Function(String?, RangeValues) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialCategoryId,
    required this.initialPriceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedCategoryId;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _priceRange = widget.initialPriceRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildCategoryFilter(),
            const SizedBox(height: 24),
            _buildPriceFilter(),
            const SizedBox(height: 24),
            _buildApplyButton(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('filters'.tr(), style: AppTextStyle.semiBold_20_dark_brown),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategoryId = null;
              _priceRange = RangeValues(widget.minPrice, widget.maxPrice);
            });
          },
          child:
              Text('clear_all'.tr(), style: const TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('categories'.tr(), style: AppTextStyle.semiBold_16_dark_brown),
        const SizedBox(height: 12),
        BlocBuilder<CategoriesCubit, CategoriesState>(
          builder: (context, state) {
            if (state is CategoriesLoaded) {
              return SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCategoryChip(
                        'all'.tr(),
                        _selectedCategoryId == null,
                        () => setState(() => _selectedCategoryId = null),
                      );
                    }
                    final category = state.categories[index - 1];
                    return _buildCategoryChip(
                      category.name,
                      _selectedCategoryId == category.id,
                      () => setState(() => _selectedCategoryId = category.id),
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

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColours.brownLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColours.brownLight),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColours.brownLight,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('price'.tr(), style: AppTextStyle.semiBold_16_dark_brown),
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
          activeColor: AppColours.brownLight,
          inactiveColor: AppColours.greyLight,
          onChanged: (values) {
            setState(() => _priceRange = values);
          },
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          widget.onApply(_selectedCategoryId, _priceRange);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColours.brownLight,
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
