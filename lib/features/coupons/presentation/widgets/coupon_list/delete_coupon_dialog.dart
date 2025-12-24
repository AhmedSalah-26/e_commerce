import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    return showDialog(
      context: context,
      builder: (_) => DeleteCouponDialog(
        coupon: coupon,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return AlertDialog(
      title: Text('delete_coupon'.tr()),
      content: Text(
        isRtl
            ? 'هل أنت متأكد من حذف الكوبون "${coupon.code}"؟'
            : 'Are you sure you want to delete coupon "${coupon.code}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text('delete'.tr()),
        ),
      ],
    );
  }
}
