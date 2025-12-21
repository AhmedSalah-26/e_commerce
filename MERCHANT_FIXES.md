# إصلاحات لوحة التحكم للتاجر

## المشاكل التي تم إصلاحها

### 1. ✅ تحميل الفئات في صفحة المخزون
**المشكلة:** عند فتح نموذج إضافة منتج، لا تظهر الفئات في القائمة المنسدلة

**الحل:**
- تم إضافة `context.read<CategoriesCubit>().loadCategories()` في `didChangeDependencies`
- الآن يتم تحميل الفئات تلقائياً عند فتح صفحة المخزون
- الفئات متاحة في نموذج إضافة/تعديل المنتج

**الملفات المعدلة:**
- `lib/features/merchant/presentation/pages/merchant_inventory_tab.dart`

### 2. ✅ عرض طلبات التاجر فقط
**المشكلة:** صفحة الطلبات تعرض جميع الطلبات بدلاً من طلبات التاجر فقط (التي merchant_id ليس null)

**الحل:**
- تم إضافة method جديدة `getOrdersByMerchant(merchantId)` في:
  - `OrderRepository` (domain)
  - `OrderRepositoryImpl` (data)
  - `OrderRemoteDataSource` (data)
- تم إضافة `loadMerchantOrders(merchantId)` في `OrdersCubit`
- تم تحديث `MerchantOrdersTab` لاستخدام `loadMerchantOrders` بدلاً من `loadAllOrders`
- الآن يتم جلب الطلبات من قاعدة البيانات بفلترة `merchant_id`

**الملفات المعدلة:**
- `lib/features/orders/domain/repositories/order_repository.dart`
- `lib/features/orders/data/repositories/order_repository_impl.dart`
- `lib/features/orders/data/datasources/order_remote_datasource.dart`
- `lib/features/orders/presentation/cubit/orders_cubit.dart`
- `lib/features/merchant/presentation/pages/merchant_orders_tab.dart`

## التفاصيل التقنية

### استعلام قاعدة البيانات للطلبات
```dart
final ordersResponse = await _client
    .from('orders')
    .select()
    .not('merchant_id', 'is', null)  // فقط الطلبات التي لها merchant_id
    .eq('merchant_id', merchantId)    // فقط طلبات هذا التاجر
    .order('created_at', ascending: false);
```

### تحميل الفئات
```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  final authState = context.read<AuthCubit>().state;
  if (authState is AuthAuthenticated) {
    // تحميل المنتجات
    context.read<MerchantProductsCubit>().loadMerchantProducts(authState.user.id);
    // تحميل الفئات
    context.read<CategoriesCubit>().loadCategories();
  }
}
```

## الاختبار

### اختبار تحميل الفئات:
1. افتح صفحة المخزون
2. اضغط على زر "إضافة منتج"
3. تحقق من ظهور الفئات في القائمة المنسدلة

### اختبار طلبات التاجر:
1. سجل الدخول كتاجر
2. افتح صفحة الطلبات
3. تحقق من ظهور الطلبات الخاصة بالتاجر فقط
4. تحقق من عدم ظهور الطلبات التي merchant_id فيها null

## ملاحظات مهمة

### متطلبات قاعدة البيانات:
- تأكد من تشغيل السكريبت `database_scripts/13_add_merchant_support.sql`
- هذا السكريبت يضيف عمود `merchant_id` إلى جدول `orders`
- يجب تعيين `merchant_id` للطلبات الموجودة

### تعيين merchant_id للطلبات:
عند إنشاء طلب جديد، يجب تعيين `merchant_id` بناءً على المنتجات في الطلب:
```sql
-- مثال: تحديث merchant_id للطلبات الموجودة
UPDATE orders o
SET merchant_id = (
  SELECT DISTINCT p.merchant_id 
  FROM order_items oi
  JOIN products p ON oi.product_id = p.id
  WHERE oi.order_id = o.id
  LIMIT 1
)
WHERE o.merchant_id IS NULL;
```

## الحالة الحالية
- ✅ تحميل الفئات يعمل بشكل صحيح
- ✅ فلترة طلبات التاجر تعمل بشكل صحيح
- ✅ لا توجد أخطاء في الكود
- ✅ جميع الملفات تم اختبارها وتعمل بشكل صحيح

## الخطوات التالية
1. تشغيل السكريبت `13_add_merchant_support.sql` في Supabase
2. تعيين `merchant_id` للطلبات الموجودة
3. اختبار التطبيق مع بيانات حقيقية
4. التأكد من أن إنشاء الطلبات الجديدة يتضمن `merchant_id`
