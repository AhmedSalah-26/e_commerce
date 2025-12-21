import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../notifications/data/services/local_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationsSetting();
  }

  Future<void> _loadNotificationsSetting() async {
    final enabled =
        await sl<LocalNotificationService>().isNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await sl<LocalNotificationService>().setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = context.locale.languageCode == 'ar';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Directionality(
        textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColours.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'settings_title'.tr(),
                    style: AppTextStyle.semiBold_20_dark_brown.copyWith(
                      fontSize: 24,
                      color: AppColours.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // User info card
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is AuthAuthenticated) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColours.brownMedium,
                                AppColours.brownLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColours.brownMedium
                                    .withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Text(
                                  (state.user.name ?? state.user.email)[0]
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: AppColours.brownMedium,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.user.name ?? state.user.email,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        state.user.isMerchant
                                            ? 'merchant'.tr()
                                            : 'customer'.tr(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  // Settings sections
                  _buildSectionTitle('account'.tr()),
                  const SizedBox(height: 8),
                  _buildSettingsCard([
                    _buildSettingItem(
                      'edit_profile'.tr(),
                      Icons.person_outline,
                      () => context.push('/edit-profile'),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      'my_orders'.tr(),
                      Icons.receipt_long_outlined,
                      () => context.push('/orders'),
                    ),
                    _buildDivider(),
                    _buildNotificationSwitch(),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionTitle('preferences'.tr()),
                  const SizedBox(height: 8),
                  _buildSettingsCard([
                    _buildLanguageItem(context),
                    _buildDivider(),
                    _buildSettingItem(
                      'help'.tr(),
                      Icons.help_outline,
                      () => context.push('/help'),
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      'about'.tr(),
                      Icons.info_outline,
                      () => context.push('/about'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSettingsCard([
                    _buildSettingItem(
                      'logout'.tr(),
                      Icons.logout,
                      () => _handleLogout(context),
                      isDestructive: true,
                    ),
                  ]),
                  const SizedBox(height: 32),
                ],
              ),
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

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('logout'.tr()),
        content: Text('logout_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(color: AppColours.greyDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            child: Text(
              'logout'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
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

  Widget _buildLanguageItem(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColours.brownLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language,
          color: AppColours.brownMedium,
          size: 22,
        ),
      ),
      title: Text(
        'language'.tr(),
        style: TextStyle(
          fontSize: 16,
          color: AppColours.brownDark,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isArabic ? 'العربية' : 'English',
            style: TextStyle(
              color: AppColours.greyMedium,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            color: AppColours.greyMedium,
            size: 16,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Widget _buildNotificationSwitch() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColours.brownLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: AppColours.brownMedium,
          size: 22,
        ),
      ),
      title: Text(
        'notifications'.tr(),
        style: TextStyle(
          fontSize: 16,
          color: AppColours.brownDark,
        ),
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: _toggleNotifications,
        activeColor: AppColours.brownMedium,
        activeTrackColor: AppColours.brownLight.withValues(alpha: 0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('change_language'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: isArabic
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.circle_outlined, color: Colors.grey),
              title: const Text('العربية'),
              onTap: () {
                context.setLocale(const Locale('ar'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: !isArabic
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
