import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CouponCodeField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;

  const CouponCodeField({
    super.key,
    required this.controller,
    required this.isEditing,
  });

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
    final randomPart =
        List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return '$randomPart$timestamp';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            enabled: !isEditing,
            textCapitalization: TextCapitalization.characters,
            validator: (v) => v?.isEmpty == true ? 'field_required'.tr() : null,
            decoration: InputDecoration(
              labelText: 'coupon_code'.tr(),
              hintText: 'SAVE20',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        if (!isEditing) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: IconButton.filled(
              onPressed: () => controller.text = _generateRandomCode(),
              icon: const Icon(Icons.auto_awesome, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              tooltip: 'generate_code'.tr(),
            ),
          ),
        ],
      ],
    );
  }
}
