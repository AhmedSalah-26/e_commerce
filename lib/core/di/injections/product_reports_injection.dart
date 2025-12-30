import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/product_reports/data/datasources/product_report_remote_datasource.dart';
import '../../../features/product_reports/presentation/cubit/product_reports_cubit.dart';

void registerProductReportsDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<ProductReportRemoteDataSource>(
    () => ProductReportRemoteDataSourceImpl(sl<SupabaseClient>()),
  );

  // Cubits
  sl.registerFactory<ProductReportsCubit>(
    () => ProductReportsCubit(sl<ProductReportRemoteDataSource>()),
  );
}
