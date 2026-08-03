CREATE PROCEDURE [dbo].[BONESIDE_ETL_WMS_CHECKOUT] 
as   
begin 


declare @StartVersionID bigint
declare @AtualVersionID bigint = CHANGE_TRACKING_CURRENT_VERSION()

SET @StartVersionID = (select Change_Tracking_Version from PBS_NAZARIA_DADOS.dbo.tblChange_Tracking_Version where Table_Name = 'dbo.WMS_CHECKOUT')

select A.CHECKOUT																	AS CHECKOUT					
		,A.USUARIO_LOGADO															AS USUARIO_LOGADO
		,A.EMPRESA																	AS EMPRESA
		,A.EMBALAGEM_SEPARACAO													AS EMBALAGEM_SEPARACAO
		,sum(C.QUANTIDADE_UNIT)													AS CONFERIDO
		,A.VOLUMES																	AS VOLUMES
		,cast(min(A.DATA_HORA) as date)										AS DATA_INI_SEPARACAO
		,cast(min(A.DATA_HORA) as time)										AS HORA_INI_SEPARACAO
		,cast(max(A.DATA_HORA_CONFIRMACAO) as date)						AS DATA_FIM_SEPARACAO
		,cast(max(A.DATA_HORA_CONFIRMACAO) as time)						AS HORA_FIM_SEPARACAO
		,concat(format(max(A.DATA_HORA_CONFIRMACAO),'HH'),'h')		AS HORA_INTERVALO
		,B.ESTOQUE_TRANSFERENCIA												AS ESTOQUE_TRANSFERENCIA
		,@AtualVersionID															AS versao_ct
		,ct.SYS_CHANGE_OPERATION												AS operation

from CHANGETABLE(CHANGES dbo.WMS_CHECKOUT, @StartVersionID) ct 
inner join PBS_NAZARIA_DADOS.dbo.WMS_CHECKOUT					A WITH(NOLOCK)
	on a.CHECKOUT = ct.CHECKOUT
inner join PBS_NAZARIA_DADOS.dbo.WMS_CHECKOUT_RESUMO			C WITH(NOLOCK) 
	on C.CHECKOUT = A.CHECKOUT
inner join PBS_NAZARIA_DADOS.dbo.ESTOQUE_TRANSFERENCIAS		B WITH(NOLOCK) 
	on B.ESTOQUE_TRANSFERENCIA = C.ESTOQUE_TRANSFERENCIA

where (SELECT MAX(v) FROM (VALUES(ct.SYS_CHANGE_VERSION), (ct.SYS_CHANGE_CREATION_VERSION)) AS VALUE(v)) <= @AtualVersionID
                            
group by A.CHECKOUT					
		  ,B.ESTOQUE_TRANSFERENCIA
		  ,A.USUARIO_LOGADO
		  ,A.EMPRESA
		  ,A.EMBALAGEM_SEPARACAO
		  ,A.VOLUMES
		  ,ct.SYS_CHANGE_OPERATION

end
