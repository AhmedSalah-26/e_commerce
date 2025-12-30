import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../domain/entities/review_report_entity.dart';
import '../cubit/review_reports_cubit.dart';

class ReviewReportRespondSheet extends StatefulWidget {
  final ReviewReportEntity report;
  final bool isArabic;

  const ReviewReportRespondSheet({
    super.key,
    required this.report,
    required this.isArabic,
  });

  @override
  State<ReviewReportRespondSheet> createState() =>
      _ReviewReportRespondSheetState();
}

class _ReviewReportRespondSheetState extends State<ReviewReportRespondSheet> {
  final _responseController = TextEditingController();
  String _selectedStatus = 'resolved';
  bool _deleteReview = false;
  bool _banReviewer = false;
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
            _buildActions(),
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
            ChoiceChip(
              label: Text(widget.isArabic ? 'تم الحل' : 'Resolved'),
              selected: _selectedStatus == 'resolved',
              onSelected: (_) => setState(() => _selectedStatus = 'resolved'),
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: _selectedStatus == 'resolved' ? Colors.white : null,
              ),
            ),
            ChoiceChip(
              label: Text(widget.isArabic ? 'مرفوض' : 'Rejected'),
              selected: _selectedStatus == 'rejected',
              onSelected: (_) => setState(() => _selectedStatus = 'rejected'),
              selectedColor: Colors.red,
              labelStyle: TextStyle(
                color: _selectedStatus == 'rejected' ? Colors.white : null,
              ),
            ),
            ChoiceChip(
              label: Text(widget.isArabic ? 'تمت المراجعة' : 'Reviewed'),
              selected: _selectedStatus == 'reviewed',
              onSelected: (_) => setState(() => _selectedStatus = 'reviewed'),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: _selectedStatus == 'reviewed' ? Colors.white : null,
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildActions() {
    if (_selectedStatus != 'resolved') return const SizedBox.shrink();

    return Column(
      children: [
        CheckboxListTile(
          value: _deleteReview,
          onChanged: (v) => setState(() => _deleteReview = v ?? false),
          title: Text(
            widget.isArabic ? 'حذف التعليق' : 'Delete Review',
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            widget.isArabic
                ? 'سيتم حذف التعليق نهائياً'
                : 'Review will be permanently deleted',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: _banReviewer,
          onChanged: (v) => setState(() => _banReviewer = v ?? false),
          title: Text(
            widget.isArabic ? 'حظر صاحب التعليق' : 'Ban Reviewer',
            style: const TextStyle(fontSize: 14),
          ),
          subtitle: Text(
            widget.isArabic
                ? 'سيتم حظر المستخدم من التعليق'
                : 'User will be banned from reviewing',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
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
                    color: Colors.white, strokeWidth: 2),
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

    try {
      final cubit = context.read<ReviewReportsCubit>();
      final success = await cubit.respondToReport(
        reportId: widget.report.id,
        status: _selectedStatus,
        adminResponse: _responseController.text.trim(),
        deleteReview: _deleteReview,
        banReviewer: _banReviewer,
      );

      if (!mounted) return;

      final message = success
          ? (widget.isArabic
              ? 'تم إرسال الرد بنجاح'
              : 'Response sent successfully')
          : (widget.isArabic ? 'فشل في إرسال الرد' : 'Failed to send response');
      final color = success ? Colors.green : Colors.red;

      Tost.showCustomToast(context, message,
          backgroundColor: color, textColor: Colors.white);

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.of(context).pop(success);
      }
    } catch (e) {
      print('❌ Error in _submit: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        Tost.showCustomToast(
          context,
          widget.isArabic ? 'حدث خطأ: $e' : 'Error: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }
}
