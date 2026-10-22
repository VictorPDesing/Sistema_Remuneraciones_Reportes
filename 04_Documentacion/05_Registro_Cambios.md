# Registro de cambios

## Etapa 1 — Origen transaccional

- Rama: `feature/estructura-datos`.
- Commit: `16b8f18`.
- Se crearon las cuatro carpetas del proyecto y el script de estructura y datos.
- Se incluyeron doce tablas, claves foráneas y generación repetible del trimestre julio–septiembre de 2026.
- Se publicó el mismo estado inicial en `main` y en la rama de trabajo.
- Validación en el entorno de desarrollo: análisis sintáctico T-SQL y cálculo independiente del calendario. El usuario confirmó la creación de la base en su instancia de SSMS; no se adjuntaron todavía evidencias de sus cantidades ni resultados.

## Etapa 2 — Data Mart, ETL y reportes

- Rama: `feature/etl-reportes`.
- Se añadió `02_Creacion_Data_Mart.sql` con cuatro dimensiones, hechos, bitácora y rechazos.
- Se añadió `02_Procedimiento_ETL.sql` con intervalo parametrizado, limpieza, validación, carga transaccional y repetición sin duplicar medidas.
- Se añadieron las vistas SQL, medidas DAX y documentación de conexión, modelo y demostración.
- Se añadió un script ejecutable de conciliación e idempotencia para SSMS.
- Se documentaron las limitaciones del origen: aprobación inferida, asistencia sin proyecto, jornada contractual no historizada y ausencia de datos salariales.
- No se modificó el generador OLTP que el usuario ya ejecutó.
- Validación: los cinco scripts SQL se ejecutaron correctamente en una instancia aislada de SQL Server 2022 Developer. Se comprobó repetición del origen, reinstalación del Data Mart, conciliación, idempotencia y carga parcial.
- Se verificaron normalización de textos, rechazo de estados desconocidos y salidas incoherentes, frontera de las 09:41 y tareas de varios proyectos en una misma jornada sin multiplicar asistencias. Después se restauraron los datos iniciales de esa instancia aislada.
- Se guardaron resultados de ejecución en `Evidencias/01_Resultados_SQL_Server.txt`. La construcción del `.pbix` y las capturas de SSMS y Power BI siguen pendientes; no se presentan como verificadas.

## Etapa 3 — Scripts y organización de entregables

- Rama: `feature/simplificar-scripts`.
- Se respetó la eliminación del README principal realizada en GitHub.
- La creación del Data Mart utiliza `CREATE DATABASE` y `CREATE TABLE` directos, con claves primarias, foráneas y unicidad. Este archivo se ejecuta una sola vez.
- Se retiraron las instrucciones de sesión `ANSI_NULLS` y `QUOTED_IDENTIFIER` de los scripts del proyecto. No se modificó el origen.
- El ETL utiliza un calendario con `WHILE` y `CASE`, sin SQL dinámico ni bloqueo de aplicación. Mantiene la limpieza, el registro de rechazos y la carga transaccional del intervalo.
- Las vistas SQL se trasladaron a `02_Procedimientos_Almacenados` y las medidas DAX a `04_Documentacion`. `03_Vistas_PowerBI` queda reservada para el dashboard y sus exportaciones.
- Se simplificaron las consultas de validación y evidencia, y se añadió una guía de ejecución sin recrear el README principal.
- Se generó `Modelo_Estrella.svg` a partir de las tablas y relaciones de SQL Server. Se añadió una guía para guardar el diagrama en SSMS y subir una captura real.
- Validación: actualización del procedimiento y las vistas sobre una instalación anterior, creación del Data Mart nuevo, cargas repetidas y comparación de los treinta resúmenes mensuales. Las cantidades e indicadores coinciden con la versión anterior. Se verificaron de nuevo los controles de calidad y la carga parcial.
- Resultados: `Evidencias/02_Resultados_Version_Simplificada.txt`. Siguen pendientes el `.pbix` y la captura del diagrama en la instancia local de SSMS.

## Registro de aportes y evidencias

Después de cada aporte real, agregar una entrada con integrante, archivos, cambio, validación y referencia al commit o pull request. Las revisiones se registran desde la cuenta de quien las realiza.
