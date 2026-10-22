USE [A&SG_DataMart];
GO

CREATE OR ALTER PROCEDURE dbo.usp_cargar_rendimiento
	@fecha_desde date = '20260701',
	@fecha_hasta date = '20260930'
AS
BEGIN
	SET NOCOUNT ON;

	IF @fecha_desde IS NULL OR @fecha_hasta IS NULL OR @fecha_desde > @fecha_hasta
		THROW 50100, N'El intervalo de fechas no es válido.', 1;
	IF DATEDIFF(day, @fecha_desde, @fecha_hasta) > 3660
		THROW 50101, N'La carga admite hasta diez años por ejecución.', 1;
	IF @@TRANCOUNT > 0
		THROW 50103, N'Ejecute el procedimiento sin una transacción externa.', 1;

	DECLARE @id_carga bigint;
	DECLARE @fecha date, @dia_semana int;
	DECLARE @asistencias_extraidas int, @tareas_extraidas int, @registros_rechazados int, @filas_cargadas int;

	INSERT INTO dbo.bitacora_etl (fecha_desde, fecha_hasta, estado)
	VALUES (@fecha_desde, @fecha_hasta, N'En ejecución');
	SET @id_carga = SCOPE_IDENTITY();

	BEGIN TRY
		BEGIN TRANSACTION;

		SELECT t.ID_Trabajador AS id_trabajador_origen,
			LTRIM(RTRIM(t.Codigo_Trabajador)) AS codigo_trabajador,
			LTRIM(RTRIM(e.Nombre_Completo)) AS nombre_completo,
			LTRIM(RTRIM(t.Rol_Cargo)) AS cargo,
			CASE WHEN t.ID_Trabajador IN (2, 9, 11)
				THEN N'Practicante' ELSE N'Regular' END AS tipo_jornada,
			LTRIM(RTRIM(e.Estado)) AS estado
		INTO #trabajadores
		FROM [A&SG_OLTP].dbo.Trabajadores t
		JOIN [A&SG_OLTP].dbo.Empleados e ON e.ID_Empleado = t.ID_Empleado
		JOIN [A&SG_OLTP].dbo.Roles_Sistema r ON r.ID_Rol = t.ID_Rol;

		IF EXISTS (SELECT 1 FROM #trabajadores WHERE nombre_completo = N'' OR codigo_trabajador = N'')
			THROW 50105, N'Hay trabajadores sin nombre o código; corrija el origen.', 1;

		UPDATE d SET codigo_trabajador = t.codigo_trabajador, nombre_completo = t.nombre_completo,
			cargo = t.cargo, tipo_jornada = t.tipo_jornada, estado = t.estado
		FROM dbo.dim_trabajador d JOIN #trabajadores t ON t.id_trabajador_origen = d.id_trabajador_origen;
		INSERT INTO dbo.dim_trabajador (id_trabajador_origen, codigo_trabajador, nombre_completo, cargo, tipo_jornada, estado)
		SELECT t.id_trabajador_origen, t.codigo_trabajador, t.nombre_completo, t.cargo, t.tipo_jornada, t.estado
		FROM #trabajadores t
		WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_trabajador d WHERE d.id_trabajador_origen = t.id_trabajador_origen);

		UPDATE d SET nombre_proyecto = LTRIM(RTRIM(p.Nombre_Proyecto)), area_departamento = LTRIM(RTRIM(p.Area_Departamento))
		FROM dbo.dim_proyecto d JOIN [A&SG_OLTP].dbo.Proyectos p ON p.ID_Proyecto = d.id_proyecto_origen;
		INSERT INTO dbo.dim_proyecto (id_proyecto_origen, nombre_proyecto, area_departamento)
		SELECT p.ID_Proyecto, LTRIM(RTRIM(p.Nombre_Proyecto)), LTRIM(RTRIM(p.Area_Departamento))
		FROM [A&SG_OLTP].dbo.Proyectos p
		WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_proyecto d WHERE d.id_proyecto_origen = p.ID_Proyecto);

		UPDATE d SET nombre_completo = LTRIM(RTRIM(e.Nombre_Completo)), codigo_administrador = LTRIM(RTRIM(a.Codigo_Administrador))
		FROM dbo.dim_administrador d
		JOIN [A&SG_OLTP].dbo.Administrador a ON a.ID_Administrador = d.id_administrador_origen
		JOIN [A&SG_OLTP].dbo.Empleados e ON e.ID_Empleado = a.ID_Empleado;
		INSERT INTO dbo.dim_administrador (id_administrador_origen, nombre_completo, codigo_administrador)
		SELECT a.ID_Administrador, LTRIM(RTRIM(e.Nombre_Completo)), LTRIM(RTRIM(a.Codigo_Administrador))
		FROM [A&SG_OLTP].dbo.Administrador a
		JOIN [A&SG_OLTP].dbo.Empleados e ON e.ID_Empleado = a.ID_Empleado
		WHERE NOT EXISTS (SELECT 1 FROM dbo.dim_administrador d WHERE d.id_administrador_origen = a.ID_Administrador);

		SET @fecha = @fecha_desde;
		WHILE @fecha <= @fecha_hasta
		BEGIN
			SET @dia_semana = ((DATEDIFF(day, '19000101', @fecha) % 7 + 7) % 7) + 1;
			IF NOT EXISTS (SELECT 1 FROM dbo.dim_tiempo WHERE fecha = @fecha)
				INSERT INTO dbo.dim_tiempo (id_tiempo, fecha, anio, trimestre, mes, nombre_mes, dia, dia_semana, nombre_dia)
				VALUES (
					YEAR(@fecha) * 10000 + MONTH(@fecha) * 100 + DAY(@fecha), @fecha,
					YEAR(@fecha), DATEPART(quarter, @fecha), MONTH(@fecha),
					CASE MONTH(@fecha)
						WHEN 1 THEN N'Enero' WHEN 2 THEN N'Febrero' WHEN 3 THEN N'Marzo'
						WHEN 4 THEN N'Abril' WHEN 5 THEN N'Mayo' WHEN 6 THEN N'Junio'
						WHEN 7 THEN N'Julio' WHEN 8 THEN N'Agosto' WHEN 9 THEN N'Septiembre'
						WHEN 10 THEN N'Octubre' WHEN 11 THEN N'Noviembre' WHEN 12 THEN N'Diciembre' END,
					DAY(@fecha), @dia_semana,
					CASE @dia_semana
						WHEN 1 THEN N'Lunes' WHEN 2 THEN N'Martes' WHEN 3 THEN N'Miércoles'
						WHEN 4 THEN N'Jueves' WHEN 5 THEN N'Viernes' WHEN 6 THEN N'Sábado' WHEN 7 THEN N'Domingo' END
				);
			SET @fecha = DATEADD(day, 1, @fecha);
		END;

		SELECT a.ID_Asistencia AS id_asistencia, a.ID_Trabajador AS id_trabajador_origen,
			a.Fecha_Entrada AS fecha_entrada, a.Fecha_Salida AS fecha_salida,
			CONVERT(date, a.Fecha_Entrada) AS fecha,
			CASE WHEN t.id_trabajador_origen IS NULL THEN N'Trabajador sin correspondencia'
				WHEN a.Fecha_Salida < a.Fecha_Entrada THEN N'Salida anterior a la entrada'
				ELSE NULL END AS motivo
		INTO #asistencias
		FROM [A&SG_OLTP].dbo.Asistencia a
		LEFT JOIN #trabajadores t ON t.id_trabajador_origen = a.ID_Trabajador
		WHERE CONVERT(date, a.Fecha_Entrada) BETWEEN @fecha_desde AND @fecha_hasta;
		SET @asistencias_extraidas = @@ROWCOUNT;

		SELECT ta.ID_Tarea AS id_tarea, ta.ID_Trabajador AS id_trabajador_origen,
			ta.ID_Proyecto AS id_proyecto_origen, ta.ID_Administrador_Asignador AS id_administrador_origen,
			ta.Fecha AS fecha, UPPER(LTRIM(RTRIM(ta.Estado_Tarea))) AS estado_tarea,
			NULLIF(LTRIM(RTRIM(ta.Observaciones)), N'') AS observaciones,
			CASE WHEN t.id_trabajador_origen IS NULL THEN N'Trabajador sin correspondencia'
				WHEN p.ID_Proyecto IS NULL THEN N'Proyecto sin correspondencia'
				WHEN e.ID_Empleado IS NULL THEN N'Administrador sin correspondencia'
				WHEN UPPER(LTRIM(RTRIM(ta.Estado_Tarea))) NOT IN (N'COMPLETADA', N'EN PROGRESO', N'ASIGNADA')
					THEN N'Estado de tarea desconocido'
				WHEN ta.Fecha_Inicio IS NOT NULL AND CONVERT(date, ta.Fecha_Inicio) < ta.Fecha
					THEN N'Inicio anterior a la asignación'
				WHEN ta.Fecha_Entrega IS NOT NULL AND (ta.Fecha_Inicio IS NULL OR ta.Fecha_Entrega < ta.Fecha_Inicio)
					THEN N'Entrega sin inicio válido'
				WHEN UPPER(LTRIM(RTRIM(ta.Estado_Tarea))) = N'COMPLETADA' AND ta.Fecha_Entrega IS NULL
					THEN N'Tarea completada sin fecha de entrega'
				WHEN UPPER(LTRIM(RTRIM(ta.Estado_Tarea))) <> N'COMPLETADA' AND ta.Fecha_Entrega IS NOT NULL
					THEN N'Tarea pendiente con fecha de entrega'
				ELSE NULL END AS motivo
		INTO #tareas
		FROM [A&SG_OLTP].dbo.Tareas ta
		LEFT JOIN #trabajadores t ON t.id_trabajador_origen = ta.ID_Trabajador
		LEFT JOIN [A&SG_OLTP].dbo.Proyectos p ON p.ID_Proyecto = ta.ID_Proyecto
		LEFT JOIN [A&SG_OLTP].dbo.Administrador a ON a.ID_Administrador = ta.ID_Administrador_Asignador
		LEFT JOIN [A&SG_OLTP].dbo.Empleados e ON e.ID_Empleado = a.ID_Empleado
		WHERE ta.Fecha BETWEEN @fecha_desde AND @fecha_hasta;
		SET @tareas_extraidas = @@ROWCOUNT;

		INSERT INTO dbo.rechazos_etl (id_carga, tabla_origen, id_registro_origen, motivo)
		SELECT @id_carga, N'Asistencia', id_asistencia, motivo FROM #asistencias WHERE motivo IS NOT NULL
		UNION ALL
		SELECT @id_carga, N'Tareas', id_tarea, motivo FROM #tareas WHERE motivo IS NOT NULL;
		SET @registros_rechazados = @@ROWCOUNT;

		DELETE f FROM dbo.fac_rendimiento_kpis f
		JOIN dbo.dim_tiempo d ON d.id_tiempo = f.id_tiempo
		WHERE d.fecha BETWEEN @fecha_desde AND @fecha_hasta;

		-- La asistencia no tiene proyecto ni administrador en el origen.
		;WITH jornadas AS (
			SELECT t.id_trabajador_origen, d.fecha, 1 AS esperada
			FROM #trabajadores t CROSS JOIN dbo.dim_tiempo d
			WHERE d.fecha BETWEEN @fecha_desde AND @fecha_hasta
				AND ((t.tipo_jornada = N'Regular' AND d.dia_semana BETWEEN 1 AND 5)
					OR (t.tipo_jornada = N'Practicante' AND d.dia_semana IN (1, 3, 5)))
		), fechas_asistencia AS (
			SELECT id_trabajador_origen, fecha FROM jornadas
			UNION
			SELECT id_trabajador_origen, fecha FROM #asistencias WHERE motivo IS NULL
		)
		INSERT INTO dbo.fac_rendimiento_kpis (
			id_trabajador, id_tiempo, id_proyecto, id_administrador, jornadas_esperadas,
			total_asistencias, asistencias_a_tiempo, tardanzas, minutos_tardanza,
			horas_permanencia, salidas_pendientes, id_carga
		)
		SELECT t.id_trabajador, d.id_tiempo, 0, 0, ISNULL(j.esperada, 0),
			CASE WHEN a.id_asistencia IS NULL THEN 0 ELSE 1 END,
			CASE WHEN CONVERT(time(0), a.fecha_entrada) < '09:41:00' THEN 1 ELSE 0 END,
			CASE WHEN CONVERT(time(0), a.fecha_entrada) >= '09:41:00' THEN 1 ELSE 0 END,
			CASE WHEN CONVERT(time(0), a.fecha_entrada) >= '09:41:00'
				THEN (DATEDIFF(second, DATEADD(minute, 580, CONVERT(datetime2(0), a.fecha)), a.fecha_entrada) + 59) / 60 ELSE 0 END,
			ISNULL(CONVERT(decimal(10,2), DATEDIFF(second, a.fecha_entrada, a.fecha_salida) / 3600.0), 0),
			CASE WHEN a.id_asistencia IS NOT NULL AND a.fecha_salida IS NULL THEN 1 ELSE 0 END, @id_carga
		FROM fechas_asistencia fa
		JOIN dbo.dim_trabajador t ON t.id_trabajador_origen = fa.id_trabajador_origen
		JOIN dbo.dim_tiempo d ON d.fecha = fa.fecha
		LEFT JOIN jornadas j ON j.id_trabajador_origen = fa.id_trabajador_origen AND j.fecha = fa.fecha
		LEFT JOIN #asistencias a ON a.id_trabajador_origen = fa.id_trabajador_origen AND a.fecha = fa.fecha AND a.motivo IS NULL;
		SET @filas_cargadas = @@ROWCOUNT;

		INSERT INTO dbo.fac_rendimiento_kpis (
			id_trabajador, id_tiempo, id_proyecto, id_administrador, total_tareas,
			tareas_completadas, tareas_sin_observaciones, tareas_fuera_plazo,
			tareas_con_correcciones, tareas_en_progreso, tareas_asignadas, id_carga
		)
		SELECT t.id_trabajador, d.id_tiempo, p.id_proyecto, a.id_administrador, COUNT(*),
			SUM(CASE WHEN ta.estado_tarea = N'COMPLETADA' THEN 1 ELSE 0 END),
			SUM(CASE WHEN ta.estado_tarea = N'COMPLETADA' AND ta.observaciones IS NULL THEN 1 ELSE 0 END),
			SUM(CASE WHEN CHARINDEX(N'FUERA DE PLAZO', UPPER(ta.observaciones)) > 0 THEN 1 ELSE 0 END),
			SUM(CASE WHEN ta.observaciones IS NOT NULL AND CHARINDEX(N'FUERA DE PLAZO', UPPER(ta.observaciones)) = 0 THEN 1 ELSE 0 END),
			SUM(CASE WHEN ta.estado_tarea = N'EN PROGRESO' THEN 1 ELSE 0 END),
			SUM(CASE WHEN ta.estado_tarea = N'ASIGNADA' THEN 1 ELSE 0 END), @id_carga
		FROM #tareas ta
		JOIN dbo.dim_trabajador t ON t.id_trabajador_origen = ta.id_trabajador_origen
		JOIN dbo.dim_tiempo d ON d.fecha = ta.fecha
		JOIN dbo.dim_proyecto p ON p.id_proyecto_origen = ta.id_proyecto_origen
		JOIN dbo.dim_administrador a ON a.id_administrador_origen = ta.id_administrador_origen
		WHERE ta.motivo IS NULL
		GROUP BY t.id_trabajador, d.id_tiempo, p.id_proyecto, a.id_administrador;
		SET @filas_cargadas += @@ROWCOUNT;

		UPDATE dbo.bitacora_etl SET fin = GETDATE(),
			estado = CASE WHEN @registros_rechazados = 0 THEN N'Completada' ELSE N'Con rechazos' END,
			asistencias_extraidas = @asistencias_extraidas, tareas_extraidas = @tareas_extraidas,
			registros_rechazados = @registros_rechazados, filas_cargadas = @filas_cargadas
		WHERE id_carga = @id_carga;
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		UPDATE dbo.bitacora_etl SET fin = GETDATE(), estado = N'Fallida', mensaje = ERROR_MESSAGE()
		WHERE id_carga = @id_carga;
		THROW;
	END CATCH;

	SELECT * FROM dbo.bitacora_etl WHERE id_carga = @id_carga;
END;
GO
