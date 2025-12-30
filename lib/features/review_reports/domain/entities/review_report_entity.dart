import 'package:equatable/equatable.dart';

class ReviewReportEntity extends Equatable {
  final String id;
  final String reviewId;
  final String? reviewerName;
  final String? reviewComment;
  final int? reviewRating;
  final String? productName;
  final String? productId;
  final String? reporterId;
  final String? reporterName;
  final String reason;
  final String? description;
  final String status;
  final String? adminResponse;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ReviewReportEntity({
    required this.id,
    required this.reviewId,
    this.reviewerName,
    this.reviewComment,
    this.reviewRating,
    this.productName,
    this.productId,
    this.reporterId,
    this.reporterName,
    required this.reason,
    this.description,
    required this.status,
    this.adminResponse,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        reviewId,
        reviewerName,
        reviewComment,
        reviewRating,
        productName,
        productId,
        reporterId,
        reporterName,
        reason,
        description,
        status,
        adminResponse,
        createdAt,
        resolvedAt,
      ];
}
