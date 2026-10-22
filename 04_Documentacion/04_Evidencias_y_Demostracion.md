# Evidencias y demostración T2

## Evidencias que deben capturarse

Las capturas se obtienen al ejecutar el trabajo. No se reemplazan por imágenes fabricadas ni por resultados esperados escritos en la guía de ejecución. Guardarlas en `04_Documentacion/Evidencias`, con estas referencias:

| Archivo | Contenido verificable |
| --- | --- |
| `01_Origen_SQL_Server.png` | Bases creadas y consulta de los diez trabajadores, con rol y jornada. |
| `02_Registros_Trimestre.png` | Cantidades de asistencias y tareas por mes en el OLTP. |
| `03_Modelo_Estrella_SSMS.png` | Diagrama guardado en SSMS con cuatro dimensiones, tabla de hechos y sus relaciones. |
| `04_Ejecucion_ETL.png` | `EXEC dbo.usp_cargar_rendimiento` y resultado de la bitácora. |
| `05_Conciliacion_Idempotencia.png` | Cantidades iguales entre origen y destino, consulta sin duplicados y mensaje final del script de validación. |
| `06_Modelo_PowerBI.png` | Relaciones uno a varios y dirección única en Power BI. |
| `07_Rendimiento_Personal.png` | KPIs, filtros y matriz de trabajadores. |
| `08_Asistencia.png` | Puntualidad, tardanzas y jornadas de practicantes. |
| `09_Tareas_Proyecto.png` | Estados de tareas, observaciones y proyectos. |

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

## Guion de diez minutos

| Tiempo | Demostración |
| --- | --- |
| 0:00–1:00 | Problema: el sistema anterior combinaba registro operativo y reportes; se propone separar OLTP y Data Mart en SQL Server. No afirmar una mejora de latencia medida sin tener mediciones comparables. |
| 1:00–2:00 | Mostrar el origen, los diez trabajadores y el período. Explicar que los datos históricos son simulados sobre el esquema del caso. |
| 2:00–3:00 | Presentar el modelo estrella, el grano y por qué la asistencia no se reparte entre proyectos. |
| 3:00–5:00 | Abrir el procedimiento y explicar extracción, limpieza de estados, tratamiento de observaciones, rechazos y transformación de medidas. Ejecutar el ETL. |
| 5:00–6:00 | Mostrar bitácora, conciliación y repetición sin duplicados. Explicar la transacción y el reemplazo del período. |
| 6:00–8:30 | Mostrar Power BI: cambiar mes y trabajador, comparar perfiles y revisar tareas por proyecto. Explicar TPA, ICT, TDT e IEP con los valores del informe. |
| 8:30–9:30 | Mostrar la guía de ejecución, las evidencias y el pull request con los cambios y revisiones reales del equipo. |
| 9:30–10:00 | Explicar límites: aprobación inferida, sin sueldo ni fórmula de pago y sin calendario de licencias. Indicar los datos necesarios para una siguiente entrega. |

## Lista de entrega

- Ejecutar los scripts que correspondan según `04_Documentacion/00_Orden_Ejecucion.md` y guardar sus resultados.
- Confirmar diez trabajadores y treinta resúmenes mensuales.
- Comprobar que todos los rechazos están resueltos o documentados antes de interpretar un reporte como completo.
- Construir y guardar el `.pbix`; comprobar filtros, totales y formatos.
- Adjuntar capturas reales y registrar qué integrante produjo y revisó cada evidencia.
- Revisar y aprobar el pull request antes de integrarlo a `main`.

Registrar los aportes de cada integrante: consultas, documentación, validación, modelo de Power BI o revisión del trabajo.
