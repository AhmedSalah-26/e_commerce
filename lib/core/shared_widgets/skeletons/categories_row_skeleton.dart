import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton for category row
class CategoriesRowSkeleton extends StatelessWidget {
  const CategoriesRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.surfaceContainerHighest;
    final highlightColor = theme.colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: skeletonColor,
      highlightColor: highlightColor,
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
