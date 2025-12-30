import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/inventory_insight_model.dart';

abstract class InventoryRemoteDataSource {
  Future<InventoryInsightsSummaryModel> getInventoryInsights(
    String merchantId, {
    int daysForDeadStock = 90,
    int lowStockThreshold = 10,
    int highStockThreshold = 100,
  });

  Future<List<ProductInventoryDetailModel>> getInventoryDetails(
    String merchantId, {
    String filter = 'all',
    int daysForAnalysis = 30,
    int lowStockThreshold = 10,
    int highStockThreshold = 100,
  });
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final SupabaseClient client;

  InventoryRemoteDataSourceImpl(this.client);

  @override
  Future<InventoryInsightsSummaryModel> getInventoryInsights(
    String merchantId, {
    int daysForDeadStock = 90,
    int lowStockThreshold = 10,
    int highStockThreshold = 100,
  }) async {
    try {
      final response = await client.rpc(
        'get_merchant_inventory_insights',
        params: {
          'p_merchant_id': merchantId,
          'p_days_for_dead_stock': daysForDeadStock,
          'p_low_stock_threshold': lowStockThreshold,
          'p_high_stock_threshold': highStockThreshold,
        },
      );

      if (response == null) {
        throw ServerException('فشل في جلب إحصائيات المخزون');
      }

      return InventoryInsightsSummaryModel.fromJson(response);
    } catch (e) {
      throw ServerException('فشل في جلب إحصائيات المخزون: $e');
    }
  }

  @override
  Future<List<ProductInventoryDetailModel>> getInventoryDetails(
    String merchantId, {
    String filter = 'all',
    int daysForAnalysis = 30,
    int lowStockThreshold = 10,
    int highStockThreshold = 100,
  }) async {
    try {
      final response = await client.rpc(
        'get_merchant_inventory_details',
        params: {
          'p_merchant_id': merchantId,
          'p_filter': filter,
          'p_days_for_analysis': daysForAnalysis,
          'p_low_stock_threshold': lowStockThreshold,
          'p_high_stock_threshold': highStockThreshold,
        },
      );

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((json) => ProductInventoryDetailModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException('فشل في جلب تفاصيل المخزون: $e');
    }
  }
}
