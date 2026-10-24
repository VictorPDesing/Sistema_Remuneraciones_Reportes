# Simulación en otra computadora

## Qué se necesita

- SQL Server Developer instalado y su servicio iniciado.
- SQL Server Management Studio (SSMS), con permiso para crear bases.
- Power BI Desktop para abrir el reporte.
- El repositorio descargado y descomprimido. No ejecutar únicamente los archivos que aparecen al final de la carpeta: seguir el orden de [00_Orden_Ejecucion.md](00_Orden_Ejecucion.md).

Todos los archivos SQL deben ejecutarse en **la misma instancia** de SQL Server. Cada integrante tiene sus propias bases: GitHub comparte el código, no una conexión a los datos del compañero.

## Crear y cargar

En SSMS, abrir y ejecutar con F5 cada archivo completo:

1. `01_Base_Datos/01_Estructura_y_Datos.sql`.
2. `01_Base_Datos/02_Creacion_Data_Mart.sql`, solo si no existe el Data Mart.
3. `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql`.
4. `02_Procedimientos_Almacenados/03_Vistas_PowerBI.sql`.
5. `01_Base_Datos/04_Cargar_Simulacion.sql`.
6. `01_Base_Datos/05_Comprobar_Simulacion.sql`.

Si ya se ejecutaron los pasos 1 y 2, continuar desde el 3. Crear el procedimiento **no lo ejecuta**: el paso 5 es el que carga los hechos. No pegar datos manualmente dentro de `fac_rendimiento_kpis`.

El generador prepara los movimientos simulados del trimestre. El procedimiento los lee desde `A&SG_OLTP`, limpia y valida, actualiza las dimensiones y carga `A&SG_DataMart`.

## Cómo saber que funcionó

El paso 6 muestra el servidor y los controles. Para el conjunto inicial:

- Diez trabajadores y treinta resúmenes trabajador-mes.
- 582 asistencias y 582 tareas.
- 1.164 filas de hechos: 582 de asistencia y 582 de tareas.
- Julio: 203 movimientos de cada tipo; agosto: 186; septiembre: 193.
- Última carga `Completada`, con cero rechazos.
- Ninguna fila en la consulta de grupos duplicados.
- TPA 92,10%; ICT 56,36%; TDT 3,44%; IEP 75,12 puntos.

Los identificadores `id_rendimiento` e `id_carga` no tienen que empezar en uno ni coincidir entre computadoras. Al volver a cargar se reconstruyen los hechos del intervalo y se registra otra carga. Comparar las cantidades y medidas.

Para demostrar que repetir no duplica los datos, ejecutar `04_Documentacion/01_Validacion_ETL.sql`. Realiza dos cargas y muestra si sus claves y medidas se conservan.

## Si la tabla aparece vacía

| Lo que ocurre | Qué revisar |
| --- | --- |
| Solo ejecuté los dos archivos de creación. | Instalar el procedimiento y las vistas; ejecutar `04_Cargar_Simulacion.sql`. El Data Mart se crea vacío. |
| Ejecuté el procedimiento como archivo, pero no aparece una carga. | `CREATE OR ALTER PROCEDURE` solo guarda la definición. Ejecutar el archivo de carga. |
| El origen tiene cero asistencias o tareas del trimestre. | Revisar los mensajes de `01_Estructura_y_Datos.sql` y que se ejecutó completo en esta instancia. El cargador avisa si no hay movimientos. |
| Hay datos en otro equipo o en otra instancia. | Comparar `@@SERVERNAME`; SQL Server no comparte las bases automáticamente entre computadoras. |
| La bitácora indica `Fallida`. | Leer su mensaje y corregir el problema antes de repetir la carga. |
| La bitácora indica `Con rechazos`. | Consultar `rechazos_etl`; los movimientos rechazados no forman parte de los KPI. |
| SQL tiene datos y Power BI está vacío. | Ajustar servidor y base en el PBIX, revisar credenciales y actualizar; borrar filtros que no correspondan al trimestre. |
| Las primeras filas tienen tareas en cero. | Esas filas son de asistencia. Las tareas están en filas separadas con sus proyectos; sumar `total_tareas` o usar las vistas. |

## Consultas para revisar

```sql
SELECT @@SERVERNAME AS servidor, DB_NAME() AS base_actual;

USE [A&SG_DataMart];
GO
SELECT COUNT(*) AS filas_hechos,
       SUM(total_asistencias) AS asistencias,
       SUM(total_tareas) AS tareas
FROM dbo.fac_rendimiento_kpis;

SELECT TOP (5) * FROM dbo.bitacora_etl ORDER BY id_carga DESC;
SELECT * FROM dbo.rechazos_etl ORDER BY id_rechazo;
```

Una vez instalados el origen, las tablas, el procedimiento y las vistas, la carga equivalente al paso 5 es:

```sql
USE [A&SG_DataMart];
GO
EXEC dbo.usp_cargar_rendimiento '20260701', '20260930';
GO
```

## Abrir los reportes

1. Abrir `03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix`.
2. En **Archivo → Opciones y configuración → Configuración de origen de datos**, cambiar el servidor por el de esta instalación. La base es `A&SG_DataMart`.
3. Configurar las credenciales y actualizar el reporte. El PBIX publicado contiene dos páginas; no hace falta volver a crear sus medidas.
4. Comparar las tarjetas sin filtros con los resultados del paso 6. En la página de bono, la base S/ 1.500 y el máximo de 20% son supuestos académicos.

Si se construye un reporte nuevo, cargar `vw_dim_trabajador`, `vw_dim_tiempo`, `vw_dim_proyecto`, `vw_dim_administrador` y `vw_rendimiento_kpis`. Crear las cuatro relaciones activas de uno a varios, desde dimensiones hacia hechos. La guía visual está en [03_Guia_PowerBI.md](03_Guia_PowerBI.md).

## Qué significan las tarjetas

| Sigla | Cálculo y lectura |
| --- | --- |
| TPA | Tasa de puntualidad: entradas a tiempo / asistencias × 100. Mayor es mejor. La tolerancia llega hasta 09:40:59. |
| ICT | Índice de cumplimiento de tareas: completadas sin observaciones / total de tareas × 100. Mayor es mejor. Es una convención académica; no existe aprobación formal en el origen. |
| TDT | Tasa de devolución de tareas, con la definición del proyecto: tareas con `FUERA DE PLAZO` / total × 100. Menor es mejor; no cuenta todas las correcciones. |
| IEP | Índice de efectividad ponderado: TPA × 0,30 + ICT × 0,50 + (100 − TDT) × 0,20. Puntaje sobre 100. |

En este proyecto la sigla es **TPA**, no ATP. El detalle y los ejemplos están en [11_Indicadores_Dashboard.md](11_Indicadores_Dashboard.md). Si no existe denominador válido, las tasas y el IEP quedan vacíos; no equivalen a cero medido.
