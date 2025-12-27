import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CouponsTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final int activeCount;
  final int inactiveCount;

  const CouponsTabBar({
    super.key,
    required this.controller,
    required this.activeCount,
    required this.inactiveCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: controller,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        tabs: [
          Tab(text: '${'active_coupons'.tr()} ($activeCount)'),
          Tab(text: '${'inactive_coupons'.tr()} ($inactiveCount)'),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
