import 'package:flutter/material.dart';

import '../../domain/entities/review_report_entity.dart';

class ReviewReportRespondButton extends StatelessWidget {
  final ReviewReportStatus status;
  final bool isArabic;
  final VoidCallback onRespond;
  final ThemeData theme;

  const ReviewReportRespondButton({
    super.key,
    required this.status,
    required this.isArabic,
    required this.onRespond,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (status != ReviewReportStatus.pending &&
        status != ReviewReportStatus.reviewed) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onRespond,
            icon: const Icon(Icons.reply, size: 18),
            label: Text(isArabic ? 'الرد على البلاغ' : 'Respond'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
