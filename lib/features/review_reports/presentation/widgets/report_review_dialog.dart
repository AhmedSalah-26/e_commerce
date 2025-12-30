import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../data/datasources/review_report_remote_datasource.dart';

class ReportReviewDialog extends StatefulWidget {
  final String reviewId;
  final String reviewerName;
  final String? reviewComment;

  const ReportReviewDialog({
    super.key,
    required this.reviewId,
    required this.reviewerName,
    this.reviewComment,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String reviewId,
    required String reviewerName,
    String? reviewComment,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ReportReviewDialog(
        reviewId: reviewId,
        reviewerName: reviewerName,
        reviewComment: reviewComment,
      ),
    );
  }

  @override
  State<ReportReviewDialog> createState() => _ReportReviewDialogState();
}

class _ReportReviewDialogState extends State<ReportReviewDialog> {
  final _descriptionController = TextEditingController();
  String? _selectedReason;
  bool _isSubmitting = false;

  final List<Map<String, String>> _reasons = [
    {
      'key': 'offensive',
      'ar': 'محتوى مسيء أو غير لائق',
      'en': 'Offensive content'
    },
    {'key': 'spam', 'ar': 'محتوى مزعج أو سبام', 'en': 'Spam content'},
    {'key': 'fake', 'ar': 'تقييم مزيف أو غير حقيقي', 'en': 'Fake review'},
    {'key': 'harassment', 'ar': 'تحرش أو تنمر', 'en': 'Harassment or bullying'},
    {
      'key': 'inappropriate',
      'ar': 'لغة غير مناسبة',
      'en': 'Inappropriate language'
    },
    {'key': 'other', 'ar': 'سبب آخر', 'en': 'Other reason'},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    setState(() => _isSubmitting = true);

    try {
      final dataSource = sl<ReviewReportRemoteDataSource>();
      await dataSource.createReport(
        reviewId: widget.reviewId,
        reason: _selectedReason!,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        Tost.showCustomToast(
          context,
          context.locale.languageCode == 'ar'
              ? 'تم إرسال البلاغ بنجاح'
              : 'Report submitted successfully',
          backgroundColor: Colors.green,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Tost.showCustomToast(
          context,
          e.toString().contains('duplicate')
              ? (context.locale.languageCode == 'ar'
                  ? 'لقد قمت بالإبلاغ عن هذا التعليق مسبقاً'
                  : 'You have already reported this review')
              : (context.locale.languageCode == 'ar'
                  ? 'فشل في إرسال البلاغ'
                  : 'Failed to submit report'),
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.flag, color: Colors.orange, size: 24),
          const SizedBox(width: 8),
          Text(isRtl ? 'الإبلاغ عن تعليق' : 'Report Review'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Review preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (widget.reviewComment != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.reviewComment!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Reason selection
            Text(
              isRtl ? 'سبب البلاغ *' : 'Report Reason *',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...(_reasons.map((reason) => RadioListTile<String>(
                  title: Text(
                    isRtl ? reason['ar']! : reason['en']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: reason['key']!,
                  groupValue: _selectedReason,
                  onChanged: (value) => setState(() => _selectedReason = value),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ))),
            const SizedBox(height: 16),

            // Description
            Text(
              isRtl
                  ? 'تفاصيل إضافية (اختياري)'
                  : 'Additional Details (optional)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isRtl
                    ? 'اكتب تفاصيل إضافية...'
                    : 'Write additional details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(isRtl ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedReason == null ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isRtl ? 'إرسال البلاغ' : 'Submit Report',
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
