import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../../features/favorites/presentation/cubit/favorites_cubit.dart';

/// Favorites feature dependency injection
void registerFavoritesDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
  );

  // Cubit
  sl.registerFactory(() => FavoritesCubit(
        sl<FavoritesRepository>(),
        sl<FavoritesRemoteDataSource>(),
      ));
}
