import '../../../../core/services/supabase_service.dart';
import '../models/review_report_model.dart';

abstract class ReviewReportRemoteDataSource {
  Future<void> createReport({
    required String reviewId,
    required String reason,
    String? description,
  });
  Future<List<ReviewReportModel>> getUserReports(String userId);
  Future<List<ReviewReportModel>> getAdminReports({String? status});
  Future<void> respondToReport({
    required String reportId,
    required String status,
    required String adminResponse,
    bool deleteReview = false,
    bool banReviewer = false,
  });
}

class ReviewReportRemoteDataSourceImpl implements ReviewReportRemoteDataSource {
  final SupabaseService _supabaseService;

  ReviewReportRemoteDataSourceImpl(this._supabaseService);

  @override
  Future<void> createReport({
    required String reviewId,
    required String reason,
    String? description,
  }) async {
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabaseService.client.from('review_reports').insert({
      'review_id': reviewId,
      'user_id': userId,
      'reason': reason,
      'description': description,
    });
  }

  @override
  Future<List<ReviewReportModel>> getUserReports(String userId) async {
    final response = await _supabaseService.client
        .rpc('get_user_review_reports', params: {'p_user_id': userId});

    return (response as List)
        .map((json) => ReviewReportModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ReviewReportModel>> getAdminReports({String? status}) async {
    print('📥 Loading admin review reports, status: $status');
    try {
      final response = await _supabaseService.client
          .rpc('get_admin_review_reports', params: {
        'p_status': status,
        'p_limit': 100,
        'p_offset': 0,
      });
      print('✅ Got ${(response as List).length} reports');
      return response.map((json) => ReviewReportModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error loading admin review reports: $e');
      rethrow;
    }
  }

  @override
  Future<void> respondToReport({
    required String reportId,
    required String status,
    required String adminResponse,
    bool deleteReview = false,
    bool banReviewer = false,
  }) async {
    print('📤 Calling respond_to_review_report with:');
    print('   reportId: $reportId');
    print('   status: $status');
    print('   adminResponse: $adminResponse');
    print('   deleteReview: $deleteReview');
    print('   banReviewer: $banReviewer');

    try {
      final response = await _supabaseService.client
          .rpc('respond_to_review_report', params: {
        'p_report_id': reportId,
        'p_status': status,
        'p_admin_response': adminResponse,
        'p_delete_review': deleteReview,
        'p_ban_reviewer': banReviewer,
      });
      print('✅ Response: $response');
    } catch (e) {
      print('❌ Error in respondToReport: $e');
      rethrow;
    }
  }
}
