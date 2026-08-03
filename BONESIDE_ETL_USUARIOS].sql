CREATE PROCEDURE [dbo].[BONESIDE_ETL_USUARIOS] 
as   
begin

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.USUARIOS')

select t1.US
UARIO
		,t1.NOME
		,@AtualVersionID  as versao_ct
		,ct.SYS_CHANGE_OPERATION  as operation

from CHANGETABLE(CHANGES dbo.USUARIOS, @StartVersionID) ct 
inner join PBS_NAZARIA_DADOS.dbo.USUARIOS t1
	on t1.USUARIO = ct.USUARIO

where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
