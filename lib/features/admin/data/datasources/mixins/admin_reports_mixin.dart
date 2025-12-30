import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';

mixin AdminReportsMixin {
  SupabaseClient get client;

  Future<List<Map<String, dynamic>>> getTopSellingMerchantsImpl(
      {int limit = 20}) async {
    try {
      // Optimized: Single RPC call with database-side aggregation
      final response = await client.rpc('get_top_selling_merchants', params: {
        'p_limit': limit,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get top selling merchants: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopOrderingCustomersImpl(
      {int limit = 20}) async {
    try {
      // Optimized: Single RPC call with database-side aggregation
      final response = await client.rpc('get_top_ordering_customers', params: {
        'p_limit': limit,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get top ordering customers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMerchantsCancellationStatsImpl(
      {int limit = 20}) async {
    try {
      // Optimized: Single RPC call with database-side aggregation
      final response =
          await client.rpc('get_merchants_cancellation_stats', params: {
        'p_limit': limit,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw ServerException('Failed to get merchants cancellation stats: $e');
    }
  }
}
