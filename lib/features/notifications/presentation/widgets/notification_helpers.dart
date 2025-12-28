import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/shared_widgets/app_dialog.dart';
import '../cubit/notifications_cubit.dart';

void showClearAllDialog(BuildContext context) {
  AppDialog.showConfirmation(
    context: context,
    title: 'clear_all_notifications'.tr(),
    message: 'clear_all_notifications_confirm'.tr(),
    confirmText: 'delete'.tr(),
    cancelText: 'cancel'.tr(),
    icon: Icons.notifications_off_outlined,
    isDestructive: true,
  ).then((confirmed) {
    if (confirmed == true) {
      context.read<NotificationsCubit>().clearAllNotifications();
    }
  });
}
