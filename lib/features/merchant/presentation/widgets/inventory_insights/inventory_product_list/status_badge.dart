import 'package:flutter/material.dart';

import '../../../../domain/entities/inventory_insight_entity.dart';

class StatusBadge extends StatelessWidget {
  final StockStatus status;
  final bool isRtl;

  const StatusBadge({
    super.key,
    required this.status,
    required this.isRtl,
  });

  (String, Color) _getStatusInfo() {
    switch (status) {
      case StockStatus.outOfStock:
        return (isRtl ? 'نفذ' : 'Out', Colors.red);
      case StockStatus.lowStock:
        return (isRtl ? 'منخفض' : 'Low', Colors.orange);
      case StockStatus.deadStock:
        return (isRtl ? 'راكد' : 'Dead', Colors.grey);
      case StockStatus.overstock:
        return (isRtl ? 'فائض' : 'Over', Colors.purple);
      case StockStatus.healthy:
        return (isRtl ? 'سليم' : 'OK', Colors.green);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getStatusInfo();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
