import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/merchant/data/datasources/inventory_remote_datasource.dart';
import '../../../features/merchant/presentation/cubit/inventory_insights_cubit.dart';

void registerMerchantDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Cubits
  sl.registerFactory(
    () => InventoryInsightsCubit(sl<InventoryRemoteDataSource>()),
  );
}
