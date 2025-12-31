import 'package:flutter/material.dart';

import '../../domain/entities/product_report_entity.dart';

class ReportStatusBadge extends StatelessWidget {
  final ReportStatus status;
  final bool isArabic;

  const ReportStatusBadge({
    super.key,
    required this.status,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ReportStatus.pending:
        color = Colors.orange;
        break;
      case ReportStatus.reviewed:
        color = Colors.blue;
        break;
      case ReportStatus.resolved:
        color = Colors.green;
        break;
      case ReportStatus.rejected:
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
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
