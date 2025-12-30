import 'package:flutter/material.dart';

class SuspendCouponDialog extends StatelessWidget {
  final bool isRtl;

  const SuspendCouponDialog({super.key, required this.isRtl});

  static Future<String?> show(BuildContext context, {required bool isRtl}) {
    return showDialog<String>(
      context: context,
      builder: (_) => SuspendCouponDialog(isRtl: isRtl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reasonController = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.block, color: Colors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Text(isRtl ? 'إيقاف الكوبون' : 'Suspend Coupon'),
        ],
      ),
      content: TextField(
        controller: reasonController,
        decoration: InputDecoration(
          labelText: isRtl ? 'سبب الإيقاف' : 'Suspension Reason',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isRtl ? 'إلغاء' : 'Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, reasonController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(isRtl ? 'إيقاف' : 'Suspend'),
        ),
      ],
    );
  }
}
