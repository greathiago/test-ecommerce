

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

console.log('Função "send-confirmation-email" iniciada.');

async function sendEmail(orderData: any) {
  const order = orderData.record;

  console.log("--- SIMULANDO ENVIO DE E-MAIL DE CONFIRMAÇÃO ---");
  console.log(`Para: (E-mail do cliente seria buscado com base no cliente_id: ${order.cliente_id})`);
  console.log(`Assunto: Confirmação do seu Pedido #${order.id.substring(0, 8)}`);
  console.log(`Corpo: Olá! Seu pedido no valor de R$${order.total} foi recebido e está com status '${order.status}'.`);
  console.log("-----------------------------------------------");
  
  return new Response("Simulação de e-mail registrada no console.", { status: 200 });
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Método não permitido', { status: 405 });
  }
  console.log('Headers:', req.headers);
  console.log('Auth header:', req.headers.get('Authorization'));
  
  try {
    const payload = await req.json();
    await sendEmail(payload);
    return new Response(JSON.stringify({ message: "Webhook processado com sucesso!" }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    console.error('Erro ao processar o webhook:', error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    });
  }
})