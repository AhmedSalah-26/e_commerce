import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../domain/entities/review_report_entity.dart';
import '../cubit/review_reports_cubit.dart';

class AdminReviewReportsPage extends StatefulWidget {
  const AdminReviewReportsPage({super.key});

  @override
  State<AdminReviewReportsPage> createState() => _AdminReviewReportsPageState();
}

class _AdminReviewReportsPageState extends State<AdminReviewReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReviewReportsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cubit = sl<ReviewReportsCubit>();
    _loadReports();
  }

  void _loadReports() {
    final status = _getStatusForTab(_tabController.index);
    _cubit.loadAdminReports(status: status);
  }

  String? _getStatusForTab(int index) {
    switch (index) {
      case 1:
        return 'pending';
      case 2:
        return 'resolved';
      case 3:
        return 'rejected';
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          title: Text(isRtl ? 'بلاغات التعليقات' : 'Review Reports'),
          bottom: TabBar(
            controller: _tabController,
            onTap: (_) => _loadReports(),
            tabs: [
              Tab(text: isRtl ? 'الكل' : 'All'),
              Tab(text: isRtl ? 'معلقة' : 'Pending'),
              Tab(text: isRtl ? 'تم الحل' : 'Resolved'),
              Tab(text: isRtl ? 'مرفوضة' : 'Rejected'),
            ],
          ),
        ),
        body: BlocBuilder<ReviewReportsCubit, ReviewReportsState>(
          builder: (context, state) {
            if (state is ReviewReportsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReviewReportsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadReports,
                      child: Text(isRtl ? 'إعادة المحاولة' : 'Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ReviewReportsLoaded) {
              if (state.reports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(isRtl ? 'لا توجد بلاغات' : 'No reports'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadReports(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportCard(
                        context, state.reports[index], isRtl);
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, ReviewReportEntity report, bool isRtl) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                _buildStatusChip(report.status, isRtl),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(report.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        report.reviewerName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (report.reviewRating != null)
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${report.reviewRating}'),
                          ],
                        ),
                    ],
                  ),
                  if (report.reviewComment != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      report.reviewComment!,
                      style: TextStyle(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${isRtl ? 'المنتج' : 'Product'}: ${report.productName ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Report reason
            Row(
              children: [
                Icon(Icons.flag, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '${isRtl ? 'السبب' : 'Reason'}: ${_getReasonText(report.reason, isRtl)}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            if (report.description != null) ...[
              const SizedBox(height: 8),
              Text(
                report.description!,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],

            // Reporter info
            const SizedBox(height: 8),
            Text(
              '${isRtl ? 'المُبلِّغ' : 'Reporter'}: ${report.reporterName ?? 'Unknown'}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),

            // Admin response
            if (report.adminResponse != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(report.adminResponse!)),
                  ],
                ),
              ),
            ],

            // Actions
            if (report.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        _showResponseDialog(context, report, isRtl),
                    child: Text(isRtl ? 'الرد' : 'Respond'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isRtl) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = isRtl ? 'معلق' : 'Pending';
        break;
      case 'reviewed':
        color = Colors.blue;
        text = isRtl ? 'قيد المراجعة' : 'Reviewed';
        break;
      case 'resolved':
        color = Colors.green;
        text = isRtl ? 'تم الحل' : 'Resolved';
        break;
      case 'rejected':
        color = Colors.red;
        text = isRtl ? 'مرفوض' : 'Rejected';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getReasonText(String reason, bool isRtl) {
    final reasons = {
      'offensive': isRtl ? 'محتوى مسيء' : 'Offensive',
      'spam': isRtl ? 'سبام' : 'Spam',
      'fake': isRtl ? 'تقييم مزيف' : 'Fake',
      'harassment': isRtl ? 'تحرش' : 'Harassment',
      'inappropriate': isRtl ? 'لغة غير مناسبة' : 'Inappropriate',
      'other': isRtl ? 'أخرى' : 'Other',
    };
    return reasons[reason] ?? reason;
  }

  void _showResponseDialog(
      BuildContext context, ReviewReportEntity report, bool isRtl) {
    final responseController = TextEditingController();
    String selectedStatus = 'resolved';
    bool deleteReview = false;
    bool banReviewer = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isRtl ? 'الرد على البلاغ' : 'Respond to Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isRtl ? 'الحالة' : 'Status'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: [
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text(isRtl ? 'تم الحل' : 'Resolved'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text(isRtl ? 'مرفوض' : 'Rejected'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedStatus = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: responseController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: isRtl ? 'الرد' : 'Response',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(isRtl ? 'حذف التعليق' : 'Delete Review'),
                  value: deleteReview,
                  onChanged: (value) {
                    setDialogState(() => deleteReview = value!);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                CheckboxListTile(
                  title: Text(isRtl ? 'حظر صاحب التعليق' : 'Ban Reviewer'),
                  value: banReviewer,
                  onChanged: (value) {
                    setDialogState(() => banReviewer = value!);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(isRtl ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await _cubit.respondToReport(
                  reportId: report.id,
                  status: selectedStatus,
                  adminResponse: responseController.text.trim(),
                  deleteReview: deleteReview,
                  banReviewer: banReviewer,
                );

                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  Tost.showCustomToast(
                    context,
                    success
                        ? (isRtl ? 'تم الرد بنجاح' : 'Response sent')
                        : (isRtl ? 'فشل في الرد' : 'Failed to respond'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  );
                  if (success) _loadReports();
                }
              },
              child: Text(isRtl ? 'إرسال' : 'Send'),
            ),
          ],
        ),
      ),
    );
  }
}
