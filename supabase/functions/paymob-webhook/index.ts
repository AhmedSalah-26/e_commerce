import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: { 'Access-Control-Allow-Origin': '*' },
    })
  }

  try {
    let payload: any
    let isRedirectCallback = false

    // Handle both GET (redirect callback) and POST (webhook)
    if (req.method === 'GET') {
      isRedirectCallback = true
      const url = new URL(req.url)
      payload = {
        obj: {
          id: url.searchParams.get('id'),
          success: url.searchParams.get('success') === 'true',
          amount_cents: Number(url.searchParams.get('amount_cents') || 0),
          order: {
            merchant_order_id: url.searchParams.get('merchant_order_id'),
          },
        },
      }
    } else {
      payload = await req.json()
    }

    console.log('Paymob webhook:', JSON.stringify(payload))

    const obj = payload.obj
    if (!obj) {
      return new Response(JSON.stringify({ error: 'No obj in payload' }), { status: 400 })
    }

    const merchantOrderId = obj.order?.merchant_order_id
    const success = obj.success === true
    const transactionId = obj.id?.toString()
    const amountCents = obj.amount_cents || 0

    // Extract actual order ID (remove timestamp suffix we added)
    let parentOrderId = merchantOrderId
    if (merchantOrderId && merchantOrderId.includes('_')) {
      parentOrderId = merchantOrderId.split('_')[0]
    }

    const paymentStatus = success ? 'paid' : 'failed'
    const orderStatus = success ? 'pending' : 'payment_failed'

    console.log(`Processing: parentOrderId=${parentOrderId}, success=${success}, status=${paymentStatus}`)

    if (parentOrderId) {
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      )

      // Update parent_orders
      await supabase
        .from('parent_orders')
        .update({
          payment_status: paymentStatus,
          payment_transaction_id: transactionId,
          payment_amount: amountCents / 100,
          updated_at: new Date().toISOString(),
        })
        .eq('id', parentOrderId)

      // Update child orders
      await supabase
        .from('orders')
        .update({
          payment_status: paymentStatus,
          status: orderStatus,
          payment_transaction_id: transactionId,
          payment_amount: amountCents / 100,
          updated_at: new Date().toISOString(),
        })
        .eq('parent_order_id', parentOrderId)

      console.log(`Updated payment status to ${paymentStatus} for order ${parentOrderId}`)
    }

    // For GET requests (redirect callback from Paymob), return HTML that closes/notifies parent
    if (isRedirectCallback) {
      const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${success ? 'Payment Successful' : 'Payment Failed'}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      background: linear-gradient(135deg, ${success ? '#10b981' : '#ef4444'} 0%, ${success ? '#059669' : '#dc2626'} 100%);
      color: white;
      text-align: center;
      padding: 20px;
    }
    .container {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 24px;
      padding: 40px;
      max-width: 400px;
    }
    .icon {
      width: 80px;
      height: 80px;
      margin: 0 auto 20px;
      background: white;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .icon svg { width: 48px; height: 48px; }
    h1 { font-size: 24px; margin-bottom: 10px; }
    p { opacity: 0.9; font-size: 16px; }
    .loader {
      margin-top: 20px;
      width: 40px;
      height: 40px;
      border: 3px solid rgba(255,255,255,0.3);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin-left: auto;
      margin-right: auto;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">
      ${success 
        ? '<svg fill="#10b981" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg>'
        : '<svg fill="#ef4444" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12 19 6.41z"/></svg>'
      }
    </div>
    <h1>${success ? 'تم الدفع بنجاح!' : 'فشل الدفع'}</h1>
    <p>${success ? 'Payment Successful' : 'Payment Failed'}</p>
    <div class="loader"></div>
    <p style="margin-top: 15px; font-size: 14px;">جاري التحويل...</p>
  </div>
  <script>
    const result = {
      success: ${success},
      parentOrderId: "${parentOrderId || ''}",
      transactionId: "${transactionId || ''}",
      paymentStatus: "${paymentStatus}"
    };
    
    // Try to notify parent window
    if (window.parent && window.parent !== window) {
      window.parent.postMessage(result, '*');
    }
    if (window.opener) {
      window.opener.postMessage(result, '*');
    }
    
    // Auto close/redirect after 2 seconds
    setTimeout(() => {
      if (window.opener) {
        window.close();
      } else if (window.parent && window.parent !== window) {
        window.parent.postMessage({ ...result, action: 'close' }, '*');
      }
    }, 2000);
  </script>
</body>
</html>
      `
      return new Response(html, {
        status: 200,
        headers: { 'Content-Type': 'text/html; charset=utf-8' }
      })
    }

    // For POST requests (webhook), return JSON
    return new Response(JSON.stringify({ success: true, parentOrderId, paymentStatus }), { 
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }
})
