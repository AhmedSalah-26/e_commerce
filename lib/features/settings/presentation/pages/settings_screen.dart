import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/shared_widgets/app_dialog.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../notifications/data/services/local_notification_service.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';

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
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Show login button for unauthenticated users
        if (authState is! AuthAuthenticated) {
          return Directionality(
            textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Text(
                  'settings_title'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                centerTitle: true,
              ),
              body: _buildLoginRequired(context, isRtl),
            ),
          );
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
              appBar: AppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Text(
                  'settings_title'.tr(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => context.push('/edit-profile'),
                        child: UserProfileCard(user: authState.user),
                      ),
                      const SizedBox(height: 24),
                      SettingsSection(
                        title: 'account'.tr(),
                        children: [
                          SettingsTile(
                            icon: Icons.person_outline,
                            title: 'edit_profile'.tr(),
                            onTap: () => context.push('/edit-profile'),
                            showDivider: false,
                          ),
                          SettingsTile(
                            icon: Icons.receipt_long_outlined,
                            title: 'my_orders'.tr(),
                            onTap: () => context.push('/orders'),
                            showDivider: false,
                          ),
                          SettingsSwitchTile(
                            icon: Icons.notifications_outlined,
                            title: 'notifications'.tr(),
                            value: _notificationsEnabled,
                            onChanged: _toggleNotifications,
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SettingsSection(
                        title: 'preferences'.tr(),
                        children: [
                          SettingsTile(
                            icon: Icons.language,
                            title: 'language'.tr(),
                            subtitle: context.locale.languageCode == 'ar'
                                ? 'العربية'
                                : 'English',
                            onTap: () => context.push('/language-settings'),
                            showDivider: false,
                          ),
                          BlocBuilder<ThemeCubit, ThemeState>(
                            builder: (context, themeState) {
                              return SettingsTile(
                                icon: themeState.themeMode == AppThemeMode.dark
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                title: 'theme'.tr(),
                                subtitle:
                                    themeState.themeMode == AppThemeMode.dark
                                        ? 'dark_mode'.tr()
                                        : 'light_mode'.tr(),
                                onTap: () => context.push('/theme-settings'),
                                showDivider: false,
                              );
                            },
                          ),
                          SettingsTile(
                            icon: Icons.help_outline,
                            title: 'help'.tr(),
                            onTap: () => context.push('/help'),
                            showDivider: false,
                          ),
                          SettingsTile(
                            icon: Icons.info_outline,
                            title: 'about'.tr(),
                            onTap: () => context.push('/about'),
                            showDivider: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SettingsSection(
                        title: '',
                        children: [
                          SettingsTile(
                            icon: Icons.logout,
                            title: 'logout'.tr(),
                            onTap: () => _handleLogout(context),
                            iconColor: Colors.red,
                            showDivider: false,
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

  Widget _buildLoginRequired(BuildContext context, bool isRtl) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'login_required'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'login_to_access_settings'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  AppRouter.setAuthenticated(false);
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ).tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    AppDialog.showConfirmation(
      context: context,
      title: 'logout'.tr(),
      message: 'logout_confirm'.tr(),
      confirmText: 'logout'.tr(),
      cancelText: 'cancel'.tr(),
      icon: Icons.logout,
      isDestructive: true,
    ).then((confirmed) {
      if (confirmed == true) {
        authCubit.signOut();
      }
    });
  }
}
