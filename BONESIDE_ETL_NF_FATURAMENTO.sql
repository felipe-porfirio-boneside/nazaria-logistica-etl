CREATE PROCEDURE [dbo].[BONESIDE_ETL_NF_FATURAMENTO] 
as   
begin 

declare @StartVersionID bigint

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.NF_FATURAMENTO')

select t1.NF_FATURAMENTO									as NF_FATURAMENTO
		,t1.PEDIDO_VENDA										as PEDIDO_VENDA
		,t1.EMPRESA												as EMPRESA
		,t1.ENTIDADE											as ENTIDADE
		,t1.DATA_HORA											as DATA_HORA
		,t1.VENDEDOR											as VENDEDOR
		,t1.CHAVE_NFE											as CHAVE_NFE
		,iif(t1.CHAVE_NFE is not null, 'Sim','Não')	as NF_Faturada
		,sum(t2.QUANTIDADE)									as QUANTIDADE
		,max(t3.TOTAL_GERAL)									as TOTAL_GERAL
		,null														as operation

from PBS_NAZARIA_DADOS.dbo.NF_FATURAMENTO t1
inner join PBS_NAZARIA_DADOS.dbo.NF_FATURAMENTO_PRODUTOS t2
	on t2.NF_FATURAMENTO = t1.NF_FATURAMENTO
inner join PBS_NAZARIA_DADOS.dbo.NF_FATURAMENTO_TOTAIS t3
	on t3.NF_FATURAMENTO = t1.NF_FATURAMENTO

where cast(t1.DATA_HORA as date) >= cast(getdate()-2 as date)

group by t1.NF_FATURAMENTO	
		  ,t1.PEDIDO_VENDA		
		  ,t1.EMPRESA				
		  ,t1.ENTIDADE			
		  ,t1.DATA_HORA			
		  ,t1.VENDEDOR			
		  ,t1.CHAVE_NFE	
		  --,ct.SYS_CHANGE_OPERATION

end
