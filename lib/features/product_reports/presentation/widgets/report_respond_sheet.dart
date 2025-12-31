import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/shared_widgets/toast.dart';
import '../../data/models/product_report_model.dart';
import '../cubit/product_reports_cubit.dart';

class ReportRespondSheet extends StatefulWidget {
  final ProductReportModel report;
  final bool isArabic;

  const ReportRespondSheet({
    super.key,
    required this.report,
    required this.isArabic,
  });

  @override
  State<ReportRespondSheet> createState() => _ReportRespondSheetState();
}

class _ReportRespondSheetState extends State<ReportRespondSheet> {
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
            _buildHandle(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildStatusSelection(),
            const SizedBox(height: 16),
            _buildResponseField(),
            const SizedBox(height: 16),
            if (_selectedStatus == 'resolved') _buildSuspendOption(),
            const SizedBox(height: 20),
            _buildSubmitButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.isArabic ? 'الرد على البلاغ' : 'Respond to Report',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isArabic ? 'حالة البلاغ:' : 'Report Status:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildStatusChip('resolved',
                widget.isArabic ? 'تم الحل' : 'Resolved', Colors.green),
            _buildStatusChip(
                'rejected', widget.isArabic ? 'مرفوض' : 'Rejected', Colors.red),
            _buildStatusChip('reviewed',
                widget.isArabic ? 'تمت المراجعة' : 'Reviewed', Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedStatus = value),
      selectedColor: color,
      labelStyle: TextStyle(color: isSelected ? Colors.white : null),
    );
  }

  Widget _buildResponseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isArabic ? 'الرد:' : 'Response:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _responseController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                widget.isArabic ? 'اكتب ردك هنا...' : 'Write your response...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuspendOption() {
    return CheckboxListTile(
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
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
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
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(widget.isArabic ? 'إرسال الرد' : 'Send Response'),
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
