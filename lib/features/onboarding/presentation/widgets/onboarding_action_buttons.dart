import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_text_style.dart';

class OnboardingActionButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPage;
  final bool isRtl;

  const OnboardingActionButtons({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNextPage,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = currentPage == totalPages - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          isLastPage ? 'onboarding_start'.tr() : 'next'.tr(),
          onNextPage,
          theme,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: AppTextStyle.semiBold_18_white,
          ),
        ),
      ),
    );
  }
}
