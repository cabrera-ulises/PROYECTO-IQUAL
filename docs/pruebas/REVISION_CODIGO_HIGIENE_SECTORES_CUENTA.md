# Revisión de código — Higiene, Sectores, Mi cuenta y helpers compartidos

**Versión de la ronda final (app v3).** Reemplaza a la `REVISION_CODIGO_HIGIENE_SECTORES_CUENTA.md` anterior y mantiene sus IDs (R-01 a R-15), con la columna **Estado** verificada en el código de la v3.

**Contra qué se revisó:** las reglas de la profesora (CONTEXTO §2 y §3) y las que se sumaron en `DISENO_IQUAL.md` (sin lambdas, structs, templates, ternarios, `auto`, `std::`, `continue`, `qMax`, `findData`; `.arg` encadenado de a un parámetro; cero comentarios; consultas con `prepare()`/`bindValue()`; `delete` después de `takeItem`).
**Sobre qué:** `mainwindow.cpp` (3270 líneas, 186 funciones) y `mainwindow.h` de la app v3 (`iqual_integrado_v3`, CONTEXTO §20). Los números de línea son los de ese archivo y pueden correrse si se edita.
**No corregí nada**: cada hallazgo dice qué había, qué hay ahora y qué falta.

## Qué miré de verdad y qué no
| Qué hice | Alcance |
|---|---|
| **Lectura completa, línea por línea** | Las 23 funciones de Higiene, Sectores y Mi cuenta (tabla del punto 3), los helpers pedidos (`confirmar`, `plural`, `agregarVacio`, `pintarUltimo`, `colorToken`, `elegirPorId`, `alternarVacio`, `abrirBase`, `abrirSqlite`, `abrirMySql`, `nombreDriverOdbc`, `valorFecha`, `valorAhora`, `ultimoId`) y los que cambiaron o se agregaron en la v3 (`valorUnicoHoy`, `cargarResumen`, `codigoRecurso`, `on_btnLoginIngresar_clicked` en el tramo corregido). Además leí el **diff completo entre la v3 y la versión anterior** (78 líneas de `mainwindow.cpp`, una de `mainwindow.ui`, una de `mainwindow.h`) |
| **Escaneo automático** | Un script recorre las **186 funciones** buscando comentarios, ternarios, `auto`, `std::`, `continue`, `qMax`/`qMin`, `findData`, lambdas, expresiones regulares, `struct`/`template`, `QOverload`, `takeItem` sin `delete` y `.arg` con más de un parámetro (incluso partido en varias líneas). Resultado en la v3: **0 hallazgos**. También recorrí `mainwindow.h`, `main.cpp`, `ventanainicio.*`, `ventanadetalle.*` y `ventanaproducto.*`: sin comentarios |
| **No hice** | No compilé ni ejecuté la app; no leí a mano las ~160 funciones de otros módulos; no revisé `.ui`, `.qss`, `CMakeLists.txt` ni `recursos.qrc`. El escaneo busca patrones de texto: puede dejar pasar algo raro (por ejemplo, un ternario escrito en varias líneas) |

## Resultado en una línea
**Las reglas prohibidas se cumplen en todo el archivo.** Los 8 comentarios, 4 ternarios, 1 `continue`, 1 `findData` y 6 `.arg` con varios parámetros de la revisión anterior **ya no están** (R-01 a R-07 corregidos). Queda un truco de estilo en `cargarResumen`, la duplicación `ponerDato`/`elegirPorId` y una función larga (ver abajo). Mis 23 funciones siguen sin hallazgos.

---

## 1. Hallazgos contra las reglas
| ID | Función (línea aprox. en la v3) | Regla | Qué había | Estado y verificación | Dueño |
|---|---|---|---|---|---|
| R-01 | `abrirBase` (90), `ultimoId` (118), `nombreDriverOdbc` (128), `abrirMySql` (145), `valorAhora` (469), `formatoCorto`, `cargarDiasEdFisica` | §2.1 y DISENO: cero comentarios | 8 líneas con `//` | **Corregido.** El escaneo no encuentra ninguna línea con `//` ni `/*` en el archivo | Arce Thiago y Cabrera Ulises / Arce Thiago y Cabrera Ulises |
| R-02 | `abrirBase`, `on_btnLoginIngresar_clicked`, `cargarPrestamos`, `cargarDiasEdFisica` | §3: sin ternarios | 4 ternarios | **Corregido.** Ahora son `if` con una variable: `QString sufijo = " · MySQL"; if (db.driverName() == "QODBC") sufijo = …` (líneas 105–107), `QString detalle = …` en el login (761–763), `QString donde = ""; if (soloMios) donde = …` (2222–2223) y `QString motivo = " (sin clase)"; if (… > 0) motivo = " (choca con tu horario)"` (2682–2683) | Arce Thiago y Cabrera Ulises, 2 y 3 |
| R-03 | `abrirSqlite` (196) | DISENO: sin `continue` | `if (sentencia.isEmpty()) continue;` | **Corregido.** Ahora es `if (!sentencia.isEmpty() && !q.exec(sentencia)) { … return false; }` (línea 219). Mismo comportamiento: una sentencia vacía no se ejecuta ni falla | Arce Thiago y Cabrera Ulises |
| R-04 | `cargarTodo` | DISENO: sin `findData` | 1 uso | **Corregido.** Usa `elegirPorId(ui->cbPlanillasAlumno, idActual)` (línea 284) | Arce Thiago y Cabrera Ulises |
| R-05 | `abrirMySql`, `idPorNombre`, `existe`, `cargarConsultas` | DISENO: `.arg` de a un parámetro | 4 `.arg` con varios parámetros | **Corregido.** Todos encadenados (`.arg(a).arg(b).arg(c)`): líneas 162–163, 350, 386 y 1264–1265. El escaneo de `.arg` con coma (multilínea incluido) no encuentra ninguno | Arce Thiago y Cabrera Ulises y 2 |
| R-06 | `codigoRecurso` | DISENO: `.arg` de a un parámetro | `.arg(numero, 2, 10, QChar('0'))` (formato) | **Corregido.** `QString texto = QString::number(numero); if (texto.size() < 2) texto = "0" + texto;` y después se arma el código por concatenación (líneas ~565–568) | Arce Thiago y Cabrera Ulises |
| R-07 | `cargarResumen` (2999) | DISENO: consultas con `prepare()`/`bindValue()` | La fecha de hoy se pegaba dentro del SQL | **Corregido.** Las consultas usan `:hoy` y se ejecutan con la función nueva `valorUnicoHoy` (372), que hace `prepare` + `bindValue(":id")` + `bindValue(":hoy", valorFecha(QDate::currentDate()))` | Arce Thiago y Cabrera Ulises |
| R-08 | `cargarResumen` (líneas 3019 a 3043) | Estilo (guías: código simple) | Condiciones `AND :id > 0` | **Abierto.** Sigue el truco para poder bindear siempre `:id` aunque la consulta no filtre por usuario; `valorUnicoHoy` además bindea `:hoy` en consultas que no lo usan (Qt lo ignora). Anotarlo en el informe como decisión, o tener variantes de `valorUnico` sin parámetros | Arce Thiago y Cabrera Ulises |

## 2. Clases y funciones fuera de la lista de §3 (hay que listarlas como "extras" en el informe)
La regla dice: "Permitido extra, solo lo imprescindible, y hay que listarlo en el informe final con una línea de explicación cada uno". Sigue siendo lo mismo que en la revisión anterior (la v3 no agregó clases nuevas); lo que **no** está en la lista de §3 y aparece en el código:
| Elemento | Dónde (líneas v3) | Para qué | Mío |
|---|---|---|---|
| `QSettings` (`iqual.ini`, tema, registro de Windows) | 68, 92, 128–145, 2961 | Guardar el motor y la conexión, y la elección de tema | |
| `qEnvironmentVariable` | 101 | Forzar SQLite con `IQUAL_MOTOR` (la usan las pruebas) | |
| Drivers `QMYSQL` y `QODBC` (además de `QSQLITE`) | `abrirMySql` | Conectar con MySQL | |
| `QSqlError` | `abrirMySql` (13 es el `#include`) | Mostrar el motivo cuando falla la conexión | |
| `QSysInfo::machineHostName()` | 450 (`registrarLog`) | Guardar el equipo en el log de auditoría | |
| `QDir().mkpath` | 1216, 2048 | Crear la carpeta de fotos | |
| `QIcon`, `QPixmap` escalado | 234, 993, 1504 | Íconos y miniaturas | |
| `QColor`, `QBrush`, `setForeground` | `colorToken` (3054), `pintarUltimo` (3206), `pintarEstadoVenta` | Color por estado en las listas | **Sí** |
| `QFont` + `setFlags` + `insertItem` | `cargarOcupacion` (2408–2411) | Línea de aviso en negrita y no seleccionable, arriba de la ocupación | **Sí** |
| `QMessageBox` como objeto con `addButton`/`clickedButton` | `confirmar` (422) | Preguntas con botones "Sí" y "No" en español (el `question` estático los muestra en inglés si no hay traducciones) | |
| `QListWidgetItem::setToolTip` | `cargarHigiene`, `cargarReservasSector` | Mostrar el texto completo de cada ítem | **Sí** |
| `blockSignals` | 506, 515, 2653, 2692, 2702, 2735, 3074, 3078 | Evitar disparar slots al cargar combos | |
| `#ifdef Q_OS_WIN` | 132 (`nombreDriverOdbc`) | Buscar el driver ODBC solo en Windows | |
| `QMovie` y `QTimer` | `ventanainicio.cpp` | Splash con el GIF y cierre automático | |

Dentro de lo permitido, pero conviene tenerlo presente para la defensa: `QDateEdit`/`QTimeEdit` con `setMinimumDate`, `setMinimumTime` y `setMaximumTime` (los límites 07:00–19:00 están en el `.ui`).

## 3. Mis funciones, una por una (v3)
| Función | Líneas | Resultado |
|---|---|---|
| `cargarHigiene` | 1316–1355 | Cumple. Arma el SQL con fragmentos fijos; ningún dato del usuario entra al texto SQL. 40 líneas |
| `actualizarPendientesHigiene` | 3232–3244 | Cumple (`prepare` + `bindValue`) |
| `actualizarUltimoMantenimiento` | 1357–1370 | Cumple |
| `on_btnHigieneReportar_clicked` | 1374–1399 | Cumple. `trimmed()`/`isEmpty()`, `valorAhora()` y `bindValue` |
| `on_btnHigieneResolver_clicked` | 1403–1431 | Cumple. `exigir`, validaciones y `bindValue` |
| `on_leHigieneObs_returnPressed`, `on_cbHigieneSector_…`, `on_cbHigieneFiltro_…` | 1401, 1372, 2924 | Cumplen (una línea cada uno) |
| `cargarOcupacion` | 2372–2415 | Cumple. `valorFecha()` y `bindValue`. Extras: `QFont`, `setFlags`, `insertItem` (§2) |
| `cargarReservasSector` | 2417–2452 | Cumple |
| `on_btnSectoresReservar_clicked` | 2457–2533 | Cumple las reglas, pero es **la función más larga del archivo (77 líneas)**: ver R-10 |
| `on_btnSectoresCancelar_clicked`, `resolverReservaSector`, `on_btnSectoresAprobar_clicked`, `on_btnSectoresRechazar_clicked` | 2535–2611 | Cumplen. Usan `confirmar` y `exigir` |
| `on_cbSectoresLugar_…`, `on_deSectoresDia_dateChanged` | 2454, 2455 | Cumplen |
| `cargarCuenta` | 782–806 | Cumple. Usa `ponerDato` (R-09) y es la que vuelven a llamar los casos de "No" y de curso repetido |
| `on_btnCuentaGuardar_clicked` | 808–861 | Cumple (la v3 le sumó la comparación con el curso guardado y la recarga tras el "No"). **54 líneas** y 6 salidas con `return`: ver R-10 |
| `on_btnCuentaClave_clicked` | 863–907 | Cumple. 45 líneas; compara el hash en C++ |
| `on_btnCuentaTelefono_clicked`, `on_leCuentaClaveRepetir_returnPressed`, `on_leCuentaTelefono_returnPressed` | 911–941 | Cumplen |

## 4. Observaciones sobre mis funciones y helpers (no son violaciones)
| ID | Dónde | Qué hay | Cómo debería | Estado |
|---|---|---|---|---|
| R-09 | `ponerDato` (3221) y `elegirPorId` (3072) | Hacen casi lo mismo. `ponerDato` (mío) vuelve al índice 0 si no hay coincidencia y no bloquea señales; `elegirPorId` bloquea señales y deja el índice como estaba | Dejar uno solo: en `cargarCuenta` usar `elegirPorId` agregándole `combo->setCurrentIndex(0)` al principio, y borrar `ponerDato`. Los combos de Mi cuenta no tienen slot conectado, así que no importa el bloqueo de señales | **Abierto** |
| R-10 | `on_btnSectoresReservar_clicked` (77 líneas) y `on_btnCuentaGuardar_clicked` (54) | Mezclan validaciones, consultas, el `INSERT`/`UPDATE` y los avisos en una sola función. Cumplen las reglas, pero "código simple y pocas líneas" | Separar en funciones chicas (por ejemplo `bool hayChoqueReserva(int sector, const QDate &dia, const QString &inicio, const QString &fin)` y una para el choque de Educación Física). No urgente | **Abierto** |
| R-11 | `pintarUltimo` / `agregarVacio` / `alternarVacio` / `pintarEstadoVenta` | Dos formas de resolver el estado vacío (un ítem gris o un `QLabel` que se alterna con la lista) y dos de pintar estados | Es una decisión de diseño y funciona; en el informe, nombrar `agregarVacio` y `alternarVacio` como "estado vacío" | Sin cambios |
| R-12 | `confirmar` (422) | Devuelve `caja.clickedButton() == si`; si se cierra con la X, no confirma | Correcto (la X equivale a "No") | Sin cambios |
| R-13 | `valorFecha` / `valorAhora` / `valorUnicoHoy` | `valorFecha` y `valorAhora` devuelven `QVariant` (texto para SQLite; `QDate`/`QDateTime` para MySQL) y `valorUnicoHoy` los usa | Correcto y simple. Explicar en el informe que esa es la razón de ser de esos métodos | Sin cambios |
| R-14 | `colorToken` (3054) | Los colores están escritos como `QColor("#…")` en el `.cpp` (DISENO §2 dice que nadie escribe colores en el `.cpp`, pero §4.7 admite `QColor` con los tokens para las listas) | Es el único lugar con colores; los claros usados son más oscuros que los del DISENO por contraste. Documentarlo | Sin cambios |
| R-15 | `takeItem` / `delete` | Ninguna función usa `takeItem` | Sin problema | Sin cambios |

## 5. Lo que queda
- **Abiertos:** R-08, R-09 y R-10 (los tres de estilo; ninguno rompe una regla prohibida).
- La tabla de extras de §2 es lo que la profesora tiene que ver en el informe (la regla pide listarlos).

## Desvíos
- No compilé ni ejecuté la app.
- El escaneo automático busca patrones de texto; lo complementé leyendo a mano los helpers pedidos, las funciones corregidas y mis 23 funciones, pero **no** leí a mano las otras ~160 funciones.
- No revisé `.ui`, `.qss`, `CMakeLists.txt` ni `recursos.qrc` (no eran parte del pedido).
- Los números de línea son aproximados (los saqué del archivo de la v3 tal como vino en el zip).

## Datos que faltan
- Ninguno. (La decisión de qué abiertos corregir es de Arce Thiago y Cabrera Ulises.)
