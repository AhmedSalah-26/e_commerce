import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_report_model.dart';

abstract class ProductReportRemoteDataSource {
  Future<List<ProductReportModel>> getUserReports();
  Future<void> createReport({
    required String productId,
    required String reason,
    String? description,
  });
  Future<List<ProductReportModel>> getAdminReports({
    String? status,
    int limit = 50,
    int offset = 0,
  });
  Future<void> respondToReport({
    required String reportId,
    required String status,
    required String adminResponse,
    bool suspendProduct = false,
    String? suspensionReason,
  });
  Future<int> getPendingReportsCount();
}

class ProductReportRemoteDataSourceImpl
    implements ProductReportRemoteDataSource {
  final SupabaseClient _supabase;

  ProductReportRemoteDataSourceImpl(this._supabase);

  @override
  Future<List<ProductReportModel>> getUserReports() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _supabase
        .rpc('get_user_product_reports', params: {'p_user_id': userId});

    return (response as List)
        .map((json) => ProductReportModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> createReport({
    required String productId,
    required String reason,
    String? description,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('product_reports').insert({
      'product_id': productId,
      'user_id': userId,
      'reason': reason,
      'description': description,
    });
  }

  @override
  Future<List<ProductReportModel>> getAdminReports({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _supabase.rpc('get_admin_product_reports', params: {
      'p_status': status,
      'p_limit': limit,
      'p_offset': offset,
    });

    return (response as List)
        .map((json) => ProductReportModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> respondToReport({
    required String reportId,
    required String status,
    required String adminResponse,
    bool suspendProduct = false,
    String? suspensionReason,
  }) async {
    await _supabase.rpc('respond_to_product_report', params: {
      'p_report_id': reportId,
      'p_status': status,
      'p_admin_response': adminResponse,
      'p_suspend_product': suspendProduct,
      'p_suspension_reason': suspensionReason,
    });
  }

  @override
  Future<int> getPendingReportsCount() async {
    final response = await _supabase
        .from('product_reports')
        .select('id')
        .eq('status', 'pending');
    return (response as List).length;
  }
}
