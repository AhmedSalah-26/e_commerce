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

    // Handle both GET (redirect callback) and POST (webhook)
    if (req.method === 'GET') {
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
    // Format: orderId_timestamp_random -> orderId
    let parentOrderId = merchantOrderId
    if (merchantOrderId && merchantOrderId.includes('_')) {
      parentOrderId = merchantOrderId.split('_')[0]
    }

    const paymentStatus = success ? 'paid' : 'failed'
    const orderStatus = success ? 'pending' : 'payment_failed'

    console.log(`Processing: parentOrderId=${parentOrderId}, success=${success}, status=${paymentStatus}`)

    if (!parentOrderId) {
      return new Response(JSON.stringify({ error: 'No parent_order_id' }), { status: 400 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Update parent_orders
    const { error: parentError } = await supabase
      .from('parent_orders')
      .update({
        payment_status: paymentStatus,
        payment_transaction_id: transactionId,
        payment_amount: amountCents / 100,
        updated_at: new Date().toISOString(),
      })
      .eq('id', parentOrderId)

    if (parentError) {
      console.error('Error updating parent_orders:', parentError)
    }

    // Update child orders
    const { error: ordersError } = await supabase
      .from('orders')
      .update({
        payment_status: paymentStatus,
        status: orderStatus,
        payment_transaction_id: transactionId,
        payment_amount: amountCents / 100,
        updated_at: new Date().toISOString(),
      })
      .eq('parent_order_id', parentOrderId)

    if (ordersError) {
      console.error('Error updating orders:', ordersError)
    }

    console.log(`Updated payment status to ${paymentStatus} for order ${parentOrderId}`)

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
