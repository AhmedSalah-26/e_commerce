import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../domain/entities/review_entity.dart';

// States
abstract class ReviewsState extends Equatable {
  const ReviewsState();
  @override
  List<Object?> get props => [];
}

class ReviewsInitial extends ReviewsState {}

class ReviewsLoading extends ReviewsState {}

class ReviewsLoaded extends ReviewsState {
  final List<ReviewEntity> reviews;
  final ReviewEntity? userReview;
  final double averageRating;
  final int totalReviews;

  const ReviewsLoaded({
    required this.reviews,
    this.userReview,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [reviews, userReview, averageRating, totalReviews];
}

class ReviewsError extends ReviewsState {
  final String message;
  const ReviewsError(this.message);
  @override
  List<Object?> get props => [message];
}

class ReviewSubmitting extends ReviewsState {}

class ReviewSubmitted extends ReviewsState {}

// Cubit
class ReviewsCubit extends Cubit<ReviewsState> {
  final ReviewRemoteDataSource _dataSource;

  ReviewsCubit(this._dataSource) : super(ReviewsInitial());

  Future<void> loadReviews(String productId, {String? userId}) async {
    emit(ReviewsLoading());
    try {
      final reviews = await _dataSource.getProductReviews(productId);

      ReviewEntity? userReview;
      if (userId != null) {
        userReview = await _dataSource.getUserReview(productId, userId);
      }

      final totalReviews = reviews.length;
      final averageRating = totalReviews > 0
          ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / totalReviews
          : 0.0;

      emit(ReviewsLoaded(
        reviews: reviews,
        userReview: userReview,
        averageRating: averageRating,
        totalReviews: totalReviews,
      ));
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  Future<void> addReview(
    String productId,
    String userId,
    int rating,
    String? comment,
  ) async {
    emit(ReviewSubmitting());
    try {
      await _dataSource.addReview(productId, userId, rating, comment);
      emit(ReviewSubmitted());
      await loadReviews(productId, userId: userId);
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  Future<void> updateReview(
    String reviewId,
    String productId,
    String userId,
    int rating,
    String? comment,
  ) async {
    emit(ReviewSubmitting());
    try {
      await _dataSource.updateReview(reviewId, rating, comment);
      emit(ReviewSubmitted());
      await loadReviews(productId, userId: userId);
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }

  Future<void> deleteReview(
      String reviewId, String productId, String userId) async {
    emit(ReviewSubmitting());
    try {
      await _dataSource.deleteReview(reviewId);
      emit(ReviewSubmitted());
      await loadReviews(productId, userId: userId);
    } catch (e) {
      emit(ReviewsError(e.toString()));
    }
  }
}
