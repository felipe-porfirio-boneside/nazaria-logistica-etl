CREATE PROCEDURE [dbo].[BONESIDE_ETL_ROTA] 
as   
begin 


select distinct t1.Rota
		,t1.regiao as descricao
		,1	as EMPRESA_USUARIA
		,t1.Setor

from [dbo].[rota_setor_alessandro] t1
left join tblrota_setor t2
	on t2.ROTA = t1.rota

where t2.rota is null

end
