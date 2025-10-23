
CREATE OR REPLACE FUNCTION public.atualizar_total_pedido()
RETURNS TRIGGER AS $$
BEGIN
  
  UPDATE public.pedidos
  SET total = (
    SELECT SUM(ip.preco_unitario * ip.quantidade)
    FROM public.itens_pedido ip
    WHERE ip.pedido_id = COALESCE(NEW.pedido_id, OLD.pedido_id)
  )
  WHERE id = COALESCE(NEW.pedido_id, OLD.pedido_id);
  
  RETURN NULL; 
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_atualizar_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON public.itens_pedido
FOR EACH ROW EXECUTE FUNCTION public.atualizar_total_pedido();