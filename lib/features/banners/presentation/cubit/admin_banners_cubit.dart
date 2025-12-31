import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/banner_remote_datasource.dart';
import '../../domain/entities/banner_entity.dart';

// States
abstract class AdminBannersState {}

class AdminBannersInitial extends AdminBannersState {}

class AdminBannersLoading extends AdminBannersState {}

class AdminBannersLoaded extends AdminBannersState {
  final List<BannerEntity> banners;
  AdminBannersLoaded(this.banners);
}

class AdminBannersError extends AdminBannersState {
  final String message;
  AdminBannersError(this.message);
}

class AdminBannerSaving extends AdminBannersState {}

class AdminBannerSaved extends AdminBannersState {
  final String message;
  AdminBannerSaved(this.message);
}

// Cubit
class AdminBannersCubit extends Cubit<AdminBannersState> {
  final BannerRemoteDatasource _datasource;

  AdminBannersCubit(this._datasource) : super(AdminBannersInitial());

  Future<void> loadBanners() async {
    emit(AdminBannersLoading());
    try {
      final banners = await _datasource.getAllBanners();
      emit(AdminBannersLoaded(banners));
    } catch (e) {
      emit(AdminBannersError(e.toString()));
    }
  }

  Future<void> createBanner({
    required String titleAr,
    String? titleEn,
    File? imageFile,
    String linkType = 'none',
    String? linkValue,
    int sortOrder = 0,
    bool isActive = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(AdminBannerSaving());
    try {
      String? imageUrl;
      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        imageUrl = await _datasource.uploadBannerImage(imageFile, fileName);
      }

      await _datasource.createBanner(
        titleAr: titleAr,
        titleEn: titleEn,
        imageUrl: imageUrl,
        linkType: linkType,
        linkValue: linkValue,
        sortOrder: sortOrder,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
      );

      emit(AdminBannerSaved('تم إنشاء البانر بنجاح'));
      await loadBanners();
    } catch (e) {
      emit(AdminBannersError(e.toString()));
    }
  }

  Future<void> updateBanner({
    required String bannerId,
    String? titleAr,
    String? titleEn,
    File? imageFile,
    String? existingImageUrl,
    String? linkType,
    String? linkValue,
    int? sortOrder,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    emit(AdminBannerSaving());
    try {
      String? imageUrl = existingImageUrl;
      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        imageUrl = await _datasource.uploadBannerImage(imageFile, fileName);
      }

      await _datasource.updateBanner(
        bannerId: bannerId,
        titleAr: titleAr,
        titleEn: titleEn,
        imageUrl: imageUrl,
        linkType: linkType,
        linkValue: linkValue,
        sortOrder: sortOrder,
        isActive: isActive,
        startDate: startDate,
        endDate: endDate,
      );

      emit(AdminBannerSaved('تم تحديث البانر بنجاح'));
      await loadBanners();
    } catch (e) {
      emit(AdminBannersError(e.toString()));
    }
  }

  Future<void> deleteBanner(String bannerId, String? imageUrl) async {
    emit(AdminBannerSaving());
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await _datasource.deleteBannerImage(imageUrl);
      }
      await _datasource.deleteBanner(bannerId);
      emit(AdminBannerSaved('تم حذف البانر بنجاح'));
      await loadBanners();
    } catch (e) {
      emit(AdminBannersError(e.toString()));
    }
  }

  Future<void> toggleBanner(String bannerId) async {
    try {
      await _datasource.toggleBanner(bannerId);
      await loadBanners();
    } catch (e) {
      emit(AdminBannersError(e.toString()));
    }
  }
}
