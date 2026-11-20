# Revisión de código — Tienda de alumnos y Educación Física (Arce Thiago y Cabrera Ulises)

**Proyecto:** PROYECTO IQUAL® · SGE
**Versión revisada:** app v3 (`iqual_integrado_v3`, CONTEXTO §20 y §23, 19/11/2026): `abrirBase` llama a `abrirMySql` y no hay otro motor. La versión anterior de este documento (app de la etapa de cierre) tenía 2 hallazgos; **en la v3 los dos están corregidos**.
**Alcance:** las funciones de Tienda y Educación Física de `mainwindow.cpp` (37 funciones, listadas abajo) y `ventanaproducto.cpp/.h`. **No se tocó el código:** lo que sale se describe y lo corrige Arce Thiago y Cabrera Ulises.
**Criterio:** CONTEXTO §2 y §3 (nivel de las guías: sin lambdas, `struct`, plantillas, ternarios, `auto`, `std::`, `continue`, `qMax`/`qMin`, `findData`; `.arg` de a un parámetro; cero comentarios; consultas con `prepare()` y `bindValue()`), más el requisito de §23: el SQL es el de MySQL (ninguna función propia de otro motor).
**Método:** un script que recorre cada función por rango de líneas y busca patrones con expresiones regulares (resultado pegado más abajo) y una lectura de cada función. La búsqueda automática no reemplaza la lectura: encuentra los patrones que se le piden, no otros problemas.

## 1. Funciones revisadas
**Tienda:** `cargarGrupos`, `recaudado`, `cargarBuffet`, `on_listBuffet_itemDoubleClicked`, `cargarMisReservas`, `on_btnBuffetReservar_clicked`, `on_btnBuffetCancelar_clicked`, `cancelarReserva`, `ventaEsMia`, `productoEsMio`, `cargarMisVentas`, `cargarMisProductos`, `on_btnBuffetEntregar_clicked`, `on_btnBuffetCancelarVenta_clicked`, `on_btnProdQuitar_clicked`, `on_btnProdReponer_clicked`, `on_btnProdEliminar_clicked`, `on_btnBuffetDonar_clicked`, `on_btnBuffetUnirse_clicked`, `on_btnProdFoto_clicked`, `on_btnProdPublicar_clicked`, `on_btnGrupoCrear_clicked`, `pintarEstadoVenta`, `cargarVendedores`, `mostrarSeleccionBuffet`, `cargarDonaciones`, `mostrarFotoProducto`, `on_btnProdFotoQuitar_clicked`.
**Educación Física:** `chocaFranja`, `chocaHorario`, `ofertaElegida`, `cargarDiasEdFisica`, `cargarFranjas`, `mostrarEstadoEdFisica`, `cargarEdFisica`, `on_btnEdFisicaInscribir_clicked`, `on_btnEdFisicaCancelar_clicked`.

## 2. Resultado por regla

| Regla | Resultado |
|---|---|
| Sin lambdas | Cumple |
| Sin `struct`, plantillas, `auto`, `std::` | Cumple |
| Sin `continue`, `qMax`/`qMin`, `findData` | Cumple |
| `.arg` encadenado de a un parámetro | Cumple (ninguna llamada con dos parámetros ni con relleno) |
| Consultas con `prepare()` y `bindValue()` | Cumple. Las consultas que se arman por partes (`cargarBuffet`) solo agregan fragmentos fijos de SQL y pasan los datos con `bindValue` |
| Cero comentarios | **Cumple** (v3) |
| Sin operador ternario | **Cumple** (v3) |

### Hallazgos de la versión anterior y su estado en la v3
| ID | Qué era | Estado en la app v3 |
|---|---|---|
| R-01 | Comentario `//` en `cargarDiasEdFisica` | **Corregido:** la línea ya no está |
| R-02 | Ternario `? :` en `cargarDiasEdFisica` (`motivo`) | **Corregido:** `QString motivo = " (sin clase)"; if (q.value(2).toInt() > 0) motivo = " (choca con tu horario)";` |

### Pasada global sobre toda la app v3 (no solo mis funciones)
Comandos de búsqueda sobre `mainwindow.cpp`, `mainwindow.h`, `main.cpp` y `ventana*.cpp`: comentarios `//` **0**, `continue` **0**, ternarios **0**, `findData` **0**, lambdas **0**, `.arg(` con coma (varios parámetros) **0**, `auto`/`std::`/`struct`/plantillas/`qMax`/`qMin` **0** (la palabra «auto» que aparece una vez es el valor por defecto de `driver` en `iqual.ini`, una cadena). Consultas con SQL armado sumando texto: **0**.
Límite: es una búsqueda por texto, no un análisis estático ni una compilación; no reemplaza que Arce Thiago y Cabrera Ulises compile.

Aviso: la lectura función por función la hice solo sobre las 37 funciones de Tienda y Educación Física. Comparé el código de la v3 con el anterior: en esas funciones solo cambió `cargarDiasEdFisica`.

## 3. Observaciones que no son reglas
- `cargarDiasEdFisica` consulta `chocaFranja` en un bucle dentro de otro bucle: son pocas filas (7 días × pocas ofertas), pero es una consulta por cada oferta. Si la base creciera, convendría una sola consulta. No es un error.
- En `cargarBuffet` la búsqueda por texto usa `LIKE` con `%` + texto + `%` sin escapar (ver E-05 en `ERRORES_TIENDA_EDFISICA.md`).
- `miniaturaProducto` relee la foto en cada recarga (ver E-04).

## 4. SQL de MySQL (¿algo que no sea de MySQL?)
Busqué en las 37 funciones y en todo `mainwindow.cpp`, dentro de las cadenas SQL: `date('now')`, `datetime('now')`, `strftime`, `last_insert_rowid`, `INSERT OR IGNORE/REPLACE`, `PRAGMA`, `GLOB` y el operador `||` de concatenación. **No encontré ninguno.** La conexión la abre `abrirBase` → `abrirMySql` (`QMYSQL` o, en Windows, `QODBC`). Lo que sí usan, y existe igual en MySQL: `COALESCE`, `COUNT`, `MIN`, subconsultas en el `SELECT`, `JOIN`/`LEFT JOIN`, `LIKE`, `ORDER BY`, `DISTINCT`.
- Fechas: se pasan con `valorAhora()` y `valorFecha()` desde C++ (no se calculan en el SQL); las dos devuelven siempre `QDateTime` o `QDate` (dentro de un `QVariant`). En la v3, el resumen del Inicio también pasa «hoy» como parámetro (`:hoy`, `valorUnicoHoy`).
- Id nuevo: se usa `ultimoId(q)`, que pide `LAST_INSERT_ID()` cuando el driver es ODBC y `lastInsertId()` con `QMYSQL`.
- `ONLY_FULL_GROUP_BY`: mis funciones no usan `GROUP BY`; no aplica. (La validación de las 131 consultas con `ONLY_FULL_GROUP_BY` está en CONTEXTO §19.1, hecha por Arce Thiago y Cabrera Ulises; yo no la ejecuté.)
- A tener en cuenta: `LIKE` en MySQL no distingue mayúsculas ni tildes (collation `utf8mb4_0900_ai_ci`). Afecta la búsqueda de la Tienda, no la rompe.
- Lo que **no puedo confirmar**: que las consultas corran en MySQL 8 de Oracle ni en Windows (§19.1 dice que no se probó); no ejecuté nada.

## Desvíos
- El pedido decía «pasada de nivel de código sobre tus funciones»: la hice con un script y lectura, no con un compilador ni con una herramienta de análisis estático.
- En la v3 amplié la búsqueda a todo el código (por texto); la lectura sigue siendo solo de mis funciones.
- No compilé la v3: en mi entorno no está Qt. Que compile lo confirma Arce Thiago y Cabrera Ulises. Las pruebas de la app son los casos por pantalla con MySQL (CONTEXTO §23): lo que vale son los casos por pantalla con MySQL.

## Datos que faltan
- Ninguno para este documento.
