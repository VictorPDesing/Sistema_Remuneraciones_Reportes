# Guía del proyecto

El proyecto usa SQL Server para preparar los datos y Power BI para mostrar los resultados. El informe de entrega es [Reporte_Rendimiento_Personal.pbix](../03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix) y tiene dos páginas: **Rendimiento del personal** y **Bono por efectividad**.

## 1. Crear las bases desde cero

En SSMS, ejecutar completos con F5 estos archivos, en orden:

1. `01_Base_Datos/01_Estructura_y_Datos.sql`.
2. `01_Base_Datos/02_Creacion_Data_Mart.sql`.
3. `02_Procedimientos_Almacenados/02_Procedimiento_ETL.sql`.
4. `02_Procedimientos_Almacenados/03_Vistas_PowerBI.sql`.
5. `04_Documentacion/01_Validacion_ETL.sql`.

El segundo archivo crea el Data Mart y se ejecuta una sola vez. No repetirlo si la base ya existe. El padrón usa los nombres del archivo original; los registros de julio a septiembre son datos simulados para el trabajo académico.

## 2. Si las bases ya existen

No borrar tablas ni crear otra vez las bases. Para actualizar el procedimiento o las vistas, ejecutar sus archivos de la carpeta `02_Procedimientos_Almacenados`.

Si todavía se tiene la versión anterior del padrón, hacer una copia de seguridad y seguir [08_Padron_Trabajadores.md](08_Padron_Trabajadores.md). Si los diez nombres ya son correctos, no hace falta repetir la corrección.

Para cargar otra vez el trimestre:

```sql
USE [A&SG_DataMart];
GO
EXEC dbo.usp_cargar_rendimiento '20260701', '20260930';
GO
```

El procedimiento toma los datos, limpia textos, revisa errores y carga el resultado. Los registros que no cumplen las reglas quedan anotados en `rechazos_etl`; el resumen de cada ejecución queda en `bitacora_etl`. Ejecutar una carga a la vez.

## 3. Revisar los resultados

Ejecutar `04_Documentacion/01_Validacion_ETL.sql`. Debe mostrar diez trabajadores, ninguna fila en la consulta de duplicados y una carga completada sin rechazos.

| Mes de 2026 | Asistencias | Tareas |
| --- | ---: | ---: |
| Julio | 203 | 203 |
| Agosto | 186 | 186 |
| Septiembre | 193 | 193 |
| Total | 582 | 582 |

Las cantidades del origen y del Data Mart deben coincidir. Hay treinta resúmenes: uno por trabajador y mes. Las tres filas de cada persona no son empleados duplicados.

El modelo estrella tiene cuatro dimensiones y una tabla de hechos. Cada fila de hechos corresponde a trabajador, fecha, proyecto y administrador. La asistencia usa proyecto y administrador cero porque el origen no le asigna esos datos. Ver [02_Modelo_y_Reglas.md](02_Modelo_y_Reglas.md) y [07_Modelo_Estrella_SSMS.md](07_Modelo_Estrella_SSMS.md).

## 4. Abrir el informe en Power BI

1. Mantener SQL Server iniciado y completar la carga ETL.
2. Descargar y abrir `03_Vistas_PowerBI/Reporte_Rendimiento_Personal.pbix`.
3. Si cambió el servidor, entrar en **Archivo → Opciones y configuración → Configuración de origen de datos → Cambiar origen**. Usar el servidor de la instalación y la base `A&SG_DataMart`.
4. Iniciar la conexión con las credenciales válidas y actualizar los visuales.

El archivo ya contiene las medidas y los visuales. No volver a crearlos para abrirlo. Para construir un informe nuevo, seguir [03_Guia_PowerBI.md](03_Guia_PowerBI.md).

## 5. Páginas del informe

**Rendimiento del personal:** seis tarjetas, filtros de mes y trabajador y barras de IEP por persona. Sin filtros debe mostrar 582 asistencias y 582 tareas.

**Bono por efectividad:** dos tablas seleccionan al trabajador con mayor y menor IEP. Se usa una base referencial de S/ 1.500 y un bono máximo del 20%, proporcional al puntaje. El texto del informe aclara que es una simulación, no una planilla real.

| Trabajador, trimestre completo | TPA | ICT | TDT | IEP | Bono | Total referencial |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Benjamin Alfonso | 95% | 95% | 0% | 96 | S/ 288 | S/ 1.788 |
| Israel Rodrigo Ochoa Mejia | 40% | 0% | 50% | 22 | S/ 66 | S/ 1.566 |

Los resultados cambian al seleccionar otros períodos. El significado de las tarjetas está en [11_Indicadores_Dashboard.md](11_Indicadores_Dashboard.md) y la fórmula del bono en [10_Ejemplo_Remuneracion.md](10_Ejemplo_Remuneracion.md).

Las páginas detalladas de asistencia o tareas por proyecto son posibles ampliaciones; no forman parte de esta entrega de dos páginas.

## 6. Archivos y evidencias

Guardar las versiones actualizadas con el mismo nombre `Reporte_Rendimiento_Personal.pbix`. El PDF es opcional. Reunir las capturas en `04_Documentacion/Evidencias`:

- `03_Modelo_Estrella_SSMS.png`: modelo de SQL Server.
- `05_Conciliacion_Idempotencia.png`: ejecución del ETL y comprobación de las cargas.
- `06_Modelo_PowerBI.png`: relaciones en Power BI.
- `07_Rendimiento_Personal.png`: primera página.
- `10_Bono_Referencial.png`: segunda página.

Subir los archivos con **Add file → Upload files** y registrar el cambio en `05_Registro_Cambios.md`. Consultar [12_Estado_Entrega.md](12_Estado_Entrega.md) para ver qué está incluido y qué falta.

La presentación tiene cinco minutos de PPT y diez de ejecución y demostración. El guion se preparará el viernes. El informe escrito se entrega aparte y no se expone.
