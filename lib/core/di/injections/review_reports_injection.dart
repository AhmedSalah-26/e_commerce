import 'package:get_it/get_it.dart';
import '../../../features/review_reports/data/datasources/review_report_remote_datasource.dart';
import '../../../features/review_reports/presentation/cubit/review_reports_cubit.dart';

void registerReviewReportsDependencies(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<ReviewReportRemoteDataSource>(
    () => ReviewReportRemoteDataSourceImpl(sl()),
  );

  // Cubits
  sl.registerFactory<ReviewReportsCubit>(
    () => ReviewReportsCubit(sl()),
  );
}
