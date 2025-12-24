import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CouponFormHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditing;

  const CouponFormHeader({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColours.brownLight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        isEditing ? 'edit_coupon'.tr() : 'add_coupon'.tr(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
