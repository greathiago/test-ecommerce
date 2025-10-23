import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import {
  createClient,
  SupabaseClient,
} from "https://esm.sh/@supabase/supabase-js@2";

console.log('Função "export-order-csv" iniciada.');

function generateCsv(data: any[]) {
  if (!data || data.length === 0) {
    throw new Error("Não foram encontrados itens para este pedido.");
  }

  const orderInfo = `Pedido ID,${data[0].pedido_id}\nCliente,${data[0].cliente_nome}\nEmail,${data[0].cliente_email}\nTotal,R$ ${data[0].total}\n\n`;
  const headers = "produto_nome,quantidade,preco_unitario,subtotal\n";

  const rows = data
    .map((item) => {
      const subtotal = (item.quantidade * item.preco_unitario).toFixed(2);

      const productName = `"${item.produto_nome.replace(/"/g, '""')}"`;
      return `${productName},${item.quantidade},${item.preco_unitario},${subtotal}`;
    })
    .join("\n");

  return orderInfo + headers + rows;
}

serve(async (req) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: { Authorization: req.headers.get("Authorization")! },
        },
      }
    );

    const url = new URL(req.url);
    const orderId = url.searchParams.get("order_id");

    if (!orderId) {
      throw new Error('O parâmetro "order_id" é obrigatório na URL.');
    }

    const { data, error } = await supabaseClient
      .from("visao_detalhes_pedido")
      .select("*")
      .eq("pedido_id", orderId);

    if (error) throw error;

    const csvContent = generateCsv(data);

    return new Response(csvContent, {
      headers: {
        "Content-Type": "text/csv",
        "Content-Disposition": `attachment; filename="pedido_${orderId}.csv"`,
      },
      status: 200,
    });
  } catch (error) {
    console.error("Erro na função de exportar CSV:", error.message);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    });
  }
});
