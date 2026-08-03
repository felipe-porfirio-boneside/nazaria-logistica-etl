CREATE procedure [dbo].[BONESIDE_ETL_ENTIDADES] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.entidades')

select distinct t1.ENTIDADE																				 as ENTIDADE
					,t1.NOME_FANTASIA																			 as NOME_FANTASIA		
					,REPLACE(REPLACE(REPLACE(t1.INSCRICAO_FEDERAL,'.', ''),'-', ''),'/', '') as INSCRICAO_FEDERAL								
					,t2.CIDADE																					 as CIDADE
					,t2.ESTADO																					 as ESTADO
					,iif(t3.CLIENTE_REDE = 14, 'GLOBO','NÃO GLOBO')									 as TIPO_CLIENTE
					,t4.DESCRICAO																				 as CLIENTE_REDE	
					,iif(len(REPLACE(REPLACE(REPLACE(t1.INSCRICAO_FEDERAL,'.', ''),'-', ''),'/', '')) <= 11,
						  'PF','PJ')																			 as PJ_PF		
					,'Não Informado'																			 as Classificacao
					,@AtualVersionID																			 as versao_ct
					,ct.SYS_CHANGE_OPERATION																 as operation

from CHANGETABLE(CHANGES dbo.entidades, @StartVersionID) ct
inner join PBS_NAZARIA_DADOS.dbo.entidades t1 with(nolock)
	on t1.entidade = ct.entidade
left join PBS_NAZARIA_DADOS.dbo.ENDERECOS t2
	on t2.ENTIDADE = t1.ENTIDADE	
left join PBS_NAZARIA_DADOS.dbo.PEDIDOS_VENDAS_PARAMETROS_ENTIDADES t3
	on t3.entidade = t1.ENTIDADE
left join PBS_NAZARIA_DADOS.dbo.CLIENTES_REDES t4
	on t4.CLIENTE_REDE = t3.CLIENTE_REDE

where t1.ENTIDADE not in (select t1.ENTIDADE
								  from PBS_NAZARIA_DADOS.dbo.ENTIDADES t1
								  inner join PBS_NAZARIA_DADOS.dbo.CLASSIFICACOES t5
								  	on t5.ENTIDADE = t1.ENTIDADE
								    and t5.CLASSIFICACAO = 15 
								 ) 

  and (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

union all

select distinct t1.ENTIDADE																	 as ENTIDADE
		,t1.NOME_FANTASIA																			 as NOME_FANTASIA		
		,REPLACE(REPLACE(REPLACE(t1.INSCRICAO_FEDERAL,'.', ''),'-', ''),'/', '') as INSCRICAO_FEDERAL								
		,t2.CIDADE																					 as CIDADE
		,t2.ESTADO																					 as ESTADO
		,iif(t3.CLIENTE_REDE = 14, 'GLOBO','NÃO GLOBO')									 as TIPO_CLIENTE
		,t4.DESCRICAO																				 as CLIENTE_REDE	
		,iif(len(REPLACE(REPLACE(REPLACE(t1.INSCRICAO_FEDERAL,'.', ''),'-', ''),'/', '')) <= 11,
			  'PF','PJ')																			 as PJ_PF		
		,t6.DESCRICAO																				 as Classificacao
		,@AtualVersionID																			 as versao_ct
		,ct.SYS_CHANGE_OPERATION																 as operation

from CHANGETABLE(CHANGES dbo.entidades, @StartVersionID) ct
inner join PBS_NAZARIA_DADOS.dbo.entidades t1 with(nolock)
	on t1.entidade = ct.entidade
left join PBS_NAZARIA_DADOS.dbo.ENDERECOS t2
	on t2.ENTIDADE = t1.ENTIDADE	
left join PBS_NAZARIA_DADOS.dbo.PEDIDOS_VENDAS_PARAMETROS_ENTIDADES t3
	on t3.entidade = t1.ENTIDADE
left join PBS_NAZARIA_DADOS.dbo.CLIENTES_REDES t4
	on t4.CLIENTE_REDE = t3.CLIENTE_REDE
left join PBS_NAZARIA_DADOS.dbo.CLASSIFICACOES t5
	on t5.ENTIDADE = t1.ENTIDADE
left join PBS_NAZARIA_DADOS.dbo.CLASSIF_ENTIDADES t6 
	on t6.CLASSIF_ENTIDADE = t5.CLASSIFICACAO  

where t6.DESCRICAO = 'TRANSPORTADORA'
  and (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
