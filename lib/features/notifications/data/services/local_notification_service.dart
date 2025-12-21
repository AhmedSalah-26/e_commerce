import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification_entity.dart';

class LocalNotificationService {
  static const String _notificationsKey = 'local_notifications';
  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<List<NotificationEntity>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notificationsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) =>
              NotificationEntity.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  Future<void> addNotification(NotificationEntity notification) async {
    final notifications = await getNotifications();
    notifications.insert(0, notification);
    await _saveNotifications(notifications);
  }

  Future<void> markAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);

    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      await _saveNotifications(notifications);
    }
  }

  Future<void> markAllAsRead() async {
    final notifications = await getNotifications();
    final updatedNotifications =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications(updatedNotifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications(notifications);
  }

  Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }

  Future<void> _saveNotifications(
      List<NotificationEntity> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_notificationsKey, json.encode(jsonList));
  }

  // Create order status notification
  Future<void> createOrderStatusNotification({
    required String orderId,
    required String status,
    required String locale,
  }) async {
    // Check if notifications are enabled
    final enabled = await isNotificationsEnabled();
    if (!enabled) return;
    final titles = {
      'ar': {
        'pending': 'طلب جديد',
        'processing': 'جاري تجهيز طلبك',
        'shipped': 'تم شحن طلبك',
        'delivered': 'تم توصيل طلبك',
        'cancelled': 'تم إلغاء طلبك',
      },
      'en': {
        'pending': 'New Order',
        'processing': 'Order Processing',
        'shipped': 'Order Shipped',
        'delivered': 'Order Delivered',
        'cancelled': 'Order Cancelled',
      },
    };

    final bodies = {
      'ar': {
        'pending': 'تم استلام طلبك رقم #${orderId.substring(0, 8)} بنجاح',
        'processing': 'طلبك رقم #${orderId.substring(0, 8)} قيد التجهيز',
        'shipped': 'طلبك رقم #${orderId.substring(0, 8)} في الطريق إليك',
        'delivered': 'تم توصيل طلبك رقم #${orderId.substring(0, 8)} بنجاح',
        'cancelled': 'تم إلغاء طلبك رقم #${orderId.substring(0, 8)}',
      },
      'en': {
        'pending': 'Your order #${orderId.substring(0, 8)} has been received',
        'processing':
            'Your order #${orderId.substring(0, 8)} is being prepared',
        'shipped': 'Your order #${orderId.substring(0, 8)} is on the way',
        'delivered':
            'Your order #${orderId.substring(0, 8)} has been delivered',
        'cancelled':
            'Your order #${orderId.substring(0, 8)} has been cancelled',
      },
    };

    final lang = locale == 'ar' ? 'ar' : 'en';
    final title = titles[lang]?[status] ?? 'Order Update';
    final body = bodies[lang]?[status] ?? 'Your order status has been updated';

    final notification = NotificationEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: 'order_status',
      orderId: orderId,
      createdAt: DateTime.now(),
    );

    await addNotification(notification);
  }
}
