import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminReportsTab extends StatelessWidget {
  final bool isRtl;
  const AdminReportsTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminLoaded) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRtl ? 'التقارير والإحصائيات' : 'Reports & Analytics',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Rankings Section
                Text(
                  isRtl ? 'الترتيبات' : 'Rankings',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildRankingsGrid(context, theme, isMobile),

                const SizedBox(height: 24),
                Text(
                  isRtl ? 'الإحصائيات العامة' : 'General Stats',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.people,
                  title: isRtl ? 'إجمالي العملاء' : 'Total Customers',
                  value: '${state.stats.totalCustomers}',
                  color: Colors.blue,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.store,
                  title: isRtl ? 'إجمالي التجار' : 'Total Merchants',
                  value: '${state.stats.totalMerchants}',
                  color: Colors.purple,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.inventory,
                  title: isRtl ? 'إجمالي المنتجات' : 'Total Products',
                  value: '${state.stats.totalProducts}',
                  subtitle:
                      '${state.stats.activeProducts} ${isRtl ? 'نشط' : 'active'}',
                  color: Colors.green,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.receipt_long,
                  title: isRtl ? 'إجمالي الطلبات' : 'Total Orders',
                  value: '${state.stats.totalOrders}',
                  subtitle:
                      '${state.stats.pendingOrders} ${isRtl ? 'معلق' : 'pending'}',
                  color: Colors.orange,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.attach_money,
                  title: isRtl ? 'إجمالي الإيرادات' : 'Total Revenue',
                  value:
                      '${state.stats.totalRevenue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                  color: Colors.teal,
                ),
                _buildReportCard(
                  theme,
                  isMobile,
                  icon: Icons.today,
                  title: isRtl ? 'طلبات اليوم' : 'Today Orders',
                  value: '${state.stats.todayOrders}',
                  subtitle:
                      '${state.stats.todayRevenue.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                  color: Colors.indigo,
                ),
              ],
            ),
          );
        }

        if (state is AdminLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.analytics, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(isRtl ? 'جاري تحميل التقارير...' : 'Loading reports...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<AdminCubit>().loadDashboard(),
                child: Text(isRtl ? 'تحديث' : 'Refresh'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingsGrid(
      BuildContext context, ThemeData theme, bool isMobile) {
    final rankings = [
      _RankingItem(
        icon: Icons.trending_up,
        title: isRtl ? 'التجار الأكثر مبيعاً' : 'Top Selling Merchants',
        color: Colors.green,
        type: 'top_selling',
      ),
      _RankingItem(
        icon: Icons.shopping_cart,
        title: isRtl ? 'العملاء الأكثر طلباً' : 'Top Ordering Customers',
        color: Colors.blue,
        type: 'top_customers',
      ),
      _RankingItem(
        icon: Icons.cancel,
        title: isRtl ? 'التجار الأكثر إلغاءً' : 'Most Cancellations',
        color: Colors.orange,
        type: 'most_cancellations',
      ),
      _RankingItem(
        icon: Icons.warning,
        title: isRtl ? 'تجار مشكلة (إلغاء > مكتمل)' : 'Problematic Merchants',
        color: Colors.red,
        type: 'problematic',
      ),
    ];

    if (isMobile) {
      return Column(
        children: rankings
            .map((r) => _buildRankingCard(context, theme, r, isMobile))
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: rankings
          .map((r) => _buildRankingCard(context, theme, r, isMobile))
          .toList(),
    );
  }

  Widget _buildRankingCard(
      BuildContext context, ThemeData theme, _RankingItem item, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRankingPage(context, item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(
                isRtl ? Icons.chevron_left : Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRankingPage(BuildContext context, _RankingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminCubit>(),
          child:
              _RankingsPage(type: item.type, title: item.title, isRtl: isRtl),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    ThemeData theme,
    bool isMobile, {
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
  }) {
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 28 : 32),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7))),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.bold)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: isMobile ? 11 : 12, color: color)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingItem {
  final IconData icon;
  final String title;
  final Color color;
  final String type;
  _RankingItem(
      {required this.icon,
      required this.title,
      required this.color,
      required this.type});
}

class _RankingsPage extends StatefulWidget {
  final String type;
  final String title;
  final bool isRtl;
  const _RankingsPage(
      {required this.type, required this.title, required this.isRtl});

  @override
  State<_RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<_RankingsPage> {
  List<Map<String, dynamic>> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final cubit = context.read<AdminCubit>();

    List<Map<String, dynamic>> result;
    switch (widget.type) {
      case 'top_selling':
        result = await cubit.getTopSellingMerchants();
        break;
      case 'top_customers':
        result = await cubit.getTopOrderingCustomers();
        break;
      case 'most_cancellations':
      case 'problematic':
        result = await cubit.getMerchantsCancellationStats();
        if (widget.type == 'problematic') {
          result = result.where((m) => m['is_problematic'] == true).toList();
        }
        break;
      default:
        result = [];
    }

    if (mounted) {
      setState(() {
        _data = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? Center(child: Text(widget.isRtl ? 'لا توجد بيانات' : 'No data'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _data.length,
                  itemBuilder: (context, index) =>
                      _buildItem(theme, index, _data[index]),
                ),
    );
  }

  Widget _buildItem(ThemeData theme, int index, Map<String, dynamic> item) {
    final rank = index + 1;
    final name = item['name'] ?? 'Unknown';
    final email = item['email'] ?? '';
    final id = item['id'] ?? item['user_id'] ?? item['merchant_id'] ?? '';
    final phone = item['phone'] ?? '';

    // Different display based on type
    String mainValue = '';
    String? subValue;
    Color? valueColor;

    switch (widget.type) {
      case 'top_selling':
        final sales = (item['total_sales'] ?? 0).toDouble();
        final orders = item['order_count'] ?? 0;
        mainValue =
            '${sales.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}';
        subValue = '$orders ${widget.isRtl ? 'طلب' : 'orders'}';
        valueColor = Colors.green;
        break;
      case 'top_customers':
        final spent = (item['total_spent'] ?? 0).toDouble();
        final orders = item['order_count'] ?? 0;
        mainValue = '$orders ${widget.isRtl ? 'طلب' : 'orders'}';
        subValue =
            '${spent.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}';
        valueColor = Colors.blue;
        break;
      case 'most_cancellations':
        final cancelled = item['cancelled_orders'] ?? 0;
        final rate = item['cancellation_rate'] ?? '0';
        mainValue = '$cancelled ${widget.isRtl ? 'ملغي' : 'cancelled'}';
        subValue = '$rate%';
        valueColor = Colors.orange;
        break;
      case 'problematic':
        final cancelled = item['cancelled_orders'] ?? 0;
        final delivered = item['delivered_orders'] ?? 0;
        final diff = item['difference'] ?? 0;
        mainValue = '${widget.isRtl ? 'ملغي' : 'Cancelled'}: $cancelled';
        subValue =
            '${widget.isRtl ? 'مكتمل' : 'Delivered'}: $delivered (${widget.isRtl ? 'فرق' : 'diff'}: +$diff)';
        valueColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: widget.type == 'problematic'
          ? Colors.red.withValues(alpha: 0.05)
          : null,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text(
            '$rank',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          mainValue,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: valueColor, fontSize: 14),
        ),
        trailing: subValue != null
            ? Text(subValue, style: TextStyle(fontSize: 12, color: valueColor))
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildDetailRow(widget.isRtl ? 'الاسم' : 'Name', name),
                _buildDetailRow(widget.isRtl ? 'الإيميل' : 'Email', email),
                if (phone.toString().isNotEmpty)
                  _buildDetailRow(
                      widget.isRtl ? 'الهاتف' : 'Phone', phone.toString()),
                _buildDetailRow('ID', id.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.isRtl ? 'تم النسخ' : 'Copied'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blueGrey;
    }
  }
}
