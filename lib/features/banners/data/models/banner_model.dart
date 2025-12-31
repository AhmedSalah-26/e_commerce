import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.titleAr,
    super.titleEn,
    required super.imageUrl,
    super.linkType,
    super.linkValue,
    super.sortOrder,
    super.isActive,
    super.startDate,
    super.endDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      titleAr: json['title_ar'] as String? ?? json['title'] as String? ?? '',
      titleEn: json['title_en'] as String?,
      imageUrl: json['image_url'] as String? ?? '',
      linkType: _parseLinkType(json['link_type'] as String?),
      linkValue: json['link_value'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// For simple banner display (from get_active_banners)
  factory BannerModel.fromSimpleJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      titleAr: json['title'] as String? ?? '',
      titleEn: null,
      imageUrl: json['image_url'] as String? ?? '',
      linkType: _parseLinkType(json['link_type'] as String?),
      linkValue: json['link_value'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'image_url': imageUrl,
      'link_type': linkType.name,
      'link_value': linkValue,
      'sort_order': sortOrder,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  static BannerLinkType _parseLinkType(String? type) {
    switch (type) {
      case 'product':
        return BannerLinkType.product;
      case 'category':
        return BannerLinkType.category;
      case 'url':
        return BannerLinkType.url;
      case 'offers':
        return BannerLinkType.offers;
      default:
        return BannerLinkType.none;
    }
  }
}
