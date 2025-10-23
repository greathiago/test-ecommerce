
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.produtos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.itens_pedido ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Usuários podem ver e atualizar seus próprios dados" ON public.clientes
  FOR ALL USING (auth.uid() = id);


CREATE POLICY "Qualquer pessoa pode visualizar produtos" ON public.produtos
  FOR SELECT USING (true);


CREATE POLICY "Usuários podem criar pedidos para si mesmos" ON public.pedidos
  FOR INSERT WITH CHECK (auth.uid() = cliente_id);
CREATE POLICY "Usuários podem ver seus próprios pedidos" ON public.pedidos
  FOR SELECT USING (auth.uid() = cliente_id);
  

CREATE POLICY "Usuários podem adicionar itens aos seus próprios pedidos" ON public.itens_pedido
  FOR INSERT WITH CHECK ( (SELECT cliente_id FROM public.pedidos WHERE id = pedido_id) = auth.uid() );
CREATE POLICY "Usuários podem ver os itens dos seus próprios pedidos" ON public.itens_pedido
  FOR SELECT USING ( (SELECT cliente_id FROM public.pedidos WHERE id = pedido_id) = auth.uid() );