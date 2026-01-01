import 'package:flutter/material.dart';

class ReviewReportReason extends StatelessWidget {
  final String reason;
  final bool isArabic;

  const ReviewReportReason({
    super.key,
    required this.reason,
    required this.isArabic,
  });

  String _getReasonText(String reason) {
    final reasons = {
      'offensive': isArabic ? 'محتوى مسيء' : 'Offensive',
      'spam': isArabic ? 'سبام' : 'Spam',
      'fake': isArabic ? 'تقييم مزيف' : 'Fake',
      'harassment': isArabic ? 'تحرش' : 'Harassment',
      'inappropriate': isArabic ? 'لغة غير مناسبة' : 'Inappropriate',
      'other': isArabic ? 'أخرى' : 'Other',
    };
    return reasons[reason] ?? reason;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.flag, size: 18, color: Colors.orange[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getReasonText(reason),
              style: TextStyle(fontSize: 13, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }
}
