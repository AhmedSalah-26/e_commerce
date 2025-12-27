import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/notifications_cubit.dart';
import '../../domain/entities/notification_entity.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_helpers.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRtl = context.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'notifications'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<NotificationsCubit, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsLoaded &&
                    state.notifications.isNotEmpty) {
                  return PopupMenuButton<String>(
                    icon:
                        Icon(Icons.more_vert, color: theme.colorScheme.primary),
                    onSelected: (value) {
                      if (value == 'mark_all_read') {
                        context.read<NotificationsCubit>().markAllAsRead();
                      } else if (value == 'clear_all') {
                        showClearAllDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          children: [
                            const Icon(Icons.done_all, size: 20),
                            const SizedBox(width: 8),
                            Text('mark_all_read'.tr()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_sweep,
                                size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('clear_all'.tr(),
                                style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<NotificationsCubit>()
                          .loadNotifications(),
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) return _buildEmptyState(theme);

              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<NotificationsCubit>().loadNotifications(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) =>
                      _buildNotificationCard(state.notifications[index]),
                ),
              );
            }

            return _buildEmptyState(theme);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 80,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'no_notifications'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationEntity notification) {
    final isRead = notification.isRead;

    return NotificationCard(
      notification: notification,
      isRead: isRead,
      onTap: () {
        if (!isRead)
          context.read<NotificationsCubit>().markAsRead(notification.id);
        if (notification.orderId != null) context.push('/orders');
      },
      onDismissed: () => context
          .read<NotificationsCubit>()
          .deleteNotification(notification.id),
    );
  }
}
