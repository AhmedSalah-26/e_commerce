import 'package:get_it/get_it.dart';
import '../../services/supabase_service.dart';
import '../../../features/reviews/data/datasources/review_remote_datasource.dart';
import '../../../features/reviews/presentation/cubit/reviews_cubit.dart';

/// Reviews feature dependency injection
void registerReviewsDependencies(GetIt sl) {
  // Data Source
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(sl<SupabaseService>().client),
  );

  // Cubit
  sl.registerFactory(() => ReviewsCubit(sl<ReviewRemoteDataSource>()));
}
