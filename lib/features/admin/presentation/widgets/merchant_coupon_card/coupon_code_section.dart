import 'package:flutter/material.dart';

import 'coupon_copy_button.dart';

class CouponCodeSection extends StatelessWidget {
  final String code;
  final String merchantName;
  final bool isSuspended;
  final bool isRtl;

  const CouponCodeSection({
    super.key,
    required this.code,
    required this.merchantName,
    required this.isSuspended,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                  decoration: isSuspended ? TextDecoration.lineThrough : null,
                  color: isSuspended
                      ? Colors.grey
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            CouponCopyButton(code: code, isRtl: isRtl),
          ],
        ),
        if (merchantName.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.store_rounded,
                size: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  merchantName,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
