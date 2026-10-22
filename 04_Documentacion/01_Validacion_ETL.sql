USE [A&SG_DataMart];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

EXEC dbo.usp_cargar_rendimiento @fecha_desde = '20260701', @fecha_hasta = '20260930';
GO

IF OBJECT_ID(N'tempdb..#primera_carga') IS NOT NULL DROP TABLE #primera_carga;
IF OBJECT_ID(N'tempdb..#conciliacion_asistencias') IS NOT NULL DROP TABLE #conciliacion_asistencias;
IF OBJECT_ID(N'tempdb..#conciliacion_tareas') IS NOT NULL DROP TABLE #conciliacion_tareas;
SELECT * INTO #primera_carga FROM dbo.vw_rendimiento_kpis;
GO

EXEC dbo.usp_cargar_rendimiento @fecha_desde = '20260701', @fecha_hasta = '20260930';
GO

IF EXISTS (SELECT * FROM #primera_carga EXCEPT SELECT * FROM dbo.vw_rendimiento_kpis)
	OR EXISTS (SELECT * FROM dbo.vw_rendimiento_kpis EXCEPT SELECT * FROM #primera_carga)
	THROW 50200, N'La segunda ejecución cambió los indicadores sin cambios en el origen.', 1;

IF (SELECT COUNT(*) FROM dbo.dim_trabajador) <> 10
	THROW 50201, N'Se esperaban diez trabajadores.', 1;

IF EXISTS (
	SELECT id_trabajador, id_tiempo, id_proyecto, id_administrador
	FROM dbo.fac_rendimiento_kpis
	GROUP BY id_trabajador, id_tiempo, id_proyecto, id_administrador HAVING COUNT(*) > 1
)
	THROW 50202, N'Hay registros duplicados en el Data Mart.', 1;

IF EXISTS (
	SELECT 1 FROM dbo.bitacora_etl
	WHERE id_carga = (SELECT MAX(id_carga) FROM dbo.bitacora_etl)
		AND (estado <> N'Completada' OR registros_rechazados <> 0)
)
	THROW 50203, N'Revise los rechazos de la última carga antes de validar el conjunto inicial.', 1;

;WITH origen AS (
	SELECT MONTH(Fecha_Calculada) AS mes, COUNT(*) AS total
	FROM [A&SG_OLTP].dbo.Asistencia
	WHERE Fecha_Calculada BETWEEN '20260701' AND '20260930'
	GROUP BY MONTH(Fecha_Calculada)
), destino AS (
	SELECT d.mes, SUM(f.total_asistencias) AS total
	FROM dbo.fac_rendimiento_kpis f JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
	WHERE d.fecha BETWEEN '20260701' AND '20260930'
	GROUP BY d.mes
)
SELECT COALESCE(o.mes, d.mes) AS mes, o.total AS asistencias_origen,
	d.total AS asistencias_destino, COALESCE(o.total, 0) - COALESCE(d.total, 0) AS diferencia
INTO #conciliacion_asistencias
FROM origen o FULL JOIN destino d ON d.mes = o.mes;

IF EXISTS (SELECT 1 FROM #conciliacion_asistencias WHERE diferencia <> 0)
	THROW 50204, N'Las asistencias del origen y el destino no coinciden.', 1;

;WITH origen AS (
	SELECT MONTH(Fecha) AS mes, COUNT(*) AS total
	FROM [A&SG_OLTP].dbo.Tareas WHERE Fecha BETWEEN '20260701' AND '20260930'
	GROUP BY MONTH(Fecha)
), destino AS (
	SELECT d.mes, SUM(f.total_tareas) AS total
	FROM dbo.fac_rendimiento_kpis f JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
	WHERE d.fecha BETWEEN '20260701' AND '20260930'
	GROUP BY d.mes
)
SELECT COALESCE(o.mes, d.mes) AS mes, o.total AS tareas_origen,
	d.total AS tareas_destino, COALESCE(o.total, 0) - COALESCE(d.total, 0) AS diferencia
INTO #conciliacion_tareas
FROM origen o FULL JOIN destino d ON d.mes = o.mes;

IF EXISTS (SELECT 1 FROM #conciliacion_tareas WHERE diferencia <> 0)
	THROW 50205, N'Las tareas del origen y el destino no coinciden.', 1;

IF (SELECT SUM(total_asistencias) FROM dbo.vw_rendimiento_kpis WHERE id_tiempo BETWEEN 20260701 AND 20260930) <> 582
	OR (SELECT SUM(total_tareas) FROM dbo.vw_rendimiento_kpis WHERE id_tiempo BETWEEN 20260701 AND 20260930) <> 582
	THROW 50206, N'El conjunto inicial debe tener 582 asistencias y 582 tareas.', 1;

IF (SELECT COUNT(*) FROM dbo.vw_indicadores_mensuales WHERE anio = 2026 AND mes BETWEEN 7 AND 9) <> 30
	THROW 50207, N'Se esperaban treinta resúmenes de trabajador y mes.', 1;

SELECT * FROM #conciliacion_asistencias ORDER BY mes;
SELECT * FROM #conciliacion_tareas ORDER BY mes;
SELECT * FROM dbo.vw_indicadores_mensuales WHERE anio = 2026 AND mes BETWEEN 7 AND 9 ORDER BY id_trabajador_origen, mes;
SELECT TOP (5) * FROM dbo.vw_calidad_cargas ORDER BY id_carga DESC;
SELECT N'Conciliación e idempotencia verificadas' AS resultado;

DROP TABLE #primera_carga;
DROP TABLE #conciliacion_asistencias;
DROP TABLE #conciliacion_tareas;
GO
