import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'coupon_text_field.dart';

class DiscountValueFields extends StatelessWidget {
  final TextEditingController discountValueController;
  final TextEditingController maxDiscountController;
  final String discountType;

  const DiscountValueFields({
    super.key,
    required this.discountValueController,
    required this.maxDiscountController,
    required this.discountType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CouponTextField(
            controller: discountValueController,
            label: 'discount_value'.tr(),
            keyboardType: TextInputType.number,
            suffix: discountType == 'percentage' ? '%' : 'egp'.tr(),
            validator: _validateDiscountValue,
          ),
        ),
        if (discountType == 'percentage') ...[
          const SizedBox(width: 12),
          Expanded(
            child: CouponTextField(
              controller: maxDiscountController,
              label: 'max_discount'.tr(),
              keyboardType: TextInputType.number,
              suffix: 'egp'.tr(),
            ),
          ),
        ],
      ],
    );
  }

  String? _validateDiscountValue(String? v) {
    if (v?.isEmpty == true) return 'field_required'.tr();
    final val = double.tryParse(v!);
    if (val == null || val <= 0) return 'invalid_value'.tr();
    if (discountType == 'percentage' && val > 100) return 'max_100'.tr();
    return null;
  }
}
