# Errores y pendientes — lista final — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Fecha:** 13/11/2026 · **App evaluada:** v3 (`iqual_integrado_v3`, CONTEXTO §20)
**Qué es:** todo lo que falta o está sin confirmar, **agrupado por responsable** (Usuario / Linares y la escuela / Otro), con **el paso concreto** de cada uno y ordenado **de más urgente a menos urgente**.
**Cómo se obtuvo:** un script buscó `[COMPLETAR`, `🔶` y «sin probar / no se probó / no probado» en todos los `.md` que tengo (los de `docs_proyecto`, los de Arce Thiago y Cabrera Ulises y 4 y los míos); además, búsquedas por texto en el código de la v3 y una lectura de `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`. **No ejecuté la app ni compilé nada.**
**Qué no recibí:** `docs_otros.zip` (documentos revisados de Arce Thiago y Cabrera Ulises, 2 y 4), los scripts `iqual_sqlite.sql`, `05_Backend_Grupo00.sql` y `consultas_demo.sql`, ni las capturas nuevas. Lo que depende de eso queda marcado.
**Fecha del Demo Day:** `[COMPLETAR: fecha y hora del Demo Day]` (el orden de abajo asume que es pronto).

---

## 1. Usuario (Arce Thiago / Cabrera Ulises)
Ordenado de lo más urgente a lo menos.

| Orden | Qué hacer (paso concreto) | Para qué | Depende de |
|---|---|---|---|
| U-01 | **Compilar la app v3 y abrirla en la computadora del Demo Day:** abrir `CMakeLists.txt` en Qt Creator, kit Desktop Qt 6.12.0 MinGW 64-bit, ejecutar `PROYECTO_IQUAL`. Mirar el título de la ventana: tiene que decir «· MySQL» o «· MySQL (ODBC)». | Sin esto no hay demo | O-01 (faltan `iqual_sqlite.sql` y los `harness*.cpp` en el zip) |
| U-02 | **Instalar MySQL Server y cargar `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`** (después `05_Backend_Grupo00.sql`) siguiendo `GUIA_INSTALACION_MYSQL.md`; verificar que hay **47 tablas** y que `iqual.ini` apunta a esa base | La app no crea las tablas en MySQL | — |
| U-03 | **Probar el driver en Windows** (`GUIA_CONEXION_APP_MYSQL.md`, camino A: MySQL Connector/ODBC Unicode de 64 bits). Si falla, plan B: `motor=sqlite` en `iqual.ini`. Anotar qué pasó | Es lo que más riesgo tiene: «no probado» (🔶 de ambas guías) | U-01, U-02 |
| U-04 | **Ensayar la demo completa** con `GUION_PITCH.md` §3 y cronometrar (meta 6 min). Volver a cargar la base después de cada ensayo | La demo cambia datos | U-01 a U-03 |
| U-05 | **Pasar a `GUION_PITCH.md` el texto exacto del Árbol de Problemas** (diapositiva 1) y repartir quién habla en cada diapositiva | El guion tiene `[COMPLETAR]` ahí | — |
| U-06 | **Armar el Pitch Deck** (5 diapositivas: Problema, Solución, Competencia, Costos y Cierre; la demo va sin diapositiva) | Entregable de la semana 6 | U-05, U-08 |
| U-07 | **Completar el presupuesto:** sumar las horas por rol de la bitácora, fijar el valor hora y su criterio, cargar infraestructura de la escuela, elegir el modelo (sugerido: llave en mano + soporte) y el precio | Sin cifras no hay presupuesto ni ROI (`PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`) | L-02 (datos de la escuela) |
| U-08 | **Cargar en `GUION_PITCH.md` diapositiva 5 los totales** de U-07 | El pitch no puede decir cifras que no están | U-07 |
| U-09 | **Ejecutar los 337 casos de prueba** (`CASOS_PRUEBA_CONSOLIDADO.md`), empezando por login, registro, objetos, préstamo, sectores, Tienda (pestañas 0 y 3) y Educación Física. Anotar OK / FALLA / NO PROBADO | Hoy hay 0 resultados cargados | U-01, U-02 |
| U-10 | **Recontar** el informe con los resultados: pedirme el recuento o volver a correr el mismo script (método en `INFORME_PRUEBAS.md` §3) | `INFORME_PRUEBAS.md` | U-09 |
| U-11 | **Sacar capturas reales de la v3** para los manuales: las tres que faltan (`cuenta_cambio_curso_aviso`, franja gris de Educación Física con un día «(choca con tu horario)», ventana de foto con doble clic) y las que cambiaron (placeholder de Higiene, «Ese ya es tu curso.») | Manuales de usuario | U-01 |
| U-12 | **Exportar los PNG de los diagramas Codd y Chen desde draw.io** (los XML están) y guardarlos en `/db` | Entregable de Bases de Datos (CONTEXTO §20) | — |
| U-13 | **Completar los datos reales** con la plantilla de datos reales (`plantilla_datos_reales`, de Arce Thiago y Cabrera Ulises) | CONTEXTO §20 | — |
| U-14 | **Decidir** lo que quedó por defecto y decirlo por escrito: U04 login (5 intentos, sin recuperación), E4-05 (el Alumno crea cursos inexistentes), ERR-08, E-10 (hash del PIN de grupo), E-12 (botón Inscribirme), E-06 (Reservar habilitado sin stock) | Mientras no decidas, los documentos describen la decisión por defecto | — |
| U-15 | **Probar `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` en MySQL 8 de Oracle** (se probó en MariaDB 10.11) y, si lo piden, `03_ModeloSQL_Grupo00_sqlserver.sql` en SQL Server 2005 | Entregables de Bases de Datos | — |
| U-16 | **Medir rendimiento** con muchos productos con foto (E-04) y con muchos datos (RNF03); y ver cómo se comporta la ventana al cambiar de tamaño | Hoy están sin medir | U-01, U-02 |
| U-17 | Decidir si se **corrigen los errores abiertos de usabilidad** (sección 4) y pedírselos a Arce Thiago y Cabrera Ulises en un pedido aparte | Son todos de gravedad baja | — |

## 2. Linares (el profesor) y la escuela
| Orden | Qué hace falta (paso concreto) | Para qué |
|---|---|---|
| L-01 | **Confirmar por escrito que MySQL es el motor aceptado** (hoy es decisión del usuario). Cómo: mostrarle `GUIA_INSTALACION_MYSQL.md` y el resultado de `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` cargado, y preguntarle | Lo dicen todos los documentos; si dice otra cosa hay que volver a SQL Server |
| L-02 | **Datos de la escuela:** cantidad de alumnos y de usuarios simultáneos; qué infraestructura (servidor, red) tiene | Presupuesto (`PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md` §4) |
| L-03 | **Quién restablece la contraseña** en el colegio (la app no tiene recuperación) y **a quién se pide ayuda / a quién se avisa** | Manuales de usuario (Arce Thiago y Cabrera Ulises y 4), `requerimientos.md`, `MANUAL_TECNICO.md` |
| L-04 | **Quién entrega el PIN de personal** y cómo se pide (para registrar Profesor, Preceptor o Maestranza) | `MANUAL_USUARIO_ACCESO_OBJETOS_PRESTAMO.md` |
| L-05 | **Qué sistema usa hoy la escuela** para notas y asistencia, si lo hay | `ANALISIS_COMPETENCIA.md`, pitch |
| L-06 | Si el proyecto **puede comercializarse** (propiedad del trabajo escolar) | Presupuesto y modelo de negocio |
| L-07 | **Carros C1 a C5 o solo C4 y C5**: el catálogo admite los cinco y la demo usa C4 y C5 | `cambios-respecto-al-diseno-inicial.md` (inconsistencia N) |
| L-08 | Política de **datos personales de los alumnos** | Pregunta de reserva del pitch |

## 3. Otro (Arce Thiago y Cabrera Ulises, 1, 2, 4)
| Orden | Responsable | Qué hacer (paso concreto) | Por qué |
|---|---|---|---|
| O-01 | **Arce Thiago y Cabrera Ulises** | Incluir en el repositorio de entrega (y en `app_codigo.zip`) los **`harness*.cpp`** y **`iqual_sqlite.sql`**, o sacar el bucle `foreach(h harness …)` del `CMakeLists.txt` y el `<file>iqual_sqlite.sql</file>` del `.qrc` | El zip de la v3 trae `recursos/` pero **no** estos archivos: CMake falla al configurar y `rcc` falla al compilar |
| O-02 | **Arce Thiago y Cabrera Ulises** | **Compilar la v3** y confirmar (CONTEXTO §20 dice harness3 y harness4 con 0 fallas) | Yo no pude compilar |
| O-03 | **Arce Thiago y Cabrera Ulises** | **Actualizar CONTEXTO §8 y §9 y el encabezado**: (a) el título dice «VERSIÓN 2.9» y el prompt dice v3.0; (b) §8 dice que `alumno2` es Electrónica (el script dice **Óptica**), que las reservas de sectores tienen fecha fija (el script MySQL usa `CURDATE()` +1 y +2) y que «Llaves con llavero rojo» está «En reclamo» con un reclamo (el script: **Disponible con dos reclamos pendientes**, de `alumno1` y `alumno2`); (c) §9 todavía dice «la base es un archivo local, una sola PC» y «auditoría sin pantalla» | Contradicen al script y a la app v3 |
| O-04 | **Arce Thiago y Cabrera Ulises** | Confirmar las **fechas de las reservas de sectores en `iqual_sqlite.sql`** (el embebido) | Yo solo vi el de MySQL |
| O-05 | **Arce Thiago y Cabrera Ulises** | Entregar `docs_otros.zip` revisado y verificar que sus casos y manual ya no digan «hoy falla» de ERR-01, 02, 05, 06, 07 ni pidan «quitar esta frase si se corrige ERR-01» (`MANUAL_USUARIO_ACCESO_OBJETOS_PRESTAMO.md`, línea 104). Incluir **ERR-20 a ERR-23** (el CONTEXTO nombra ERR-23) y los casos nuevos | En mis copias esos textos siguen viejos: en el consolidado ajusté 10 casos a la v3, pero no puedo editar los originales |
| O-06 | **Arce Thiago y Cabrera Ulises** | Lo mismo para Higiene, Sectores y Mi cuenta (E4-03, E4-04, E4-06 corregidos en la v3; placeholder nuevo de Higiene) y **actualizar el `README_proyecto.md`** (todavía dice 44 tablas, SQLite por defecto, «Buffet Paralelo» y «Planillas de Taller») y la estructura final del repositorio | README desactualizado |
| O-07 | **Arce Thiago y Cabrera Ulises** | Entregar los scripts que no recibí (`iqual_sqlite.sql`, `05_Backend_Grupo00.sql`, `consultas_demo.sql`) para poder verificar «5 procedimientos» y «10 consultas de demostración» contra el archivo | Hoy esos números los tomo de CONTEXTO §19.1 y de `GUIA_INSTALACION_MYSQL.md` |
| O-08 | **Arce Thiago y Cabrera Ulises** | Revisar las dos guías con 🔶 (`GUIA_INSTALACION_MYSQL.md` §1, `GUIA_CONEXION_APP_MYSQL.md` §3): quedan «sin probar en Windows» hasta que lo pruebe el usuario (U-03) | Marca de «sin probar» |
| O-09 | **Arce Thiago y Cabrera Ulises** | Confirmar el **estado (Corregido / Abierto)** de los errores de Arce Thiago y Cabrera Ulises y 4 que no figuran en CONTEXTO §19.2 ni §20 | Sus documentos no tienen columna Estado |
| O-10 | **Arce Thiago y Cabrera Ulises (yo)** | Volver a correr el conteo de `INFORME_PRUEBAS.md` y `CASOS_PRUEBA_CONSOLIDADO.md` cuando lleguen los documentos nuevos de Arce Thiago y Cabrera Ulises y 4 | Hoy usan los de la etapa de cierre |

## 4. Errores abiertos (app v3)
**24 abiertos (y 1 a verificar)**, todos de gravedad baja; ninguno de gravedad alta. Detalle en `INFORME_PRUEBAS.md` §5 y en cada `ERRORES_*.md`.

| Módulo | Abiertos |
|---|---|
| Acceso | ERR-14, ERR-15, ERR-16 |
| Objetos perdidos | ERR-11, ERR-12, ERR-13, ERR-17 |
| Préstamo de equipos | ERR-09, ERR-18 |
| Varias | ERR-10 |
| Higiene | E4-07, E4-08 |
| Sectores | E4-09, E4-10, E4-12, E4-13 |
| Tienda | E-04, E-05, E-06, E-07, E-09, E-10, E-13, E-14 |
| Educación Física | E-11, E-16 |

Decisiones por defecto (el usuario puede cambiarlas): ERR-04, ERR-08, E4-05, E4-14, E-08, E-12. Corregidos en la v3 respecto de la ronda anterior: E4-04, E4-06 y E-15.
Los hallazgos de nivel de código que había listado antes (siete comentarios, un `continue` y cuatro ternarios) **ya no existen en la v3**: lo verifiqué con búsquedas por texto sobre todo el código (`REVISION_CODIGO_TIENDA_EDFISICA.md`).

## 5. Coherencia cruzada: inconsistencias encontradas y corregidas
Revisé `MANUAL_TECNICO.md`, `GUION_PITCH.md`, `ANALISIS_COMPETENCIA.md` y `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md` contra CONTEXTO, el código v3 y `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`.

| # | Inconsistencia | Dónde | Estado |
|---|---|---|---|
| X-01 | Métricas de la app de la etapa anterior (3247 líneas, 185 funciones, 97 `prepare`, 215 `bindValue`, `.h` 246) | `MANUAL_TECNICO.md`, `PRESUPUESTO…` | **Corregido** a la v3: 3269, 186, 98, 217, 247 (recontado con comandos) |
| X-02 | «298 casos» y «29 errores abiertos / 14 corregidos» | `GUION_PITCH.md`, `PRESUPUESTO…`, `INFORME_PRUEBAS.md` | **Corregido**: 337 casos, 26 abiertos, 17 corregidos |
| X-03 | «Las reservas de sectores tienen fecha fija y ya no se ven» | `MANUAL_TECNICO.md`, `GUION_PITCH.md` | **Corregido para MySQL** (el script usa `CURDATE()`); para SQLite queda `[COMPLETAR]` (O-04) |
| X-04 | Usuario vendedor de la reserva demo de la Tienda (`[COMPLETAR]`) | `GUION_PITCH.md` | **Resuelto con el script:** el Alfajor de dulce de leche es de `alumno1`; la reserva la hizo `preceptor1` |
| X-05 | Especialidad de `alumno2` («Electrónica» en CONTEXTO §8 contra «Óptica» en los casos de Arce Thiago y Cabrera Ulises) | `GUION_PITCH.md`, `MANUAL_TECNICO.md` | **Corregido:** el script dice 5° 2° Óptica; CONTEXTO §8 está viejo (O-03) |
| X-06 | El `.qrc` y el `CMakeLists.txt` piden archivos que el zip no trae | `MANUAL_TECNICO.md` §5.3 | **Actualizado:** ahora faltan solo `iqual_sqlite.sql` y los `harness*.cpp` (O-01) |
| X-07 | Faltaban las limitaciones de CONTEXTO §9 (sin pagos reales, sin notificaciones, cruce solo para cursos con horario) | `MANUAL_TECNICO.md` §8 | **Corregido** |
| X-08 | CONTEXTO §9 dice que la auditoría no tiene pantalla; la app sí la tiene (pestaña «Auditoría» de Objetos perdidos) | `MANUAL_TECNICO.md` (lo describe como la app, no como CONTEXTO) | **Corregido en mis documentos**; CONTEXTO §9 pendiente (O-03) |
| X-09 | Mencionar el motor: los cuatro documentos dicen MySQL con respaldo SQLite | Todos | **Verificado, sin cambios** |
| X-10 | Cifras de estructura: 47 tablas, 5 procedimientos, 10 consultas de demostración, 28 de verificación | `MANUAL_TECNICO.md`, `GUION_PITCH.md` | **47 tablas verificadas** contando `CREATE TABLE` en `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`. Los 5 procedimientos y las 10 consultas **no se pudieron verificar contra el archivo** (no lo recibí): salen de CONTEXTO §19.1 y `GUIA_INSTALACION_MYSQL.md` (O-07) |
| X-11 | Precios y datos externos sin fecha de publicación | `ANALISIS_COMPETENCIA.md`, `PRESUPUESTO…` | **Corregido:** pasaron a `[COMPLETAR]`; quedan con fecha el precio de lista de MySQL (11/09/2025, según artículo del 17/08/2026, actualizado el 25/09/2026), la fecha del 21/04/2026 de MySQL 8.0 y la nota de Tramix (29/11/2012, marcada como antigua) |
| X-12 | Nota de Interempresas («700 colegios») citada sin haberla leído | `ANALISIS_COMPETENCIA.md` | **Corregido:** la saqué |
| X-13 | La app no llama a los procedimientos almacenados (búsqueda de `CALL` y `sp_` en la v3: 0 resultados) | `MANUAL_TECNICO.md` §3.3 | **Verificado**; sigue como duda a decidir (cuándo mostrarlos en la defensa) |
| X-14 | `INFORME_PRUEBAS.md` / `CASOS_PRUEBA_CONSOLIDADO.md`: casos de Arce Thiago y Cabrera Ulises y 4 con «hoy falla» | consolidado | **Corregido** en 10 casos (DAS-07, DAS-08, RCL-10, CON-01, PUB-09, PRE-26, HIG-16, HIG-19, CUE-06, CUE-09) |

## 6. Marcas encontradas (escaneo)
| Marca | Dónde (cantidad por archivo) |
|---|---|
| `[COMPLETAR` | `CASOS_PRUEBA_ACCESO_OBJETOS_PRESTAMO.md` (11) · `MANUAL_USUARIO_ACCESO_OBJETOS_PRESTAMO.md` (4) · `MANUAL_USUARIO_HIGIENE_SECTORES_CUENTA.md` (1) · `CASOS_PRUEBA_TIENDA_EDFISICA.md` (5; dos son aclaraciones de uso) · `requerimientos.md` (2) · `cambios-respecto-al-diseno-inicial.md` (2) · mis documentos: `PRESUPUESTO…` (52), `ANALISIS_COMPETENCIA.md` (30), `GUION_PITCH.md` (17), `MANUAL_TECNICO.md` (13), `INFORME_PRUEBAS.md` (8); `CASOS_PRUEBA_CONSOLIDADO.md` (12) repite los de Arce Thiago y Cabrera Ulises y 3 |
| `🔶` | `GUIA_INSTALACION_MYSQL.md` (2) · `GUIA_CONEXION_APP_MYSQL.md` (2) |
| «sin probar / no se probó / no probado» | `GUIA_INSTALACION_MYSQL.md` (1) · `GUIA_CONEXION_APP_MYSQL.md` (1) · `MANUAL_TECNICO.md` (2) · `INFORME_PRUEBAS.md` (5) · menciones del mismo tema en casos y requerimientos |
| Sin marcas | `README_proyecto.md`, `REVISION_ESTATICA_MYSQL.md`, `justificacion_3FN.md`, `ERRORES_ACCESO_OBJETOS_PRESTAMO/3/4.md`, `historias-de-usuario.md`, `matriz-trazabilidad.md` (pero el README está desactualizado: O-06) |

## 7. Lo que se probó y lo que no
- **Probado** (CONTEXTO §19.1 y §20, por Arce Thiago y Cabrera Ulises, Linux, Qt 6.4, MariaDB 10.11): pruebas automáticas (en la v3, harness3 y harness4) con 0 fallas con `QMYSQL` y SQLite; 131 consultas con `ONLY_FULL_GROUP_BY`; los scripts de MySQL, los procedimientos y las consultas de demostración y verificación sin errores.
- **No probado:** MySQL 8 de Oracle, SQL Server 2005, Windows (ODBC y plugin compilado), los 337 casos de prueba, el rendimiento (RNF03), el redimensionado de la ventana.
- **Yo no compilé ni ejecuté la aplicación.**

## Desvíos
- El prompt pide agrupar por responsable con el paso concreto; reemplacé la versión anterior (que agrupaba por tipo de dato) por esta.
- No sé la fecha del Demo Day; el orden de urgencia es mi criterio (primero lo que bloquea la demo, después lo que la prepara, después lo que la completa).
- `docs_otros.zip` no vino: lo que dice sobre Arce Thiago y Cabrera Ulises, 2 y 4 es lo que tenía de la etapa de cierre.
- Los escaneos son por texto; un `[COMPLETAR]` escrito de otra forma no se detecta. Los diagramas XML, el PDF del plan, las capturas y los `.sql` no se escanearon con estas marcas (el script SQL sí se leyó para los datos de demostración).

## Datos que faltan
- `docs_otros.zip`, `iqual_sqlite.sql`, `05_Backend_Grupo00.sql`, `consultas_demo.sql` y las capturas nuevas: los adjunta el usuario.
- Fecha del Demo Day.
- Todo lo de las secciones 1 a 3: nadie más puede cerrarlo.

## Actualización posterior (13/11/2026)
- O-01 y O-02 **resueltos**: la v3 compila y sus pruebas automáticas (harness3 y harness4) dan 0 fallas en MariaDB 10.11 y SQLite; el `CMakeLists.txt` y el `.qrc` de la entrega traen `iqual_sqlite.sql` y no dependen de los `harness*.cpp`.
- Los casos de prueba suman 337 (172 + 78 + 87) tras la ronda final de Arce Thiago y Cabrera Ulises y 4.
