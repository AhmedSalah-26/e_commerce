-- ============================================================
-- Fix currency in coupon validation messages (SAR -> EGP)
-- ============================================================

-- Update validate_coupon function with correct currency
CREATE OR REPLACE FUNCTION validate_coupon(
    p_coupon_code VARCHAR,
    p_user_id UUID,
    p_order_amount DECIMAL,
    p_product_ids UUID[] DEFAULT NULL,
    p_store_id UUID DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_coupon RECORD;
    v_user_usage_count INTEGER;
    v_discount_amount DECIMAL;
    v_applicable_amount DECIMAL;
BEGIN
    -- البحث عن الكوبون
    SELECT * INTO v_coupon
    FROM coupons
    WHERE code = UPPER(p_coupon_code)
    AND is_active = true;
    
    -- التحقق من وجود الكوبون
    IF v_coupon IS NULL THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'INVALID_CODE',
            'error_ar', 'كود الخصم غير صحيح',
            'error_en', 'Invalid coupon code'
        );
    END IF;
    
    -- التحقق من تاريخ البداية
    IF v_coupon.start_date > NOW() THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'NOT_STARTED',
            'error_ar', 'كود الخصم لم يبدأ بعد',
            'error_en', 'Coupon has not started yet'
        );
    END IF;
    
    -- التحقق من تاريخ الانتهاء
    IF v_coupon.end_date IS NOT NULL AND v_coupon.end_date < NOW() THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'EXPIRED',
            'error_ar', 'كود الخصم منتهي الصلاحية',
            'error_en', 'Coupon has expired'
        );
    END IF;
    
    -- التحقق من الحد الأقصى للاستخدام الكلي
    IF v_coupon.usage_limit IS NOT NULL AND v_coupon.usage_count >= v_coupon.usage_limit THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'USAGE_LIMIT_REACHED',
            'error_ar', 'تم استنفاد عدد مرات استخدام الكوبون',
            'error_en', 'Coupon usage limit reached'
        );
    END IF;
    
    -- التحقق من استخدام المستخدم
    SELECT COUNT(*) INTO v_user_usage_count
    FROM coupon_usages
    WHERE coupon_id = v_coupon.id AND user_id = p_user_id;
    
    IF v_user_usage_count >= v_coupon.usage_limit_per_user THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'USER_LIMIT_REACHED',
            'error_ar', 'لقد استخدمت هذا الكوبون من قبل',
            'error_en', 'You have already used this coupon'
        );
    END IF;
    
    -- التحقق من الحد الأدنى للطلب
    IF p_order_amount < v_coupon.min_order_amount THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'MIN_ORDER_NOT_MET',
            'error_ar', 'الحد الأدنى للطلب ' || v_coupon.min_order_amount || ' ج.م',
            'error_en', 'Minimum order amount is ' || v_coupon.min_order_amount || ' EGP'
        );
    END IF;
    
    -- التحقق من المتجر (إذا كان الكوبون خاص بمتجر)
    IF v_coupon.store_id IS NOT NULL AND v_coupon.store_id != p_store_id THEN
        RETURN json_build_object(
            'valid', false,
            'error_code', 'MERCHANT_MISMATCH',
            'error_ar', 'هذا الكوبون خاص بمتجر آخر',
            'error_en', 'This coupon is for another store'
        );
    END IF;
    
    -- حساب قيمة الخصم
    v_applicable_amount := p_order_amount;
    
    IF v_coupon.discount_type = 'percentage' THEN
        v_discount_amount := v_applicable_amount * (v_coupon.discount_value / 100);
        -- تطبيق الحد الأقصى للخصم
        IF v_coupon.max_discount_amount IS NOT NULL AND v_discount_amount > v_coupon.max_discount_amount THEN
            v_discount_amount := v_coupon.max_discount_amount;
        END IF;
    ELSE
        v_discount_amount := LEAST(v_coupon.discount_value, v_applicable_amount);
    END IF;
    
    -- تقريب قيمة الخصم
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

-- Update get_available_coupons function with correct currency
CREATE OR REPLACE FUNCTION get_available_coupons(
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
        -- التحقق من إمكانية التطبيق
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN false
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN false
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN false
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN false
            ELSE true
        END AS is_applicable,
        -- سبب عدم التطبيق بالعربي
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'الحد الأدنى للطلب ' || c.min_order_amount || ' ج.م'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'خاص بمتجر آخر'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'تم استنفاد الكوبون'
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'تم استخدامه مسبقاً'
            ELSE NULL
        END AS reason_ar,
        -- سبب عدم التطبيق بالإنجليزي
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'Minimum order ' || c.min_order_amount || ' EGP'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'For another store'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'Coupon exhausted'
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'Already used'
            ELSE NULL
        END AS reason_en
    FROM coupons c
    WHERE c.is_active = true
    AND c.start_date <= NOW()
    AND (c.end_date IS NULL OR c.end_date > NOW())
    AND (c.store_id IS NULL OR c.store_id = p_store_id)
    ORDER BY is_applicable DESC, c.discount_value DESC;
END;
$$;

-- Update sample coupons descriptions
UPDATE coupons SET 
    description_ar = 'خصم 20 جنيه على طلبك',
    description_en = '20 EGP off your order',
    name_ar = 'وفر 20 جنيه',
    name_en = 'Save 20 EGP'
WHERE code = 'SAVE20';
