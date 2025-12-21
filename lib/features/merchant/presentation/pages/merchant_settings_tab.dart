import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/profile_edit_dialog.dart';
import '../widgets/store_info_dialog.dart';
import '../widgets/settings_dialogs.dart';

class MerchantSettingsTab extends StatelessWidget {
  const MerchantSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColours.white,
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
                    color: AppColours.primary,
                  ),
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
                      title: isRtl ? 'معلومات المتجر' : 'Store Information',
                      icon: Icons.store_outlined,
                      onTap: () => StoreInfoDialog.show(context, isRtl),
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
                      onTap: () => LanguageDialog.show(context, isRtl),
                    ),
                    _SettingsItem(
                      title: isRtl ? 'الإشعارات' : 'Notifications',
                      icon: Icons.notifications_outlined,
                      onTap: () => NotificationsDialog.show(context, isRtl),
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
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String? title;
  final List<_SettingsItem> items;

  const _SettingsSection({this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(right: 4, left: 4),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColours.greyDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColours.greyLight, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColours.greyLighter,
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
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : AppColours.brownLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : AppColours.brownMedium,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? Colors.red : AppColours.brownDark,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColours.greyMedium,
        size: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }
}
