import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'coupon_text_field.dart';

class CouponLimitsFields extends StatelessWidget {
  final TextEditingController minOrderController;
  final TextEditingController usageLimitController;

  const CouponLimitsFields({
    super.key,
    required this.minOrderController,
    required this.usageLimitController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CouponTextField(
            controller: minOrderController,
            label: 'min_order'.tr(),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CouponTextField(
            controller: usageLimitController,
            label: 'usage_limit'.tr(),
            hint: 'unlimited'.tr(),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
