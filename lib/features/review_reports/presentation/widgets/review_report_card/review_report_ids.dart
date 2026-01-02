import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/shared_widgets/toast.dart';
import '../../../data/models/review_report_model.dart';

class ReviewReportIds extends StatelessWidget {
  final ReviewReportModel report;
  final bool isArabic;
  final bool showIds;
  final VoidCallback onToggle;

  const ReviewReportIds({
    super.key,
    required this.report,
    required this.isArabic,
    required this.showIds,
    required this.onToggle,
  });

  void _copyToClipboard(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    Tost.showCustomToast(
      context,
      isArabic ? 'تم نسخ $label' : '$label copied',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.key,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'المعرفات (IDs)' : 'IDs',
                  style: TextStyle(
                      fontSize: 13, color: theme.colorScheme.onSurface),
                ),
                const Spacer(),
                Icon(
                  showIds ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
        if (showIds) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildIdRow(context, isArabic ? 'البلاغ' : 'Report', report.id),
                if (report.reviewId != null)
                  _buildIdRow(context, isArabic ? 'التعليق' : 'Review',
                      report.reviewId!),
                if (report.reviewerId != null)
                  _buildIdRow(context, isArabic ? 'صاحب التعليق' : 'Reviewer',
                      report.reviewerId!),
                if (report.reporterId != null)
                  _buildIdRow(context, isArabic ? 'صاحب البلاغ' : 'Reporter',
                      report.reporterId!),
                if (report.productId != null)
                  _buildIdRow(context, isArabic ? 'المنتج' : 'Product',
                      report.productId!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIdRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style:
                  TextStyle(fontSize: 11, color: theme.colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.copy,
                size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () => _copyToClipboard(context, value, label),
          ),
        ],
      ),
    );
  }
}
