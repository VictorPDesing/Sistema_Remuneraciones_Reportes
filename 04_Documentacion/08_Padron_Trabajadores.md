# Padrón de trabajadores

La lista de personas se toma de las tablas `Empleados` y `Trabajadores` del archivo original. La regla de jornadas y los registros históricos del trimestre son parte del conjunto académico; no cambian esa lista de personas.

## Instalación existente

Antes de actualizar, guardar una copia de seguridad de `A&SG_OLTP` y `A&SG_DataMart` desde SSMS: botón derecho sobre cada base, **Tasks / Tareas → Back Up / Copia de seguridad**. Elegir una ubicación válida en la computadora del servidor.

Después ejecutar, en este orden:

1. `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql` para actualizar la regla de jornadas.
2. `01_Base_Datos/03_Alinear_Personal_Origen.sql` para alinear los registros con el padrón.
3. `04_Documentacion/01_Validacion_ETL.sql` para recargar y verificar el Data Mart.

El script de alineación comprueba la estructura esperada antes de modificarla. Si encuentra un estado distinto, se detiene y revierte la operación. No desactivar las claves foráneas ni continuar ejecutando otras partes si aparece un error.

Se conservan los identificadores de las asistencias y tareas, sus fechas, estados y observaciones. El cambio de referencia del trabajador anterior al trabajador 5 se aplica también a archivos y evaluaciones. Los registros de actividades y comentarios continúan vinculados a sus tareas. La dimensión conserva su clave interna para mantener las relaciones de los hechos.

Se conservan los datos de contacto existentes al reasignar las personas y no se importan contactos ni credenciales del archivo adjunto. El trabajador trasladado conserva su PIN local. El script no importa el volcado completo de MySQL ni reemplaza los proyectos o movimientos por los del archivo original.

La corrección y el generador actualizado cumplen funciones distintas: **no volver a ejecutar el generador como sustituto del script de alineación** en una instalación anterior.

## Comprobación de personas

```sql
USE [A&SG_OLTP];
GO
SELECT t.ID_Trabajador, e.ID_Empleado, e.Nombre_Completo
FROM dbo.Trabajadores t
JOIN dbo.Empleados e ON e.ID_Empleado = t.ID_Empleado
ORDER BY t.ID_Trabajador;

USE [A&SG_DataMart];
GO
SELECT COUNT(*) AS total_trabajadores FROM dbo.dim_trabajador;
SELECT id_trabajador_origen, nombre_completo
FROM dbo.dim_trabajador
ORDER BY id_trabajador_origen;
```

Las dos listas deben coincidir y el conteo debe ser diez. Consultar la tabla de correspondencias en `02_Modelo_y_Reglas.md`.

## Resumen mensual

`vw_indicadores_mensuales` agrupa por trabajador y mes. Por eso una persona aparece tres veces al consultar julio, agosto y septiembre. El resultado esperado es treinta filas: diez trabajadores por tres meses.

La consulta de duplicados de la validación debe seguir vacía. Las cantidades esperadas se mantienen: 582 asistencias y 582 tareas, distribuidas en 203, 186 y 193 por mes.

Si Power BI ya estaba conectado, actualizar los visuales de DirectQuery o actualizar los datos si se utilizó Importar. No renombrar las personas manualmente en Power BI: los nombres deben llegar desde el Data Mart.
