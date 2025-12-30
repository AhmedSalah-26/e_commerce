import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/merchant/data/datasources/inventory_remote_datasource.dart';
import '../../../features/merchant/presentation/cubit/inventory_insights_cubit.dart';

void registerMerchantDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Cubits
  sl.registerFactory(
    () => InventoryInsightsCubit(sl<InventoryRemoteDataSource>()),
  );
}
