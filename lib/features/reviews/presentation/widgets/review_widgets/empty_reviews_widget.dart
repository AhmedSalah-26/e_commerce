import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_style.dart';

class EmptyReviewsWidget extends StatelessWidget {
  const EmptyReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 60,
              color: AppColours.greyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'no_reviews'.tr(),
              style: AppTextStyle.normal_16_greyDark,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'be_first_review'.tr(),
              style: AppTextStyle.normal_12_black.copyWith(
                color: AppColours.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
