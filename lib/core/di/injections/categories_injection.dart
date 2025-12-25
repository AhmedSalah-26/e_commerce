import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../services/image_upload_service.dart';
import '../../../features/categories/data/datasources/category_remote_datasource.dart';
import '../../../features/categories/data/repositories/category_repository_impl.dart';
import '../../../features/categories/domain/repositories/category_repository.dart';
import '../../../features/categories/presentation/cubit/categories_cubit.dart';

/// Categories feature dependency injection
void registerCategoriesDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );

  // Cubit
  sl.registerFactory(() => CategoriesCubit(
        sl<CategoryRepository>(),
        imageUploadService: sl<ImageUploadService>(),
      ));
}
