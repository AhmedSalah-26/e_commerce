import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import 'copyable_row.dart';
import 'status_chip.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isRtl;
  final bool isMobile;
  final VoidCallback onRefresh;

  const OrderCard({
    super.key,
    required this.order,
    required this.isRtl,
    required this.isMobile,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = order['status'] ?? 'pending';
    final priority = order['priority'] ?? 'normal';
    final total = (order['total'] ?? 0).toDouble();
    final orderId = (order['id'] ?? '').toString();
    final customerName = order['customer_name'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _getPriorityBorder(priority),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
        childrenPadding:
            EdgeInsets.fromLTRB(isMobile ? 12 : 16, 0, isMobile ? 12 : 16, 12),
        leading: _buildLeading(status),
        title: _buildTitle(orderId, priority),
        subtitle: _buildSubtitle(theme, customerName, total),
        trailing: StatusChip(status: status, isRtl: isRtl),
        children: [
          _OrderDetails(order: order, isRtl: isRtl),
          const SizedBox(height: 12),
          _OrderActions(
            order: order,
            isRtl: isRtl,
            status: status,
            onRefresh: onRefresh,
          ),
        ],
      ),
    );
  }

  BorderSide _getPriorityBorder(String priority) {
    return switch (priority) {
      'urgent' => const BorderSide(color: Colors.red, width: 2),
      'high' => const BorderSide(color: Colors.orange, width: 1),
      _ => BorderSide.none,
    };
  }

  Widget _buildLeading(String status) {
    return CircleAvatar(
      backgroundColor: _getStatusColor(status),
      radius: isMobile ? 18 : 22,
      child: Icon(Icons.receipt, color: Colors.white, size: isMobile ? 18 : 22),
    );
  }

  Widget _buildTitle(String orderId, String priority) {
    final displayId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    return Row(
      children: [
        Text('#$displayId',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16)),
        const SizedBox(width: 8),
        PriorityChip(priority: priority, isRtl: isRtl),
      ],
    );
  }

  Widget _buildSubtitle(ThemeData theme, String name, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: TextStyle(fontSize: isMobile ? 13 : 14)),
        Text('${total.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
            style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      ],
    );
  }

  Color _getStatusColor(String s) =>
      {
        'pending': Colors.orange,
        'processing': Colors.blue,
        'shipped': Colors.purple,
        'delivered': Colors.green,
        'cancelled': Colors.red,
        'closed': Colors.grey
      }[s] ??
      Colors.grey;
}

class _OrderDetails extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isRtl;

  const _OrderDetails({required this.order, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderId = (order['id'] ?? '').toString();
    final customerName = order['customer_name'] ?? '';
    final customerPhone = order['customer_phone'] ?? '';
    final profile = order['profiles'];
    final userEmail = profile?['email'] ?? '';
    final userId = profile?['id'] ?? order['user_id'] ?? '';
    final address = order['shipping_address'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CopyableRow(
              label: isRtl ? 'رقم الطلب' : 'Order ID',
              value: orderId,
              labelWidth: 90),
          CopyableRow(
              label: isRtl ? 'الاسم' : 'Name',
              value: customerName,
              labelWidth: 90),
          CopyableRow(
              label: isRtl ? 'الهاتف' : 'Phone',
              value: customerPhone,
              labelWidth: 90),
          if (userEmail.isNotEmpty)
            CopyableRow(
                label: isRtl ? 'الإيميل' : 'Email',
                value: userEmail,
                labelWidth: 90),
          if (userId.toString().isNotEmpty)
            CopyableRow(
                label: 'User ID', value: userId.toString(), labelWidth: 90),
          if (address.isNotEmpty)
            CopyableRow(
                label: isRtl ? 'العنوان' : 'Address',
                value: address,
                labelWidth: 90),
        ],
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  final Map<String, dynamic> order;
  final bool isRtl;
  final String status;
  final VoidCallback onRefresh;

  const _OrderActions({
    required this.order,
    required this.isRtl,
    required this.status,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (status != 'closed' && status != 'cancelled')
          _ActionBtn(
            label: isRtl ? 'الحالة' : 'Status',
            icon: Icons.update,
            onTap: () => _showStatusDialog(context),
          ),
        _ActionBtn(
          label: isRtl ? 'الأولوية' : 'Priority',
          icon: Icons.flag,
          onTap: () => _showPriorityDialog(context),
        ),
        _ActionBtn(
          label: isRtl ? 'تعديل' : 'Edit',
          icon: Icons.edit,
          onTap: () => _showEditDialog(context),
        ),
        if (status == 'closed')
          _ActionBtn(
            label: isRtl ? 'فتح' : 'Reopen',
            icon: Icons.lock_open,
            color: Colors.green,
            onTap: () => _updateStatus(context, 'delivered'),
          )
        else if (status == 'delivered' || status == 'cancelled')
          _ActionBtn(
            label: isRtl ? 'إغلاق' : 'Close',
            icon: Icons.lock,
            onTap: () => _updateStatus(context, 'closed'),
          ),
      ],
    );
  }

  void _showStatusDialog(BuildContext context) {
    final current = order['status'] ?? 'pending';
    final statuses = [
      'pending',
      'processing',
      'shipped',
      'delivered',
      'cancelled'
    ];
    final labels = isRtl
        ? {
            'pending': 'جديد',
            'processing': 'تجهيز',
            'shipped': 'شحن',
            'delivered': 'تم',
            'cancelled': 'ملغي'
          }
        : null;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(isRtl ? 'تغيير الحالة' : 'Change Status'),
        children: statuses
            .map((s) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (s != current) _updateStatus(context, s);
                  },
                  child: Row(children: [
                    Icon(
                      s == current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: _getStatusColor(s),
                    ),
                    const SizedBox(width: 8),
                    Text(labels?[s] ?? s),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  void _showPriorityDialog(BuildContext context) {
    final current = order['priority'] ?? 'normal';
    final priorities = ['low', 'normal', 'high', 'urgent'];
    final labels = isRtl
        ? {'low': 'منخفض', 'normal': 'عادي', 'high': 'عالي', 'urgent': 'عاجل'}
        : null;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(isRtl ? 'تغيير الأولوية' : 'Change Priority'),
        children: priorities
            .map((p) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (p != current) _updatePriority(context, p);
                  },
                  child: Row(children: [
                    Icon(p == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off),
                    const SizedBox(width: 8),
                    Text(labels?[p] ?? p),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final addressCtrl =
        TextEditingController(text: order['shipping_address'] ?? '');
    final notesCtrl = TextEditingController(text: order['admin_notes'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isRtl ? 'تعديل' : 'Edit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressCtrl,
              decoration:
                  InputDecoration(labelText: isRtl ? 'العنوان' : 'Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration:
                  InputDecoration(labelText: isRtl ? 'ملاحظات' : 'Notes'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isRtl ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _updateDetails(context, {
                'shipping_address': addressCtrl.text,
                'admin_notes': notesCtrl.text,
              });
            },
            child: Text(isRtl ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final cubit = context.read<AdminCubit>();
    final ok = await cubit.updateOrderStatus(order['id'], newStatus);
    if (ok && context.mounted) {
      onRefresh();
      _showSnack(context);
    }
  }

  Future<void> _updatePriority(BuildContext context, String priority) async {
    final cubit = context.read<AdminCubit>();
    final ok = await cubit.updateOrderPriority(order['id'], priority);
    if (ok && context.mounted) {
      onRefresh();
      _showSnack(context);
    }
  }

  Future<void> _updateDetails(
      BuildContext context, Map<String, dynamic> data) async {
    final cubit = context.read<AdminCubit>();
    final ok = await cubit.updateOrderDetails(order['id'], data);
    if (ok && context.mounted) {
      onRefresh();
      _showSnack(context);
    }
  }

  void _showSnack(BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(isRtl ? 'تم' : 'Done')));
  }

  Color _getStatusColor(String s) =>
      {
        'pending': Colors.orange,
        'processing': Colors.blue,
        'shipped': Colors.purple,
        'delivered': Colors.green,
        'cancelled': Colors.red
      }[s] ??
      Colors.grey;
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _ActionBtn(
      {required this.label,
      required this.icon,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      style: color != null
          ? OutlinedButton.styleFrom(side: BorderSide(color: color!))
          : null,
    );
  }
}
