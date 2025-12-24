import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CouponsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const CouponsEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'no_coupons'.tr(),
            style: const TextStyle(
              fontSize: 18,
              color: AppColours.greyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'no_coupons_desc'.tr(),
            style: const TextStyle(color: AppColours.greyMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: Text('add_coupon'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColours.brownMedium,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
