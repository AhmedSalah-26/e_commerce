import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/banner_model.dart';

class BannerRemoteDatasource {
  final SupabaseClient _client;
  String _locale = 'ar';

  BannerRemoteDatasource(this._client);

  void setLocale(String locale) => _locale = locale;

  /// Get active banners for display
  Future<List<BannerModel>> getActiveBanners() async {
    final response = await _client.rpc(
      'get_active_banners',
      params: {'p_locale': _locale},
    );

    return (response as List)
        .map((json) => BannerModel.fromSimpleJson(json))
        .toList();
  }

  /// Get all banners for admin
  Future<List<BannerModel>> getAllBanners() async {
    final response = await _client.rpc('admin_get_all_banners');

    return (response as List)
        .map((json) => BannerModel.fromJson(json))
        .toList();
  }

  /// Create new banner
  Future<String> createBanner({
    required String titleAr,
    String? titleEn,
    String? imageUrl,
    String linkType = 'none',
    String? linkValue,
    int sortOrder = 0,
    bool isActive = true,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client.rpc(
      'admin_create_banner',
      params: {
        'p_title_ar': titleAr,
        'p_title_en': titleEn,
        'p_image_url': imageUrl,
        'p_link_type': linkType,
        'p_link_value': linkValue,
        'p_sort_order': sortOrder,
        'p_is_active': isActive,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
      },
    );

    return response as String;
  }

  /// Update banner
  Future<bool> updateBanner({
    required String bannerId,
    String? titleAr,
    String? titleEn,
    String? imageUrl,
    String? linkType,
    String? linkValue,
    int? sortOrder,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _client.rpc(
      'admin_update_banner',
      params: {
        'p_banner_id': bannerId,
        'p_title_ar': titleAr,
        'p_title_en': titleEn,
        'p_image_url': imageUrl,
        'p_link_type': linkType,
        'p_link_value': linkValue,
        'p_sort_order': sortOrder,
        'p_is_active': isActive,
        'p_start_date': startDate?.toIso8601String(),
        'p_end_date': endDate?.toIso8601String(),
      },
    );

    return response as bool;
  }

  /// Delete banner
  Future<bool> deleteBanner(String bannerId) async {
    final response = await _client.rpc(
      'admin_delete_banner',
      params: {'p_banner_id': bannerId},
    );

    return response as bool;
  }

  /// Toggle banner status
  Future<bool> toggleBanner(String bannerId) async {
    final response = await _client.rpc(
      'admin_toggle_banner',
      params: {'p_banner_id': bannerId},
    );

    return response as bool;
  }

  /// Upload banner image
  Future<String> uploadBannerImage(File imageFile, String fileName) async {
    final path = 'banners/$fileName';

    await _client.storage.from('banners').upload(
          path,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('banners').getPublicUrl(path);
  }

  /// Delete banner image
  Future<void> deleteBannerImage(String imageUrl) async {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final bucketIndex = pathSegments.indexOf('banners');
    if (bucketIndex != -1 && bucketIndex < pathSegments.length - 1) {
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
      await _client.storage.from('banners').remove([filePath]);
    }
  }
}
