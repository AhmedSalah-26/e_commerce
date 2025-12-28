import 'package:flutter/material.dart';

/// A beautifully styled dialog widget for the app
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;
  final Color? iconColor;
  final bool showCancelButton;
  final bool isDestructive;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
    this.iconColor,
    this.showCancelButton = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            if (icon != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (iconColor ?? theme.colorScheme.primary)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: iconColor ?? theme.colorScheme.primary,
                ),
              ),
            ],
            // Title
            Padding(
              padding: EdgeInsets.only(
                top: icon != null ? 16 : 24,
                left: 24,
                right: 24,
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Message or Content
            if (message != null || content != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 24,
                  right: 24,
                ),
                child: content ??
                    Text(
                      message!,
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
              ),
            const SizedBox(height: 24),
            // Buttons
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Row(
                children: [
                  if (showCancelButton) ...[
                    Expanded(
                      child: _DialogButton(
                        text: cancelText ?? 'إلغاء',
                        onPressed: onCancel ?? () => Navigator.pop(context),
                        isOutlined: true,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: _DialogButton(
                      text: confirmText ?? 'تأكيد',
                      onPressed: onConfirm ?? () => Navigator.pop(context),
                      color: isDestructive
                          ? Colors.red
                          : (confirmColor ?? theme.colorScheme.primary),
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show a confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor ?? (isDestructive ? Colors.red : null),
        isDestructive: isDestructive,
        onConfirm: () => Navigator.pop(ctx, true),
        onCancel: () => Navigator.pop(ctx, false),
      ),
    );
  }

  /// Show an info dialog with only OK button
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    String? message,
    String? buttonText,
    IconData? icon,
    Color? iconColor,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AppDialog(
        title: title,
        message: message,
        confirmText: buttonText ?? 'حسناً',
        icon: icon ?? Icons.info_outline,
        iconColor: iconColor,
        showCancelButton: false,
        onConfirm: () => Navigator.pop(ctx),
      ),
    );
  }

  /// Show a success dialog
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String? buttonText,
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.check_circle_outline,
      iconColor: Colors.green,
    );
  }

  /// Show an error dialog
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String? buttonText,
  }) {
    return showInfo(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      icon: Icons.error_outline,
      iconColor: Colors.red,
    );
  }

  /// Show a custom dialog with custom content
  static Future<T?> showCustom<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    bool showCancelButton = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AppDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        showCancelButton: showCancelButton,
        onConfirm: onConfirm ?? () => Navigator.pop(ctx),
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final Color? color;
  final ThemeData theme;

  const _DialogButton({
    required this.text,
    required this.onPressed,
    required this.theme,
    this.isOutlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? theme.colorScheme.primary;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: theme.colorScheme.outline,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
