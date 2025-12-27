import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_text_style.dart';
import '../../../../../core/shared_widgets/toast.dart';
import '../../../../../core/shared_widgets/skeleton_widgets.dart';
import '../../../../../core/utils/error_helper.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../auth/presentation/cubit/auth_state.dart';
import '../../../domain/entities/review_entity.dart';
import '../../cubit/reviews_cubit.dart';
import 'review_rating_summary.dart';
import 'add_review_button.dart';
import 'empty_reviews_widget.dart';
import 'review_card.dart';
import 'review_form_dialog.dart';

class ReviewsSection extends StatefulWidget {
  final String productId;

  const ReviewsSection({super.key, required this.productId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    context.read<ReviewsCubit>().loadReviews(widget.productId, userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewsCubit, ReviewsState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          Tost.showCustomToast(
            context,
            'review_added'.tr(),
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else if (state is ReviewsError) {
          Tost.showCustomToast(
            context,
            ErrorHelper.getUserFriendlyMessage(state.message),
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        if (state is ReviewsLoading) {
          return const ReviewsSectionSkeleton();
        }

        if (state is ReviewsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(state),
              const SizedBox(height: 12),
              if (state.totalReviews > 0)
                ReviewRatingSummary(
                  averageRating: state.averageRating,
                  totalReviews: state.totalReviews,
                ),
              const SizedBox(height: 16),
              _buildAddReviewButton(state),
              const SizedBox(height: 16),
              if (state.reviews.isEmpty)
                const EmptyReviewsWidget()
              else
                ...state.reviews.map((review) => _buildReviewCard(review)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(ReviewsLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'reviews_and_ratings'.tr(),
          style: AppTextStyle.semiBold_20_dark_brown,
        ),
        if (state.totalReviews > 0)
          Text(
            '(${state.totalReviews})',
            style: AppTextStyle.normal_16_greyDark,
          ),
      ],
    );
  }

  Widget _buildAddReviewButton(ReviewsLoaded state) {
    final authState = context.read<AuthCubit>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    return AddReviewButton(
      isAuthenticated: isAuthenticated,
      userReview: state.userReview,
      onPressed: () => _showReviewDialog(state.userReview),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    final authState = context.read<AuthCubit>().state;
    final isOwner =
        authState is AuthAuthenticated && authState.user.id == review.userId;

    return ReviewCard(
      review: review,
      isOwner: isOwner,
      onDelete: () => _showDeleteConfirmation(review),
    );
  }

  void _showReviewDialog(ReviewEntity? existingReview) {
    final reviewsCubit = context.read<ReviewsCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReviewFormDialog(
        existingReview: existingReview,
        onSubmit: (rating, comment) {
          final authState = authCubit.state;
          if (authState is AuthAuthenticated) {
            if (existingReview != null) {
              reviewsCubit.updateReview(
                existingReview.id,
                widget.productId,
                authState.user.id,
                rating,
                comment,
              );
            } else {
              reviewsCubit.addReview(
                widget.productId,
                authState.user.id,
                rating,
                comment,
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(ReviewEntity review) {
    final reviewsCubit = context.read<ReviewsCubit>();
    final authCubit = context.read<AuthCubit>();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_review'.tr(),
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text('هل أنت متأكد من حذف تقييمك؟',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'cancel'.tr(),
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final authState = authCubit.state;
              if (authState is AuthAuthenticated) {
                reviewsCubit.deleteReview(
                  review.id,
                  widget.productId,
                  authState.user.id,
                );
              }
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
