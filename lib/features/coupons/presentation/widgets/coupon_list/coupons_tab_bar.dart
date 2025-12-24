import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

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
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppColours.brownMedium,
        unselectedLabelColor: AppColours.greyMedium,
        indicatorColor: AppColours.brownMedium,
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
