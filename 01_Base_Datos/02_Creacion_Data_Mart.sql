USE [master];
GO

CREATE DATABASE [A&SG_DataMart];
GO

USE [A&SG_DataMart];
GO

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

CREATE TABLE dbo.dim_proyecto (
	id_proyecto int IDENTITY(0,1) PRIMARY KEY,
	id_proyecto_origen int NULL UNIQUE,
	nombre_proyecto nvarchar(150) NOT NULL,
	area_departamento nvarchar(100) NOT NULL
);
GO

CREATE TABLE dbo.dim_administrador (
	id_administrador int IDENTITY(0,1) PRIMARY KEY,
	id_administrador_origen int NULL UNIQUE,
	nombre_completo nvarchar(150) NOT NULL,
	codigo_administrador nvarchar(20) NOT NULL
);
GO

INSERT INTO dbo.dim_proyecto (id_proyecto_origen, nombre_proyecto, area_departamento)
VALUES (NULL, N'Asistencia sin proyecto', N'No aplica');
GO

INSERT INTO dbo.dim_administrador (id_administrador_origen, nombre_completo, codigo_administrador)
VALUES (NULL, N'Asistencia sin administrador', N'NO-APLICA');
GO

CREATE TABLE dbo.bitacora_etl (
	id_carga bigint IDENTITY(1,1) PRIMARY KEY,
	fecha_desde date NOT NULL,
	fecha_hasta date NOT NULL,
	inicio datetime2(0) NOT NULL DEFAULT GETDATE(),
	fin datetime2(0) NULL,
	estado nvarchar(20) NOT NULL,
	asistencias_extraidas int NULL,
	tareas_extraidas int NULL,
	registros_rechazados int NULL,
	filas_cargadas int NULL,
	mensaje nvarchar(2048) NULL
);
GO

CREATE TABLE dbo.rechazos_etl (
	id_rechazo bigint IDENTITY(1,1) PRIMARY KEY,
	id_carga bigint NOT NULL REFERENCES dbo.bitacora_etl(id_carga),
	tabla_origen nvarchar(30) NOT NULL,
	id_registro_origen int NOT NULL,
	motivo nvarchar(200) NOT NULL
);
GO

CREATE TABLE dbo.fac_rendimiento_kpis (
	id_rendimiento bigint IDENTITY(1,1) PRIMARY KEY,
	id_trabajador int NOT NULL CONSTRAINT FK_rendimiento_trabajador REFERENCES dbo.dim_trabajador(id_trabajador),
	id_tiempo int NOT NULL CONSTRAINT FK_rendimiento_tiempo REFERENCES dbo.dim_tiempo(id_tiempo),
	id_proyecto int NOT NULL CONSTRAINT FK_rendimiento_proyecto REFERENCES dbo.dim_proyecto(id_proyecto),
	id_administrador int NOT NULL CONSTRAINT FK_rendimiento_administrador REFERENCES dbo.dim_administrador(id_administrador),
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
	CONSTRAINT UQ_rendimiento_grano UNIQUE (id_trabajador, id_tiempo, id_proyecto, id_administrador)
);
GO
