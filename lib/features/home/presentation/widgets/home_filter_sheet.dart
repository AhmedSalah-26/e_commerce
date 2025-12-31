import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../products/domain/enums/sort_option.dart';

class HomeFilterSheet extends StatefulWidget {
  final String? initialCategoryId;
  final RangeValues initialPriceRange;
  final double minPrice;
  final double maxPrice;
  final SortOption initialSortOption;
  final Function(String?, RangeValues, SortOption) onApply;

  const HomeFilterSheet({
    super.key,
    required this.initialCategoryId,
    required this.initialPriceRange,
    required this.minPrice,
    required this.maxPrice,
    this.initialSortOption = SortOption.newest,
    required this.onApply,
  });

  @override
  State<HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<HomeFilterSheet> {
  late String? tempCategoryId;
  late RangeValues tempPriceRange;
  late SortOption tempSortOption;

  @override
  void initState() {
    super.initState();
    tempCategoryId = widget.initialCategoryId;
    tempPriceRange = widget.initialPriceRange;
    tempSortOption = widget.initialSortOption;
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
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('filters'.tr(),
                    style: AppTextStyle.semiBold_20_dark_brown.copyWith(
                      color: theme.colorScheme.onSurface,
                    )),
                TextButton(
                  onPressed: () {
                    setState(() {
                      tempCategoryId = null;
                      tempPriceRange =
                          RangeValues(widget.minPrice, widget.maxPrice);
                      tempSortOption = SortOption.newest;
                    });
                  },
                  child: Text('clear_all'.tr(),
                      style: const TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Sort options
            Text('sort_by'.tr(),
                style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
            const SizedBox(height: 12),
            _buildSortOptions(theme),
            const SizedBox(height: 24),
            // Category filter
            Text('categories'.tr(),
                style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
            const SizedBox(height: 12),
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoaded) {
                  return SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        final isSelected = tempCategoryId == category.id;
                        return _buildCategoryChip(
                          category.name,
                          isSelected,
                          theme,
                          () {
                            setState(() {
                              // Toggle selection - tap again to deselect
                              if (isSelected) {
                                tempCategoryId = null;
                              } else {
                                tempCategoryId = category.id;
                              }
                            });
                          },
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),
            // Price filter
            Text('price'.tr(),
                style: AppTextStyle.semiBold_16_dark_brown.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${tempPriceRange.start.toInt()} ${'egp'.tr()}',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
                Text('${tempPriceRange.end.toInt()} ${'egp'.tr()}',
                    style: TextStyle(color: theme.colorScheme.onSurface)),
              ],
            ),
            RangeSlider(
              values: tempPriceRange,
              min: widget.minPrice,
              max: widget.maxPrice,
              divisions: 100,
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.outline,
              onChanged: (values) {
                setState(() => tempPriceRange = values);
              },
            ),
            const SizedBox(height: 24),
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                      tempCategoryId, tempPriceRange, tempSortOption);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('apply'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOptions(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SortOption.values.map((option) {
        final isSelected = tempSortOption == option;
        return GestureDetector(
          onTap: () => setState(() => tempSortOption = option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Text(
              option.translationKey.tr(),
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.primary,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChip(
      String label, bool isSelected, ThemeData theme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
