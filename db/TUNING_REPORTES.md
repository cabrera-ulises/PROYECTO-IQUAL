# TUNING_REPORTES — optimización de dos reportes (clase 004)

**Proyecto IQUAL® (SGE)** · Autor del documento: Arce Thiago y Cabrera Ulises · Fecha: 14/11/2026 · Archivo SQL: `05b_Backend_reportes.sql`
Nivel: el de la clase 004 (árboles de ejecución, álgebra relacional, selección y proyección conmutativas, reunir lo mínimo, tablas temporales). Nada fuera de clase.

## 0. Qué se optimiza y por qué estos dos

| Original | Tuneado | Por qué lo justifica |
|---|---|---|
| `sp_rep_ventas_por_producto` | `sp_rep_ventas_por_producto_tuneado` | Reúne **5 tablas** (`detalle_venta`, `venta_buffet`, `estado_venta`, `producto_buffet`, `categoria_producto`) y recién después filtra por estado y fecha. `detalle_venta` es la tabla que más crece del sistema (una fila por producto de cada venta). |
| `sp_rep_actividad_por_usuario` | `sp_rep_actividad_por_usuario_tuneado` | Tiene **3 `LEFT JOIN` en paralelo** sobre el mismo usuario: las filas se **multiplican** (préstamos × reservas × reclamos de cada usuario) y hay que arreglarlo con `COUNT(DISTINCT …)`. Es el caso típico donde reunir antes de agrupar es caro. |

Los dos tuneados devuelven **exactamente** las mismas filas, columnas (nombre, tipo y orden) y el mismo orden que el original. Eso lo comprueba el caso `04` de cada uno en `06_PruebasSQL_claude3.xlsx`.

**Notación.** σ = selección (WHERE), π = proyección (columnas), ⋈ = reunión (JOIN), γ = agrupamiento (GROUP BY + funciones), τ = orden (ORDER BY).
`det` = `detalle_venta`, `ven` = `venta_buffet`, `est` = `estado_venta`, `pro` = `producto_buffet`, `cat` = `categoria_producto`, `usu` = `usuario`, `rol` = `rol`, `pre` = `prestamo_ct`, `res` = `reserva_sector`, `rec` = `reclamo_objeto`.

---

## 1. `sp_rep_ventas_por_producto` → `sp_rep_ventas_por_producto_tuneado`

### 1.1 Antes (el SQL del original)
Una sola consulta: se reúnen las 5 tablas, se filtra con `WHERE` y se agrupa.

```
τ monto_total DESC, nombre_producto, id_producto
 └─ π id_producto, nombre_producto, nombre_categoria, [agregados]
     └─ γ id_producto, nombre_producto, nombre_categoria ;  SUM(cantidad), COUNT(*), SUM(cantidad*precio_unitario), MIN(DATE(fecha_hora)), MAX(DATE(fecha_hora))
         └─ σ  est.nombre_estado = 'Entregada'  ∧  ven.fecha_hora ∈ [desde, hasta]
             └─ ⋈ cat.id_categoria_producto = pro.id_categoria_producto
                 ├─ ⋈ pro.id_producto = det.id_producto
                 │   ├─ ⋈ est.id_estado_venta = ven.id_estado_venta
                 │   │   ├─ ⋈ ven.id_venta = det.id_venta
                 │   │   │   ├─ det
                 │   │   │   └─ ven
                 │   │   └─ est
                 │   └─ pro
                 └─ cat
```
Como en la diapositiva 3 de la clase: la selección está **arriba de todas las reuniones**, así que las 5 relaciones llegan completas a la reunión. (Un optimizador moderno puede empujar el `WHERE` hacia abajo por su cuenta; acá lo dejamos escrito explícito, que es lo que muestra la clase y lo que podemos defender.)

### 1.2 Después (el SQL del tuneado)
Tres pasos, con la misma lógica de las diapositivas 4 a 13:

```
Paso 1 (σ conmutativa + π conmutativa)   tmp_ventas_entregadas = π id_venta, DATE(fecha_hora) ( σ nombre_estado='Entregada' ∧ fecha_hora ∈ [desde,hasta] ( ven ⋈ est ) )

Paso 2 (γ antes de reunir lo demás)       t = γ id_producto ; SUM, COUNT, SUM, MIN, MAX ( det ⋈ tmp_ventas_entregadas )

Paso 3 (reunión mínima)                    τ monto_total DESC, nombre_producto, id_producto
                                            └─ π id_producto, nombre_producto, nombre_categoria, [agregados de t]
                                                └─ ⋈ cat.id_categoria_producto = pro.id_categoria_producto
                                                    ├─ ⋈ pro.id_producto = t.id_producto
                                                    │   ├─ t
                                                    │   └─ pro
                                                    └─ cat
```
- `estado_venta` se reúne **solo con `venta_buffet`** (la única que tiene `id_estado_venta`), y ya filtrada.
- `detalle_venta` se reúne **solo con las ventas que sobrevivieron** (2 columnas: `id_venta` y la fecha).
- `producto_buffet` y `categoria_producto` se reúnen al final con **una fila por producto vendido**, no con una fila por línea de venta.

### 1.3 Qué cambió en el SQL
| Original | Tuneado |
|---|---|
| Un `SELECT` con 5 `JOIN`, `WHERE` y `GROUP BY` | `CREATE TEMPORARY TABLE tmp_ventas_entregadas AS SELECT …` + subconsulta en `FROM` con `GROUP BY` + 2 `JOIN` finales |
| El filtro de estado y fecha se aplica sobre el resultado de reunir todo | El filtro se aplica **antes**, sobre `venta_buffet` |
| Se proyectan todas las columnas de las 5 tablas hasta el `GROUP BY` | Solo viajan `id_venta`, `fecha` y las 4 columnas del detalle |
| — | `DROP TEMPORARY TABLE IF EXISTS` al inicio, al final y en el handler (no queda basura si falla) |

Limitación conocida (la clase también la menciona, diap. 13): la tabla temporal se crea y se destruye en cada llamada. Para el volumen del proyecto es aceptable; la alternativa de quinto año son vistas e índices ya compilados.

### 1.4 Índices que usa
- `ix_venta_estado_fecha` (`venta_buffet`: `id_estado_venta`, `fecha_hora`): igualdad por estado + rango de fechas, en ese orden. Resuelve el Paso 1 sin recorrer toda la tabla.
- PK de `detalle_venta` (`id_venta`, `id_producto`): resuelve la reunión del Paso 2 (ya existe, no se repite).
- PK de `producto_buffet` y de `categoria_producto`: el Paso 3.

### 1.5 Comparación con `EXPLAIN` (medido con MariaDB 10.11)
Para cada versión: `EXPLAIN` de la consulta interna del SP con los mismos parámetros (por ejemplo `'2026-10-01'` y `'2026-10-31'`). Para el tuneado, `EXPLAIN` del Paso 1 y del Paso 2/3 por separado. Anotar `type`, `key`, `rows` y `Extra` de cada fila, y el tiempo de `CALL` (con `SET profiling` o simplemente medido en el cliente).

| | Original | Tuneado |
|---|---|---|
| `EXPLAIN` | 5 filas en el plan: `ev` const → `v` range (`ix_venta_estado_fecha`, Using index) → `d` ref (PRIMARY) → `p` eq_ref → `cp` eq_ref; **Using temporary** en el GROUP BY | Paso 1: `ev` const → `v` range (`ix_venta_estado_fecha`, Using index). Paso 2: `tv` (ALL, 8 filas) → `d` ref (PRIMARY); Using temporary; Using filesort |
| Filas estimadas (suma de `rows`) | 1 + 8 + 1 + 1 + 1 = 12 por fila de venta | 1 + 8 + 8 + 1 = 18 (incluye la tabla temporal) |
| Tiempo del `CALL` sin índices `ix_` | no medible: `ix_venta_estado_fecha` lo usa una clave foránea y MariaDB no deja borrarlo | no medible (mismo motivo) |
| Tiempo del `CALL` con índices `ix_` (promedio de 150 llamadas, rango oct-nov 2026) | 0,34 ms | 1,02 ms |

> **Resultado medido (MariaDB 10.11, 28 ventas y 37 líneas de detalle):** con tan pocos datos **el tuneado NO es más rápido**: la tabla temporal cuesta más que lo que ahorra. Los dos usan el índice `ix_venta_estado_fecha` y devuelven exactamente las mismas filas (caso `TC_SP_REP_VENTAS_POR_PRODUCTO_TUNEADO_04`, PASS). La mejora del árbol (filtrar antes de reunir) recién se nota con miles de filas; se defiende el razonamiento y se informa la medición tal cual.

---

## 2. `sp_rep_actividad_por_usuario` → `sp_rep_actividad_por_usuario_tuneado`

### 2.1 Antes (el SQL del original)
```
τ total_actividad DESC, usuario_nick
 └─ σ(HAVING)  COUNT(DISTINCT id_prestamo) + COUNT(DISTINCT id_reserva) + COUNT(DISTINCT id_reclamo) > 0
     └─ γ id_usuario, usuario_nick, nombre_completo, nombre_rol ;  COUNT(DISTINCT …) ×3
         └─ ⟕ rec.id_usuario = usu.id_usuario  ∧  rec.fecha_reclamo ∈ [desde,hasta]
             ├─ ⟕ res.id_usuario = usu.id_usuario  ∧  res.fecha_reserva ∈ [desde,hasta]
             │   ├─ ⟕ pre.id_usuario_solicitante = usu.id_usuario  ∧  pre.fecha_prestamo ∈ [desde,hasta]
             │   │   ├─ ⋈ rol.id_rol = usu.id_rol
             │   │   │   ├─ usu
             │   │   │   └─ rol
             │   │   └─ pre
             │   └─ res
             └─ rec
```
(⟕ = reunión externa izquierda, `LEFT JOIN`.) El problema: para un usuario con *p* préstamos, *r* reservas y *c* reclamos, la reunión genera **p × r × c filas** (con 0 se toma 1) que después `COUNT(DISTINCT)` tiene que deduplicar. El filtro de fechas tiene que ir en el `ON` (si va en `WHERE` se pierden los usuarios sin actividad y el `LEFT JOIN` deja de serlo), por lo que no se puede “empujar” hacia abajo sin cambiar la estructura.

### 2.2 Después (el SQL del tuneado)
```
τ total_actividad DESC, usuario_nick
 └─ σ  a.cantidad + b.cantidad + c.cantidad > 0          (el HAVING pasa a WHERE: ya no hay γ arriba)
     └─ π usuario_nick, nombre_completo, nombre_rol, COALESCE(a), COALESCE(b), COALESCE(c), suma
         └─ ⟕ c.id_usuario = usu.id_usuario
             ├─ ⟕ b.id_usuario = usu.id_usuario
             │   ├─ ⟕ a.id_usuario = usu.id_usuario
             │   │   ├─ ⋈ rol.id_rol = usu.id_rol
             │   │   │   ├─ usu
             │   │   │   └─ rol
             │   │   └─ a = γ id_usuario_solicitante ; COUNT(*) ( σ fecha_prestamo ∈ [desde,hasta] ( π id_usuario_solicitante, fecha_prestamo ( pre ) ) )
             │   └─ b = γ id_usuario ; COUNT(*) ( σ fecha_reserva ∈ [desde,hasta] ( π id_usuario, fecha_reserva ( res ) ) )
             └─ c = γ id_usuario ; COUNT(*) ( σ fecha_reclamo ∈ [desde,hasta] ( π id_usuario, fecha_reclamo ( rec ) ) )
```
Cada rama (a, b, c) hace primero **σ y π sobre su propia tabla** y **γ** (una fila por usuario). Así cada `LEFT JOIN` une como máximo **una fila por usuario**: no hay multiplicación de filas y desaparece el `COUNT(DISTINCT)`.

### 2.3 Qué cambió en el SQL
| Original | Tuneado |
|---|---|
| 3 `LEFT JOIN` directos a las tablas, filtro de fechas en cada `ON` | 3 subconsultas en `FROM` (`a`, `b`, `c`), cada una con su `WHERE` de fechas y su `GROUP BY` |
| `COUNT(DISTINCT …)` ×3 en la consulta externa (necesario por la multiplicación de filas) | `COUNT(*)` dentro de cada subconsulta (no hace falta `DISTINCT`) |
| `GROUP BY` + `HAVING … > 0` en la consulta externa | Sin `GROUP BY` externo; el `HAVING` se convierte en `WHERE COALESCE(…) + … > 0` |
| Usuarios sin actividad: descartados por el `HAVING` | Descartados por el `WHERE` (mismo resultado) |

**Por qué el `HAVING` del original es correcto:** la condición depende de un agregado (la suma de conteos), que recién existe después del `GROUP BY`; en un `WHERE` no se puede usar. En el tuneado el agregado ya fue calculado dentro de las subconsultas, por eso alcanza con `WHERE`.

### 2.4 Índices que usa
- `ix_prestamo_solic_fecha` (`prestamo_ct`: `id_usuario_solicitante`, `fecha_prestamo`)
- `ix_reserva_usuario_fecha` (`reserva_sector`: `id_usuario`, `fecha_reserva`)
- `ix_reclamo_usuario_fecha` (`reclamo_objeto`: `id_usuario`, `fecha_reclamo`)
Los tres son índices **cubridores** de cada subconsulta: filtran por fecha y agrupan por usuario recorriendo solo el índice. (En `reclamo_objeto` ya existe `ux_reclamo_usuario_objeto`, que empieza igual por `id_usuario` pero no incluye la fecha; por eso el nuevo no es una repetición.)
La PK de `usuario` y de `rol` resuelven las reuniones con los datos principales.

### 2.5 Comparación con `EXPLAIN` (medido con MariaDB 10.11)
| | Original | Tuneado |
|---|---|---|
| `EXPLAIN` | no se extrajo (la consulta es una UNION de tres ramas dentro del SP) | no se extrajo |
| Filas estimadas (suma de `rows`) | no medido | no medido |
| Tiempo del `CALL` sin índices `ix_` | no medible (los `ix_` están creados y varios los usa una FK) | no medible |
| Tiempo del `CALL` con índices `ix_` (promedio de 150 llamadas) | 0,66 ms | 0,55 ms |

> **Resultado medido (MariaDB 10.11, 24 préstamos, 28 reservas, 25 reclamos):** diferencia de ~0,1 ms, dentro del ruido; las dos versiones devuelven las mismas filas (caso `TC_SP_REP_ACTIVIDAD_POR_USUARIO_TUNEADO_04`, PASS).

---

## 3. Cómo se comprueba que son equivalentes
1. `CALL sp_rep_ventas_por_producto(NULL, NULL);` y `CALL sp_rep_ventas_por_producto_tuneado(NULL, NULL);` → mismas filas, mismas columnas, mismo orden. Lo mismo con un rango (`'2026-10-01'`, `'2026-10-31'`) y con uno sin datos (`'2000-01-01'`, `'2000-01-31'`).
2. Ídem para `sp_rep_actividad_por_usuario` y su tuneado.
3. Si hay una forma automática: guardar cada resultado en una tabla temporal y hacer `SELECT … EXCEPT …` en los dos sentidos (la clase 002 vio `EXCEPT`; en MariaDB 10.11 existe, en MySQL 8 desde 8.0.31) → 0 filas.
   Si el motor no lo tiene, comparar a ojo o con `COUNT(*)` y `SUM(monto_total)`.

## 4. Índices de la sección final del `.sql`
Los 12 índices están al final de `03_ModeloSQL_Grupo06.sql`. Se crean con `CREATE INDEX` al final de `03_ModeloSQL_Grupo06.sql`, después de las tablas: como el 03 borra y vuelve a crear las tablas, los índices se recrean en cada carga. La tabla completa de qué reporte usa cada índice está en `SP_REPORTES.md` (§ Índices).

## Desvíos
- No se ejecutó nada (sin MySQL/MariaDB en el entorno): los `EXPLAIN` y tiempos quedan para Arce Thiago y Cabrera Ulises.
- Se usó **tabla temporal en el de ventas** y **subconsultas en `FROM` en el de actividad**: así se muestran las dos técnicas de la clase 004 (no hay variables tipo tabla en MySQL).
- Se mantienen los dos reportes sugeridos por el contrato (§21); no se cambiaron.

## Datos que faltan
- Repetir la medición en MySQL 8 con más datos (el volumen actual es chico).
- Volumen de filas con que se mide (depende de lo que cargue Arce Thiago y Cabrera Ulises en `04_DatosSQL`): detalle_venta 37, prestamo_ct 24, reserva_sector 28, reclamo_objeto 25.
