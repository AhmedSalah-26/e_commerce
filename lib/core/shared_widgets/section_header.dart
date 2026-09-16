import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Reusable modern section header matching the custom capsule button design
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final String? viewAllText;
  final EdgeInsetsGeometry padding;
  final Color? titleColor;
  final Color? subtitleColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.viewAllText,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 8),
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title & Subtitle column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                    color: titleColor ?? theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: subtitleColor ??
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Rounded capsule "عرض الكل <" button
          if (onViewAll != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onViewAll,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRtl ? Icons.chevron_left : Icons.chevron_right,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        viewAllText ?? 'view_all'.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
