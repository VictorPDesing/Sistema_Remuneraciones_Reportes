USE [master];
GO

IF DB_ID(N'A&SG_OLTP') IS NULL
	EXEC(N'CREATE DATABASE [A&SG_OLTP]');
GO

USE [A&SG_OLTP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO

IF OBJECT_ID(N'dbo.Roles_Sistema', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Roles_Sistema](
	[ID_Rol] [int] IDENTITY(1,1) NOT NULL,
	[Nombre_Rol] [nvarchar](50) NOT NULL,
	[Descripcion] [nvarchar](255) NULL,
 CONSTRAINT [PK_Roles_Sistema] PRIMARY KEY CLUSTERED ([ID_Rol] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Empleados', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Empleados](
	[ID_Empleado] [int] IDENTITY(1,1) NOT NULL,
	[Nombre_Completo] [nvarchar](150) NOT NULL,
	[Correo] [nvarchar](150) NULL,
	[Telefono] [nvarchar](20) NULL,
	[Estado] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Empleados] PRIMARY KEY CLUSTERED ([ID_Empleado] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Trabajadores', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Trabajadores](
	[ID_Trabajador] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Rol_Cargo] [nvarchar](100) NOT NULL,
	[HoraIngreso] [time](0) NULL,
	[Codigo_Trabajador] [nvarchar](20) NOT NULL,
	[PIN_Acceso] [nvarchar](255) NOT NULL,
	[ID_Rol] [int] NOT NULL,
 CONSTRAINT [PK_Trabajadores] PRIMARY KEY CLUSTERED ([ID_Trabajador] ASC),
 CONSTRAINT [UQ_Trabajadores_Codigo] UNIQUE NONCLUSTERED ([Codigo_Trabajador] ASC),
 CONSTRAINT [UQ_Trabajadores_Empleado] UNIQUE NONCLUSTERED ([ID_Empleado] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Administrador', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Administrador](
	[ID_Administrador] [int] IDENTITY(1,1) NOT NULL,
	[ID_Empleado] [int] NOT NULL,
	[Codigo_Administrador] [nvarchar](20) NOT NULL,
	[PIN_Acceso] [nvarchar](255) NOT NULL,
	[ID_Rol] [int] NOT NULL,
 CONSTRAINT [PK_Administrador] PRIMARY KEY CLUSTERED ([ID_Administrador] ASC),
 CONSTRAINT [UQ_Administrador_Codigo] UNIQUE NONCLUSTERED ([Codigo_Administrador] ASC),
 CONSTRAINT [UQ_Administrador_Empleado] UNIQUE NONCLUSTERED ([ID_Empleado] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Proyectos', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Proyectos](
	[ID_Proyecto] [int] IDENTITY(1,1) NOT NULL,
	[Nombre_Proyecto] [nvarchar](150) NOT NULL,
	[Area_Departamento] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Proyectos] PRIMARY KEY CLUSTERED ([ID_Proyecto] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Tareas', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Tareas](
	[ID_Tarea] [int] IDENTITY(1,1) NOT NULL,
	[ID_Trabajador] [int] NOT NULL,
	[ID_Administrador_Asignador] [int] NOT NULL,
	[ID_Proyecto] [int] NOT NULL,
	[Fecha] [date] NOT NULL,
	[Fecha_Inicio] [datetime2](0) NULL,
	[Fecha_Entrega] [datetime2](0) NULL,
	[Descripcion_Tarea] [nvarchar](max) NOT NULL,
	[Estado_Tarea] [nvarchar](30) NOT NULL,
	[Observaciones] [nvarchar](max) NULL,
 CONSTRAINT [PK_Tareas] PRIMARY KEY CLUSTERED ([ID_Tarea] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Asistencia', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Asistencia](
	[ID_Asistencia] [int] IDENTITY(1,1) NOT NULL,
	[ID_Trabajador] [int] NOT NULL,
	[Fecha_Entrada] [datetime2](0) NOT NULL,
	[Fecha_Salida] [datetime2](0) NULL,
	[Fecha_Calculada]  AS (CONVERT([date],[Fecha_Entrada])) PERSISTED,
	[Estado_Asistencia]  AS (case when ((datepart(hour,[Fecha_Entrada])*(3600)+datepart(minute,[Fecha_Entrada])*(60))+datepart(second,[Fecha_Entrada]))<(34860) then CONVERT([nvarchar](20),N'A tiempo') else CONVERT([nvarchar](20),N'Tardanza') end) PERSISTED,
 CONSTRAINT [PK_Asistencia] PRIMARY KEY CLUSTERED ([ID_Asistencia] ASC),
 CONSTRAINT [UQ_Trabajador_Fecha] UNIQUE NONCLUSTERED ([ID_Trabajador] ASC, [Fecha_Calculada] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Actividades', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Actividades](
	[ID_Actividad] [int] IDENTITY(1,1) NOT NULL,
	[ID_Tarea] [int] NOT NULL,
	[Fecha_Actividad] [datetime2](0) NOT NULL,
	[Descripcion_Actividad] [nvarchar](max) NOT NULL,
	[Estado_Actividad] [nvarchar](20) NOT NULL,
	[Observaciones] [nvarchar](max) NULL,
 CONSTRAINT [PK_Actividades] PRIMARY KEY CLUSTERED ([ID_Actividad] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Archivos', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Archivos](
	[ID_Archivo] [int] IDENTITY(1,1) NOT NULL,
	[ID_Trabajador] [int] NOT NULL,
	[ID_Tarea] [int] NULL,
	[ID_Actividad] [int] NULL,
	[Nombre_Original] [nvarchar](255) NOT NULL,
	[Nombre_Almacenado] [nvarchar](255) NOT NULL,
	[Tipo_Archivo] [nvarchar](100) NOT NULL,
	[Tamano_Archivo] [bigint] NOT NULL,
	[GoogleDrive_File_ID] [nvarchar](255) NOT NULL,
	[Ruta_GoogleDrive] [nvarchar](500) NULL,
	[Fecha_Subida] [datetime2](0) NOT NULL,
	[Estado] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_Archivos] PRIMARY KEY CLUSTERED ([ID_Archivo] ASC),
 CONSTRAINT [UQ_Archivos_GoogleDrive] UNIQUE NONCLUSTERED ([GoogleDrive_File_ID] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Comentarios_Tarea', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Comentarios_Tarea](
	[ID_Comentario] [int] IDENTITY(1,1) NOT NULL,
	[ID_Tarea] [int] NOT NULL,
	[Autor] [nvarchar](150) NOT NULL,
	[Rol] [nvarchar](15) NOT NULL,
	[Mensaje] [nvarchar](max) NOT NULL,
	[Fecha] [datetime2](0) NULL,
 CONSTRAINT [PK_Comentarios_Tarea] PRIMARY KEY CLUSTERED ([ID_Comentario] ASC)
);
END;
GO

IF OBJECT_ID(N'dbo.Evaluaciones_Rendimiento', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[Evaluaciones_Rendimiento](
	[ID_Evaluacion] [int] IDENTITY(1,1) NOT NULL,
	[ID_Trabajador] [int] NOT NULL,
	[ID_Administrador] [int] NOT NULL,
	[Periodo_Texto] [nvarchar](50) NULL,
	[Fecha_Inicio] [date] NULL,
	[Fecha_Fin] [date] NULL,
	[Total_Asistencias] [int] NULL,
	[Llegadas_Tiempo] [int] NULL,
	[Tardanzas] [int] NULL,
	[Total_Tareas] [int] NULL,
	[Tareas_Completadas] [int] NULL,
	[Eficiencia_Porcentaje] [decimal](5, 2) NULL,
	[Fecha_Generacion] [datetime2](0) NULL,
 CONSTRAINT [PK_Evaluaciones_Rendimiento] PRIMARY KEY CLUSTERED ([ID_Evaluacion] ASC)
);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Trabajadores_ID_Empleado' AND parent_object_id = OBJECT_ID(N'dbo.Trabajadores'))
	ALTER TABLE dbo.Trabajadores WITH CHECK ADD CONSTRAINT FK_Trabajadores_ID_Empleado
		FOREIGN KEY (ID_Empleado) REFERENCES dbo.Empleados (ID_Empleado);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Trabajadores_ID_Rol' AND parent_object_id = OBJECT_ID(N'dbo.Trabajadores'))
	ALTER TABLE dbo.Trabajadores WITH CHECK ADD CONSTRAINT FK_Trabajadores_ID_Rol
		FOREIGN KEY (ID_Rol) REFERENCES dbo.Roles_Sistema (ID_Rol);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Administrador_ID_Empleado' AND parent_object_id = OBJECT_ID(N'dbo.Administrador'))
	ALTER TABLE dbo.Administrador WITH CHECK ADD CONSTRAINT FK_Administrador_ID_Empleado
		FOREIGN KEY (ID_Empleado) REFERENCES dbo.Empleados (ID_Empleado);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Administrador_ID_Rol' AND parent_object_id = OBJECT_ID(N'dbo.Administrador'))
	ALTER TABLE dbo.Administrador WITH CHECK ADD CONSTRAINT FK_Administrador_ID_Rol
		FOREIGN KEY (ID_Rol) REFERENCES dbo.Roles_Sistema (ID_Rol);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Tareas_ID_Trabajador' AND parent_object_id = OBJECT_ID(N'dbo.Tareas'))
	ALTER TABLE dbo.Tareas WITH CHECK ADD CONSTRAINT FK_Tareas_ID_Trabajador
		FOREIGN KEY (ID_Trabajador) REFERENCES dbo.Trabajadores (ID_Trabajador);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Tareas_ID_Administrador_Asignador' AND parent_object_id = OBJECT_ID(N'dbo.Tareas'))
	ALTER TABLE dbo.Tareas WITH CHECK ADD CONSTRAINT FK_Tareas_ID_Administrador_Asignador
		FOREIGN KEY (ID_Administrador_Asignador) REFERENCES dbo.Administrador (ID_Administrador);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Tareas_ID_Proyecto' AND parent_object_id = OBJECT_ID(N'dbo.Tareas'))
	ALTER TABLE dbo.Tareas WITH CHECK ADD CONSTRAINT FK_Tareas_ID_Proyecto
		FOREIGN KEY (ID_Proyecto) REFERENCES dbo.Proyectos (ID_Proyecto);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Asistencia_ID_Trabajador' AND parent_object_id = OBJECT_ID(N'dbo.Asistencia'))
	ALTER TABLE dbo.Asistencia WITH CHECK ADD CONSTRAINT FK_Asistencia_ID_Trabajador
		FOREIGN KEY (ID_Trabajador) REFERENCES dbo.Trabajadores (ID_Trabajador);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Actividades_ID_Tarea' AND parent_object_id = OBJECT_ID(N'dbo.Actividades'))
	ALTER TABLE dbo.Actividades WITH CHECK ADD CONSTRAINT FK_Actividades_ID_Tarea
		FOREIGN KEY (ID_Tarea) REFERENCES dbo.Tareas (ID_Tarea);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Archivos_ID_Trabajador' AND parent_object_id = OBJECT_ID(N'dbo.Archivos'))
	ALTER TABLE dbo.Archivos WITH CHECK ADD CONSTRAINT FK_Archivos_ID_Trabajador
		FOREIGN KEY (ID_Trabajador) REFERENCES dbo.Trabajadores (ID_Trabajador);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Archivos_ID_Tarea' AND parent_object_id = OBJECT_ID(N'dbo.Archivos'))
	ALTER TABLE dbo.Archivos WITH CHECK ADD CONSTRAINT FK_Archivos_ID_Tarea
		FOREIGN KEY (ID_Tarea) REFERENCES dbo.Tareas (ID_Tarea);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Archivos_ID_Actividad' AND parent_object_id = OBJECT_ID(N'dbo.Archivos'))
	ALTER TABLE dbo.Archivos WITH CHECK ADD CONSTRAINT FK_Archivos_ID_Actividad
		FOREIGN KEY (ID_Actividad) REFERENCES dbo.Actividades (ID_Actividad);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Comentarios_Tarea_ID_Tarea' AND parent_object_id = OBJECT_ID(N'dbo.Comentarios_Tarea'))
	ALTER TABLE dbo.Comentarios_Tarea WITH CHECK ADD CONSTRAINT FK_Comentarios_Tarea_ID_Tarea
		FOREIGN KEY (ID_Tarea) REFERENCES dbo.Tareas (ID_Tarea);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Evaluaciones_Rendimiento_ID_Trabajador' AND parent_object_id = OBJECT_ID(N'dbo.Evaluaciones_Rendimiento'))
	ALTER TABLE dbo.Evaluaciones_Rendimiento WITH CHECK ADD CONSTRAINT FK_Evaluaciones_Rendimiento_ID_Trabajador
		FOREIGN KEY (ID_Trabajador) REFERENCES dbo.Trabajadores (ID_Trabajador);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_Evaluaciones_Rendimiento_ID_Administrador' AND parent_object_id = OBJECT_ID(N'dbo.Evaluaciones_Rendimiento'))
	ALTER TABLE dbo.Evaluaciones_Rendimiento WITH CHECK ADD CONSTRAINT FK_Evaluaciones_Rendimiento_ID_Administrador
		FOREIGN KEY (ID_Administrador) REFERENCES dbo.Administrador (ID_Administrador);
GO

DECLARE @tabla_identidad sysname;

BEGIN TRY
	BEGIN TRANSACTION;

	DECLARE @roles TABLE (id_rol int, nombre nvarchar(50));
	INSERT INTO @roles VALUES
		(1, N'Administrador'), (2, N'Trabajador'), (3, N'Practicante');

	IF EXISTS (
		SELECT 1 FROM dbo.Roles_Sistema r
		JOIN @roles d ON d.id_rol = r.ID_Rol
		WHERE r.Nombre_Rol <> d.nombre
	)
		THROW 50001, N'Los identificadores de roles ya pertenecen a otros registros.', 1;

	SET IDENTITY_INSERT dbo.Roles_Sistema ON;
	SET @tabla_identidad = N'Roles_Sistema';
	INSERT INTO dbo.Roles_Sistema (ID_Rol, Nombre_Rol)
	SELECT id_rol, nombre FROM @roles d
	WHERE NOT EXISTS (SELECT 1 FROM dbo.Roles_Sistema r WHERE r.ID_Rol = d.id_rol);
	SET IDENTITY_INSERT dbo.Roles_Sistema OFF;
	SET @tabla_identidad = NULL;

	DECLARE @personal TABLE (
		id_empleado int, nombre nvarchar(150), cargo nvarchar(100), id_rol int
	);
	INSERT INTO @personal VALUES
		(1, N'Adonis', N'Analista de proyectos', 2),
		(2, N'Benjamin Alfonso', N'Practicante de sistemas', 3),
		(3, N'Celeste', N'Asistente de proyectos', 2),
		(4, N'Fernando Carhuatanta', N'Asistente de ingeniería', 2),
		(5, N'Administrador General', N'Administrador', 1),
		(6, N'Diego Garrido', N'Analista de sistemas', 2),
		(7, N'Victor Paredes', N'Asistente de operaciones', 2),
		(8, N'Luis Obregón', N'Asistente de obra', 2),
		(9, N'Israel', N'Practicante de operaciones', 3),
		(10, N'Carlos Mendoza', N'Asistente de logística', 2),
		(11, N'Matías', N'Practicante de ingeniería', 3);

	IF EXISTS (
		SELECT 1 FROM dbo.Empleados e
		JOIN @personal p ON p.id_empleado = e.ID_Empleado
		WHERE e.Nombre_Completo <> p.nombre
	)
		THROW 50002, N'Los identificadores de empleados ya pertenecen a otras personas.', 1;

	SET IDENTITY_INSERT dbo.Empleados ON;
	SET @tabla_identidad = N'Empleados';
	INSERT INTO dbo.Empleados (ID_Empleado, Nombre_Completo, Estado)
	SELECT id_empleado, nombre, N'Activo' FROM @personal p
	WHERE NOT EXISTS (SELECT 1 FROM dbo.Empleados e WHERE e.ID_Empleado = p.id_empleado);
	SET IDENTITY_INSERT dbo.Empleados OFF;
	SET @tabla_identidad = NULL;

	IF EXISTS (
		SELECT 1 FROM dbo.Trabajadores t
		JOIN @personal p ON p.id_empleado = t.ID_Trabajador
		WHERE p.id_rol <> 1 AND (t.ID_Empleado <> p.id_empleado OR t.ID_Rol <> p.id_rol)
	)
		THROW 50003, N'Los identificadores de trabajadores no coinciden con el personal.', 1;

	SET IDENTITY_INSERT dbo.Trabajadores ON;
	SET @tabla_identidad = N'Trabajadores';
	INSERT INTO dbo.Trabajadores (
		ID_Trabajador, ID_Empleado, Rol_Cargo, HoraIngreso, Codigo_Trabajador, PIN_Acceso, ID_Rol
	)
	SELECT id_empleado, id_empleado, cargo, '09:00:00',
		N'TR-' + RIGHT(N'000' + CONVERT(nvarchar(3), id_empleado), 3), N'ACCESO_DESHABILITADO', id_rol
	FROM @personal p
	WHERE id_rol <> 1
		AND NOT EXISTS (SELECT 1 FROM dbo.Trabajadores t WHERE t.ID_Trabajador = p.id_empleado);
	SET IDENTITY_INSERT dbo.Trabajadores OFF;
	SET @tabla_identidad = NULL;

	IF EXISTS (SELECT 1 FROM dbo.Administrador WHERE ID_Administrador = 1 AND (ID_Empleado <> 5 OR ID_Rol <> 1))
		THROW 50004, N'El administrador 1 ya tiene otra asignación.', 1;

	SET IDENTITY_INSERT dbo.Administrador ON;
	SET @tabla_identidad = N'Administrador';
	IF NOT EXISTS (SELECT 1 FROM dbo.Administrador WHERE ID_Administrador = 1)
		INSERT INTO dbo.Administrador (ID_Administrador, ID_Empleado, Codigo_Administrador, PIN_Acceso, ID_Rol)
		VALUES (1, 5, N'AD-001', N'ACCESO_DESHABILITADO', 1);
	SET IDENTITY_INSERT dbo.Administrador OFF;
	SET @tabla_identidad = NULL;

	DECLARE @proyectos TABLE (id_proyecto int, nombre nvarchar(150), area nvarchar(100));
	INSERT INTO @proyectos VALUES
		(1, N'Construcción y supervisión de obras', N'Ingeniería'),
		(2, N'Gestión documental y asesoría legal', N'Legal'),
		(3, N'Implementación del sistema de remuneraciones', N'Sistemas');

	IF EXISTS (
		SELECT 1 FROM dbo.Proyectos p
		JOIN @proyectos d ON d.id_proyecto = p.ID_Proyecto
		WHERE p.Nombre_Proyecto <> d.nombre OR p.Area_Departamento <> d.area
	)
		THROW 50005, N'Los identificadores de proyectos ya están ocupados.', 1;

	SET IDENTITY_INSERT dbo.Proyectos ON;
	SET @tabla_identidad = N'Proyectos';
	INSERT INTO dbo.Proyectos (ID_Proyecto, Nombre_Proyecto, Area_Departamento)
	SELECT id_proyecto, nombre, area FROM @proyectos d
	WHERE NOT EXISTS (SELECT 1 FROM dbo.Proyectos p WHERE p.ID_Proyecto = d.id_proyecto);
	SET IDENTITY_INSERT dbo.Proyectos OFF;
	SET @tabla_identidad = NULL;

	DECLARE @jornadas TABLE (
		id_trabajador int, fecha date, numero_jornada int, total_jornadas int,
		PRIMARY KEY (id_trabajador, numero_jornada)
	);

	;WITH fechas AS (
		SELECT CONVERT(date, '20260701', 112) AS fecha
		UNION ALL
		SELECT DATEADD(day, 1, fecha) FROM fechas WHERE fecha < CONVERT(date, '20260930', 112)
	)
	INSERT INTO @jornadas (id_trabajador, fecha, numero_jornada, total_jornadas)
	SELECT p.id_empleado, f.fecha,
		ROW_NUMBER() OVER (PARTITION BY p.id_empleado ORDER BY f.fecha),
		COUNT(*) OVER (PARTITION BY p.id_empleado)
	FROM fechas f CROSS JOIN @personal p
	WHERE p.id_rol <> 1
		AND ((p.id_rol = 2 AND DATEDIFF(day, '19000101', f.fecha) % 7 BETWEEN 0 AND 4)
			OR (p.id_rol = 3 AND DATEDIFF(day, '19000101', f.fecha) % 7 IN (0, 2, 4)))
	OPTION (MAXRECURSION 100);

	DECLARE @id_trabajador int = 1, @numero_jornada int, @total_jornadas int;
	DECLARE @fecha date, @posicion int, @variacion bigint, @minutos_entrada int;
	DECLARE @fecha_entrada datetime2(0), @fecha_salida datetime2(0);
	DECLARE @id_proyecto int, @descripcion nvarchar(200), @estado nvarchar(30);
	DECLARE @observaciones nvarchar(max), @fecha_inicio datetime2(0), @fecha_entrega datetime2(0);
	DECLARE @limite_completadas int, @limite_progreso int, @limite_correcciones int;

	WHILE @id_trabajador <= 11
	BEGIN
		SET @total_jornadas = 0;
		SELECT @total_jornadas = COUNT(*) FROM @jornadas WHERE id_trabajador = @id_trabajador;
		SET @numero_jornada = 1;

		WHILE @numero_jornada <= @total_jornadas
		BEGIN
			SELECT @fecha = fecha FROM @jornadas
			WHERE id_trabajador = @id_trabajador AND numero_jornada = @numero_jornada;

			-- Porcentajes del trimestre redondeados a jornadas completas.
			SET @posicion = ((@numero_jornada - 1) * 17 + @id_trabajador * 7) % @total_jornadas + 1;
			SET @variacion = ABS(CONVERT(bigint, CHECKSUM(CONCAT(@id_trabajador, N'-', CONVERT(char(8), @fecha, 112)))));

			IF @id_trabajador = 2
				SET @minutos_entrada = CASE WHEN @posicion <= ROUND(@total_jornadas * 0.95, 0)
					THEN 525 + @variacion % 31 ELSE 581 + @variacion % 10 END;
			ELSE IF @id_trabajador IN (1, 3)
				SET @minutos_entrada = CASE WHEN @posicion <= ROUND(@total_jornadas * 0.85, 0)
					THEN 535 + @variacion % 31 ELSE 525 + @variacion % 10 END;
			ELSE IF @id_trabajador = 11
				SET @minutos_entrada = CASE WHEN @posicion <= @total_jornadas * 0.50 THEN 570 ELSE 585 END;
			ELSE IF @id_trabajador = 9
				SET @minutos_entrada = CASE WHEN @posicion <= ROUND(@total_jornadas * 0.60, 0)
					THEN 582 + @variacion % 34 ELSE 555 + @variacion % 26 END;
			ELSE
				-- Se conserva el máximo de 09:35 para los regulares.
				SET @minutos_entrada = CASE WHEN @posicion <= ROUND(@total_jornadas * 0.75, 0)
					THEN 540 + @variacion % 36 ELSE 525 + @variacion % 15 END;

			SET @fecha_entrada = DATEADD(minute, @minutos_entrada, CONVERT(datetime2(0), @fecha));
			SET @fecha_salida = DATEADD(hour, 18, CONVERT(datetime2(0), @fecha));

			IF NOT EXISTS (SELECT 1 FROM dbo.Asistencia WHERE ID_Trabajador = @id_trabajador AND Fecha_Calculada = @fecha)
				INSERT INTO dbo.Asistencia (ID_Trabajador, Fecha_Entrada, Fecha_Salida)
				VALUES (@id_trabajador, @fecha_entrada, @fecha_salida);

			-- Una tarea por jornada; el orden distribuye los estados entre los tres meses.
			SET @posicion = ((@numero_jornada - 1) * 19 + @id_trabajador * 3) % @total_jornadas + 1;
			SET @id_proyecto = (@numero_jornada + @id_trabajador - 1) % 3 + 1;
			SET @descripcion = N'Revisión del expediente diario ' + CONVERT(nvarchar(8), @fecha, 112)
				+ N' / TR-' + RIGHT(N'000' + CONVERT(nvarchar(3), @id_trabajador), 3);
			SET @observaciones = NULL;

			IF @id_trabajador = 2
			BEGIN
				SET @limite_completadas = CONVERT(int, ROUND(@total_jornadas * 0.95, 0));
				SET @limite_progreso = @limite_completadas + 1;
			END;
			ELSE IF @id_trabajador = 9
			BEGIN
				SET @limite_completadas = CONVERT(int, ROUND(@total_jornadas * 0.50, 0));
				SET @limite_progreso = CONVERT(int, ROUND(@total_jornadas * 0.80, 0));
				IF @posicion <= @limite_completadas
					SET @observaciones = N'[ENTREGADO FUERA DE PLAZO]';
			END;
			ELSE
			BEGIN
				SET @limite_completadas = CONVERT(int, ROUND(@total_jornadas *
					CASE WHEN @id_trabajador = 1 THEN 0.90 WHEN @id_trabajador = 3 THEN 0.80
						WHEN @id_trabajador = 11 THEN 0.40 ELSE 0.65 END, 0));
				SET @limite_progreso = CONVERT(int, ROUND(@total_jornadas *
					CASE WHEN @id_trabajador = 1 THEN 0.95 WHEN @id_trabajador = 3 THEN 0.90
						WHEN @id_trabajador = 11 THEN 0.70 ELSE 0.85 END, 0));
				SET @limite_correcciones = CONVERT(int, ROUND(@total_jornadas * 0.10, 0));
				IF @posicion <= @limite_correcciones
					SET @observaciones = N'Corregir las medidas y adjuntar el sustento actualizado.';
			END;

			SET @estado = CASE WHEN @posicion <= @limite_completadas THEN N'Completada'
				WHEN @posicion <= @limite_progreso THEN N'En Progreso' ELSE N'Asignada' END;
			SET @fecha_inicio = CASE WHEN @estado = N'Asignada' THEN NULL
				ELSE DATEADD(minute, 15, @fecha_entrada) END;
			SET @fecha_entrega = CASE WHEN @estado <> N'Completada' THEN NULL
				WHEN @observaciones = N'[ENTREGADO FUERA DE PLAZO]'
					THEN DATEADD(hour, 10, DATEADD(day, 1, CONVERT(datetime2(0), @fecha)))
				ELSE DATEADD(hour, 17, CONVERT(datetime2(0), @fecha)) END;

			IF NOT EXISTS (
				SELECT 1 FROM dbo.Tareas WHERE ID_Trabajador = @id_trabajador
					AND Fecha = @fecha AND Descripcion_Tarea = @descripcion
			)
				INSERT INTO dbo.Tareas (
					ID_Trabajador, ID_Administrador_Asignador, ID_Proyecto, Fecha,
					Fecha_Inicio, Fecha_Entrega, Descripcion_Tarea, Estado_Tarea, Observaciones
				)
				VALUES (@id_trabajador, 1, @id_proyecto, @fecha, @fecha_inicio,
					@fecha_entrega, @descripcion, @estado, @observaciones);

			SET @numero_jornada += 1;
		END;
		SET @id_trabajador += 1;
	END;

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
	IF @tabla_identidad IS NOT NULL
	BEGIN
		DECLARE @sentencia nvarchar(300) = N'SET IDENTITY_INSERT dbo.' + QUOTENAME(@tabla_identidad) + N' OFF;';
		EXEC sys.sp_executesql @sentencia;
	END;
	THROW;
END CATCH;
GO

SELECT YEAR(Fecha_Calculada) AS Anio, MONTH(Fecha_Calculada) AS Mes,
	COUNT(*) AS Total_Asistencias,
	SUM(CASE WHEN Estado_Asistencia = N'A tiempo' THEN 1 ELSE 0 END) AS Llegadas_A_Tiempo,
	SUM(CASE WHEN Estado_Asistencia = N'Tardanza' THEN 1 ELSE 0 END) AS Tardanzas
FROM dbo.Asistencia
WHERE Fecha_Calculada >= '20260701' AND Fecha_Calculada < '20261001'
GROUP BY YEAR(Fecha_Calculada), MONTH(Fecha_Calculada)
ORDER BY Anio, Mes;
GO
