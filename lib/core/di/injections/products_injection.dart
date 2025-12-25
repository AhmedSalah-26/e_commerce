import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/products/data/datasources/product_remote_datasource.dart';
import '../../../features/products/data/repositories/product_repository_impl.dart';
import '../../../features/products/domain/repositories/product_repository.dart';
import '../../../features/products/domain/usecases/get_products_usecase.dart';
import '../../../features/products/domain/usecases/get_products_by_category_usecase.dart';
import '../../../features/products/presentation/cubit/products_cubit.dart';
import '../../../features/home/presentation/cubit/home_sliders_cubit.dart';
import '../../../features/merchant/presentation/cubit/merchant_products_cubit.dart';
import '../../services/image_upload_service.dart';

/// Products feature dependency injection
void registerProductsDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(
      () => GetProductsByCategoryUseCase(sl<ProductRepository>()));

  // Cubits
  sl.registerFactory(() => ProductsCubit(repository: sl<ProductRepository>()));
  sl.registerFactory(() => HomeSlidersCubit(sl<ProductRepository>()));
  sl.registerFactory(() => MerchantProductsCubit(
        sl<ProductRepository>(),
        imageUploadService: sl<ImageUploadService>(),
      ));
}
