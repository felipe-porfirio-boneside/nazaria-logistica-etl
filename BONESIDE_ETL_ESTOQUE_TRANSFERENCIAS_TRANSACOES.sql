CREATE PROCEDURE [dbo].[BONESIDE_ETL_ESTOQUE_TRANSFERENCIAS_TRANSACOES] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.ESTOQUE_TRANSFER
ENCIAS_TRANSACOES')

declare @StartVersionID_ESTOQUE_TRANSFERENCIAS bigint

SET @StartVersionID_ESTOQUE_TRANSFERENCIAS = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.ESTOQUE_TRANSFERENCIAS')

select B.ESTOQUE_TRANSFERENCIA										AS ESTOQUE_TRANSFERENCIA,
       A.PRODUTO															AS PRODUTO,
		 B.PEDIDO_VENDA													AS PEDIDO_VENDA,
		 D.DESCRICAO														AS TIPO_ESTOQUE,
       SUM(ISNULL(A.QTDE_ORIGINAL, 0))                      AS QTDE_ORIGINAL,
       SUM(ISNULL(A.CONFERENCIA  , 0))                      AS CONFERENCIA,
       SUM(ISNULL(A.ACERTO_FALTA  , 0))                     AS ACERTO_FALTA,
       SUM(ISNULL(A.ACERTO_SOBRA  , 0))                     AS ACERTO_SOBRA,       
       SUM(ISNULL(A.QTDE_ORIGINAL, 0)) -
       SUM(ISNULL(A.CONFERENCIA  , 0)) -
       SUM(ISNULL(A.ACERTO_FALTA , 0)) -
       SUM(ISNULL(A.ACERTO_FALTA_SEPARACAO, 0))  +				
       SUM(ISNULL(A.ACERTO_SOBRA , 0))                      AS SALDO,
       SUM(ISNULL(A.QTDE_ORIGINAL, 0)) -
       SUM(ISNULL(A.CONFERENCIA  , 0))                      AS DIVERGENCIA_ORIGINAL,
       SUM( CASE WHEN (B.TIPO_ESTOQUE = 1 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR,'N') = 'S' ) OR (B.TIPO_ESTOQUE = 2 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR_FR,'N') = 'S' ) OR (B.SEPARACAO_VIA_COLETOR = 'S')
                 THEN ISNULL(A.SEPARACAO  , 0)
       		     ELSE ISNULL(A.CONFERENCIA, 0)
       	    END )                                           AS SEPARACAO,
       SUM( CASE WHEN (B.TIPO_ESTOQUE = 1 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR,'N') = 'S' ) OR (B.TIPO_ESTOQUE = 2 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR_FR,'N') = 'S' ) OR (B.SEPARACAO_VIA_COLETOR = 'S')
                THEN ISNULL(A.ACERTO_FALTA_SEPARACAO, 0)
       		    ELSE ISNULL(A.ACERTO_FALTA , 0)
       	    END )                                           AS ACERTO_FALTA_SEPARACAO,
       SUM( CASE WHEN (B.TIPO_ESTOQUE = 1 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR,'N') = 'S' ) OR (B.TIPO_ESTOQUE = 2 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR_FR,'N') = 'S' ) OR (B.SEPARACAO_VIA_COLETOR = 'S')
                 THEN ISNULL(A.ACERTO_SOBRA_SEPARACAO, 0)
       		     ELSE ISNULL(A.ACERTO_SOBRA , 0)
            END )                                           AS ACERTO_SOBRA_SEPARACAO,       
       0                                                    AS DIVERGENCIA_SEPARACAO_CHECKOUT,
       SUM(ISNULL(A.QTDE_ORIGINAL, 0)) - ( SUM( CASE WHEN (B.TIPO_ESTOQUE = 1 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR,'N') = 'S' ) OR (B.TIPO_ESTOQUE = 2 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR_FR,'N') = 'S' ) OR (B.SEPARACAO_VIA_COLETOR = 'S')
                                                     THEN ISNULL(A.SEPARACAO  , 0)
       		                                         ELSE ISNULL(A.CONFERENCIA, 0)
       	                                        END ) +

                                           SUM( CASE WHEN (B.TIPO_ESTOQUE = 1 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR,'N') = 'S' ) OR (B.TIPO_ESTOQUE = 2 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR_FR,'N') = 'S' ) OR (B.SEPARACAO_VIA_COLETOR = 'S')
            
                                                     THEN ISNULL(A.ACERTO_FALTA_SEPARACAO, 0)
                                                     ELSE ISNULL(A.ACERTO_FALTA , 0)
                                                END ) -
                                           
                                           SUM( CASE WHEN (B.TIPO_ESTOQUE = 1 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR,'N') = 'S' ) OR (B.TIPO_ESTOQUE = 2 AND ISNULL(C.CONFERENCIA_CHECKOUT_COLETOR_FR,'N') = 'S' ) OR (B.SEPARACAO_VIA_COLETOR = 'S')
            
                                                     THEN ISNULL(A.ACERTO_SOBRA_SEPARACAO, 0)
                                                     ELSE ISNULL(A.ACERTO_SOBRA , 0)
                                    END ) )     as SALDO_SEPARACAO
		,b.DATA_HORA													 as dt_romaneio 
		,e.dt_falta														 as dt_falta
		,@AtualVersionID												 as versao_ct
		,ct.SYS_CHANGE_OPERATION									 as operation

from 
CHANGETABLE(CHANGES dbo.ESTOQUE_TRANSFERENCIAS_TRANSACOES, @StartVersionID) ct
inner join 
ESTOQUE_TRANSFERENCIAS_TRANSACOES A with(nolock)
	on a.TRANSFERENCIA_TRANSACAO = ct.TRANSFERENCIA_TRANSACAO
join ESTOQUE_TRANSFERENCIAS						B with(nolock) on B.ESTOQUE_TRANSFERENCIA = A.ESTOQUE_TRANSFERENCIA
																			  and b.PEDIDO_VENDA is not null
join PARAMETROS_ESTOQUE								C with(nolock) on C.EMPRESA_USUARIA       = B.EMPRESA
left join TIPOS_ESTOQUE_TRANSFERENCIAS			D with(nolock) on D.TIPO_ESTOQUE				= B.TIPO_ESTOQUE
left join (
				select max(t1.DATA_HORA)					as dt_falta
						,t0.ESTOQUE_TRANSFERENCIA			as ESTOQUE_TRANSFERENCIA
						,t0.PRODUTO								as PRODUTO

				from RESOLUCAO_DIV_ESTOQUE_TRANSF t1 with(nolock)
				inner join RESOLUCAO_DIV_ESTOQUE_TRANSF_ITENS t0 with(nolock)
					on t0.RESOLUCAO = t1.RESOLUCAO
				  and t0.QUANTIDADE > 0

				group by t0.ESTOQUE_TRANSFERENCIA
						  ,t0.PRODUTO

			 ) E 
	on e.ESTOQUE_TRANSFERENCIA = a.ESTOQUE_TRANSFERENCIA
 and e.PRODUTO = a.PRODUTO

where 1=1
  and (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID
  
group by B.ESTOQUE_TRANSFERENCIA,
         A.PRODUTO,
         case when B.TIPO_ESTOQUE = 1
				  then C.CONFERENCIA_CHECKOUT_COLETOR
				  else C.CONFERENCIA_CHECKOUT_COLETOR_FR
			end,
			B.PEDIDO_VENDA,
			D.DESCRICAO,
			b.DATA_HORA,
			e.dt_falta,
			ct.SYS_CHANGE_OPERATION
	
union all

select t1.ESTOQUE_TRANSFERENCIA										AS ESTOQUE_TRANSFERENCIA,
       isnull(e.PRODUTO,0)												AS PRODUTO,
		 t1.PEDIDO_VENDA													AS PEDIDO_VENDA,
		 D.DESCRICAO														AS TIPO_ESTOQUE,
       0											                     AS QTDE_ORIGINAL,
       0											                     AS CONFERENCIA,
       isnull(e.QUANTIDADE,0)				                     AS ACERTO_FALTA,
       0											                     AS ACERTO_SOBRA,       
       0																		AS SALDO,
       0																		AS DIVERGENCIA_ORIGINAL,
       0																		AS SEPARACAO,
       0																		AS ACERTO_FALTA_SEPARACAO,
       0																		AS ACERTO_SOBRA_SEPARACAO,       
       0                                                    AS DIVERGENCIA_SEPARACAO_CHECKOUT,
       0																		AS SALDO_SEPARACAO
		,t1.DATA_HORA													   AS dt_romaneio 
		,e.dt_falta															AS dt_falta
		,@AtualVersionID													AS versao_ct
		,ct.SYS_CHANGE_OPERATION										AS operation

from 
CHANGETABLE(CHANGES dbo.ESTOQUE_TRANSFERENCIAS, @StartVersionID_ESTOQUE_TRANSFERENCIAS) ct
inner join 
ESTOQUE_TRANSFERENCIAS t1 with(nolock)
	on t1.ESTOQUE_TRANSFERENCIA = ct.ESTOQUE_TRANSFERENCIA
left join TIPOS_ESTOQUE_TRANSFERENCIAS	D with(nolock) 
	on D.TIPO_ESTOQUE = t1.TIPO_ESTOQUE
left join (
				select max(t1.DATA_HORA)					as dt_falta
						,t0.ESTOQUE_TRANSFERENCIA			as ESTOQUE_TRANSFERENCIA
						,t0.PRODUTO								as PRODUTO
						,sum(t0.QUANTIDADE)					as QUANTIDADE

				from RESOLUCAO_DIV_ESTOQUE_TRANSF t1 with(nolock)
				inner join RESOLUCAO_DIV_ESTOQUE_TRANSF_ITENS t0 with(nolock)
					on t0.RESOLUCAO = t1.RESOLUCAO
				  and t0.QUANTIDADE > 0

				group by t0.ESTOQUE_TRANSFERENCIA
						  ,t0.PRODUTO

			 ) E 
	on e.ESTOQUE_TRANSFERENCIA = t1.ESTOQUE_TRANSFERENCIA
left join ESTOQUE_TRANSFERENCIAS_TRANSACOES t2 with(nolock)
	on t2.ESTOQUE_TRANSFERENCIA = t1.ESTOQUE_TRANSFERENCIA
  and t2.PRODUTO = e.PRODUTO 

where 1=1
  and (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID
  and t2.TRANSFERENCIA_TRANSACAO is null
  and t1.PEDIDO_VENDA is not null

end


