import 'package:flutter/material.dart';

/// Filter state model
class FilterState {
  final String? categoryId;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;

  const FilterState({
    this.categoryId,
    this.priceRange = const RangeValues(0, 10000),
    this.minPrice = 0,
    this.maxPrice = 10000,
  });

  FilterState copyWith({
    String? categoryId,
    RangeValues? priceRange,
    double? minPrice,
    double? maxPrice,
  }) {
    return FilterState(
      categoryId: categoryId ?? this.categoryId,
      priceRange: priceRange ?? this.priceRange,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  bool get hasActiveFilters {
    return categoryId != null ||
        priceRange.start > minPrice ||
        priceRange.end < maxPrice;
  }

  FilterState clear() {
    return FilterState(
      categoryId: null,
      priceRange: RangeValues(minPrice, maxPrice),
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}
