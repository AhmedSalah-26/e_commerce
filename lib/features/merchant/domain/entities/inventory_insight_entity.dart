import 'package:equatable/equatable.dart';

/// Summary of inventory insights
class InventoryInsightsSummary extends Equatable {
  final int totalProducts;
  final int totalStock;
  final double totalStockValue;
  final int lowStockCount;
  final int outOfStockCount;
  final int overstockCount;
  final int deadStockCount;

  const InventoryInsightsSummary({
    required this.totalProducts,
    required this.totalStock,
    required this.totalStockValue,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.overstockCount,
    required this.deadStockCount,
  });

  int get alertsCount =>
      lowStockCount + outOfStockCount + overstockCount + deadStockCount;

  int get healthyCount => totalProducts - alertsCount;

  double get healthyPercentage =>
      totalProducts > 0 ? (healthyCount / totalProducts) * 100 : 0;

  @override
  List<Object?> get props => [
        totalProducts,
        totalStock,
        totalStockValue,
        lowStockCount,
        outOfStockCount,
        overstockCount,
        deadStockCount,
      ];
}

/// Stock status enum
enum StockStatus {
  healthy,
  lowStock,
  outOfStock,
  overstock,
  deadStock;

  static StockStatus fromString(String value) {
    switch (value) {
      case 'low_stock':
        return StockStatus.lowStock;
      case 'out_of_stock':
        return StockStatus.outOfStock;
      case 'overstock':
        return StockStatus.overstock;
      case 'dead_stock':
        return StockStatus.deadStock;
      default:
        return StockStatus.healthy;
    }
  }
}

/// Product inventory details
class ProductInventoryDetail extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final int stock;
  final double price;
  final double? discountPrice;
  final String? image;
  final bool isActive;
  final int salesLastPeriod;
  final int totalSales;
  final DateTime? lastSaleDate;
  final double turnoverRate;
  final double sellThroughRate;
  final int daysOfStock;
  final int suggestedReorderQty;
  final StockStatus stockStatus;

  const ProductInventoryDetail({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.stock,
    required this.price,
    this.discountPrice,
    this.image,
    required this.isActive,
    required this.salesLastPeriod,
    required this.totalSales,
    this.lastSaleDate,
    required this.turnoverRate,
    required this.sellThroughRate,
    required this.daysOfStock,
    required this.suggestedReorderQty,
    required this.stockStatus,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;

  double get effectivePrice => discountPrice ?? price;

  double get stockValue => stock * effectivePrice;

  bool get needsReorder => suggestedReorderQty > 0;

  bool get hasAlert => stockStatus != StockStatus.healthy;

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        stock,
        price,
        discountPrice,
        image,
        isActive,
        salesLastPeriod,
        totalSales,
        lastSaleDate,
        turnoverRate,
        sellThroughRate,
        daysOfStock,
        suggestedReorderQty,
        stockStatus,
      ];
}
