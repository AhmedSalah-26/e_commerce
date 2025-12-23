-- Insert sample reviews for products
-- Using a sample user ID (you may need to replace with actual user IDs from your database)

-- First, let's create some reviews for popular products
INSERT INTO reviews (id, product_id, user_id, rating, comment, created_at) VALUES
-- سماعات بلوتوث لاسلكية
(gen_random_uuid(), '253709bf-db1b-4277-b946-fd1e8a01830d', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'سماعات ممتازة جداً، جودة الصوت رائعة وإلغاء الضوضاء فعال', NOW() - INTERVAL '10 days'),
(gen_random_uuid(), '253709bf-db1b-4277-b946-fd1e8a01830d', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'منتج جيد، البطارية تدوم طويلاً', NOW() - INTERVAL '8 days'),
(gen_random_uuid(), '253709bf-db1b-4277-b946-fd1e8a01830d', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'أفضل سماعات اشتريتها، أنصح بها بشدة', NOW() - INTERVAL '5 days'),

-- ماوس جيمنج RGB
(gen_random_uuid(), 'd84580c1-32c7-4ac9-8b5d-c364577f1158', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'ماوس احترافي، الإضاءة رائعة والاستجابة سريعة جداً', NOW() - INTERVAL '12 days'),
(gen_random_uuid(), 'd84580c1-32c7-4ac9-8b5d-c364577f1158', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'ممتاز للألعاب، مريح في الاستخدام', NOW() - INTERVAL '7 days'),

-- كيبورد ميكانيكي
(gen_random_uuid(), 'd4319aa7-5654-4d84-9baa-5cf33d35ddff', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'كيبورد رائع، صوت الأزرار مميز والكتابة مريحة', NOW() - INTERVAL '15 days'),
(gen_random_uuid(), 'd4319aa7-5654-4d84-9baa-5cf33d35ddff', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'جودة ممتازة، يستحق السعر', NOW() - INTERVAL '9 days'),

-- شاشة 27 بوصة 4K
(gen_random_uuid(), 'd64dbf79-6e45-4683-b3c5-a1463b44d6f4', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'شاشة مذهلة، الألوان حقيقية والدقة عالية جداً', NOW() - INTERVAL '20 days'),
(gen_random_uuid(), 'd64dbf79-6e45-4683-b3c5-a1463b44d6f4', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'أفضل شاشة للعمل والألعاب', NOW() - INTERVAL '14 days'),

-- ساعة ذكية
(gen_random_uuid(), 'd76d6b54-ce41-4411-8c37-1a4e597c3d8b', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'ساعة جميلة ومفيدة، تتبع اللياقة دقيق', NOW() - INTERVAL '11 days'),
(gen_random_uuid(), 'd76d6b54-ce41-4411-8c37-1a4e597c3d8b', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'تصميم أنيق وبطارية ممتازة', NOW() - INTERVAL '6 days'),

-- جاكيت جلد
(gen_random_uuid(), '260b83e7-3fee-4728-977e-0a57b26bb4ce', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'جاكيت فخم جداً، الجلد طبيعي وناعم', NOW() - INTERVAL '18 days'),
(gen_random_uuid(), '260b83e7-3fee-4728-977e-0a57b26bb4ce', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'تصميم عصري وجودة عالية', NOW() - INTERVAL '13 days'),

-- فستان سهرة
(gen_random_uuid(), 'e3692d44-5755-410c-a506-f1cb5bc81608', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'فستان راقي جداً، القماش ممتاز', NOW() - INTERVAL '16 days'),
(gen_random_uuid(), 'e3692d44-5755-410c-a506-f1cb5bc81608', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'تصميم أنيق ومقاس مضبوط', NOW() - INTERVAL '10 days'),

-- طقم أواني طهي
(gen_random_uuid(), 'bfc46064-d510-4d15-928b-f437999b280c', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'طقم ممتاز، جودة عالية ومتين', NOW() - INTERVAL '22 days'),
(gen_random_uuid(), 'bfc46064-d510-4d15-928b-f437999b280c', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'سهل التنظيف والطبخ فيه ممتاز', NOW() - INTERVAL '17 days'),

-- سجادة يوجا
(gen_random_uuid(), '37ad4915-116a-45a0-9925-3dcb0c59cd23', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'سجادة مريحة جداً ومضادة للانزلاق فعلاً', NOW() - INTERVAL '8 days'),
(gen_random_uuid(), '37ad4915-116a-45a0-9925-3dcb0c59cd23', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'سمك مناسب وجودة ممتازة', NOW() - INTERVAL '4 days'),

-- رواية الخيميائي
(gen_random_uuid(), 'b821583e-dcf0-4ad7-93ce-fbefdc822ca4', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'رواية رائعة، من أفضل ما قرأت', NOW() - INTERVAL '25 days'),
(gen_random_uuid(), 'b821583e-dcf0-4ad7-93ce-fbefdc822ca4', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'كتاب ملهم ومؤثر جداً', NOW() - INTERVAL '19 days'),

-- سيروم فيتامين سي
(gen_random_uuid(), '899165ea-1fbf-4d00-94ac-c55bb5e9a200', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 5, 'نتائج مذهلة على البشرة، أنصح به', NOW() - INTERVAL '12 days'),
(gen_random_uuid(), '899165ea-1fbf-4d00-94ac-c55bb5e9a200', 'e7ab5369-e6c3-450f-bd6b-1cdcc7008440', 4, 'منتج فعال، البشرة أصبحت أكثر نضارة', NOW() - INTERVAL '7 days');

-- Update review_count for these products
UPDATE products SET review_count = 3 WHERE id = '253709bf-db1b-4277-b946-fd1e8a01830d';
UPDATE products SET review_count = 2 WHERE id = 'd84580c1-32c7-4ac9-8b5d-c364577f1158';
UPDATE products SET review_count = 2 WHERE id = 'd4319aa7-5654-4d84-9baa-5cf33d35ddff';
UPDATE products SET review_count = 2 WHERE id = 'd64dbf79-6e45-4683-b3c5-a1463b44d6f4';
UPDATE products SET review_count = 2 WHERE id = 'd76d6b54-ce41-4411-8c37-1a4e597c3d8b';
UPDATE products SET review_count = 2 WHERE id = '260b83e7-3fee-4728-977e-0a57b26bb4ce';
UPDATE products SET review_count = 2 WHERE id = 'e3692d44-5755-410c-a506-f1cb5bc81608';
UPDATE products SET review_count = 2 WHERE id = 'bfc46064-d510-4d15-928b-f437999b280c';
UPDATE products SET review_count = 2 WHERE id = '37ad4915-116a-45a0-9925-3dcb0c59cd23';
UPDATE products SET review_count = 2 WHERE id = 'b821583e-dcf0-4ad7-93ce-fbefdc822ca4';
UPDATE products SET review_count = 2 WHERE id = '899165ea-1fbf-4d00-94ac-c55bb5e9a200';