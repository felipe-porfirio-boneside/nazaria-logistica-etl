CREATE PROCEDURE [dbo].[BONESIDE_ETL_PRODUTOS_LOCAIS] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.PRODUTOS_LOCAIS')

select A.OBJETO_CONTROLE														AS OBJETO_CONTROLE
		,A.PRODUTO																	AS PRODUTO                      
      ,I.DESCRICAO																AS CLASSIFICACAO_PRODUTO_ESTOQUE_DES
		,D.DESCRICAO																AS LOCALIZADOR
		,D.CORREDOR																	AS CORREDOR
		,iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',
			  left(D.CORREDOR, 2),
			  left(D.CORREDOR, 1))												AS PREFIXO
		,TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int)		AS NUMERO	
		, case when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'M'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 47 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 56 then 'Baixo Giro'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'M'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 57 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 67 then 'Médio Giro'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'M'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 68 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 83 then 'Alto Giro'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'F'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 88                then 'Fraldas'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'PE' 
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 2 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 5   then 'Perfumaria 3'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'PS' 
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 1                 then 'Psicotrópico'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'T'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 1 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 2   then 'Termolábil'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'G'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 1                 then 'Geladeira'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'A'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 3                 then 'Alimento 3'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'P'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 72                then 'Kenvue'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'P'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 74                then 'Nivea'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'P'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 82 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 84 then 'Unilever'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'P'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 64 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 69 then 'Diversos1'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'P'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) >= 70 and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) <= 71 then 'Diversos2'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'P'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) in(75,86,90,91)		then 'Diversos3'
				 when iif(left(D.CORREDOR, 2) = 'PE' or left(D.CORREDOR, 2) = 'PS',left(D.CORREDOR, 2),left(D.CORREDOR, 1)) = 'A'  
				  and TRY_CAST(dbo.fnt_prefixo_corredor(D.CORREDOR) as int) = 88						then 'Alimento'
				  else 'Não definido'
		end																			AS SETOR_LOGISTICA
	  ,D.LOCALIZADOR																AS CODIGO_LOCALIZADOR	
	  ,F.DESCRICAO																	AS TIPO_LOCALIZADOR
	  ,x.EMBALAGEM_INDUSTRIA
	  ,@AtualVersionID															as versao_ct
	  ,ct.SYS_CHANGE_OPERATION													as operation
		
from CHANGETABLE(CHANGES dbo.PRODUTOS_LOCAIS, @StartVersionID) ct
inner join PBS_NAZARIA_DADOS.dbo.PRODUTOS_LOCAIS					 A with(nolock) 
	on a.PRODUTO_LOCAL = ct.PRODUTO_LOCAL
join PBS_NAZARIA_DADOS.dbo.PRODUTOS										 X with(nolock) 
	on X.PRODUTO = A.PRODUTO                                         
join PBS_NAZARIA_DADOS.dbo.CADASTROS_LOCALIZADORES					 D with(nolock) 
	on D.LOCALIZADOR = A.CODIGO_LOCALIZADOR           
left join PBS_NAZARIA_DADOS.dbo.CLASSIFICACOES_PRODUTOS_ESTOQUE I with(nolock) 
	on I.CLASSIFICACAO_PRODUTO_ESTOQUE = X.CLASSIFICACAO_PRODUTO_ESTOQUE
left join PBS_NAZARIA_DADOS.dbo.TIPOS_LOCALIZADORES F
	on f.TIPO_LOCALIZADOR = D.TIPO_LOCALIZADOR

where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID

end
 
