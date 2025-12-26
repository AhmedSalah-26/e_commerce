/// خيارات ترتيب المنتجات
enum SortOption {
  /// الأحدث أولاً (الافتراضي)
  newest,

  /// السعر من الأقل للأعلى
  priceLowToHigh,

  /// السعر من الأعلى للأقل
  priceHighToLow,

  /// الأعلى تقييماً
  highestRated,
}

/// Extension لإضافة خصائص مساعدة
extension SortOptionExtension on SortOption {
  /// الحصول على مفتاح الترجمة
  String get translationKey {
    switch (this) {
      case SortOption.newest:
        return 'sort_newest';
      case SortOption.priceLowToHigh:
        return 'sort_price_low_high';
      case SortOption.priceHighToLow:
        return 'sort_price_high_low';
      case SortOption.highestRated:
        return 'sort_highest_rated';
    }
  }

  /// الحصول على اسم العمود للترتيب في قاعدة البيانات
  String get orderColumn {
    switch (this) {
      case SortOption.newest:
        return 'created_at';
      case SortOption.priceLowToHigh:
      case SortOption.priceHighToLow:
        return 'price';
      case SortOption.highestRated:
        return 'rating';
    }
  }

  /// هل الترتيب تصاعدي؟
  bool get isAscending {
    switch (this) {
      case SortOption.newest:
      case SortOption.priceHighToLow:
      case SortOption.highestRated:
        return false;
      case SortOption.priceLowToHigh:
        return true;
    }
  }
}
