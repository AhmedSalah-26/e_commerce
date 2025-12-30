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
  bool _loadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  static const int _pageSize = 20;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _currentPage = 0;
      _hasMore = true;
    });

    final result = await _fetchData(0);

    if (mounted) {
      setState(() {
        _data = result;
        _loading = false;
        _hasMore = result.length >= _pageSize;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;

    setState(() => _loadingMore = true);

    final nextPage = _currentPage + 1;
    final result = await _fetchData(nextPage);

    if (mounted) {
      setState(() {
        _data.addAll(result);
        _currentPage = nextPage;
        _loadingMore = false;
        _hasMore = result.length >= _pageSize;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchData(int page) async {
    final cubit = context.read<AdminCubit>();
    final offset = page * _pageSize;
    final limit = _pageSize;

    List<Map<String, dynamic>> result;
    switch (widget.type) {
      case 'top_selling':
        result = await cubit.getTopSellingMerchants(limit: limit + offset);
        break;
      case 'top_customers':
        result = await cubit.getTopOrderingCustomers(limit: limit + offset);
        break;
      case 'most_cancellations':
      case 'problematic':
        result =
            await cubit.getMerchantsCancellationStats(limit: limit + offset);
        if (widget.type == 'problematic') {
          result = result.where((m) => m['is_problematic'] == true).toList();
        }
        break;
      default:
        result = [];
    }

    // Return only the items for this page
    if (page > 0 && result.length > offset) {
      return result.skip(offset).take(limit).toList();
    }
    return result.take(limit).toList();
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
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _data.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _data.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _RankingCard(
                      rank: index + 1,
                      item: _data[index],
                      type: widget.type,
                      isRtl: widget.isRtl,
                    );
                  },
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
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
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
