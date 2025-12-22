import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Shimmer skeleton box
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}
