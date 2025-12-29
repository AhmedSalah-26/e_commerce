import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  final bool isRtl;
  final VoidCallback? onMenuTap;

  const AdminHeader({super.key, required this.isRtl, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isMobile ? 56 : 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            ),
          if (isMobile && onMenuTap != null) ...[
            const SizedBox(width: 8),
            Text(
              isRtl ? 'لوحة التحكم' : 'Admin',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Spacer(),
          Text(
            isRtl ? 'لوحة التحكم' : 'Admin Dashboard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
