import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';

class LanguageDialog {
  static Future<void> show(BuildContext context, bool isRtl) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isRtl ? 'تغيير اللغة' : 'Change Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: isRtl
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              title: const Text('العربية'),
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: !isRtl
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              title: const Text('English'),
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsDialog {
  static Future<void> show(BuildContext context, bool isRtl) {
    return showDialog(
      context: context,
      builder: (ctx) => _NotificationsDialogContent(isRtl: isRtl),
    );
  }
}

class _NotificationsDialogContent extends StatefulWidget {
  final bool isRtl;

  const _NotificationsDialogContent({required this.isRtl});

  @override
  State<_NotificationsDialogContent> createState() =>
      _NotificationsDialogContentState();
}

class _NotificationsDialogContentState
    extends State<_NotificationsDialogContent> {
  bool _orderNotifications = true;
  bool _promotionNotifications = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(widget.isRtl ? 'الإشعارات' : 'Notifications'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title:
                Text(widget.isRtl ? 'إشعارات الطلبات' : 'Order Notifications'),
            subtitle: Text(
              widget.isRtl
                  ? 'استلم إشعارات عند وصول طلبات جديدة'
                  : 'Receive notifications for new orders',
              style: const TextStyle(fontSize: 12),
            ),
            value: _orderNotifications,
            onChanged: (value) => setState(() => _orderNotifications = value),
            activeTrackColor: AppColours.primary.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.grey.shade300,
          ),
          const Divider(),
          SwitchListTile(
            title: Text(
                widget.isRtl ? 'إشعارات العروض' : 'Promotion Notifications'),
            subtitle: Text(
              widget.isRtl
                  ? 'استلم إشعارات عن العروض والتحديثات'
                  : 'Receive notifications about promotions',
              style: const TextStyle(fontSize: 12),
            ),
            value: _promotionNotifications,
            onChanged: (value) =>
                setState(() => _promotionNotifications = value),
            activeTrackColor: AppColours.primary.withValues(alpha: 0.5),
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.isRtl ? 'إغلاق' : 'Close'),
        ),
      ],
    );
  }
}

class LogoutDialog {
  static Future<void> show(
    BuildContext context,
    bool isRtl,
    VoidCallback onLogout,
  ) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isRtl ? 'تسجيل الخروج' : 'Logout'),
        content: Text(
          isRtl
              ? 'هل أنت متأكد من تسجيل الخروج؟'
              : 'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isRtl ? 'إلغاء' : 'Cancel',
              style: const TextStyle(color: AppColours.greyDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onLogout();
            },
            child: Text(
              isRtl ? 'تسجيل الخروج' : 'Logout',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
