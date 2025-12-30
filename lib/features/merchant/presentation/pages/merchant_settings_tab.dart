import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../settings/presentation/widgets/user_profile_card.dart';
import '../widgets/profile_edit_dialog.dart';
import '../widgets/store_info_dialog.dart';
import '../widgets/settings_dialogs.dart';
import '../widgets/shipping_dialog/shipping_prices_dialog.dart';

class MerchantSettingsTab extends StatelessWidget {
  const MerchantSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              AppRouter.setAuthenticated(false);
              context.go('/login');
            }
          },
          child: Directionality(
            textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        isRtl ? 'الإعدادات' : 'Settings',
                        style: AppTextStyle.semiBold_20_dark_brown.copyWith(
                          fontSize: 24,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Profile Card
                      GestureDetector(
                        onTap: () => ProfileEditDialog.show(context, isRtl),
                        child: UserProfileCard(user: authState.user),
                      ),
                      const SizedBox(height: 24),
                      _SettingsSection(
                        title: isRtl ? 'الحساب' : 'Account',
                        items: [
                          _SettingsItem(
                            title: isRtl ? 'الملف الشخصي' : 'Profile',
                            icon: Icons.person_outline,
                            onTap: () => ProfileEditDialog.show(context, isRtl),
                          ),
                          _SettingsItem(
                            title:
                                isRtl ? 'معلومات المتجر' : 'Store Information',
                            icon: Icons.store_outlined,
                            onTap: () => StoreInfoDialog.show(context, isRtl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: isRtl ? 'الشحن' : 'Shipping',
                        items: [
                          _SettingsItem(
                            title: 'shipping_prices'.tr(),
                            icon: Icons.local_shipping_outlined,
                            onTap: () =>
                                ShippingPricesDialog.show(context, isRtl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: isRtl ? 'التقييمات' : 'Reviews',
                        items: [
                          _SettingsItem(
                            title: isRtl
                                ? 'المنتجات الأعلى تقييماً'
                                : 'Top Rated Products',
                            icon: Icons.star_outline,
                            onTap: () => context.push('/merchant-top-rated'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: isRtl ? 'ذكاء المخزون' : 'Inventory Insights',
                        items: [
                          _SettingsItem(
                            title: isRtl
                                ? 'تحليلات المخزون'
                                : 'Inventory Analytics',
                            icon: Icons.analytics_outlined,
                            onTap: () =>
                                context.push('/merchant-inventory-insights'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: isRtl ? 'التسويق' : 'Marketing',
                        items: [
                          _SettingsItem(
                            title: 'coupons'.tr(),
                            icon: Icons.local_offer_outlined,
                            onTap: () => context.push('/merchant-coupons'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: isRtl ? 'التفضيلات' : 'Preferences',
                        items: [
                          _SettingsItem(
                            title: isRtl ? 'اللغة' : 'Language',
                            icon: Icons.language,
                            onTap: () => context.push('/language-settings'),
                          ),
                          _SettingsItem(
                            title: isRtl ? 'المظهر' : 'Theme',
                            icon: Icons.palette_outlined,
                            onTap: () => context.push('/theme-settings'),
                          ),
                          _SettingsItem(
                            title: isRtl ? 'الإشعارات' : 'Notifications',
                            icon: Icons.notifications_outlined,
                            onTap: () =>
                                NotificationsDialog.show(context, isRtl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: isRtl ? 'المساعدة' : 'Help',
                        items: [
                          _SettingsItem(
                            title: isRtl ? 'مساعدة' : 'Help',
                            icon: Icons.help_outline,
                            onTap: () => context.push('/help'),
                          ),
                          _SettingsItem(
                            title: isRtl ? 'عن التطبيق' : 'About',
                            icon: Icons.info_outline,
                            onTap: () => context.push('/about'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        items: [
                          _SettingsItem(
                            title: 'switch_to_user_mode'.tr(),
                            icon: Icons.person,
                            onTap: () => context.go('/home'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        items: [
                          _SettingsItem(
                            title: isRtl ? 'تسجيل الخروج' : 'Logout',
                            icon: Icons.logout,
                            isDestructive: true,
                            onTap: () => LogoutDialog.show(
                              context,
                              isRtl,
                              () => context.read<AuthCubit>().signOut(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String? title;
  final List<_SettingsItem> items;

  const _SettingsSection({this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(right: 4, left: 4),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outline,
                    indent: 56,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : theme.colorScheme.primary,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? Colors.red : theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        size: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }
}
