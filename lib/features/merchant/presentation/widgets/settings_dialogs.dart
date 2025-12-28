import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/shared_widgets/app_dialog.dart';

class LanguageDialog {
  static Future<void> show(BuildContext context, bool isRtl) {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.language,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRtl ? 'تغيير اللغة' : 'Change Language',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                title: 'العربية',
                isSelected: isRtl,
                onTap: () {
                  context.setLocale(const Locale('ar'));
                  Navigator.pop(ctx);
                },
              ),
              _LanguageOption(
                title: 'English',
                isSelected: !isRtl,
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? theme.colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: theme.colorScheme.onSurface,
              ),
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
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isRtl ? 'الإشعارات' : 'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _NotificationSwitch(
              title: widget.isRtl ? 'إشعارات الطلبات' : 'Order Notifications',
              subtitle: widget.isRtl
                  ? 'استلم إشعارات عند وصول طلبات جديدة'
                  : 'Receive notifications for new orders',
              value: _orderNotifications,
              onChanged: (value) => setState(() => _orderNotifications = value),
            ),
            _NotificationSwitch(
              title:
                  widget.isRtl ? 'إشعارات العروض' : 'Promotion Notifications',
              subtitle: widget.isRtl
                  ? 'استلم إشعارات عن العروض والتحديثات'
                  : 'Receive notifications about promotions',
              value: _promotionNotifications,
              onChanged: (value) =>
                  setState(() => _promotionNotifications = value),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isRtl ? 'حفظ' : 'Save',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.outline,
          ),
        ],
      ),
    );
  }
}

class LogoutDialog {
  static Future<void> show(
    BuildContext context,
    bool isRtl,
    VoidCallback onLogout,
  ) {
    return AppDialog.showConfirmation(
      context: context,
      title: isRtl ? 'تسجيل الخروج' : 'Logout',
      message: isRtl
          ? 'هل أنت متأكد من تسجيل الخروج؟'
          : 'Are you sure you want to logout?',
      confirmText: isRtl ? 'تسجيل الخروج' : 'Logout',
      cancelText: isRtl ? 'إلغاء' : 'Cancel',
      icon: Icons.logout,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        onLogout();
      }
    });
  }
}
