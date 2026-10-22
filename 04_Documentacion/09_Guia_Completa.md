# Guía completa de ejecución y reportes

## 1. Padrón del proyecto

Los identificadores y nombres siguientes proceden del archivo original. No confundir el identificador del empleado con el del trabajador.

| ID trabajador | ID empleado | Nombre completo |
| --- | --- | --- |
| 1 | 2 | Adonis Vasquez |
| 2 | 3 | Benjamin Alfonso |
| 3 | 4 | Celeste Lechuga |
| 5 | 6 | Marco Coila |
| 6 | 7 | Kevin Vega |
| 7 | 8 | Fiorella Alarcon |
| 8 | 9 | Alejandro Guzman |
| 9 | 10 | Israel Rodrigo Ochoa Mejia |
| 10 | 11 | Edu Cruz |
| 11 | 12 | Matias Sebastian Moreno Rodriguez |

El administrador es el empleado 1 y no forma parte del conteo de diez trabajadores. Los trabajadores 2, 9 y 11 tienen jornada L–M–V por la regla académica; los demás, L–V. En el origen todos tienen rol Trabajador, por lo que el ETL aplica la jornada por identificador.

El padrón se toma del origen; las asistencias y tareas de julio, agosto y septiembre de 2026 son el histórico simulado del proyecto. El script de alineación no importa el volcado completo de MySQL ni sus credenciales.

## 2. Continuar si ya se llegó a la validación del ETL

No borrar bases ni recrear tablas. Integrar el pull request del padrón, descargar la rama `main` actualizada con **Code → Download ZIP** y descomprimirla.

Antes de modificar la instalación, realizar una copia de seguridad de ambas bases desde SSMS: botón derecho en la base → **Tasks / Tareas → Back Up / Copia de seguridad**. Elegir una ubicación válida del servidor.

Ejecutar completos, en este orden:

1. `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql`.
2. `01_Base_Datos/03_Alinear_Personal_Origen.sql`.
3. `04_Documentacion/01_Validacion_ETL.sql`.

El segundo archivo valida la instalación y conserva los movimientos históricos al alinear las relaciones. El tercero vuelve a cargar el Data Mart y verifica que las dos cargas produzcan las mismas medidas. Si aparece un error en la alineación, detenerse y revisar el mensaje; no desactivar relaciones ni ejecutar fragmentos por separado.

No usar el generador `01_Estructura_y_Datos.sql` como sustituto de esta corrección. No ejecutar el archivo MySQL adjunto directamente en SSMS.

## 3. Instalación desde cero

Esta sección solo corresponde a una instancia que todavía no tiene las bases del proyecto. Ejecutar con F5 cada archivo completo, en este orden:

1. `01_Base_Datos/01_Estructura_y_Datos.sql`.
2. `01_Base_Datos/02_Creacion_Data_Mart.sql`.
3. `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql`.
4. `02_Procedimientos_Almacenados/03_Vistas_PowerBI.sql`.
5. `04_Documentacion/01_Validacion_ETL.sql`.

La creación del Data Mart se ejecuta una sola vez. El procedimiento y las vistas pueden actualizarse con sus archivos. No es necesario ejecutar la alineación en una instalación nueva con el generador actual.

## 4. Verificar el paso 3: personas, cargas y cantidades

En SSMS:

```sql
USE [A&SG_DataMart];
GO
SELECT COUNT(*) AS total_trabajadores FROM dbo.dim_trabajador;

SELECT id_trabajador_origen, nombre_completo
FROM dbo.dim_trabajador ORDER BY id_trabajador_origen;

SELECT TOP (1) * FROM dbo.vw_calidad_cargas ORDER BY id_carga DESC;

SELECT nombre_completo, mes, total_asistencias, total_tareas, tpa, ict, tdt, iep
FROM dbo.vw_indicadores_mensuales
ORDER BY id_trabajador_origen, mes;
```

Debe haber diez trabajadores y treinta resúmenes mensuales. Cada persona aparece tres veces porque tiene un resumen de julio, uno de agosto y uno de septiembre. Eso no constituye duplicación de empleados. La consulta de duplicados de la validación debe estar vacía.

| Mes | Asistencias | Tareas |
| --- | ---: | ---: |
| Julio de 2026 | 203 | 203 |
| Agosto de 2026 | 186 | 186 |
| Septiembre de 2026 | 193 | 193 |
| Total | 582 | 582 |

La última carga debe estar `Completada`, con cero rechazos. Las 1.164 filas de hechos incluyen filas de asistencia y agrupaciones de tareas: no representan 1.164 asistencias. Guardar las capturas de ejecución y conciliación en `04_Documentacion/Evidencias`.

## 5. Guardar el modelo estrella en SSMS

1. Actualizar el explorador de objetos y expandir `A&SG_DataMart`.
2. Abrir **Database Diagrams / Diagramas de base de datos → New Database Diagram / Nuevo diagrama**.
3. Aceptar la creación de objetos de compatibilidad si SSMS lo solicita y se dispone de permisos.
4. Agregar `dim_trabajador`, `dim_tiempo`, `dim_proyecto`, `dim_administrador` y `fac_rendimiento_kpis`.
5. Colocar los hechos en el centro y las dimensiones alrededor. Deben aparecer las cuatro relaciones.
6. Guardar el diagrama como `Modelo_Estrella_Rendimiento`.
7. Usar **Windows + Shift + S** y guardar la captura en `04_Documentacion/Evidencias/03_Modelo_Estrella_SSMS.png`.

Las relaciones ya están creadas por las claves foráneas; dibujar el diagrama no vuelve a crear las tablas. Consultar [07_Modelo_Estrella_SSMS.md](07_Modelo_Estrella_SSMS.md) para el detalle. El SVG del repositorio es una referencia, no una captura de SSMS.

## 6. Conectar Power BI

En SSMS, ejecutar:

```sql
SELECT SERVERPROPERTY('ServerName') AS servidor;
```

En Power BI Desktop:

1. **Obtener datos → SQL Server**.
2. Escribir el servidor obtenido y la base `A&SG_DataMart`.
3. Seleccionar **DirectQuery** y la autenticación válida para esa instancia. Para la sesión local de Windows, usar las credenciales actuales.
4. Cargar únicamente `vw_dim_trabajador`, `vw_dim_tiempo`, `vw_dim_proyecto`, `vw_dim_administrador` y `vw_rendimiento_kpis`.

No cargar a la vez las tablas OLTP ni `vw_indicadores_mensuales` en este modelo. La vista mensual se utiliza para contrastar resultados en SSMS.

## 7. Relaciones en Power BI

En **Vista de modelo**, configurar estas relaciones activas:

| Dimensión | Columna de ambos lados | Destino |
| --- | --- | --- |
| `vw_dim_trabajador` | `id_trabajador` | `vw_rendimiento_kpis` |
| `vw_dim_tiempo` | `id_tiempo` | `vw_rendimiento_kpis` |
| `vw_dim_proyecto` | `id_proyecto` | `vw_rendimiento_kpis` |
| `vw_dim_administrador` | `id_administrador` | `vw_rendimiento_kpis` |

Cardinalidad **uno a varios**, dimensión del lado 1 y hechos del lado muchos. Dirección de filtro **única** desde dimensión hacia hechos. No relacionar por nombre ni por `id_trabajador_origen`.

Configurar `fecha` como Fecha. Ordenar `nombre_mes` por `mes` y `nombre_dia` por `dia_semana`. Guardar una captura del modelo como `06_Modelo_PowerBI.png` en la carpeta de evidencias.

## 8. Medidas DAX

Abrir [Medidas_PowerBI.dax](Medidas_PowerBI.dax). En Power BI, seleccionar **Modelado → Nueva medida** y crear una definición por vez. No pegar todo el archivo en una sola medida. Si la configuración regional exige punto y coma, sustituir las comas de argumentos por `;`.

Crear las medidas de cantidades del archivo antes de TPA, ICT, TDT e IEP. Las fórmulas principales son:

```dax
TPA = DIVIDE([Llegadas a tiempo], [Total asistencias])
```

```dax
ICT = DIVIDE([Tareas sin observaciones], [Total tareas])
```

```dax
TDT = DIVIDE([Tareas fuera de plazo], [Total tareas])
```

```dax
IEP =
IF(
    ISBLANK([TPA]) || ISBLANK([ICT]) || ISBLANK([TDT]),
    BLANK(),
    100 * ([TPA] * 0.30 + [ICT] * 0.50 + (1 - [TDT]) * 0.20)
)
```

Dar formato de porcentaje con dos decimales a TPA, ICT, TDT y las tasas. El IEP lleva formato decimal con dos decimales, en escala de 0 a 100. Las cantidades son enteros. Las tasas se calculan a partir de las sumas, sin promediar porcentajes mensuales.

## 9. Página: Rendimiento del personal

Crear segmentadores de año, mes y nombre completo del trabajador, tomados de sus dimensiones.

- Tarjetas: Total asistencias, Total tareas, TPA, ICT, TDT e IEP.
- Barras agrupadas: nombre completo en categorías e IEP en valores. Orden descendente por IEP.
- Líneas: nombre del mes en el eje X y TPA, ICT y TDT en el eje Y.
- Matriz: nombre completo en filas y cantidades e indicadores en valores.

No incluir filtros de proyecto o administrador en esta página. La asistencia del origen no tiene asignación a proyectos. Si el reporte ya existía antes de alinear el padrón, actualizar sus datos o visuales para recibir los nombres de las dimensiones; no escribir nombres manualmente.

## 10. Página: Control de asistencia

Segmentadores de año, mes y trabajador.

- Tarjetas: Total asistencias, Llegadas a tiempo, Total tardanzas y Minutos de tardanza.
- Columnas apiladas: trabajador en el eje y Llegadas a tiempo y Total tardanzas como valores.
- Tabla: trabajador, Total asistencias, Total tardanzas, Horas de permanencia y Salidas pendientes.

No sincronizar filtros de proyecto hacia esta página. Las horas de permanencia no son automáticamente horas pagables y una jornada sin marca no demuestra una falta injustificada.

## 11. Página: Cumplimiento de tareas

Segmentadores de año, mes, trabajador, proyecto y administrador.

Agregar `vw_dim_proyecto[id_proyecto]` a **Filtros de esta página**, con condición **mayor que cero**. Excluye el miembro técnico de asistencia.

- Tarjetas: Total tareas, Tareas completadas, Tareas pendientes, ICT y TDT.
- Columnas apiladas: nombre del proyecto en categorías y tareas completadas, en progreso y asignadas en valores.
- Barras: nombre completo del trabajador en categorías y Tareas fuera de plazo en valores.
- Matriz: proyecto y trabajador en filas; Total tareas, Tareas completadas, ICT y TDT en valores.

No mostrar TPA ni IEP por proyecto. Para conocer los campos y detalles de cada visual, consultar [03_Guia_PowerBI.md](03_Guia_PowerBI.md).

## 12. Contrastar los indicadores

Seleccionar el trimestre completo en la página de rendimiento, sin filtros de proyecto ni administrador. Deben verse 582 asistencias y 582 tareas.

| Trabajador | TPA | ICT | TDT | IEP |
| --- | ---: | ---: | ---: | ---: |
| Benjamin Alfonso | 95,00% | 95,00% | 0,00% | 96,00 |
| Israel Rodrigo Ochoa Mejia | 40,00% | 0,00% | 50,00% | 22,00 |
| Matias Sebastian Moreno Rodriguez | 50,00% | 30,00% | 0,00% | 50,00 |

Estos son valores trimestrales. Al filtrar un mes pueden cambiar. En SQL las tasas se muestran en escala de 0 a 100; en DAX se calculan de 0 a 1 y se formatean como porcentajes.

## 13. Página: Simulación de bono por efectividad

Seguir [10_Ejemplo_Remuneracion.md](10_Ejemplo_Remuneracion.md) y crear las medidas de [Remuneracion_Referencial.dax](Remuneracion_Referencial.dax), una por una. Se utiliza una base mensual referencial de S/ 1.500 y un bono máximo del 20%, proporcional al IEP del período. Son supuestos académicos, no datos salariales de la empresa.

Agregar un texto visible que identifique la simulación y dos tablas con nombre, IEP, base, bono y remuneración referencial. Usar el filtro visual Top N superior 1 por IEP para la primera e inferior 1 para la segunda. No fijar nombres manualmente ni filtrar proyectos en esta página.

Para el trimestre completo, Benjamin Alfonso tiene IEP 96: bono de S/ 288 y remuneración referencial de S/ 1.788. Israel Rodrigo Ochoa Mejia tiene IEP 22: bono de S/ 66 y remuneración referencial de S/ 1.566. El sueldo base se conserva en ambos casos. Estas cifras no incluyen una liquidación de beneficios ni aportes.

## 14. Guardar y subir los entregables

Guardar el informe como `03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix`. Si se solicita una versión para visualizar sin Power BI Desktop, exportar también un PDF a esa carpeta.

Guardar capturas reales en `04_Documentacion/Evidencias`:

- `01_Origen_SQL_Server.png`: padrón de diez trabajadores.
- `02_Registros_Trimestre.png`: cantidades por mes.
- `03_Modelo_Estrella_SSMS.png`: diagrama de SSMS.
- `04_Ejecucion_ETL.png`: ejecución y bitácora.
- `05_Conciliacion_Idempotencia.png`: comprobación de las cargas.
- `06_Modelo_PowerBI.png`: relaciones de las vistas.
- `07_Rendimiento_Personal.png`, `08_Asistencia.png` y `09_Tareas_Proyecto.png`: páginas del informe.
- `10_Bono_Referencial.png`: comparación referencial entre mayor y menor IEP.

En GitHub, entrar a cada carpeta y usar **Add file → Upload files**. Registrar el aporte y sus validaciones en `05_Registro_Cambios.md`. No subir el archivo original con credenciales ni capturas de contraseñas o datos de contacto innecesarios.

## 15. Demostración de diez minutos

1. Problema y arquitectura: un minuto.
2. Padrón y datos del trimestre: un minuto.
3. Modelo estrella y grano de los hechos: un minuto.
4. Explicación del procedimiento y ejecución ETL: dos minutos.
5. Bitácora, calidad e idempotencia: un minuto.
6. Dashboards y filtros: tres minutos.
7. Entregables y límites: un minuto.

Explicar que ICT usa completadas sin observaciones como convención de aceptación; no existe una aprobación formal en el origen. El IEP es un índice de rendimiento. La comparación monetaria presentada es una simulación con base y bono declarados, no una política real de remuneraciones.
