import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../generated/locale_keys.g.dart';
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
    final theme = Theme.of(context);
    final isLastPage = currentPage == totalPages - 1;

    return Row(
      mainAxisAlignment: isLastPage
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceBetween,
      children: [
        if (!isLastPage)
          _buildActionButton(
            LocaleKeys.onboarding_skip.tr(),
            onSkip,
            theme,
            isOutlined: true,
          ),
        _buildActionButton(
          isLastPage ? LocaleKeys.onboarding_start.tr() : LocaleKeys.next.tr(),
          onNextPage,
          theme,
          isOutlined: false,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    VoidCallback onPressed,
    ThemeData theme, {
    bool isOutlined = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
        border: isOutlined
            ? Border.all(color: theme.colorScheme.primary, width: 2)
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
                    color: theme.colorScheme.primary,
                  )
                : AppTextStyle.semiBold_18_white,
          ),
        ),
      ),
    );
  }
}
