import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../widgets/copyable_row.dart';

class AdminRankingsPage extends StatefulWidget {
  final String type;
  final String title;
  final bool isRtl;

  const AdminRankingsPage({
    super.key,
    required this.type,
    required this.title,
    required this.isRtl,
  });

  @override
  State<AdminRankingsPage> createState() => _AdminRankingsPageState();
}

class _AdminRankingsPageState extends State<AdminRankingsPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? Center(child: Text(widget.isRtl ? 'لا توجد بيانات' : 'No data'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _data.length,
                  itemBuilder: (context, index) => _RankingCard(
                    rank: index + 1,
                    item: _data[index],
                    type: widget.type,
                    isRtl: widget.isRtl,
                  ),
                ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> item;
  final String type;
  final bool isRtl;

  const _RankingCard({
    required this.rank,
    required this.item,
    required this.type,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? 'Unknown';
    final email = item['email'] ?? '';
    final id = item['id'] ?? item['user_id'] ?? item['merchant_id'] ?? '';
    final phone = item['phone'] ?? '';

    final (mainValue, subValue, valueColor) = _getDisplayValues();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: type == 'problematic' ? Colors.red.withValues(alpha: 0.05) : null,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(rank),
          child: Text('$rank',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(mainValue,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: valueColor, fontSize: 14)),
        trailing: subValue != null
            ? Text(subValue, style: TextStyle(fontSize: 12, color: valueColor))
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                CopyableRow(label: isRtl ? 'الاسم' : 'Name', value: name),
                CopyableRow(label: isRtl ? 'الإيميل' : 'Email', value: email),
                if (phone.toString().isNotEmpty)
                  CopyableRow(
                      label: isRtl ? 'الهاتف' : 'Phone',
                      value: phone.toString()),
                CopyableRow(label: 'ID', value: id.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, String?, Color) _getDisplayValues() {
    switch (type) {
      case 'top_selling':
        final sales = (item['total_sales'] ?? 0).toDouble();
        final orders = item['order_count'] ?? 0;
        return (
          '${sales.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
          '$orders ${isRtl ? 'طلب' : 'orders'}',
          Colors.green
        );
      case 'top_customers':
        final spent = (item['total_spent'] ?? 0).toDouble();
        final orders = item['order_count'] ?? 0;
        return (
          '$orders ${isRtl ? 'طلب' : 'orders'}',
          '${spent.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
          Colors.blue
        );
      case 'most_cancellations':
        final cancelled = item['cancelled_orders'] ?? 0;
        final rate = item['cancellation_rate'] ?? '0';
        return (
          '$cancelled ${isRtl ? 'ملغي' : 'cancelled'}',
          '$rate%',
          Colors.orange
        );
      case 'problematic':
        final cancelled = item['cancelled_orders'] ?? 0;
        final delivered = item['delivered_orders'] ?? 0;
        final diff = item['difference'] ?? 0;
        return (
          '${isRtl ? 'ملغي' : 'Cancelled'}: $cancelled',
          '${isRtl ? 'مكتمل' : 'Delivered'}: $delivered (+$diff)',
          Colors.red
        );
      default:
        return ('', null, Colors.grey);
    }
  }

  Color _getRankColor(int rank) {
    return switch (rank) {
      1 => Colors.amber,
      2 => Colors.grey,
      3 => Colors.brown,
      _ => Colors.blueGrey
    };
  }
}
