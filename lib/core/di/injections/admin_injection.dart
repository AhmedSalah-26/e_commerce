import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../../features/admin/domain/repositories/admin_repository.dart';
import '../../../features/admin/presentation/cubit/admin_cubit.dart';

void registerAdminDependencies(GetIt sl) {
  // Datasource
  sl.registerLazySingleton<AdminRemoteDatasource>(
    () => AdminRemoteDatasourceImpl(Supabase.instance.client),
  );

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDatasource>()),
  );

  // Cubit
  sl.registerFactory(() => AdminCubit(sl<AdminRepository>()));
}
