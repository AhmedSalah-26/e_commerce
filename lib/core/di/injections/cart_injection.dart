import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../../features/cart/domain/repositories/cart_repository.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';

/// Cart feature dependency injection
void registerCartDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
  );

  // Cubit
  sl.registerFactory(() => CartCubit(sl<CartRepository>()));
}
