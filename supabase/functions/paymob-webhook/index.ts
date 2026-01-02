import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { 
      headers: { 'Access-Control-Allow-Origin': '*' } 
    })
  }

  try {
    const payload = await req.json()
    console.log('Paymob webhook:', JSON.stringify(payload))

    // Extract data from Paymob payload
    const obj = payload.obj
    if (!obj) {
      return new Response(JSON.stringify({ error: 'No obj in payload' }), { status: 400 })
    }

    // merchant_order_id is our parent_order_id
    const parentOrderId = obj.order?.merchant_order_id
    const success = obj.success === true
    const transactionId = obj.id?.toString()
    const amountCents = obj.amount_cents || 0

    const paymentStatus = success ? 'paid' : 'failed'
    const orderStatus = success ? 'pending' : 'payment_failed'

    console.log(`Parent Order: ${parentOrderId}, Success: ${success}, Status: ${paymentStatus}`)

    // Update database if we have order ID
    if (parentOrderId) {
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
      )

      // Update parent_orders first
      const { error: parentError } = await supabase
        .from('parent_orders')
        .update({
          payment_status: paymentStatus,
          payment_transaction_id: transactionId,
          payment_amount: amountCents / 100,
          updated_at: new Date().toISOString()
        })
        .eq('id', parentOrderId)

      if (parentError) {
        console.error('Error updating parent_orders:', parentError)
      }

      // Update all child orders with this parent_order_id
      // Also update order status based on payment result
      const { error: ordersError } = await supabase
        .from('orders')
        .update({
          payment_status: paymentStatus,
          status: orderStatus,
          payment_transaction_id: transactionId,
          payment_amount: amountCents / 100,
          updated_at: new Date().toISOString()
        })
        .eq('parent_order_id', parentOrderId)

      if (ordersError) {
        console.error('Error updating orders:', ordersError)
      }

      console.log(`Updated payment status to ${paymentStatus} and order status to ${orderStatus} for parent order ${parentOrderId}`)
    }

    return new Response(
      JSON.stringify({ success: true, parent_order_id: parentOrderId, payment_status: paymentStatus }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }
})
