# Lectura de las tarjetas del dashboard

Las tarjetas responden a los filtros seleccionados. Si se elige un mes y un trabajador, muestran ese caso; al quitar esos filtros, resumen el conjunto seleccionado. El título general del trimestre no significa que las tarjetas estén mostrando los tres meses cuando un segmentador tiene seleccionado solo uno.

## Tarjetas principales

| Tarjeta | Significado | Cálculo | Interpretación |
| --- | --- | --- | --- |
| Total asistencias | Cantidad de registros de entrada válidos. | Suma de `total_asistencias`. | Es un conteo de marcaciones, no de personas ni de horas. |
| Total tareas | Cantidad de tareas válidas asignadas en el período. | Suma de `total_tareas`. | Incluye completadas, en progreso y asignadas. El período corresponde a su fecha de asignación. |
| TPA | Tasa de puntualidad. | Llegadas a tiempo / total asistencias × 100. | Cuanto mayor, mejor puntualidad. Hasta las 09:40:59 es a tiempo; desde las 09:41:00 es tardanza. |
| ICT | Índice de cumplimiento de tareas. | Completadas sin observaciones / total tareas × 100. | Cuanto mayor, mayor proporción de tareas que cumple el criterio de aceptación del proyecto. |
| TDT | Tasa de devolución de tareas, según la definición adoptada para este proyecto. | Tareas con `FUERA DE PLAZO` en observaciones / total tareas × 100. | Cuanto menor, mejor. Mide la marca de entrega fuera de plazo; no cuenta todas las correcciones como devoluciones. |
| IEP | Índice de efectividad ponderado. | TPA × 0,30 + ICT × 0,50 + (100 − TDT) × 0,20. | Puntaje de 0 a 100. Combina puntualidad, cumplimiento y penalización por entregas fuera de plazo. No es un monto de dinero. |

El origen no tiene un campo de aprobación formal. Por eso, para ICT se usa la convención **completada sin observaciones**. No se debe presentar ese indicador como una aprobación explícita de un supervisor.

## Ejemplo: Edu Cruz, septiembre de 2026

Las tarjetas muestran 22 asistencias, 22 tareas, TPA 100%, ICT 59,09%, TDT 0% e IEP 79,55.

- **22 asistencias:** existen 22 registros de entrada válidos para ese trabajador y mes.
- **22 tareas:** se asignaron 22 tareas válidas en septiembre.
- **TPA 100%:** las 22 entradas fueron clasificadas a tiempo.
- **ICT 59,09%:** 13 de las 22 tareas están completadas sin observaciones. Las nueve restantes pueden estar pendientes o tener observaciones; no se deduce su estado exacto a partir de esta tarjeta.
- **TDT 0%:** ninguna de las 22 tareas tiene el marcador de entrega fuera de plazo. Esto no significa que todas estén completadas ni que ninguna tenga correcciones.
- **IEP 79,55:** el puntaje combina los tres indicadores con sus pesos.

```text
IEP = 100 × 0,30 + (13 / 22 × 100) × 0,50 + (100 − 0) × 0,20
IEP = 79,5454... → 79,55 puntos
```

El cálculo utiliza la precisión disponible; el formato de la tarjeta redondea a dos decimales. No se promedian porcentajes mensuales para calcular el trimestre: se suman numeradores y denominadores y se vuelve a calcular cada tasa.

## Medidas auxiliares y complementarias

| Medida | Qué representa |
| --- | --- |
| Llegadas a tiempo | Entradas anteriores a las 09:41:00. |
| Total tardanzas | Entradas desde las 09:41:00. |
| Tareas completadas | Tareas cuyo estado es Completada, tengan o no observaciones. |
| Tareas sin observaciones | Tareas completadas con observaciones vacías o nulas después de la limpieza. Es el numerador del ICT. |
| Tareas fuera de plazo | Tareas con el texto `FUERA DE PLAZO` en observaciones. Es el numerador del TDT. |
| Tareas en progreso | Tareas cuyo estado es En Progreso. |
| Tareas asignadas | Tareas cuyo estado actual es Asignada. No confundir con Total tareas, que incluye todos los estados válidos. |
| Tareas pendientes | Suma de tareas en progreso y asignadas. |
| Tasa de finalización | Completadas / total tareas. Incluye completadas con observaciones; por eso puede ser mayor que ICT. |
| Minutos de tardanza | Minutos posteriores a las 09:40 en entradas clasificadas tarde, redondeando hacia arriba las fracciones. No son descuentos salariales. |
| Horas de permanencia | Tiempo registrado entre entrada y salida, sin descontar pausas. No equivale por sí solo a horas pagables. |
| Salidas pendientes | Asistencias válidas sin hora de salida registrada. |

## Filtros y valores vacíos

- El segmentador de mes modifica el período analizado y el de trabajador selecciona la persona.
- Si un denominador es cero, la tasa queda vacía; no se reemplaza por un cero que aparentaría un resultado medido.
- El IEP queda vacío si no puede calcularse alguno de sus componentes.
- La asistencia no tiene proyecto ni administrador en el origen. Los reportes por proyecto usan las medidas de tareas; no deben atribuir puntualidad ni IEP a cada proyecto.
- Si el selector de mes muestra **(En blanco)**, revisar que la relación sea `vw_dim_tiempo[id_tiempo]` → `vw_rendimiento_kpis[id_tiempo]`, que no haya fechas o nombres de mes nulos en la consulta y que las claves de hechos tengan correspondencia en tiempo. No asumir que representa un cuarto mes ni ocultarlo como sustituto de verificar el modelo.

## Frases para la demostración

**Puntualidad:** «TPA nos indica qué proporción de las entradas cumple el horario con la tolerancia definida».

**Cumplimiento:** «ICT cuenta las tareas completadas sin observaciones sobre todas las asignadas en el período».

**Fuera de plazo:** «En este proyecto, TDT identifica las tareas con la observación de entrega fuera de plazo; buscamos que sea bajo».

**Resultado conjunto:** «IEP pondera 30% puntualidad, 50% cumplimiento y 20% ausencia de entregas fuera de plazo. Se presenta como puntaje sobre 100».

Para el ejemplo monetario, consultar [10_Ejemplo_Remuneracion.md](10_Ejemplo_Remuneracion.md). La base y el bono son supuestos académicos; las tarjetas de KPIs no contienen sueldos reales.
