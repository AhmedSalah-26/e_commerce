import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class AdminSettingsTab extends StatelessWidget {
  final bool isRtl;
  const AdminSettingsTab({super.key, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRtl ? 'الإعدادات' : 'Settings',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSection(
            theme,
            isMobile,
            title: isRtl ? 'الحساب' : 'Account',
            children: [
              _buildSettingItem(
                theme,
                icon: Icons.person,
                title: isRtl ? 'الملف الشخصي' : 'Profile',
                onTap: () => context.push('/edit-profile'),
              ),
              _buildSettingItem(
                theme,
                icon: Icons.lock,
                title: isRtl ? 'تغيير كلمة المرور' : 'Change Password',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            isMobile,
            title: isRtl ? 'التطبيق' : 'App',
            children: [
              _buildSettingItem(
                theme,
                icon: Icons.language,
                title: isRtl ? 'اللغة' : 'Language',
                onTap: () => context.push('/language-settings'),
              ),
              _buildSettingItem(
                theme,
                icon: Icons.palette,
                title: isRtl ? 'المظهر' : 'Theme',
                onTap: () => context.push('/theme-settings'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            isMobile,
            title: isRtl ? 'التنقل' : 'Navigation',
            children: [
              _buildSettingItem(
                theme,
                icon: Icons.home,
                title: isRtl ? 'الصفحة الرئيسية' : 'Home Page',
                onTap: () => context.go('/home'),
              ),
              _buildSettingItem(
                theme,
                icon: Icons.store,
                title: isRtl ? 'لوحة التاجر' : 'Merchant Dashboard',
                onTap: () => context.go('/merchant-dashboard'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            theme,
            isMobile,
            title: isRtl ? 'أخرى' : 'Other',
            children: [
              _buildSettingItem(
                theme,
                icon: Icons.help,
                title: isRtl ? 'المساعدة' : 'Help',
                onTap: () => context.push('/help'),
              ),
              _buildSettingItem(
                theme,
                icon: Icons.info,
                title: isRtl ? 'حول التطبيق' : 'About',
                onTap: () => context.push('/about'),
              ),
              _buildSettingItem(
                theme,
                icon: Icons.logout,
                title: isRtl ? 'تسجيل الخروج' : 'Logout',
                color: Colors.red,
                onTap: () async {
                  await context.read<AuthCubit>().signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    bool isMobile, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? theme.colorScheme.onSurface),
      title: Text(title, style: TextStyle(color: color)),
      trailing: Icon(
        isRtl ? Icons.chevron_left : Icons.chevron_right,
        color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
