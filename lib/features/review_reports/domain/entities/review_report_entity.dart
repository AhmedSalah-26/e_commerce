import 'package:equatable/equatable.dart';

enum ReviewReportStatus { pending, reviewed, resolved, rejected }

extension ReviewReportStatusX on ReviewReportStatus {
  String get value {
    switch (this) {
      case ReviewReportStatus.pending:
        return 'pending';
      case ReviewReportStatus.reviewed:
        return 'reviewed';
      case ReviewReportStatus.resolved:
        return 'resolved';
      case ReviewReportStatus.rejected:
        return 'rejected';
    }
  }

  String getLabel(bool isArabic) {
    switch (this) {
      case ReviewReportStatus.pending:
        return isArabic ? 'قيد المراجعة' : 'Pending';
      case ReviewReportStatus.reviewed:
        return isArabic ? 'تمت المراجعة' : 'Reviewed';
      case ReviewReportStatus.resolved:
        return isArabic ? 'تم الحل' : 'Resolved';
      case ReviewReportStatus.rejected:
        return isArabic ? 'مرفوض' : 'Rejected';
    }
  }

  static ReviewReportStatus fromString(String value) {
    switch (value) {
      case 'reviewed':
        return ReviewReportStatus.reviewed;
      case 'resolved':
        return ReviewReportStatus.resolved;
      case 'rejected':
        return ReviewReportStatus.rejected;
      default:
        return ReviewReportStatus.pending;
    }
  }
}

class ReviewReportEntity extends Equatable {
  final String id;
  final String? reviewId;
  final String? reviewerId;
  final String? reviewerName;
  final String? reviewComment;
  final int? reviewRating;
  final String? productName;
  final String? productId;
  final String? reporterId;
  final String? reporterName;
  final String reason;
  final String? description;
  final ReviewReportStatus status;
  final String? adminResponse;
  final String? adminName;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ReviewReportEntity({
    required this.id,
    this.reviewId,
    this.reviewerId,
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
    this.adminName,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        reviewId,
        reviewerId,
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
        adminName,
        createdAt,
        resolvedAt,
      ];
}
