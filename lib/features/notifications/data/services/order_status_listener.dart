import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_notification_service.dart';

/// Service to listen for order status changes and create notifications
/// Uses Supabase Realtime with filter to only receive relevant updates
class OrderStatusListener {
  final SupabaseClient _client;
  final LocalNotificationService _notificationService;

  RealtimeChannel? _ordersChannel;
  String? _currentUserId;
  String _locale = 'ar';

  OrderStatusListener({
    required SupabaseClient client,
    required LocalNotificationService notificationService,
  })  : _client = client,
        _notificationService = notificationService;

  /// Start listening for order status changes for a user
  /// Uses filter on user_id to only receive updates for this user's orders
  void startListening(String userId, {String locale = 'ar'}) {
    // Don't restart if already listening for same user
    if (_currentUserId == userId && _ordersChannel != null) {
      _locale = locale;
      return;
    }

    stopListening();
    _currentUserId = userId;
    _locale = locale;

    debugPrint('🔔 Starting order status listener for user: $userId');

    // Listen to parent_orders with filter on user_id
    // This is more efficient - only receives updates for this user
    _ordersChannel = _client
        .channel('user_orders_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'parent_orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _handleParentOrderChange,
        )
        .subscribe();
  }

  /// Handle parent order status change
  void _handleParentOrderChange(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      final oldRecord = payload.oldRecord;

      if (newRecord.isEmpty) return;

      final parentOrderId = newRecord['id'] as String?;
      final newStatus = newRecord['status'] as String?;
      final oldStatus = oldRecord['status'] as String?;

      // Only process if status actually changed
      if (newStatus == null || newStatus == oldStatus) return;

      debugPrint(
          '📦 Parent order status changed: $parentOrderId to $newStatus');

      // Create notification for the user
      _notificationService.createOrderStatusNotification(
        orderId: parentOrderId ?? 'unknown',
        status: newStatus,
        locale: _locale,
      );

      debugPrint('✅ Notification created for order status: $newStatus');
    } catch (e) {
      debugPrint('❌ Error handling order change: $e');
    }
  }

  /// Update locale for notifications
  void setLocale(String locale) {
    _locale = locale;
  }

  /// Stop listening for changes
  void stopListening() {
    if (_ordersChannel != null) {
      debugPrint('🔕 Stopping order status listener');
      _client.removeChannel(_ordersChannel!);
      _ordersChannel = null;
      _currentUserId = null;
    }
  }

  /// Dispose resources
  void dispose() {
    stopListening();
  }
}
