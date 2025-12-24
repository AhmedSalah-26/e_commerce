-- ============================================================
-- نظام الكوبونات والخصومات
-- Coupons and Discounts System
-- ============================================================

-- ============================================================
-- 1. جدول الكوبونات الرئيسي
-- ============================================================
CREATE TABLE IF NOT EXISTS coupons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    description_ar TEXT,
    description_en TEXT,
    
    -- نوع الخصم: percentage (نسبة مئوية) أو fixed (مبلغ ثابت)
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value > 0),
    
    -- الحد الأقصى للخصم (للنسبة المئوية)
    max_discount_amount DECIMAL(10, 2),
    
    -- الحد الأدنى لقيمة الطلب
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    
    -- عدد مرات الاستخدام
    usage_limit INTEGER, -- NULL = غير محدود
    usage_count INTEGER DEFAULT 0,
    usage_limit_per_user INTEGER DEFAULT 1,
    
    -- فترة الصلاحية
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    
    -- نطاق التطبيق
    scope VARCHAR(20) DEFAULT 'all' CHECK (scope IN ('all', 'categories', 'products', 'merchants')),
    
    -- حالة الكوبون
    is_active BOOLEAN DEFAULT true,
    
    -- المتجر (NULL = كوبون عام للمنصة)
    store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. جدول ربط الكوبونات بالفئات
-- ============================================================
CREATE TABLE IF NOT EXISTS coupon_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(coupon_id, category_id)
);

-- ============================================================
-- 3. جدول ربط الكوبونات بالمنتجات
-- ============================================================
CREATE TABLE IF NOT EXISTS coupon_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(coupon_id, product_id)
);

-- ============================================================
-- 4. جدول استخدامات الكوبونات
-- ============================================================
CREATE TABLE IF NOT EXISTS coupon_usages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    coupon_id UUID NOT NULL REFERENCES coupons(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    order_id UUID REFERENCES parent_orders(id) ON DELETE SET NULL,
    discount_amount DECIMAL(10, 2) NOT NULL,
    used_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 5. إضافة حقول الكوبون لجدول الطلبات
-- ============================================================
ALTER TABLE parent_orders 
ADD COLUMN IF NOT EXISTS coupon_id UUID REFERENCES coupons(id),
ADD COLUMN IF NOT EXISTS coupon_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS coupon_discount DECIMAL(10, 2) DEFAULT 0;

-- ============================================================
-- 6. الفهارس
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_coupons_code ON coupons(code);
CREATE INDEX IF NOT EXISTS idx_coupons_store ON coupons(store_id);
CREATE INDEX IF NOT EXISTS idx_coupons_active ON coupons(is_active, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_user ON coupon_usages(user_id);
CREATE INDEX IF NOT EXISTS idx_coupon_usages_coupon ON coupon_usages(coupon_id);

-- ============================================================
-- 7. دالة التحقق من صلاحية الكوبون
-- ============================================================
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
            'error_ar', 'الحد الأدنى للطلب ' || v_coupon.min_order_amount || ' ر.س',
            'error_en', 'Minimum order amount is ' || v_coupon.min_order_amount || ' SAR'
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

-- ============================================================
-- 8. دالة تطبيق الكوبون على الطلب
-- ============================================================
CREATE OR REPLACE FUNCTION apply_coupon_to_order(
    p_coupon_id UUID,
    p_user_id UUID,
    p_order_id UUID,
    p_discount_amount DECIMAL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- تسجيل الاستخدام
    INSERT INTO coupon_usages (coupon_id, user_id, order_id, discount_amount)
    VALUES (p_coupon_id, p_user_id, p_order_id, p_discount_amount);
    
    -- تحديث عداد الاستخدام
    UPDATE coupons
    SET usage_count = usage_count + 1,
        updated_at = NOW()
    WHERE id = p_coupon_id;
    
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$;

-- ============================================================
-- 9. دالة الحصول على كوبونات المستخدم المتاحة
-- ============================================================
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
            WHEN c.min_order_amount > p_order_amount THEN 'الحد الأدنى للطلب ' || c.min_order_amount || ' ر.س'
            WHEN c.store_id IS NOT NULL AND c.store_id != p_store_id THEN 'خاص بمتجر آخر'
            WHEN c.usage_limit IS NOT NULL AND c.usage_count >= c.usage_limit THEN 'تم استنفاد الكوبون'
            WHEN (SELECT COUNT(*) FROM coupon_usages cu WHERE cu.coupon_id = c.id AND cu.user_id = p_user_id) >= c.usage_limit_per_user THEN 'تم استخدامه مسبقاً'
            ELSE NULL
        END AS reason_ar,
        -- سبب عدم التطبيق بالإنجليزي
        CASE 
            WHEN c.min_order_amount > p_order_amount THEN 'Minimum order ' || c.min_order_amount || ' SAR'
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

-- ============================================================
-- 10. سياسات RLS
-- ============================================================
ALTER TABLE coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupon_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupon_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE coupon_usages ENABLE ROW LEVEL SECURITY;

-- سياسة قراءة الكوبونات النشطة للجميع
CREATE POLICY "Anyone can view active coupons"
ON coupons FOR SELECT
USING (is_active = true AND start_date <= NOW() AND (end_date IS NULL OR end_date > NOW()));

-- سياسة إدارة الكوبونات للتجار
CREATE POLICY "Merchants can manage their coupons"
ON coupons FOR ALL
USING (store_id IN (SELECT id FROM stores WHERE merchant_id = auth.uid()));

-- سياسة قراءة استخدامات الكوبون للمستخدم
CREATE POLICY "Users can view their coupon usages"
ON coupon_usages FOR SELECT
USING (user_id = auth.uid());

-- ============================================================
-- 11. كوبونات تجريبية
-- ============================================================
INSERT INTO coupons (code, name_ar, name_en, description_ar, description_en, discount_type, discount_value, max_discount_amount, min_order_amount, usage_limit, end_date)
VALUES 
    ('WELCOME10', 'خصم الترحيب', 'Welcome Discount', 'خصم 10% للمستخدمين الجدد', '10% off for new users', 'percentage', 10, 50, 100, 1000, NOW() + INTERVAL '1 year'),
    ('SAVE20', 'وفر 20 ريال', 'Save 20 SAR', 'خصم 20 ريال على طلبك', '20 SAR off your order', 'fixed', 20, NULL, 150, 500, NOW() + INTERVAL '6 months'),
    ('SUMMER25', 'عرض الصيف', 'Summer Sale', 'خصم 25% على جميع المنتجات', '25% off all products', 'percentage', 25, 100, 200, NULL, NOW() + INTERVAL '3 months')
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- 12. منح الصلاحيات
-- ============================================================
GRANT SELECT ON coupons TO authenticated;
GRANT SELECT ON coupon_categories TO authenticated;
GRANT SELECT ON coupon_products TO authenticated;
GRANT SELECT, INSERT ON coupon_usages TO authenticated;
GRANT EXECUTE ON FUNCTION validate_coupon TO authenticated;
GRANT EXECUTE ON FUNCTION apply_coupon_to_order TO authenticated;
GRANT EXECUTE ON FUNCTION get_available_coupons TO authenticated;


-- ============================================================
-- 13. تحديث دالة إنشاء الطلب المجمع لدعم الكوبونات
-- ============================================================
-- ملاحظة: يجب تحديث دالة create_multi_vendor_order لإضافة دعم الكوبونات
-- أضف هذه المعاملات للدالة:
-- p_coupon_id UUID DEFAULT NULL,
-- p_coupon_code VARCHAR DEFAULT NULL,
-- p_coupon_discount DECIMAL DEFAULT 0

-- وأضف هذا الكود قبل إنشاء الطلب الرئيسي:
-- INSERT INTO parent_orders (..., coupon_id, coupon_code, coupon_discount)
-- VALUES (..., p_coupon_id, p_coupon_code, p_coupon_discount);

-- وبعد إنشاء الطلب بنجاح، سجل استخدام الكوبون:
-- IF p_coupon_id IS NOT NULL THEN
--     PERFORM apply_coupon_to_order(p_coupon_id, p_user_id, v_parent_order_id, p_coupon_discount);
-- END IF;
