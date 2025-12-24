import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'coupon_text_field.dart';

class CouponNamesFields extends StatelessWidget {
  final TextEditingController nameArController;
  final TextEditingController nameEnController;

  const CouponNamesFields({
    super.key,
    required this.nameArController,
    required this.nameEnController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CouponTextField(
            controller: nameArController,
            label: 'name_ar'.tr(),
            validator: (v) => v?.isEmpty == true ? 'field_required'.tr() : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CouponTextField(
            controller: nameEnController,
            label: 'name_en'.tr(),
            validator: (v) => v?.isEmpty == true ? 'field_required'.tr() : null,
          ),
        ),
      ],
    );
  }
}
