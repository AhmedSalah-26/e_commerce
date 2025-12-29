import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminOrdersTab extends StatefulWidget {
  final bool isRtl;
  const AdminOrdersTab({super.key, required this.isRtl});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _statuses = [
    '',
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadOrders('');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadOrders(_statuses[_tabController.index]);
    }
  }

  void _loadOrders(String status) {
    context.read<AdminCubit>().loadOrders(
          status: status.isEmpty ? null : status,
          search:
              _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        _buildHeader(theme, isMobile),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: theme.colorScheme.primary,
          labelStyle: TextStyle(fontSize: isMobile ? 11 : 13),
          tabs: [
            Tab(text: widget.isRtl ? 'الكل' : 'All'),
            Tab(text: widget.isRtl ? 'معلق' : 'Pending'),
            Tab(text: widget.isRtl ? 'تجهيز' : 'Processing'),
            Tab(text: widget.isRtl ? 'شحن' : 'Shipped'),
            Tab(text: widget.isRtl ? 'تم' : 'Delivered'),
            Tab(text: widget.isRtl ? 'ملغي' : 'Cancelled'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(6, (_) => _buildOrdersList(isMobile)),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: widget.isRtl
              ? 'بحث بالاسم أو الهاتف...'
              : 'Search by name or phone...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: isMobile,
        ),
        onSubmitted: (_) => _loadOrders(_statuses[_tabController.index]),
      ),
    );
  }

  Widget _buildOrdersList(bool isMobile) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        if (state is AdminOrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminError) {
          return Center(child: Text(state.message));
        }
        if (state is AdminOrdersLoaded) {
          if (state.orders.isEmpty) {
            return Center(
              child: Text(widget.isRtl ? 'لا توجد طلبات' : 'No orders found'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _loadOrders(_statuses[_tabController.index]),
            child: ListView.builder(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) =>
                  _buildOrderCard(state.orders[index], isMobile),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isMobile) {
    final theme = Theme.of(context);
    final status = order['status'] ?? 'pending';
    final total = (order['total'] ?? 0).toDouble();
    final customerName = order['customer_name'] ?? '';
    final orderId = (order['id'] ?? '').toString();

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ),
                _buildStatusChip(status, isMobile),
              ],
            ),
            const SizedBox(height: 8),
            Text(customerName, style: TextStyle(fontSize: isMobile ? 13 : 14)),
            const SizedBox(height: 4),
            Text(
              '${total.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusButtons(order, status, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: isMobile ? 11 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusButtons(
      Map<String, dynamic> order, String status, bool isMobile) {
    if (status == 'delivered' || status == 'cancelled')
      return const SizedBox.shrink();

    final nextStatus = _getNextStatus(status);
    if (nextStatus == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _updateStatus(order['id'], nextStatus),
            icon: Icon(Icons.check, size: isMobile ? 16 : 18),
            label: Text(
              _getStatusText(nextStatus),
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ),
        if (status != 'cancelled') ...[
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _updateStatus(order['id'], 'cancelled'),
            icon:
                Icon(Icons.close, size: isMobile ? 16 : 18, color: Colors.red),
            label: Text(
              widget.isRtl ? 'إلغاء' : 'Cancel',
              style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red)),
          ),
        ],
      ],
    );
  }

  String? _getNextStatus(String current) {
    switch (current) {
      case 'pending':
        return 'processing';
      case 'processing':
        return 'shipped';
      case 'shipped':
        return 'delivered';
      default:
        return null;
    }
  }

  Future<void> _updateStatus(String orderId, String status) async {
    final success =
        await context.read<AdminCubit>().updateOrderStatus(orderId, status);
    if (success) {
      _loadOrders(_statuses[_tabController.index]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isRtl ? 'تم التحديث' : 'Updated')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    if (widget.isRtl) {
      switch (status) {
        case 'pending':
          return 'معلق';
        case 'processing':
          return 'تجهيز';
        case 'shipped':
          return 'شحن';
        case 'delivered':
          return 'تم التوصيل';
        case 'cancelled':
          return 'ملغي';
        default:
          return status;
      }
    }
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }
}
