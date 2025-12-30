import '../../domain/entities/inventory_insight_entity.dart';

class InventoryInsightsSummaryModel extends InventoryInsightsSummary {
  const InventoryInsightsSummaryModel({
    required super.totalProducts,
    required super.totalStock,
    required super.totalStockValue,
    required super.lowStockCount,
    required super.outOfStockCount,
    required super.overstockCount,
    required super.deadStockCount,
  });

  factory InventoryInsightsSummaryModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    return InventoryInsightsSummaryModel(
      totalProducts: summary['total_products'] ?? 0,
      totalStock: summary['total_stock'] ?? 0,
      totalStockValue: (summary['total_stock_value'] ?? 0).toDouble(),
      lowStockCount: summary['low_stock_count'] ?? 0,
      outOfStockCount: summary['out_of_stock_count'] ?? 0,
      overstockCount: summary['overstock_count'] ?? 0,
      deadStockCount: summary['dead_stock_count'] ?? 0,
    );
  }
}

class ProductInventoryDetailModel extends ProductInventoryDetail {
  const ProductInventoryDetailModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.stock,
    required super.price,
    super.discountPrice,
    super.image,
    required super.isActive,
    required super.salesLastPeriod,
    required super.totalSales,
    super.lastSaleDate,
    required super.turnoverRate,
    required super.sellThroughRate,
    required super.daysOfStock,
    required super.suggestedReorderQty,
    required super.stockStatus,
  });

  factory ProductInventoryDetailModel.fromJson(Map<String, dynamic> json) {
    return ProductInventoryDetailModel(
      id: json['id'] ?? '',
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'] ?? json['name_ar'] ?? '',
      stock: json['stock'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discount_price']?.toDouble(),
      image: json['image'],
      isActive: json['is_active'] ?? true,
      salesLastPeriod: json['sales_last_period'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      lastSaleDate: json['last_sale_date'] != null
          ? DateTime.parse(json['last_sale_date'])
          : null,
      turnoverRate: (json['turnover_rate'] ?? 0).toDouble(),
      sellThroughRate: (json['sell_through_rate'] ?? 0).toDouble(),
      daysOfStock: json['days_of_stock'] ?? 999,
      suggestedReorderQty: json['suggested_reorder_qty'] ?? 0,
      stockStatus: StockStatus.fromString(json['stock_status'] ?? 'healthy'),
    );
  }
}
