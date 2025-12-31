import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/reports/date_picker_button.dart';
import '../widgets/reports/quick_filter_chip.dart';
import '../widgets/reports/ranking_button.dart';
import '../widgets/reports/stat_card.dart';
import 'admin_rankings_page.dart';

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
                _buildTitle(theme),
                const SizedBox(height: 16),
                _buildDateFilter(theme, isMobile),
                const SizedBox(height: 24),
                _buildSectionTitle(
                    theme, widget.isRtl ? 'الإحصائيات' : 'Statistics'),
                const SizedBox(height: 12),
                ..._buildStatCards(state, isMobile),
                const SizedBox(height: 24),
                _buildSectionTitle(
                    theme, widget.isRtl ? 'الترتيبات' : 'Rankings'),
                const SizedBox(height: 12),
                _buildRankingsGrid(isMobile),
              ],
            ),
          );
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Center(
      child: Text(
        widget.isRtl ? 'التقارير والإحصائيات' : 'Reports & Statistics',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildDateFilter(ThemeData theme, bool isMobile) {
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterHeader(theme),
            const SizedBox(height: 12),
            _buildDatePickers(dateFormat),
            const SizedBox(height: 8),
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterHeader(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.date_range, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          widget.isRtl ? 'فلتر التاريخ' : 'Date Filter',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (_isFiltering)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (_fromDate != null || _toDate != null)
          TextButton(
            onPressed: _clearFilter,
            child: Text(
              widget.isRtl ? 'مسح' : 'Clear',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickers(DateFormat dateFormat) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        DatePickerButton(
          label: widget.isRtl ? 'من' : 'From',
          date: _fromDate,
          dateFormat: dateFormat,
          onTap: _isFiltering ? null : () => _selectDate(true),
          isRtl: widget.isRtl,
        ),
        DatePickerButton(
          label: widget.isRtl ? 'إلى' : 'To',
          date: _toDate,
          dateFormat: dateFormat,
          onTap: _isFiltering ? null : () => _selectDate(false),
          isRtl: widget.isRtl,
        ),
        ElevatedButton.icon(
          onPressed: _isFiltering ? null : _applyFilter,
          icon: const Icon(Icons.filter_alt, size: 18),
          label: Text(widget.isRtl ? 'تطبيق' : 'Apply'),
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        QuickFilterChip(
          label: widget.isRtl ? 'اليوم' : 'Today',
          isSelected: _selectedQuickFilter == 'today',
          onTap: _isFiltering ? null : () => _setQuickFilter(0, 'today'),
        ),
        QuickFilterChip(
          label: widget.isRtl ? 'أمس' : 'Yesterday',
          isSelected: _selectedQuickFilter == 'yesterday',
          onTap: _isFiltering ? null : () => _setQuickFilter(1, 'yesterday'),
        ),
        QuickFilterChip(
          label: widget.isRtl ? 'آخر 7 أيام' : 'Last 7 days',
          isSelected: _selectedQuickFilter == 'week',
          onTap: _isFiltering ? null : () => _setQuickFilter(7, 'week'),
        ),
        QuickFilterChip(
          label: widget.isRtl ? 'آخر 30 يوم' : 'Last 30 days',
          isSelected: _selectedQuickFilter == 'month',
          onTap: _isFiltering ? null : () => _setQuickFilter(30, 'month'),
        ),
        QuickFilterChip(
          label: widget.isRtl ? 'هذا الشهر' : 'This month',
          isSelected: _selectedQuickFilter == 'this_month',
          onTap: _isFiltering ? null : _setThisMonth,
        ),
      ],
    );
  }

  Widget _buildRankingsGrid(bool isMobile) {
    final items = [
      (
        Icons.trending_up,
        widget.isRtl ? 'التجار الأكثر مبيعاً' : 'Top Selling',
        Colors.green,
        'top_selling'
      ),
      (
        Icons.shopping_cart,
        widget.isRtl ? 'العملاء الأكثر طلباً' : 'Top Customers',
        Colors.blue,
        'top_customers'
      ),
      (
        Icons.cancel,
        widget.isRtl ? 'الأكثر إلغاءً' : 'Most Cancellations',
        Colors.orange,
        'most_cancellations'
      ),
      (
        Icons.warning,
        widget.isRtl ? 'تجار مشكلة' : 'Problematic',
        Colors.red,
        'problematic'
      ),
    ];

    final cards = items
        .map((i) => RankingButton(
              icon: i.$1,
              title: i.$2,
              color: i.$3,
              onTap: () => _openRankings(i.$4, i.$2),
              isRtl: widget.isRtl,
            ))
        .toList();

    if (isMobile) return Column(children: cards);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: cards,
    );
  }

  List<Widget> _buildStatCards(AdminLoaded state, bool isMobile) {
    final s = state.stats;
    return [
      StatCard(
          icon: Icons.people,
          title: widget.isRtl ? 'العملاء' : 'Customers',
          value: '${s.totalCustomers}',
          color: Colors.blue,
          isMobile: isMobile),
      StatCard(
          icon: Icons.store,
          title: widget.isRtl ? 'التجار' : 'Merchants',
          value: '${s.totalMerchants}',
          color: Colors.purple,
          isMobile: isMobile),
      StatCard(
          icon: Icons.inventory,
          title: widget.isRtl ? 'المنتجات' : 'Products',
          value: '${s.totalProducts}',
          sub: '${s.activeProducts} ${widget.isRtl ? 'نشط' : 'active'}',
          color: Colors.green,
          isMobile: isMobile),
      StatCard(
          icon: Icons.receipt_long,
          title: widget.isRtl ? 'الطلبات' : 'Orders',
          value: '${s.totalOrders}',
          sub: '${s.pendingOrders} ${widget.isRtl ? 'معلق' : 'pending'}',
          color: Colors.orange,
          isMobile: isMobile),
      StatCard(
          icon: Icons.attach_money,
          title: widget.isRtl ? 'الإيرادات' : 'Revenue',
          value: s.totalRevenue.toStringAsFixed(0),
          color: Colors.teal,
          isMobile: isMobile),
      StatCard(
          icon: Icons.today,
          title: widget.isRtl ? 'اليوم' : 'Today',
          value: '${s.todayOrders}',
          sub: s.todayRevenue.toStringAsFixed(0),
          color: Colors.indigo,
          isMobile: isMobile),
    ];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<AdminCubit>().loadDashboard(),
            child: Text(widget.isRtl ? 'تحديث' : 'Refresh'),
          ),
        ],
      ),
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
