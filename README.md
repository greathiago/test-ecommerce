# E-commerce Supabase

Este projeto implementa um sistema básico de e-commerce usando Supabase, demonstrando boas práticas de modelagem de dados, segurança e automação.

## Estrutura do Projeto

### Banco de Dados

O projeto utiliza quatro tabelas principais:

1. **`clientes`**: Armazena informações dos usuários

   - Integrada com `auth.users` do Supabase para autenticação
   - Automaticamente populada através de trigger quando um novo usuário é criado

2. **`produtos`**: Catálogo de produtos disponíveis

   - Sistema de estoque integrado
   - Preços com precisão de duas casas decimais

3. **`pedidos`**: Registro principal de compras

   - Status controlado por ENUM para garantir consistência
   - Total calculado automaticamente por trigger

4. **`itens_pedido`**: Relacionamento entre pedidos e produtos
   - Mantém o preço no momento da compra
   - Trigger atualiza automaticamente o total do pedido

### Segurança (RLS - Row Level Security)

Todas as tabelas implementam políticas de segurança em nível de linha:

- **`clientes`**: Usuários só podem ver e editar seus próprios dados
- **`produtos`**: Leitura pública, mas modificações bloqueadas
- **`pedidos`**: Usuários só veem e criam seus próprios pedidos
- **`itens_pedido`**: Acesso vinculado à propriedade do pedido

### Automação

1. **Criação de Cliente Automática**

   - Trigger `on_auth_user_created` cria automaticamente um registro na tabela `clientes` quando um novo usuário se registra

2. **Cálculo Automático de Total**
   - Trigger `trigger_atualizar_total_pedido` mantém o campo `total` da tabela `pedidos` sempre atualizado
   - Recalcula o total sempre que itens são adicionados, modificados ou removidos

### Otimização de Consultas

A view `visao_detalhes_pedido` oferece:

- Junção otimizada de todas as tabelas relacionadas
- Cálculos prontos como subtotais
- Facilita a geração de relatórios e exportações

### Edge Functions

1. **`send-confirmation-email`**

   - Acionada por webhook quando um novo pedido é criado
   - Simula o envio de e-mail de confirmação
   - Facilmente extensível para usar serviços reais de e-mail

2. **`export-order-csv`**
   - Endpoint HTTP GET que gera CSV de pedidos
   - Utiliza a view otimizada para buscar dados
   - Formato ideal para relatórios e integrações

## Configuração

1. **Variáveis de Ambiente**

   ```bash
   SUPABASE_URL=sua_url
   SUPABASE_SERVICE_ROLE_KEY=sua_chave
   ```

2. **Database Webhook**
   - Configure em Database > Webhooks
   - Evento: INSERT na tabela `pedidos`
   - URL: sua_url/functions/v1/send-confirmation-email

## Uso

### Exportar Pedido como CSV

```http
GET /functions/v1/export-order-csv?order_id=uuid_do_pedido
```

### Políticas de Segurança

Todas as operações respeitam o usuário autenticado através do `auth.uid()`, garantindo que:

- Clientes só vejam seus próprios dados
- Pedidos sejam associados ao cliente correto
- Produtos sejam visíveis publicamente mas protegidos contra modificações

## Decisões de Arquitetura

- **Lógica no Banco de Dados:** Optei por usar Triggers para o cálculo de totais e integridade de dados (como a criação automática de clientes) para garantir que as regras de negócio sejam sempre aplicadas, independente de onde venha a requisição (Frontend, Edge Function ou acesso direto).
- **Segurança por Padrão:** A aplicação de RLS em todas as tabelas garante que a segurança seja aplicada na camada de dados, prevenindo vazamentos mesmo se houver falhas na aplicação cliente.
- **Otimização com Views:** A criação da `visao_detalhes_pedido` evita múltiplas consultas e joins complexos no código da aplicação ou nas Edge Functions, centralizando a lógica de leitura complexa no banco.
