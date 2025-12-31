import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reviews/reviews_sheet_header.dart';
import 'reviews/rating_overview.dart';
import 'reviews/rating_distribution_chart.dart';
import 'reviews/review_item_card.dart';

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
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          ReviewsSheetHeader(
            productName: widget.productName,
            isRtl: widget.isRtl,
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                RatingOverview(
                  avgRating: widget.avgRating,
                  reviewCount: widget.reviewCount,
                  isRtl: widget.isRtl,
                ),
                const SizedBox(height: 24),
                RatingDistributionChart(
                  distribution: _ratingDistribution,
                  totalReviews: widget.reviewCount,
                ),
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
                  ..._reviews.map((review) => ReviewItemCard(
                        review: review,
                        isRtl: widget.isRtl,
                      )),
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
}
