import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/notifications_cubit.dart';

void showClearAllDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('clear_all_notifications'.tr()),
      content: Text('clear_all_notifications_confirm'.tr()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'cancel'.tr(),
            style: const TextStyle(color: AppColours.greyDark),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.read<NotificationsCubit>().clearAllNotifications();
          },
          child: Text(
            'delete'.tr(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
