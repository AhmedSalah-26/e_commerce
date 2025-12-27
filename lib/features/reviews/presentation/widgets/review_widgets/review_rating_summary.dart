import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../../core/theme/app_text_style.dart';

class ReviewRatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const ReviewRatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              RatingBarIndicator(
                rating: averageRating,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 16,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'based_on_reviews'
                  .tr()
                  .replaceAll('{}', totalReviews.toString())
                  .replaceAll('{count}', totalReviews.toString()),
              style: AppTextStyle.normal_12_black.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
