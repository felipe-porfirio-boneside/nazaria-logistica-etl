CREATE PROCEDURE [dbo].[BONESIDE_ETL_EMPRESAS_USUARIAS] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.EMPRESAS_USUARIAS')

select t1.EMPRESA_USUARIA
		,t1.NOME
		,t1.NOME_FANTASIA
		,t1.ENTIDADE
		,@AtualVersionID	as versao_ct
		,ct.SYS_CHANGE_OPERATION as operation

from CHANGETABLE(CHANGES dbo.EMPRESAS_USUARIAS, @StartVersionID) ct 
inner join PBS_NAZARIA_DADOS.dbo.EMPRESAS_USUARIAS t1
	on t1.EMPRESA_USUARIA = ct.EMPRESA_USUARIA

where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
