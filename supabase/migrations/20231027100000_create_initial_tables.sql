CREATE TYPE status_pedido AS ENUM ('pendente', 'pago', 'enviado', 'entregue', 'cancelado');

CREATE TABLE public.clientes (
  id uuid NOT NULL PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome_completo text,
  email text UNIQUE
);

CREATE TABLE public.produtos (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL,
  descricao text,
  preco numeric(10, 2) NOT NULL CHECK (preco > 0),
  estoque int NOT NULL CHECK (estoque >= 0),
  data_criacao timestamptz DEFAULT now()
);

CREATE TABLE public.pedidos (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id uuid NOT NULL REFERENCES public.clientes(id),
  status status_pedido NOT NULL DEFAULT 'pendente',
  total numeric(10, 2) DEFAULT 0.00,
  data_pedido timestamptz DEFAULT now()
);

CREATE TABLE public.itens_pedido (
  id uuid NOT NULL PRIMARY KEY DEFAULT gen_random_uuid(),
  pedido_id uuid NOT NULL REFERENCES public.pedidos(id) ON DELETE CASCADE,
  produto_id uuid NOT NULL REFERENCES public.produtos(id),
  quantidade int NOT NULL CHECK (quantidade > 0),
  preco_unitario numeric(10, 2) NOT NULL
);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.clientes (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();