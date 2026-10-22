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

## Etapa 4 — Padrón de trabajadores

- Rama: `feature/personal-origen`.
- Se alinearon nombres, identificadores de empleado y trabajador, cargos, códigos y roles con el padrón original proporcionado.
- Se añadió `01_Base_Datos/03_Alinear_Personal_Origen.sql` para actualizar las instalaciones existentes sin eliminar asistencias ni tareas. El trabajador 5 conserva el histórico del registro anterior correspondiente.
- Se actualizó el generador para nuevas instalaciones. No se copian del archivo adjunto PIN, correos ni teléfonos.
- El ETL identifica las jornadas de practicantes mediante los trabajadores 2, 9 y 11, porque el origen solo distingue trabajador y administrador.
- Se actualizaron las evidencias y la guía completa. La validación muestra diez personas y treinta resúmenes mensuales; los resultados vigentes están en `Evidencias/03_Resultados_Padron_Origen.txt`.
- Se añadió una página propuesta de bono por efectividad con base y porcentaje referenciales explícitos, junto con sus medidas DAX. Los visuales y las medidas quedan pendientes de comprobar en Power BI Desktop.
- Comprobación en SQL Server: conservación de identificadores de asistencia y tarea, fechas y estados; segunda ejecución de la alineación sin duplicados; recarga del Data Mart con el padrón de origen.

## Etapa 5 — Lectura de indicadores

- Se añadió un diccionario de tarjetas y medidas auxiliares con fórmulas, interpretación y sentido de mejora.
- Se documentó la lectura de los filtros y el ejemplo de Edu Cruz en septiembre: 22 asistencias, 22 tareas, ICT 59,09% e IEP 79,55.
- Se incluyeron frases de apoyo para la demostración y la distinción entre cumplimiento sin observaciones, finalización y entrega fuera de plazo.
- No se modificaron los scripts SQL ni las medidas DAX.

## Registro de aportes y evidencias

Después de cada aporte real, agregar una entrada con integrante, archivos, cambio, validación y referencia al commit o pull request. Las revisiones se registran desde la cuenta de quien las realiza.
