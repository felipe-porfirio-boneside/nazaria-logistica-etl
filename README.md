# Data Warehouse Logístico & Analytics Platform

## Pipeline de Dados SQL Server → PostgreSQL → Power BI

## Visão Geral

Este projeto consiste no desenvolvimento de uma plataforma analítica de dados voltada para operações logísticas, contemplando todo o ciclo de engenharia de dados desde a extração das informações operacionais até a disponibilização dos indicadores para análise no Power BI.

A solução foi construída utilizando uma arquitetura de Data Warehouse com múltiplas camadas de processamento:

- **Staging**
- **Bronze**
- **Silver**
- **Gold**

O objetivo principal é transformar dados transacionais provenientes do ambiente operacional SQL Server em uma estrutura analítica otimizada para consumo de BI, permitindo acompanhamento de pedidos, faturamento, expedição, estoque e performance logística.

---

# Arquitetura da Solução

## Fluxo de Dados

              SQL Server
         Sistema Operacional
                  |
                  |
                  ↓

        Processo ETL Python
    (Polars + PyODBC + SQLAlchemy)
                  |
                  |
                  ↓
            PostgreSQL DW
    ┌───────────────────────────┐
    │                           │
    │          STAGING          │
    │      Dados extraídos      │
    │                           │
    └─────────────┬─────────────┘
                  |
                  ↓
    ┌───────────────────────────┐
    │                           │
    │          BRONZE           │
    │ Dados históricos tratados │
    │                           │
    └─────────────┬─────────────┘
                  |
                  ↓
    ┌───────────────────────────┐
    │                           │
    │          SILVER           │
    │       Regras de negócio   │
    │       Normalização        │
    │                           │
    └─────────────┬─────────────┘
                  |
                  ↓
    ┌───────────────────────────┐
    │                           │
    │          GOLD             │
    │      Modelo dimensional   │
    │      Fatos e Dimensões    │
    │                           │
    └─────────────┬─────────────┘
                  |
                  ↓
              Power BI
         Dashboards Analíticos

---

# Tecnologias Utilizadas

## Engenharia de Dados

- Python
- Polars
- PyODBC
- SQLAlchemy
- PostgreSQL
- SQL Server
- Stored Procedures
- Change Tracking

## Business Intelligence

- Power BI
- Modelo Dimensional
- Fatos e Dimensões
- Indicadores Logísticos

---

# Contexto de Negócio

O projeto tem como domínio principal a operação logística, utilizando informações relacionadas a:

- Pedidos de venda
- Processos de faturamento
- Separação de produtos
- Expedição
- Transporte
- Controle de estoque
- Localização física dos produtos
- Movimentações internas


O acompanhamento do ciclo do pedido é realizado através dos seguintes status operacionais:

| Código | Status |
|---|---|
| 01 | Pedido em Solicitação de Faturamento |
| 02 | Pedido em Separação |
| 03 | Pedido Liberado para Expedição |
| 04 | Pedido Pré-Faturado |
| 05 | Pedido Faturado |
| 06 | Pedido Despachado |
| 99 | Pedido Cortado na Separação |

---

# Camadas do Data Warehouse

## 1. Staging Layer

A camada staging representa a área inicial de ingestão dos dados provenientes do SQL Server.

Características:

- Recebe dados extraídos do sistema operacional.
- Mantém estrutura próxima da origem.
- Serve como área intermediária para processamento.
- Permite rastreabilidade da carga.

Tabelas:

centro_estoque || estoque_transferencia || localizador || rota || solicitacao_faturamento || entidade || produto || empresa || cadastro_localizador || usuario|| checkout || pedido_venda_status
pedidos_vendas || pedido_venda_status_descricao || lote_validade || nf_faturamento || saldo_localizador

---

# 2. Bronze Layer

A camada Bronze representa o armazenamento inicial dentro do Data Warehouse.

Responsabilidades:

- Persistência dos dados ingeridos.
- Controle histórico.
- Padronização inicial.
- Preparação para regras de negócio.

Tabelas:

lote_validade || usuario || cadastro_localizador || empresa || checkout || produto || rota || pedido_venda_status || centro_estoque || entidade || solicitacao_faturamento
saldo_localizador || pedidos_vendas || nf_faturamento || estoque_transferencia

---

# 3. Silver Layer

A camada Silver concentra regras de tratamento e preparação dos dados para consumo analítico.

Responsabilidades:

- Limpeza dos dados.
- Aplicação de regras de negócio.
- Consolidação de informações.
- Preparação para o modelo dimensional.

Tabelas:

pedido_venda_status || solicitacao_faturamento || nf_faturamento || estoque_transferencia

---

# 4. Gold Layer

A camada Gold representa o modelo dimensional utilizado pelo Power BI.

O modelo foi estruturado utilizando conceitos de:

- Star Schema
- Tabelas Fato
- Tabelas Dimensão

## Tabelas Dimensão

d_usuario || d_localizador || d_setor_logistica || d_centro_estoque || d_transportadora || d_cliente || d_calendario || d_empresa || d_rota
d_produto || d_lote_validade || d_pedido_venda_status || d_turno || d_carga

---

## Tabelas Fato

f_checkout || f_pedido_venda || f_saldo_localizador || f_pedido_venda_produto

---

# Processo ETL

O processo de integração foi desenvolvido em Python.

Principais etapas:

# 1. Extração

Os dados são extraídos do SQL Server através de consultas utilizando:

- Stored Procedures
- Change Tracking

# 📦 Stored Procedures - Processo ETL SQL Server

As extrações dos dados operacionais são realizadas através de Stored Procedures desenvolvidas no SQL Server.

Foram implementadas procedures utilizando **SQL Server Change Tracking**, permitindo processamento incremental das alterações.

## Procedures Utilizadas

```sql
BONESIDE_ETL_EMPRESAS_USUARIAS
BONESIDE_ETL_EMPRESAS_USUARIAS_MERGE_CT

BONESIDE_ETL_ENTIDADES
BONESIDE_ETL_ENTIDADES_MERGE_CT

BONESIDE_ETL_ESTOQUE_TRANSFERENCIAS_TRANSACOES
BONESIDE_ETL_ESTOQUE_TRANSFERENCIAS_TRANSACOES_MERGE_CT

BONESIDE_ETL_NF_FATURAMENTO

BONESIDE_ETL_PEDIDOS_VENDAS
BONESIDE_ETL_PEDIDOS_VENDAS_MERGE_CT

BONESIDE_ETL_PEDIDOS_VENDAS_STATUS_LOG
BONESIDE_ETL_PEDIDOS_VENDAS_VENDAS_STATUS_MERGE_CT

BONESIDE_ETL_PRODUTOS
BONESIDE_ETL_PRODUTOS_MERGE_CT

BONESIDE_ETL_PRODUTOS_LOCAIS
BONESIDE_ETL_PRODUTOS_LOCAIS_MERGE_CT

BONESIDE_ETL_PRODUTOS_LOTE_VALIDADE
BONESIDE_ETL_PRODUTOS_LOTE_VALIDADE_MERGE_CT

BONESIDE_ETL_ROTA

BONESIDE_ETL_SALDO_LOCALIZADOR
BONESIDE_ETL_SALDO_LOCALIZADOR_MERGE_CT

BONESIDE_ETL_SOLICITACAO_FATURAMENTO
BONESIDE_ETL_SOLICITACAO_FATURAMENTO_MERGE_CT

BONESIDE_ETL_USUARIOS
BONESIDE_ETL_USUARIOS_MERGE_CT

BONESIDE_ETL_WMS_CHECKOUT
BONESIDE_ETL_WMS_CHECKOUT_MERGE_CT
```

---

# 2. Controle Incremental

Foi utilizado SQL Server Change Tracking.

O processo:

1. Executa a carga incremental.
2. Captura a versão atual do Change Tracking.
3. Remove colunas técnicas.
4. Persiste os dados no PostgreSQL.
5. Atualiza a versão somente após sucesso da carga.

---

# 3. Carga no PostgreSQL

A persistência dos dados utiliza:

- SQLAlchemy
- Polars DataFrame Writer

---

# 4. Atualização do Data Warehouse

Após a carga das tabelas staging, são executadas procedures responsáveis pela atualização das camadas seguintes.

Exemplo:


staging.pedidos_vendas

    ↓

bronze.usp_merge_pedido_venda()

    ↓
gold.usp_merge_fato_pedido_venda()

    ↓
Power BI

---

# Modelo Analítico

O modelo Gold permite análises como:

## Pedidos

- Quantidade de pedidos
- Evolução por período
- Tempo em cada etapa operacional
- Pedidos faturados
- Pedidos despachados


## Operação Logística

- Performance de separação
- Volume expedido
- Controle de cortes
- Produtividade operacional


## Estoque

- Saldo por localização
- Produtos armazenados
- Movimentações internas
- Lotes e validade


---

# Execução do Processo

## Ambiente Atual

O processo atualmente não possui deploy automatizado.

A execução ocorre:

- Ambiente local
- Máquina de desenvolvimento
- Conexão VPN com ambiente corporativo


Periodicidade:

- 2 vezes por semana
- Ou conforme necessidade para demonstrações e validações com usuários
