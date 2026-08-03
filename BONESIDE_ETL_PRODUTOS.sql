CREATE PROCEDURE [dbo].[BONESIDE_ETL_PRODUTOS] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.PRODUTOS')

select A.PRODUTO			as PRODUTO
	   ,A.DESCRICAO	   as DESCRICAO
	   ,C.DESCRICAO	   as MARCA
	   ,e.DESCRICAO		as SECAO
		,@AtualVersionID	as versao_ct
		,ct.SYS_CHANGE_OPERATION	as operation

from CHANGETABLE(CHANGES dbo.PRODUTOS, @StartVersionID) ct
inner join PBS_NAZARIA_DADOS.dbo.PRODUTOS	A with(nolock)
	on a.PRODUTO = ct.produto
left join PBS_NAZARIA_DADOS.dbo.MARCAS	C with(nolock) 
	on C.MARCA = A.MARCA
left join PBS_NAZARIA_DADOS.dbo.SECOES_PRODUTOS E with(nolock)
	on e.SECAO_PRODUTO = A.SECAO_PRODUTO

where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
