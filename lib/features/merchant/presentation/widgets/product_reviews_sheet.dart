import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../review_reports/presentation/widgets/report_review_dialog.dart';

class ProductReviewsSheet extends StatefulWidget {
  final String productId;
  final String? productName;
  final double avgRating;
  final int reviewCount;
  final bool isRtl;

  const ProductReviewsSheet({
    super.key,
    required this.productId,
    this.productName,
    required this.avgRating,
    required this.reviewCount,
    required this.isRtl,
  });

  @override
  State<ProductReviewsSheet> createState() => _ProductReviewsSheetState();
}

class _ProductReviewsSheetState extends State<ProductReviewsSheet> {
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _reviews = [];
  Map<int, int> _ratingDistribution = {};
  bool _isLoading = true;
  bool _hasMore = true;
  int _page = 0;
  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadRatingDistribution();
    _loadReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadReviews();
    }
  }

  Future<void> _loadRatingDistribution() async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select('rating')
          .eq('product_id', widget.productId);

      final reviews = List<Map<String, dynamic>>.from(response);
      final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final review in reviews) {
        final rating = review['rating'] as int;
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }

      setState(() => _ratingDistribution = distribution);
    } catch (e) {
      debugPrint('Error loading rating distribution: $e');
    }
  }

  Future<void> _loadReviews() async {
    if (_isLoading && _page > 0 || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select('*, profiles:user_id(name, avatar_url)')
          .eq('product_id', widget.productId)
          .order('created_at', ascending: false)
          .range(_page * _pageSize, (_page + 1) * _pageSize - 1);

      final reviews = List<Map<String, dynamic>>.from(response);

      setState(() {
        _reviews.addAll(reviews);
        _page++;
        _hasMore = reviews.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                _buildRatingOverview(theme),
                const SizedBox(height: 24),
                _buildRatingDistribution(theme),
                const Divider(height: 32),
                Text(
                  widget.isRtl ? 'التعليقات' : 'Reviews',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isLoading && _reviews.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (_reviews.isEmpty)
                  _buildEmptyReviews()
                else
                  ..._reviews.map((review) => _buildReviewCard(review, theme)),
                if (_isLoading && _reviews.isNotEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.productName ?? (widget.isRtl ? 'التقييمات' : 'Reviews'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverview(ThemeData theme) {
    return Row(
      children: [
        Column(
          children: [
            Text(
              widget.avgRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                if (widget.avgRating >= starValue) {
                  return const Icon(Icons.star, size: 20, color: Colors.amber);
                } else if (widget.avgRating >= starValue - 0.5) {
                  return const Icon(Icons.star_half,
                      size: 20, color: Colors.amber);
                }
                return Icon(Icons.star_border,
                    size: 20, color: Colors.grey[400]);
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.reviewCount} ${widget.isRtl ? 'تقييم' : 'reviews'}',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(ThemeData theme) {
    final total = widget.reviewCount > 0 ? widget.reviewCount : 1;

    return Column(
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final count = _ratingDistribution[stars] ?? 0;
        final percentage = count / total;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text('$stars',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.isRtl ? 'لا توجد تعليقات بعد' : 'No reviews yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review, ThemeData theme) {
    final profile = review['profiles'] as Map<String, dynamic>?;
    final userName = profile?['name'] ?? (widget.isRtl ? 'مستخدم' : 'User');
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
                // Report button
                IconButton(
                  icon: Icon(
                    Icons.flag_outlined,
                    size: 20,
                    color: theme.colorScheme.outline,
                  ),
                  onPressed: () => _reportReview(reviewId, userName, comment),
                  tooltip: widget.isRtl ? 'إبلاغ' : 'Report',
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

  void _reportReview(String reviewId, String reviewerName, String? comment) {
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
      return widget.isRtl ? 'اليوم' : 'Today';
    } else if (diff.inDays == 1) {
      return widget.isRtl ? 'أمس' : 'Yesterday';
    } else if (diff.inDays < 7) {
      return widget.isRtl
          ? 'منذ ${diff.inDays} أيام'
          : '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
