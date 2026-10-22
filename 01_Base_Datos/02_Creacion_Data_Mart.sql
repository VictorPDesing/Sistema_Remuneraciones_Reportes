USE [master];
GO

IF DB_ID(N'A&SG_DataMart') IS NULL
	EXEC(N'CREATE DATABASE [A&SG_DataMart]');
GO

USE [A&SG_DataMart];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.dim_trabajador', N'U') IS NULL
	CREATE TABLE dbo.dim_trabajador (
		id_trabajador int IDENTITY(1,1) PRIMARY KEY,
		id_trabajador_origen int NOT NULL UNIQUE,
		codigo_trabajador nvarchar(20) NOT NULL,
		nombre_completo nvarchar(150) NOT NULL,
		cargo nvarchar(100) NOT NULL,
		tipo_jornada nvarchar(20) NOT NULL,
		estado nvarchar(10) NOT NULL
	);
GO

IF OBJECT_ID(N'dbo.dim_tiempo', N'U') IS NULL
	CREATE TABLE dbo.dim_tiempo (
		id_tiempo int PRIMARY KEY,
		fecha date NOT NULL UNIQUE,
		anio smallint NOT NULL,
		trimestre tinyint NOT NULL,
		mes tinyint NOT NULL,
		nombre_mes nvarchar(15) NOT NULL,
		dia tinyint NOT NULL,
		dia_semana tinyint NOT NULL,
		nombre_dia nvarchar(15) NOT NULL
	);
GO

IF OBJECT_ID(N'dbo.dim_proyecto', N'U') IS NULL
	CREATE TABLE dbo.dim_proyecto (
		id_proyecto int IDENTITY(1,1) PRIMARY KEY,
		id_proyecto_origen int NULL UNIQUE,
		nombre_proyecto nvarchar(150) NOT NULL,
		area_departamento nvarchar(100) NOT NULL
	);
GO

IF OBJECT_ID(N'dbo.dim_administrador', N'U') IS NULL
	CREATE TABLE dbo.dim_administrador (
		id_administrador int IDENTITY(1,1) PRIMARY KEY,
		id_administrador_origen int NULL UNIQUE,
		nombre_completo nvarchar(150) NOT NULL,
		codigo_administrador nvarchar(20) NOT NULL
	);
GO

IF NOT EXISTS (SELECT 1 FROM dbo.dim_proyecto WHERE id_proyecto = 0)
BEGIN
	SET IDENTITY_INSERT dbo.dim_proyecto ON;
	INSERT INTO dbo.dim_proyecto (id_proyecto, id_proyecto_origen, nombre_proyecto, area_departamento)
	VALUES (0, NULL, N'Asistencia sin proyecto', N'No aplica');
	SET IDENTITY_INSERT dbo.dim_proyecto OFF;
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.dim_administrador WHERE id_administrador = 0)
BEGIN
	SET IDENTITY_INSERT dbo.dim_administrador ON;
	INSERT INTO dbo.dim_administrador (id_administrador, id_administrador_origen, nombre_completo, codigo_administrador)
	VALUES (0, NULL, N'Asistencia sin administrador', N'NO-APLICA');
	SET IDENTITY_INSERT dbo.dim_administrador OFF;
END;
GO

IF OBJECT_ID(N'dbo.bitacora_etl', N'U') IS NULL
	CREATE TABLE dbo.bitacora_etl (
		id_carga bigint IDENTITY(1,1) PRIMARY KEY,
		fecha_desde date NOT NULL,
		fecha_hasta date NOT NULL,
		inicio datetime2(0) NOT NULL DEFAULT SYSDATETIME(),
		fin datetime2(0) NULL,
		estado nvarchar(20) NOT NULL,
		asistencias_extraidas int NULL,
		tareas_extraidas int NULL,
		registros_rechazados int NULL,
		filas_cargadas int NULL,
		mensaje nvarchar(2048) NULL
	);
GO

IF OBJECT_ID(N'dbo.rechazos_etl', N'U') IS NULL
	CREATE TABLE dbo.rechazos_etl (
		id_rechazo bigint IDENTITY(1,1) PRIMARY KEY,
		id_carga bigint NOT NULL REFERENCES dbo.bitacora_etl(id_carga),
		tabla_origen nvarchar(30) NOT NULL,
		id_registro_origen int NOT NULL,
		motivo nvarchar(200) NOT NULL
	);
GO

IF OBJECT_ID(N'dbo.fac_rendimiento_kpis', N'U') IS NULL
	CREATE TABLE dbo.fac_rendimiento_kpis (
		id_rendimiento bigint IDENTITY(1,1) PRIMARY KEY,
		id_trabajador int NOT NULL REFERENCES dbo.dim_trabajador(id_trabajador),
		id_tiempo int NOT NULL REFERENCES dbo.dim_tiempo(id_tiempo),
		id_proyecto int NOT NULL REFERENCES dbo.dim_proyecto(id_proyecto),
		id_administrador int NOT NULL REFERENCES dbo.dim_administrador(id_administrador),
		jornadas_esperadas int NOT NULL DEFAULT 0,
		total_asistencias int NOT NULL DEFAULT 0,
		asistencias_a_tiempo int NOT NULL DEFAULT 0,
		tardanzas int NOT NULL DEFAULT 0,
		minutos_tardanza int NOT NULL DEFAULT 0,
		horas_permanencia decimal(10,2) NOT NULL DEFAULT 0,
		salidas_pendientes int NOT NULL DEFAULT 0,
		total_tareas int NOT NULL DEFAULT 0,
		tareas_completadas int NOT NULL DEFAULT 0,
		tareas_sin_observaciones int NOT NULL DEFAULT 0,
		tareas_fuera_plazo int NOT NULL DEFAULT 0,
		tareas_con_correcciones int NOT NULL DEFAULT 0,
		tareas_en_progreso int NOT NULL DEFAULT 0,
		tareas_asignadas int NOT NULL DEFAULT 0,
		id_carga bigint NOT NULL REFERENCES dbo.bitacora_etl(id_carga),
		CONSTRAINT UQ_rendimiento_grano UNIQUE (id_trabajador, id_tiempo, id_proyecto, id_administrador),
		CONSTRAINT CK_rendimiento_asistencias CHECK (
			jornadas_esperadas BETWEEN 0 AND 1 AND total_asistencias BETWEEN 0 AND 1
			AND asistencias_a_tiempo >= 0 AND tardanzas >= 0
			AND total_asistencias = asistencias_a_tiempo + tardanzas
			AND minutos_tardanza >= 0 AND horas_permanencia >= 0
			AND salidas_pendientes BETWEEN 0 AND total_asistencias
		),
		CONSTRAINT CK_rendimiento_tareas CHECK (
			total_tareas >= 0 AND tareas_completadas >= 0 AND tareas_en_progreso >= 0 AND tareas_asignadas >= 0
			AND total_tareas = tareas_completadas + tareas_en_progreso + tareas_asignadas
			AND tareas_sin_observaciones BETWEEN 0 AND tareas_completadas
			AND tareas_fuera_plazo BETWEEN 0 AND total_tareas
			AND tareas_con_correcciones BETWEEN 0 AND total_tareas
		),
		CONSTRAINT CK_rendimiento_atribucion CHECK (
			(id_proyecto = 0 AND id_administrador = 0 AND total_tareas = 0)
			OR (id_proyecto > 0 AND id_administrador > 0 AND jornadas_esperadas = 0 AND total_asistencias = 0)
		)
	);
GO
