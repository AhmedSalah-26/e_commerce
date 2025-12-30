import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/review_report_remote_datasource.dart';
import '../../domain/entities/review_report_entity.dart';

// States
abstract class ReviewReportsState extends Equatable {
  const ReviewReportsState();
  @override
  List<Object?> get props => [];
}

class ReviewReportsInitial extends ReviewReportsState {}

class ReviewReportsLoading extends ReviewReportsState {}

class ReviewReportsLoaded extends ReviewReportsState {
  final List<ReviewReportEntity> reports;
  const ReviewReportsLoaded(this.reports);
  @override
  List<Object?> get props => [reports];
}

class ReviewReportsError extends ReviewReportsState {
  final String message;
  const ReviewReportsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ReviewReportSubmitting extends ReviewReportsState {}

class ReviewReportSubmitted extends ReviewReportsState {}

// Cubit
class ReviewReportsCubit extends Cubit<ReviewReportsState> {
  final ReviewReportRemoteDataSource _dataSource;

  ReviewReportsCubit(this._dataSource) : super(ReviewReportsInitial());

  Future<void> loadUserReports(String userId) async {
    emit(ReviewReportsLoading());
    try {
      final reports = await _dataSource.getUserReports(userId);
      emit(ReviewReportsLoaded(reports));
    } catch (e) {
      emit(ReviewReportsError(e.toString()));
    }
  }

  Future<void> loadAdminReports({String? status}) async {
    emit(ReviewReportsLoading());
    try {
      final reports = await _dataSource.getAdminReports(status: status);
      emit(ReviewReportsLoaded(reports));
    } catch (e) {
      emit(ReviewReportsError(e.toString()));
    }
  }

  Future<bool> submitReport({
    required String reviewId,
    required String reason,
    String? description,
  }) async {
    emit(ReviewReportSubmitting());
    try {
      await _dataSource.createReport(
        reviewId: reviewId,
        reason: reason,
        description: description,
      );
      emit(ReviewReportSubmitted());
      return true;
    } catch (e) {
      emit(ReviewReportsError(e.toString()));
      return false;
    }
  }

  Future<bool> respondToReport({
    required String reportId,
    required String status,
    required String adminResponse,
    bool deleteReview = false,
    bool banReviewer = false,
  }) async {
    try {
      await _dataSource.respondToReport(
        reportId: reportId,
        status: status,
        adminResponse: adminResponse,
        deleteReview: deleteReview,
        banReviewer: banReviewer,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
