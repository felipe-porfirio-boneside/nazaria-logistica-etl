CREATE PROCEDURE [dbo].[BONESIDE_ETL_PRODUTOS_LOTE_VALIDADE] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.PRODUTOS_LOTE_VALIDADE')


select t1.LOTE_VALIDADE					as LOTE_VALIDADE			
		,t1.PRODUTO							as PRODUTO					
		,t1.LOTE								as LOTE						
		,t1.VALIDADE_DIGITACAO			as VALIDADE_DIGITACAO	
		,cast(t1.VALIDADE as date)		as VALIDADE				
		,t1.FABRICACAO_DIGITACAO		as	FABRICACAO_DIGITACAO	
		,cast(t1.FABRICACAO as date)	as FABRICACAO
		,@AtualVersionID					as versao_ct
		,ct.SYS_CHANGE_OPERATION		as operation

from CHANGETABLE(CHANGES dbo.PRODUTOS_LOTE_VALIDADE, @StartVersionID) ct
inner join PBS_NAZARIA_DADOS.dbo.PRODUTOS_LOTE_VALIDADE t1
	on t1.LOTE_VALIDADE = ct.LOTE_VALIDADE

where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
