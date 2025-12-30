import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../data/models/review_report_model.dart';
import '../../domain/entities/review_report_entity.dart';

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

  void _copyToClipboard(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    Tost.showCustomToast(
      context,
      widget.isArabic ? 'تم نسخ $label' : '$label copied',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  String _getReasonText(String reason) {
    final reasons = {
      'offensive': widget.isArabic ? 'محتوى مسيء' : 'Offensive',
      'spam': widget.isArabic ? 'سبام' : 'Spam',
      'fake': widget.isArabic ? 'تقييم مزيف' : 'Fake',
      'harassment': widget.isArabic ? 'تحرش' : 'Harassment',
      'inappropriate': widget.isArabic ? 'لغة غير مناسبة' : 'Inappropriate',
      'other': widget.isArabic ? 'أخرى' : 'Other',
    };
    return reasons[reason] ?? reason;
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
            _buildHeader(theme),
            _buildReviewComment(theme),
            const Divider(height: 20),
            _buildReporterInfo(),
            const SizedBox(height: 8),
            _buildDate(dateFormat),
            const SizedBox(height: 12),
            _buildIdsSection(),
            const SizedBox(height: 12),
            _buildReasonSection(),
            _buildDescription(),
            _buildAdminResponse(theme),
            _buildRespondButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
                widget.report.reviewerName ??
                    (widget.isArabic ? 'مستخدم' : 'User'),
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
                    '${widget.report.reviewRating ?? '-'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.report.productName ??
                          (widget.isArabic ? 'منتج محذوف' : 'Deleted'),
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
            status: widget.report.status, isArabic: widget.isArabic),
      ],
    );
  }

  Widget _buildReviewComment(ThemeData theme) {
    if (widget.report.reviewComment == null ||
        widget.report.reviewComment!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            widget.report.reviewComment!,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildReporterInfo() {
    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${widget.isArabic ? 'صاحب البلاغ:' : 'Reporter:'} ${widget.report.reporterName ?? '-'}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildDate(DateFormat dateFormat) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          dateFormat.format(widget.report.createdAt),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildIdsSection() {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showIds = !_showIds),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.key, size: 16, color: Colors.white70),
                const SizedBox(width: 8),
                Text(
                  widget.isArabic ? 'المعرفات (IDs)' : 'IDs',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
                const Spacer(),
                Icon(
                  _showIds ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
        if (_showIds) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildIdRow(
                    widget.isArabic ? 'البلاغ' : 'Report', widget.report.id),
                if (widget.report.reviewId != null)
                  _buildIdRow(widget.isArabic ? 'التعليق' : 'Review',
                      widget.report.reviewId!),
                if (widget.report.reviewerId != null)
                  _buildIdRow(widget.isArabic ? 'صاحب التعليق' : 'Reviewer',
                      widget.report.reviewerId!),
                if (widget.report.reporterId != null)
                  _buildIdRow(widget.isArabic ? 'صاحب البلاغ' : 'Reporter',
                      widget.report.reporterId!),
                if (widget.report.productId != null)
                  _buildIdRow(widget.isArabic ? 'المنتج' : 'Product',
                      widget.report.productId!),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIdRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 14, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () => _copyToClipboard(value, label),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
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
              _getReasonText(widget.report.reason),
              style: TextStyle(fontSize: 13, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.report.description == null ||
        widget.report.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          widget.report.description!,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildAdminResponse(ThemeData theme) {
    if (widget.report.adminResponse == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.isArabic ? 'الرد:' : 'Response:'} ${widget.report.adminName ?? 'Admin'}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(widget.report.adminResponse!,
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRespondButton(ThemeData theme) {
    if (widget.report.status != ReviewReportStatus.pending &&
        widget.report.status != ReviewReportStatus.reviewed) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onRespond,
            icon: const Icon(Icons.reply, size: 18),
            label: Text(widget.isArabic ? 'الرد على البلاغ' : 'Respond'),
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
