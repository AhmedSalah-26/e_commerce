-- Sync all product ratings from reviews table
-- Run this to fix products where rating/review_count is out of sync

-- First, let's see the current state
SELECT p.id, p.name_ar, p.rating as current_rating, p.review_count as current_count,
       COALESCE(AVG(r.rating), 0) as actual_rating,
       COUNT(r.id) as actual_count
FROM products p
LEFT JOIN reviews r ON r.product_id = p.id
GROUP BY p.id, p.name_ar, p.rating, p.review_count
HAVING p.rating != COALESCE(AVG(r.rating), 0) 
    OR p.review_count != COUNT(r.id)
LIMIT 20;

-- Update all products with correct ratings
UPDATE products p
SET 
  rating = COALESCE(sub.avg_rating, 0),
  review_count = COALESCE(sub.review_count, 0)
FROM (
  SELECT 
    product_id,
    ROUND(AVG(rating)::DECIMAL, 2) as avg_rating,
    COUNT(*)::INTEGER as review_count
  FROM reviews
  GROUP BY product_id
) sub
WHERE p.id = sub.product_id
  AND (p.rating != sub.avg_rating OR p.review_count != sub.review_count);

-- Also set rating to 0 for products with no reviews
UPDATE products
SET rating = 0, review_count = 0
WHERE id NOT IN (SELECT DISTINCT product_id FROM reviews)
  AND (rating != 0 OR review_count != 0);

-- Verify the fix
SELECT id, name_ar, rating, review_count
FROM products
WHERE review_count > 0
ORDER BY review_count DESC
LIMIT 10;
