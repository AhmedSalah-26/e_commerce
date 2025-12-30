import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../routing/app_router.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double iconSize;
  final EdgeInsets padding;
  final Widget? customIllustration;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize = 64,
    this.padding = const EdgeInsets.all(32),
    this.customIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIllustration != null)
              customIllustration!
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (iconColor ?? colorScheme.primary).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor ?? colorScheme.primary,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStates {
  static Widget noProducts(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'no_products'.tr(),
      subtitle: 'try_different_search'.tr(),
      actionLabel: 'start_shopping'.tr(),
      onAction: () => context.go('/home'),
    );
  }

  static Widget noOrders(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'no_orders'.tr(),
      subtitle: 'start_shopping_desc'.tr(),
      actionLabel: 'start_shopping'.tr(),
      onAction: () => context.go('/home'),
    );
  }

  static Widget emptyCart(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: 'empty_cart'.tr(),
      subtitle: 'empty_cart_desc'.tr(),
      actionLabel: 'start_shopping'.tr(),
      onAction: () => context.go('/home'),
    );
  }

  static Widget noFavorites(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'no_favorites'.tr(),
      subtitle: 'no_favorites_desc'.tr(),
      actionLabel: 'browse_products'.tr(),
      onAction: () => context.go('/home'),
    );
  }

  static Widget noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_off_outlined,
      title: 'لا توجد إشعارات',
      subtitle: 'أنت محدث بالكامل',
    );
  }

  static Widget noReviews({VoidCallback? onWriteReview}) {
    return EmptyStateWidget(
      icon: Icons.rate_review_outlined,
      title: 'no_reviews'.tr(),
      subtitle: 'be_first_to_review'.tr(),
      actionLabel: onWriteReview != null ? 'write_review'.tr() : null,
      onAction: onWriteReview,
    );
  }

  static Widget noSearchResults({String? query, VoidCallback? onClearSearch}) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'no_results'.tr(),
      subtitle: query != null
          ? 'لا توجد نتائج لـ "$query"'
          : 'try_different_keywords'.tr(),
      actionLabel: onClearSearch != null ? 'clear_search'.tr() : null,
      onAction: onClearSearch,
    );
  }

  static Widget noReports() {
    return const EmptyStateWidget(
      icon: Icons.report_outlined,
      title: 'لا توجد تقارير',
      subtitle: 'كل شيء واضح',
    );
  }

  static Widget noData({String? message, VoidCallback? onRefresh}) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'no_data'.tr(),
      subtitle: message,
      actionLabel: onRefresh != null ? 'refresh'.tr() : null,
      onAction: onRefresh,
    );
  }

  static Widget loginRequired(BuildContext context, {String? message}) {
    return EmptyStateWidget(
      icon: Icons.lock_outline,
      title: 'login_required'.tr(),
      subtitle: message ?? 'login_to_continue'.tr(),
      actionLabel: 'login'.tr(),
      onAction: () {
        AppRouter.setAuthenticated(false);
        context.go('/login');
      },
    );
  }
}
