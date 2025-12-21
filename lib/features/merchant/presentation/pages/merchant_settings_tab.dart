import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Core/Theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

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
                // Account section
                _buildSectionTitle(isRtl ? 'الحساب' : 'Account'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSettingItem(
                    isRtl ? 'الملف الشخصي' : 'Profile',
                    Icons.person_outline,
                    () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    isRtl ? 'معلومات المتجر' : 'Store Information',
                    Icons.store_outlined,
                    () {},
                  ),
                ]),
                const SizedBox(height: 16),
                // Preferences section
                _buildSectionTitle(isRtl ? 'التفضيلات' : 'Preferences'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSettingItem(
                    isRtl ? 'اللغة' : 'Language',
                    Icons.language,
                    () => _showLanguageDialog(context, isRtl),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    isRtl ? 'الإشعارات' : 'Notifications',
                    Icons.notifications_outlined,
                    () {},
                  ),
                ]),
                const SizedBox(height: 16),
                // Help section
                _buildSectionTitle(isRtl ? 'المساعدة' : 'Help'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSettingItem(
                    isRtl ? 'مساعدة' : 'Help',
                    Icons.help_outline,
                    () => context.push('/help'),
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    isRtl ? 'عن التطبيق' : 'About',
                    Icons.info_outline,
                    () => context.push('/about'),
                  ),
                ]),
                const SizedBox(height: 16),
                // Logout
                _buildSettingsCard([
                  _buildSettingItem(
                    isRtl ? 'تسجيل الخروج' : 'Logout',
                    Icons.logout,
                    () => _handleLogout(context, isRtl),
                    isDestructive: true,
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColours.greyDark,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColours.greyLight, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColours.greyLighter,
      indent: 56,
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
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
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColours.greyMedium,
        size: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context, bool isRtl) {
    showDialog(
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

  void _handleLogout(BuildContext context, bool isRtl) {
    showDialog(
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
              style: TextStyle(color: AppColours.greyDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
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
