import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
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
    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColours.greyLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.login, color: AppColours.brownMedium),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'login_required'.tr(),
                style: AppTextStyle.normal_16_greyDark,
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
        color: AppColours.brownMedium,
      ),
      label: Text(
        userReview != null ? 'edit_review'.tr() : 'add_review'.tr(),
        style: const TextStyle(color: AppColours.brownMedium),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColours.brownMedium, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
