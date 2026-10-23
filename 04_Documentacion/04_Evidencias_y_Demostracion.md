# Evidencias y demostración T2

## Evidencias que deben capturarse

Las capturas se obtienen al ejecutar el trabajo. No se reemplazan por imágenes fabricadas ni por resultados esperados escritos en la guía de ejecución. Guardarlas en `04_Documentacion/Evidencias`, con estas referencias:

| Archivo | Contenido | Estado |
| --- | --- | --- |
| `03_Modelo_Estrella_SSMS.png` | Diagrama con cuatro dimensiones y hechos. | Incluido. |
| `05_Conciliacion_Idempotencia.png` | Ejecuciones ETL, bitácora, cantidades iguales y repetición sin duplicados. | Incluido; también acredita la ejecución del ETL. |
| `03_Vistas_PowerBI/06_Modelo_PowerBI.png` | Relaciones uno a varios, activas y con dirección única en Power BI. | Incluido en la carpeta del reporte; se conserva su ubicación. |
| `07_Rendimiento_Personal.png` | Seis tarjetas, filtros y barras por trabajador. | Incluido. |
| `10_Bono_Referencial.png` | Comparación de mayor y menor IEP con supuestos monetarios visibles. | Captura complementaria aún no subida; la página existe en el PBIX. |

Las capturas del padrón y de las cantidades del origen pueden añadirse como complemento. Las páginas de asistencia y tareas por proyecto son ampliaciones opcionales y no forman parte del informe de dos páginas. No es necesario crear capturas de páginas que no se entregan.

El informe escrito y sus enlaces de evidencia están en [Informe_Final](Informe_Final). La correspondencia de apartados se explica en [13_Informe_y_Evidencias.md](13_Informe_y_Evidencias.md).

No mostrar contraseñas, PIN, correos personales innecesarios ni otros datos privados. Al adjuntar cada captura, registrar en el pull request la fecha de ejecución, la versión de SQL Server y el archivo utilizado.

## Consultas para las primeras evidencias

```sql
USE [A&SG_OLTP];
GO
SELECT t.ID_Trabajador, e.Nombre_Completo, r.Nombre_Rol, t.HoraIngreso
FROM dbo.Trabajadores t
JOIN dbo.Empleados e ON e.ID_Empleado = t.ID_Empleado
JOIN dbo.Roles_Sistema r ON r.ID_Rol = t.ID_Rol
ORDER BY t.ID_Trabajador;

SELECT MONTH(Fecha_Calculada) AS mes, COUNT(*) AS asistencias
FROM dbo.Asistencia
WHERE Fecha_Calculada BETWEEN '20260701' AND '20260930'
GROUP BY MONTH(Fecha_Calculada) ORDER BY mes;

SELECT MONTH(Fecha) AS mes, COUNT(*) AS tareas
FROM dbo.Tareas
WHERE Fecha BETWEEN '20260701' AND '20260930'
GROUP BY MONTH(Fecha) ORDER BY mes;
GO
```

## Presentación y demostración

Se dispone de **cinco minutos para el PPT** y **diez minutos para ejecutar y demostrar cómo se elaboran los reportes**. El informe escrito se entrega aparte y no se expone.

El guion detallado se preparará el viernes. Debe utilizar las dos páginas incluidas en el informe: rendimiento y bono referencial. La demostración requiere SQL Server disponible y debe incluir el ETL, una verificación de resultados, la creación de una medida o visual y los filtros del informe. Los valores monetarios se explican como simulación académica.

## Lista de entrega

- Ejecutar los scripts que correspondan según `04_Documentacion/00_Orden_Ejecucion.md` y guardar sus resultados.
- Confirmar diez trabajadores y treinta resúmenes mensuales.
- Comprobar que todos los rechazos están resueltos o documentados antes de interpretar un reporte como completo.
- Descargar el `.pbix` incluido y comprobar su conexión, filtros, totales y formatos en Power BI Desktop.
- Adjuntar capturas reales y registrar qué integrante produjo y revisó cada evidencia.
- Revisar y aprobar el pull request antes de integrarlo a `main`.

Registrar los aportes de cada integrante: consultas, documentación, validación, modelo de Power BI o revisión del trabajo.
