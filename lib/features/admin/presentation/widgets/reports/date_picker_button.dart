import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat dateFormat;
  final VoidCallback? onTap;
  final bool isRtl;

  const DatePickerButton({
    super.key,
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label: ', style: const TextStyle(color: Colors.grey)),
            Text(
              date != null
                  ? dateFormat.format(date!)
                  : (isRtl ? 'اختر' : 'Select'),
              style: TextStyle(
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }
}
