import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewReportInfo extends StatelessWidget {
  final String? reporterName;
  final DateTime createdAt;
  final DateFormat dateFormat;
  final bool isArabic;

  const ReviewReportInfo({
    super.key,
    required this.reporterName,
    required this.createdAt,
    required this.dateFormat,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${isArabic ? 'صاحب البلاغ:' : 'Reporter:'} ${reporterName ?? '-'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              dateFormat.format(createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
