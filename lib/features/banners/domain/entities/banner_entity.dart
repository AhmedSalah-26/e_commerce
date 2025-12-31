import 'package:equatable/equatable.dart';

enum BannerLinkType { none, product, category, url, offers }

class BannerEntity extends Equatable {
  final String id;
  final String titleAr;
  final String? titleEn;
  final String imageUrl;
  final BannerLinkType linkType;
  final String? linkValue;
  final int sortOrder;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    required this.titleAr,
    this.titleEn,
    required this.imageUrl,
    this.linkType = BannerLinkType.none,
    this.linkValue,
    this.sortOrder = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  String getTitle(String locale) {
    if (locale == 'en' && titleEn != null && titleEn!.isNotEmpty) {
      return titleEn!;
    }
    return titleAr;
  }

  @override
  List<Object?> get props => [
        id,
        titleAr,
        titleEn,
        imageUrl,
        linkType,
        linkValue,
        sortOrder,
        isActive,
        startDate,
        endDate,
      ];
}
