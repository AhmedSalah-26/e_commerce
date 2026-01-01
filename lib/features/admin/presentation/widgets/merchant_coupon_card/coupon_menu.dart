import 'package:flutter/material.dart';

class CouponMenu extends StatelessWidget {
  final bool isActive;
  final bool isSuspended;
  final bool isRtl;
  final VoidCallback onToggle;
  final VoidCallback onSuspend;

  const CouponMenu({
    super.key,
    required this.isActive,
    required this.isSuspended,
    required this.isRtl,
    required this.onToggle,
    required this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: theme.colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'toggle') onToggle();
        if (value == 'suspend') onSuspend();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                isActive
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
                color: isActive ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(isActive
                  ? (isRtl ? 'تعطيل' : 'Deactivate')
                  : (isRtl ? 'تفعيل' : 'Activate')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'suspend',
          child: Row(
            children: [
              Icon(
                isSuspended ? Icons.check_circle_rounded : Icons.block_rounded,
                size: 20,
                color: isSuspended ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                isSuspended
                    ? (isRtl ? 'إلغاء الإيقاف' : 'Unsuspend')
                    : (isRtl ? 'إيقاف' : 'Suspend'),
                style:
                    TextStyle(color: isSuspended ? Colors.green : Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
