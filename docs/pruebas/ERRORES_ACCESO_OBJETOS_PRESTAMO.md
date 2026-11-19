# Errores encontrados — Inicio, Acceso, Dashboard, Objetos perdidos y Préstamo de equipos

**Versión:** ronda final, actualizada a la **app v3** (`iqual_integrado_v3`, CONTEXTO v3.0, §20). Reemplaza a la versión anterior; **se mantienen los IDs** `ERR-01` a `ERR-23`. Cada estado lo verifiqué leyendo el código de v3 (comparé `mainwindow.cpp` y `mainwindow.h` de v3 contra la versión anterior, línea por línea). **Ronda de cierre (19/11/2026, CONTEXTO v3.2, §22):** revisé los errores que dependen de pocos datos contra `04_DatosSQL_Grupo00.sql` (62 usuarios, cargado en MariaDB 10.11) y `iqual_sqlite.sql`; cambiaron `ERR-12`, `ERR-18` y `ERR-21`, y sumé `ERR-24` y `ERR-25`.
**Alcance:** lectura de `mainwindow.cpp`, `mainwindow.ui`, `ventanadetalle.*`, `ventanainicio.*` y `main.cpp` actuales, y de las funciones compartidas que usan estas pantallas (`aplicarPermisos`, `exigir`, `fallar`, `confirmar`, `cargarResumen`, `cargarTodo`, `cerrarSesion`, `on_stackedWidget_currentChanged`, login y registro). En esta ronda no vinieron capturas nuevas (ver 4b).
**Qué no hice:** no ejecuté la aplicación ni corregí código. Cada estado sale de leer el código actual y, donde lo aclaro, de las capturas; los pasos de reproducción están para que los verifiques.
**Gravedad:** alta = pérdida de datos, salto de permisos o fuga seria; media = resultado incorrecto o confuso que el usuario puede notar; baja = detalle, robustez o decisión pendiente. **No encontré errores de gravedad alta.**
**Estado:**
- **Corregido:** el código actual ya hace lo que debería (digo en qué función).
- **Abierto:** sigue pasando.
- **Decisión por defecto:** el comportamiento actual es una decisión vigente (CONTEXTO §19.3 y §20); no se arregla salvo que el usuario diga otra cosa.
- **A verificar:** lo deduzco de leer el código pero depende de algo que no pude comprobar (motor, Windows).

## 1. Resumen

| ID | Zona | Función | Gravedad | Estado |
|---|---|---|---|---|
| ERR-01 | Dashboard | `cargarResumen` | Media | **Corregido** |
| ERR-02 | Dashboard | `cargarResumen` (Profesor) | Media | **Corregido** |
| ERR-03 | Login | `on_btnLoginIngresar_clicked` | Media | **Corregido** |
| ERR-04 | Login | `on_btnLoginIngresar_clicked` | Media | **Decisión por defecto** (U04) |
| ERR-05 | Objetos / Publicar | `cargarCatalogos`, `on_btnObjPublicar_clicked` | Media | **Corregido** |
| ERR-06 | Objetos / Consultas | `cargarConsultas` | Media | **Corregido** |
| ERR-07 | Préstamo | `cargarPrestamos` | Baja | **Corregido** |
| ERR-08 | Préstamo | `on_btnPlanillasDevolver_clicked` | Baja | **Decisión por defecto** |
| ERR-09 | Préstamo | `on_btnPlanillasDevolver_clicked` | Baja | **Decisión por defecto** (U11) |
| ERR-10 | Varias | `fallar` y sus llamadores | Baja | **Abierto** |
| ERR-11 | Objetos | `cargarObjetos`, `cerrarSesion` | Baja | **Abierto** (la corrección no alcanza) |
| ERR-12 | Objetos | `cargarObjetos` | Baja | **Abierto** |
| ERR-13 | Objetos / Publicar | `on_btnObjPublicar_clicked` | Baja | **Abierto** |
| ERR-14 | Registro | `on_btnRegistrar_clicked` | Baja | **Abierto** |
| ERR-15 | Registro | `on_btnRegistrar_clicked`, `existe` | Baja | **Corregido en MySQL**; abierto solo en el modo SQLite |
| ERR-16 | Registro / Login | `PIN_PERSONAL`, `hashClave` | Baja | **Abierto** (limitación declarada) |
| ERR-17 | Detalle | `VentanaDetalle::setObjeto` | Baja | **Abierto** |
| ERR-18 | Préstamo | `cargarPrestamos` | Baja | **Abierto** |
| ERR-19 | Dashboard | `cargarResumen` | Baja | **Corregido** |
| ERR-20 | Objetos / Publicar | `on_btnObjPublicar_clicked` | Baja | **Corregido en v3** |
| ERR-21 | Préstamo | `cargarPrestamos` | Baja | **No se da** (cerrado: columnas `VARCHAR(5)`) |
| ERR-22 | Objetos / Consultas | `cargarConsultas` | Baja | **Corregido en v3** |
| ERR-23 | Inicio de la app | `main`, `VentanaInicio` | Baja | **Decisión por defecto** (no tocar, §20) |
| ERR-24 | Objetos / Reclamos | `resolverReclamo` | Media | **Abierto** (nuevo, datos de MySQL) |
| ERR-25 | Objetos | `cargarObjetos` | Baja | **Abierto** (nuevo, datos de MySQL) |

## 2. Detalle

### ERR-01 — Los números del Inicio no se actualizan mientras se usa la app
- **Estado: Corregido.** `on_stackedWidget_currentChanged` llama a `cargarResumen()` cada vez que la página pasa a `PAG_DASHBOARD` (con `idActual > 0`), además de la carga que hace `cargarTodo`. Verificado leyendo el código.
- **Era:** los tres números se calculaban solo al iniciar sesión.
- **Cómo probarlo:** casos `DAS-07` y `RCL-10` de `CASOS_PRUEBA_ACCESO_OBJETOS_PRESTAMO.md`.
- **Gravedad:** media.

### ERR-02 — "Tus reservas de sectores" (Profesor) contaba reservas que ya no valen
- **Estado: Corregido.** En la rama Profesor de `cargarResumen`, la consulta ahora filtra `e.nombre_estado IN ('Pendiente', 'Aprobada')` y `fecha_reserva` desde hoy. El Preceptor cuenta las pendientes desde hoy.
- **En v3:** la fecha de hoy ya no se pega en el SQL: `cargarResumen` usa el parámetro `:hoy` y `valorUnicoHoy` (nueva, `mainwindow.cpp` línea 372) lo pasa con `bindValue(":hoy", valorFecha(QDate::currentDate()))`. El Preceptor cuenta las reservas pendientes con `r.fecha_reserva >= :hoy` y el Profesor las pendientes y aprobadas con la misma condición.
- **Gravedad:** media.

### ERR-03 — El login fallido guardaba en claro lo escrito en "Usuario"
- **Estado: Corregido.** Si el usuario no existe, `on_btnLoginIngresar_clicked` registra "Intento fallido con un usuario inexistente" y ya no guarda lo que se escribió. Si el usuario existe se guarda su nombre de usuario, que es un dato legítimo.
- **En v3:** la línea con el operador ternario se reemplazó por un `if` (`on_btnLoginIngresar_clicked`, líneas 761 a 763): `detalle` arranca en "Intento fallido con un usuario inexistente" y solo cambia si el usuario existe.
- **Gravedad:** media.

### ERR-04 — Cinco fallos de cualquier persona bloquean el acceso a todos hasta reiniciar la app
- **Estado: Decisión por defecto (U04, CONTEXTO §19.3).** `intentosFallidos` sigue siendo de la ventana, solo vuelve a cero con un ingreso correcto y `cerrarSesion` no lo reinicia; con 5 fallos el botón queda deshabilitado y Enter muestra "Superaste el máximo de intentos…". No hay recuperación de contraseña en la app.
- **Qué pasa:** en una computadora compartida, un alumno que falla 5 veces bloquea a todos hasta cerrar y abrir la aplicación.
- **Qué debería pasar:** si el usuario lo decide, un bloqueo temporal (por ejemplo 60 segundos).
- **Gravedad:** media.

### ERR-05 — Al publicar, categoría y sector arrancaban con un valor elegido sin que el preceptor lo decida
- **Estado: Corregido.** `cargarCatalogos` carga los combos con "Elegí una categoría" / "Elegí un sector" y `on_btnObjPublicar_clicked` rechaza con "Elegí la categoría del objeto." y "Elegí el sector donde lo encontraron." La captura `preceptor_c_p3_t3` lo muestra.
- **Efecto secundario:** ver `ERR-20` (corregido en v3).
- **Gravedad:** media.

### ERR-06 — Las consultas no mostraban la fecha
- **Estado: Corregido.** `cargarConsultas` trae `fecha_publicacion` y la muestra en la primera línea ("Alumno Dos · tel. 1155550002 · 23/10"), como pide el criterio 8.2 de US08. Captura `alumno_c_p3_t2`.
- **Formato de la fecha:** corregido en v3 (ver `ERR-22`).
- **Gravedad:** media.

### ERR-07 — Un alumno veía los préstamos de los demás
- **Estado: Corregido.** `cargarPrestamos` filtra `p.id_usuario_solicitante = :usuario` cuando el rol es Alumno y, si no hay ninguno, dice "Todavía no tenés préstamos registrados." (Profesor, Preceptor y Maestranza ven todos.) La captura `alumno_c_p6` muestra solo C4-05.
- **Gravedad:** baja.

### ERR-08 — Devolver un equipo viene con "Funciona" elegido de antemano
- **Estado: Decisión por defecto (CONTEXTO §19.3).** El desplegable sigue arrancando en "Funciona" y solo "No funciona" pide confirmación.
- **Gravedad:** baja.

### ERR-09 — Las observaciones de la devolución pierden su prefijo si el préstamo no tenía
- **Estado: Decisión por defecto (U11, CONTEXTO §19.3).** Sigue habiendo un solo campo de observaciones para pedir y devolver. `on_btnPlanillasDevolver_clicked` agrega " / Devolución: " solo cuando ya había una observación previa; si no, guarda el texto tal cual. Queda como limitación conocida.
- **Gravedad:** baja.

### ERR-10 — Elegir "nada" deja un registro Fallido en la auditoría
- **Estado: Abierto.**
- **Función:** `fallar` con evento no vacío, en `on_btnObjReclamar_clicked` ("Elegí un objeto de la lista."), `resolverReclamo` ("Elegí un reclamo de la lista."), `on_btnPlanillasPrestar_clicked` y `on_btnPlanillasDevolver_clicked`. En cambio `on_btnObjArchivar_clicked`, las funciones de Consultas y `on_btnPlanillasReparar_clicked` ya pasan `""` y no registran: el criterio es **inconsistente** dentro de las mismas pantallas.
- **Pasos:** 1) Como alumno, "Reclamar objeto" sin elegir tarjeta. 2) Como preceptor, mirar Auditoría.
- **Qué pasa:** queda "Reclamo de objeto · Fallido · Elegí un objeto de la lista." El criterio 11.3 de US11 habla de validaciones de negocio (cupo lleno, superposición), no de olvidos de selección. La decisión de §19.3 sobre "botones sin selección" dice que avisan al apretarlos, pero no dice si se registran.
- **Qué debería pasar:** avisar sin registrar (pasar `""`), como en Archivar y Consultas.
- **Gravedad:** baja (llena la auditoría de ruido).

### ERR-11 — La tarjeta elegida de Objetos sobrevive al cambio de usuario
- **Estado: Abierto. La corrección que figura en CONTEXTO §19.2 no alcanza.**
- **Qué hay hoy:** `cerrarSesion` hace `ui->listObjetos->clearSelection()` (línea 617), pero `seleccionado()` (línea 526) lee `currentRow()` y `clearSelection()` **no cambia el elemento actual** (así lo dice la documentación de Qt). Al iniciar sesión, `cargarObjetos` guarda `seleccionado(...)` antes de reconstruir la lista y vuelve a marcar esa tarjeta.
- **Pasos:** 1) Como `alumno1`, elegir "Campera azul". 2) "Cerrar sesión". 3) Ingresar como `alumno2`. 4) Abrir Objetos.
- **Qué pasa (según el código):** la campera aparece elegida y un "Reclamar objeto" apurado actúa sobre ella.
- **Qué debería pasar:** cada sesión arranca sin selección (por ejemplo `setCurrentRow(-1)` en `cerrarSesion`).
- **Cómo verificarlo:** son los pasos de arriba; si en tu prueba no queda elegida, avisame y lo saco.
- **Gravedad:** baja.

### ERR-12 — "Objetos para reclamar: N" depende de la búsqueda, pero no lo dice
- **Estado: Abierto.** `cargarObjetos` sigue sumando solo lo que pasa el filtro.
- **Pasos:** 1) Escribir `camp` en el buscador.
- **Qué pasa:** el resumen baja sin aclarar que está filtrado. **Datos: SQLite:** de "Objetos para reclamar: 2" a 1 (queda "Campera azul"). **Datos: MySQL:** de 12 a 2 (quedan "Campera de jean" y "Campera azul").
- **Qué debería pasar:** contar siempre el total, o aclarar "(según tu búsqueda)".
- **Gravedad:** baja.

### ERR-13 — Publicar con foto puede dejar un archivo huérfano o fallar por nombre repetido
- **Estado: Abierto.** `on_btnObjPublicar_clicked` copia la foto antes del `INSERT` y `QFile::copy` no sobrescribe.
- **Pasos:** a) Publicar con una foto cuando el `INSERT` falla: el archivo queda en `imagenes_objetos` sin objeto. b) Publicar dos veces el mismo archivo dentro del mismo segundo: la segunda copia falla.
- **Qué pasa:** a) archivo huérfano; b) "No se pudo guardar la foto. Probá con otra imagen."
- **Qué debería pasar:** borrar la copia si el `INSERT` falla y evitar nombres repetidos.
- **Gravedad:** baja.

### ERR-14 — Validaciones del registro más laxas que lo que pide el texto
- **Estado: Abierto.** `on_btnRegistrar_clicked` no cambió.
- **Qué pasa:** el usuario `ju an` (con espacio en el medio) se acepta; una contraseña de cuatro espacios se acepta; el correo `a@.` pasa; el nombre `1 2` pasa.
- **Qué debería pasar:** rechazarlos con el aviso correspondiente.
- **Gravedad:** baja.

### ERR-15 — El control de correo repetido distinguía mayúsculas
- **Estado: Corregido en MySQL; abierto solo en el modo SQLite de respaldo.** `existe("usuario", "email", mail)` compara con `=`. Con MySQL, la collation por defecto (`utf8mb4_0900_ai_ci`, CONTEXTO §19.1) no distingue mayúsculas ni tildes, así que `Ana@correo.com` ya se detecta como repetido. En SQLite la comparación sigue siendo exacta.
- **Pasos:** 1) Crear `ana@correo.com`. 2) Crear otra cuenta con `Ana@correo.com`.
- **Qué pasa en SQLite:** se crea. **En MySQL:** el control dice "Ya hay una cuenta con ese correo."
- **Efecto relacionado:** con MySQL, `Optica` y `Óptica` se tratan como iguales, lo que afecta a quien arme una especialidad nueva al registrarse (decisión E4-05).
- **Gravedad:** baja.

### ERR-16 — PIN en el código y hash sin sal
- **Estado: Abierto (limitación declarada, CONTEXTO §9).** `PIN_PERSONAL` sigue siendo una constante y `hashClave` es SHA-256 sin sal.
- **Qué debería pasar:** nada por ahora; conviene declararla en la defensa.
- **Gravedad:** baja.

### ERR-17 — El detalle dice "no tiene foto" aunque el archivo exista en la base y falte en disco
- **Estado: Abierto.** `VentanaDetalle::setObjeto` sigue usando `rutaFoto.isEmpty() || foto.isNull()` para un único mensaje.
- **Pasos:** 1) Publicar un objeto con foto. 2) Borrar el archivo de `imagenes_objetos`. 3) Doble clic en el objeto.
- **Qué pasa:** "Este objeto no tiene foto."
- **Qué debería pasar:** distinguir "no tiene foto" de "no se encontró el archivo".
- **Gravedad:** baja.

### ERR-18 — La lista de préstamos muestra solo 40 y la consulta trae todos
- **Estado: Abierto.** `cargarPrestamos` mantiene `mostrados < 40` y no usa `LIMIT`.
- **Con los datos de la base:** MySQL trae 24 préstamos y SQLite 2, así que el límite no se alcanza con los datos demo; para reproducirlo hay que registrar 17 préstamos más en MySQL.
- **Qué pasa:** con más de 40 préstamos se ven los 40 primeros (activos primero) y no hay forma de paginar; el buscador por código sí encuentra los viejos. Cada tecla del buscador vuelve a leer todos.
- **Qué debería pasar:** documentarlo como límite o agregar un `LIMIT` y un aviso.
- **Gravedad:** baja.

### ERR-19 — El resumen del Profesor usaba una función de SQLite
- **Estado: Corregido.** `cargarResumen` ya no usa `date('now', 'localtime')`; busqué en todo `mainwindow.cpp` y lo único propio de SQLite que queda está en `abrirSqlite` (`PRAGMA foreign_keys`), que es el camino de respaldo.
- **Gravedad:** baja.

### ERR-20 (nuevo) — Después de publicar, categoría y sector conservaban la elección anterior
- **Estado: Corregido en v3.** `on_btnObjPublicar_clicked` ahora termina con `ui->cbObjCategoria->setCurrentIndex(0)` y `ui->cbObjSector->setCurrentIndex(0)` (líneas 1248 y 1249), así que los dos combos vuelven a "Elegí una categoría" / "Elegí un sector" después de publicar. Es lo que dice CONTEXTO §20 (punto 1) y lo verifiqué en el código.
- **Era:** se publicaba un segundo objeto con la categoría y el sector del anterior sin ningún aviso.
- **Cómo probarlo:** casos `PUB-02` y `PUB-14`.
- **Gravedad:** baja.

### ERR-21 (nuevo, a verificar) — Las horas del préstamo podrían verse con segundos en MySQL
- **Función:** `cargarPrestamos`: `q.value(6).toString()` y `"Devuelto " + q.value(7).toString()`.
- **Estado: No se da (cerrado en la ronda de cierre).** Con `SHOW COLUMNS FROM prestamo_ct;` sobre `03_ModeloSQL_Grupo00.sql` cargado en MariaDB 10.11, `hora_prestamo` y `hora_devolucion` son `varchar(5)` y los datos de `04_DatosSQL_Grupo00.sql` están como `14:10`; el driver las devuelve como texto y la lista dice "Retiró 23/10 14:10". Lo de abajo solo aplicaría si alguien cambiara las columnas a `TIME`. Falta ver el texto en pantalla en la compu del usuario.
- **Qué pasaría (si las dos columnas fueran de tipo `TIME`):** el driver de MySQL las devuelve como hora y su texto es "14:10:00", así que la lista diría "Retiró 23/10 14:10:00" y "Devuelto 15:10:00". En SQLite son texto "14:10" y se ve bien (así están las capturas).
- **Cómo verificarlo:** `SHOW COLUMNS FROM prestamo_ct;` y abrir Préstamo de equipos con MySQL.
- **Qué debería pasar:** mostrar siempre `HH:mm` (por ejemplo, tomar los primeros 5 caracteres).
- **Gravedad:** baja.

### ERR-22 (nuevo) — La fecha de las consultas salía en otro formato que el resto de la app
- **Estado: Corregido en v3.** `cargarConsultas` convierte la fecha con `QDate::fromString(..., "yyyy-MM-dd").toString("dd/MM")` y arma el texto con `.arg` encadenados (líneas 1264 y 1265). Ahora se lee "Alumno Dos · tel. 1155550002 · 23/10". Verificado en el código; no hay captura nueva que lo muestre.
- **Observación (no es un error nuevo):** el formato `dd/MM` no muestra el año, igual que Auditoría y Préstamo. Si las consultas viejas no se borran, una de hace un año se lee igual que una de esta semana. Es una decisión de formato; no la cuento como error.
- **Cómo probarlo:** casos `CON-01` y `CON-12`.
- **Gravedad:** baja (microcopy).

### ERR-23 (nuevo) — Si falla MySQL al arrancar, el aviso aparece con el splash abierto y el splash puede repetirse
- **Estado: Decisión por defecto (no tocar).** CONTEXTO §20: "la pantalla de inicio (splash) sigue como está (ERR-23, decisión: no tocar)". Verifiqué que `main.cpp`, `ventanainicio.cpp` y `ventanainicio.h` no cambiaron entre las dos versiones.
- **Qué hay hoy:** `main` muestra el splash, **construye** `MainWindow` (que abre la base y puede mostrar un aviso modal) y recién después llama a `inicio.exec()`; el `QTimer` del splash es repetitivo (2600 ms).
- **Qué pasa (según el código):** durante el aviso el temporizador dispara `accept()` y oculta el splash; al volver a `main`, `exec()` lo muestra otra vez unos 2,6 segundos más.
- **Cómo verificarlo:** 1) apagar el servidor MySQL; 2) abrir la aplicación; 3) cerrar el aviso "No se pudo usar MySQL…" pasados unos segundos. En Windows puede variar el orden de las ventanas.
- **Gravedad:** baja.

### ERR-24 (nuevo, datos de MySQL) — Un objeto "En reclamo" no vuelve a Disponible al rechazar sus reclamos
- **Estado: Abierto.**
- **Función:** `resolverReclamo`. Solo cambia el estado del objeto al **aprobar** (lo pasa a Devuelto); al rechazar solo actualiza el reclamo. El procedimiento `sp_resolver_reclamo` de `05_Backend_Grupo00.sql` sí lo hace: si el objeto estaba "En reclamo" y no le quedan reclamos Pendientes, vuelve a Disponible (y CONTEXTO §6 lo describe así).
- **Por qué recién aparece:** la app nunca marca un objeto como "En reclamo" (reclamar lo deja Disponible, caso `OBJ-04`), y SQLite no trae ninguno. El script de MySQL carga 4 objetos "En reclamo": "Auriculares blancos", "Termo verde", "Pendrive 16 GB" y "Anteojos con marco negro".
- **Pasos:** 1) Con MySQL, entrar como `preceptor1`. 2) En Reclamos, rechazar el de Martina Vega (Termo verde, el único pendiente de ese objeto). 3) Mirar Objetos.
- **Qué pasa (según el código):** "Termo verde" sigue "En reclamo" (en gris) con "(1 reclamo)" y 0 pendientes; solo sale de ahí si se aprueba un reclamo o se archiva.
- **Qué debería pasar:** volver a Disponible, como hace el procedimiento. Alternativa: que el script cargue esos objetos como Disponible, igual que las Llaves, que también tienen 2 reclamos pendientes.
- **Gravedad:** media (el objeto queda trabado en un estado que la app no sabe resolver).

### ERR-25 (nuevo, datos de MySQL) — "Objetos para reclamar" no cuenta los objetos "En reclamo", que igual se pueden reclamar
- **Estado: Abierto.**
- **Función:** `cargarObjetos` suma como "para reclamar" solo los de estado Disponible, pero `on_btnObjReclamar_clicked` rechaza solo los Devueltos y Archivados, así que un "En reclamo" también se reclama.
- **Qué pasa:** con MySQL el resumen dice "Objetos para reclamar: 12" y hay 16 que se pueden reclamar (12 Disponibles y 4 "En reclamo"). Además los "En reclamo" salen en gris, igual que los "Ya devuelto", aunque no estén devueltos.
- **Qué debería pasar:** contarlos también (y pintarlos como reclamables), o unificar los estados de los datos (ERR-24).
- **Gravedad:** baja.

## 3. Zonas revisadas sin hallazgos

- **Permisos de Objetos y Préstamo.** Cada acción llama a `exigir` con su rol (reclamar: Alumno; resolver, archivar y publicar: Preceptor; pedir y devolver: Alumno, Profesor y Preceptor; reparar: Preceptor y Maestranza) y además los controles se ocultan con `aplicarPermisos`. No encontré un camino por la interfaz para saltearlos. El dato reservado solo se carga en la ventana de detalle si `rolEs("Preceptor")`.
- **Doble clic en botones.** "Reclamar", "Publicar" y "Registrar préstamo" no generan duplicados: el índice único de `reclamo_objeto` frena el segundo reclamo, y tras publicar o prestar el formulario y la selección se vacían, así que el segundo clic cae en una validación.
- **Aprobar o rechazar con la lista desactualizada.** `resolverReclamo` vuelve a leer el estado del reclamo antes de actuar ("Ese reclamo ya fue resuelto.") y la aprobación corre en una transacción.
- **Reconstrucción de listas.** Después de cada acción de Objetos y Préstamo se recargan las listas que cambian, y el Inicio ahora se actualiza al volver (ERR-01).
- **Consultas SQL.** Todas las de estas pantallas usan `prepare()` y `bindValue()` salvo la fecha de `cargarResumen` (ver ERR-02) y no usan nada específico de SQLite: ni `date('now')`, ni `strftime`, ni `||`, ni `last_insert_rowid()`.
- **Fechas hacia MySQL.** Reclamar, publicar y publicar consulta mandan `valorFecha(QDate::currentDate())`; prestar y devolver mandan la hora como texto `HH:mm` y las columnas son `VARCHAR(5)`, así que se leen igual (ERR-21). `obtenerCurso` usa `ultimoId()`.
- **Mayúsculas en el login.** El usuario se compara con `LOWER(usuario_nick)` y la contraseña se compara por su hash, así que "ALUMNO1" entra igual que "alumno1" en SQLite y en MySQL, y la contraseña sigue distinguiendo mayúsculas.

## 4. Los dos pendientes míos

### 4a. ¿Conviene separar las observaciones de "pedir" y "devolver" un equipo? (U11)

**Estado:** el usuario no cambió la decisión (CONTEXTO §19.3 y §20: un solo campo). **Mantengo mi recomendación** por si la reabre, pero los documentos describen el campo único.

**Mi recomendación: sí conviene y es un cambio chico.** Hoy hay un solo campo (`lePlanillasObs`) dentro de la tarjeta "Pedir un equipo", pero "Devolver equipo" también lo lee desde otra tarjeta. Consecuencias: quien devuelve no sabe que tiene que escribir ahí, el texto del pedido se puede reutilizar sin querer al devolver, y la devolución guarda el texto con y sin prefijo según el caso (ERR-09).

**Qué exigiría:**
1. **`.ui`:** un `QLineEdit` nuevo, por ejemplo `leDevolucionObs`, en la tarjeta "Préstamos", junto a "¿Cómo vuelve el equipo?". `lePlanillasObs` queda solo en "Pedir un equipo".
2. **`.cpp`:** `on_btnPlanillasDevolver_clicked` lee `leDevolucionObs` en vez de `lePlanillasObs`, la limpia al terminar y guarda siempre el prefijo "Devolución: ".
3. **Funciones compartidas:** `cerrarSesion` limpia también el campo nuevo; el bloque `<tabstops>` lo suma después de "¿Cómo vuelve el equipo?"; si se ocultan los controles de devolución para Maestranza, `aplicarPermisos` lo suma a esa lista.
4. **Base de datos:** nada; sigue habiendo una sola columna `observaciones` en `prestamo_ct`.
5. **Pruebas:** actualizar `PRE-17` y sumar un caso (escribir en un campo no afecta al otro).

**Riesgo:** bajo; no cambia ninguna regla de negocio ni la base.

### 4b. Defectos visuales y de microcopy en las capturas nuevas

**Qué miré.** En esta ronda **no vinieron capturas nuevas**. Conservé la tabla de la ronda anterior (que armé mirando 11 capturas de la etapa de cierre) y la verifiqué contra el código v3: las páginas 3 y 6 y el diálogo de detalle **no cambiaron en el `.ui`** (la única diferencia de `mainwindow.ui` entre versiones es un placeholder de Higiene), así que los defectos visuales de abajo siguen, salvo los que marco como resueltos. Las capturas que nunca abrí (variantes en tema oscuro de Inicio, Reclamos, Consultas, Publicar y Auditoría, y algunas del preceptor) siguen sin verse: no afirmo nada de ellas. `[COMPLETAR: sacar capturas nuevas con la v3 para confirmar los defectos visuales]`

| Captura | Defecto | Tipo | Estado |
|---|---|---|---|
| `alumno_c_p2_inicio`, `preceptor_c_p2_inicio` | Los textos de las tarjetas de módulos quedan cortados: "Higiene y Mantenimi…", "Reserva de Sectores" y "Préstamo de equipos" casi sin margen | Visual | Sigue |
| `alumno_c_p2_inicio`, `preceptor_c_p2_inicio` | Los nombres de las tarjetas no coinciden con los de la barra lateral ni con los títulos de página: "Objetos Perdidos" / "Objetos perdidos", "Higiene y Mantenimiento" / "Higiene", "Reserva de Sectores" / "Reserva de sectores" | Microcopy | Sigue |
| `preceptor_c_p2_inicio` | Con cinco módulos queda un hueco en la grilla (falta la tarjeta de Educación Física) | Visual | Sigue |
| `alumno_c_p2_inicio` | Saludo "Hola, Alumno": toma la primera palabra del nombre de la cuenta demo ("Alumno Uno"); con datos reales saldrá bien | Microcopy | Sigue (solo demo) |
| `alumno_c_p3_t0` | (Captura con el juego chico de SQLite; con MySQL hay 21 tarjetas y la barra de desplazamiento es esperable.) Aparece la barra de desplazamiento vertical con una sola fila de tarjetas, y las miniaturas sin foto son cuadrados lisos que parecen cajas vacías: los íconos `sin_foto_*.png` todavía no están en los recursos (los pide Arce Thiago y Cabrera Ulises) | Visual | Sigue |
| `preceptor_o_p3_t0` | En tema oscuro las miniaturas vacías casi no se distinguen del fondo | Visual | Sigue |
| `alumno_c_p3_t2`, `preceptor_c_p3_t2` | Las consultas mostraban la fecha como "2026-10-23"; en v3 se ve "23/10" (ERR-22) | Microcopy | **Resuelto en v3** (por código) |
| `alumno_c_p3_t2`, `preceptor_c_p3_t2` | "Borrar consulta" se ve activo en rojo aunque no haya ninguna consulta elegida; avisa recién al apretarlo | Visual | Decisión por defecto (botones sin selección, §19.3) |
| `preceptor_c_p3_t1` | Los reclamos de un mismo objeto se leen bien, pero los ítems no tienen separación visible (solo una línea en blanco) y la selección casi no se nota | Visual | Sigue |
| `preceptor_c_p3_t3` | Categoría y sector dicen "Elegí una categoría" / "Elegí un sector", y desde v3 vuelven a ese valor después de publicar (ERR-05 y ERR-20) | Contenido | **Resuelto** |
| `preceptor_c_p3_t3` | El placeholder de "Descripción" se corta ("…otros det…") | Visual | Sigue |
| `preceptor_c_p3_t4` | "Auditoría" es global pero vive dentro de "Objetos perdidos", lo que confunde a quien la busca | Navegación | Sigue |
| `alumno_c_p6`, `preceptor_c_p6`, `alumno_o_p6` | La etiqueta "¿Cómo vuelve el equipo?" y el botón "Devolver equipo" se cortan ("¿Cómo vuelve el…", "volver equi") por el poco ancho de la tarjeta | Visual | Sigue (también en tema oscuro) |
| `alumno_c_p6`, `preceptor_c_p6`, `alumno_o_p6` | El placeholder de observaciones se corta ("…le falta una t…") | Visual | Sigue |
| `alumno_c_p6` | La línea de cada préstamo es más ancha que la lista y aparece una barra de desplazamiento horizontal; en `alumno_o_p6` el mismo texto salta a otra línea | Visual | Sigue |
| `alumno_c_p6` | En el desplegable de alumno (deshabilitado) el nombre se corta ("Alumno" en vez de "Alumno Uno") | Visual | Sigue |
| `alumno_c_p6` | La lista "Préstamos" muestra solo el préstamo del alumno (C4-05) | Contenido | **Resuelto** (ERR-07) |
| `preceptor_c_p6` | "Marcar reparado" queda habilitado sin ningún equipo elegido; avisa recién al apretarlo | Visual | Decisión por defecto (§19.3) |

## Desvíos
- No ejecuté la app: los estados salen de leer el código v3 y de compararlo con la versión anterior.
- **`ERR-11` sigue Abierto:** en v3 `cerrarSesion` todavía usa `ui->listObjetos->clearSelection()` (línea 617) y `seleccionado()` sigue leyendo `currentRow()` (línea 526; que `clearSelection()` no cambia), así que la tarjeta elegida sobrevive al cambio de usuario. El CONTEXTO §19.2 lo da por corregido; es lo único donde lo contradigo. Probalo con los pasos del archivo.
- `ERR-10`, `ERR-12`, `ERR-13`, `ERR-14`, `ERR-16`, `ERR-17` y `ERR-18` no cambiaron en v3 (verifiqué cada función).
- `ERR-21` quedó **cerrado** en la ronda de cierre: las columnas de hora son `VARCHAR(5)` en el script de MySQL.
- Ronda de cierre: `ERR-12` y `ERR-18` ahora citan los números de MySQL y de SQLite; `ERR-24` y `ERR-25` salen de los objetos "En reclamo" del script de MySQL (leí el código; no ejecuté la app). Ningún otro error dependía de pocos datos (ninguno hablaba de una lista vacía).
- Cambios de v3 que cierran errores míos: `ERR-02` (fecha por parámetro), `ERR-03`, `ERR-20` y `ERR-22`. Lo de `ERR-23` es decisión de no tocar.

## Datos que faltan
- Resultado de probar `ERR-11`, `ERR-24` y `ERR-25` en tu equipo (por confirmar en la compu del usuario).
- Ver en pantalla que las horas de Préstamo salen como `HH:mm` con MySQL (cierra del todo `ERR-21`).
- Capturas nuevas con la v3 para confirmar la tabla 4b.
- Si el usuario cambia alguna decisión de §19.3 o §20 (U04, U11, ERR-08, botones sin selección, splash), actualizar `ERR-04`, `ERR-08`, `ERR-09`, `ERR-23` y la tabla 4b.
