import 'package:get_it/get_it.dart';

import '../../services/supabase_service.dart';
import '../../../features/banners/data/datasources/banner_remote_datasource.dart';

void registerBannersDependencies(GetIt sl) {
  sl.registerLazySingleton<BannerRemoteDatasource>(
    () => BannerRemoteDatasource(sl<SupabaseService>().client),
  );
}
