-- =====================================================
-- Fix payment_method to use 'card' instead of 'pending'
-- =====================================================

DROP FUNCTION IF EXISTS public.create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, UUID, TEXT, UUID, TEXT, NUMERIC);

CREATE OR REPLACE FUNCTION public.create_multi_vendor_order(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_shipping_cost NUMERIC DEFAULT 0,
  p_governorate_id UUID DEFAULT NULL,
  p_payment_method TEXT DEFAULT 'cash_on_delivery',
  p_coupon_id UUID DEFAULT NULL,
  p_coupon_code TEXT DEFAULT NULL,
  p_coupon_discount NUMERIC DEFAULT 0
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_parent_order_id UUID;
  v_order_id UUID;
  v_merchant_subtotal NUMERIC;
  v_merchant_shipping NUMERIC;
  v_total_subtotal NUMERIC := 0;
  v_total_shipping NUMERIC := 0;
  v_payment_status TEXT;
  merchant_rec RECORD;
BEGIN
  -- Determine payment_status based on payment_method
  -- 'card' = online card payment (pending until webhook confirms)
  -- 'cash_on_delivery' = pay on delivery
  IF p_payment_method = 'card' THEN
    v_payment_status := 'pending';
  ELSE
    v_payment_status := 'cash_on_delivery';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.cart_items WHERE user_id = p_user_id) THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_total_subtotal
  FROM public.cart_items ci
  JOIN public.products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  SELECT COALESCE(SUM(
    COALESCE(
      (SELECT msp.price FROM public.merchant_shipping_prices msp
       WHERE msp.merchant_id = sub.merchant_id 
       AND msp.governorate_id = p_governorate_id 
       AND msp.is_active = true),
      p_shipping_cost
    )
  ), 0) INTO v_total_shipping
  FROM (
    SELECT DISTINCT pr.merchant_id
    FROM public.cart_items ci2
    JOIN public.products pr ON pr.id = ci2.product_id
    WHERE ci2.user_id = p_user_id
  ) sub;
  
  INSERT INTO public.parent_orders (
    user_id, total, subtotal, shipping_cost,
    delivery_address, customer_name, customer_phone, notes, governorate_id,
    payment_method, payment_status, coupon_id, coupon_code, coupon_discount
  )
  VALUES (
    p_user_id,
    v_total_subtotal + v_total_shipping - COALESCE(p_coupon_discount, 0),
    v_total_subtotal,
    v_total_shipping,
    p_delivery_address, p_customer_name, p_customer_phone, p_notes, p_governorate_id,
    p_payment_method, v_payment_status, p_coupon_id, p_coupon_code, p_coupon_discount
  )
  RETURNING id INTO v_parent_order_id;
  
  IF p_coupon_id IS NOT NULL THEN
    PERFORM public.apply_coupon_to_order(p_coupon_id, p_user_id, v_parent_order_id, p_coupon_discount);
  END IF;
  
  FOR merchant_rec IN 
    SELECT DISTINCT pr.merchant_id
    FROM public.cart_items ci
    JOIN public.products pr ON pr.id = ci.product_id
    WHERE ci.user_id = p_user_id
  LOOP
    SELECT COALESCE(SUM(ci.quantity * COALESCE(pr.discount_price, pr.price)), 0) INTO v_merchant_subtotal
    FROM public.cart_items ci
    JOIN public.products pr ON pr.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND (pr.merchant_id = merchant_rec.merchant_id OR (pr.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
    
    SELECT COALESCE(
      (SELECT msp.price FROM public.merchant_shipping_prices msp
       WHERE msp.merchant_id = merchant_rec.merchant_id 
       AND msp.governorate_id = p_governorate_id 
       AND msp.is_active = true),
      p_shipping_cost
    ) INTO v_merchant_shipping;
    
    INSERT INTO public.orders (
      user_id, merchant_id, parent_order_id,
      total, subtotal, shipping_cost,
      delivery_address, customer_name, customer_phone, notes,
      governorate_id, status, payment_method, payment_status
    )
    VALUES (
      p_user_id,
      merchant_rec.merchant_id,
      v_parent_order_id,
      v_merchant_subtotal + v_merchant_shipping,
      v_merchant_subtotal,
      v_merchant_shipping,
      p_delivery_address, p_customer_name, p_customer_phone, p_notes,
      p_governorate_id, 'pending', p_payment_method, v_payment_status
    )
    RETURNING id INTO v_order_id;
    
    INSERT INTO public.order_items (order_id, product_id, product_name, product_name_en, product_image, quantity, price)
    SELECT 
      v_order_id,
      ci.product_id,
      COALESCE(pr.name_ar, pr.name_en, 'منتج'),
      COALESCE(pr.name_en, pr.name_ar, 'Product'),
      pr.images[1],
      ci.quantity,
      COALESCE(pr.discount_price, pr.price)
    FROM public.cart_items ci
    JOIN public.products pr ON pr.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND (pr.merchant_id = merchant_rec.merchant_id OR (pr.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
  END LOOP;
  
  DELETE FROM public.cart_items WHERE user_id = p_user_id;
  
  RETURN v_parent_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, UUID, TEXT, UUID, TEXT, NUMERIC) TO authenticated;
