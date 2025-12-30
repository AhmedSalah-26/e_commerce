import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/models/review_report_model.dart';
import '../../domain/entities/review_report_entity.dart';
import '../cubit/review_reports_cubit.dart';
import '../widgets/review_report_card.dart';
import '../widgets/review_report_respond_sheet.dart';

class AdminReviewReportsPage extends StatelessWidget {
  const AdminReviewReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReviewReportsCubit>()..loadAdminReports(),
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
            isArabic ? 'بلاغات التعليقات' : 'Review Reports',
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
            _buildFilterChips(isArabic),
            Expanded(child: _buildReportsList(isArabic)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isArabic) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildReportsList(bool isArabic) {
    return BlocBuilder<ReviewReportsCubit, ReviewReportsState>(
      builder: (context, state) {
        if (state is ReviewReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReviewReportsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(isArabic ? 'حدث خطأ' : 'An error occurred'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context
                      .read<ReviewReportsCubit>()
                      .loadAdminReports(status: _selectedStatus),
                  child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
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
                  Icon(Icons.flag_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'لا توجد بلاغات' : 'No reports',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<ReviewReportsCubit>()
                .loadAdminReports(status: _selectedStatus),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                final report = state.reports[index];
                return ReviewReportCard(
                  report: report as ReviewReportModel,
                  isArabic: isArabic,
                  onRespond: () => _showRespondSheet(context, report, isArabic),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _filterByStatus(String? status) {
    setState(() => _selectedStatus = status);
    context.read<ReviewReportsCubit>().loadAdminReports(status: status);
  }

  void _showRespondSheet(
      BuildContext context, ReviewReportEntity report, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ReviewReportsCubit>(),
        child: ReviewReportRespondSheet(report: report, isArabic: isArabic),
      ),
    ).then((responded) {
      if (responded == true) {
        context
            .read<ReviewReportsCubit>()
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
