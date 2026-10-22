USE [A&SG_DataMart];
GO

SELECT SERVERPROPERTY('ProductVersion') AS version_sql;

SELECT COUNT(*) AS trabajadores FROM dbo.dim_trabajador;
SELECT COUNT(*) AS fechas FROM dbo.dim_tiempo;
SELECT COUNT(*) AS filas_hechos FROM dbo.fac_rendimiento_kpis;

SELECT d.mes, SUM(f.total_asistencias) AS asistencias, SUM(f.total_tareas) AS tareas
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930'
GROUP BY d.mes ORDER BY d.mes;

SELECT nombre_completo, mes, tpa, ict, tdt, iep
FROM dbo.vw_indicadores_mensuales
WHERE anio = 2026 AND mes BETWEEN 7 AND 9
ORDER BY id_trabajador_origen, mes;

SELECT TOP (1) estado, asistencias_extraidas, tareas_extraidas, registros_rechazados, filas_cargadas
FROM dbo.bitacora_etl ORDER BY id_carga DESC;
GO
