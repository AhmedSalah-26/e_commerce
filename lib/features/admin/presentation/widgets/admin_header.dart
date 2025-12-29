import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class AdminHeader extends StatelessWidget {
  final bool isRtl;
  final VoidCallback? onMenuTap;

  const AdminHeader({super.key, required this.isRtl, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isMobile ? 56 : 64,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (onMenuTap != null)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuTap,
            ),
          if (isMobile && onMenuTap != null) ...[
            const SizedBox(width: 8),
            Text(
              isRtl ? 'لوحة التحكم' : 'Admin',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: Badge(
              label: const Text('3'),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurface,
                size: isMobile ? 22 : 24,
              ),
            ),
            onPressed: () {},
          ),
          SizedBox(width: isMobile ? 4 : 8),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final name = state is AuthAuthenticated
                  ? (state.user.name ?? '')
                  : (isRtl ? 'مسؤول' : 'Admin');

              return PopupMenuButton<String>(
                offset: const Offset(0, 50),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: isMobile ? 16 : 18,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 8),
                      Text(name, style: theme.textTheme.bodyMedium),
                    ],
                    Icon(
                      Icons.arrow_drop_down,
                      size: isMobile ? 20 : 24,
                    ),
                  ],
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(isRtl ? 'الملف الشخصي' : 'Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          isRtl ? 'تسجيل الخروج' : 'Logout',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthCubit>().signOut();
                    context.go('/login');
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
