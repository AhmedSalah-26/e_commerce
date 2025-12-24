import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_colors.dart';

/// Full page skeleton for product details screen
class ProductScreenSkeleton extends StatelessWidget {
  const ProductScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: AppColours.greyLighter,
      highlightColor: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image slider skeleton
            Container(
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                color: AppColours.greyLighter,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            // Product name and price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: screenWidth * 0.5,
                        decoration: BoxDecoration(
                          color: AppColours.greyLighter,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 16,
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          color: AppColours.greyLighter,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 24,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),

            // Rating row skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: AppColours.greyLighter,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.04),

            // Store info skeleton
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColours.greyLighter,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Stock status skeleton
            Container(
              height: 20,
              width: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: AppColours.greyLighter,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),

            // Description skeleton
            Container(
              height: 16,
              width: screenWidth * 0.25,
              decoration: BoxDecoration(
                color: AppColours.greyLighter,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            // Quantity selector skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 30,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),

            // Total price skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 20,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  height: 24,
                  width: screenWidth * 0.25,
                  decoration: BoxDecoration(
                    color: AppColours.greyLighter,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.2),
          ],
        ),
      ),
    );
  }
}
