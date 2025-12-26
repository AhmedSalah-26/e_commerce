import 'package:flutter/material.dart';
import '../../../products/domain/enums/sort_option.dart';

/// Filter state model
class FilterState {
  final String? categoryId;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final SortOption sortOption;

  const FilterState({
    this.categoryId,
    this.priceRange = const RangeValues(0, 100000),
    this.minPrice = 0,
    this.maxPrice = 100000,
    this.sortOption = SortOption.newest,
  });

  FilterState copyWith({
    String? categoryId,
    bool clearCategoryId = false,
    RangeValues? priceRange,
    double? minPrice,
    double? maxPrice,
    SortOption? sortOption,
  }) {
    return FilterState(
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      priceRange: priceRange ?? this.priceRange,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get hasActiveFilters {
    return categoryId != null ||
        priceRange.start > minPrice ||
        priceRange.end < maxPrice ||
        sortOption != SortOption.newest;
  }

  FilterState clear() {
    return FilterState(
      categoryId: null,
      priceRange: RangeValues(minPrice, maxPrice),
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortOption: SortOption.newest,
    );
  }
}
