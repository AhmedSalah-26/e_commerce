-- ============================================================
-- إصلاح حذف الكوبونات المستخدمة في الطلبات
-- Fix coupon deletion when used in orders
-- ============================================================

-- تغيير الـ foreign key من RESTRICT إلى SET NULL
-- عند حذف الكوبون، يتم تعيين coupon_id في الطلبات إلى NULL

-- 1. حذف الـ constraint القديم
ALTER TABLE parent_orders 
DROP CONSTRAINT IF EXISTS parent_orders_coupon_id_fkey;

-- 2. إضافة constraint جديد مع ON DELETE SET NULL
ALTER TABLE parent_orders
ADD CONSTRAINT parent_orders_coupon_id_fkey 
FOREIGN KEY (coupon_id) 
REFERENCES coupons(id) 
ON DELETE SET NULL;

-- ============================================================
-- ملاحظة: بعد تنفيذ هذا السكريبت:
-- - عند حذف كوبون، الطلبات القديمة ستحتفظ بقيمة الخصم
-- - لكن coupon_id سيصبح NULL
-- - هذا يسمح بحذف الكوبونات بدون مشاكل
-- ============================================================
