import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../domain/entities/product_report_entity.dart';
import '../cubit/product_reports_cubit.dart';

class ReportProductDialog extends StatefulWidget {
  final String productId;
  final String productName;

  const ReportProductDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String productId,
    required String productName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => sl<ProductReportsCubit>(),
        child: ReportProductDialog(
          productId: productId,
          productName: productName,
        ),
      ),
    );
  }

  @override
  State<ReportProductDialog> createState() => _ReportProductDialogState();
}

class _ReportProductDialogState extends State<ReportProductDialog> {
  ReportReason? _selectedReason;
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = context.locale.languageCode == 'ar';

    return BlocListener<ProductReportsCubit, ProductReportsState>(
      listener: (context, state) {
        if (state is ReportSubmitted) {
          Navigator.of(context).pop(true);
          Tost.showCustomToast(
            context,
            isArabic
                ? 'تم إرسال البلاغ بنجاح'
                : 'Report submitted successfully',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else if (state is ReportSubmitError) {
          setState(() => _isSubmitting = false);
          Tost.showCustomToast(
            context,
            isArabic ? 'فشل إرسال البلاغ' : 'Failed to submit report',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.flag, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic ? 'الإبلاغ عن المنتج' : 'Report Product',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic ? 'سبب البلاغ:' : 'Report Reason:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...ReportReason.values
                  .map((reason) => RadioListTile<ReportReason>(
                        title: Text(
                          reason.getLabel(isArabic),
                          style: const TextStyle(fontSize: 14),
                        ),
                        value: reason,
                        // ignore: deprecated_member_use
                        groupValue: _selectedReason,
                        // ignore: deprecated_member_use
                        onChanged: (value) =>
                            setState(() => _selectedReason = value),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      )),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'تفاصيل إضافية (اختياري):'
                    : 'Additional Details (optional):',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isArabic
                      ? 'اكتب تفاصيل البلاغ...'
                      : 'Write report details...',
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
            onPressed:
                _isSubmitting ? null : () => Navigator.of(context).pop(false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed:
                _isSubmitting || _selectedReason == null ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              foregroundColor: Colors.white,
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
                : Text(isArabic ? 'إرسال البلاغ' : 'Submit Report'),
          ),
        ],
      ),
    );
  }

  void _submitReport() {
    if (_selectedReason == null) return;
    setState(() => _isSubmitting = true);
    context.read<ProductReportsCubit>().submitReport(
          productId: widget.productId,
          reason: _selectedReason!.getLabel(true), // Store Arabic label
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
  }
}
