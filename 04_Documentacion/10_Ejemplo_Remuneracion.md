# Ejemplo de bono por efectividad

Esta página del informe es una simulación académica. No utiliza sueldos reales ni representa una política aprobada por la empresa. Se aplica una misma base referencial a las dos personas para mostrar el efecto del IEP; no establece equivalencia contractual entre jornadas ni una planilla real.

## Supuestos

- Sueldo base mensual referencial: S/ 1.500.
- Bono máximo referencial: 20% de la base, equivalente a S/ 300.
- IEP: puntaje del trimestre seleccionado, en escala de 0 a 100.
- Bono: base × 20% × IEP / 100.
- Remuneración referencial de un mes: base + bono.

Se propone usar el puntaje del trimestre para ejemplificar un bono mensual. No se suman tres sueldos ni se calculan aportes, impuestos, beneficios legales o descuentos. Un IEP bajo reduce el bono simulado, no el sueldo base. Para calcular pagos reales se necesitan sueldos, contratos y reglas confirmadas.

## Medidas

Crear primero las medidas de `Medidas_PowerBI.dax`. Después crear, una por una, las definiciones de [Remuneracion_Referencial.dax](Remuneracion_Referencial.dax).

Dar formato de moneda en soles, dos decimales, a `Sueldo base referencial`, `Bono referencial` y `Remuneracion referencial`. Dar formato porcentual a `Porcentaje maximo de bono`. El IEP sigue en escala de 0 a 100.

Las medidas de bono y remuneración quedan vacías si el contexto no identifica a un solo trabajador o no tiene IEP. No representan un total de planilla.

## Página de Power BI

1. Crear una página llamada **Simulación de bono por efectividad**.
2. Agregar segmentadores de año y mes; seleccionar 2026 y julio, agosto y septiembre. No sincronizar el filtro de proyecto ni un filtro individual de trabajador desde otras páginas.
3. Agregar un cuadro de texto visible: **Simulación académica: base S/ 1.500, bono máximo 20%; no corresponde a una planilla real**.
4. Insertar una tabla con `vw_dim_trabajador[nombre_completo]`, `[IEP]`, `[Sueldo base referencial]`, `[Bono referencial]` y `[Remuneracion referencial]`.
5. En filtros de ese visual, seleccionar `nombre_completo`, tipo **Top N**, opción **Superior / Top**, cantidad 1, por valor `[IEP]`. Aplicar el filtro. Título: **Mayor efectividad del período**.
6. Duplicar la tabla y cambiar el filtro a **Inferior / Bottom**, cantidad 1, por `[IEP]`. Título: **Menor efectividad del período**.
7. Desactivar los totales de ambas tablas. No escribir nombres manualmente ni fijarlos mediante filtros: la selección debe responder al IEP del período.
8. Si se genera una nueva captura, registrar sus filtros y fecha. Ya existe `03_Vistas_PowerBI/Bono por efectividad.png`; se conserva su ubicación.

## Resultado de referencia del trimestre

| Trabajador | IEP | Base referencial | Bono | Remuneración referencial |
| --- | ---: | ---: | ---: | ---: |
| Benjamin Alfonso | 96,00 | S/ 1.500,00 | S/ 288,00 | S/ 1.788,00 |
| Israel Rodrigo Ochoa Mejia | 22,00 | S/ 1.500,00 | S/ 66,00 | S/ 1.566,00 |

Al cambiar el mes o el conjunto de trabajadores, el resultado puede variar. Comparar por IEP evita seleccionar automáticamente a quien tiene más tareas por trabajar más días, aunque el índice no mide por sí solo complejidad ni esfuerzo de las tareas.

La ejecución del ETL está validada en SQL Server. Las medidas DAX y los visuales de esta página deben comprobarse en Power BI Desktop antes de presentar sus capturas como evidencia.
