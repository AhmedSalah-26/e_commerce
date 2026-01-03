// Supabase Edge Function for Paymob Payment
// This acts as a proxy to avoid CORS issues

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const PAYMOB_API_URL = 'https://accept.paymob.com/api'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { action, apiKey, data } = await req.json()

    let response
    let result

    switch (action) {
      case 'auth':
        // Step 1: Get auth token
        response = await fetch(`${PAYMOB_API_URL}/auth/tokens`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ api_key: apiKey }),
        })
        result = await response.json()
        break

      case 'order':
        // Step 2: Register order
        response = await fetch(`${PAYMOB_API_URL}/ecommerce/orders`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data),
        })
        result = await response.json()
        break

      case 'payment_key':
        // Step 3: Get payment key
        response = await fetch(`${PAYMOB_API_URL}/acceptance/payment_keys`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data),
        })
        result = await response.json()
        break

      case 'wallet_pay':
        // Step 4: Wallet payment
        response = await fetch(`${PAYMOB_API_URL}/acceptance/payments/pay`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data),
        })
        result = await response.json()
        break

      default:
        return new Response(
          JSON.stringify({ error: 'Invalid action' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    }

    return new Response(
      JSON.stringify(result),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Paymob proxy error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
