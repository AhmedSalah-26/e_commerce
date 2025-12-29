-- =====================================================
-- FIX FUNCTION SEARCH PATH SECURITY WARNINGS
-- Add SET search_path = '' to all functions
-- =====================================================

-- NOTE: is_merchant() and is_admin() cannot be dropped because RLS policies depend on them
-- They will be updated in-place with CREATE OR REPLACE

-- DROP functions that can be safely dropped (no RLS dependencies)
DROP FUNCTION IF EXISTS public.is_user_banned(UUID);
DROP FUNCTION IF EXISTS public.cleanup_expired_flash_sales();
DROP FUNCTION IF EXISTS public.get_discounted_products_sorted(INTEGER, INTEGER);
DROP FUNCTION IF EXISTS public.get_available_coupons(UUID, DECIMAL, UUID);
DROP FUNCTION IF EXISTS public.get_parent_order_details(UUID);
DROP FUNCTION IF EXISTS public.create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, UUID, TEXT, UUID, TEXT, NUMERIC);
DROP FUNCTION IF EXISTS public.create_order_from_cart(UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION IF EXISTS public.create_order_from_cart(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, UUID);
DROP FUNCTION IF EXISTS public.refund_coupon_usage(UUID);
DROP FUNCTION IF EXISTS public.get_product_reviews(UUID);

-- 1. is_merchant
CREATE OR REPLACE FUNCTION public.is_merchant()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = (SELECT auth.uid()) AND role = 'merchant'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = '';

-- 2. is_admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = (SELECT auth.uid()) 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = '';

-- 3. is_user_banned
CREATE OR REPLACE FUNCTION public.is_user_banned(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE id = p_user_id AND is_banned = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = '';

-- 4. update_updated_at_column
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = '';

-- 5. update_stores_updated_at
CREATE OR REPLACE FUNCTION public.update_stores_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = '';

-- 6. update_product_rating
CREATE OR REPLACE FUNCTION public.update_product_rating()
RETURNS TRIGGER AS $$
DECLARE
  avg_rating DECIMAL(3,2);
BEGIN
  IF TG_OP = 'DELETE' THEN
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM public.reviews
    WHERE product_id = OLD.product_id;
    
    UPDATE public.products SET rating = avg_rating WHERE id = OLD.product_id;
  ELSE
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM public.reviews
    WHERE product_id = NEW.product_id;
    
    UPDATE public.products SET rating = avg_rating WHERE id = NEW.product_id;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 7. get_product_reviews
CREATE OR REPLACE FUNCTION public.get_product_reviews(p_product_id UUID)
RETURNS TABLE (
  id UUID,
  product_id UUID,
  user_id UUID,
  user_name TEXT,
  rating INTEGER,
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.product_id,
    r.user_id,
    COALESCE(p.name, 'مستخدم') as user_name,
    r.rating,
    r.comment,
    r.created_at
  FROM public.reviews r
  LEFT JOIN public.profiles p ON r.user_id = p.id
  WHERE r.product_id = p_product_id
  ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 8. get_cart_total
CREATE OR REPLACE FUNCTION public.get_cart_total(p_user_id UUID)
RETURNS DECIMAL AS $$
DECLARE
  v_total DECIMAL;
BEGIN
  SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0)
  INTO v_total
  FROM public.cart_items ci
  JOIN public.products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  RETURN v_total;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 9. clear_user_cart
CREATE OR REPLACE FUNCTION public.clear_user_cart(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  DELETE FROM public.cart_items WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 10. get_product_count_by_category
CREATE OR REPLACE FUNCTION public.get_product_count_by_category(p_category_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM public.products
  WHERE category_id = p_category_id AND is_active = true;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 11. can_delete_category
CREATE OR REPLACE FUNCTION public.can_delete_category(p_category_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM public.products 
    WHERE category_id = p_category_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 12. decrease_product_stock
CREATE OR REPLACE FUNCTION public.decrease_product_stock(p_product_id UUID, p_quantity INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
  v_current_stock INTEGER;
BEGIN
  SELECT stock INTO v_current_stock
  FROM public.products
  WHERE id = p_product_id;
  
  IF v_current_stock >= p_quantity THEN
    UPDATE public.products
    SET stock = stock - p_quantity
    WHERE id = p_product_id;
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 13. restore_stock_on_cancel
CREATE OR REPLACE FUNCTION public.restore_stock_on_cancel(p_order_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE public.products p
  SET stock = p.stock + oi.quantity
  FROM public.order_items oi
  WHERE oi.order_id = p_order_id
  AND oi.product_id = p.id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 14. get_shipping_price
CREATE OR REPLACE FUNCTION public.get_shipping_price(
  p_merchant_id UUID,
  p_governorate_id UUID
)
RETURNS DECIMAL AS $$
DECLARE
  v_price DECIMAL;
BEGIN
  SELECT price INTO v_price
  FROM public.merchant_shipping_prices
  WHERE merchant_id = p_merchant_id
    AND governorate_id = p_governorate_id
    AND is_active = true;
  
  RETURN COALESCE(v_price, 0);
END;
$$ LANGUAGE plpgsql SET search_path = '';

-- 15. is_flash_sale_active
CREATE OR REPLACE FUNCTION public.is_flash_sale_active(p_product_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_result BOOLEAN;
BEGIN
  SELECT 
    CASE 
      WHEN flash_sale_end IS NOT NULL AND flash_sale_end > NOW() THEN true
      ELSE false
    END INTO v_result
  FROM public.products
  WHERE id = p_product_id;
  
  RETURN COALESCE(v_result, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 16. cleanup_expired_flash_sales
CREATE OR REPLACE FUNCTION public.cleanup_expired_flash_sales()
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  WITH updated AS (
    UPDATE public.products
    SET 
      discount_price = NULL,
      flash_sale_end = NULL
    WHERE flash_sale_end IS NOT NULL 
      AND flash_sale_end <= NOW()
    RETURNING id
  )
  SELECT COUNT(*) INTO v_count FROM updated;
  
  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 17. trigger_cleanup_flash_sales (trigger function)
CREATE OR REPLACE FUNCTION public.trigger_cleanup_flash_sales()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM public.cleanup_expired_flash_sales();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';


-- 18. get_discounted_products_sorted
CREATE OR REPLACE FUNCTION public.get_discounted_products_sorted(
  p_limit INTEGER DEFAULT 20,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  name_ar TEXT,
  name_en TEXT,
  description_ar TEXT,
  description_en TEXT,
  price DECIMAL,
  discount_price DECIMAL,
  discount_percentage INTEGER,
  images TEXT[],
  category_id UUID,
  merchant_id UUID,
  stock INTEGER,
  rating DECIMAL,
  is_active BOOLEAN,
  flash_sale_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ
) AS $$
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
    CASE 
      WHEN p.price > 0 AND p.discount_price IS NOT NULL 
      THEN ROUND(((p.price - p.discount_price) / p.price * 100))::INTEGER
      ELSE 0
    END as discount_percentage,
    p.images,
    p.category_id,
    p.merchant_id,
    p.stock,
    p.rating,
    p.is_active,
    p.flash_sale_end,
    p.created_at
  FROM public.products p
  WHERE p.is_active = true
    AND p.discount_price IS NOT NULL
    AND p.discount_price < p.price
  ORDER BY 
    CASE WHEN p.flash_sale_end IS NOT NULL AND p.flash_sale_end > NOW() THEN 0 ELSE 1 END,
    ((p.price - p.discount_price) / p.price) DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 19. validate_order_shipping
CREATE OR REPLACE FUNCTION public.validate_order_shipping(
  p_user_id UUID,
  p_governorate_id UUID
)
RETURNS JSON AS $$
DECLARE
  v_merchant_id UUID;
  v_shipping_price DECIMAL;
  v_missing_merchants UUID[];
  v_result JSON;
BEGIN
  -- Get all merchants in cart
  FOR v_merchant_id IN 
    SELECT DISTINCT p.merchant_id
    FROM public.cart_items ci
    JOIN public.products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND p.merchant_id IS NOT NULL
  LOOP
    -- Check if merchant has shipping price for this governorate
    SELECT price INTO v_shipping_price
    FROM public.merchant_shipping_prices
    WHERE merchant_id = v_merchant_id
      AND governorate_id = p_governorate_id
      AND is_active = true;
    
    IF v_shipping_price IS NULL THEN
      v_missing_merchants := array_append(v_missing_merchants, v_merchant_id);
    END IF;
  END LOOP;
  
  IF array_length(v_missing_merchants, 1) > 0 THEN
    RETURN json_build_object(
      'valid', false,
      'missing_merchants', v_missing_merchants
    );
  ELSE
    RETURN json_build_object('valid', true);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 20. validate_coupon
CREATE OR REPLACE FUNCTION public.validate_coupon(
  p_coupon_code VARCHAR,
  p_user_id UUID,
  p_order_amount DECIMAL,
  p_product_ids UUID[] DEFAULT NULL,
  p_store_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_coupon RECORD;
  v_user_usage_count INTEGER;
  v_discount_amount DECIMAL;
  v_applicable_amount DECIMAL;
BEGIN
  SELECT * INTO v_coupon
  FROM public.coupons
  WHERE code = UPPER(p_coupon_code)
  AND is_active = true;
  
  IF v_coupon IS NULL THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'INVALID_CODE',
      'error_ar', 'كود الخصم غير صحيح',
      'error_en', 'Invalid coupon code'
    );
  END IF;
  
  IF v_coupon.start_date > NOW() THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'NOT_STARTED',
      'error_ar', 'كود الخصم لم يبدأ بعد',
      'error_en', 'Coupon has not started yet'
    );
  END IF;
  
  IF v_coupon.end_date IS NOT NULL AND v_coupon.end_date < NOW() THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'EXPIRED',
      'error_ar', 'كود الخصم منتهي الصلاحية',
      'error_en', 'Coupon has expired'
    );
  END IF;
  
  IF v_coupon.usage_limit IS NOT NULL AND v_coupon.usage_count >= v_coupon.usage_limit THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'USAGE_LIMIT_REACHED',
      'error_ar', 'تم استنفاد عدد مرات استخدام الكوبون',
      'error_en', 'Coupon usage limit reached'
    );
  END IF;
  
  SELECT COUNT(*) INTO v_user_usage_count
  FROM public.coupon_usages
  WHERE coupon_id = v_coupon.id AND user_id = p_user_id;
  
  IF v_user_usage_count >= v_coupon.usage_limit_per_user THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'USER_LIMIT_REACHED',
      'error_ar', 'لقد استخدمت هذا الكوبون من قبل',
      'error_en', 'You have already used this coupon'
    );
  END IF;
  
  IF p_order_amount < v_coupon.min_order_amount THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'MIN_ORDER_NOT_MET',
      'error_ar', 'الحد الأدنى للطلب ' || v_coupon.min_order_amount || ' ر.س',
      'error_en', 'Minimum order amount is ' || v_coupon.min_order_amount || ' SAR'
    );
  END IF;
  
  IF v_coupon.store_id IS NOT NULL AND v_coupon.store_id != p_store_id THEN
    RETURN json_build_object(
      'valid', false,
      'error_code', 'MERCHANT_MISMATCH',
      'error_ar', 'هذا الكوبون خاص بمتجر آخر',
      'error_en', 'This coupon is for another store'
    );
  END IF;
  
  v_applicable_amount := p_order_amount;
  
  IF v_coupon.discount_type = 'percentage' THEN
    v_discount_amount := v_applicable_amount * (v_coupon.discount_value / 100);
    IF v_coupon.max_discount_amount IS NOT NULL AND v_discount_amount > v_coupon.max_discount_amount THEN
      v_discount_amount := v_coupon.max_discount_amount;
    END IF;
  ELSE
    v_discount_amount := LEAST(v_coupon.discount_value, v_applicable_amount);
  END IF;
  
  v_discount_amount := ROUND(v_discount_amount, 2);
  
  RETURN json_build_object(
    'valid', true,
    'coupon_id', v_coupon.id,
    'code', v_coupon.code,
    'name_ar', v_coupon.name_ar,
    'name_en', v_coupon.name_en,
    'discount_type', v_coupon.discount_type,
    'discount_value', v_coupon.discount_value,
    'discount_amount', v_discount_amount,
    'final_amount', p_order_amount - v_discount_amount
  );
END;
$$;

-- 21. apply_coupon_to_order
CREATE OR REPLACE FUNCTION public.apply_coupon_to_order(
  p_coupon_id UUID,
  p_user_id UUID,
  p_order_id UUID,
  p_discount_amount DECIMAL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.coupon_usages (coupon_id, user_id, order_id, discount_amount)
  VALUES (p_coupon_id, p_user_id, p_order_id, p_discount_amount);
  
  UPDATE public.coupons
  SET usage_count = usage_count + 1,
      updated_at = NOW()
  WHERE id = p_coupon_id;
  
  RETURN true;
EXCEPTION
  WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- 22. get_available_coupons
CREATE OR REPLACE FUNCTION public.get_available_coupons(
  p_user_id UUID,
  p_order_amount DECIMAL DEFAULT 0,
  p_store_id UUID DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  code VARCHAR,
  name_ar VARCHAR,
  name_en VARCHAR,
  description_ar TEXT,
  description_en TEXT,
  discount_type VARCHAR,
  discount_value DECIMAL,
  max_discount_amount DECIMAL,
  min_order_amount DECIMAL,
  end_date TIMESTAMPTZ,
  is_applicable BOOLEAN,
  reason_ar TEXT,
  reason_en TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.id,
    c.code,
    c.name_ar,
    c.name_en,
    c.description_ar,
    c.description_en,
    c.discount_type,
    c.discount_value,
    c.max_discount_amount,
    c.min_order_amount,
    c.end_date,
    CASE 
      WHEN c.min_order_amount > p_order_amount THEN false
      WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN false
      WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN false
      WHEN (SELECT COUNT(*) FROM public.coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN false
      ELSE true
    END AS is_applicable,
    CASE 
      WHEN c.min_order_amount > p_order_amount THEN 'الحد الأدنى للطلب ' || c.min_order_amount || ' ر.س'
      WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'خاص بمتجر آخر'
      WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'تم استنفاد الكوبون'
      WHEN (SELECT COUNT(*) FROM public.coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'تم استخدامه مسبقاً'
      ELSE NULL
    END AS reason_ar,
    CASE 
      WHEN c.min_order_amount > p_order_amount THEN 'Minimum order ' || c.min_order_amount || ' SAR'
      WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'For another store'
      WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'Coupon exhausted'
      WHEN (SELECT COUNT(*) FROM public.coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'Already used'
      ELSE NULL
    END AS reason_en
  FROM public.coupons c
  WHERE c.is_active = true
  AND c.start_date <= NOW()
  AND (c.end_date IS NULL OR c.end_date > NOW())
  AND (c.store_id IS NULL OR c.store_id = p_store_id)
  ORDER BY is_applicable DESC, c.discount_value DESC;
END;
$$;

-- 23. refund_coupon_usage
CREATE OR REPLACE FUNCTION public.refund_coupon_usage(p_order_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_coupon_id UUID;
BEGIN
  SELECT coupon_id INTO v_coupon_id
  FROM public.coupon_usages
  WHERE order_id = p_order_id;
  
  IF v_coupon_id IS NOT NULL THEN
    DELETE FROM public.coupon_usages WHERE order_id = p_order_id;
    
    UPDATE public.coupons
    SET usage_count = GREATEST(usage_count - 1, 0)
    WHERE id = v_coupon_id;
  END IF;
END;
$$;

-- 24. trigger_refund_coupon_on_cancel
CREATE OR REPLACE FUNCTION public.trigger_refund_coupon_on_cancel()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    PERFORM public.refund_coupon_usage(NEW.id);
  END IF;
  RETURN NEW;
END;
$$;

-- 25. get_parent_order_details
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


-- 26. create_multi_vendor_order (MAIN ORDER FUNCTION)
CREATE OR REPLACE FUNCTION public.create_multi_vendor_order(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL,
  p_shipping_cost NUMERIC DEFAULT 0,
  p_governorate_id UUID DEFAULT NULL,
  p_payment_method TEXT DEFAULT 'cash',
  p_coupon_id UUID DEFAULT NULL,
  p_coupon_code TEXT DEFAULT NULL,
  p_coupon_discount NUMERIC DEFAULT 0
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_parent_order_id UUID;
  v_order_id UUID;
  v_merchant_subtotal NUMERIC;
  v_merchant_shipping NUMERIC;
  v_total_subtotal NUMERIC := 0;
  v_total_shipping NUMERIC := 0;
  merchant_rec RECORD;
BEGIN
  -- Check if cart is empty
  IF NOT EXISTS (SELECT 1 FROM public.cart_items WHERE user_id = p_user_id) THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  -- Calculate total subtotal first
  SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_total_subtotal
  FROM public.cart_items ci
  JOIN public.products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  -- Calculate total shipping by summing each merchant's shipping price
  SELECT COALESCE(SUM(
    COALESCE(
      (SELECT price FROM public.merchant_shipping_prices 
       WHERE merchant_id = sub.merchant_id 
       AND governorate_id = p_governorate_id 
       AND is_active = true),
      p_shipping_cost
    )
  ), 0) INTO v_total_shipping
  FROM (
    SELECT DISTINCT p.merchant_id
    FROM public.cart_items ci
    JOIN public.products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
  ) sub;
  
  -- Create parent order with total shipping for all merchants
  INSERT INTO public.parent_orders (
    user_id, total, subtotal, shipping_cost,
    delivery_address, customer_name, customer_phone, notes, governorate_id,
    payment_method, coupon_id, coupon_code, coupon_discount
  )
  VALUES (
    p_user_id,
    v_total_subtotal + v_total_shipping - COALESCE(p_coupon_discount, 0),
    v_total_subtotal,
    v_total_shipping,
    p_delivery_address, p_customer_name, p_customer_phone, p_notes, p_governorate_id,
    p_payment_method, p_coupon_id, p_coupon_code, p_coupon_discount
  )
  RETURNING id INTO v_parent_order_id;
  
  -- Apply coupon if provided
  IF p_coupon_id IS NOT NULL THEN
    PERFORM public.apply_coupon_to_order(p_coupon_id, p_user_id, v_parent_order_id, p_coupon_discount);
  END IF;
  
  -- Create orders for each merchant
  FOR merchant_rec IN 
    SELECT DISTINCT p.merchant_id
    FROM public.cart_items ci
    JOIN public.products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
  LOOP
    -- Calculate subtotal for this merchant
    SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0) INTO v_merchant_subtotal
    FROM public.cart_items ci
    JOIN public.products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND (p.merchant_id = merchant_rec.merchant_id OR (p.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
    
    -- Get shipping price for this merchant
    SELECT COALESCE(
      (SELECT price FROM public.merchant_shipping_prices 
       WHERE merchant_id = merchant_rec.merchant_id 
       AND governorate_id = p_governorate_id 
       AND is_active = true),
      p_shipping_cost
    ) INTO v_merchant_shipping;
    
    -- Create order for this merchant
    INSERT INTO public.orders (
      user_id, merchant_id, parent_order_id,
      total, subtotal, shipping_cost,
      delivery_address, customer_name, customer_phone, notes,
      governorate_id, status, payment_method
    )
    VALUES (
      p_user_id,
      merchant_rec.merchant_id,
      v_parent_order_id,
      v_merchant_subtotal + v_merchant_shipping,
      v_merchant_subtotal,
      v_merchant_shipping,
      p_delivery_address, p_customer_name, p_customer_phone, p_notes,
      p_governorate_id, 'pending', p_payment_method
    )
    RETURNING id INTO v_order_id;
    
    -- Create order items for this merchant
    INSERT INTO public.order_items (order_id, product_id, product_name, product_name_en, product_image, quantity, price)
    SELECT 
      v_order_id,
      ci.product_id,
      COALESCE(p.name_ar, p.name_en, 'منتج'),
      COALESCE(p.name_en, p.name_ar, 'Product'),
      p.images[1],
      ci.quantity,
      COALESCE(p.discount_price, p.price)
    FROM public.cart_items ci
    JOIN public.products p ON p.id = ci.product_id
    WHERE ci.user_id = p_user_id
    AND (p.merchant_id = merchant_rec.merchant_id OR (p.merchant_id IS NULL AND merchant_rec.merchant_id IS NULL));
  END LOOP;
  
  -- Clear cart
  DELETE FROM public.cart_items WHERE user_id = p_user_id;
  
  RETURN v_parent_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_multi_vendor_order(UUID, TEXT, TEXT, TEXT, TEXT, NUMERIC, UUID, TEXT, UUID, TEXT, NUMERIC) TO authenticated;

-- 27. create_order_from_cart (legacy function if exists)
CREATE OR REPLACE FUNCTION public.create_order_from_cart(
  p_user_id UUID,
  p_delivery_address TEXT DEFAULT NULL,
  p_customer_name TEXT DEFAULT NULL,
  p_customer_phone TEXT DEFAULT NULL,
  p_notes TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_order_id UUID;
  v_total DECIMAL;
BEGIN
  -- Calculate total
  SELECT COALESCE(SUM(ci.quantity * COALESCE(p.discount_price, p.price)), 0)
  INTO v_total
  FROM public.cart_items ci
  JOIN public.products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  IF v_total = 0 THEN
    RAISE EXCEPTION 'Cart is empty';
  END IF;
  
  -- Create order
  INSERT INTO public.orders (user_id, total, delivery_address, customer_name, customer_phone, notes, status)
  VALUES (p_user_id, v_total, p_delivery_address, p_customer_name, p_customer_phone, p_notes, 'pending')
  RETURNING id INTO v_order_id;
  
  -- Create order items
  INSERT INTO public.order_items (order_id, product_id, product_name, product_image, quantity, price)
  SELECT 
    v_order_id,
    ci.product_id,
    COALESCE(p.name_ar, p.name_en, 'منتج'),
    p.images[1],
    ci.quantity,
    COALESCE(p.discount_price, p.price)
  FROM public.cart_items ci
  JOIN public.products p ON p.id = ci.product_id
  WHERE ci.user_id = p_user_id;
  
  -- Clear cart
  DELETE FROM public.cart_items WHERE user_id = p_user_id;
  
  RETURN v_order_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_order_from_cart TO authenticated;

-- =====================================================
-- ALSO FIX: Leaked Password Protection
-- Go to Supabase Dashboard > Authentication > Settings
-- Enable "Leaked Password Protection"
-- =====================================================

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================
GRANT EXECUTE ON FUNCTION public.is_merchant() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_user_banned(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_product_reviews(UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.get_cart_total(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.clear_user_cart(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_product_count_by_category(UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.can_delete_category(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.decrease_product_stock(UUID, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.restore_stock_on_cancel(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_shipping_price(UUID, UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.is_flash_sale_active(UUID) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.cleanup_expired_flash_sales() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_discounted_products_sorted(INTEGER, INTEGER) TO authenticated, anon;
GRANT EXECUTE ON FUNCTION public.validate_order_shipping(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.validate_coupon(VARCHAR, UUID, DECIMAL, UUID[], UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.apply_coupon_to_order(UUID, UUID, UUID, DECIMAL) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_available_coupons(UUID, DECIMAL, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.refund_coupon_usage(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_parent_order_details(UUID) TO authenticated;
