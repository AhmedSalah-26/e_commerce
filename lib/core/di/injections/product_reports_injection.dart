import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/product_reports/data/datasources/product_report_remote_datasource.dart';
import '../../../features/product_reports/presentation/cubit/product_reports_cubit.dart';

void registerProductReportsDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<ProductReportRemoteDataSource>(
    () => ProductReportRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Cubits
  sl.registerFactory<ProductReportsCubit>(
    () => ProductReportsCubit(sl<ProductReportRemoteDataSource>()),
  );
}
