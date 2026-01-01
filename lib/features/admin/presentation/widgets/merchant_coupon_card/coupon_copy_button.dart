import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CouponCopyButton extends StatelessWidget {
  final String code;
  final bool isRtl;

  const CouponCopyButton({
    super.key,
    required this.code,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isRtl ? 'تم النسخ' : 'Copied!'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.copy_rounded,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
