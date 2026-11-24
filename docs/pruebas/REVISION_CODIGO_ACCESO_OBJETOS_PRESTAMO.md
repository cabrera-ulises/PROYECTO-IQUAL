# Revisión de nivel de código — funciones de Arce Thiago y Cabrera Ulises

**Versión:** ronda final, sobre la **app v3** (`iqual_integrado_v3`, CONTEXTO v3.0, §20). **Ronda sin SQLite (19/11/2026, CONTEXTO v3.3, §23):** la volví a pasar sobre el código actual del repositorio (`repo.zip`), donde `abrirSqlite` y el driver de SQLite ya no existen. Reemplaza a la revisión anterior.
**Archivos revisados:** `mainwindow.cpp`, `mainwindow.h`, `ventanadetalle.cpp`, `ventanainicio.cpp`, `ventanainicio.h` y `main.cpp` del repositorio actual (`repo.zip`). Los números de línea son los de ese `mainwindow.cpp`; cambiaron respecto de la revisión anterior porque se sacó el código de SQLite.
**Reglas contra las que revisé:** CONTEXTO §2 (cero comentarios, `delete` después de `takeItem`, código simple) y §3 (lo permitido, lo permitido extra que hay que listar y lo prohibido: `struct`, expresiones regulares, lambdas, operador ternario, `QOverload`, referencias devueltas, templates, herencia propia salvo `QDialog`, comentarios), más las reglas comunes de la etapa: sin `auto`, `std::`, `continue`, `qMax` ni `findData`, `.arg` encadenado de a un parámetro y consultas con `prepare()` y `bindValue()`.
**No toqué el código.**

## 1. Resultado

**En mis funciones no queda ninguna infracción de §2 ni de §3 en la v3.** Los cuatro hallazgos de la revisión anterior (R-01 a R-04) están corregidos, y la búsqueda automática de patrones sobre **todo** el archivo (no solo mis funciones) no encontró ninguna otra.

| # | Función | Qué había | Estado en v3 | Dónde lo verifiqué |
|---|---|---|---|---|
| R-01 | `on_btnLoginIngresar_clicked` | Operador ternario en el `registrarLog` | **Corregido** | Líneas 740 a 742: `QString detalle = "Intento fallido con un usuario inexistente";`, un `if (idActual > 0)` y `registrarLog("Inicio de sesión", detalle, ...)` |
| R-02 | `cargarPrestamos` | Ternario dentro de `.arg(...)` | **Corregido** | Se arma antes `QString donde = "";` y un `if (soloMios)`, y el SQL usa `.arg(donde)` |
| R-03 | `cargarConsultas` | `.arg` con cuatro parámetros | **Corregido** | Líneas 1243 y 1244: `.arg(...).arg(...).arg(dia).arg(...)` encadenados |
| R-04 | `cargarResumen` | La fecha de hoy se pegaba dentro del SQL | **Corregido** | Las consultas usan `:hoy` y la nueva `valorUnicoHoy` (línea 333) lo pasa con `bindValue(":hoy", valorFecha(QDate::currentDate()))`; las tres cifras del Inicio se piden con `valorUnicoHoy` (líneas 3027 a 3029) |

## 2. Qué miré de verdad y qué no

**Miré (leídas completas, y pasadas por la búsqueda automática):**
- **Objetos:** `cargarObjetos`, `on_listObjetos_itemDoubleClicked`, `cargarReclamos`, `on_btnObjReclamar_clicked`, `resolverReclamo` y sus dos slots, `on_btnObjArchivar_clicked`, `on_btnObjFoto_clicked`, `on_btnObjPublicar_clicked`, `cargarConsultas`, `on_btnConsultaPublicar_clicked`, `on_btnConsultaBorrar_clicked`, `cargarAuditoria` y los slots de búsqueda y filtro.
- **Préstamo de equipos:** `cargarPlanillas`, `cargarFueraServicio`, `mostrarProgramas`, `cargarPrestamos`, `on_btnPlanillasPrestar_clicked`, `on_btnPlanillasDevolver_clicked`, `on_btnPlanillasReparar_clicked`, `actualizarResumenPlanillas` y los slots de filtro.
- **Acceso e Inicio:** `on_btnLoginIngresar_clicked`, `on_btnRegistrar_clicked`, `actualizarRegistro`, `limpiarRegistro`, `cargarResumen`, `valorUnicoHoy`, `on_stackedWidget_currentChanged` y los slots de navegación de mis pantallas.
- **Ventanas:** `VentanaDetalle`, `VentanaInicio` y `main.cpp`.
- **Compartidas (solo lectura, porque las usan mis pantallas):** `cerrarSesion`, `exigir`, `fallar`, `confirmar`, `agregarVacio`, `plural`, `colorToken`, `seleccionado`, `elegirPorId`.

**Cómo busqué:** una pasada automática, función por función, con patrones para comentarios (`//` y `/*`), operador ternario, `continue`, `qMax`/`qMin`, `findData`, `auto`, `std::`, lambdas en `connect`, `struct`/`template`/`QRegularExpression`/`QOverload` y `.arg(` con más de un parámetro; más una lectura a ojo de cada función y una búsqueda de `takeItem` (no se usa en ninguna parte, así que no hay `delete` pendiente). La pasada automática es una heurística: puede dejar pasar un caso raro (por ejemplo, una expresión partida en varias líneas).

**No miré:**
- Los `.ui` ni los `.qss`.
- Que el código compile o que los resultados sean correctos: no lo ejecuté. Los harness automáticos de la ronda final ya no existen (CONTEXTO §23): las pruebas de la app son los casos por pantalla de `CASOS_PRUEBA_ACCESO_OBJETOS_PRESTAMO.md` y los 104 casos de los procedimientos.
- El contenido de las funciones de los otros chats más allá de la búsqueda de patrones.

## 3. Todo el archivo, no solo mis funciones

CONTEXTO §20 dice que la v3 corrigió las infracciones en todo el archivo. Lo verifiqué con la misma búsqueda de patrones sobre `mainwindow.cpp`, `ventanadetalle.cpp`, `ventanainicio.cpp` y `main.cpp`: **0 hallazgos** (repetida en esta ronda sobre el código actual, también con `mainwindow.h`, `ventanadetalle.h` y `ventanainicio.h`) de comentarios, ternarios, `continue`, `qMax`, `findData`, `auto`, `std::`, lambdas ni `.arg` con varios parámetros. Las que había en la revisión anterior en funciones de otros (comentarios en `abrirBase`, `ultimoId`, `nombreDriverOdbc`, `abrirMySql`, `valorAhora` y `formatoCorto`; el ternario de `abrirBase`; el `findData` de `cargarTodo`; el comentario y el ternario de `cargarDiasEdFisica`) ya no están. `abrirSqlite` ya no existe (CONTEXTO §23): `abrirBase` solo llama a `abrirMySql` y, si falla, avisa el motivo y devuelve `false`; el constructor de `MainWindow` deshabilita el `stackedWidget`. También desaparecieron el `.arg` con relleno de `codigoRecurso` y los `.arg` de varios parámetros de `abrirMySql`, `idPorNombre` y `existe`.

**Una observación (no es una infracción):** `hoy()` quedó definida en `mainwindow.cpp` (línea 460) y declarada en `mainwindow.h`, pero ya no la usa ninguna función (el dashboard pasó a `valorFecha(QDate::currentDate())`). Es código sin uso: se puede borrar o dejar.

## 4. Extras fuera de la lista permitida de §3 (para el informe final, una línea cada uno)

No son infracciones por sí mismos, pero §3 pide listarlos con una línea de explicación. La lista sigue siendo la misma que en la revisión anterior.

| Extra | Dónde lo uso | Para qué |
|---|---|---|
| `QListWidgetItem::setForeground` con `QBrush` y `QColor` (vía `colorToken`) | `cargarObjetos`, `cargarFueraServicio`, `cargarPrestamos`, `cargarAuditoria` | Pintar el estado de cada ítem (verde, gris, rojo) como pide DISENO §4.7 |
| `QListWidgetItem::setIcon` y `QIcon` | `cargarObjetos` | Miniatura de la foto en las tarjetas |
| `QListWidget` en modo `IconMode` (propiedades en el `.ui`) | `listObjetos` | Mostrar los objetos como tarjetas |
| `agregarVacio` (ítem no seleccionable con `setFlags`) | todas las listas | Mensaje de lista vacía (DISENO §4.6) |
| `QTabWidget::setTabText` y `setTabVisible` | `cargarReclamos`, `aplicarPermisos` | Mostrar "Reclamos (N)" y ocultar pestañas por rol |
| `QVariant` | `on_btnObjPublicar_clicked`, `on_btnPlanillasPrestar_clicked`, `on_btnRegistrar_clicked` | Guardar `NULL` cuando un campo opcional está vacío |
| `QDir().mkpath` | `on_btnObjPublicar_clicked` | Crear la carpeta `imagenes_objetos` si falta |
| `QDate` / `QTime` y `valorFecha` | reclamar, publicar, consultas, prestar, devolver, `valorUnicoHoy` | Mandar fechas a MySQL como fecha y no como texto, y leer la fecha de las consultas para mostrarla día/mes |
| `QMessageBox` armado a mano (`addButton`, `setDefaultButton`, `clickedButton`) | `confirmar` (Arce Thiago y Cabrera Ulises) | Botones "Sí" y "No" en español |
| `QSettings` | `on_btnTema_clicked` y `abrirBase` (Arce Thiago y Cabrera Ulises) | Recordar el tema elegido y leer `iqual.ini` |
| `QMovie`, `QTimer`, `QMouseEvent` y `mousePressEvent` | `VentanaInicio` | Mostrar el splash animado, cerrarlo solo a los 2,6 segundos o con un clic |
| `Qt::SplashScreen` y `Qt::FramelessWindowHint` | `VentanaInicio` | Ventana sin bordes para el splash |

`VentanaInicio` hereda de `QDialog`, que es la herencia permitida; el único método sobrescrito es `mousePressEvent`.

## 5. Consultas: SQL estándar que corre en MySQL (§23)

Revisé de nuevo todas las consultas de mis funciones sobre el código actual. **Todas son SQL estándar que MySQL ejecuta tal cual** y ya no hay ninguna rama ni función por motor: `abrirSqlite` y el driver de SQLite se sacaron en la ronda sin SQLite (CONTEXTO §23). Busqué en todo `mainwindow.cpp`, `mainwindow.h`, `ventanadetalle.*`, `ventanainicio.*` y `main.cpp` `PRAGMA`, `strftime`, `date('now')`, `datetime(`, `INSERT OR`, `AUTOINCREMENT`, `IFNULL`, `GLOB`, `last_insert_rowid`, `QSQLITE` y `IQUAL_MOTOR`: **0 resultados** (la búsqueda de `datetime(` solo encuentra `QDateTime::currentDateTime()` de Qt, que no es SQL).

| Zona | Funciones | Lo que usan | Resultado |
|---|---|---|---|
| Objetos | `cargarObjetos`, `cargarReclamos`, `on_btnObjReclamar_clicked`, `resolverReclamo`, `on_btnObjArchivar_clicked`, `on_btnObjPublicar_clicked`, `on_listObjetos_itemDoubleClicked` | `JOIN`, subconsulta `COUNT(*)`, `COALESCE`, `UPDATE`/`INSERT` con parámetros | Estándar |
| Consultas y auditoría | `cargarConsultas`, `on_btnConsultaPublicar_clicked`, `on_btnConsultaBorrar_clicked`, `cargarAuditoria` | `JOIN`, `LEFT JOIN`, `ORDER BY` | Estándar |
| Préstamo | `cargarPlanillas`, `cargarFueraServicio`, `cargarPrestamos`, `on_btnPlanillasPrestar_clicked`, `on_btnPlanillasDevolver_clicked`, `on_btnPlanillasReparar_clicked`, `mostrarProgramas`, `actualizarResumenPlanillas` | `EXISTS`, `ORDER BY CASE WHEN`, `GROUP BY` con la columna agrupada, `COALESCE`, `NULL` literal en el `INSERT` | Estándar (el `GROUP BY` cumple `ONLY_FULL_GROUP_BY`) |
| Acceso e Inicio | `on_btnLoginIngresar_clicked`, `on_btnRegistrar_clicked`, `cargarResumen`, `valorUnicoHoy` | `LOWER(usuario_nick)`, comparación del hash, `COUNT(*)`, `IN (...)`, `>= :hoy` con la fecha por parámetro | Estándar |

Otras notas:
- `AND :id > 0` (en `cargarObjetos` y `cargarResumen`, para que `valorUnico` siempre reciba su parámetro) queda como `? > 0`, válido en MySQL y también en SQL Server.
- `valorUnicoHoy` le pasa siempre `:hoy` aunque la consulta no lo use; Qt ignora un parámetro que no está en el SQL, y CONTEXTO §20 dice que los harness pasaron con 0 fallas.
- Todos los `LIMIT` de la app están hechos en C++ (por ejemplo `mostrados < 40`), no en el SQL.
- **Lo que no es sintaxis pero depende de la base:** cómo se lee `hora_prestamo`. Las columnas son `VARCHAR(5)` y se leen como texto `HH:mm` (ver `ERR-21` en `ERRORES_ACCESO_OBJETOS_PRESTAMO.md`: cerrado, falta solo verlo en pantalla).

## Desvíos

- Esta revisión no incluye `cerrarSesion`, `cargarTodo` ni `aplicarPermisos` como "mías": son compartidas y de Arce Thiago y Cabrera Ulises; solo las leí para verificar errores.
- El resultado "0 hallazgos" sale de la lectura y de la búsqueda automática; no usé ningún analizador de código.
- No compilé ni ejecuté nada.
- Ronda sin SQLite (19/11/2026): en la sección 3 saqué `abrirSqlite` de la lista de funciones corregidas (ya no existe) y actualicé los números de línea de R-01, R-03, R-04 y de `hoy()`; el `.cpp` no lo toqué. Verifiqué las líneas con `grep -n` sobre el `mainwindow.cpp` de `repo.zip`.

## Datos que faltan
- Ninguno para esta entrega.
