import '../../domain/entities/review_report_entity.dart';

class ReviewReportModel extends ReviewReportEntity {
  const ReviewReportModel({
    required super.id,
    required super.reviewId,
    super.reviewerName,
    super.reviewComment,
    super.reviewRating,
    super.productName,
    super.productId,
    super.reporterId,
    super.reporterName,
    required super.reason,
    super.description,
    required super.status,
    super.adminResponse,
    required super.createdAt,
    super.resolvedAt,
  });

  factory ReviewReportModel.fromJson(Map<String, dynamic> json) {
    return ReviewReportModel(
      id: json['id'] as String,
      reviewId: json['review_id'] as String,
      reviewerName: json['reviewer_name'] as String?,
      reviewComment: json['review_comment'] as String?,
      reviewRating: json['review_rating'] as int?,
      productName: json['product_name'] as String?,
      productId: json['product_id'] as String?,
      reporterId: json['reporter_id'] as String?,
      reporterName: json['reporter_name'] as String?,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      adminResponse: json['admin_response'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review_id': reviewId,
      'reason': reason,
      'description': description,
      'status': status,
    };
  }
}
