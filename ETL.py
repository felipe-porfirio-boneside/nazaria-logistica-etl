import polars as pl
import pyodbc
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError
from datetime import date, timedelta

tp_job = 0

# --------------
# Querys pro ETL
# --------------

# Pedido de Venda #

query_pedido_venda = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PEDIDOS_VENDAS]"""

query_pedido_venda_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PEDIDOS_VENDAS_MERGE_CT] @AtualVersionID = ?"""

query_pedido_venda_DW = f"""CALL bronze.usp_merge_pedido_venda();
	                        CALL gold.usp_merge_fato_pedido_venda();
	                        CALL gold.usp_merge_fato_pedido_venda_produto();"""

# Pedido de Venda - log status #

query_pedido_venda_status = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PEDIDOS_VENDAS_STATUS_LOG]"""

query_pedido_venda_status_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].BONESIDE_ETL_PEDIDOS_VENDAS_VENDAS_STATUS_MERGE_CT @AtualVersionID = ?"""

query_pedido_venda_status_DW = f"""CALL bronze.usp_merge_pedido_venda_status();
                                   CALL silver.usp_merge_pedido_venda_status();"""

# Cadastro de Entidade #

query_entidade = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_ENTIDADES]"""

query_entidade_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_ENTIDADES_MERGE_CT] @AtualVersionID = ?"""

query_entidade_DW = f"""CALL bronze.usp_merge_entidade();
                        CALL gold.usp_merge_dim_cliente();
                        CALL gold.usp_merge_dim_transportador();"""

# Solicitação de Faturamento #

query_solicitacao = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_SOLICITACAO_FATURAMENTO]"""

query_solicitacao_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_SOLICITACAO_FATURAMENTO_MERGE_CT] @AtualVersionID = ?"""

query_solicitacao_DW = f"""CALL bronze.usp_merge_solicitacao_faturamento();
                           CALL silver.usp_merge_solicitacao_faturamento();"""

# Cadastro de Produto #

query_produto = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PRODUTOS]"""

query_produto_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PRODUTOS_MERGE_CT] @AtualVersionID = ?"""

qquery_produto_DW = f"""CALL bronze.usp_merge_produto();
                        CALL gold.usp_merge_dim_produto();"""

# Cadastro de Emrpesa #

query_empresa = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_EMPRESAS_USUARIAS]"""

query_empresa_ct = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_EMPRESAS_USUARIAS_MERGE_CT] @AtualVersionID = ?"""

query_empresa_DW = f"""CALL bronze.usp_merge_empresa();
                       CALL gold.usp_merge_dim_empresa();"""

# Estoque transferencia #

query_estoque_transferencia = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_ESTOQUE_TRANSFERENCIAS_TRANSACOES]"""

query_estoque_transferencia_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_ESTOQUE_TRANSFERENCIAS_TRANSACOES_MERGE_CT] @AtualVersionID = ?"""

query_estoque_transferencia_DW = f""" CALL bronze.usp_merge_estoque_transferencia();
                                      CALL silver.usp_merge_estoque_transferencia();"""

# Cadastro de Localizador #

query_cadastro_localizador = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PRODUTOS_LOCAIS]"""

query_cadastro_localizador_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PRODUTOS_LOCAIS_MERGE_CT] @AtualVersionID = ?"""

query_cadastro_localizador_DW = f"""CALL bronze.usp_merge_cadastro_localizador();
                                    CALL gold.usp_merge_dim_setor_logistica();"""

# Cadastro de Usuario #

query_usuario = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_USUARIOS]"""

query_usuario_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_USUARIOS_MERGE_CT] @AtualVersionID = ?"""

query_usuario_DW = f"""CALL bronze.usp_merge_usuario();
                       CALL gold.usp_merge_dim_usuario();"""

# Checkout #

query_checkout = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_WMS_CHECKOUT]"""

query_checkout_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_WMS_CHECKOUT_MERGE_CT] @AtualVersionID = ?"""

query_checkout_DW = f"""CALL bronze.usp_merge_checkout();
                        CALL gold.usp_merge_fato_checkout();"""

# Saldo de Estoque #

query_saldo_localizador = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_SALDO_LOCALIZADOR]"""

query_saldo_localizador_CT = f"""exec [PBS_NAZARIA_DADOS].[dbo].[BONESIDE_ETL_SALDO_LOCALIZADOR_MERGE_CT] @AtualVersionID = ?"""

query_saldo_localizador_DW = f"""CALL gold.usp_merge_fato_saldo_localizador();"""

# Cadastro de Lote e Validade #

query_lote_validade = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PRODUTOS_LOTE_VALIDADE]"""

query_lote_validade_CT = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_PRODUTOS_LOTE_VALIDADE_MERGE_CT] @AtualVersionID = ?"""

query_lote_validade_DW = f"""CALL bronze.usp_merge_lote_validade();
                             CALL gold.usp_merge_dim_lote_validade();"""

# NF Faturamento #

query_nf_faturamento = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_NF_FATURAMENTO]"""

query_nf_faturamento_DW = f"""CALL bronze.usp_merge_nf_faturamento();
                              CALL silver.usp_merge_nf_faturamento();"""

# Rota #

query_rota = f"""exec PBS_NAZARIA_DADOS.[dbo].[BONESIDE_ETL_ROTA]"""

query_rota_DW = f"""CALL bronze.usp_merge_rota();
                              CALL gold.usp_merge_dim_rota();"""

# ------------------------------
# Abre conexão no banco de dados
# ------------------------------

conn_sql = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=ip"
    "DATABASE=banco"
    "UID=usuario"
    "PWD=senha"
)

engine = create_engine(
    "postgresql+psycopg2://usuario:senha@ip/banco"
)

# --------------------------------
# Seleciona os dados no SQL Server
# --------------------------------

"""
tp_job: 1 = Apenas um processo
        2 = Completo
"""

tp_job = 2

if tp_job == 1:
    jobs = [
        {
            "nome": "Estoque Transferencia",
            "query": query_estoque_transferencia,
            "query_CT": query_estoque_transferencia_CT,
            "destino": "staging.estoque_transferencia",
            "DW": query_estoque_transferencia_DW
        }
    ]

if tp_job == 2:
    jobs = [
        {
            "nome": "Solicitação de Faturamento",
            "query": query_solicitacao,
            "query_CT": query_solicitacao_CT,
            "destino": "staging.solicitacao_faturamento",
            "DW": query_solicitacao_DW
        },
        {
            "nome": "Estoque Transferencia",
            "query": query_estoque_transferencia,
            "query_CT": query_estoque_transferencia_CT,
            "destino": "staging.estoque_transferencia",
            "DW": query_estoque_transferencia_DW
        },
        {
            "nome": "Cadastro de Entidade",
            "query": query_entidade,
            "query_CT": query_entidade_CT,
            "destino": "staging.entidade",
            "DW": query_entidade_DW
        },
        {
            "nome": "Cadastro de Produto",
            "query": query_produto,
            "query_CT": query_produto_CT,
            "destino": "staging.produto",
            "DW": qquery_produto_DW
        },
        {
            "nome": "Cadastro de Empresa",
            "query": query_empresa,
            "query_CT": query_empresa_ct,
            "destino": "staging.empresa",
            "DW": query_empresa_DW
        },
        {
            "nome": "Cadastro de Localizador",
            "query": query_cadastro_localizador,
            "query_CT": query_cadastro_localizador_CT,
            "destino": "staging.cadastro_localizador",
            "DW": query_cadastro_localizador_DW
        },
        {
            "nome": "Cadastro de Usuario",
            "query": query_usuario,
            "query_CT": query_usuario_CT,
            "destino": "staging.usuario",
            "DW": query_usuario_DW
        },
        {
            "nome": "Checkout",
            "query": query_checkout,
            "query_CT": query_checkout_CT,
            "destino": "staging.checkout",
            "DW": query_checkout_DW
        },
        {
            "nome": "Cadastro de Lote e Validade",
            "query": query_lote_validade,
            "query_CT": query_lote_validade_CT,
            "destino": "staging.lote_validade",
            "DW": query_lote_validade_DW
        },
        {
            "nome": "NF Faturamento",
            "query": query_nf_faturamento,
            "destino": "staging.nf_faturamento",
            "DW": query_nf_faturamento_DW
        },
        {
            "nome": "Saldo por localizador",
            "query": query_saldo_localizador,
            "query_CT": query_saldo_localizador_CT,
            "destino": "staging.saldo_localizador",
            "DW": query_saldo_localizador_DW
        },
        {
            "nome": "Pedido de Venda Status",
            "query": query_pedido_venda_status,
            "query_CT": query_pedido_venda_status_CT,
            "destino": "staging.pedido_venda_status",
            "DW": query_pedido_venda_status_DW
        },
        {
            "nome": "Pedido de Venda",
            "query": query_pedido_venda,
            "query_CT": query_pedido_venda_CT,
            "destino": "staging.pedidos_vendas",
            "DW": query_pedido_venda_DW
        }
    ]

for script in jobs:

    processo = script["nome"]
    destino = script["destino"]
    query_dados = script["query"]
    procedure_DW = None
    cursor = None

    if script.get("DW"):
        procedure_DW = script["DW"]

    if script.get("query_CT"):
        query_atualiza_CT = script["query_CT"]

    try:

        print(f"Inicio do Processo: {processo}")

        # 1. Busca dados
        df = pl.read_database(
            query=query_dados,
            connection=conn_sql
        )
        print("Consulta de dados Concluida")

        if "versao_ct" in df.columns:
            # Captura a versão do Change Tracking
            versao_ct = df["versao_ct"].max()

            # Remove coluna técnica
            df = df.drop("versao_ct")

        # 2. Grava no PostgreSQL
        df.write_database(
            table_name=destino,
            connection=engine,
            if_table_exists="append"
        )
        print(f"Insert realizado com sucesso: {destino}")

        # 3. Atualiza controle SOMENTE após sucesso
        if script.get("query_CT"):
            cursor = conn_sql.cursor()
            cursor.execute(query_atualiza_CT, versao_ct)
            conn_sql.commit()

            print("Change Tracking atualizado")

    except Exception as e:
        if cursor:
            conn_sql.rollback()

        print(f"Erro: {processo}")
        print(f"Detalhe: {e}")

    finally:
        if cursor:
            cursor.close()

    # 4. Merge DW

    if script.get("DW"):
        try:
            print(f"Atualização do Processo no DW: {processo}")
            with engine.begin() as conn:
                conn.execute(
                    text(procedure_DW)
                )
                print(f"Fim da Atualização no DW: {processo}")
                print("-" * 25)

        except SQLAlchemyError as e:
            print(f"Erro na procedure de Merge no PostgreSQL: {e}")

# -----------------------------
# Merge dos dados no PostgreSQL
# -----------------------------

try:
    print("Iniciando Atualização do DW - PostgreSQL")
    with engine.begin() as conn:
        conn.execute(
            text("CALL gold.usp_merge_carga_dw()")
        )
        print("Fim da Atualização do DW - PostgreSQL")
                        
except SQLAlchemyError as e:
    print(f"Erro na procedure de Merge no PostgreSQL: {e}")






