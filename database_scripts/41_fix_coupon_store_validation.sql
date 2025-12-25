-- ============================================================
-- إصلاح التحقق من المتجر في دالة validate_coupon
-- Fix store validation in validate_coupon function
-- المشكلة: كان يقارن store_id (من جدول stores) مع merchant_id (من جدول products)
-- الحل: جلب merchant_id من جدول stores ومقارنته مع merchant_id في products
-- ============================================================

DROP FUNCTION IF EXISTS validate_coupon(VARCHAR, UUID, DECIMAL, UUID[], UUID);

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
AS $func$
DECLARE
    v_coupon RECORD;
    v_user_usage_count INTEGER;
    v_discount_amount DECIMAL;
    v_applicable_amount DECIMAL;
    v_coupon_product_ids UUID[];
    v_coupon_category_ids UUID[];
    v_matching_products UUID[];
    v_non_matching_products UUID[];
    v_products_in_categories UUID[];
    v_coupon_merchant_id UUID;
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
    -- جلب merchant_id من جدول stores للمقارنة الصحيحة
    IF v_coupon.store_id IS NOT NULL THEN
        -- جلب merchant_id الخاص بالمتجر صاحب الكوبون
        SELECT merchant_id INTO v_coupon_merchant_id
        FROM stores
        WHERE id = v_coupon.store_id;
        
        -- التحقق من أن كل منتجات السلة تنتمي لنفس التاجر
        IF p_product_ids IS NOT NULL AND array_length(p_product_ids, 1) > 0 THEN
            -- البحث عن منتجات من تجار آخرين
            SELECT ARRAY_AGG(p.id) INTO v_non_matching_products
            FROM products p
            WHERE p.id = ANY(p_product_ids)
            AND (p.merchant_id IS NULL OR p.merchant_id != v_coupon_merchant_id);
            
            -- لو فيه منتجات من تجار آخرين، رفض الكوبون
            IF v_non_matching_products IS NOT NULL AND array_length(v_non_matching_products, 1) > 0 THEN
                RETURN json_build_object(
                    'valid', false,
                    'error_code', 'CART_HAS_OTHER_STORE_PRODUCTS',
                    'error_ar', 'السلة تحتوي على منتجات من متاجر أخرى. هذا الكوبون خاص بمتجر واحد فقط',
                    'error_en', 'Cart contains products from other stores. This coupon is for one store only'
                );
            END IF;
        END IF;
    END IF;
    
    -- التحقق من المنتجات المحددة (إذا كان الكوبون خاص بمنتجات معينة)
    IF v_coupon.scope = 'products' THEN
        -- جلب المنتجات المرتبطة بالكوبون
        SELECT ARRAY_AGG(product_id) INTO v_coupon_product_ids
        FROM coupon_products
        WHERE coupon_id = v_coupon.id;
        
        -- التحقق من وجود منتجات مرتبطة
        IF v_coupon_product_ids IS NULL OR array_length(v_coupon_product_ids, 1) IS NULL THEN
            RETURN json_build_object(
                'valid', false,
                'error_code', 'NO_COUPON_PRODUCTS',
                'error_ar', 'الكوبون غير مرتبط بأي منتجات',
                'error_en', 'Coupon is not linked to any products'
            );
        END IF;
        
        -- التحقق من أن السلة تحتوي فقط على منتجات من الكوبون
        IF p_product_ids IS NOT NULL AND array_length(p_product_ids, 1) > 0 THEN
            -- البحث عن منتجات غير مشمولة في السلة
            v_non_matching_products := NULL;
            SELECT ARRAY_AGG(pid) INTO v_non_matching_products
            FROM unnest(p_product_ids) AS pid
            WHERE NOT (pid = ANY(v_coupon_product_ids));
            
            -- لو فيه منتجات غير مشمولة، رفض الكوبون
            IF v_non_matching_products IS NOT NULL AND array_length(v_non_matching_products, 1) > 0 THEN
                RETURN json_build_object(
                    'valid', false,
                    'error_code', 'CART_HAS_NON_COVERED_PRODUCTS',
                    'error_ar', 'السلة تحتوي على منتجات غير مشمولة بهذا الكوبون. يرجى إزالتها أولاً',
                    'error_en', 'Cart contains products not covered by this coupon. Please remove them first'
                );
            END IF;
        END IF;
    END IF;
    
    -- التحقق من الفئات المحددة (إذا كان الكوبون خاص بفئات معينة)
    IF v_coupon.scope = 'categories' THEN
        -- جلب الفئات المرتبطة بالكوبون
        SELECT ARRAY_AGG(category_id) INTO v_coupon_category_ids
        FROM coupon_categories
        WHERE coupon_id = v_coupon.id;
        
        -- التحقق من وجود فئات مرتبطة
        IF v_coupon_category_ids IS NULL OR array_length(v_coupon_category_ids, 1) IS NULL THEN
            RETURN json_build_object(
                'valid', false,
                'error_code', 'NO_COUPON_CATEGORIES',
                'error_ar', 'الكوبون غير مرتبط بأي فئات',
                'error_en', 'Coupon is not linked to any categories'
            );
        END IF;
        
        -- التحقق من أن كل منتجات السلة تنتمي للفئات المشمولة
        IF p_product_ids IS NOT NULL AND array_length(p_product_ids, 1) > 0 THEN
            -- جلب المنتجات التي تنتمي للفئات المشمولة
            SELECT ARRAY_AGG(DISTINCT p.id) INTO v_products_in_categories
            FROM products p
            WHERE p.id = ANY(p_product_ids)
            AND p.category_id = ANY(v_coupon_category_ids);
            
            -- البحث عن منتجات غير مشمولة (ليست في الفئات)
            v_non_matching_products := NULL;
            SELECT ARRAY_AGG(pid) INTO v_non_matching_products
            FROM unnest(p_product_ids) AS pid
            WHERE NOT (pid = ANY(COALESCE(v_products_in_categories, ARRAY[]::UUID[])));
            
            -- لو فيه منتجات غير مشمولة، رفض الكوبون
            IF v_non_matching_products IS NOT NULL AND array_length(v_non_matching_products, 1) > 0 THEN
                RETURN json_build_object(
                    'valid', false,
                    'error_code', 'CART_HAS_NON_COVERED_CATEGORIES',
                    'error_ar', 'السلة تحتوي على منتجات من فئات غير مشمولة بهذا الكوبون. يرجى إزالتها أولاً',
                    'error_en', 'Cart contains products from categories not covered by this coupon. Please remove them first'
                );
            END IF;
        END IF;
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
        'final_amount', p_order_amount - v_discount_amount,
        'scope', v_coupon.scope
    );
END;
$func$;

-- منح الصلاحيات
GRANT EXECUTE ON FUNCTION validate_coupon TO authenticated;
