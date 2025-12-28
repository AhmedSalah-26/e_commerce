import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/shared_widgets/app_dialog.dart';
import '../../../domain/entities/coupon_entity.dart';

class DeleteCouponDialog extends StatelessWidget {
  final CouponEntity coupon;
  final VoidCallback onConfirm;

  const DeleteCouponDialog({
    super.key,
    required this.coupon,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required CouponEntity coupon,
    required VoidCallback onConfirm,
  }) {
    final isRtl = context.locale.languageCode == 'ar';

    return AppDialog.showConfirmation(
      context: context,
      title: 'delete_coupon'.tr(),
      message: isRtl
          ? 'هل أنت متأكد من حذف الكوبون "${coupon.code}"؟'
          : 'Are you sure you want to delete coupon "${coupon.code}"?',
      confirmText: 'delete'.tr(),
      cancelText: 'cancel'.tr(),
      icon: Icons.delete_outline,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        onConfirm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This widget is kept for backward compatibility but the static show method is preferred
    final isRtl = context.locale.languageCode == 'ar';

    return AppDialog(
      title: 'delete_coupon'.tr(),
      message: isRtl
          ? 'هل أنت متأكد من حذف الكوبون "${coupon.code}"؟'
          : 'Are you sure you want to delete coupon "${coupon.code}"?',
      confirmText: 'delete'.tr(),
      cancelText: 'cancel'.tr(),
      icon: Icons.delete_outline,
      isDestructive: true,
      onConfirm: () {
        Navigator.pop(context);
        onConfirm();
      },
    );
  }
}
