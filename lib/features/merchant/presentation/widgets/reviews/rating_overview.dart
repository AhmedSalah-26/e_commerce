import 'package:flutter/material.dart';

class RatingOverview extends StatelessWidget {
  final double avgRating;
  final int reviewCount;
  final bool isRtl;

  const RatingOverview({
    super.key,
    required this.avgRating,
    required this.reviewCount,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Column(
          children: [
            Text(
              avgRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                if (avgRating >= starValue) {
                  return const Icon(Icons.star, size: 20, color: Colors.amber);
                } else if (avgRating >= starValue - 0.5) {
                  return const Icon(Icons.star_half,
                      size: 20, color: Colors.amber);
                }
                return Icon(Icons.star_border,
                    size: 20, color: Colors.grey[400]);
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '$reviewCount ${isRtl ? 'تقييم' : 'reviews'}',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ],
    );
  }
}
