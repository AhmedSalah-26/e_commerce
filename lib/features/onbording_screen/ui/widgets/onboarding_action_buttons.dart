import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';

class OnboardingActionButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPage;
  final VoidCallback onSkip;
  final bool isRtl;

  const OnboardingActionButtons({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNextPage,
    required this.onSkip,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return Row(
      mainAxisAlignment: isLastPage
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        if (!isLastPage)
          _buildActionButton(
            isRtl ? 'تخطي' : 'Skip',
            onSkip,
            isOutlined: true,
          ),
        _buildActionButton(
          isLastPage ? (isRtl ? 'ابدأ' : 'Start') : (isRtl ? 'التالي' : 'Next'),
          onNextPage,
          isOutlined: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : AppColours.brownMedium,
        borderRadius: BorderRadius.circular(10),
        border: isOutlined
            ? Border.all(color: AppColours.brownMedium, width: 2)
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: isOutlined
                ? AppTextStyle.semiBold_18_white.copyWith(
                    color: AppColours.brownMedium,
                  )
                : AppTextStyle.semiBold_18_white,
          ),
        ),
      ),
    );
  }
}
