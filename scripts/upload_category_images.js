const https = require('https');
const fs = require('fs');

const SUPABASE_PROJECT_REF = 'jkgnpxpygmychdylaoct';
const SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprZ25weHB5Z215Y2hkeWxhb2N0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjI0NjkzNywiZXhwIjoyMDgxODIyOTM3fQ.2rXulCMrn-9AeMZsL7VHle0gGt3BZ9SJ7tGE2VFnV3o';
const MANAGEMENT_TOKEN = 'sbp_v0_771bffe5ae84887856ff401ccb8f02c0cd0d3808';

async function uploadToStorage(bucket, filename, filePath) {
  return new Promise((resolve, reject) => {
    const fileBytes = fs.readFileSync(filePath);
    const req = https.request({
      hostname: `${SUPABASE_PROJECT_REF}.supabase.co`,
      path: `/storage/v1/object/${bucket}/${filename}`,
      method: 'POST',
      headers: {
        'apikey': SERVICE_KEY,
        'Authorization': `Bearer ${SERVICE_KEY}`,
        'Content-Type': 'image/jpeg',
        'x-upsert': 'true',
        'Content-Length': fileBytes.length
      }
    }, res => {
      let body = '';
      res.on('data', d => body += d);
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log(`Uploaded ${filename} successfully.`);
          resolve(`https://${SUPABASE_PROJECT_REF}.supabase.co/storage/v1/object/public/${bucket}/${filename}`);
        } else {
          console.error(`Failed to upload ${filename}: ${res.statusCode} ${body}`);
          reject(body);
        }
      });
    });
    req.on('error', reject);
    req.write(fileBytes);
    req.end();
  });
}

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
      res.on('end', () => resolve(JSON.parse(body)));
    });
    req.on('error', reject);
    req.write(data, 'utf8');
    req.end();
  });
}

async function run() {
  const images = [
    {
      id: '11111111-1111-1111-1111-111111111111',
      name_ar: 'إلكترونيات',
      filename: 'cat_electronics.jpg',
      path: 'C:\\Users\\ahmed\\.gemini\\antigravity-ide\\brain\\f47fcf14-07ce-4d73-ad2c-1e9a1a9d8581\\cat_electronics_1789587701752.jpg'
    },
    {
      id: '22222222-2222-2222-2222-222222222222',
      name_ar: 'ملابس وأزياء',
      filename: 'cat_clothing.jpg',
      path: 'C:\\Users\\ahmed\\.gemini\\antigravity-ide\\brain\\f47fcf14-07ce-4d73-ad2c-1e9a1a9d8581\\cat_clothing_1789587723530.jpg'
    },
    {
      id: '33333333-3333-3333-3333-333333333333',
      name_ar: 'المنزل والمطبخ',
      filename: 'cat_home.jpg',
      path: 'C:\\Users\\ahmed\\.gemini\\antigravity-ide\\brain\\f47fcf14-07ce-4d73-ad2c-1e9a1a9d8581\\cat_home_1789587745599.jpg'
    },
    {
      id: '44444444-4444-4444-4444-444444444444',
      name_ar: 'رياضة ولياقة',
      filename: 'cat_sports.jpg',
      path: 'C:\\Users\\ahmed\\.gemini\\antigravity-ide\\brain\\f47fcf14-07ce-4d73-ad2c-1e9a1a9d8581\\cat_sports_1789587770762.jpg'
    },
    {
      id: '55555555-5555-5555-5555-555555555555',
      name_ar: 'كتب وقراءة',
      filename: 'cat_books.jpg',
      path: 'C:\\Users\\ahmed\\.gemini\\antigravity-ide\\brain\\f47fcf14-07ce-4d73-ad2c-1e9a1a9d8581\\cat_books_1789587799570.jpg'
    }
  ];

  for (const item of images) {
    const url = await uploadToStorage('categories', item.filename, item.path);
    await executeQuery(`UPDATE public.categories SET image_url = '${url}' WHERE id = '${item.id}';`);
    console.log(`Updated ${item.name_ar} image_url: ${url}`);
  }

  // Beauty & Supermarket from existing storage objects or Unsplash working direct links
  await executeQuery(`
    UPDATE public.categories SET image_url = 'https://jkgnpxpygmychdylaoct.supabase.co/storage/v1/object/public/products/images/1766448342552_scaled_1000804742.webp' WHERE id = '66666666-6666-6666-6666-666666666666';
    UPDATE public.categories SET image_url = 'https://jkgnpxpygmychdylaoct.supabase.co/storage/v1/object/public/categories/images/1766348235980_scaled_1000804017.jpg' WHERE id = '80287c2e-a077-4ea1-8654-2a8aab3a674e';
  `);

  console.log('All category images in Supabase Storage updated!');
}

run().catch(console.error);
