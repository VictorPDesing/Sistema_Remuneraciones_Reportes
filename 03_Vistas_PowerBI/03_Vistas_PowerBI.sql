USE [A&SG_DataMart];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW dbo.vw_dim_trabajador AS
SELECT id_trabajador, id_trabajador_origen, codigo_trabajador, nombre_completo, cargo, tipo_jornada, estado
FROM dbo.dim_trabajador;
GO

CREATE OR ALTER VIEW dbo.vw_dim_tiempo AS
SELECT id_tiempo, fecha, anio, trimestre, mes, nombre_mes, dia, dia_semana, nombre_dia
FROM dbo.dim_tiempo;
GO

CREATE OR ALTER VIEW dbo.vw_dim_proyecto AS
SELECT id_proyecto, id_proyecto_origen, nombre_proyecto, area_departamento
FROM dbo.dim_proyecto;
GO

CREATE OR ALTER VIEW dbo.vw_dim_administrador AS
SELECT id_administrador, id_administrador_origen, nombre_completo, codigo_administrador
FROM dbo.dim_administrador;
GO

CREATE OR ALTER VIEW dbo.vw_rendimiento_kpis AS
SELECT id_trabajador, id_tiempo, id_proyecto, id_administrador,
	jornadas_esperadas, total_asistencias, asistencias_a_tiempo, tardanzas, minutos_tardanza,
	horas_permanencia, salidas_pendientes, total_tareas, tareas_completadas,
	tareas_sin_observaciones, tareas_fuera_plazo, tareas_con_correcciones, tareas_en_progreso, tareas_asignadas,
	CASE WHEN jornadas_esperadas = 1 AND total_asistencias = 0 THEN 1 ELSE 0 END AS jornadas_sin_marca
FROM dbo.fac_rendimiento_kpis;
GO

CREATE OR ALTER VIEW dbo.vw_indicadores_mensuales AS
WITH resumen AS (
	SELECT t.id_trabajador_origen, t.nombre_completo, t.tipo_jornada, d.anio, d.mes, d.nombre_mes,
		SUM(f.jornadas_esperadas) AS jornadas_esperadas,
		SUM(f.total_asistencias) AS total_asistencias,
		SUM(f.asistencias_a_tiempo) AS asistencias_a_tiempo,
		SUM(f.tardanzas) AS tardanzas,
		SUM(f.minutos_tardanza) AS minutos_tardanza,
		SUM(f.horas_permanencia) AS horas_permanencia,
		SUM(f.salidas_pendientes) AS salidas_pendientes,
		SUM(f.jornadas_sin_marca) AS jornadas_sin_marca,
		SUM(f.total_tareas) AS total_tareas,
		SUM(f.tareas_completadas) AS tareas_completadas,
		SUM(f.tareas_sin_observaciones) AS tareas_sin_observaciones,
		SUM(f.tareas_fuera_plazo) AS tareas_fuera_plazo,
		SUM(f.tareas_con_correcciones) AS tareas_con_correcciones,
		SUM(f.tareas_en_progreso) AS tareas_en_progreso,
		SUM(f.tareas_asignadas) AS tareas_asignadas
	FROM dbo.vw_rendimiento_kpis f
	JOIN dbo.dim_trabajador t ON t.id_trabajador = f.id_trabajador
	JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
	GROUP BY t.id_trabajador_origen, t.nombre_completo, t.tipo_jornada, d.anio, d.mes, d.nombre_mes
), indicadores AS (
	SELECT *,
		100.0 * asistencias_a_tiempo / NULLIF(total_asistencias, 0) AS tpa,
		100.0 * tareas_sin_observaciones / NULLIF(total_tareas, 0) AS ict,
		100.0 * tareas_fuera_plazo / NULLIF(total_tareas, 0) AS tdt,
		100.0 * tareas_completadas / NULLIF(total_tareas, 0) AS tasa_finalizacion,
		100.0 * tareas_con_correcciones / NULLIF(total_tareas, 0) AS tasa_correccion
	FROM resumen
)
SELECT id_trabajador_origen, nombre_completo, tipo_jornada, anio, mes, nombre_mes,
	jornadas_esperadas, total_asistencias, asistencias_a_tiempo, tardanzas, minutos_tardanza,
	horas_permanencia, salidas_pendientes, jornadas_sin_marca,
	total_tareas, tareas_completadas, tareas_sin_observaciones, tareas_fuera_plazo,
	tareas_con_correcciones, tareas_en_progreso, tareas_asignadas,
	CONVERT(decimal(6,2), tpa) AS tpa,
	CONVERT(decimal(6,2), ict) AS ict,
	CONVERT(decimal(6,2), tdt) AS tdt,
	CONVERT(decimal(6,2), tpa * 0.30 + ict * 0.50 + (100 - tdt) * 0.20) AS iep,
	CONVERT(decimal(6,2), tasa_finalizacion) AS tasa_finalizacion,
	CONVERT(decimal(6,2), tasa_correccion) AS tasa_correccion
FROM indicadores;
GO

CREATE OR ALTER VIEW dbo.vw_calidad_cargas AS
SELECT id_carga, fecha_desde, fecha_hasta, inicio, fin, estado,
	asistencias_extraidas, tareas_extraidas, registros_rechazados, filas_cargadas, mensaje,
	DATEDIFF(second, inicio, fin) AS duracion_segundos
FROM dbo.bitacora_etl;
GO
