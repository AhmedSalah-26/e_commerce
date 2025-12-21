-- Fix Product Ratings Script
-- This script ensures product ratings are calculated from actual reviews
-- Run this in Supabase SQL Editor

-- First, make sure the rating column exists and has correct type
ALTER TABLE products 
ALTER COLUMN rating TYPE DECIMAL(3,2) USING rating::DECIMAL(3,2);

-- Set default rating to 0 for products without reviews
ALTER TABLE products 
ALTER COLUMN rating SET DEFAULT 0;

-- Update all product ratings based on actual reviews
UPDATE products p
SET rating = COALESCE(
    (SELECT AVG(r.rating)::DECIMAL(3,2) 
     FROM reviews r 
     WHERE r.product_id = p.id),
    0
);

-- Add review_count column if it doesn't exist (optional but useful)
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0;

-- Update review counts
UPDATE products p
SET review_count = (
    SELECT COUNT(*) 
    FROM reviews r 
    WHERE r.product_id = p.id
);

-- Recreate the trigger function to also update review_count
CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL(3,2);
    total_reviews INTEGER;
    target_product_id UUID;
BEGIN
    -- Determine which product to update
    IF TG_OP = 'DELETE' THEN
        target_product_id := OLD.product_id;
    ELSE
        target_product_id := NEW.product_id;
    END IF;
    
    -- Calculate new average rating and count
    SELECT 
        COALESCE(AVG(rating)::DECIMAL(3,2), 0),
        COUNT(*)
    INTO avg_rating, total_reviews
    FROM reviews
    WHERE product_id = target_product_id;
    
    -- Update the product
    UPDATE products 
    SET 
        rating = avg_rating,
        review_count = total_reviews
    WHERE id = target_product_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
DROP TRIGGER IF EXISTS trigger_update_product_rating ON reviews;
CREATE TRIGGER trigger_update_product_rating
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_product_rating();

-- Verify the update worked
SELECT 
    p.id,
    p.name_ar,
    p.rating,
    p.review_count,
    (SELECT COUNT(*) FROM reviews r WHERE r.product_id = p.id) as actual_count,
    (SELECT AVG(rating) FROM reviews r WHERE r.product_id = p.id) as actual_avg
FROM products p
ORDER BY p.created_at DESC
LIMIT 10;
