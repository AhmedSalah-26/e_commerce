import 'package:equatable/equatable.dart';

enum ReportStatus { pending, reviewed, resolved, rejected }

enum ReportReason {
  fake,
  inappropriate,
  wrongInfo,
  scam,
  copyright,
  other,
}

extension ReportReasonExtension on ReportReason {
  String get value {
    switch (this) {
      case ReportReason.fake:
        return 'fake';
      case ReportReason.inappropriate:
        return 'inappropriate';
      case ReportReason.wrongInfo:
        return 'wrong_info';
      case ReportReason.scam:
        return 'scam';
      case ReportReason.copyright:
        return 'copyright';
      case ReportReason.other:
        return 'other';
    }
  }

  String getLabel(bool isArabic) {
    switch (this) {
      case ReportReason.fake:
        return isArabic ? 'منتج مزيف' : 'Fake Product';
      case ReportReason.inappropriate:
        return isArabic ? 'محتوى غير لائق' : 'Inappropriate Content';
      case ReportReason.wrongInfo:
        return isArabic ? 'معلومات خاطئة' : 'Wrong Information';
      case ReportReason.scam:
        return isArabic ? 'احتيال' : 'Scam';
      case ReportReason.copyright:
        return isArabic ? 'انتهاك حقوق الملكية' : 'Copyright Violation';
      case ReportReason.other:
        return isArabic ? 'سبب آخر' : 'Other';
    }
  }
}

extension ReportStatusExtension on ReportStatus {
  String get value {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.reviewed:
        return 'reviewed';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  String getLabel(bool isArabic) {
    switch (this) {
      case ReportStatus.pending:
        return isArabic ? 'قيد المراجعة' : 'Pending';
      case ReportStatus.reviewed:
        return isArabic ? 'تمت المراجعة' : 'Reviewed';
      case ReportStatus.resolved:
        return isArabic ? 'تم الحل' : 'Resolved';
      case ReportStatus.rejected:
        return isArabic ? 'مرفوض' : 'Rejected';
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReportStatus.pending;
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }
}

class ProductReportEntity extends Equatable {
  final String id;
  final String productId;
  final String? productName;
  final String? productImage;
  final String? merchantId;
  final String? merchantName;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String reason;
  final String? description;
  final ReportStatus status;
  final String? adminResponse;
  final String? adminId;
  final String? adminName;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ProductReportEntity({
    required this.id,
    required this.productId,
    this.productName,
    this.productImage,
    this.merchantId,
    this.merchantName,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.reason,
    this.description,
    required this.status,
    this.adminResponse,
    this.adminId,
    this.adminName,
    required this.createdAt,
    this.resolvedAt,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        productImage,
        merchantId,
        merchantName,
        userId,
        userName,
        userEmail,
        reason,
        description,
        status,
        adminResponse,
        adminId,
        adminName,
        createdAt,
        resolvedAt,
      ];
}
