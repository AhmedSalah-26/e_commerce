import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../domain/entities/parent_order_entity.dart';

class OrderSummaryCard extends StatelessWidget {
  final ParentOrderEntity parentOrder;

  const OrderSummaryCard({super.key, required this.parentOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'order_number'.tr()}: #${parentOrder.id.substring(0, 8)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              _OverallStatusBadge(status: parentOrder.overallStatus),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${'merchants_count'.tr()}: ${parentOrder.merchantCount}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (parentOrder.createdAt != null) ...[
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy - hh:mm a', context.locale.languageCode)
                  .format(parentOrder.createdAt!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverallStatusBadge extends StatelessWidget {
  final String status;

  const _OverallStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String displayText;

    switch (status) {
      case 'delivered':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        displayText = 'delivered'.tr();
        break;
      case 'shipped':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        displayText = 'shipped'.tr();
        break;
      case 'processing':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        displayText = 'processing'.tr();
        break;
      case 'partially_cancelled':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        displayText = 'partially_cancelled'.tr();
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        displayText = 'pending'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
