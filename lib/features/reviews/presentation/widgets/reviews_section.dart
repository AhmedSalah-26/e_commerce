import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_style.dart';
import '../../../../core/shared_widgets/toast.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/review_entity.dart';
import '../cubit/reviews_cubit.dart';

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
            'review_added'.tr(),
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else if (state is ReviewsError) {
          Tost.showCustomToast(
            state.message,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        if (state is ReviewsLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColours.brownMedium),
            ),
          );
        }

        if (state is ReviewsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Row(
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
              ),
              const SizedBox(height: 12),

              // Average Rating Summary
              if (state.totalReviews > 0) _buildRatingSummary(state),

              const SizedBox(height: 16),

              // Add/Edit Review Button
              _buildAddReviewSection(state),

              const SizedBox(height: 16),

              // Reviews List
              if (state.reviews.isEmpty)
                _buildEmptyReviews()
              else
                ...state.reviews.map((review) => _buildReviewCard(review)),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRatingSummary(ReviewsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColours.greyLighter,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColours.brownMedium,
                ),
              ),
              RatingBarIndicator(
                rating: state.averageRating,
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 16,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'based_on_reviews'
                  .tr()
                  .replaceAll('{}', state.totalReviews.toString())
                  .replaceAll('{count}', state.totalReviews.toString()),
              style: AppTextStyle.normal_12_black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection(ReviewsLoaded state) {
    final authState = context.read<AuthCubit>().state;
    final isAuthenticated = authState is AuthAuthenticated;

    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColours.greyLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.login, color: AppColours.brownMedium),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'login_required'.tr(),
                style: AppTextStyle.normal_16_greyDark,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _showReviewDialog(state.userReview),
      icon: Icon(
        state.userReview != null ? Icons.edit : Icons.rate_review,
        color: Colors.white,
      ),
      label: Text(
        state.userReview != null ? 'edit_review'.tr() : 'add_review'.tr(),
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColours.brownMedium,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.rate_review_outlined,
            size: 60,
            color: AppColours.greyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'no_reviews'.tr(),
            style: AppTextStyle.normal_16_greyDark,
          ),
          const SizedBox(height: 8),
          Text(
            'be_first_review'.tr(),
            style: AppTextStyle.normal_12_black.copyWith(
              color: AppColours.greyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewEntity review) {
    final authState = context.read<AuthCubit>().state;
    final isOwner =
        authState is AuthAuthenticated && authState.user.id == review.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColours.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColours.brownLight.withValues(alpha: 0.2),
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColours.brownMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColours.brownDark,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: review.rating.toDouble(),
                direction: Axis.horizontal,
                itemCount: 5,
                itemSize: 16,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: AppTextStyle.normal_12_black,
            ),
          ],
          if (isOwner) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(review),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: Text(
                    'delete'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showReviewDialog(ReviewEntity? existingReview) {
    double rating = existingReview?.rating.toDouble() ?? 0;
    final commentController = TextEditingController(
      text: existingReview?.comment ?? '',
    );

    // Store references before opening the modal
    final reviewsCubit = context.read<ReviewsCubit>();
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  existingReview != null
                      ? 'edit_review'.tr()
                      : 'add_review'.tr(),
                  style: AppTextStyle.semiBold_20_dark_brown,
                ),
                const SizedBox(height: 20),
                Text(
                  'your_rating'.tr(),
                  style: AppTextStyle.normal_16_brownLight,
                ),
                const SizedBox(height: 8),
                Center(
                  child: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 40,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (value) {
                      setModalState(() => rating = value);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'write_comment'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColours.brownLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (rating == 0) {
                        Tost.showCustomToast(
                          'rating_required'.tr(),
                          backgroundColor: Colors.orange,
                          textColor: Colors.white,
                        );
                        return;
                      }

                      final authState = authCubit.state;
                      if (authState is AuthAuthenticated) {
                        if (existingReview != null) {
                          reviewsCubit.updateReview(
                            existingReview.id,
                            widget.productId,
                            authState.user.id,
                            rating.toInt(),
                            commentController.text.trim().isEmpty
                                ? null
                                : commentController.text.trim(),
                          );
                        } else {
                          reviewsCubit.addReview(
                            widget.productId,
                            authState.user.id,
                            rating.toInt(),
                            commentController.text.trim().isEmpty
                                ? null
                                : commentController.text.trim(),
                          );
                        }
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColours.brownMedium,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      existingReview != null
                          ? 'update_review'.tr()
                          : 'submit_review'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ReviewEntity review) {
    // Store references before opening the dialog
    final reviewsCubit = context.read<ReviewsCubit>();
    final authCubit = context.read<AuthCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('delete_review'.tr()),
        content: const Text('هل أنت متأكد من حذف تقييمك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(color: AppColours.greyDark),
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
