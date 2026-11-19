# Informe de pruebas — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Fecha de este informe:** 13/11/2026 · **App evaluada:** v3 (`iqual_integrado_v3`, CONTEXTO §20)

> **Estado en una línea:** hay **337 casos de prueba escritos** y **53 errores detectados por lectura de código** (20 corregidos, 8 con decisión por defecto, 24 abiertos, 1 a verificar en MySQL, ninguno de gravedad alta). **Ningún caso fue ejecutado todavía:** la columna «Resultado» está vacía. Lo único que se ejecutó fue lo que informa el CONTEXTO (§19.1 y §20): pruebas automáticas (harness3 y harness4, 0 fallas) y scripts en MariaDB 10.11 y SQLite.
>
> **Aviso sobre las fuentes:** no recibí `docs_otros.zip` (documentos revisados de Arce Thiago y Cabrera Ulises, 2 y 4). Este informe usa los casos y errores de Arce Thiago y Cabrera Ulises y 4 de la etapa de cierre. Si ellos sumaron casos o errores nuevos (el CONTEXTO nombra un ERR-23 que no figura en mis copias), **faltan acá** y hay que volver a correr el conteo.

---

## 1. Alcance
Se cubren las diez pantallas de la app más Mi cuenta, divididas por área de trabajo:

| Autor | Pantallas |
|---|---|
| Arce Thiago y Cabrera Ulises | Inicio (landing), Acceso (iniciar sesión y crear cuenta), Dashboard, Objetos perdidos (Objetos, Reclamos, Consultas, Publicar, Auditoría), Ventana de detalle, Préstamo de equipos |
| Arce Thiago y Cabrera Ulises | Higiene y mantenimiento, Reserva de sectores, Mi cuenta |
| Arce Thiago y Cabrera Ulises | Tienda de alumnos (seis pestañas), Educación Física |

Los casos se relacionan con las historias de usuario (US) y los requerimientos (RF/RNF) de `historias-de-usuario.md`, `requerimientos.md` y `matriz-trazabilidad.md`.

**Qué no se cubre:** rendimiento (RNF03) y el comportamiento en SQL Server 2005; no hay casos de tiempo ni de carga. Arce Thiago y Cabrera Ulises deja anotado qué no se puede ver desde la pantalla (códigos de reserva, el límite de horario por código).

## 2. Entorno
| Dato | Valor |
|---|---|
| Probado por Arce Thiago y Cabrera Ulises (CONTEXTO §19.1 y §20) | Linux, Qt 6.4, MariaDB 10.11: pruebas automáticas (en la v3, harness3 y harness4) con 0 fallas con `QMYSQL` y con SQLite; 131 consultas validadas con `ONLY_FULL_GROUP_BY`; `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`, procedimientos, `consultas_demo.sql` y `consultas_verificacion.sql` sin errores |
| **No probado** | MySQL 8 de Oracle · SQL Server 2005 · Windows (ni ODBC ni plugin `QMYSQL` compilado) |
| Entorno previsto para ejecutar los casos | `[COMPLETAR: equipo, sistema operativo, versión de Qt, motor de base (MySQL o SQLite) y versión de la app con la que se corran los casos]` |
| Datos | Base de demostración recién cargada. Usuarios y claves: script de datos y `GUIA_CONEXION_APP_MYSQL.md` (no se copian acá) |

## 3. Método
1. **Cómo se escribieron los casos:** cada autor leyó el código (`mainwindow.cpp`, `mainwindow.ui`) y las capturas, y redactó casos con ID, historia o requisito que cubre, rol, precondición, pasos, resultado esperado y una columna «Resultado» vacía.
2. **Cómo se detectaron los errores:** por lectura del código y de las capturas, no corriendo la app. Cada error tiene función, pasos para reproducirlo, qué pasa, qué debería pasar y gravedad.
3. **Cómo se ejecutan los casos (pendiente):** con la app corriendo y la base de demo, se sigue cada caso y se anota OK / FALLA / NO PROBADO y una nota. Varios casos modifican datos: para volver al estado inicial se recarga la base de demo.
4. **Gravedad:** Alta = pierde datos o bloquea el uso · Media = confunde o deja datos viejos a la vista · Baja = detalle, rendimiento o robustez.
5. **Cómo se contó (los números de abajo):** un script lee `CASOS_PRUEBA_ACCESO_OBJETOS_PRESTAMO.md`, `CASOS_PRUEBA_HIGIENE_SECTORES_CUENTA.md` y `CASOS_PRUEBA_TIENDA_EDFISICA.md` y cuenta las filas de tabla cuyo ID tiene formato de caso; el mismo script revisa que no haya IDs repetidos y cuenta cuántas filas tienen la columna «Resultado» vacía y cuántas traen `[COMPLETAR`. Los errores se contaron leyendo las tablas resumen de `ERRORES_ACCESO_OBJETOS_PRESTAMO.md`, `ERRORES_HIGIENE_SECTORES_CUENTA.md` y `ERRORES_TIENDA_EDFISICA.md`.

## 4. Casos de prueba por módulo
(Detalle completo con todos los casos: `CASOS_PRUEBA_CONSOLIDADO.md`.)

| Autor | Módulo | Prefijo | Rango | Casos | Con resultado cargado |
|---|---|---|---|---|---|
| Arce Thiago y Cabrera Ulises | Inicio (landing) | INI | 01–09 | 9 | 0 |
| Arce Thiago y Cabrera Ulises | Acceso: iniciar sesión | LOG | 01–15 | 15 | 0 |
| Arce Thiago y Cabrera Ulises | Acceso: crear cuenta | REG | 01–23 | 23 | 0 |
| Arce Thiago y Cabrera Ulises | Dashboard | DAS | 01–13 | 13 | 0 |
| Arce Thiago y Cabrera Ulises | Objetos: lista y reclamo | OBJ | 01–21 | 21 | 0 |
| Arce Thiago y Cabrera Ulises | Objetos: Reclamos | RCL | 01–11 | 11 | 0 |
| Arce Thiago y Cabrera Ulises | Objetos: Consultas | CON | 01–13 | 13 | 0 |
| Arce Thiago y Cabrera Ulises | Objetos: Publicar | PUB | 01–14 | 14 | 0 |
| Arce Thiago y Cabrera Ulises | Objetos: Auditoría | AUD | 01–09 | 9 | 0 |
| Arce Thiago y Cabrera Ulises | Ventana de detalle | DET | 01–10 | 10 | 0 |
| Arce Thiago y Cabrera Ulises | Préstamo de equipos | PRE | 01–34 | 34 | 0 |
| | **Subtotal Arce Thiago y Cabrera Ulises** | | | **172** | **0** |
| Arce Thiago y Cabrera Ulises | Higiene y mantenimiento | HIG | 01–23 | 23 | 0 |
| Arce Thiago y Cabrera Ulises | Reserva de sectores | SEC | 01–29 | 29 | 0 |
| Arce Thiago y Cabrera Ulises | Mi cuenta | CUE | 01–26 | 26 | 0 |
| | **Subtotal Arce Thiago y Cabrera Ulises** | | | **78** | **0** |
| Arce Thiago y Cabrera Ulises | Tienda: Productos | TIE-P0 | 01–14 | 14 | 0 |
| Arce Thiago y Cabrera Ulises | Tienda: Publicar | TIE-P1 | 01–11 | 11 | 0 |
| Arce Thiago y Cabrera Ulises | Tienda: Grupos y donaciones | TIE-P2 | 01–17 | 17 | 0 |
| Arce Thiago y Cabrera Ulises | Tienda: Mis reservas | TIE-P3 | 01–07 | 7 | 0 |
| Arce Thiago y Cabrera Ulises | Tienda: Mis ventas | TIE-P4 | 01–07 | 7 | 0 |
| Arce Thiago y Cabrera Ulises | Tienda: Mis productos | TIE-P5 | 01–11 | 11 | 0 |
| Arce Thiago y Cabrera Ulises | Educación Física | EDF | 01–20 | 20 | 0 |
| | **Subtotal Arce Thiago y Cabrera Ulises** | | | **87** | **0** |
| | **TOTAL** | | | **337** | **0** |

Controles del conteo: no hay IDs repetidos dentro de los casos (172, 78 y 87 IDs únicos; Arce Thiago y Cabrera Ulises repite SEC-26 y CUE-05 solo en su tabla de la pasada con MySQL, que no se cuenta); las 337 filas tienen la columna «Resultado» vacía. El total del consolidado (337) coincide con la suma de los tres archivos. Respecto de la versión anterior de este informe (299), sumaron Arce Thiago y Cabrera Ulises (+27 casos) y Arce Thiago y Cabrera Ulises (+11), que agregaron casos de borde y de v3 en esta ronda.

**Casos con datos por confirmar (`[COMPLETAR]`):** REG-15, REG-16, DAS-08, OBJ-17, AUD-07, DET-05, DET-08, PRE-04 (Arce Thiago y Cabrera Ulises) y TIE-P1-07, TIE-P1-11, EDF-18 (Arce Thiago y Cabrera Ulises): 11 casos. Piden un dato que no estaba en los archivos (programas asignados a cada equipo, DNI y correo exactos de `alumno1`, datos que hay que preparar antes del caso, o una decisión del equipo).

**Resultados de ejecución:** OK: 0 · FALLA: 0 · NO PROBADO: 337 (todos).

## 5. Errores por módulo y estado
**Cómo se asignó el estado.** Arce Thiago y Cabrera Ulises tiene columna «Estado» en su documento. Los documentos de Arce Thiago y Cabrera Ulises y de Arce Thiago y Cabrera Ulises no la tienen, así que el estado sale de CONTEXTO §19.2 (errores corregidos), §19.3 (decisiones por defecto) y §20 (app v3):
- **Corregido:** figura en §19.2.
- **Decisión por defecto:** figura en §19.3 (se dejó así a propósito, el usuario puede cambiarlo).
- **Corregido (app v3):** lo dice CONTEXTO §20 (E4-04 y E4-06) o lo verifiqué en el código v3 (E-15).
- **Abierto:** no figura en ninguno de los anteriores; se asume que sigue igual. `[COMPLETAR: Arce Thiago y Cabrera Ulises y Arce Thiago y Cabrera Ulises confirman el estado de sus errores «Abierto» y de los nuevos, p. ej. ERR-20 a ERR-23; Arce Thiago y Cabrera Ulises confirma cuáles se arreglaron en la v3]`
- Excepción: ERR-19 (función de SQLite en el resumen del Profesor) no figura en §19.2, pero busqué en el `mainwindow.cpp` de la v3 `date('now')`, `datetime('now')`, `strftime`, `julianday`, `last_insert_rowid`, `INSERT OR` y no hay ninguno; el único `PRAGMA` es el de `abrirSqlite` (propio de SQLite, que es correcto ahí). Lo marco **Corregido (verificado en el código)**.

### 5.1 Resumen
| Autor | Total | Corregido | Decisión por defecto | Abierto | Alta | Media | Baja |
|---|---|---|---|---|---|---|---|
| Arce Thiago y Cabrera Ulises (ERR) | 23 | 10 | 4 | 8 + 1 a verificar (ERR-21) | 0 | 6 | 17 |
| Arce Thiago y Cabrera Ulises (E4) | 14 | 6 | 2 | 6 | 0 | 4 | 10 |
| Arce Thiago y Cabrera Ulises (E) | 16 | 4 | 2 | 10 | 0 | 3 | 13 |
| **Total** | **53** | **20** | **8** | **24 + 1 a verificar** | **0** | **13** | **40** |

### 5.2 Detalle por módulo
| Módulo | ID | Gravedad | Estado | Título corto |
|---|---|---|---|---|
| Dashboard | ERR-01 | Media | Corregido | Los números del Inicio no se actualizaban |
| Dashboard | ERR-02 | Media | Corregido | «Tus reservas de sectores» (Profesor) contaba reservas que ya no valen |
| Objetos perdidos | ERR-20 | Baja | Corregido (app v3) | Categoría y sector no volvían a «Elegí…» después de publicar |
| Objetos perdidos | ERR-22 | Baja | Corregido (app v3) | La fecha de las consultas se mostraba completa; ahora dd/MM |
| Préstamo de equipos | ERR-21 | Baja | A verificar (MySQL) | Tipo de las columnas de hora de préstamo y devolución |
| Inicio | ERR-23 | Baja | Decisión por defecto | El splash puede repetirse u ocultarse si aparece el aviso de MySQL (no se toca) |
| Dashboard | ERR-19 | Baja | Corregido (verificado en el código) | Resumen del Profesor usaba una función de SQLite |
| Dashboard | E4-01 | Media | Corregido | Contadores del Inicio desactualizados (misma causa que ERR-01) |
| Dashboard | E4-02 | Media | Corregido | Reservas de sectores contaba canceladas y rechazadas (misma causa que ERR-02) |
| Acceso | ERR-03 | Media | Corregido | El login fallido guardaba en claro lo escrito en «Usuario» |
| Acceso | ERR-04 | Media | Decisión por defecto (U04) | Cinco fallos bloquean el acceso a todos hasta reiniciar la app |
| Acceso | ERR-14 | Baja | Abierto | Validaciones del registro más laxas que el texto |
| Acceso | ERR-15 | Baja | Abierto | El control de correo repetido distingue mayúsculas |
| Acceso | ERR-16 | Baja | Abierto | PIN en el código y hash sin sal |
| Objetos perdidos | ERR-05 | Media | Corregido | Categoría y sector arrancaban con un valor ya elegido |
| Objetos perdidos | ERR-06 | Media | Corregido | Las consultas no mostraban la fecha |
| Objetos perdidos | ERR-11 | Baja | Abierto | La tarjeta elegida sobrevive al cambio de usuario |
| Objetos perdidos | ERR-12 | Baja | Abierto | «Objetos para reclamar: N» depende de la búsqueda sin decirlo |
| Objetos perdidos | ERR-13 | Baja | Abierto | Publicar con foto puede dejar un archivo huérfano o fallar por nombre repetido |
| Objetos perdidos | ERR-17 | Baja | Abierto | El detalle dice «no tiene foto» si falta el archivo en disco |
| Préstamo de equipos | ERR-07 | Baja | Corregido | Un alumno veía los préstamos de los demás |
| Préstamo de equipos | ERR-08 | Baja | Decisión por defecto | Devolver arranca en «Funciona»; solo «No funciona» pide confirmación |
| Préstamo de equipos | ERR-09 | Baja | Abierto | Observaciones de la devolución pierden su prefijo si el préstamo no tenía |
| Préstamo de equipos | ERR-18 | Baja | Abierto | La lista muestra solo 40 y la consulta trae todos |
| Varias | ERR-10 | Baja | Abierto | Elegir «nada» deja un registro Fallido en la auditoría |
| Higiene | E4-03 | Media | Corregido | Observaciones sin límite de largo (`VARCHAR(200)` en MySQL) |
| Higiene | E4-07 | Baja | Abierto | El tope de 20 resueltos es silencioso |
| Higiene | E4-08 | Baja | Abierto | El mensaje de «sin pendientes» aparece dos veces |
| Sectores | E4-09 | Baja | Abierto | Reservas de hoy ya terminadas siguen como «próximas» |
| Sectores | E4-10 | Baja | Abierto | La fecha mínima del calendario no se actualiza pasada la medianoche |
| Sectores | E4-12 | Baja | Abierto | Sin sectores reservables, la ocupación queda vacía sin mensaje |
| Sectores | E4-13 | Baja | Abierto | Una reserva que empieza en el minuto actual se rechaza |
| Sectores | E4-14 | Baja | Decisión por defecto | Botones activos sin reserva elegida (avisan al tocarlos) |
| Sectores / Higiene | E4-11 | Baja | Corregido | Cerrar sesión no limpiaba selecciones |
| Mi cuenta | E4-04 | Baja | Corregido (app v3, §20) | Guardar el mismo curso decía «Cambiaste tu curso.»; ahora dice «Ese ya es tu curso.» |
| Mi cuenta | E4-05 | Media | Decisión por defecto | El Alumno puede crear cursos que no existen |
| Mi cuenta | E4-06 | Baja | Corregido (app v3, §20) | Tras responder «No» los combos quedaban con el curso rechazado; ahora vuelven al curso anterior |
| Tienda | E-01 | Media | Corregido | Cerrar sesión no limpiaba los formularios (ni el PIN) |
| Tienda | E-04 | Baja | Abierto | Releer y reescalar las fotos con cada letra del buscador (no medido) |
| Tienda | E-05 | Baja | Abierto | Buscar «%» o «_» los toma como comodines |
| Tienda | E-06 | Baja | Abierto | Reservar queda habilitado con producto propio o sin stock |
| Tienda | E-07 | Baja | Abierto | Sin tope máximo en precio, stock, meta y monto |
| Tienda | E-08 | Baja | Decisión por defecto | «Viaje» y «viaje» se toman como el mismo nombre en MySQL |
| Tienda | E-09 | Baja | Abierto | Producto sin stock se lista con «SIN STOCK» (ver E-06) |
| Tienda | E-10 | Baja | Abierto | El PIN del grupo se guarda en texto plano |
| Tienda | E-13 | Baja | Abierto | Los combos «Ver» y «Vendedor» cortan el texto a 1100 px |
| Tienda | E-14 | Baja | Abierto | Los combos «Ver» y «Grupo» conservan la selección al cambiar de usuario |
| Educación Física | E-02 | Media | Corregido | La hora preseleccionada caía en una opción gris |
| Educación Física | E-03 | Media | Corregido | Un día cuyas horas chocan quedaba habilitado |
| Educación Física | E-11 | Baja | Abierto | «(choca con …)» nombra una sola materia |
| Educación Física | E-12 | Baja | Decisión por defecto | Los errores «Fallido» no se alcanzan desde la pantalla |
| Educación Física | E-15 | Baja | Corregido (app v3, verificado en el código) | Un comentario `//` y un ternario en `cargarDiasEdFisica` |
| Educación Física | E-16 | Baja | Abierto | Redacción distinta entre la franja y el mensaje de error |

Los estados de Arce Thiago y Cabrera Ulises y Arce Thiago y Cabrera Ulises son los que ellos mismos escribieron en la columna «Estado» de sus `ERRORES_*.md` de la ronda final (verificados en el código v3). ERR-20 y ERR-22 (Corregidos en v3) y ERR-23 (decisión por defecto: no tocar el splash) y ERR-21 (a verificar en MySQL) se suman a la tabla 5.2 como filas nuevas; ERR-09 pasó de Abierto a Decisión por defecto y ERR-15 figura «Corregido en MySQL, abierto solo en SQLite» (se cuenta como Corregido).

**Pendientes propios de Arce Thiago y Cabrera Ulises y 4** (no son errores de la tabla anterior): la pregunta sobre separar las observaciones de pedir y devolver un equipo (U11, decisión por defecto: un solo campo) y las listas de defectos visuales y de microcopy de las capturas (Arce Thiago y Cabrera Ulises sección 4b; Arce Thiago y Cabrera Ulises «Pendientes propios (b)», ítems V1–V13). Quedan registrados en sus documentos y en `ERRORES_Y_PENDIENTES.md`.

## 6. Conclusiones
1. **El sistema está bien cubierto en papel, pero sin ejecución:** 337 casos para las diez pantallas, ninguno corrido. Hasta que se corran, no se puede afirmar que algo «pasa» ni que «falla».
2. **No se encontró ningún error de gravedad alta.** Los 13 de gravedad media son de coherencia (números desactualizados, formularios que no se limpian, opciones mal preseleccionadas) y **los 13 figuran corregidos (11) o con decisión por defecto (2: ERR-04 y E4-05)**.
3. **De los 53 errores, 20 están corregidos y 8 se dejaron a propósito** (decisión por defecto, el usuario puede cambiarla). Quedan **24 abiertos** y 1 a verificar en MySQL (ERR-21), casi todos de gravedad baja (usabilidad, textos, robustez); algunos pueden estar ya arreglados sin que conste (ver 5).
4. **Riesgos reales que siguen abiertos:** Windows sin probar (ODBC y plugin), MySQL 8 de Oracle sin probar, y la falta de confirmación de Linares sobre MySQL. Ningún caso se ejecutó sobre esos entornos.
5. **Limitaciones declaradas, no errores:** PIN del grupo en texto plano (E-10) y clave con SHA-256 sin sal (ERR-16), alcance escolar (RNF02).
6. **Siguiente paso:** ejecutar primero los casos que tocan lo corregido (para confirmar los arreglos) y los de flujo principal por rol (LOG, REG, OBJ, PRE, SEC, TIE-P0/P3, EDF); después el resto.

## Desvíos
- Los casos y errores de Arce Thiago y Cabrera Ulises y Arce Thiago y Cabrera Ulises de la ronda final llegaron después de este informe: Arce Thiago y Cabrera Ulises volvió a correr el conteo sobre sus archivos nuevos (172 y 78 casos) y actualizó las cifras de este informe y del consolidado.
- En `CASOS_PRUEBA_CONSOLIDADO.md` reemplacé la clave de demostración por «la contraseña de demo» (no se escriben claves). Los IDs no cambian.
- No ejecuté ningún caso ni ninguna prueba; todo lo que se cuenta sale de leer los documentos y el código.
- El conteo de casos con `[COMPLETAR]` (11) lo hizo el script buscando esa marca en las filas de tabla; puede haber `[COMPLETAR]` en el texto fuera de las tablas (preámbulos, desvíos), que se listan en `ERRORES_Y_PENDIENTES.md`.

## Datos que faltan
- Resultados (OK / FALLA / NO PROBADO) de los 337 casos: quien pruebe.
- `[COMPLETAR: entorno de ejecución de los casos (equipo, SO, Qt, motor, versión de la app)]`
- `[COMPLETAR: Arce Thiago y Cabrera Ulises confirma qué errores «Abierto» de Arce Thiago y Cabrera Ulises y Arce Thiago y Cabrera Ulises ya fueron corregidos]`
- Datos para los 11 casos con `[COMPLETAR]` (programas por equipo, DNI y correo de `alumno1`, decisión sobre nombre repetido de producto, etc.).
- Medición de E-04 (rendimiento de fotos) y de RNF03.
