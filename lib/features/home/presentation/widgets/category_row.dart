import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../categories/domain/entities/category_entity.dart';

class HorizontalCategoriesView extends StatelessWidget {
  final Function(String?) onCategorySelected;
  final VoidCallback? onOffersSelected;
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final bool isOffersSelected;

  const HorizontalCategoriesView({
    required this.onCategorySelected,
    this.onOffersSelected,
    required this.categories,
    this.selectedCategoryId,
    this.isOffersSelected = false,
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
        addAutomaticKeepAlives: false,
        itemCount: categories.length + 2, // +2 for "All" and "Offers"
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: CategoryCard(
                title: 'all_products'.tr(),
                isSelected: selectedCategoryId == null && !isOffersSelected,
                onPressed: () => onCategorySelected(null),
              ),
            );
          }
          if (index == 1) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: CategoryCard(
                title: 'offers'.tr(),
                isSelected: isOffersSelected,
                onPressed: () => onOffersSelected?.call(),
                isOffer: true,
              ),
            );
          }
          final category = categories[index - 2];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: CategoryCard(
              title: category.name,
              isSelected:
                  selectedCategoryId == category.id && !isOffersSelected,
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
  final bool isOffer;

  const CategoryCard({
    required this.title,
    required this.isSelected,
    required this.onPressed,
    this.isOffer = false,
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
        color: isOffer && isSelected
            ? AppColours.brownLight.withValues(alpha: 0.2)
            : AppColours.greyLighter,
      ),
      child: TextButton(
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOffer) ...[
              Icon(
                Icons.local_offer,
                size: 16,
                color: isSelected ? AppColours.brownLight : AppColours.greyDark,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: isSelected ? textStyle : AppTextStyle.normal_16_greyDark,
            ),
          ],
        ),
      ),
    );
  }
}
