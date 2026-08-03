CREATE PROCEDURE [dbo].[BONESIDE_ETL_SALDO_LOCALIZADOR] 
as   
begin 

declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.ESTOQUE_LANCAMENTOS_CACH
E_LV_LOCALIZADOR')

select B.CENTRO_ESTOQUE					as CENTRO_ESTOQUE
		,X.EMPRESA							as EMPRESA
		,B.PRODUTO							as PRODUTO
		,m.DESCRICAO						as LOCALIZADOR
		,m.CORREDOR							as CORREDOR
		,isnull(O.LOTE_VALIDADE,0)		as LOTE_VALIDADE
		,SUM(B.ESTOQUE_SALDO)			as ESTOQUE
		,a.EMBALAGEM_INDUSTRIA			as EMBALAGEM_INDUSTRIA
		,F.DESCRICAO						as TIPO_LOCALIZADOR
		,b.ID									as ID	
		,b.operation						as operation

from PBS_NAZARIA_DADOS.dbo.PRODUTOS A WITH(NOLOCK)
inner join (
					SELECT A.PRODUTO,
							 A.CENTRO_ESTOQUE,
							 CASE WHEN ISNULL(A.LOTE_VALIDADE,-1) > 0 
							      THEN A.LOTE_VALIDADE
							      ELSE -1
							 END                                      AS LOTE_VALIDADE,
							 CASE WHEN ISNULL(A.CODIGO_LOCALIZADOR,-1) > 0 
							      THEN A.CODIGO_LOCALIZADOR
							      ELSE -1
							 END                 AS CODIGO_LOCALIZADOR,
							 SUM(A.SALDO_AJUSTE) AS SALDO,
							 SUM(A.SALDO_AJUSTE) AS ESTOQUE_SALDO,
							 a.ID
							 ,@AtualVersionID		AS versao_ct
							 ,ct.SYS_CHANGE_OPERATION	as operation
					
					from CHANGETABLE(CHANGES dbo.ESTOQUE_LANCAMENTOS_CACHE_LV_LOCALIZADOR, @StartVersionID) ct 
					inner join 
					ESTOQUE_LANCAMENTOS_CACHE_LV_LOCALIZADOR A WITH(NOLOCK)
						on a.ID = ct.ID
					JOIN CENTROS_ESTOQUE     B WITH(NOLOCK) ON B.OBJETO_CONTROLE = A.CENTRO_ESTOQUE
					JOIN PARAMETROS_ESTOQUE  C WITH(NOLOCK) ON C.EMPRESA_USUARIA = B.EMPRESA
					                                       AND C.EMPRESA_WMS     = 'S'

					where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID
					    
					GROUP BY A.PRODUTO,
					         A.CENTRO_ESTOQUE,
					         CASE WHEN ISNULL(A.LOTE_VALIDADE,-1) > 0 
					              THEN A.LOTE_VALIDADE
					              ELSE -1
					         END,
					         CASE WHEN ISNULL(A.CODIGO_LOCALIZADOR,-1) > 0 
					              THEN A.CODIGO_LOCALIZADOR
					              ELSE -1
					         END,
								a.ID,
								ct.SYS_CHANGE_OPERATION

					having SUM(A.SALDO_AJUSTE) <> 0
			  ) B 
	on B.PRODUTO = A.PRODUTO
inner join PBS_NAZARIA_DADOS.dbo.CENTROS_ESTOQUE X WITH(NOLOCK) 
	on X.OBJETO_CONTROLE = B.CENTRO_ESTOQUE
left join PBS_NAZARIA_DADOS.dbo.CADASTROS_LOCALIZADORES M WITH(NOLOCK) 
	on M.LOCALIZADOR = B.CODIGO_LOCALIZADOR
left join PBS_NAZARIA_DADOS.dbo.PRODUTOS_LOTE_VALIDADE O WITH(NOLOCK) 
	on O.LOTE_VALIDADE = B.LOTE_VALIDADE   
left join PBS_NAZARIA_DADOS.dbo.TIPOS_LOCALIZADORES F
	on f.TIPO_LOCALIZADOR = M.TIPO_LOCALIZADOR
  
group by B.CENTRO_ESTOQUE
		  ,X.EMPRESA
		  ,B.PRODUTO
		  ,m.DESCRICAO
		  ,O.LOTE_VALIDADE		  
		  ,a.EMBALAGEM_INDUSTRIA
		  ,F.DESCRICAO
		  ,m.CORREDOR	
		  ,b.ID	
		  ,b.operation
		  
end
