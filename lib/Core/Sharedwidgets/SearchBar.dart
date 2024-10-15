import 'package:flutter/material.dart';
import '../Theme/app_colors.dart';
import '../Theme/app_text_style.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine width based on screen size
    double searchBarWidth = screenWidth > 600 ? 400 : 280; // Example: wider on larger screens

    return Container(
      alignment: Alignment.center,
      width: searchBarWidth, // Use responsive width
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColours.greyLighter, // Use defined color
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.search,
            color: AppColours.primaryColor, // Use defined color
          ),
          SizedBox(width: 8),
          Text("البحث", style: AppTextStyle.normal_12_greyDark),
        ],
      ),
    );
  }
}
