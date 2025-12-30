-- Fix product ratings and rating_count based on existing reviews
-- Run this once to sync existing data

-- Update all products with their actual rating stats from reviews
UPDATE products p
SET 
  rating = COALESCE(
    (SELECT ROUND(AVG(r.rating)::numeric, 1) FROM reviews r WHERE r.product_id = p.id),
    0
  ),
  rating_count = COALESCE(
    (SELECT COUNT(*) FROM reviews r WHERE r.product_id = p.id),
    0
  );

-- Create a trigger to automatically update product ratings when reviews change
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
DECLARE
  target_product_id UUID;
  avg_rating NUMERIC;
  review_count INTEGER;
BEGIN
  -- Determine which product to update
  IF TG_OP = 'DELETE' THEN
    target_product_id := OLD.product_id;
  ELSE
    target_product_id := NEW.product_id;
  END IF;
  
  -- Calculate new rating stats
  SELECT 
    COALESCE(ROUND(AVG(rating)::numeric, 1), 0),
    COUNT(*)
  INTO avg_rating, review_count
  FROM reviews
  WHERE product_id = target_product_id;
  
  -- Update the product
  UPDATE products
  SET 
    rating = avg_rating,
    rating_count = review_count
  WHERE id = target_product_id;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS trigger_update_product_rating ON reviews;

-- Create trigger for INSERT, UPDATE, DELETE on reviews
CREATE TRIGGER trigger_update_product_rating
AFTER INSERT OR UPDATE OR DELETE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_product_rating();

-- Verify the fix
SELECT 
  p.id,
  p.name_ar,
  p.rating,
  p.rating_count,
  (SELECT COUNT(*) FROM reviews r WHERE r.product_id = p.id) as actual_count,
  (SELECT ROUND(AVG(r.rating)::numeric, 1) FROM reviews r WHERE r.product_id = p.id) as actual_rating
FROM products p
WHERE EXISTS (SELECT 1 FROM reviews r WHERE r.product_id = p.id)
LIMIT 10;
