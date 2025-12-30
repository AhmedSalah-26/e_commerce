import '../../domain/entities/product_report_entity.dart';

class ProductReportModel extends ProductReportEntity {
  const ProductReportModel({
    required super.id,
    required super.productId,
    super.productName,
    super.productImage,
    super.merchantId,
    super.merchantName,
    required super.userId,
    super.userName,
    super.userEmail,
    required super.reason,
    super.description,
    required super.status,
    super.adminResponse,
    super.adminId,
    super.adminName,
    required super.createdAt,
    super.resolvedAt,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String?,
      productImage: json['product_image'] as String?,
      merchantId: json['merchant_id'] as String?,
      merchantName: json['merchant_name'] as String?,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: ReportStatusExtension.fromString(
          json['status'] as String? ?? 'pending'),
      adminResponse: json['admin_response'] as String?,
      adminId: json['admin_id'] as String?,
      adminName: json['admin_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'user_id': userId,
      'reason': reason,
      'description': description,
    };
  }
}
