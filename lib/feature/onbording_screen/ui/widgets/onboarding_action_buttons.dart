import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Core/Theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';

class OnboardingActionButtons extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNextPage;
  final VoidCallback onSkip;

  const OnboardingActionButtons({
    required this.currentPage,
    required this.onNextPage,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: currentPage == 2
          ? MainAxisAlignment.end // Align "ابدأ" to the right on the last page
          : MainAxisAlignment.spaceBetween, // Default alignment for other pages
      children: [
        if (currentPage < 2) // Check if not on the last page
          _buildActionButton('تخطي', onSkip),
        _buildActionButton(
          currentPage == 2 ? 'ابدأ' : 'التالي',
          onNextPage,
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColours.brownMedium,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyle.semiBold_18_white,
        ),
      ),
    );
  }
}
