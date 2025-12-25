import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/coupons/data/datasources/coupon_remote_datasource.dart';
import '../../../features/coupons/presentation/cubit/coupon_cubit.dart';

/// Coupons feature dependency injection
void registerCouponsDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<CouponRemoteDatasource>(
    () => CouponRemoteDatasource(sl<SupabaseService>().client),
  );

  // Cubits
  sl.registerFactory(() => CouponCubit(sl<CouponRemoteDatasource>()));
  sl.registerFactory(() => MerchantCouponsCubit(sl<CouponRemoteDatasource>()));
}
