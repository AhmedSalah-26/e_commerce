-- Fix get_parent_order_details to include payment fields
-- Run this in Supabase SQL Editor

DROP FUNCTION IF EXISTS public.get_parent_order_details(UUID);

CREATE OR REPLACE FUNCTION public.get_parent_order_details(p_parent_order_id UUID)
RETURNS TABLE (
  parent_order_id UUID,
  parent_total DECIMAL,
  parent_subtotal DECIMAL,
  parent_shipping_cost DECIMAL,
  delivery_address TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  notes TEXT,
  parent_created_at TIMESTAMPTZ,
  payment_method TEXT,
  payment_status TEXT,
  coupon_id UUID,
  coupon_code TEXT,
  coupon_discount DECIMAL,
  order_id UUID,
  merchant_id UUID,
  merchant_name TEXT,
  merchant_phone TEXT,
  order_total DECIMAL,
  order_subtotal DECIMAL,
  order_shipping_cost DECIMAL,
  order_status TEXT,
  order_created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    po.id as parent_order_id,
    po.total as parent_total,
    po.subtotal as parent_subtotal,
    po.shipping_cost as parent_shipping_cost,
    po.delivery_address,
    po.customer_name,
    po.customer_phone,
    po.notes,
    po.created_at as parent_created_at,
    po.payment_method,
    po.payment_status,
    po.coupon_id,
    po.coupon_code,
    po.coupon_discount,
    o.id as order_id,
    o.merchant_id,
    COALESCE(s.name, pr.name) as merchant_name,
    COALESCE(s.phone, pr.phone) as merchant_phone,
    o.total as order_total,
    o.subtotal as order_subtotal,
    o.shipping_cost as order_shipping_cost,
    o.status as order_status,
    o.created_at as order_created_at
  FROM public.parent_orders po
  LEFT JOIN public.orders o ON o.parent_order_id = po.id
  LEFT JOIN public.stores s ON s.merchant_id = o.merchant_id
  LEFT JOIN public.profiles pr ON pr.id = o.merchant_id
  WHERE po.id = p_parent_order_id
  ORDER BY o.created_at;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_parent_order_details(UUID) TO authenticated;
