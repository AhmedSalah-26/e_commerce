import 'package:flutter/material.dart';

import '../../../data/models/review_report_model.dart';
import 'review_report_status_badge.dart';

class ReviewReportHeader extends StatelessWidget {
  final ReviewReportModel report;
  final bool isArabic;

  const ReviewReportHeader({
    super.key,
    required this.report,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.rate_review, color: Colors.amber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                report.reviewerName ?? (isArabic ? 'مستخدم' : 'User'),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${report.reviewRating ?? '-'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      report.productName ??
                          (isArabic ? 'منتج محذوف' : 'Deleted'),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ReviewReportStatusBadge(
          status: report.status,
          isArabic: isArabic,
        ),
      ],
    );
  }
}
