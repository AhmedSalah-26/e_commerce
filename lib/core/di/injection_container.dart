import 'package:get_it/get_it.dart';
import '../services/supabase_service.dart';

// Auth imports
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Products imports
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/get_products_by_category_usecase.dart';
import '../../features/products/presentation/cubit/products_cubit.dart';
import '../../features/home/presentation/cubit/home_sliders_cubit.dart';

// Categories imports
import '../../features/categories/data/datasources/category_remote_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';

// Cart imports
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';

// Orders imports
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';

// Favorites imports
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';

// Notifications imports
import '../../features/notifications/data/services/local_notification_service.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';

// Reviews imports
import '../../features/reviews/data/datasources/review_remote_datasource.dart';
import '../../features/reviews/presentation/cubit/reviews_cubit.dart';

// Merchant imports
import '../../features/merchant/presentation/cubit/merchant_products_cubit.dart';
import '../services/image_upload_service.dart';

// Shipping imports
import '../../features/shipping/data/datasources/shipping_remote_datasource.dart';
import '../../features/shipping/data/repositories/shipping_repository_impl.dart';
import '../../features/shipping/domain/repositories/shipping_repository.dart';
import '../../features/shipping/presentation/cubit/shipping_cubit.dart';

// Coupons imports
import '../../features/coupons/data/datasources/coupon_remote_datasource.dart';
import '../../features/coupons/presentation/cubit/coupon_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Core Services
  sl.registerLazySingleton<SupabaseService>(() => SupabaseServiceImpl.instance);
  await sl<SupabaseService>().initialize();

  // Image Upload Service (registered early as it's used by multiple features)
  sl.registerLazySingleton<ImageUploadService>(
    () => ImageUploadService(sl<SupabaseService>().client),
  );

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerFactory(() => AuthCubit(
        signInUseCase: sl<SignInUseCase>(),
        signUpUseCase: sl<SignUpUseCase>(),
        signOutUseCase: sl<SignOutUseCase>(),
        getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
        repository: sl<AuthRepository>(),
      ));

  // Products Feature
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<ProductRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetProductsUseCase(sl<ProductRepository>()));
  sl.registerLazySingleton(
      () => GetProductsByCategoryUseCase(sl<ProductRepository>()));
  sl.registerFactory(() => ProductsCubit(
        repository: sl<ProductRepository>(),
      ));
  sl.registerFactory(() => HomeSlidersCubit(sl<ProductRepository>()));

  // Categories Feature
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl<CategoryRemoteDataSource>()),
  );
  sl.registerFactory(() {
    return CategoriesCubit(
      sl<CategoryRepository>(),
      imageUploadService: sl<ImageUploadService>(),
    );
  });

  // Cart Feature
  sl.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartRemoteDataSource>()),
  );
  sl.registerFactory(() => CartCubit(sl<CartRepository>()));

  // Orders Feature
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<OrderRemoteDataSource>()),
  );
  sl.registerFactory(() => OrdersCubit(sl<OrderRepository>()));

  // Favorites Feature
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl<FavoritesRemoteDataSource>()),
  );
  sl.registerFactory(() => FavoritesCubit(
        sl<FavoritesRepository>(),
        sl<FavoritesRemoteDataSource>(),
      ));

  // Notifications Feature
  sl.registerLazySingleton<LocalNotificationService>(
    () => LocalNotificationService(),
  );
  sl.registerFactory(() => NotificationsCubit(
        notificationService: sl<LocalNotificationService>(),
      ));

  // Reviews Feature
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerFactory(() => ReviewsCubit(sl<ReviewRemoteDataSource>()));

  // Merchant Feature
  sl.registerFactory(() {
    return MerchantProductsCubit(
      sl<ProductRepository>(),
      imageUploadService: sl<ImageUploadService>(),
    );
  });

  // Shipping Feature
  sl.registerLazySingleton<ShippingRemoteDataSource>(
    () => ShippingRemoteDataSourceImpl(sl<SupabaseService>().client),
  );
  sl.registerLazySingleton<ShippingRepository>(
    () => ShippingRepositoryImpl(sl<ShippingRemoteDataSource>()),
  );
  sl.registerFactory(() => ShippingCubit(sl<ShippingRepository>()));

  // Coupons Feature
  sl.registerLazySingleton<CouponRemoteDatasource>(
    () => CouponRemoteDatasource(sl<SupabaseService>().client),
  );
  sl.registerFactory(() => CouponCubit(sl<CouponRemoteDatasource>()));
  sl.registerFactory(() => MerchantCouponsCubit(sl<CouponRemoteDatasource>()));
}
