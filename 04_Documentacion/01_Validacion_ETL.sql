USE [A&SG_DataMart];
GO

EXEC dbo.usp_cargar_rendimiento '20260701', '20260930';

DROP TABLE IF EXISTS #primera_carga;
SELECT * INTO #primera_carga FROM dbo.vw_rendimiento_kpis;

EXEC dbo.usp_cargar_rendimiento '20260701', '20260930';

IF EXISTS (SELECT * FROM #primera_carga EXCEPT SELECT * FROM dbo.vw_rendimiento_kpis)
	OR EXISTS (SELECT * FROM dbo.vw_rendimiento_kpis EXCEPT SELECT * FROM #primera_carga)
	THROW 50200, N'Los datos cambiaron entre la primera y la segunda carga.', 1;

SELECT COUNT(*) AS total_trabajadores FROM dbo.dim_trabajador;

SELECT id_trabajador, id_tiempo, id_proyecto, id_administrador, COUNT(*) AS repeticiones
FROM dbo.fac_rendimiento_kpis
GROUP BY id_trabajador, id_tiempo, id_proyecto, id_administrador
HAVING COUNT(*) > 1;

SELECT d.mes,
	(SELECT COUNT(*) FROM [A&SG_OLTP].dbo.Asistencia a
	 WHERE a.Fecha_Calculada BETWEEN '20260701' AND '20260930'
		AND MONTH(a.Fecha_Calculada) = d.mes) AS asistencias_origen,
	SUM(f.total_asistencias) AS asistencias_destino,
	(SELECT COUNT(*) FROM [A&SG_OLTP].dbo.Tareas t
	 WHERE t.Fecha BETWEEN '20260701' AND '20260930'
		AND MONTH(t.Fecha) = d.mes) AS tareas_origen,
	SUM(f.total_tareas) AS tareas_destino
FROM dbo.fac_rendimiento_kpis f
JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
WHERE d.fecha BETWEEN '20260701' AND '20260930'
GROUP BY d.mes
ORDER BY d.mes;

SELECT nombre_completo, mes, total_asistencias, total_tareas, tpa, ict, tdt, iep
FROM dbo.vw_indicadores_mensuales
WHERE anio = 2026 AND mes BETWEEN 7 AND 9
ORDER BY id_trabajador_origen, mes;

SELECT TOP (2) * FROM dbo.vw_calidad_cargas ORDER BY id_carga DESC;

SELECT N'Las dos cargas conservan los mismos datos' AS resultado;
DROP TABLE #primera_carga;
GO
