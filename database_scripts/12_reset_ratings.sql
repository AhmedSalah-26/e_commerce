-- Calculate and update product ratings from reviews table
-- Run this in Supabase SQL Editor

-- Update all product ratings based on actual reviews
UPDATE products p
SET rating = COALESCE(
    (SELECT AVG(r.rating)::DECIMAL(3,2) 
     FROM reviews r 
     WHERE r.product_id = p.id),
    0
);

-- Verify the update
SELECT 
    p.id,
    p.name_ar,
    p.rating,
    (SELECT COUNT(*) FROM reviews r WHERE r.product_id = p.id) as reviews_count,
    (SELECT AVG(rating) FROM reviews r WHERE r.product_id = p.id) as calculated_avg
FROM products p
ORDER BY p.rating DESC;
