
CREATE OR REPLACE VIEW public.visao_detalhes_pedido AS
SELECT
  p.id AS pedido_id,
  p.data_pedido,
  p.status,
  p.total,
  c.id AS cliente_id,
  c.nome_completo AS cliente_nome,
  c.email AS cliente_email,
  ip.quantidade,
  ip.preco_unitario,
  prod.id AS produto_id,
  prod.nome AS produto_nome
FROM
  public.pedidos p
  JOIN public.clientes c ON p.cliente_id = c.id
  JOIN public.itens_pedido ip ON p.id = ip.pedido_id
  JOIN public.produtos prod ON ip.produto_id = prod.id;