import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../data/models/review_report_model.dart';
import 'review_report_header.dart';
import 'review_report_comment.dart';
import 'review_report_info.dart';
import 'review_report_ids.dart';
import 'review_report_reason.dart';
import 'review_report_description.dart';
import 'review_report_admin_response.dart';
import 'review_report_respond_button.dart';

class ReviewReportCard extends StatefulWidget {
  final ReviewReportModel report;
  final bool isArabic;
  final VoidCallback onRespond;

  const ReviewReportCard({
    super.key,
    required this.report,
    required this.isArabic,
    required this.onRespond,
  });

  @override
  State<ReviewReportCard> createState() => _ReviewReportCardState();
}

class _ReviewReportCardState extends State<ReviewReportCard> {
  bool _showIds = false;

  void _toggleIds() {
    setState(() => _showIds = !_showIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd - HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReviewReportHeader(
              report: widget.report,
              isArabic: widget.isArabic,
            ),
            ReviewReportComment(
              comment: widget.report.reviewComment,
              theme: theme,
            ),
            const Divider(height: 20),
            ReviewReportInfo(
              reporterName: widget.report.reporterName,
              createdAt: widget.report.createdAt,
              dateFormat: dateFormat,
              isArabic: widget.isArabic,
            ),
            const SizedBox(height: 12),
            ReviewReportIds(
              report: widget.report,
              isArabic: widget.isArabic,
              showIds: _showIds,
              onToggle: _toggleIds,
            ),
            const SizedBox(height: 12),
            ReviewReportReason(
              reason: widget.report.reason,
              isArabic: widget.isArabic,
            ),
            ReviewReportDescription(
              description: widget.report.description,
            ),
            ReviewReportAdminResponse(
              adminResponse: widget.report.adminResponse,
              adminName: widget.report.adminName,
              isArabic: widget.isArabic,
              theme: theme,
            ),
            ReviewReportRespondButton(
              status: widget.report.status,
              isArabic: widget.isArabic,
              onRespond: widget.onRespond,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }
}
