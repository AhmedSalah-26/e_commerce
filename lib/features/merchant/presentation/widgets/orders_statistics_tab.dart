import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';

class OrdersStatisticsTab extends StatefulWidget {
  final String merchantId;

  const OrdersStatisticsTab({super.key, required this.merchantId});

  @override
  State<OrdersStatisticsTab> createState() => _OrdersStatisticsTabState();
}

class _OrdersStatisticsTabState extends State<OrdersStatisticsTab> {
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isInitialLoad = true;
  String _selectedPeriod = 'week'; // Default to week

  @override
  void initState() {
    super.initState();
    _setDateRange('week'); // Set default to week
  }

  void _setDateRange(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _selectedPeriod = period;
      _endDate = today;

      switch (period) {
        case 'day':
          _startDate = today;
          break;
        case 'week':
          _startDate = today.subtract(const Duration(days: 7));
          break;
        case 'month':
          _startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case '3months':
          _startDate = DateTime(now.year, now.month - 3, now.day);
          break;
        case 'custom':
          // Keep current dates for custom
          break;
      }
    });
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    // Only show loading on initial load
    if (_isInitialLoad) {
      setState(() => _isLoading = true);
    }
    final stats = await context
        .read<OrdersCubit>()
        .getMerchantStatistics(widget.merchantId, _startDate, _endDate);
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
        _isInitialLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateFilter(isRtl, theme),
          const SizedBox(height: 20),
          _buildSummaryCards(isRtl, theme),
          const SizedBox(height: 20),
          _buildStatusBreakdown(isRtl, theme),
        ],
      ),
    );
  }

  Widget _buildDateFilter(bool isRtl, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isRtl ? 'فلترة حسب التاريخ' : 'Filter by Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                )),
            const SizedBox(height: 12),
            // Quick filter buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip(isRtl ? 'يوم' : 'Day', 'day', isRtl, theme),
                  const SizedBox(width: 8),
                  _buildPeriodChip(
                      isRtl ? 'أسبوع' : 'Week', 'week', isRtl, theme),
                  const SizedBox(width: 8),
                  _buildPeriodChip(
                      isRtl ? 'شهر' : 'Month', 'month', isRtl, theme),
                  const SizedBox(width: 8),
                  _buildPeriodChip(
                      isRtl ? '3 شهور' : '3 Months', '3months', isRtl, theme),
                  const SizedBox(width: 8),
                  _buildPeriodChip(
                      isRtl ? 'مخصص' : 'Custom', 'custom', isRtl, theme),
                ],
              ),
            ),
            if (_selectedPeriod == 'custom') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                      child: _buildDateButton(isRtl ? 'من' : 'From', _startDate,
                          true, isRtl, theme)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildDateButton(
                          isRtl ? 'إلى' : 'To', _endDate, false, isRtl, theme)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(
      String label, String period, bool isRtl, ThemeData theme) {
    final isSelected = _selectedPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _setDateRange(period),
      selectedColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: theme.colorScheme.primary,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildDateButton(
      String label, DateTime? date, bool isStart, bool isRtl, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startDate = picked;
            } else {
              _endDate = picked;
            }
          });
          _loadStatistics();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isRtl, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildSummaryCard(
              isRtl ? 'إجمالي الطلبات' : 'Total Orders',
              '${_stats['total'] ?? 0}',
              theme.colorScheme.primary,
              Icons.receipt_long,
              theme,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildSummaryCard(
              isRtl ? 'الإيرادات' : 'Revenue',
              '${(_stats['revenue'] ?? 0.0).toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
              Colors.green,
              Icons.attach_money,
              theme,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, Color color, IconData icon, ThemeData theme) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(bool isRtl, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isRtl ? 'تفصيل الحالات' : 'Status Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                )),
            const SizedBox(height: 16),
            _buildStatusRow(isRtl ? 'قيد الانتظار' : 'Pending',
                _stats['pending'] ?? 0, Colors.orange, theme),
            _buildStatusRow(isRtl ? 'قيد التجهيز' : 'Processing',
                _stats['processing'] ?? 0, Colors.blue, theme),
            _buildStatusRow(isRtl ? 'تم الشحن' : 'Shipped',
                _stats['shipped'] ?? 0, Colors.purple, theme),
            _buildStatusRow(isRtl ? 'تم التوصيل' : 'Delivered',
                _stats['delivered'] ?? 0, Colors.green, theme),
            _buildStatusRow(isRtl ? 'ملغي' : 'Cancelled',
                _stats['cancelled'] ?? 0, Colors.red, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(
      String label, int count, Color color, ThemeData theme) {
    final total = _stats['total'] ?? 1;
    final percentage = total > 0 ? (count / total * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(label,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ))),
              Text('$count',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('(${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  )),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: theme.scaffoldBackgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
