import 'package:flutter/material.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../../Core/Theme/app_colors.dart';
import '../../data/models/Category.dart';

// Import your color definitions

class HorizontalCategoriesView extends StatefulWidget {
  final Function(String) onCategorySelected;
  final List<Category> categories;

  HorizontalCategoriesView({
    required this.onCategorySelected,
    super.key,
    required this.categories,
  });

  @override
  State<HorizontalCategoriesView> createState() =>
      _HorizontalCategoriesViewState();
}

class _HorizontalCategoriesViewState extends State<HorizontalCategoriesView> {
  String selectedCategory = "All"; // Default selected category

  void _setSelectedCategory(int index) {
    setState(() {
      for (var category in widget.categories) {
        category.isSelected = false;
      }
      widget.categories[index].isSelected = true;
      selectedCategory = widget.categories[index].title;
      widget.onCategorySelected(selectedCategory); // Pass selected category to parent
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width from MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    // Define responsive padding based on screen width
    final horizontalPadding = screenWidth > 600 ? 16.0 : 8.0;

    return SizedBox(
      height: 50,
      width: screenWidth,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: CategoryCard(
              category: widget.categories[index],
              onPressed: () => _setSelectedCategory(index),
            ),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onPressed;

  const CategoryCard({
    required this.category,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen width from MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    // Define responsive text size based on screen width
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
          overlayColor: MaterialStateProperty.all(Colors.transparent),
        ),
        onPressed: onPressed,
        child: Text(
          category.title,
          style: category.isSelected
              ? textStyle
              : AppTextStyle.normal_16_greyDark,
        ),
      ),
    );
  }
}


