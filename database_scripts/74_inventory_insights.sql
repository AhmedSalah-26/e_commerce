-- =====================================================
-- INVENTORY INSIGHTS FOR MERCHANTS
-- =====================================================
-- Provides inventory analytics including:
-- 1. Inventory Turnover Rate
-- 2. Low Stock Alerts
-- 3. Overstock/Slow Moving Products
-- 4. Dead Stock Detection
-- 5. Sell-through Rate
-- 6. Days of Stock Remaining

-- Function to get inventory insights for a merchant
CREATE OR REPLACE FUNCTION get_merchant_inventory_insights(
  p_merchant_id UUID,
  p_days_for_dead_stock INTEGER DEFAULT 90,
  p_low_stock_threshold INTEGER DEFAULT 10,
  p_high_stock_threshold INTEGER DEFAULT 100
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
  v_total_products INTEGER;
  v_total_stock INTEGER;
  v_total_stock_value DECIMAL;
  v_low_stock_count INTEGER;
  v_out_of_stock_count INTEGER;
  v_overstock_count INTEGER;
  v_dead_stock_count INTEGER;
BEGIN
  -- Get basic counts
  SELECT 
    COUNT(*),
    COALESCE(SUM(stock), 0),
    COALESCE(SUM(stock * COALESCE(discount_price, price)), 0)
  INTO v_total_products, v_total_stock, v_total_stock_value
  FROM products
  WHERE merchant_id = p_merchant_id AND is_suspended = false;

  -- Low stock count (stock > 0 but <= threshold)
  SELECT COUNT(*) INTO v_low_stock_count
  FROM products
  WHERE merchant_id = p_merchant_id 
    AND is_suspended = false
    AND stock > 0 
    AND stock <= p_low_stock_threshold;

  -- Out of stock count
  SELECT COUNT(*) INTO v_out_of_stock_count
  FROM products
  WHERE merchant_id = p_merchant_id 
    AND is_suspended = false
    AND stock = 0;

  -- Overstock count (high stock with low sales)
  SELECT COUNT(*) INTO v_overstock_count
  FROM products p
  WHERE p.merchant_id = p_merchant_id 
    AND p.is_suspended = false
    AND p.stock > p_high_stock_threshold
    AND (
      SELECT COALESCE(SUM(oi.quantity), 0)
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE oi.product_id = p.id
        AND o.status NOT IN ('cancelled')
        AND o.created_at >= NOW() - INTERVAL '30 days'
    ) < 5;

  -- Dead stock count (no sales in X days)
  SELECT COUNT(*) INTO v_dead_stock_count
  FROM products p
  WHERE p.merchant_id = p_merchant_id 
    AND p.is_suspended = false
    AND p.stock > 0
    AND NOT EXISTS (
      SELECT 1
      FROM order_items oi
      JOIN orders o ON o.id = oi.order_id
      WHERE oi.product_id = p.id
        AND o.status NOT IN ('cancelled')
        AND o.created_at >= NOW() - (p_days_for_dead_stock || ' days')::INTERVAL
    );

  -- Build result JSON
  v_result := json_build_object(
    'summary', json_build_object(
      'total_products', v_total_products,
      'total_stock', v_total_stock,
      'total_stock_value', v_total_stock_value,
      'low_stock_count', v_low_stock_count,
      'out_of_stock_count', v_out_of_stock_count,
      'overstock_count', v_overstock_count,
      'dead_stock_count', v_dead_stock_count
    ),
    'thresholds', json_build_object(
      'low_stock', p_low_stock_threshold,
      'high_stock', p_high_stock_threshold,
      'dead_stock_days', p_days_for_dead_stock
    )
  );

  RETURN v_result;
END;
$$;

-- Function to get detailed product inventory data
CREATE OR REPLACE FUNCTION get_merchant_inventory_details(
  p_merchant_id UUID,
  p_filter TEXT DEFAULT 'all', -- 'all', 'low_stock', 'out_of_stock', 'overstock', 'dead_stock'
  p_days_for_analysis INTEGER DEFAULT 30,
  p_low_stock_threshold INTEGER DEFAULT 10,
  p_high_stock_threshold INTEGER DEFAULT 100
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_result JSON;
BEGIN
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
      -- Calculate inventory turnover (sales / avg stock, simplified as sales / current stock)
      CASE WHEN ps.stock > 0 THEN ROUND((ps.sales_last_period::DECIMAL / ps.stock), 2) ELSE 0 END as turnover_rate,
      -- Calculate sell-through rate (sold / (sold + remaining))
      CASE WHEN (ps.total_sales + ps.stock) > 0 
        THEN ROUND((ps.total_sales::DECIMAL / (ps.total_sales + ps.stock) * 100), 1) 
        ELSE 0 
      END as sell_through_rate,
      -- Calculate days of stock remaining
      CASE WHEN ps.sales_last_period > 0 
        THEN ROUND((ps.stock::DECIMAL / (ps.sales_last_period::DECIMAL / p_days_for_analysis)), 0)
        ELSE 999 -- Infinite if no sales
      END as days_of_stock,
      -- Calculate suggested reorder quantity (based on sales velocity)
      CASE WHEN ps.sales_last_period > 0 
        THEN GREATEST(0, ROUND((ps.sales_last_period * 2) - ps.stock, 0)) -- 2 months supply
        ELSE 0 
      END as suggested_reorder_qty,
      -- Determine stock status
      CASE 
        WHEN ps.stock = 0 THEN 'out_of_stock'
        WHEN ps.stock <= p_low_stock_threshold THEN 'low_stock'
        WHEN ps.stock > p_high_stock_threshold AND ps.sales_last_period < 5 THEN 'overstock'
        WHEN ps.stock > 0 AND ps.last_sale_date IS NULL THEN 'dead_stock'
        WHEN ps.stock > 0 AND ps.last_sale_date < NOW() - INTERVAL '90 days' THEN 'dead_stock'
        ELSE 'healthy'
      END as stock_status
    FROM product_sales ps
  )
  SELECT json_agg(
    json_build_object(
      'id', ep.id,
      'name_ar', ep.name_ar,
      'name_en', ep.name_en,
      'stock', ep.stock,
      'price', ep.price,
      'discount_price', ep.discount_price,
      'image', CASE WHEN array_length(ep.images, 1) > 0 THEN ep.images[1] ELSE NULL END,
      'is_active', ep.is_active,
      'sales_last_period', ep.sales_last_period,
      'total_sales', ep.total_sales,
      'last_sale_date', ep.last_sale_date,
      'turnover_rate', ep.turnover_rate,
      'sell_through_rate', ep.sell_through_rate,
      'days_of_stock', ep.days_of_stock,
      'suggested_reorder_qty', ep.suggested_reorder_qty,
      'stock_status', ep.stock_status
    )
    ORDER BY 
      CASE ep.stock_status
        WHEN 'out_of_stock' THEN 1
        WHEN 'low_stock' THEN 2
        WHEN 'dead_stock' THEN 3
        WHEN 'overstock' THEN 4
        ELSE 5
      END,
      ep.stock ASC
  ) INTO v_result
  FROM enriched_products ep
  WHERE 
    p_filter = 'all' 
    OR ep.stock_status = p_filter
    OR (p_filter = 'alerts' AND ep.stock_status IN ('out_of_stock', 'low_stock', 'overstock', 'dead_stock'));

  RETURN COALESCE(v_result, '[]'::JSON);
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_merchant_inventory_insights TO authenticated;
GRANT EXECUTE ON FUNCTION get_merchant_inventory_details TO authenticated;
