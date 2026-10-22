# Estado del repositorio

## Incluido

- Scripts del origen, Data Mart, ETL, vistas y validación.
- Padrón alineado con el archivo original y resultados de prueba en SQL Server.
- `03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix`, con las páginas Rendimiento del personal y Bono por efectividad.
- Definición de indicadores y ejemplo de bono, con supuestos visibles.
- Capturas del modelo estrella en SSMS, validación del ETL y página de rendimiento.

## Falta subir

| Archivo | Cómo obtenerlo |
| --- | --- |
| `Evidencias/06_Modelo_PowerBI.png` | Abrir la vista de modelo y capturar las cuatro relaciones entre dimensiones y hechos. |
| `Evidencias/10_Bono_Referencial.png` | Abrir la segunda página y capturar ambas tablas con sus importes y aviso de simulación. |

La captura de rendimiento incluye `(En blanco)` en el selector de meses. Comprobar la relación de tiempo y los datos antes de excluirlo del visual; después puede reemplazarse la captura por la versión final.

## Revisión realizada

Se revisaron los archivos publicados, las imágenes y la estructura guardada del `.pbix`. El informe contiene dos páginas; la primera tiene seis tarjetas, dos selectores y barras. La segunda tiene dos tablas con filtros superior e inferior por IEP y el aviso de simulación.

Se conservó el contenido del archivo completo al dejarlo con el nombre de entrega. Se retiró la versión anterior de ese nombre que no tenía visuales y se reunieron las capturas en una carpeta.

Esta revisión no ejecutó Power BI Desktop ni una conexión en vivo. Antes de exponer, abrir el archivo con SQL Server disponible y comprobar los resultados indicados en la guía.

## Fuera del cierre de GitHub

El PPT queda a cargo del equipo. El guion detallado se prepara el viernes: cinco minutos de PPT y diez de demostración. El informe escrito se entrega aparte. No hace falta añadir más páginas al dashboard para este alcance.
