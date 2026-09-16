const https = require('https');

const SUPABASE_PROJECT_REF = 'jkgnpxpygmychdylaoct';
const MANAGEMENT_TOKEN = 'sbp_v0_771bffe5ae84887856ff401ccb8f02c0cd0d3808';

async function executeQuery(sql) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ query: sql });
    const req = https.request({
      hostname: 'api.supabase.com',
      path: `/v1/projects/${SUPABASE_PROJECT_REF}/database/query`,
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${MANAGEMENT_TOKEN}`,
        'Content-Type': 'application/json; charset=utf-8',
        'Content-Length': Buffer.byteLength(data, 'utf8')
      }
    }, res => {
      let body = '';
      res.on('data', d => body += d);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          if (res.statusCode >= 400) {
            reject(json);
          } else {
            resolve(json);
          }
        } catch (e) {
          reject(body);
        }
      });
    });
    req.on('error', reject);
    req.write(data, 'utf8');
    req.end();
  });
}

// Curated high quality product image dictionary by keywords
const productImages = {
  // Electronics
  'Smart Watch': ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=80'],
  'HD Webcam': ['https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=600&auto=format&fit=crop&q=80'],
  'Bluetooth Speaker': ['https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&auto=format&fit=crop&q=80'],
  'Gaming Mouse Pad': ['https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=600&auto=format&fit=crop&q=80'],
  'Flash Drive': ['https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=600&auto=format&fit=crop&q=80'],
  'Laptop Stand': ['https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80'],
  'Wireless Earbuds': ['https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&auto=format&fit=crop&q=80'],
  'Noise Cancelling Headphones': ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80'],
  'Power Bank': ['https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=600&auto=format&fit=crop&q=80'],
  'Wireless Charger': ['https://images.unsplash.com/photo-1622445262464-84b1456045b6?w=600&auto=format&fit=crop&q=80'],
  'Mechanical Keyboard': ['https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&auto=format&fit=crop&q=80'],
  'Gaming Mouse': ['https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=600&auto=format&fit=crop&q=80'],

  // Fashion & Clothing
  'Cotton Pajamas': ['https://images.unsplash.com/photo-1617952385804-7b326fa42766?w=600&auto=format&fit=crop&q=80'],
  'Summer Hat': ['https://images.unsplash.com/photo-1521369909029-2afed882baee?w=600&auto=format&fit=crop&q=80'],
  'Leather Jacket': ['https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&auto=format&fit=crop&q=80'],
  'Casual Sneakers': ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80'],
  'Classic T-Shirt': ['https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=600&auto=format&fit=crop&q=80'],
  'Denim Jeans': ['https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=600&auto=format&fit=crop&q=80'],
  'Sunglasses': ['https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=600&auto=format&fit=crop&q=80'],
  'Leather Wallet': ['https://images.unsplash.com/photo-1627123424574-724758594e93?w=600&auto=format&fit=crop&q=80'],
  'Silk Scarf': ['https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=600&auto=format&fit=crop&q=80'],
  'Classic Watch': ['https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&auto=format&fit=crop&q=80'],

  // Home & Kitchen
  'Kitchen Knife Set': ['https://images.unsplash.com/photo-1593618998160-e34014e67546?w=600&auto=format&fit=crop&q=80'],
  'Wall Clock': ['https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=600&auto=format&fit=crop&q=80'],
  'Magazine Rack': ['https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&auto=format&fit=crop&q=80'],
  'Coffee Maker': ['https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?w=600&auto=format&fit=crop&q=80'],
  'Air Fryer': ['https://images.unsplash.com/photo-1585515320310-259814833e62?w=600&auto=format&fit=crop&q=80'],
  'Blender': ['https://images.unsplash.com/photo-1570222094114-d054a817e56b?w=600&auto=format&fit=crop&q=80'],
  'Aromatherapy Diffuser': ['https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=600&auto=format&fit=crop&q=80'],
  'Ceramic Dinnerware Set': ['https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=600&auto=format&fit=crop&q=80'],

  // Sports & Fitness
  'Boxing Gloves': ['https://images.unsplash.com/photo-1509255929945-586a420363cf?w=600&auto=format&fit=crop&q=80'],
  'Basketball': ['https://images.unsplash.com/photo-1546519638-68e109498ffc?w=600&auto=format&fit=crop&q=80'],
  'Professional Football': ['https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=600&auto=format&fit=crop&q=80'],
  'Padel Racket': ['https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=600&auto=format&fit=crop&q=80'],
  'Swimming Goggles': ['https://images.unsplash.com/photo-1530549387789-4c1017266635?w=600&auto=format&fit=crop&q=80'],
  'Swimming Cap': ['https://images.unsplash.com/photo-1560089000-7433a4ebbd64?w=600&auto=format&fit=crop&q=80'],
  'Yoga Mat': ['https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=600&auto=format&fit=crop&q=80'],
  'Jump Rope': ['https://images.unsplash.com/photo-1518611012118-696072aa579a?w=600&auto=format&fit=crop&q=80'],
  'Sports Bag': ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80'],
  'Wrist Weights': ['https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=600&auto=format&fit=crop&q=80'],
  'Pull-up Bar': ['https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=600&auto=format&fit=crop&q=80'],
  'Medicine Ball 5kg': ['https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=600&auto=format&fit=crop&q=80'],
  'Resistance Bands': ['https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=600&auto=format&fit=crop&q=80'],
  'Stationary Bike': ['https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80'],
  'Football Boots': ['https://images.unsplash.com/photo-1511556532299-8f662fc26c06?w=600&auto=format&fit=crop&q=80'],
  'Sports Earphones': ['https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&auto=format&fit=crop&q=80'],
  'Pedometer': ['https://images.unsplash.com/photo-1576243345690-4e4b79b63288?w=600&auto=format&fit=crop&q=80'],

  // Books
  'Learn Programming Book': ['https://images.unsplash.com/photo-1532012197267-da84d127e765?w=600&auto=format&fit=crop&q=80'],
  'English Arabic Dictionary': ['https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80'],
  'Arabic Cooking Book': ['https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=600&auto=format&fit=crop&q=80'],
  'Self Development Book': ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=600&auto=format&fit=crop&q=80'],
  'Children Encyclopedia': ['https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80'],
  'Short Stories Book': ['https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=600&auto=format&fit=crop&q=80'],
  'Learn English Book': ['https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=600&auto=format&fit=crop&q=80'],
  'Islamic History Book': ['https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=600&auto=format&fit=crop&q=80'],
  'Premium Notebook': ['https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=600&auto=format&fit=crop&q=80'],

  // Beauty & Personal Care
  'Natural Shampoo': ['https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=600&auto=format&fit=crop&q=80'],
  'Waterproof Mascara': ['https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=600&auto=format&fit=crop&q=80'],
  'Luxury Perfume': ['https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=600&auto=format&fit=crop&q=80'],
  'Face Moisturizer': ['https://images.unsplash.com/photo-1556228720-195a672e8a03?w=600&auto=format&fit=crop&q=80'],
  'Lipstick Set': ['https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=600&auto=format&fit=crop&q=80'],
  'Sunscreen SPF 50': ['https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?w=600&auto=format&fit=crop&q=80'],

  // Supermarket / Food
  'Gourmet Mixed Nuts': ['https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80'],
  'Organic Honey': ['https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80'],
  'Roasted Pistachios': ['https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&auto=format&fit=crop&q=80'],
};

// Arabic translation mapping dictionary
const arabicDictionary = {
  'Short Stories Book': { ar: 'كتاب قصص قصيرة عالمية', descAr: 'مجموعة مختارة من أروع القصص الأدبية القصيرة لكبار الكتاب والمؤلفين.' },
  'Basketball': { ar: 'كرة سلة احترافية جلدية', descAr: 'كرة سلة رسمية مصنوعة من جلد مركب عالي الجودة مناسبة للملاعب الداخلية والخارجية.' },
  'Boxing Gloves': { ar: 'قفازات ملاكمة احترافية', descAr: 'قفازات ملاكمة مبطنة بطبقات حماية متطورة لامتصاص الصدمات وحماية المعصم.' },
  'Magazine Rack': { ar: 'حامل مجلات وكتب عصري', descAr: 'منظم وحامل كتب ومجلات بتصميم أنيق يناسب غرف المعيشة والمكاتب الحديثة.' },
  'Wall Clock': { ar: 'ساعة حائط دائرية كلاسيكية', descAr: 'ساعة حائط هادئة بتصميم مودرن وأرقام واضحة تناسب ديكور المنزل والمكتب.' },
  'Natural Shampoo': { ar: 'شامبو طبيعي بخلاصة الأعشاب', descAr: 'شامبو عضوي خالي من السلفات والبارابين لتغذية الشعر وترطيبه بعمق.' },
  'Children Encyclopedia': { ar: 'موسوعة العلوم والمعرفة للأطفال', descAr: 'موسوعة علمية مصورة وشاملة تنمي مهارات ومعارف الأطفال بأسلوب تفاعلي جذاب.' },
  'Self Development Book': { ar: 'كتاب فن إدارة الذات والنجاح', descAr: 'دليل عملي لتطوير الشخصية، تنظيم الوقت، وبناء عادات النجاح اليومية.' },
  'Arabic Cooking Book': { ar: 'كتاب أسرار المطبخ العربي والشرقي', descAr: 'أشهى الوصفات الشرقية التقليدية والعصرية مع خطوات التحضير الدقيقة بالصور.' },
  'English Arabic Dictionary': { ar: 'قاموس إنجليزي عربي شامل', descAr: 'معجم لغوي شامل يحتوي على آلاف المفردات والمصطلحات الشائعة مع أمثلة ونطق سليم.' },
  'Learn Programming Book': { ar: 'كتاب احترف البرمجة من الصفر', descAr: 'مرجع شامل لتعلم مبادئ ولغات البرمجة الحديثة وبناء التطبيقات خطوة بخطوة.' },
  'Pedometer': { ar: 'عداد خطوات ومسافات رقمي', descAr: 'جهاز صغير وعالي الدقة لحساب الخطوات اليومية، السعرات الحرارية والمسافات المقطوعة.' },
  'Volleyball': { ar: 'كرة طائرة للمسابقات والشواطئ', descAr: 'كرة طائرة بملمس ناعم ومقاومة ممتازة للماء، مناسبة للتدريب والمباريات.' },
  'Padel Racket': { ar: 'مضرب بادل كاربون فايبر', descAr: 'مضرب بادل احترافي مصنوع من ألياف الكربون لضمان أقصى قدر من التحكم وقوة الضربة.' },
  'Swimming Cap': { ar: 'قبعة سباحة سيليكون مرنة', descAr: 'قبعة سباحة مصممة لحماية الشعر ومنع دخول الماء مع راحة تامة أثناء السباحة.' },
  'Swimming Goggles': { ar: 'نظارات سباحة مضادة للضباب', descAr: 'نظارات سباحة مع عدسات حماية من الأشعة فوق البنفسجية ومقاومة لتشكل الضباب.' },
  'Football Boots': { ar: 'حذاء كرة قدم أرضية عشبية', descAr: 'حذاء رياضي خفيف الوزن مع نعل سفلي متطور للثبات وسرعة المناورة في الملعب.' },
  'Sports Earphones': { ar: 'سماعات رياضية لاسلكية بلوتوث', descAr: 'سماعات أذن مقاومة للماء والتعرق مع بطارية تدوم طويلاً وصوت عالي النقاء.' },
  'Stationary Bike': { ar: 'دراجة تمارين رياضية منزلية', descAr: 'دراجة ثابتة مزودة بشاشة رقمية ومستويات مقاومة متعددة لحرق الدهون وتقوية العضلات.' },
  'Smart Watch': { ar: 'ساعة ذكية مقاومة للماء مع تتبع اللياقة', descAr: 'شاشة AMOLED عالية الدقة، قياس نبضات القلب ونسبة الأكسجين مع بطارية تدوم 7 أيام.' },
  'Summer Hat': { ar: 'قبعة صيفية أنيقة للحماية من الشمس', descAr: 'قبعة شاطئ كلاسيكية خفيفة الوزن توفر حماية فائقة من أشعة الشمس ومظهر جذاب.' },
  'Resistance Bands': { ar: 'مجموعة أحزمة المقاومة للتمارين', descAr: 'أحزمة مطاطية متعددة الأوزان لتمارين اللياقة البدنية وتقوية العضلات في المنزل.' },
  'Medicine Ball 5kg': { ar: 'كرة تمارين طبية ثقيلة 5 كجم', descAr: 'كرة حديدية مغطاة بطبقة مطاطية متينة لتمارين القوة والتوازن والتأهيل الرياضي.' },
  'Pull-up Bar': { ar: 'عقلة تمارين منزلية سهلة التثبيت', descAr: 'بار عقلة من الفولاذ المقوى يمكن تثبيته على إطار الباب لتمارين الظهر والذراعين.' },
  'Wrist Weights': { ar: 'أثقال معصم وكاحل قابلة للتعديل', descAr: 'أوزان مبطنة لزيادة شدة التمارين الرياضية والمشي والجري.' },
  'Sports Bag': { ar: 'حقيبة رياضية للجيم والسفر', descAr: 'حقيبة واسعة مع قسم مخصص للأحذية ومقاومة للماء بتصميم عصري وخفيف.' },
  'Yoga Mat': { ar: 'بساط يوغا وتمارين غير قابل للانزلاق', descAr: 'سجادة تمارين سميكة ومريحة للمفاصل مصنوعة من مواد صديقة للبيئة.' },
  'Jump Rope': { ar: 'حبل قفز سريع مع محامل معدنية', descAr: 'حبل قفز فائق السرعة لتمارين الكارديو وحرق السعرات بكفاءة عالية.' },
  'Professional Football': { ar: 'كرة قدم احترافية معتمدة', descAr: 'كرة قدم متينة بجودة عالية لمباريات الملاعب العشبية والتدريب المكثف.' },
  'Kitchen Knife Set': { ar: 'طقم سكاكين مطبخ ستانلس ستيل مع حامل', descAr: 'طقم احترافي مكون من 6 قطع حادة جداً مع حامل خشبي أنيق للمطبخ العصري.' },
  'HD Webcam': { ar: 'كاميرا ويب عالية الدقة 1080p مع مايكروفون', descAr: 'كاميرا ممتازة للاجتماعات عبر الإنترنت والبث المباشر مع عزل الضوضاء التلقائي.' },
  'Bluetooth Speaker': { ar: 'سبيكر بلوتوث محمول بصوت نقي وباس قوي', descAr: 'مكبر صوت لاسلكي مقاوم للماء مع إضاءة ديناميكية وبطارية تدوم 12 ساعة متواصلة.' },
  'Cotton Pajamas': { ar: 'بيجامة قطنية مريحة 100% قطن مصري', descAr: 'طقم ملابس نوم قطنية فاخرة بملمس ناعم جداً وقصة مريحة مناسبة لجميع المواسم.' },
  'Gaming Mouse Pad': { ar: 'ماوس باد جيمنج عريض بإضاءة RGB', descAr: 'سطح قماشي أملس يوفر استجابة فائقة للماوس مع قاعدة مطاطية مانعة للانزلاق.' },
  'Premium Notebook': { ar: 'دفتر ملاحظات جلدي فاخر مع قلم', descAr: 'دفتر أعمال أنيق بأوراق سميكة مقاومة لتسرب الحبر وغلاف جلدي راقي.' },
  'Flash Drive': { ar: 'فلاشة ميموري فائقة السرعة USB 3.2', descAr: 'وحدة تخزين بيانات سريعة بهيكل معدني متين مقاوم للصدمات والماء.' },
  'Laptop Stand': { ar: 'حامل لابتوب ألومنيوم مريح وقابل للطي', descAr: 'حامل لابتوب مريح للرقبة يحسن تهوية الجهاز ومناسب لجميع أحجام الحواسيب المحمولة.' },
  'Waterproof Mascara': { ar: 'ماسكارا لتكثيف وتطويل الرموش مقاومة للماء', descAr: 'تركيبة تدوم طوال اليوم بدون تكتل تمنح الرموش كثافة استثنائية وجاذبية فورية.' },
};

async function run() {
  console.log('--- 1. Updating Categories with correct UTF-8 names & High-Res Images ---');

  const categoriesUpdates = [
    {
      id: '11111111-1111-1111-1111-111111111111',
      name_ar: 'إلكترونيات',
      name_en: 'Electronics',
      image_url: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&auto=format&fit=crop&q=80',
      sort_order: 1
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      name_ar: 'ملابس وأزياء',
      name_en: 'Fashion & Clothing',
      image_url: 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500&auto=format&fit=crop&q=80',
      sort_order: 2
    },
    {
      id: '33333333-3333-3333-3333-333333333333',
      name_ar: 'المنزل والمطبخ',
      name_en: 'Home & Kitchen',
      image_url: 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=500&auto=format&fit=crop&q=80',
      sort_order: 3
    },
    {
      id: '44444444-4444-4444-4444-444444444444',
      name_ar: 'رياضة ولياقة',
      name_en: 'Sports & Fitness',
      image_url: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop&q=80',
      sort_order: 4
    },
    {
      id: '55555555-5555-5555-5555-555555555555',
      name_ar: 'كتب وقراءة',
      name_en: 'Books & Reading',
      image_url: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&auto=format&fit=crop&q=80',
      sort_order: 5
    },
    {
      id: '66666666-6666-6666-6666-666666666666',
      name_ar: 'العناية والجمال',
      name_en: 'Beauty & Personal Care',
      image_url: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500&auto=format&fit=crop&q=80',
      sort_order: 6
    },
    {
      id: '80287c2e-a077-4ea1-8654-2a8aab3a674e',
      name_ar: 'سوبرماركت ومأكولات',
      name_en: 'Supermarket & Food',
      image_url: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80',
      sort_order: 7
    }
  ];

  for (const cat of categoriesUpdates) {
    const sql = `
      UPDATE public.categories 
      SET name_ar = '${cat.name_ar.replace(/'/g, "''")}',
          name_en = '${cat.name_en.replace(/'/g, "''")}',
          image_url = '${cat.image_url}',
          sort_order = ${cat.sort_order}
      WHERE id = '${cat.id}';
    `;
    await executeQuery(sql);
    console.log(`Updated Category: ${cat.name_ar} (${cat.name_en})`);
  }

  console.log('\n--- 2. Fetching Products to Fix Encoding & Images ---');
  const products = await executeQuery('SELECT id, name_en, name_ar, description_en, description_ar, category_id, images FROM public.products;');

  console.log(`Found ${products.length} products. Updating...`);

  let count = 0;
  for (const p of products) {
    const nameEn = (p.name_en || '').trim();
    let dictEntry = null;

    // Find in dictionary
    for (const key of Object.keys(arabicDictionary)) {
      if (nameEn.toLowerCase().includes(key.toLowerCase()) || key.toLowerCase().includes(nameEn.toLowerCase())) {
        dictEntry = arabicDictionary[key];
        break;
      }
    }

    const arName = dictEntry ? dictEntry.ar : (p.name_ar && !p.name_ar.includes('Ø') ? p.name_ar : nameEn);
    const arDesc = dictEntry ? dictEntry.descAr : `منتج أصلي عالي الجودة من أفضل الماركات العالمية، متوفر الآن بضمان كامل وشحن سريع.`;
    const enDesc = (p.description_en && p.description_en.length > 5) ? p.description_en : `Premium quality authentic product with full manufacturer warranty and fast express delivery.`;

    // Find suitable image
    let newImage = null;
    for (const imgKey of Object.keys(productImages)) {
      if (nameEn.toLowerCase().includes(imgKey.toLowerCase()) || imgKey.toLowerCase().includes(nameEn.toLowerCase())) {
        newImage = productImages[imgKey][0];
        break;
      }
    }

    // Fallback if no specific image matched
    if (!newImage) {
      if (p.category_id === '11111111-1111-1111-1111-111111111111') newImage = 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&auto=format&fit=crop&q=80';
      else if (p.category_id === '22222222-2222-2222-2222-222222222222') newImage = 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=600&auto=format&fit=crop&q=80';
      else if (p.category_id === '33333333-3333-3333-3333-333333333333') newImage = 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600&auto=format&fit=crop&q=80';
      else if (p.category_id === '44444444-4444-4444-4444-444444444444') newImage = 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600&auto=format&fit=crop&q=80';
      else if (p.category_id === '55555555-5555-5555-5555-555555555555') newImage = 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80';
      else if (p.category_id === '66666666-6666-6666-6666-666666666666') newImage = 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=600&auto=format&fit=crop&q=80';
      else newImage = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600&auto=format&fit=crop&q=80';
    }

    const imagesArraySql = `ARRAY['${newImage}']::text[]`;

    const sql = `
      UPDATE public.products
      SET name_ar = '${arName.replace(/'/g, "''")}',
          description_ar = '${arDesc.replace(/'/g, "''")}',
          description_en = '${enDesc.replace(/'/g, "''")}',
          images = ${imagesArraySql},
          updated_at = NOW()
      WHERE id = '${p.id}';
    `;

    await executeQuery(sql);
    count++;
    if (count % 10 === 0 || count === products.length) {
      console.log(`Updated ${count}/${products.length} products...`);
    }
  }

  console.log('\n--- 3. Verifying Results ---');
  const sample = await executeQuery('SELECT id, name_ar, name_en, images[1] as image, category_id FROM public.products LIMIT 5;');
  console.log(JSON.stringify(sample, null, 2));

  const sampleCats = await executeQuery('SELECT id, name_ar, name_en, image_url FROM public.categories ORDER BY sort_order ASC;');
  console.log('\nUpdated Categories:');
  console.log(JSON.stringify(sampleCats, null, 2));

  console.log('\n✅ Database content and encoding updated successfully!');
}

run().catch(console.error);
