import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CouponInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const CouponInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColours.greyDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColours.greyDark),
          ),
        ],
      ),
    );
  }
}
