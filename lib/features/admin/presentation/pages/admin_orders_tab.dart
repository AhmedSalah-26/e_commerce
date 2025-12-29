import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    'cancelled',
    'closed'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
            Tab(text: widget.isRtl ? 'جديد' : 'Pending'),
            Tab(text: widget.isRtl ? 'تجهيز' : 'Processing'),
            Tab(text: widget.isRtl ? 'شحن' : 'Shipped'),
            Tab(text: widget.isRtl ? 'تم' : 'Delivered'),
            Tab(text: widget.isRtl ? 'ملغي' : 'Cancelled'),
            Tab(text: widget.isRtl ? 'مغلق' : 'Closed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: List.generate(7, (_) => _buildOrdersList(isMobile)),
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
              ? 'بحث بالاسم / الهاتف / رقم الطلب...'
              : 'Search by name / phone / order ID...',
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
                child:
                    Text(widget.isRtl ? 'لا توجد طلبات' : 'No orders found'));
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
    final priority = order['priority'] ?? 'normal';
    final total = (order['total'] ?? 0).toDouble();
    final customerName = order['customer_name'] ?? '';
    final customerPhone = order['customer_phone'] ?? '';
    final orderId = (order['id'] ?? '').toString();
    final profile = order['profiles'];
    final userEmail = profile?['email'] ?? '';
    final userId = profile?['id'] ?? order['user_id'] ?? '';
    final shippingAddress = order['shipping_address'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: priority == 'urgent'
            ? const BorderSide(color: Colors.red, width: 2)
            : priority == 'high'
                ? const BorderSide(color: Colors.orange, width: 1)
                : BorderSide.none,
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        childrenPadding:
            EdgeInsets.fromLTRB(isMobile ? 12 : 16, 0, isMobile ? 12 : 16, 12),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          radius: isMobile ? 18 : 22,
          child: Icon(Icons.receipt,
              color: Colors.white, size: isMobile ? 18 : 22),
        ),
        title: Row(
          children: [
            Text(
              '#${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16),
            ),
            const SizedBox(width: 8),
            _buildPriorityChip(priority, isMobile),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customerName, style: TextStyle(fontSize: isMobile ? 13 : 14)),
            Text(
              '${total.toStringAsFixed(0)} ${widget.isRtl ? 'ج.م' : 'EGP'}',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ],
        ),
        trailing: _buildStatusChip(status, isMobile),
        children: [
          // Customer Details Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildCopyableRow(
                    widget.isRtl ? 'رقم الطلب' : 'Order ID', orderId),
                _buildCopyableRow(
                    widget.isRtl ? 'الاسم' : 'Name', customerName),
                _buildCopyableRow(
                    widget.isRtl ? 'الهاتف' : 'Phone', customerPhone),
                if (userEmail.isNotEmpty)
                  _buildCopyableRow(
                      widget.isRtl ? 'الإيميل' : 'Email', userEmail),
                if (userId.toString().isNotEmpty)
                  _buildCopyableRow(widget.isRtl ? 'معرف العميل' : 'User ID',
                      userId.toString()),
                if (shippingAddress.isNotEmpty)
                  _buildCopyableRow(
                      widget.isRtl ? 'العنوان' : 'Address', shippingAddress),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Action Buttons
          _buildActionButtons(order, status, isMobile),
        ],
      ),
    );
  }

  Widget _buildCopyableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _copyToClipboard(value),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String priority, bool isMobile) {
    if (priority == 'normal') return const SizedBox.shrink();
    final colors = {
      'low': Colors.grey,
      'high': Colors.orange,
      'urgent': Colors.red
    };
    final labels = widget.isRtl
        ? {'low': 'منخفض', 'high': 'عالي', 'urgent': 'عاجل'}
        : {'low': 'Low', 'high': 'High', 'urgent': 'Urgent'};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors[priority]?.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(labels[priority] ?? '',
          style: TextStyle(color: colors[priority], fontSize: 10)),
    );
  }

  Widget _buildStatusChip(String status, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(_getStatusText(status),
          style: TextStyle(color: _getStatusColor(status), fontSize: 11)),
    );
  }

  Widget _buildActionButtons(
      Map<String, dynamic> order, String status, bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (status != 'closed' && status != 'cancelled')
          OutlinedButton.icon(
            onPressed: () => _showStatusDialog(order),
            icon: const Icon(Icons.update, size: 14),
            label: Text(widget.isRtl ? 'الحالة' : 'Status',
                style: const TextStyle(fontSize: 11)),
          ),
        OutlinedButton.icon(
          onPressed: () => _showPriorityDialog(order),
          icon: const Icon(Icons.flag, size: 14),
          label: Text(widget.isRtl ? 'الأولوية' : 'Priority',
              style: const TextStyle(fontSize: 11)),
        ),
        OutlinedButton.icon(
          onPressed: () => _showEditAddressDialog(order),
          icon: const Icon(Icons.edit_location, size: 14),
          label: Text(widget.isRtl ? 'العنوان' : 'Address',
              style: const TextStyle(fontSize: 11)),
        ),
        if (status == 'closed')
          OutlinedButton.icon(
            onPressed: () => _updateStatus(order['id'], 'delivered'),
            icon: const Icon(Icons.lock_open, size: 14, color: Colors.green),
            label: Text(widget.isRtl ? 'فتح' : 'Reopen',
                style: const TextStyle(fontSize: 11, color: Colors.green)),
          )
        else if (status == 'delivered' || status == 'cancelled')
          OutlinedButton.icon(
            onPressed: () => _updateStatus(order['id'], 'closed'),
            icon: const Icon(Icons.lock, size: 14),
            label: Text(widget.isRtl ? 'إغلاق' : 'Close',
                style: const TextStyle(fontSize: 11)),
          ),
      ],
    );
  }

  void _showStatusDialog(Map<String, dynamic> order) {
    final current = order['status'] ?? 'pending';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRtl ? 'تغيير الحالة' : 'Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                  .map((s) => RadioListTile<String>(
                        title: Text(_getStatusText(s)),
                        value: s,
                        groupValue: current,
                        onChanged: (v) {
                          Navigator.pop(ctx);
                          if (v != null && v != current)
                            _updateStatus(order['id'], v);
                        },
                      ))
                  .toList(),
        ),
      ),
    );
  }

  void _showPriorityDialog(Map<String, dynamic> order) {
    final current = order['priority'] ?? 'normal';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRtl ? 'تغيير الأولوية' : 'Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['low', 'normal', 'high', 'urgent']
              .map((p) => RadioListTile<String>(
                    title: Text(_getPriorityText(p)),
                    value: p,
                    groupValue: current,
                    onChanged: (v) {
                      Navigator.pop(ctx);
                      if (v != null && v != current)
                        _updatePriority(order['id'], v);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showEditAddressDialog(Map<String, dynamic> order) {
    final addressCtrl =
        TextEditingController(text: order['shipping_address'] ?? '');
    final notesCtrl = TextEditingController(text: order['admin_notes'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.isRtl ? 'تعديل' : 'Edit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressCtrl,
              decoration: InputDecoration(
                  labelText: widget.isRtl ? 'العنوان' : 'Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: InputDecoration(
                  labelText: widget.isRtl ? 'ملاحظات' : 'Notes'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(widget.isRtl ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateDetails(order['id'], {
                'shipping_address': addressCtrl.text,
                'admin_notes': notesCtrl.text
              });
            },
            child: Text(widget.isRtl ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    final ok = await context.read<AdminCubit>().updateOrderStatus(id, status);
    if (ok && mounted) {
      _loadOrders(_statuses[_tabController.index]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.isRtl ? 'تم' : 'Done')));
    }
  }

  Future<void> _updatePriority(String id, String priority) async {
    final ok =
        await context.read<AdminCubit>().updateOrderPriority(id, priority);
    if (ok && mounted) {
      _loadOrders(_statuses[_tabController.index]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.isRtl ? 'تم' : 'Done')));
    }
  }

  Future<void> _updateDetails(String id, Map<String, dynamic> data) async {
    final ok = await context.read<AdminCubit>().updateOrderDetails(id, data);
    if (ok && mounted) {
      _loadOrders(_statuses[_tabController.index]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(widget.isRtl ? 'تم' : 'Done')));
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.isRtl ? 'تم النسخ' : 'Copied')));
  }

  Color _getStatusColor(String s) {
    return {
          'pending': Colors.orange,
          'processing': Colors.blue,
          'shipped': Colors.purple,
          'delivered': Colors.green,
          'cancelled': Colors.red,
          'closed': Colors.grey
        }[s] ??
        Colors.grey;
  }

  String _getStatusText(String s) {
    if (widget.isRtl) {
      return {
            'pending': 'جديد',
            'processing': 'تجهيز',
            'shipped': 'شحن',
            'delivered': 'تم',
            'cancelled': 'ملغي',
            'closed': 'مغلق'
          }[s] ??
          s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  String _getPriorityText(String p) {
    if (widget.isRtl) {
      return {
            'low': 'منخفض',
            'normal': 'عادي',
            'high': 'عالي',
            'urgent': 'عاجل'
          }[p] ??
          p;
    }
    return p[0].toUpperCase() + p.substring(1);
  }
}
