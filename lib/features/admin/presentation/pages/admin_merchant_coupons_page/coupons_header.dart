import 'package:flutter/material.dart';

class CouponsHeader extends StatelessWidget {
  final bool isRtl;
  final bool isDark;

  const CouponsHeader({
    super.key,
    required this.isRtl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Center(
        child: Text(
          isRtl ? 'كوبونات التجار' : 'Merchant Coupons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
