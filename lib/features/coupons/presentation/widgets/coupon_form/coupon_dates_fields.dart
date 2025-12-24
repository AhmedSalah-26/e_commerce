import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'coupon_date_field.dart';

class CouponDatesFields extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const CouponDatesFields({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CouponDateField(
            label: 'start_date'.tr(),
            date: startDate,
            onChanged: onStartDateChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CouponDateField(
            label: 'end_date'.tr(),
            date: endDate,
            isOptional: true,
            onChanged: onEndDateChanged,
          ),
        ),
      ],
    );
  }
}
