USE [A&SG_DataMart];
GO
SET NOCOUNT ON;

SELECT CONVERT(nvarchar(30), SERVERPROPERTY('ProductVersion')) AS version_sql,
	CONVERT(nvarchar(100), SERVERPROPERTY('Edition')) AS edicion;

SELECT (SELECT COUNT(*) FROM dbo.dim_trabajador) AS trabajadores,
	(SELECT COUNT(*) FROM dbo.dim_tiempo) AS fechas,
	(SELECT COUNT(*) FROM dbo.dim_proyecto) AS proyectos_con_miembro_tecnico,
	(SELECT COUNT(*) FROM dbo.dim_administrador) AS administradores_con_miembro_tecnico,
	(SELECT COUNT(*) FROM dbo.fac_rendimiento_kpis) AS filas_hechos;

SELECT d.anio, d.mes, SUM(f.total_asistencias) AS asistencias, SUM(f.total_tareas) AS tareas
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930'
GROUP BY d.anio, d.mes ORDER BY d.anio, d.mes;

;WITH resumen AS (
	SELECT t.id_trabajador_origen, t.nombre_completo,
		SUM(f.total_asistencias) AS asistencias, SUM(f.asistencias_a_tiempo) AS a_tiempo,
		SUM(f.total_tareas) AS tareas, SUM(f.tareas_sin_observaciones) AS sin_observaciones,
		SUM(f.tareas_fuera_plazo) AS fuera_plazo
	FROM dbo.fac_rendimiento_kpis f
	JOIN dbo.dim_trabajador t ON t.id_trabajador = f.id_trabajador
	JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
	WHERE d.fecha BETWEEN '20260701' AND '20260930'
	GROUP BY t.id_trabajador_origen, t.nombre_completo
), indicadores AS (
	SELECT *, 100.0 * a_tiempo / NULLIF(asistencias, 0) AS tpa,
		100.0 * sin_observaciones / NULLIF(tareas, 0) AS ict,
		100.0 * fuera_plazo / NULLIF(tareas, 0) AS tdt
	FROM resumen
)
SELECT id_trabajador_origen, nombre_completo, asistencias, tareas,
	CONVERT(decimal(6,2), tpa) AS tpa, CONVERT(decimal(6,2), ict) AS ict,
	CONVERT(decimal(6,2), tdt) AS tdt,
	CONVERT(decimal(6,2), tpa * 0.30 + ict * 0.50 + (100 - tdt) * 0.20) AS iep
FROM indicadores ORDER BY id_trabajador_origen;

SELECT TOP (1) estado, asistencias_extraidas, tareas_extraidas, registros_rechazados, filas_cargadas
FROM dbo.bitacora_etl ORDER BY id_carga DESC;
GO
