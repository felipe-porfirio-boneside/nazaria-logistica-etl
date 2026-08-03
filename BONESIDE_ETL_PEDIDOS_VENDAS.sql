CREATE PROCEDURE [dbo].[BONESIDE_ETL_PEDIDOS_VENDAS] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

set @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.PEDIDOS_VENDAS')


select t1.PEDIDO_VENDA																						as PEDIDO_VENDA
		,t1.EMPRESA																								as EMPRESA
		,t1.DATA_HORA																							as DATA_HORA
		,t1.ENTIDADE																							as ENTIDADE
		,t1.VENDEDOR																							as VENDEDOR
		,t1.EMISSAO																								as EMISSAO
		,t1.MOVIMENTO																							as MOVIMENTO
		,t1.TRANSPORTADORA																					as TRANSPORTADORA									
	   ,t1.DATA_ENTREGA																						as DATA_ENTREGA
		,t2.DESCRICAO																							as DESCRICAO
		,t3.PRODUTO																								as PRODUTO
		,iif(isnull(t3.QUANTIDADE_ATENDIDA,0) > 0,t3.QUANTIDADE_ATENDIDA,t3.QUANTIDADE)	as QUANTIDADE
		,t4.ROTA																									as ROTA
		,t5.STATUS_PEDIDO_VENDA																				as STATUS_PEDIDO_VENDA
		,t3.TOTAL_PRODUTO																						as total 
		,@AtualVersionID																						as versao_ct
		,ct.SYS_CHANGE_OPERATION																			as operation
		,'PEDIDOS_VENDAS'						                                  as tabela

from CHANGETABLE (CHANGES dbo.PEDIDOS_VENDAS, @StartVersionID) ct
inner join PBS_NAZARIA_DADOS.dbo.PEDIDOS_VENDAS t1 with(nolock)
	on t1.PEDIDO_VENDA = ct.PEDIDO_VENDA
inner join PBS_NAZARIA_DADOS.dbo.PEDIDOS_VENDAS_PRODUTOS_COMPLETA t3 with(nolock)
	on t3.PEDIDO_VENDA = t1.PEDIDO_VENDA
inner join PBS_NAZARIA_DADOS.dbo.PEDIDOS_VENDAS_STATUS	t5 with(nolock) 
	on t5.PEDIDO_VENDA = t1.PEDIDO_VENDA
left join PBS_NAZARIA_DADOS.dbo.ORIGENS_VENDAS_CANAIS t2 with(nolock) 
	on t2.ORIGEM_VENDA_CANAL = t1.ORIGEM_VENDA_CANAL
left join PBS_NAZARIA_DADOS.dbo.ROTAS_FATURAMENTOS_ENTIDADES t4 with(nolock)
	on t4.ENTIDADE = t1.ENTIDADE
  and t4.EMPRESA_USUARIA = t1.EMPRESA 


where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
