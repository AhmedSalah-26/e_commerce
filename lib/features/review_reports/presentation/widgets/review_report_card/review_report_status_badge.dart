import 'package:flutter/material.dart';

import '../../../domain/entities/review_report_entity.dart';

class ReviewReportStatusBadge extends StatelessWidget {
  final ReviewReportStatus status;
  final bool isArabic;

  const ReviewReportStatusBadge({
    super.key,
    required this.status,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ReviewReportStatus.pending:
        color = Colors.orange;
        break;
      case ReviewReportStatus.reviewed:
        color = Colors.blue;
        break;
      case ReviewReportStatus.resolved:
        color = Colors.green;
        break;
      case ReviewReportStatus.rejected:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.getLabel(isArabic),
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}
