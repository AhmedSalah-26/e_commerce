import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/domain/entities/category_entity.dart';

class HorizontalCategoriesView extends StatelessWidget {
  final Function(String?) onCategorySelected;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;

  const HorizontalCategoriesView({
    required this.onCategorySelected,
    required this.categories,
    this.selectedCategoryId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? 16.0 : 8.0;

    return SizedBox(
      height: 50,
      width: screenWidth,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: CategoryCard(
                title: 'all_products'.tr(),
                isSelected: selectedCategoryId == null,
                onPressed: () => onCategorySelected(null),
              ),
            );
          }
          final category = categories[index - 1];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: CategoryCard(
              title: category.name,
              isSelected: selectedCategoryId == category.id,
              onPressed: () => onCategorySelected(category.id),
            ),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryCard({
    required this.title,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textStyle = screenWidth > 600
        ? AppTextStyle.normal_18_brownLight
        : AppTextStyle.normal_16_brownLight;

    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: AppColours.greyLighter,
      ),
      child: TextButton(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: isSelected ? textStyle : AppTextStyle.normal_16_greyDark,
        ),
      ),
    );
  }
}
