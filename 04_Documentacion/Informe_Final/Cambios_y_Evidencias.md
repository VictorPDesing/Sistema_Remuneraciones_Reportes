# Revisión del informe BI

Se utiliza la solución de `b-alfonso/Sistema_Remuneraciones_Reportes`, versión `9726a5470b3ab6cd333edc21e1015d04da9598b3`. El Word original se conserva. La entrega revisada está en `Informe_Final_BI_AySG_Grupo2.docx`; el PDF permite comprobar su presentación.

## Qué se conserva

- El contexto de A&SG S.A.C. y el antecedente Streamlit, MySQL y Clever Cloud.
- El esquema y el padrón como referencia del origen. Los movimientos de julio–septiembre se identifican como simulados.
- La organización por capítulos del formato del curso, el nombre del curso, docente, NRC y equipo.
- Los conceptos de ETL, Data Mart, modelo dimensional, indicadores y visualización, alineados con los archivos finales.

## Cambios realizados

| Parte | Cambio |
| --- | --- |
| Portada, resumen y abstract | Razón social A&SG S.A.C., título BI y alcance T2; se completaron resumen y traducción. |
| 1.1–1.4 | Se diferencia el antecedente MySQL del ETL local en SQL Server y se fija julio–septiembre de 2026. |
| 1.3 | Se conserva un objetivo futuro de Big Data, sin implementación ni evaluación en T2. |
| 1.5 | Criterios demostrables: cantidades, fórmulas, filtros, bitácora y repetición de la carga. |
| 1.6 | Padrón conservado, movimientos simulados, nombres visibles y dimensiones sin versiones históricas. |
| 2.1–2.2 | Se mantienen fundamentos BI y se sustituyen citas incompletas por fuentes técnicas identificables. Se retiraron porcentajes de mejora de otras empresas que no son resultados del proyecto. |
| 2.4 | SQL Server, T-SQL, SSMS, Power BI, DAX y GitHub; MySQL, Clever Cloud y Streamlit como antecedentes. |
| 3.1–3.3 | Arquitectura del repositorio; se retiraron Supabase, PostgreSQL, Deno y el ETL en Python. |
| 3.4.1 | Fórmulas reales: ICT = completadas sin observaciones; TDT = marca FUERA DE PLAZO / total; IEP en puntos. |
| 3.4.2 | Modelo de GitHub: id_rendimiento, id_tiempo, cargo y medidas aditivas. Sin SCD tipo 2. Diccionario completo en anexo B. |
| 3.4.3 | Extracción, limpieza, validación, rechazos, transacción y carga repetible con el procedimiento publicado. |
| 3.4.4 | Dos páginas reales del PBIX; se retiraron gráficos y filtros descritos que no existen en la entrega. |
| 3.6–3.7 | Se separan controles implementados de recomendaciones; orden real de instalación y actualización. |
| Capítulo IV | Validación BI por los tres meses y repetición del trimestre. Sin experimentos NoSQL ni benchmarks inventados. |
| Capítulo V | Rutas, versión, código, pruebas e historial reales. Se atribuyen los dashboards a Fernando Carhuatanta según confirmación del equipo. |
| Capítulo VI | Conteos, dos ejecuciones de la captura, tasas globales, comparación de diez trabajadores y bono referencial. |
| Capítulo VII | Conclusiones y recomendaciones vinculadas con resultados y evidencia. |
| Capítulo VIII | Alcance académico, límites de los indicadores, datos identificables y responsabilidades. |
| Anexos | Manifiesto E-01 a E-16, enlaces permanentes, diccionario, ficha de datos y scripts. |
| 2.3, 3.5 y 5.3 | Apartados reservados, sin contenido de Big Data desarrollado. E-08 y E-14 también quedan reservadas. |

## Capturas reemplazadas

| En el informe | Evidencia utilizada de GitHub |
| --- | --- |
| Arquitectura anterior | Diagrama nuevo elaborado a partir de los scripts actuales: OLTP → procedimiento → Data Mart → vistas → Power BI. |
| Modelo conceptual/físico del otro desarrollo | `04_Documentacion/Evidencias/03_Modelo_Estrella_SSMS.png`. El texto y el diccionario explican el modelo lógico. |
| Relaciones del otro modelo | `03_Vistas_PowerBI/06_Modelo_PowerBI.png`. |
| Validación sin respaldo | `04_Documentacion/Evidencias/05_Conciliacion_Idempotencia.png`. |
| Dashboards del compañero con otro origen | `04_Documentacion/Evidencias/07_Rendimiento_Personal.png` y el archivo `Reporte_Rendimiento_Personal.pbix`. |

Ya están insertadas las capturas disponibles. No necesitas volver a pegar las imágenes del Word anterior.

La captura de la página de bono aún no existe en GitHub. El informe utiliza la tabla calculada, los supuestos y el enlace al PBIX, que contiene esa página. Si quieren añadir la captura como complemento, abrir **Bono por efectividad** en Power BI Desktop, comprobar los importes y guardar `04_Documentacion/Evidencias/10_Bono_Referencial.png`. No se fabricó esa captura.

## Cómo funcionan los enlaces de evidencia

El manifiesto del Word ya contiene los enlaces. Un ejemplo es:

https://github.com/b-alfonso/Sistema_Remuneraciones_Reportes/blob/9726a5470b3ab6cd333edc21e1015d04da9598b3/01_Base_Datos/02_Creacion_Data_Mart.sql

El identificador completo después de `blob/` fija el archivo a una versión. Si después cambia `main`, el enlace continúa mostrando el material evaluado. En Word se abre con **Ctrl + clic**; en PDF, con clic.

Para crear otro enlace desde GitHub: abrir el archivo, pulsar **Y** para obtener el enlace permanente y copiar la dirección. Para un `.pbix`, el docente debe usar **Download raw file** y abrirlo en Power BI Desktop. Ese enlace no es un dashboard web ni requiere Power BI Service.

Se verificó respuesta HTTP 200 en los 27 enlaces distintos de GitHub del informe. El documento incluye además referencias bibliográficas de Microsoft y Kimball; las URL de documentación externa no se usaron como prueba de resultados del proyecto.

## Revisión del equipo antes de entregar

- Confirmar los nombres abreviados de portada y el NRC 26043, conservado del archivo original.
- El reparto fue confirmado por el equipo: Benjamin Alfonso, base de datos; Fernando Carhuatanta, dashboards; Victor Paredes, KPI de BI; Luis Obregón, parte experimental; Diego Garrido, revisión de posibles vulnerabilidades. No se atribuyen commits ajenos ni se asignan porcentajes sin registro. La revisión de seguridad no se presenta como una auditoría formal ni como garantía de ausencia de vulnerabilidades.
- Abrir el PBIX en la computadora de exposición y comprobar la conexión con SQL Server. Esta revisión documental no ejecutó Power BI Desktop.
- Revisar el valor `(En blanco)` del selector de meses. Verificar relaciones y claves antes de ocultarlo. La captura se conserva tal como está publicada.
- Si la institución exige firmas o una ficha individual adicional, deben completarlas sus autores. No se generaron firmas ni aceptaciones empresariales.

No se modificaron scripts SQL, medidas DAX, archivos PBIX ni imágenes existentes de `03_Vistas_PowerBI`. Las guías actualizadas explican dónde está cada evidencia y cuál es el archivo principal de entrega.
