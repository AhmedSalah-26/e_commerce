import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

/// Auth feature dependency injection
void registerAuthDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));

  // Cubit
  sl.registerFactory(() => AuthCubit(
        signInUseCase: sl<SignInUseCase>(),
        signUpUseCase: sl<SignUpUseCase>(),
        signOutUseCase: sl<SignOutUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        repository: sl<AuthRepository>(),
      ));
}
