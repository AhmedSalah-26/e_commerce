import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateFilter(context, theme, isMobile, state),
                const SizedBox(height: 20),
                _buildTitle(theme, widget.isRtl ? 'الترتيبات' : 'Rankings'),
                const SizedBox(height: 12),
                _buildRankingsGrid(context, isMobile),
                const SizedBox(height: 24),
                _buildTitle(theme, widget.isRtl ? 'الإحصائيات' : 'Statistics'),
                const SizedBox(height: 12),
                ..._buildStatCards(state, isMobile),
              ],
            ),
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildDateFilter(
      BuildContext context, ThemeData theme, bool isMobile, AdminLoaded state) {
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.date_range, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  widget.isRtl ? 'فلتر التاريخ' : 'Date Filter',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_fromDate != null || _toDate != null)
                  TextButton(
                    onPressed: _clearFilter,
                    child: Text(
                      widget.isRtl ? 'مسح' : 'Clear',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _DatePickerButton(
                  label: widget.isRtl ? 'من' : 'From',
                  date: _fromDate,
                  dateFormat: dateFormat,
                  onTap: () => _selectDate(true),
                  isRtl: widget.isRtl,
                ),
                _DatePickerButton(
                  label: widget.isRtl ? 'إلى' : 'To',
                  date: _toDate,
                  dateFormat: dateFormat,
                  onTap: () => _selectDate(false),
                  isRtl: widget.isRtl,
                ),
                ElevatedButton.icon(
                  onPressed: _applyFilter,
                  icon: const Icon(Icons.filter_alt, size: 18),
                  label: Text(widget.isRtl ? 'تطبيق' : 'Apply'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickFilterChip(
                  label: widget.isRtl ? 'اليوم' : 'Today',
                  onTap: () => _setQuickFilter(0),
                ),
                _QuickFilterChip(
                  label: widget.isRtl ? 'أمس' : 'Yesterday',
                  onTap: () => _setQuickFilter(1),
                ),
                _QuickFilterChip(
                  label: widget.isRtl ? 'آخر 7 أيام' : 'Last 7 days',
                  onTap: () => _setQuickFilter(7),
                ),
                _QuickFilterChip(
                  label: widget.isRtl ? 'آخر 30 يوم' : 'Last 30 days',
                  onTap: () => _setQuickFilter(30),
                ),
                _QuickFilterChip(
                  label: widget.isRtl ? 'هذا الشهر' : 'This month',
                  onTap: () => _setThisMonth(),
                ),
              ],
            ),
          ],
        ),
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
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _setQuickFilter(int days) {
    final now = DateTime.now();
    setState(() {
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
      _fromDate = DateTime(now.year, now.month, 1);
      _toDate = now;
    });
    _applyFilter();
  }

  void _applyFilter() {
    context.read<AdminCubit>().loadDashboard(
          fromDate: _fromDate,
          toDate: _toDate,
        );
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    context.read<AdminCubit>().loadDashboard();
  }

  Widget _buildTitle(ThemeData theme, String text) {
    return Text(text,
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildRankingsGrid(BuildContext context, bool isMobile) {
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
        .map((i) => _RankingButton(
              icon: i.$1,
              title: i.$2,
              color: i.$3,
              onTap: () => _openRankings(context, i.$4, i.$2),
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

  void _openRankings(BuildContext context, String type, String title) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AdminCubit>(),
            child: AdminRankingsPage(
                type: type, title: title, isRtl: widget.isRtl),
          ),
        ));
  }

  List<Widget> _buildStatCards(AdminLoaded state, bool isMobile) {
    final s = state.stats;
    return [
      _StatCard(
          icon: Icons.people,
          title: widget.isRtl ? 'العملاء' : 'Customers',
          value: '${s.totalCustomers}',
          color: Colors.blue,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.store,
          title: widget.isRtl ? 'التجار' : 'Merchants',
          value: '${s.totalMerchants}',
          color: Colors.purple,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.inventory,
          title: widget.isRtl ? 'المنتجات' : 'Products',
          value: '${s.totalProducts}',
          sub: '${s.activeProducts} ${widget.isRtl ? 'نشط' : 'active'}',
          color: Colors.green,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.receipt_long,
          title: widget.isRtl ? 'الطلبات' : 'Orders',
          value: '${s.totalOrders}',
          sub: '${s.pendingOrders} ${widget.isRtl ? 'معلق' : 'pending'}',
          color: Colors.orange,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.attach_money,
          title: widget.isRtl ? 'الإيرادات' : 'Revenue',
          value: s.totalRevenue.toStringAsFixed(0),
          color: Colors.teal,
          isMobile: isMobile),
      _StatCard(
          icon: Icons.today,
          title: widget.isRtl ? 'اليوم' : 'Today',
          value: '${s.todayOrders}',
          sub: s.todayRevenue.toStringAsFixed(0),
          color: Colors.indigo,
          isMobile: isMobile),
    ];
  }

  Widget _buildEmptyState(BuildContext context) {
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
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat dateFormat;
  final VoidCallback onTap;
  final bool isRtl;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.dateFormat,
    required this.onTap,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label: ', style: const TextStyle(color: Colors.grey)),
            Text(
              date != null
                  ? dateFormat.format(date!)
                  : (isRtl ? 'اختر' : 'Select'),
              style: TextStyle(
                fontWeight: date != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.calendar_today, size: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickFilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RankingButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isRtl;

  const _RankingButton(
      {required this.icon,
      required this.title,
      required this.color,
      required this.onTap,
      required this.isRtl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
              Icon(isRtl ? Icons.chevron_left : Icons.chevron_right,
                  color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? sub;
  final Color color;
  final bool isMobile;

  const _StatCard(
      {required this.icon,
      required this.title,
      required this.value,
      this.sub,
      required this.color,
      required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: isMobile ? 13 : 14, color: Colors.grey)),
                  Text(value,
                      style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold)),
                  if (sub != null)
                    Text(sub!,
                        style: TextStyle(
                            fontSize: isMobile ? 11 : 12, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
