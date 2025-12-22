import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../../core/theme/app_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColours.brownMedium,
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
              style: AppTextStyle.normal_12_black,
            ),
          ),
        ],
      ),
    );
  }
}
