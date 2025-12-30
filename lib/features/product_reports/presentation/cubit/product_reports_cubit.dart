import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/product_report_remote_datasource.dart';
import '../../data/models/product_report_model.dart';

// States
abstract class ProductReportsState extends Equatable {
  const ProductReportsState();
  @override
  List<Object?> get props => [];
}

class ProductReportsInitial extends ProductReportsState {}

class ProductReportsLoading extends ProductReportsState {}

class ProductReportsLoaded extends ProductReportsState {
  final List<ProductReportModel> reports;
  final int? totalCount;

  const ProductReportsLoaded(this.reports, {this.totalCount});

  @override
  List<Object?> get props => [reports, totalCount];
}

class ProductReportsError extends ProductReportsState {
  final String message;

  const ProductReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportSubmitting extends ProductReportsState {}

class ReportSubmitted extends ProductReportsState {}

class ReportSubmitError extends ProductReportsState {
  final String message;

  const ReportSubmitError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProductReportsCubit extends Cubit<ProductReportsState> {
  final ProductReportRemoteDataSource _dataSource;

  ProductReportsCubit(this._dataSource) : super(ProductReportsInitial());

  Future<void> loadUserReports() async {
    emit(ProductReportsLoading());
    try {
      final reports = await _dataSource.getUserReports();
      emit(ProductReportsLoaded(reports));
    } catch (e) {
      emit(ProductReportsError(e.toString()));
    }
  }

  Future<void> loadAdminReports({String? status}) async {
    emit(ProductReportsLoading());
    try {
      final reports = await _dataSource.getAdminReports(status: status);
      final totalCount = reports.isNotEmpty ? reports.length : 0;
      emit(ProductReportsLoaded(reports, totalCount: totalCount));
    } catch (e) {
      emit(ProductReportsError(e.toString()));
    }
  }

  Future<bool> submitReport({
    required String productId,
    required String reason,
    String? description,
  }) async {
    emit(ReportSubmitting());
    try {
      await _dataSource.createReport(
        productId: productId,
        reason: reason,
        description: description,
      );
      emit(ReportSubmitted());
      return true;
    } catch (e) {
      emit(ReportSubmitError(e.toString()));
      return false;
    }
  }

  Future<bool> respondToReport({
    required String reportId,
    required String status,
    required String adminResponse,
    bool suspendProduct = false,
    String? suspensionReason,
  }) async {
    try {
      await _dataSource.respondToReport(
        reportId: reportId,
        status: status,
        adminResponse: adminResponse,
        suspendProduct: suspendProduct,
        suspensionReason: suspensionReason,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> getPendingCount() async {
    try {
      return await _dataSource.getPendingReportsCount();
    } catch (_) {
      return 0;
    }
  }
}
