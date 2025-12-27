import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../services/image_upload_service.dart';
import '../../services/connectivity_service.dart';

/// Core services dependency injection
Future<void> registerCoreDependencies(GetIt sl) async {
  // Connectivity Service (initialize first)
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  await sl<ConnectivityService>().initialize();

  // Supabase Service
  sl.registerLazySingleton<SupabaseService>(() => SupabaseServiceImpl.instance);
  await sl<SupabaseService>().initialize();

  // Image Upload Service
  sl.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(sl<SupabaseService>().client),
  );
}
