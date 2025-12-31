import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/banner_remote_datasource.dart';
import '../../domain/entities/banner_entity.dart';

// States
abstract class BannersState {}

class BannersInitial extends BannersState {}

class BannersLoading extends BannersState {}

class BannersLoaded extends BannersState {
  final List<BannerEntity> banners;
  BannersLoaded(this.banners);
}

class BannersError extends BannersState {
  final String message;
  BannersError(this.message);
}

// Cubit
class BannersCubit extends Cubit<BannersState> {
  final BannerRemoteDatasource _datasource;

  BannersCubit(this._datasource) : super(BannersInitial());

  void setLocale(String locale) => _datasource.setLocale(locale);

  Future<void> loadActiveBanners() async {
    emit(BannersLoading());
    try {
      final banners = await _datasource.getActiveBanners();
      emit(BannersLoaded(banners));
    } catch (e) {
      emit(BannersError(e.toString()));
    }
  }
}
