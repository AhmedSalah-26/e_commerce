import 'package:flutter/material.dart';
import 'product_reviews_sheet.dart';

class TopRatedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isRtl;

  const TopRatedProductCard({
    super.key,
    required this.product,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = isRtl
        ? (product['name_ar'] ?? product['name'])
        : (product['name'] ?? product['name_ar']);
    final images = product['images'] as List? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] : null;
    final avgRating = (product['avg_rating'] ?? 0).toDouble();
    final reviewCount = product['review_count'] ?? 0;
    final price = (product['price'] ?? 0).toDouble();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showReviews(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildImage(imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${price.toStringAsFixed(0)} ${isRtl ? 'ج.م' : 'EGP'}',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRatingBar(avgRating, reviewCount, theme),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildRatingBar(double avgRating, int reviewCount, ThemeData theme) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (avgRating >= starValue) {
            return const Icon(Icons.star, size: 16, color: Colors.amber);
          } else if (avgRating >= starValue - 0.5) {
            return const Icon(Icons.star_half, size: 16, color: Colors.amber);
          }
          return Icon(Icons.star_border, size: 16, color: Colors.grey[400]);
        }),
        const SizedBox(width: 8),
        Text(
          avgRating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount ${isRtl ? 'تقييم' : 'reviews'})',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  void _showReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductReviewsSheet(
        productId: product['id'],
        productName: isRtl
            ? (product['name_ar'] ?? product['name'])
            : (product['name'] ?? product['name_ar']),
        avgRating: (product['avg_rating'] ?? 0).toDouble(),
        reviewCount: product['review_count'] ?? 0,
        isRtl: isRtl,
      ),
    );
  }
}
