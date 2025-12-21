import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/services/local_notification_service.dart';

// States
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> notifications;
  final int unreadCount;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class NotificationsCubit extends Cubit<NotificationsState> {
  final LocalNotificationService _notificationService;

  NotificationsCubit({required LocalNotificationService notificationService})
      : _notificationService = notificationService,
        super(const NotificationsInitial());

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());

    try {
      final notifications = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();

      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _notificationService.clearAllNotifications();
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> addOrderNotification({
    required String orderId,
    required String status,
    required String locale,
  }) async {
    try {
      await _notificationService.createOrderStatusNotification(
        orderId: orderId,
        status: status,
        locale: locale,
      );
      await loadNotifications();
    } catch (e) {
      // Silently fail
    }
  }

  Future<int> getUnreadCount() async {
    return await _notificationService.getUnreadCount();
  }
}
