-- =====================================================
-- Monthly Statistics Function for Admin Dashboard Charts
-- Returns last 6 months with MM/YY format
-- =====================================================

-- Drop old function if exists
DROP FUNCTION IF EXISTS get_monthly_stats(INTEGER);

-- Create monthly stats function
CREATE OR REPLACE FUNCTION get_monthly_stats(p_months INTEGER DEFAULT 6)
RETURNS TABLE (
  month_name TEXT,
  month_number INTEGER,
  year_number INTEGER,
  total_sales NUMERIC,
  new_customers INTEGER,
  total_orders INTEGER,
  cancelled_orders INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH months AS (
    SELECT 
      TO_CHAR(d, 'MM/YY') as m_label,
      EXTRACT(MONTH FROM d)::INTEGER as m_num,
      EXTRACT(YEAR FROM d)::INTEGER as y_num,
      DATE_TRUNC('month', d) as month_start,
      DATE_TRUNC('month', d) + INTERVAL '1 month' - INTERVAL '1 second' as month_end
    FROM generate_series(
      DATE_TRUNC('month', NOW()) - ((p_months - 1) || ' months')::INTERVAL,
      DATE_TRUNC('month', NOW()),
      '1 month'::INTERVAL
    ) d
  ),
  order_stats AS (
    SELECT 
      DATE_TRUNC('month', o.created_at) as order_month,
      COALESCE(SUM(CASE WHEN o.status != 'cancelled' THEN o.total ELSE 0 END), 0) as sales,
      COUNT(CASE WHEN o.status != 'cancelled' THEN 1 END) as orders,
      COUNT(CASE WHEN o.status = 'cancelled' THEN 1 END) as cancelled
    FROM public.orders o
    WHERE o.created_at >= DATE_TRUNC('month', NOW()) - ((p_months - 1) || ' months')::INTERVAL
    GROUP BY DATE_TRUNC('month', o.created_at)
  ),
  customer_stats AS (
    SELECT 
      DATE_TRUNC('month', p.created_at) as customer_month,
      COUNT(*) as new_custs
    FROM public.profiles p
    WHERE p.role = 'customer'
      AND p.created_at >= DATE_TRUNC('month', NOW()) - ((p_months - 1) || ' months')::INTERVAL
    GROUP BY DATE_TRUNC('month', p.created_at)
  )
  SELECT 
    m.m_label::TEXT,
    m.m_num,
    m.y_num,
    COALESCE(os.sales, 0)::NUMERIC,
    COALESCE(cs.new_custs, 0)::INTEGER,
    COALESCE(os.orders, 0)::INTEGER,
    COALESCE(os.cancelled, 0)::INTEGER
  FROM months m
  LEFT JOIN order_stats os ON DATE_TRUNC('month', os.order_month) = m.month_start
  LEFT JOIN customer_stats cs ON DATE_TRUNC('month', cs.customer_month) = m.month_start
  ORDER BY m.y_num, m.m_num;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_monthly_stats(INTEGER) TO authenticated;
