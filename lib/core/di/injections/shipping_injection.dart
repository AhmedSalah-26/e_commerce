import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/shipping/data/datasources/shipping_remote_datasource.dart';
import '../../../features/shipping/data/repositories/shipping_repository_impl.dart';
import '../../../features/shipping/domain/repositories/shipping_repository.dart';
import '../../../features/shipping/presentation/cubit/shipping_cubit.dart';

/// Shipping feature dependency injection
void registerShippingDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<ShippingRemoteDataSource>(
    () => ShippingRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<ShippingRepository>(
    () => ShippingRepositoryImpl(sl<ShippingRemoteDataSource>()),
  );

  // Cubit
  sl.registerFactory(() => ShippingCubit(sl<ShippingRepository>()));
}
