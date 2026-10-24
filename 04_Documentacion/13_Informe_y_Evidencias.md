# Informe BI y evidencias

La solución final utiliza el origen `A&SG_OLTP`, el procedimiento `dbo.usp_cargar_rendimiento`, el destino `A&SG_DataMart` y el reporte `Reporte_Rendimiento_Personal.pbix`. El informe escrito está en [Informe_Final](Informe_Final).

## Alcance común

- Empresa: **A&SG S.A.C.**
- Antecedente: Streamlit con MySQL en Clever Cloud.
- Implementación T2: SQL Server, ETL en T-SQL, modelo estrella, vistas y Power BI Desktop.
- Datos: padrón de diez trabajadores del origen y movimientos simulados de julio–septiembre de 2026.
- Resultado documentado: 582 asistencias, 582 tareas, 1.164 filas de hechos y 30 resúmenes trabajador-mes.
- Indicadores del trimestre: TPA 92,10%, ICT 56,36%, TDT 3,44% e IEP 75,12 puntos.
- Bono: ejemplo académico con base S/ 1.500 y máximo 20%; no es una planilla real.

Los apartados de Big Data no se desarrollan en T2. Solo se mantiene un objetivo futuro en 1.3 del informe.

## Correspondencia con el informe

| Apartado | Archivos que lo respaldan |
| --- | --- |
| 1.1, 1.4 y ficha del dataset | `08_Padron_Trabajadores.md` y `01_Base_Datos/01_Estructura_y_Datos.sql`. |
| 1.5 y requerimientos | `00_Orden_Ejecucion.md`, validación y resultados del padrón. |
| 2.4 y 3.3 | Scripts del origen, Data Mart, procedimiento, vistas y archivo PBIX. |
| 3.4.1 | `11_Indicadores_Dashboard.md`, `Medidas_PowerBI.dax` y vistas SQL. |
| 3.4.2 y anexo B | `01_Base_Datos/02_Creacion_Data_Mart.sql` y captura del modelo SSMS. |
| 3.4.3 | `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql`. |
| 3.4.4 y 6.4 | PBIX principal y capturas de relaciones y rendimiento. |
| Capítulo IV y 5.4 | `01_Validacion_ETL.sql` y `Evidencias/05_Conciliacion_Idempotencia.png`. |
| Capítulo VI | `Evidencias/03_Resultados_Padron_Origen.txt`, conciliación y dashboard. |
| Ejemplo de bono | `10_Ejemplo_Remuneracion.md` y `Remuneracion_Referencial.dax`. |
| Mejoras e historial | `05_Registro_Cambios.md` y commits/pull requests reales. |

## Enlaces de evidencia

El informe fija código, reportes y capturas a la versión `9726a5470b3ab6cd333edc21e1015d04da9598b3`. Los scripts y reportes de esa versión se conservan; esta actualización añade el informe y corrige referencias documentales.

El manifiesto E-01 a E-16 está dentro del Word y en [Informe_Final/Manifiesto_Evidencias.json](Informe_Final/Manifiesto_Evidencias.json). E-08 y E-14 quedan reservadas para Big Data. E-11 y E-16 remiten al propio informe. E-15 enlaza el historial, sin atribuir commits a personas distintas de sus autores registrados.

Para otro archivo: abrirlo en GitHub, pulsar **Y**, copiar el enlace permanente y pegarlo en el manifiesto. El PBIX se descarga con **Download raw file** y se abre en Power BI Desktop; no es una publicación web.

## Capturas y comprobaciones

Ya existen las capturas del modelo SSMS, relaciones de Power BI, conciliación y rendimiento. La captura del bono ya está en `03_Vistas_PowerBI/Bono por efectividad.png`, junto con `Reporte por rendimiento.png`. El informe archivado conserva las referencias del momento en que se preparó; estas guías reflejan las incorporaciones posteriores.

Antes de exponer, abrir el reporte en el equipo de clase y comprobar la conexión y los filtros. La captura existente muestra `(En blanco)` en el selector de meses: revisar la correspondencia de claves y la relación antes de excluir esa opción. No se afirma una nueva ejecución en vivo durante la revisión del documento.

El reparto confirmado por el equipo es: Benjamin Alfonso, base de datos; Fernando Carhuatanta, dashboards; Victor Paredes, KPI de BI; Luis Obregón, parte experimental; Diego Garrido, revisión de posibles vulnerabilidades. El reparto identifica responsabilidades y artefactos, sin atribuir commits a cuentas distintas de las registradas ni asignar porcentajes sin registro.
