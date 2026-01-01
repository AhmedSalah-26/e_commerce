import 'package:flutter/material.dart';

class MerchantOrdersTabBar extends StatelessWidget {
  final TabController controller;
  final bool isRtl;
  final ThemeData theme;

  const MerchantOrdersTabBar({
    super.key,
    required this.controller,
    required this.isRtl,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor:
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        tabs: [
          Tab(text: isRtl ? 'انتظار' : 'Pending'),
          Tab(text: isRtl ? 'تجهيز' : 'Processing'),
          Tab(text: isRtl ? 'شحن' : 'Shipped'),
          Tab(text: isRtl ? 'توصيل' : 'Delivered'),
          Tab(text: isRtl ? 'ملغي' : 'Cancelled'),
          Tab(
              icon: const Icon(Icons.analytics, size: 20),
              text: isRtl ? 'إحصائيات' : 'Stats'),
        ],
      ),
    );
  }
}
