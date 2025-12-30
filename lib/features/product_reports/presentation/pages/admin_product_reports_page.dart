import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../domain/entities/product_report_entity.dart';
import '../../data/models/product_report_model.dart';
import '../cubit/product_reports_cubit.dart';

class AdminProductReportsPage extends StatelessWidget {
  const AdminProductReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductReportsCubit>()..loadAdminReports(),
      child: const _AdminReportsView(),
    );
  }
}

class _AdminReportsView extends StatefulWidget {
  const _AdminReportsView();

  @override
  State<_AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<_AdminReportsView> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          title: Text(
            isArabic ? 'بلاغات المنتجات' : 'Product Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _FilterChip(
                    label: isArabic ? 'الكل' : 'All',
                    isSelected: _selectedStatus == null,
                    onTap: () => _filterByStatus(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: isArabic ? 'قيد المراجعة' : 'Pending',
                    isSelected: _selectedStatus == 'pending',
                    onTap: () => _filterByStatus('pending'),
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: isArabic ? 'تمت المراجعة' : 'Reviewed',
                    isSelected: _selectedStatus == 'reviewed',
                    onTap: () => _filterByStatus('reviewed'),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: isArabic ? 'تم الحل' : 'Resolved',
                    isSelected: _selectedStatus == 'resolved',
                    onTap: () => _filterByStatus('resolved'),
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: isArabic ? 'مرفوض' : 'Rejected',
                    isSelected: _selectedStatus == 'rejected',
                    onTap: () => _filterByStatus('rejected'),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
            // Reports list
            Expanded(
              child: BlocBuilder<ProductReportsCubit, ProductReportsState>(
                builder: (context, state) {
                  if (state is ProductReportsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ProductReportsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(isArabic ? 'حدث خطأ' : 'An error occurred'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProductReportsCubit>()
                                .loadAdminReports(status: _selectedStatus),
                            child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductReportsLoaded) {
                    if (state.reports.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              isArabic ? 'لا توجد بلاغات' : 'No reports',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<ProductReportsCubit>()
                          .loadAdminReports(status: _selectedStatus),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.reports.length,
                        itemBuilder: (context, index) {
                          final report = state.reports[index];
                          return _AdminReportCard(
                            report: report,
                            isArabic: isArabic,
                            onRespond: () =>
                                _showRespondDialog(context, report, isArabic),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterByStatus(String? status) {
    setState(() => _selectedStatus = status);
    context.read<ProductReportsCubit>().loadAdminReports(status: status);
  }

  void _showRespondDialog(
      BuildContext context, ProductReportModel report, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductReportsCubit>(),
        child: _RespondSheet(report: report, isArabic: isArabic),
      ),
    ).then((responded) {
      if (responded == true) {
        context
            .read<ProductReportsCubit>()
            .loadAdminReports(status: _selectedStatus);
      }
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : chipColor,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: chipColor.withValues(alpha: 0.1),
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      side: BorderSide(color: chipColor.withValues(alpha: 0.3)),
    );
  }
}

class _AdminReportCard extends StatefulWidget {
  final ProductReportModel report;
  final bool isArabic;
  final VoidCallback onRespond;

  const _AdminReportCard({
    required this.report,
    required this.isArabic,
    required this.onRespond,
  });

  @override
  State<_AdminReportCard> createState() => _AdminReportCardState();
}

class _AdminReportCardState extends State<_AdminReportCard> {
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
            // Header
            Row(
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
                            fontWeight: FontWeight.w600, fontSize: 14),
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
                _StatusBadge(
                    status: widget.report.status, isArabic: widget.isArabic),
              ],
            ),
            const Divider(height: 20),
            // Reporter info
            Row(
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
            ),
            const SizedBox(height: 8),
            // Date
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(widget.report.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // IDs Expandable Section
            InkWell(
              onTap: () => setState(() => _showIds = !_showIds),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            ),
            if (_showIds) ...[
              const SizedBox(height: 8),
              _buildIdRow(
                  widget.isArabic ? 'البلاغ' : 'Report', widget.report.id),
              _buildIdRow(widget.isArabic ? 'المنتج' : 'Product',
                  widget.report.productId),
              if (widget.report.merchantId != null)
                _buildIdRow(widget.isArabic ? 'التاجر' : 'Merchant',
                    widget.report.merchantId!),
              _buildIdRow(widget.isArabic ? 'المُبلِّغ' : 'Reporter',
                  widget.report.userId),
            ],
            const SizedBox(height: 12),
            // Reason
            Container(
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
            ),
            if (widget.report.description != null &&
                widget.report.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.report.description!,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
            // Admin response
            if (widget.report.adminResponse != null) ...[
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
            // Respond button
            if (widget.report.status == ReportStatus.pending ||
                widget.report.status == ReportStatus.reviewed) ...[
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
          ],
        ),
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

  Widget _imagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ReportStatus status;
  final bool isArabic;

  const _StatusBadge({required this.status, required this.isArabic});

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
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

class _RespondSheet extends StatefulWidget {
  final ProductReportModel report;
  final bool isArabic;

  const _RespondSheet({required this.report, required this.isArabic});

  @override
  State<_RespondSheet> createState() => _RespondSheetState();
}

class _RespondSheetState extends State<_RespondSheet> {
  final _responseController = TextEditingController();
  String _selectedStatus = 'resolved';
  bool _suspendProduct = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.isArabic ? 'الرد على البلاغ' : 'Respond to Report',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Status selection
            Text(
              widget.isArabic ? 'حالة البلاغ:' : 'Report Status:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(widget.isArabic ? 'تم الحل' : 'Resolved'),
                  selected: _selectedStatus == 'resolved',
                  onSelected: (_) =>
                      setState(() => _selectedStatus = 'resolved'),
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'resolved' ? Colors.white : null,
                  ),
                ),
                ChoiceChip(
                  label: Text(widget.isArabic ? 'مرفوض' : 'Rejected'),
                  selected: _selectedStatus == 'rejected',
                  onSelected: (_) =>
                      setState(() => _selectedStatus = 'rejected'),
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'rejected' ? Colors.white : null,
                  ),
                ),
                ChoiceChip(
                  label: Text(widget.isArabic ? 'تمت المراجعة' : 'Reviewed'),
                  selected: _selectedStatus == 'reviewed',
                  onSelected: (_) =>
                      setState(() => _selectedStatus = 'reviewed'),
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: _selectedStatus == 'reviewed' ? Colors.white : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Response text
            Text(
              widget.isArabic ? 'الرد:' : 'Response:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _responseController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: widget.isArabic
                    ? 'اكتب ردك هنا...'
                    : 'Write your response...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            // Suspend product option
            if (_selectedStatus == 'resolved')
              CheckboxListTile(
                value: _suspendProduct,
                onChanged: (v) => setState(() => _suspendProduct = v ?? false),
                title: Text(
                  widget.isArabic ? 'إيقاف المنتج' : 'Suspend Product',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  widget.isArabic
                      ? 'سيتم حظر المنتج من العرض'
                      : 'Product will be blocked from display',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 20),
            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(widget.isArabic ? 'إرسال الرد' : 'Send Response'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_responseController.text.trim().isEmpty) {
      Tost.showCustomToast(
        context,
        widget.isArabic ? 'يرجى كتابة الرد' : 'Please write a response',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await context.read<ProductReportsCubit>().respondToReport(
          reportId: widget.report.id,
          status: _selectedStatus,
          adminResponse: _responseController.text.trim(),
          suspendProduct: _suspendProduct,
          suspensionReason: _suspendProduct
              ? (widget.isArabic
                  ? 'تم الإيقاف بسبب بلاغات المستخدمين'
                  : 'Suspended due to user reports')
              : null,
        );

    if (mounted) {
      Navigator.of(context).pop(success);
      if (success) {
        Tost.showCustomToast(
          context,
          widget.isArabic
              ? 'تم إرسال الرد بنجاح'
              : 'Response sent successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    }
  }
}
