-- Drop existing function first (required when changing return type)
DROP FUNCTION IF EXISTS get_discounted_products_sorted(integer, integer);

-- Function to get discounted products sorted by discount percentage (highest first)
-- Updated to include flash sale fields
CREATE OR REPLACE FUNCTION get_discounted_products_sorted(
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  name_ar TEXT,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  price DECIMAL,
  discount_price DECIMAL,
  images TEXT[],
  category_id UUID,
  stock INT,
  rating DECIMAL,
  rating_count INT,
  is_active BOOLEAN,
  is_featured BOOLEAN,
  merchant_id UUID,
  created_at TIMESTAMPTZ,
  discount_percentage DECIMAL,
  is_flash_sale BOOLEAN,
  flash_sale_start TIMESTAMPTZ,
  flash_sale_end TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name_ar,
    p.name_en,
    p.description_ar,
    p.description_en,
    p.price,
    p.discount_price,
    p.images,
    p.category_id,
    p.stock,
    p.rating,
    p.rating_count,
    p.is_active,
    p.is_featured,
    p.merchant_id,
    p.created_at,
    ROUND(((p.price - p.discount_price) / p.price * 100)::DECIMAL, 2) as discount_percentage,
    p.is_flash_sale,
    p.flash_sale_start,
    p.flash_sale_end
  FROM products p
  WHERE p.is_active = true
    AND p.discount_price IS NOT NULL
    AND p.price > 0
    AND p.discount_price > 0
    AND p.discount_price < p.price
  ORDER BY ((p.price - p.discount_price) / p.price) DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_discounted_products_sorted TO authenticated;
GRANT EXECUTE ON FUNCTION get_discounted_products_sorted TO anon;
