# Modelo estrella en SQL Server

El archivo `01_Base_Datos/02_Creacion_Data_Mart.sql` crea las tablas y sus relaciones. El diagrama de SSMS permite mostrar esas mismas relaciones como evidencia.

## Crear el diagrama

1. En el explorador de SSMS, actualizar **Databases** y expandir `A&SG_DataMart`.
2. Abrir **Database Diagrams / Diagramas de base de datos** y elegir **New Database Diagram / Nuevo diagrama**.
3. Si SSMS solicita crear los objetos de compatibilidad con diagramas, aceptar con una cuenta que tenga permisos sobre la base.
4. Agregar solamente `dim_trabajador`, `dim_tiempo`, `dim_proyecto`, `dim_administrador` y `fac_rendimiento_kpis`.
5. Poner los hechos en el centro y las cuatro dimensiones alrededor. Las relaciones se dibujan a partir de las claves foráneas existentes.
6. Mostrar las columnas de cada tabla y ajustar el zoom para que se lean las claves y las líneas.
7. Guardar el diagrama con el nombre `Modelo_Estrella_Rendimiento`.

Las tablas `bitacora_etl` y `rechazos_etl` son de control. No hace falta incluirlas en la captura del modelo estrella.

## Capturar y subir

Con el diagrama abierto, usar **Windows + Shift + S** y guardar la imagen como:

`04_Documentacion/Evidencias/03_Modelo_Estrella_SSMS.png`

En GitHub, abrir esa carpeta, elegir **Add file → Upload files**, cargar la imagen y registrar el cambio. Si se sube desde una rama de trabajo, abrir un pull request hacia `main`.

La captura de SSMS debe obtenerse en la computadora donde se abre el diagrama; no se genera desde un script T-SQL. `Modelo_Estrella.svg` es un diagrama de referencia generado a partir de las tablas y relaciones de una instancia SQL Server de validación. No sustituye la captura de SSMS.

## Comprobar las relaciones

```sql
USE [A&SG_DataMart];
GO
SELECT
	OBJECT_NAME(parent_object_id) AS tabla_hechos,
	name AS relacion,
	OBJECT_NAME(referenced_object_id) AS tabla_relacionada
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('dbo.fac_rendimiento_kpis');
```

Deben aparecer las cuatro dimensiones y la relación adicional con la bitácora. Cada dimensión se relaciona uno a varios con los hechos. En las filas de asistencia, proyecto y administrador usan la clave cero porque el origen no asigna una marcación a un proyecto.
