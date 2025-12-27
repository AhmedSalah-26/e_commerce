import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_text_style.dart';
import '../../../domain/entities/review_entity.dart';

class AddReviewButton extends StatelessWidget {
  final bool isAuthenticated;
  final ReviewEntity? userReview;
  final VoidCallback onPressed;

  const AddReviewButton({
    super.key,
    required this.isAuthenticated,
    required this.userReview,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.login, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'login_required'.tr(),
                style: AppTextStyle.normal_16_greyDark.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        userReview != null ? Icons.edit : Icons.rate_review,
        color: theme.colorScheme.primary,
      ),
      label: Text(
        userReview != null ? 'edit_review'.tr() : 'add_review'.tr(),
        style: TextStyle(color: theme.colorScheme.primary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
