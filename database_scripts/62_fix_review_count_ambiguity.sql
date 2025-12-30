-- Fix ambiguous review_count reference in update_product_rating trigger
-- The variable name conflicts with the column name

CREATE OR REPLACE FUNCTION update_product_rating()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  target_product_id UUID;
  v_avg_rating NUMERIC;
  v_review_count INTEGER;
BEGIN
  -- Determine which product to update
  IF TG_OP = 'DELETE' THEN
    target_product_id := OLD.product_id;
  ELSE
    target_product_id := NEW.product_id;
  END IF;

  -- Calculate new average rating and count
  SELECT 
    COALESCE(ROUND(AVG(rating)::numeric, 1), 0),
    COUNT(*)
  INTO v_avg_rating, v_review_count
  FROM reviews
  WHERE product_id = target_product_id;

  -- Update the product
  UPDATE products 
  SET 
    rating = v_avg_rating,
    rating_count = v_review_count
  WHERE id = target_product_id;

  IF TG_OP = 'DELETE' THEN
    RETURN OLD;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Recreate triggers to use the updated function
DROP TRIGGER IF EXISTS update_product_rating_on_insert ON reviews;
DROP TRIGGER IF EXISTS update_product_rating_on_update ON reviews;
DROP TRIGGER IF EXISTS update_product_rating_on_delete ON reviews;

CREATE TRIGGER update_product_rating_on_insert
  AFTER INSERT ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_product_rating();

CREATE TRIGGER update_product_rating_on_update
  AFTER UPDATE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_product_rating();

CREATE TRIGGER update_product_rating_on_delete
  AFTER DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_product_rating();
