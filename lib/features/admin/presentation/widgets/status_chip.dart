import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isRtl;
  final bool compact;

  const StatusChip({
    super.key,
    required this.status,
    this.isRtl = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8, vertical: compact ? 2 : 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getText(),
        style: TextStyle(
            color: _getColor(),
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getColor() {
    return {
          'pending': Colors.orange,
          'processing': Colors.blue,
          'shipped': Colors.purple,
          'delivered': Colors.green,
          'cancelled': Colors.red,
          'closed': Colors.grey,
          'active': Colors.green,
          'inactive': Colors.orange,
          'banned': Colors.red,
          'suspended': Colors.red,
        }[status] ??
        Colors.grey;
  }

  String _getText() {
    if (isRtl) {
      return {
            'pending': 'جديد',
            'processing': 'تجهيز',
            'shipped': 'شحن',
            'delivered': 'تم',
            'cancelled': 'ملغي',
            'closed': 'مغلق',
            'active': 'نشط',
            'inactive': 'معطل',
            'banned': 'محظور',
            'suspended': 'موقوف',
          }[status] ??
          status;
    }
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }
}
