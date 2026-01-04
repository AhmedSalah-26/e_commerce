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

    // For GET requests (redirect callback from Paymob), redirect to webapp
    if (isRedirectCallback) {
      // Redirect to webapp orders page
      // Use APP_BASE_URL env variable, fallback to localhost for testing
      const webappUrl = Deno.env.get('APP_BASE_URL') || 'http://localhost:5173'
      const redirectUrl = `${webappUrl}/orders?payment=${success ? 'success' : 'failed'}&order_id=${parentOrderId || ''}`
      
      console.log(`Redirecting to: ${redirectUrl}`)
      
      return new Response(null, {
        status: 302,
        headers: { 
          'Location': redirectUrl,
          'Cache-Control': 'no-cache, no-store, must-revalidate'
        }
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
