USE [A&SG_DataMart];
GO

SET NOCOUNT ON;

IF DB_NAME() <> N'A&SG_DataMart'
	THROW 50310, N'Seleccione A&SG_DataMart en esta instancia de SQL Server.', 1;

SELECT @@SERVERNAME AS servidor, DB_NAME() AS base_actual;

SELECT N'Asistencias OLTP' AS concepto, COUNT(*) AS cantidad
FROM [A&SG_OLTP].dbo.Asistencia
WHERE Fecha_Calculada BETWEEN '20260701' AND '20260930'
UNION ALL
SELECT N'Tareas OLTP', COUNT(*)
FROM [A&SG_OLTP].dbo.Tareas
WHERE Fecha BETWEEN '20260701' AND '20260930'
UNION ALL
SELECT N'Trabajadores del Data Mart', COUNT(*) FROM dbo.dim_trabajador
UNION ALL
SELECT N'Filas de hechos del trimestre', COUNT(*)
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930';

IF NOT EXISTS (SELECT 1 FROM dbo.bitacora_etl)
	PRINT N'No hay cargas registradas. Ejecute 04_Cargar_Simulacion.sql después de instalar el procedimiento.';

SELECT TOP (5) id_carga, fecha_desde, fecha_hasta, inicio, fin, estado,
	asistencias_extraidas, tareas_extraidas, registros_rechazados, filas_cargadas, mensaje
FROM dbo.bitacora_etl
ORDER BY id_carga DESC;

SELECT d.anio, d.mes,
	SUM(f.total_asistencias) AS asistencias,
	SUM(f.total_tareas) AS tareas
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930'
GROUP BY d.anio, d.mes
ORDER BY d.anio, d.mes;

SELECT id_trabajador, id_tiempo, id_proyecto, id_administrador, COUNT(*) AS repeticiones
FROM dbo.fac_rendimiento_kpis
GROUP BY id_trabajador, id_tiempo, id_proyecto, id_administrador
HAVING COUNT(*) > 1;

SELECT nombre_completo, mes, total_asistencias, total_tareas, tpa, ict, tdt, iep
FROM dbo.vw_indicadores_mensuales
WHERE anio = 2026 AND mes BETWEEN 7 AND 9
ORDER BY id_trabajador_origen, mes;

;WITH resumen AS (
	SELECT SUM(f.total_asistencias) AS asistencias,
		SUM(f.asistencias_a_tiempo) AS puntuales,
		SUM(f.total_tareas) AS tareas,
		SUM(f.tareas_sin_observaciones) AS sin_observaciones,
		SUM(f.tareas_fuera_plazo) AS fuera_plazo
	FROM dbo.fac_rendimiento_kpis f
	JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
	WHERE d.fecha BETWEEN '20260701' AND '20260930'
), tasas AS (
	SELECT asistencias, tareas,
		100.0 * puntuales / NULLIF(asistencias, 0) AS tpa,
		100.0 * sin_observaciones / NULLIF(tareas, 0) AS ict,
		100.0 * fuera_plazo / NULLIF(tareas, 0) AS tdt
	FROM resumen
)
SELECT asistencias, tareas,
	CONVERT(decimal(6,2), tpa) AS tpa,
	CONVERT(decimal(6,2), ict) AS ict,
	CONVERT(decimal(6,2), tdt) AS tdt,
	CONVERT(decimal(6,2), tpa * 0.30 + ict * 0.50 + (100 - tdt) * 0.20) AS iep
FROM tasas;

SELECT N'Asistencia y calendario' AS tipo_fila, COUNT(*) AS filas
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930'
	AND f.id_proyecto = 0 AND f.id_administrador = 0
UNION ALL
SELECT N'Tareas', COUNT(*)
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930'
	AND f.total_tareas > 0;
GO
