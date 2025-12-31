import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../review_reports/presentation/widgets/report_review_dialog.dart';

class ReviewItemCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool isRtl;

  const ReviewItemCard({
    super.key,
    required this.review,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = review['profiles'] as Map<String, dynamic>?;
    final userName = profile?['name'] ?? (isRtl ? 'مستخدم' : 'User');
    final avatarUrl = profile?['avatar_url'] as String?;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final rating = review['rating'] as int;
    final comment = review['comment'] as String?;
    final reviewId = review['id'] as String;
    final createdAt = review['created_at'] != null
        ? DateTime.parse(review['created_at'])
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: hasAvatar
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => Text(
                              userName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : Text(
                          userName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                          if (createdAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.flag_outlined,
                    size: 20,
                    color: theme.colorScheme.outline,
                  ),
                  onPressed: () =>
                      _reportReview(context, reviewId, userName, comment),
                  tooltip: isRtl ? 'إبلاغ' : 'Report',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(comment, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  void _reportReview(BuildContext context, String reviewId, String reviewerName,
      String? comment) {
    ReportReviewDialog.show(
      context,
      reviewId: reviewId,
      reviewerName: reviewerName,
      reviewComment: comment,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return isRtl ? 'اليوم' : 'Today';
    } else if (diff.inDays == 1) {
      return isRtl ? 'أمس' : 'Yesterday';
    } else if (diff.inDays < 7) {
      return isRtl ? 'منذ ${diff.inDays} أيام' : '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
