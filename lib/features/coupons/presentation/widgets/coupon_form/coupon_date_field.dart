import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CouponDateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isOptional;
  final ValueChanged<DateTime> onChanged;

  const CouponDateField({
    super.key,
    required this.label,
    required this.date,
    this.isOptional = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('yyyy/MM/dd').format(date!)
                    : (isOptional ? 'optional'.tr() : 'select_date'.tr()),
                style:
                    TextStyle(color: date != null ? Colors.black : Colors.grey),
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
