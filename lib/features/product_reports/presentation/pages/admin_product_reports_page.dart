import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/models/product_report_model.dart';
import '../cubit/product_reports_cubit.dart';
import '../widgets/admin_report_card.dart';
import '../widgets/report_filter_chip.dart';
import '../widgets/report_respond_sheet.dart';

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
          ReportFilterChip(
            label: isArabic ? 'الكل' : 'All',
            isSelected: _selectedStatus == null,
            onTap: () => _filterByStatus(null),
          ),
          const SizedBox(width: 8),
          ReportFilterChip(
            label: isArabic ? 'قيد المراجعة' : 'Pending',
            isSelected: _selectedStatus == 'pending',
            onTap: () => _filterByStatus('pending'),
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          ReportFilterChip(
            label: isArabic ? 'تمت المراجعة' : 'Reviewed',
            isSelected: _selectedStatus == 'reviewed',
            onTap: () => _filterByStatus('reviewed'),
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          ReportFilterChip(
            label: isArabic ? 'تم الحل' : 'Resolved',
            isSelected: _selectedStatus == 'resolved',
            onTap: () => _filterByStatus('resolved'),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          ReportFilterChip(
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
    return BlocBuilder<ProductReportsCubit, ProductReportsState>(
      builder: (context, state) {
        if (state is ProductReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductReportsError) {
          return _buildErrorState(isArabic);
        }

        if (state is ProductReportsLoaded) {
          if (state.reports.isEmpty) {
            return _buildEmptyState(isArabic);
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
                return AdminReportCard(
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
    );
  }

  Widget _buildErrorState(bool isArabic) {
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
                .read<ProductReportsCubit>()
                .loadAdminReports(status: _selectedStatus),
            child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
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

  void _filterByStatus(String? status) {
    setState(() => _selectedStatus = status);
    context.read<ProductReportsCubit>().loadAdminReports(status: status);
  }

  void _showRespondDialog(
      BuildContext context, ProductReportModel report, bool isArabic) {
    final cubit = context.read<ProductReportsCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ReportRespondSheet(report: report, isArabic: isArabic),
      ),
    ).then((responded) {
      if (responded == true && mounted) {
        cubit.loadAdminReports(status: _selectedStatus);
      }
    });
  }
}
