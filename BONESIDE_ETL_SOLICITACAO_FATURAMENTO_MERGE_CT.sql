CREATE PROCEDURE [dbo].[BONESIDE_ETL_SOLICITACAO_FATURAMENTO_MERGE_CT] 
(
	@AtualVersionID bigint
)
as     
begin

merge PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version as target
using (
			select s.name + '.' + t.name				  as Table_Name
					,@AtualVersionID						  as [Version_ID] -- Get the change tracking version ID

			from PBS_NAZARIA_DADOS.sys.change_tracking_tables tr
			inner join PBS_NAZARIA_DADOS.sys.tables t 
				on t.object_id = tr.object_id
			inner join PBS_NAZARIA_DADOS.sys.schemas s 
				on s.schema_id = t.schema_id
			where t.name = 'SOLICITACOES_FATURAMENTOS'
		) AS source
	ON target.Table_Name = source.Table_Name

WHEN MATCHED -- Exists? Then update

THEN UPDATE SET target.Change_Tracking_Version = source.Version_ID

WHEN NOT MATCHED -- No match? Insert
THEN INSERT 
(	
	 Table_Name
	,Change_Tracking_Version
)
VALUES 
(
	 source.Table_Name
	,source.Version_ID
);

end

