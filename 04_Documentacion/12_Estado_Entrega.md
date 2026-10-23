# Estado del repositorio

## Incluido

- Scripts del origen, Data Mart, ETL, vistas y validación.
- Padrón alineado con el archivo original y resultados de prueba en SQL Server.
- `03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix`, con las páginas Rendimiento del personal y Bono por efectividad.
- Definición de indicadores y ejemplo de bono, con supuestos visibles.
- Capturas del modelo estrella en SSMS, validación del ETL y página de rendimiento.
- Captura de las cuatro relaciones activas de Power BI en `03_Vistas_PowerBI/06_Modelo_PowerBI.png`.
- Informe BI y manifiesto de evidencias en `Informe_Final`, con los enlaces de código fijados a la versión `9726a54`.

## Captura complementaria

| Archivo | Cómo obtenerlo |
| --- | --- |
| `Evidencias/10_Bono_Referencial.png` | Abrir la segunda página y capturar ambas tablas con sus importes y aviso de simulación. |

La segunda página existe en el archivo PBIX. El informe escrito incluye la fórmula y la tabla de resultados del bono; no presenta una captura inexistente como evidencia de ejecución.

En la versión revisada, `Bono_por_efectividad.pbix` y `Reporte_Rendimiento_Personal.pbix` tienen el mismo contenido. Para la entrega se utiliza el segundo nombre; ambas copias se conservan.

La captura de rendimiento incluye `(En blanco)` en el selector de meses. Comprobar la relación de tiempo y los datos antes de excluirlo del visual; después puede reemplazarse la captura por la versión final.

## Revisión realizada

Se revisaron los archivos publicados, las imágenes y la estructura guardada del `.pbix`. El informe contiene dos páginas; la primera tiene seis tarjetas, dos selectores y barras. La segunda tiene dos tablas con filtros superior e inferior por IEP y el aviso de simulación.

Se conservó el contenido del archivo completo al dejarlo con el nombre de entrega. Se retiró la versión anterior de ese nombre que no tenía visuales y se reunieron las capturas en una carpeta.

Esta revisión no ejecutó Power BI Desktop ni una conexión en vivo. Antes de exponer, abrir el archivo con SQL Server disponible y comprobar los resultados indicados en la guía.

## Fuera del cierre de GitHub

El PPT queda a cargo del equipo. El guion detallado se prepara el viernes: cinco minutos de PPT y diez de demostración. El informe escrito se entrega aparte. No hace falta añadir más páginas al dashboard para este alcance.
