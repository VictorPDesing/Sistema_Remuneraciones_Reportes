USE [A&SG_DataMart];
GO

SET NOCOUNT ON;

IF DB_NAME() <> N'A&SG_DataMart'
	THROW 50300, N'Conecte la consulta con A&SG_DataMart. Si no existe, ejecute 02_Creacion_Data_Mart.sql.', 1;

IF DB_ID(N'A&SG_OLTP') IS NULL
	THROW 50301, N'Falta A&SG_OLTP. Ejecute primero 01_Estructura_y_Datos.sql.', 1;

IF OBJECT_ID(N'dbo.fac_rendimiento_kpis', N'U') IS NULL
	THROW 50302, N'Faltan las tablas del Data Mart. Revise 02_Creacion_Data_Mart.sql.', 1;

IF OBJECT_ID(N'dbo.usp_cargar_rendimiento', N'P') IS NULL
	THROW 50303, N'Falta el procedimiento. Ejecute 02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql.', 1;

DECLARE @fecha_desde date = '20260701';
DECLARE @fecha_hasta date = '20260930';

IF NOT EXISTS (
	SELECT 1 FROM [A&SG_OLTP].dbo.Asistencia
	WHERE Fecha_Calculada BETWEEN @fecha_desde AND @fecha_hasta
)
	THROW 50304, N'El origen no tiene asistencias del trimestre. Revise el servidor y ejecute el generador del origen.', 1;

IF NOT EXISTS (
	SELECT 1 FROM [A&SG_OLTP].dbo.Tareas
	WHERE Fecha BETWEEN @fecha_desde AND @fecha_hasta
)
	THROW 50305, N'El origen no tiene tareas del trimestre. Revise el servidor y ejecute el generador del origen.', 1;

EXEC dbo.usp_cargar_rendimiento @fecha_desde, @fecha_hasta;

SELECT @@SERVERNAME AS servidor, DB_NAME() AS base_actual;

SELECT COUNT(*) AS filas_hechos,
	SUM(total_asistencias) AS total_asistencias,
	SUM(total_tareas) AS total_tareas
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN @fecha_desde AND @fecha_hasta;
GO
