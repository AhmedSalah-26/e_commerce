-- Drop old function versions to avoid ambiguity
DROP FUNCTION IF EXISTS get_merchant_inventory_details(UUID, TEXT, INTEGER, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS get_merchant_inventory_details(UUID, TEXT, INTEGER, INTEGER, INTEGER, INTEGER, INTEGER);

-- Recreate with pagination support
CREATE OR REPLACE FUNCTION get_merchant_inventory_details(
  p_merchant_id UUID,
  p_filter TEXT DEFAULT 'all',
  p_days_for_analysis INTEGER DEFAULT 30,
  p_low_stock_threshold INTEGER DEFAULT 10,
  p_high_stock_threshold INTEGER DEFAULT 100,
  p_page INTEGER DEFAULT 0,
  p_limit INTEGER DEFAULT 20
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
  v_offset INTEGER;
BEGIN
  v_offset := p_page * p_limit;

  WITH product_sales AS (
    SELECT 
      p.id,
      p.name_ar,
      p.name_en,
      p.stock,
      p.price,
      p.discount_price,
      p.images,
      p.is_active,
      COALESCE(SUM(CASE 
        WHEN o.created_at >= NOW() - (p_days_for_analysis || ' days')::INTERVAL 
        AND o.status NOT IN ('cancelled')
        THEN oi.quantity 
        ELSE 0 
      END), 0) as sales_last_period,
      COALESCE(SUM(CASE 
        WHEN o.status NOT IN ('cancelled')
        THEN oi.quantity 
        ELSE 0 
      END), 0) as total_sales,
      MAX(o.created_at) FILTER (WHERE o.status NOT IN ('cancelled')) as last_sale_date
    FROM products p
    LEFT JOIN order_items oi ON oi.product_id = p.id
    LEFT JOIN orders o ON o.id = oi.order_id
    WHERE p.merchant_id = p_merchant_id AND p.is_suspended = false
    GROUP BY p.id, p.name_ar, p.name_en, p.stock, p.price, p.discount_price, p.images, p.is_active
  ),
  enriched_products AS (
    SELECT 
      ps.*,
      CASE WHEN ps.stock > 0 THEN ROUND((ps.sales_last_period::DECIMAL / ps.stock), 2) ELSE 0 END as turnover_rate,
      CASE WHEN (ps.total_sales + ps.stock) > 0 
        THEN ROUND((ps.total_sales::DECIMAL / (ps.total_sales + ps.stock) * 100), 1) 
        ELSE 0 
      END as sell_through_rate,
      CASE WHEN ps.sales_last_period > 0 
        THEN ROUND((ps.stock::DECIMAL / (ps.sales_last_period::DECIMAL / p_days_for_analysis)), 0)
        ELSE 999
      END as days_of_stock,
      CASE WHEN ps.sales_last_period > 0 
        THEN GREATEST(0, ROUND((ps.sales_last_period * 2) - ps.stock, 0))
        ELSE 0 
      END as suggested_reorder_qty,
      CASE 
        WHEN ps.stock = 0 THEN 'out_of_stock'
        WHEN ps.stock <= p_low_stock_threshold THEN 'low_stock'
        WHEN ps.stock > p_high_stock_threshold AND ps.sales_last_period < 5 THEN 'overstock'
        WHEN ps.stock > 0 AND ps.last_sale_date IS NULL THEN 'dead_stock'
        WHEN ps.stock > 0 AND ps.last_sale_date < NOW() - INTERVAL '90 days' THEN 'dead_stock'
        ELSE 'healthy'
      END as stock_status
    FROM product_sales ps
  ),
  filtered_products AS (
    SELECT * FROM enriched_products ep
    WHERE 
      p_filter = 'all' 
      OR ep.stock_status = p_filter
      OR (p_filter = 'alerts' AND ep.stock_status IN ('out_of_stock', 'low_stock', 'overstock', 'dead_stock'))
  )
  SELECT json_agg(sub) INTO v_result
  FROM (
    SELECT 
      fp.id,
      fp.name_ar,
      fp.name_en,
      fp.stock,
      fp.price,
      fp.discount_price,
      CASE WHEN array_length(fp.images, 1) > 0 THEN fp.images[1] ELSE NULL END as image,
      fp.is_active,
      fp.sales_last_period,
      fp.total_sales,
      fp.last_sale_date,
      fp.turnover_rate,
      fp.sell_through_rate,
      fp.days_of_stock,
      fp.suggested_reorder_qty,
      fp.stock_status
    FROM filtered_products fp
    ORDER BY 
      CASE fp.stock_status
        WHEN 'out_of_stock' THEN 1
        WHEN 'low_stock' THEN 2
        WHEN 'dead_stock' THEN 3
        WHEN 'overstock' THEN 4
        ELSE 5
      END,
      fp.stock ASC
    LIMIT p_limit OFFSET v_offset
  ) sub;

  RETURN COALESCE(v_result, '[]'::JSON);
END;
$$;

GRANT EXECUTE ON FUNCTION get_merchant_inventory_details TO authenticated;
