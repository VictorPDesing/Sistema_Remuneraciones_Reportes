# Orden de ejecución

La guía de principio a fin, con el padrón y las páginas de Power BI, está en [09_Guia_Completa.md](09_Guia_Completa.md).

## Archivos

| Carpeta | Contenido |
| --- | --- |
| `01_Base_Datos` | Origen de la empresa y creación del Data Mart. |
| `02_Procedimientos_Almacenados` | Procedimiento ETL y vistas SQL de consulta. |
| `03_Vistas_PowerBI` | Dashboard `.pbix` y sus exportaciones a PDF o imágenes. Se conserva el nombre de carpeta del proyecto. |
| `04_Documentacion` | Reglas, medidas DAX, validaciones, modelo y evidencias. |

## Si solo está creado el origen

Abrir una consulta nueva en SSMS y ejecutar los archivos completos en este orden:

1. `01_Base_Datos/02_Creacion_Data_Mart.sql`.
2. `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql`.
3. `02_Procedimientos_Almacenados/03_Vistas_PowerBI.sql`.
4. `04_Documentacion/01_Validacion_ETL.sql`.

La creación del Data Mart se ejecuta **una sola vez**. Contiene `CREATE DATABASE` y `CREATE TABLE` directos; si la base ya existe, no volver a ejecutar ese archivo. Los scripts de procedimiento y vistas usan `CREATE OR ALTER` para poder actualizarlos.

## Si ya está instalado el Data Mart

Se conservan las tablas y sus columnas. No borrar bases ni volver a ejecutar la creación.

Para alinear una instalación anterior con el padrón original, seguir [08_Padron_Trabajadores.md](08_Padron_Trabajadores.md): actualizar primero el procedimiento ETL, ejecutar `01_Base_Datos/03_Alinear_Personal_Origen.sql` y después la validación. El script de alineación está destinado a instalaciones existentes; no hace falta ejecutarlo al crear desde cero con el generador actual.

Para actualizar los datos después:

```sql
USE [A&SG_DataMart];
GO
EXEC dbo.usp_cargar_rendimiento '20260701', '20260930';
GO
```

Ejecutar una carga a la vez, desde una sesión sin otra transacción abierta. El procedimiento sustituye los hechos del intervalo dentro de una transacción y registra su resultado en `bitacora_etl`. Las dimensiones se actualizan con `UPDATE`, `INSERT` y `NOT EXISTS`. El calendario se completa con un `WHILE`.

## Qué revisar

El script de validación ejecuta dos cargas y comprueba que sus medidas sean iguales. Después muestra diez trabajadores, una consulta de duplicados que debe estar vacía, las cantidades del origen y destino y los indicadores mensuales.

| Mes de 2026 | Asistencias | Tareas |
| --- | ---: | ---: |
| Julio | 203 | 203 |
| Agosto | 186 | 186 |
| Septiembre | 193 | 193 |
| Total | 582 | 582 |

La última carga debe estar `Completada`, con cero rechazos. Deben existir treinta resúmenes de trabajador y mes. Si aparece `Con rechazos`, consultar `rechazos_etl`, corregir los datos correspondientes y volver a cargar el período. Las cantidades anteriores corresponden al conjunto simulado inicial, no a cualquier origen futuro.

## Modelo y dashboard

El modelo estrella se crea físicamente con las cuatro dimensiones y las claves foráneas de `fac_rendimiento_kpis`. Para dibujarlo y tomar la captura en SSMS, seguir [07_Modelo_Estrella_SSMS.md](07_Modelo_Estrella_SSMS.md).

Para conectar Power BI, seguir [03_Guia_PowerBI.md](03_Guia_PowerBI.md). Guardar el informe terminado en `03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix`. Esa carpeta está reservada para los entregables visuales; los scripts SQL están en `02_Procedimientos_Almacenados`.

Los resultados reales de validación y las capturas se organizan dentro de `04_Documentacion/Evidencias`.
