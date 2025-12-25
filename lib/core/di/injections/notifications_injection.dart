import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/notifications/data/services/local_notification_service.dart';
import '../../../features/notifications/data/services/order_status_listener.dart';
import '../../../features/notifications/presentation/cubit/notifications_cubit.dart';

/// Notifications feature dependency injection
void registerNotificationsDependencies(GetIt sl) {
  // Services
  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );

  sl.registerLazySingleton<OrderStatusListener>(
    () => OrderStatusListener(
      client: sl<SupabaseService>().client,
      notificationService: sl<LocalNotificationService>(),
    ),
  );

  // Cubit
  sl.registerFactory(() => NotificationsCubit(
        notificationService: sl<LocalNotificationService>(),
      ));
}
