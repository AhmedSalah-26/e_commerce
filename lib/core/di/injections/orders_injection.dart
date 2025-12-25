import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../../features/orders/data/repositories/order_repository_impl.dart';
import '../../../features/orders/domain/repositories/order_repository.dart';
import '../../../features/orders/presentation/cubit/orders_cubit.dart';

/// Orders feature dependency injection
void registerOrdersDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<OrderRemoteDataSource>()),
  );

  // Cubit
  sl.registerFactory(() => OrdersCubit(sl<OrderRepository>()));
}
