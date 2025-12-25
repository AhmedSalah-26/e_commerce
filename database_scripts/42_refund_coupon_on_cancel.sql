-- ============================================================
-- استرجاع استخدام الكوبون عند إلغاء الطلب
-- Refund coupon usage when order is cancelled
-- ============================================================

-- دالة لاسترجاع استخدام الكوبون
CREATE OR REPLACE FUNCTION refund_coupon_usage(
    p_order_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_coupon_id UUID;
    v_usage_record RECORD;
BEGIN
    -- البحث عن سجل استخدام الكوبون للطلب
    SELECT * INTO v_usage_record
    FROM coupon_usages
    WHERE order_id = p_order_id;
    
    -- لو مفيش كوبون مستخدم، نرجع true
    IF v_usage_record IS NULL THEN
        RETURN true;
    END IF;
    
    -- حذف سجل الاستخدام
    DELETE FROM coupon_usages
    WHERE order_id = p_order_id;
    
    -- تقليل عداد الاستخدام في جدول الكوبونات
    UPDATE coupons
    SET usage_count = GREATEST(usage_count - 1, 0),
        updated_at = NOW()
    WHERE id = v_usage_record.coupon_id;
    
    RETURN true;
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$func$;

-- Trigger function لاسترجاع الكوبون تلقائياً عند إلغاء الطلب
CREATE OR REPLACE FUNCTION trigger_refund_coupon_on_cancel()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    -- لو الحالة الجديدة cancelled والقديمة مش cancelled
    IF NEW.status = 'cancelled' AND (OLD.status IS NULL OR OLD.status != 'cancelled') THEN
        -- استرجاع الكوبون للطلب الرئيسي (parent_order)
        PERFORM refund_coupon_usage(NEW.parent_order_id);
    END IF;
    
    RETURN NEW;
END;
$func$;

-- حذف الـ trigger القديم لو موجود
DROP TRIGGER IF EXISTS trg_refund_coupon_on_cancel ON orders;

-- إنشاء الـ trigger على جدول orders
CREATE TRIGGER trg_refund_coupon_on_cancel
    AFTER UPDATE OF status ON orders
    FOR EACH ROW
    EXECUTE FUNCTION trigger_refund_coupon_on_cancel();

-- منح الصلاحيات
GRANT EXECUTE ON FUNCTION refund_coupon_usage TO authenticated;
