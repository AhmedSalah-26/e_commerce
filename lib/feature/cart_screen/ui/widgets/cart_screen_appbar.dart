import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../Core/Theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';

class CartScreenAppBar extends StatelessWidget {
  const CartScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02, // Adjust vertical padding based on screen width
        horizontal: screenWidth * 0.04, // Adjust horizontal padding based on screen width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "السله",
            style: AppTextStyle.semiBold_20_dark_brown.copyWith(
              fontSize: screenWidth * 0.06, // Adjust font size based on screen width
              color: AppColours.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
