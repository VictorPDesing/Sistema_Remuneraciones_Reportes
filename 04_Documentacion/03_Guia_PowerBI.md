# Conexión y reportes en Power BI

## Preparar SQL Server

Ejecutar los archivos en el orden de `04_Documentacion/00_Orden_Ejecucion.md`. Revisar que la última carga esté `Completada`, sin rechazos, y que las cantidades del origen y del destino coincidan. Si la carga está `Con rechazos`, resolver las incidencias antes de presentar resultados como completos.

En SSMS, obtener el servidor correcto con:

```sql
SELECT CONVERT(nvarchar(128), SERVERPROPERTY('ServerName')) AS servidor;
```

Power BI debe poder conectarse a esa misma instancia. El servicio SQL Server debe estar iniciado. Si se usa otra computadora, habilitar TCP/IP, configurar el puerto y permitir únicamente el acceso necesario en el firewall. No publicar SQL Server directamente en Internet. Mantener el cifrado y utilizar un certificado confiable si la conexión lo requiere.

## Conectar las vistas

1. Abrir Power BI Desktop y seleccionar **Obtener datos → SQL Server**.
2. Pegar el nombre del servidor obtenido en SSMS. Escribir `A&SG_DataMart` en **Base de datos**.
3. Seleccionar **DirectQuery** para la demostración con consultas al servidor. También se puede usar **Importar** si se desea un modelo con actualización manual; registrar el modo elegido en la evidencia.
4. Elegir la autenticación que ya funciona con la instancia; para una instalación local normalmente se utiliza Windows.
5. Seleccionar únicamente estas cinco vistas: `vw_dim_trabajador`, `vw_dim_tiempo`, `vw_dim_proyecto`, `vw_dim_administrador` y `vw_rendimiento_kpis`.
6. Cargar y abrir la vista de modelo. No cargar las tablas OLTP ni crear relaciones adicionales entre las dimensiones.

`vw_indicadores_mensuales` se consulta en SSMS para contrastar los resultados. No añadirla como una segunda tabla de hechos al modelo inicial, porque ya resume las mismas medidas. `vw_calidad_cargas` puede importarse como una tabla independiente para una página de calidad, sin relaciones con los hechos.

## Relaciones

Crear estas cuatro relaciones activas, con cardinalidad **uno a varios** y dirección de filtro **única**, desde dimensión hacia hechos:

| Lado uno | Columna | Lado varios | Columna |
| --- | --- | --- | --- |
| `vw_dim_trabajador` | `id_trabajador` | `vw_rendimiento_kpis` | `id_trabajador` |
| `vw_dim_tiempo` | `id_tiempo` | `vw_rendimiento_kpis` | `id_tiempo` |
| `vw_dim_proyecto` | `id_proyecto` | `vw_rendimiento_kpis` | `id_proyecto` |
| `vw_dim_administrador` | `id_administrador` | `vw_rendimiento_kpis` | `id_administrador` |

No relacionar por nombre de persona o proyecto. `id_trabajador_origen` sirve para conciliar con el OLTP, no para sustituir la clave interna de la relación.

Configurar `fecha` como fecha y marcar `vw_dim_tiempo` como tabla de fechas. Ordenar `nombre_mes` por `mes` y `nombre_dia` por `dia_semana`. Para períodos que incluyan varios años, usar año y mes juntos. Ocultar las claves internas a los usuarios del informe.

## Medidas y formato

Abrir `04_Documentacion/Medidas_PowerBI.dax`. Crear cada definición por separado con **Modelado → Nueva medida**; el archivo contiene varias medidas y no se pega completo en una sola. Según la configuración regional, puede ser necesario cambiar las comas de argumentos por punto y coma en el editor DAX.

- Formato **porcentaje, dos decimales**: TPA, ICT, TDT, tasa de finalización, tasa de corrección, tasa de tardanza y cobertura de marcas.
- Formato **decimal, dos decimales**: IEP, horas de permanencia y minutos por tardanza.
- Formato **entero**: cantidades de tareas, asistencias, jornadas y minutos totales.

Las tasas DAX usan valores de 0 a 1; las vistas SQL las muestran de 0 a 100. Un TPA `0,95` en DAX debe verse como `95,00%`, que corresponde a `95,00` en la vista SQL. El IEP se muestra directamente en escala 0 a 100, sin formato de porcentaje.

Usar las medidas explícitas; no crear un promedio de porcentajes. El total de un trimestre debe recalcularse con todas las tareas y asistencias seleccionadas.

## Páginas del informe

### 1. Rendimiento del personal

Segmentadores: año, mes y trabajador. No colocar segmentadores de proyecto ni administrador en esta página.

- Tarjetas: TPA, ICT, TDT, IEP, total de asistencias y total de tareas.
- Barras por trabajador: IEP y tareas sin observaciones.
- Gráfico de líneas por mes: TPA, ICT y TDT.
- Matriz: trabajador, mes, asistencias, tardanzas, tareas completadas, tareas sin observaciones e IEP.

Ordenar las barras por IEP descendente. No fijar manualmente quién ocupa el primer lugar: el gráfico debe reflejar los datos calculados. Los regulares tienen TPA de 100% por las franjas del generador; Benjamin se distingue por el cumplimiento de tareas y el IEP, no por ser el único puntual.

### 2. Asistencia

Segmentadores: año, mes, tipo de jornada y trabajador.

- Tarjetas: total de asistencias, tardanzas, minutos de tardanza y salidas pendientes.
- Columnas apiladas: llegadas a tiempo y tardanzas por trabajador.
- Tabla: trabajador, jornadas esperadas, jornadas sin marca, cobertura de marcas y horas de permanencia.

No denominar las jornadas sin marca como faltas injustificadas. El conjunto inicial tiene todas las jornadas registradas; mostrar cero en ese indicador es un resultado válido. No sincronizar filtros de proyecto de otras páginas hacia esta página.

### 3. Tareas por proyecto

Segmentadores: año, mes, trabajador, proyecto y administrador.

- Tarjetas: total de tareas, tareas pendientes, ICT y TDT.
- Columnas apiladas: completadas, en progreso y asignadas por proyecto.
- Matriz: proyecto, administrador, trabajador, tareas con correcciones y tareas fuera de plazo.

En esta página filtrar `id_proyecto > 0` para ocultar el miembro técnico de asistencia. No mostrar TPA, horas de permanencia ni IEP por proyecto: no existe una atribución de asistencia a proyectos en el origen. El IEP queda vacío al no haber asistencias en un filtro de proyecto real.

### 4. Simulación de bono por efectividad

Construir la comparación entre mayor y menor IEP con [10_Ejemplo_Remuneracion.md](10_Ejemplo_Remuneracion.md). La base y el bono son valores referenciales declarados; no sueldos reales. Las medidas están en `04_Documentacion/Remuneracion_Referencial.dax`.

### 5. Calidad de carga

Opcionalmente cargar `vw_calidad_cargas` y mostrar el identificador, inicio, fin, estado, cantidades extraídas, rechazadas y cargadas. Mostrar la última ejecución y conservar las anteriores como evidencia de repetición. Esta tabla no participa en los cálculos de rendimiento.

## Contraste y actualización

1. Filtrar julio de 2026 sin proyecto ni trabajador: 203 asistencias y 203 tareas.
2. Filtrar agosto: 186 de cada una. Filtrar septiembre: 193 de cada una.
3. Seleccionar el trimestre: 582 de cada una.
4. Contrastar cada trabajador y mes con `dbo.vw_indicadores_mensuales` en SSMS, considerando la escala de porcentajes.
5. Ejecutar nuevamente el ETL en SSMS. En DirectQuery, actualizar los visuales; en Importar, actualizar los datos del modelo. Si persiste información anterior, comprobar el modo de conexión y la caché del informe.
6. Guardar el informe como `Reporte_Rendimiento_Personal.pbix` y subirlo a `03_Vistas_PowerBI` una vez construido. El repositorio todavía no contiene un `.pbix` generado ni capturas de resultados.

Power BI Desktop puede trabajar localmente sin publicar el informe. Publicar en Power BI Service es opcional y requiere permisos/licencia y, si SQL Server está en una computadora local, una puerta de enlace configurada. No afirmar que DirectQuery elimina toda latencia: el rendimiento depende del servidor, las consultas y la red.
