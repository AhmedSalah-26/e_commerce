import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/shared_widgets/toast.dart';
import '../../data/models/product_report_model.dart';
import '../../domain/entities/product_report_entity.dart';
import 'report_status_badge.dart';

class AdminReportCard extends StatefulWidget {
  final ProductReportModel report;
  final bool isArabic;
  final VoidCallback onRespond;

  const AdminReportCard({
    super.key,
    required this.report,
    required this.isArabic,
    required this.onRespond,
  });

  @override
  State<AdminReportCard> createState() => _AdminReportCardState();
}

class _AdminReportCardState extends State<AdminReportCard> {
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
            _buildHeader(),
            const Divider(height: 20),
            _buildReporterInfo(),
            const SizedBox(height: 8),
            _buildDate(dateFormat),
            const SizedBox(height: 12),
            _buildIdsSection(),
            if (_showIds) _buildIdsList(),
            const SizedBox(height: 12),
            _buildReason(),
            if (widget.report.description?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                widget.report.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            if (widget.report.adminResponse != null) _buildAdminResponse(theme),
            if (widget.report.status == ReportStatus.pending ||
                widget.report.status == ReportStatus.reviewed)
              _buildRespondButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.report.productImage != null
              ? CachedNetworkImage(
                  imageUrl: widget.report.productImage!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _imagePlaceholder(),
                  errorWidget: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.report.productName ??
                    (widget.isArabic ? 'منتج محذوف' : 'Deleted'),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${widget.isArabic ? 'التاجر:' : 'Merchant:'} ${widget.report.merchantName ?? '-'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        ReportStatusBadge(
          status: widget.report.status,
          isArabic: widget.isArabic,
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
            '${widget.report.userName ?? 'مستخدم'} (${widget.report.userEmail ?? '-'})',
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
    return InkWell(
      onTap: () => setState(() => _showIds = !_showIds),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.key, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              widget.isArabic ? 'المعرفات (IDs)' : 'IDs',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const Spacer(),
            Icon(
              _showIds ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _buildIdRow(widget.isArabic ? 'البلاغ' : 'Report', widget.report.id),
          _buildIdRow(
              widget.isArabic ? 'المنتج' : 'Product', widget.report.productId),
          if (widget.report.merchantId != null)
            _buildIdRow(widget.isArabic ? 'التاجر' : 'Merchant',
                widget.report.merchantId!),
          _buildIdRow(
              widget.isArabic ? 'المُبلِّغ' : 'Reporter', widget.report.userId),
        ],
      ),
    );
  }

  Widget _buildIdRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 14),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () => _copyToClipboard(value, label),
          ),
        ],
      ),
    );
  }

  Widget _buildReason() {
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
              widget.report.reason,
              style: TextStyle(fontSize: 13, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminResponse(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
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
            Text(
              widget.report.adminResponse!,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRespondButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
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
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
