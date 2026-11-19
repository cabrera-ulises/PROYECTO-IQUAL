# Errores encontrados — Higiene, Reserva de sectores y Mi cuenta

**Versión de la ronda final (app v3).** Reemplaza al `ERRORES_HIGIENE_SECTORES_CUENTA.md` anterior. Mantiene los IDs E4-01 a E4-14 y la tabla visual V1–V13, con la columna **Estado** de cada hallazgo verificada contra la **app v3** (`iqual_integrado_v3`, CONTEXTO §20).

**Ronda de cierre (19/11/2026).** Revisado contra los datos nuevos de MySQL (`04_DatosSQL_Grupo00.sql`, 62 usuarios). Ninguno de los 14 hallazgos cambia de estado ni de gravedad; se actualizaron los pasos de E4-05, E4-07 y E4-08 porque dependían de pocos datos, se corrigió la referencia de línea de E4-03 y se agregaron cuatro observaciones sobre los datos (D4-01 a D4-04, al final de «Observaciones»). No hay errores nuevos de la app.

## Cómo se revisó
- **Código:** `mainwindow.cpp`, `mainwindow.h` y `mainwindow.ui` de la app v3 (`app_codigo.zip` de esta ronda). Comparé la v3 contra la versión que revisé en la etapa anterior (78 líneas distintas en `mainwindow.cpp`, un texto en el `.ui` y una declaración nueva en el `.h`) y releí las funciones de mis tres páginas y las compartidas que usan (`cerrarSesion`, `on_stackedWidget_currentChanged`, `cargarResumen`, `valorUnicoHoy`, `aplicarTema`, `aplicarPermisos`, `confirmar`, `valorFecha`, `valorAhora`, `formatoCorto`, `obtenerCurso`, `chocaHorario`).
- **Capturas:** esta ronda **no trae capturas nuevas**. Los estados de la tabla V se verifican con el `.ui` y el código de la v3 (que solo cambió el texto de ayuda de Higiene); las capturas que vi en la etapa anterior (12 imágenes, claro y oscuro) siguen siendo la referencia visual. `[COMPLETAR: capturas nuevas de la v3 para confirmar los cambios visuales]`
- **Base:** `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` para los tipos de columna que usan mis pantallas. En la ronda de cierre también cargué `03` y `04` de `paquete_v7.zip` en MariaDB 10.11 y ejecuté consultas equivalentes a las de mis pantallas (mismos filtros y orden) para comprobar las cantidades.
- **No ejecuté la app** ni MySQL (no pude compilarla/abrirla en este entorno): "Corregido" significa que **lo verifiqué leyendo el código**, no que lo probé en pantalla.
- **Comparación con el `.ui` anterior:** de mis tres páginas, el único cambio es el texto de ayuda de `leHigieneObs` ("Contá qué pasa (ej: falta papel)"); Sectores y Mi cuenta están igual.

**Estados.** *Corregido* = el código actual ya lo resuelve (verificado). *Abierto* = sigue igual. *Decisión por defecto* = el CONTEXTO §19.3 lo deja así a propósito hasta que el usuario diga otra cosa.
No hay errores de gravedad alta ni media abiertos en estas tres páginas: lo abierto es todo de gravedad **baja**. **Balance de la v3 en mis pantallas:** 6 corregidos (E4-01, E4-02, E4-03, E4-04, E4-06, E4-11), 2 decisiones por defecto (E4-05, E4-14) y 6 abiertos (E4-07, E4-08, E4-09, E4-10, E4-12, E4-13).

## Resumen
| ID | Función | Gravedad | Estado | Una línea |
|---|---|---|---|---|
| E4-01 | `cargarResumen` / Dashboard | Media | **Corregido** | Los contadores del Inicio se recargan al entrar al Inicio |
| E4-02 | `cargarResumen` | Media | **Corregido** | Profesor cuenta solo Pendiente/Aprobada desde hoy; Preceptor, pendientes desde hoy |
| E4-03 | `leHigieneObs` (`.ui`) | Media | **Corregido** | Observaciones limitadas a 200 caracteres (igual que `VARCHAR(200)`) |
| E4-04 | `on_btnCuentaGuardar_clicked` | Baja | **Corregido (v3)** | Guardar el mismo curso ahora dice "Ese ya es tu curso." |
| E4-05 | `on_btnCuentaGuardar_clicked` / `obtenerCurso` | Media | **Decisión por defecto** | Un alumno puede crear un curso inexistente desde Mi cuenta |
| E4-06 | `on_btnCuentaGuardar_clicked` | Baja | **Corregido (v3)** | Tras responder "No", los combos vuelven al curso guardado |
| E4-07 | `cargarHigiene` | Baja | **Abierto** | El tope de 20 resueltos no avisa |
| E4-08 | `cargarHigiene` + `actualizarPendientesHigiene` | Baja | **Abierto** | El mensaje de "sin pendientes" aparece dos veces |
| E4-09 | `cargarReservasSector` | Baja | **Abierto** | Reservas de hoy ya terminadas siguen como "próximas" (y cuentan en el Inicio) |
| E4-10 | `MainWindow::MainWindow` | Baja | **Abierto** | La fecha mínima del calendario no se actualiza pasada la medianoche |
| E4-11 | `cerrarSesion` | Baja | **Corregido** | Se limpian lugar, día, horas, sector y tipo |
| E4-12 | `cargarOcupacion` | Baja | **Abierto** | Sin sectores reservables, la ocupación queda vacía y sin mensaje |
| E4-13 | `on_btnSectoresReservar_clicked` | Baja | **Abierto** | Una reserva que empieza en el minuto actual se rechaza |
| E4-14 | `on_btnSectoresAprobar/Rechazar/Cancelar`, `on_btnHigieneResolver_clicked` | Baja | **Decisión por defecto** | Botones activos sin selección (§19.3) |

**Errores nuevos:** ninguno. Revisé los tres casos posibles por MySQL que pedía el encargo y no encontré errores reales en mis pantallas (ver "Revisión MySQL").

---

## Detalle

### E4-01 — Contadores del Dashboard desactualizados · Media · **Corregido**
- **Antes:** `cargarResumen` solo corría al iniciar sesión; volver a Inicio mostraba números viejos.
- **Verificado:** en `on_stackedWidget_currentChanged`, cuando `pagina == PAG_DASHBOARD` y `idActual > 0` se llama a `cargarResumen()`. Cubre los tres caminos del caso original (reportar, resolver, reservar/aprobar y volver a Inicio).
- **Para probar en pantalla:** casos nuevos `HIG-20` y `SEC-26` de `CASOS_PRUEBA_HIGIENE_SECTORES_CUENTA.md`.

### E4-02 — "Tus reservas de sectores" cuenta reservas que no se muestran · Media · **Corregido**
- **Antes:** el Profesor veía 3 en el Inicio y 2 en la lista porque se contaba la Cancelada; el Preceptor contaba pendientes de cualquier fecha.
- **Verificado:** `cargarResumen` rama Profesor ahora cuenta `e.nombre_estado IN ('Pendiente', 'Aprobada') AND r.fecha_reserva >= hoy`; rama Preceptor cuenta pendientes con `r.fecha_reserva >= hoy`. Ya no hay `date('now')`.
- **Detalle que queda y no es error:** la lista "Reservas próximas" del Profesor sí muestra las **Rechazadas** (solo excluye las Canceladas), y el Inicio no las cuenta. Los dos números pueden diferir en esas. Es coherente con "Tus reservas" = activas, pero conviene que quien pruebe lo sepa (caso `SEC-26`).
- **Observación de código (no es error de comportamiento):** la fecha de hoy se concatena como texto dentro del SQL (`hoy()`); lo anoto en `REVISION_CODIGO_HIGIENE_SECTORES_CUENTA.md`.

### E4-03 — Observaciones sin límite de largo · Media · **Corregido**
- **Antes:** sin `maxLength`; en MySQL el `INSERT` fallaba con "No se pudo enviar el reporte. Probá de nuevo." para textos de más de 200 caracteres.
- **Verificado:** `mainwindow.ui` ahora tiene `maxLength` 200 en `leHigieneObs`. `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` define `observaciones VARCHAR(200) NOT NULL` (línea 354 de `03_ModeloSQL_Grupo00.sql`): coincide. Además `on_btnHigieneReportar_clicked` aplica `trimmed()` antes de guardar, así que nunca supera el límite. El campo cuenta unidades de texto de Qt, que son iguales o más que los caracteres de MySQL, así que no hay forma de pasarse.
- **Para probar:** caso `HIG-19` (actualizado) y `HIG-21`.

### E4-04 — Guardar el mismo curso dice que lo cambió · Baja · **Corregido (v3)**
- **Antes:** con `alumno1`, **Guardar curso** sin tocar los combos mostraba "Cambiaste tu curso." y hacía un `UPDATE` igual al valor que ya tenía.
- **Verificado en la v3:** `on_btnCuentaGuardar_clicked` (línea ~821) lee el curso guardado (`COALESCE(id_curso, 0)`), lo compara con el elegido y, si son iguales, muestra **"Ese ya es tu curso."** y sale sin tocar la base ni mirar Educación Física.
- **Observación menor (no es error):** el texto se muestra con `info()`, es decir, en la ventana titulada "Listo" (la de los éxitos), aunque no se cambió nada. Si se prefiere, podría ir en la ventana "Atención". Ver caso `CUE-09`.

### E4-05 — Se pueden crear cursos inexistentes desde Mi cuenta · Media · **Decisión por defecto (§19.3)**
- **Función:** `on_btnCuentaGuardar_clicked` → `obtenerCurso`.
- **Pasos:** con `alumno1`, elegir 7°, 9°, Óptica y **Guardar curso** (datos: MySQL: esa combinación tampoco existe entre los 24 cursos cargados, así que se crea igual).
- **Qué pasa:** se inserta el curso en la tabla `curso` y la app responde "Cambiaste tu curso."; el curso inventado no tiene horario, por lo que el cruce con Educación Física deja de validar para ese alumno.
- **Estado:** el CONTEXTO §19.3 lo deja así y pide documentarlo como **limitación**. Texto sugerido para el informe: "Mi cuenta permite elegir cualquier combinación de año, división y especialidad del catálogo y crea el curso si no existe; el control de choques con Educación Física solo funciona para los cursos que tienen horario cargado".

### E4-06 — Tras responder "No" los combos quedaban desfasados · Baja · **Corregido (v3)**
- **Antes:** con `alumno2` inscripto en Vóley martes 14:00–16:00, al elegir 4° 1° Computación y responder **No**, el curso real no cambiaba pero los combos seguían mostrando el curso rechazado.
- **Verificado en la v3:** cuando `confirmar(...)` devuelve "No", la función llama a `cargarCuenta()` antes del `return` (líneas ~831–834); `cargarCuenta` vuelve a poner los tres combos con el curso guardado.
- **Para probar:** casos `CUE-06` y `CUE-25`.

### E4-07 — El tope de 20 resueltos no avisa · Baja · **Abierto**
- **Función:** `cargarHigiene` (`MAX_RESUELTOS`).
- **Qué pasa:** con más de 20 reportes resueltos, "Todos" y "Resueltos" muestran los 20 de número más alto y los demás no se ven, sin ninguna leyenda. Datos: SQLite: hay 1 resuelto, así que el tope no se ve sin cargar datos. Datos: MySQL: hay 13 resueltos y 9 pendientes; el tope se ve resolviendo 8 de los 9 pendientes (21 resueltos; caso `HIG-14`).
- **Qué debería pasar:** una línea del tipo "Mostrando los últimos 20 resueltos".
- **Verificado:** el código actual no cambió.

### E4-08 — El mensaje de "sin pendientes" se repite · Baja · **Abierto**
- **Función:** `cargarHigiene` y `actualizarPendientesHigiene`.
- **Pasos:** resolver todo y poner **Ver:** en "Pendientes" (datos: MySQL: son 9 pendientes; el caso `HIG-12` trae un `UPDATE` para resolverlos de una vez).
- **Qué pasa:** el chip dice "No hay reportes pendientes. ¡Todo en orden!" y la lista "No hay reportes pendientes.".
- **Qué debería pasar:** una sola vez.
- **Verificado:** ambos textos siguen en el código.

### E4-09 — Reservas de hoy que ya terminaron siguen "próximas" · Baja · **Abierto**
- **Función:** `cargarReservasSector` (filtra por `fecha_reserva >= hoy`, no por hora).
- **Pasos:** con `preceptor1`, reservar para hoy una franja que empiece dentro de 1–2 minutos y dure 1 minuto; esperar y volver a la página.
- **Qué pasa:** sigue en "Reservas próximas" y se puede cancelar, aprobar o rechazar. Tras la corrección de E4-02, el Inicio también la cuenta (mismo filtro por fecha).
- **Qué debería pasar:** dejar de figurar como próxima cuando pasó su hora de fin.
- **Verificado:** por lectura; no reproducido en la app.

### E4-10 — Fecha mínima del calendario fija · Baja · **Abierto**
- **Función:** `MainWindow::MainWindow` (`setMinimumDate(QDate::currentDate())` se llama una sola vez).
- **Qué pasa:** con la app abierta pasada la medianoche, el calendario sigue permitiendo el día anterior. Mejoró algo: `cerrarSesion` ahora vuelve el día a hoy, así que el valor inicial es correcto después de cerrar sesión; el **mínimo** del calendario sigue viejo hasta reiniciar. Si se reserva en ese día, aparece "No se puede reservar en una fecha que ya pasó." (no se crea nada).
- **Qué debería pasar:** actualizar el mínimo al entrar a la página.
- **Verificado:** por lectura, no reproducido.

### E4-11 — Al cerrar sesión no se limpiaban las selecciones · Baja · **Corregido**
- **Verificado:** `cerrarSesion` ahora hace `cbSectoresLugar->setCurrentIndex(0)`, `deSectoresDia->setDate(QDate::currentDate())`, `teSectoresInicio->setTime(QTime(8, 0))`, `teSectoresFin->setTime(QTime(9, 0))`, `cbHigieneSector` y `cbHigieneTipo` a 0, `cbHigieneFiltro` a 0, limpia `leHigieneObs` y los cuatro campos de Mi cuenta. Los combos de curso de Mi cuenta no se reinician ahí, pero `cargarCuenta` los vuelve a poner con el curso de quien entra.
- **Para probar:** caso nuevo `SEC-27` y `HIG-22`.

### E4-12 — Ocupación vacía y sin explicación si no hay sectores reservables · Baja · **Abierto**
- **Función:** `cargarOcupacion` (`if (sector <= 0) return;`).
- **Qué pasa:** con una base sin sectores de tipo "Reservable", el combo Lugar queda vacío y la tarjeta de ocupación vacía, sin texto; el título conserva el valor anterior.
- **Qué debería pasar:** un estado vacío ("Todavía no hay sectores para reservar").
- **Verificado:** el `return` sigue igual.

### E4-13 — Reservar con inicio en el minuto actual se rechaza · Baja · **Abierto**
- **Función:** `on_btnSectoresReservar_clicked` (compara `time() < QTime::currentTime()`, con segundos).
- **Qué pasa:** a las 10:15:30, reservar hoy de 10:15 a 10:30 da "Ese horario de inicio ya pasó. Elegí uno más tarde." Es discutible; se puede dejar así.
- **Verificado:** igual que antes.

### E4-14 — Botones activos sin selección · Baja · **Decisión por defecto (§19.3)**
- **Qué pasa:** Aprobar, Rechazar, Cancelar reserva y Marcar resuelto quedan activos y avisan al apretarlos ("Elegí una reserva de la lista." / "Elegí un reporte de la lista."). Aprobar, Rechazar y Marcar resuelto dejan una fila **Fallido** en `log_auditoria` por cada clic sin selección.
- **Estado:** el CONTEXTO §19.3 decide no habilitarlos por selección. Para la defensa, el costo conocido es ese ruido en la auditoría.

---

## Revisión MySQL (lo que pedía el encargo)
Resultado: **no encontré errores nuevos en mis pantallas.** No ejecuté la app contra MySQL; esto es lectura del código y de `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`. Lo ya probado en MariaDB figura en el CONTEXTO §19.1.
| Punto | Qué revisé | Resultado |
|---|---|---|
| `QDate` en las reservas | `valorFecha()` devuelve `QDate` para MySQL y texto para SQLite; el código lo usa en `cargarOcupacion`, `cargarReservasSector` y `on_btnSectoresReservar_clicked`. Al leer, `cargarReservasSector` hace `QDate::fromString(q.value(1).toString(), "yyyy-MM-dd")`, que sirve con `QDate` y con texto. `cargarResumen` compara contra un literal `'yyyy-MM-dd'`, que MySQL convierte | Sin error |
| Horas de las reservas | `hora_inicio` y `hora_fin` son `VARCHAR(5)` en `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`: las comparaciones de texto (`<`, `>`) y el `ORDER BY` se comportan igual que en SQLite | Sin error |
| Fechas con hora | `valorAhora()` manda `QDateTime` a MySQL; `formatoCorto()` recorta a 19 caracteres y cambia la "T" por espacio, así que muestra bien lo que devuelve MySQL (`reporte_higiene.fecha_hora` y `fecha_hora_resolucion` son `DATETIME`) | Sin error |
| Mayúsculas en el login | El login pasa el usuario a minúsculas y compara `LOWER(usuario_nick)`: se comporta igual en los dos motores. Mi cuenta muestra el nick **tal como está guardado** (lo lee por `id_usuario`) | Sin error |
| `VARCHAR(200)` | Ver E4-03 | Corregido |
| Teléfono | `contacto_telefono VARCHAR(15)`; la validación acepta de 8 a 15 dígitos | Coincide |
| Contraseña | Se compara el SHA-256 en C++ (no en SQL), así que no depende de la collation; `password_hash CHAR(64)` | Sin error |
| `ONLY_FULL_GROUP_BY` | Mis consultas (`cargarHigiene`, `actualizarPendientesHigiene`, `cargarOcupacion`, `cargarReservasSector`, `cargarCuenta`) no usan `GROUP BY` | Sin error |
| Autorizador nulo | `id_usuario_autorizador INT NULL`; el `INSERT` manda un `QVariant` vacío cuando reserva un Profesor | Sin error |
| Collation sin tildes ni mayúsculas | Las comparaciones de estados y sectores de mis funciones son por id o por nombres de catálogo que no se repiten salvo en mayúsculas/tildes | Sin error |

## Zonas revisadas sin errores
- **Superposición de reservas (RF10):** la condición `hora_inicio < nuevo_fin AND hora_fin > nuevo_inicio` está igual que antes; la comprobé sobre la base demo en la etapa anterior (bordes contiguos permitidos, Cancelada no ocupa, otro sector no choca) y no cambió.
- **Límites de horario:** el `.ui` sigue fijando 07:00–18:59 (inicio) y 07:00–19:00 (fin); la validación del código sigue.
- **Permisos:** `exigir` protege cada acción y `aplicarPermisos` oculta los botones por rol; sin cambios.
- **Cambio de contraseña y teléfono:** mismas validaciones y mensajes; el foco va al campo con el problema.
- **Doble clic:** los avisos y confirmaciones (`confirmar`) son modales y el segundo intento recibe "Ese horario está ocupado…", sin duplicar.
- **Listas que no se recargan:** dentro de cada página se recargan tras cada acción y en `aplicarTema`; el Dashboard ahora también (E4-01).

## Observaciones (no son errores; decide el usuario)
- **Auditoría:** cambiar contraseña, teléfono o curso (salvo la cancelación de la inscripción) y cancelar una reserva de sector no se registran (RF18 no los incluye). Reportar con la observación vacía registra un **Fallido** por cada intento.
- **Contraseñas:** SHA-256 sin sal (RNF02 lo declara así).
- **Privacidad:** la ocupación muestra el nombre de quien reservó a todos los roles (US05 5.1).
- **Reservas Rechazadas:** siguen en "Reservas próximas" hasta que pasa su fecha y no hay forma de ocultarlas. Con los datos de MySQL son 3 y por eso el estado vacío del Preceptor (`SEC-19`) no se alcanza solo con la pantalla.
- **D4-01 · Reservas de Alumnos en los datos de MySQL (ronda de cierre).** `04_DatosSQL_Grupo00.sql` trae 7 reservas de sectores a nombre de usuarios con rol Alumno (Lucía Pérez, Valentina Torres —dos—, Mateo Herrera, Thiago Gutiérrez, Sofía Núñez y Benjamín Maldonado; 3 Pendientes, 1 Aprobada, 2 Rechazadas y 1 Cancelada), pero la regla de negocio dice que solo Profesores y Preceptores reservan (CONTEXTO §6 y §7) y la app no lo permite. Las 3 Pendientes cuentan en la tarjeta "Reservas de sectores pendientes" del Preceptor (8 en total). No toqué el script; propongo pasarlas a nombre de un Profesor o Preceptor.
- **D4-02 · Fechas de las reservas.** Las reservas de MySQL se crean con `CURDATE()` al ejecutar `04` (de hoy+1 a hoy+5): pasados 5 días desde la carga ya no figuran en las listas ni en las tarjetas del Inicio (la app filtra fecha ≥ hoy). Para probar hay que volver a ejecutar `04` el mismo día.
- **D4-03 · Horas de resolución de los reportes.** 8 de los 13 reportes resueltos de MySQL figuran resueltos fuera del horario escolar (por ejemplo, 00:05, 01:49, 05:54 o 23:18), y "Último mantenimiento" las muestra tal cual (por ejemplo, Biblioteca: "30/10 01:49 — Profesor Uno"). No es un error de la app: es realismo de los datos; conviene ajustarlas si se muestran en la defensa.
- **D4-04 · Texto y sector que no coinciden.** Algunos reportes nuevos tienen un sector que no encaja con lo escrito (por ejemplo, "Hay que barrer las hojas del patio" figura en Biblioteca). No afecta ninguna prueba.

---

## Defectos visuales y de microcopy (V1–V13)
Esta ronda no trae capturas: la tabla parte de las 12 de la etapa anterior (`alumno_c/o_p4`, `p7`, `p9` y `preceptor_c/o_p4`, `p7`, `p9`, claro y oscuro). En la v3 solo se corrigió V4; el resto sigue igual (el `.ui` y los textos de las listas no cambiaron). Los que dependen del `.ui` o de los `.qss` los toma Arce Thiago y Cabrera Ulises.

| # | Captura(s) | Defecto | Propuesta | Estado |
|---|---|---|---|---|
| V1 | `preceptor_c_p7`, `preceptor_o_p7` | En "Reservas próximas" la segunda línea de la pendiente se corta ("Pendiente de aprobación - Profeso…") y se pierde el nombre de quien reservó | Acortar ("Pendiente - Profesor Uno") o poner estado y persona en líneas distintas | Abierto |
| V2 | `preceptor_c_p7`, `preceptor_o_p7` | Aprobar, Rechazar y Cancelar reserva se ven activos sin selección; "Cancelar reserva" ocupa todo el ancho en rojo y llama más la atención que Aprobar | Misma altura/peso para los tres; la habilitación por selección queda como decisión (E4-14) | Decisión por defecto (§19.3) para la habilitación; Abierto para el tamaño |
| V3 | `alumno_c_p4`, `alumno_o_p4`, `preceptor_c_p4`, `preceptor_o_p4` | El reporte resuelto se parte justo entre fecha y hora ("Resuelto 20/10 / 08:45 por Maestranza Uno") | Poner "Resuelto dd/MM HH:mm por …" en su propia línea | Abierto |
| V4 | Las cuatro de Higiene | El texto de ayuda de "¿Qué pasó?" se cortaba ("Contá qué pasa (ej: falta papel, …") | Acortarlo: "Contá qué pasa (ej: falta papel)" | **Corregido (v3)**: el `.ui` ya dice "Contá qué pasa (ej: falta papel)". `[COMPLETAR: captura de la v3 que confirme que ya no se corta]` |
| V5 | Las cuatro de Higiene | "¿Dónde?" arranca en "Aula" (primer sector alfabético): se puede dejar sin querer | Empezar con una opción de ayuda ("Elegí el sector") | Abierto |
| V6 | `preceptor_c_p4`, `preceptor_o_p4` | "Marcar resuelto" se ve activo sin selección | Igual que V2 | Decisión por defecto (§19.3) |
| V7 | Las cuatro de Mi cuenta | El contenido no queda alineado con las otras páginas: empieza en x≈292 y termina en x≈1047 (Higiene y Sectores: 272 y 1068); las columnas terminan a distinta altura | Revisar los espaciadores de `contenedorCuenta` | Abierto (Arce Thiago y Cabrera Ulises, `.ui`) |
| V8 | `alumno_c_p9`, `alumno_o_p9` | Los tres combos de curso (4°, 1°, Computación) no tienen rótulo: una vez elegidos no se sabe cuál es cuál | Rótulos "Año", "División", "Especialidad" | Abierto |
| V9 | Las cuatro de Mi cuenta | En contraseña y teléfono solo hay texto de ayuda (placeholder), que desaparece al escribir | Un rótulo sobre cada campo | Abierto |
| V10 | `alumno_c_p7`, `alumno_o_p7`, `preceptor_c_p7`, `preceptor_o_p7` | El título dice "Ocupación de Biblioteca el 10/11" (sin año) y el campo Día "10/11/2026" | Unificar el formato | Abierto |
| V11 | `preceptor_c_p7`, `preceptor_o_p7` | Las flechas de Desde/Hasta son muy chicas y están apiladas | Revisar el tamaño de los botones del selector de hora (`.qss`) | Abierto (Arce Thiago y Cabrera Ulises) |
| V12 | `alumno_c_p7`, `alumno_o_p7` | La tarjeta de ocupación del alumno ocupa casi toda la pantalla con una línea | Aceptable | Sin acción |
| V13 | `alumno_c_p4`, `alumno_o_p4`, `preceptor_o_p4` | El rótulo "Último mantenimiento" no dice de qué sector es | Dejar como está o "Último mantenimiento de este sector" | Opcional |

---

## Hallazgo fuera de mis pantallas (para Arce Thiago y Cabrera Ulises)
### X-01 — `CMakeLists.txt` de la v3 referencia archivos que no vienen en el zip · Gravedad alta si va al repo
- **Dónde:** `CMakeLists.txt` (líneas finales): `foreach(h harness harness2 harness3 harness4 harness6 harness7)` con `add_executable(${h} ${h}.cpp mainwindow.cpp …)`.
- **Pasos para reproducirlo:** abrir `CMakeLists.txt` de `app_codigo.zip` (v3) en Qt Creator, o correr `cmake` sobre esa carpeta.
- **Qué pasa:** la carpeta no tiene `harness.cpp`, `harness2.cpp`, `harness3.cpp`, `harness4.cpp`, `harness6.cpp` ni `harness7.cpp` (son las pruebas automáticas internas), así que CMake debería fallar con "Cannot find source file" al configurar y **no se podría compilar la app** desde el repositorio. La versión V5 anterior no tenía esas líneas. *(Lo comprobé por lectura del `CMakeLists.txt` y de la lista de archivos; no corrí CMake.)*
- **Qué debería pasar:** el `CMakeLists.txt` que va al repo compila solo el target `PROYECTO_IQUAL`; el bloque de los `harness` queda solo en la copia de trabajo de Arce Thiago y Cabrera Ulises (o se incluyen los archivos de prueba en el repo).
- **Por qué importa para mis documentos:** el README explica cómo compilar con Qt Creator; con ese `CMakeLists.txt` el paso falla.

## Errores nuevos de esta ronda
Ninguno. Releí la v3 buscando regresiones en mis tres páginas (por ejemplo, que la comparación del curso se haga después de `obtenerCurso`, que `cargarCuenta` no dependa de nada nuevo y que `valorUnicoHoy` mande `:hoy` también a consultas que no lo usan) y no encontré nada que falle. `valorUnicoHoy` bindea `:hoy` y `:id` en todas las consultas del resumen aunque alguna no use `:hoy`: Qt ignora los nombres que no están en la consulta, así que no es un error.

## Desvíos
- No ejecuté la app: "Corregido" es verificado por lectura del código, no por prueba en pantalla. En la ronda de cierre sí cargué `03` y `04` en MariaDB 10.11 para comprobar los datos.
- El archivo de contexto de este zip dice "VERSIÓN 2.9" en el título, aunque el prompt habla de v3.0; usé su sección 20 (13/11/2026) como referencia de la v3.
- En la ronda de cierre usé el `03` y el `04` de `paquete_v7.zip`: `observaciones` (`VARCHAR(200)`), `hora_inicio` y `hora_fin` (`VARCHAR(5)`) y `contacto_telefono` (`VARCHAR(15)`) siguen igual.
- No hay capturas nuevas: el estado visual de V4 queda verificado en el `.ui`, no en una imagen.

## Datos que faltan
- Resultados de ejecutar los casos de prueba (los completa el usuario).
- Capturas de la v3 de Higiene, Sectores y Mi cuenta para cerrar la tabla V.
- Una prueba real en MySQL 8 de Oracle y en Windows (el CONTEXTO §19.1 las marca como no probadas).
- Confirmar en la compu del usuario, con la app abierta sobre MySQL, los casos de `CASOS_PRUEBA_HIGIENE_SECTORES_CUENTA.md` que dicen "datos: MySQL".
