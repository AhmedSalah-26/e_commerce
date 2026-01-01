import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../cubit/admin_cubit.dart';
import '../../cubit/admin_state.dart';
import '../admin_rankings_page.dart';
import 'reports_title.dart';
import 'reports_date_filter.dart';
import 'reports_stats_section.dart';
import 'reports_rankings_section.dart';
import 'reports_empty_state.dart';

class AdminReportsTab extends StatefulWidget {
  final bool isRtl;
  const AdminReportsTab({super.key, required this.isRtl});

  @override
  State<AdminReportsTab> createState() => _AdminReportsTabState();
}

class _AdminReportsTabState extends State<AdminReportsTab> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isFiltering = false;
  String? _selectedQuickFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  void _loadInitialData() {
    final state = context.read<AdminCubit>().state;
    if (state is! AdminLoaded) {
      context.read<AdminCubit>().loadDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocConsumer<AdminCubit, AdminState>(
      listenWhen: (p, c) => p is AdminLoading && c is AdminLoaded,
      listener: (_, __) {
        if (_isFiltering) setState(() => _isFiltering = false);
      },
      buildWhen: (p, c) =>
          c is AdminLoaded || (c is AdminLoading && !_isFiltering),
      builder: (context, state) {
        if (state is AdminLoading && !_isFiltering) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReportsTitle(isRtl: widget.isRtl),
                const SizedBox(height: 16),
                ReportsDateFilter(
                  isRtl: widget.isRtl,
                  isMobile: isMobile,
                  fromDate: _fromDate,
                  toDate: _toDate,
                  isFiltering: _isFiltering,
                  selectedQuickFilter: _selectedQuickFilter,
                  onSelectDate: _selectDate,
                  onApplyFilter: _applyFilter,
                  onClearFilter: _clearFilter,
                  onSetQuickFilter: _setQuickFilter,
                  onSetThisMonth: _setThisMonth,
                ),
                const SizedBox(height: 24),
                ReportsStatsSection(
                  state: state,
                  isRtl: widget.isRtl,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 24),
                ReportsRankingsSection(
                  isRtl: widget.isRtl,
                  isMobile: isMobile,
                  onOpenRankings: _openRankings,
                ),
              ],
            ),
          );
        }

        return ReportsEmptyState(
          isRtl: widget.isRtl,
          onRefresh: () => context.read<AdminCubit>().loadDashboard(),
        );
      },
    );
  }

  Future<void> _selectDate(bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? (_fromDate ?? now) : (_toDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        if (isFrom)
          _fromDate = picked;
        else
          _toDate = picked;
      });
    }
  }

  void _setQuickFilter(int days, String filterKey) {
    final now = DateTime.now();
    setState(() {
      _selectedQuickFilter = filterKey;
      if (days == 0) {
        _fromDate = DateTime(now.year, now.month, now.day);
        _toDate = now;
      } else if (days == 1) {
        final yesterday = now.subtract(const Duration(days: 1));
        _fromDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        _toDate = DateTime(
            yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
      } else {
        _fromDate = now.subtract(Duration(days: days));
        _toDate = now;
      }
    });
    _applyFilter();
  }

  void _setThisMonth() {
    final now = DateTime.now();
    setState(() {
      _selectedQuickFilter = 'this_month';
      _fromDate = DateTime(now.year, now.month, 1);
      _toDate = now;
    });
    _applyFilter();
  }

  void _applyFilter() {
    setState(() => _isFiltering = true);
    context
        .read<AdminCubit>()
        .loadDashboard(fromDate: _fromDate, toDate: _toDate);
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedQuickFilter = null;
      _isFiltering = true;
    });
    context.read<AdminCubit>().loadDashboard();
  }

  void _openRankings(String type, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminCubit>(),
          child:
              AdminRankingsPage(type: type, title: title, isRtl: widget.isRtl),
        ),
      ),
    );
  }
}
