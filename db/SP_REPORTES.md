# SP_REPORTES — fichas de los reportes (defensa técnica)

**Proyecto IQUAL® (SGE)** · Autor: Arce Thiago y Cabrera Ulises · 14/11/2026 · Código: `05b_Backend_reportes.sql` · Pruebas: `06_PruebasSQL_claude3.xlsx` · Tuning: `TUNING_REPORTES.md`

## Reglas comunes a todos los reportes

- **Fechas:** `p_desde` y `p_hasta` son `DATE`. `NULL` = sin límite de ese lado. El rango es **inclusivo** en las dos puntas (en columnas `DATETIME` se compara contra el día siguiente, exclusivo, para que «hasta» incluya todo el día).
- **Rango invertido** (`desde > hasta`): fila `estado='ERROR'`, `codigo_sql=1644`, `descripcion_error='Rango de fechas invalido: desde es mayor que hasta'` (regla de negocio con `SIGNAL`, la atrapa el handler).
- **Cualquier otro error SQL:** el mismo handler (`EXIT HANDLER FOR SQLEXCEPTION` + `GET DIAGNOSTICS`, estilo clase 006) devuelve `estado`, `codigo_sql`, `descripcion_error`.
- **Éxito:** devuelve directamente la tabla del reporte (sin fila `estado='OK'`, para poder compararla con un `SELECT` en las pruebas). Sin datos en el rango: 0 filas, no es error.
- Todos usan **JOIN + GROUP BY + manejo de fechas** (lo exige la consigna). Solo `JOIN`, `GROUP BY`, `HAVING`, `COUNT/SUM/AVG/MIN/MAX`, `BETWEEN`-equivalentes, `COALESCE`, `DATEDIFF/DATE/CURDATE`, subconsultas, `UNION ALL` y tablas temporales: lo visto en clase.

## Fichas

### 1. `sp_rep_prestamos_por_carro(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Qué carros de computadoras se usan más y cuántos préstamos siguen sin devolverse?
- **Tablas reunidas:** prestamo_ct, recursos_ct, carro
- **Columnas:** nombre_carro, total_prestamos, equipos_distintos, sin_devolver, primer_prestamo, ultimo_prestamo, dias_entre_extremos
- **Nota:** Solo cuenta recursos que están en un carro (los tableros de dibujo tienen `id_carro` NULL y no entran). `sin_devolver` = `COUNT(*) - COUNT(hora_devolucion)` (los NULL no se cuentan).
- **Ejemplo:** `CALL sp_rep_prestamos_por_carro('2026-10-22', '2026-10-23');`

### 2. `sp_rep_objetos_por_categoria_estado(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Cuántos objetos perdidos hay de cada categoría en cada estado y hace cuánto está el más antiguo?
- **Tablas reunidas:** objeto_perdido, categoria_objeto, estado_objeto
- **Columnas:** nombre_categoria, nombre_estado, cantidad_objetos, primer_registro, ultimo_registro, dias_desde_el_mas_antiguo
- **Nota:** `dias_desde_el_mas_antiguo` depende del día en que se ejecuta (usa `CURDATE()`).
- **Ejemplo:** `CALL sp_rep_objetos_por_categoria_estado('2026-10-01', '2026-10-31');`

### 3. `sp_rep_higiene_por_sector(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿En qué sectores se acumulan los problemas de higiene y cuánto tardan en resolverse?
- **Tablas reunidas:** reporte_higiene, sector, tipo_reporte
- **Columnas:** nombre_sector, nombre_tipo, total_reportes, resueltos, pendientes, primer_reporte, ultimo_reporte, dias_promedio_resolucion
- **Nota:** `resueltos` = reportes con fecha de resolución; `dias_promedio_resolucion` es NULL si ninguno se resolvió (el promedio ignora los NULL).
- **Ejemplo:** `CALL sp_rep_higiene_por_sector('2026-10-01', '2026-10-31');`

### 4. `sp_rep_ocupacion_sectores(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Qué sectores se reservan más, cuántas horas y cuántas reservas se cancelaron o rechazaron?
- **Tablas reunidas:** reserva_sector, sector, tipo_sector, estado_reserva
- **Columnas:** nombre_sector, nombre_tipo, nombre_estado, cantidad_reservas, dias_con_reservas, horas_reservadas, primera_fecha, ultima_fecha
- **Nota:** Las horas se guardan como texto `HH:MM`: `TIME_TO_SEC` las convierte a segundos para restar fin − inicio.
- **Ejemplo:** `CALL sp_rep_ocupacion_sectores(CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 DAY));`

### 5. `sp_rep_ventas_por_producto(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Qué productos del buffet se venden más, en unidades y en pesos (solo ventas entregadas)?
- **Tablas reunidas:** detalle_venta, venta_buffet, estado_venta, producto_buffet, categoria_producto
- **Columnas:** id_producto, nombre_producto, nombre_categoria, unidades_vendidas, cantidad_ventas, monto_total, primera_venta, ultima_venta
- **Nota:** Solo ventas en estado **Entregada** (las Reservadas y Canceladas no son ventas concretadas). Es la versión sin tuning; ver `sp_rep_ventas_por_producto_tuneado`.
- **Ejemplo:** `CALL sp_rep_ventas_por_producto('2026-10-01', '2026-10-31');`

### 6. `sp_rep_recaudado_por_grupo(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Cuánto juntó cada grupo del buffet en el período y qué porcentaje de su meta es?
- **Tablas reunidas:** grupo_buffet, donacion_buffet, detalle_venta, venta_buffet, estado_venta, producto_buffet
- **Columnas:** nombre_grupo, meta_monto, donaciones, ventas_entregadas, recaudado, porcentaje_meta, cantidad_movimientos, ultimo_movimiento
- **Nota:** Regla vigente del CONTEXTO: recaudado = donaciones + ventas **Entregadas** de los productos del grupo. Solo aparecen grupos con movimientos en el rango.
- **Ejemplo:** `CALL sp_rep_recaudado_por_grupo('2026-10-01', '2026-10-31');`

### 7. `sp_rep_inscriptos_por_deporte(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Cuántos alumnos se anotaron en cada deporte (oferta día + franja) y cuántos cupos quedan?
- **Tablas reunidas:** inscripcion_ed_fisica, oferta_deporte, deporte, dia_semana, franja_horaria
- **Columnas:** nombre_deporte, nombre_dia, hora_inicio, hora_fin, cupo_maximo, inscriptos, cupos_libres, primera_inscripcion, ultima_inscripcion
- **Nota:** `cupos_libres` compara los inscriptos **del rango** con el cupo: para el cupo real usar (NULL, NULL).
- **Ejemplo:** `CALL sp_rep_inscriptos_por_deporte('2026-10-01', '2026-10-31');`

### 8. `sp_rep_actividad_por_usuario(p_desde, p_hasta)`

- **Pregunta de negocio:** ¿Quiénes usan más el sistema y en qué (préstamos, reservas, reclamos)?
- **Tablas reunidas:** usuario, rol, prestamo_ct, reserva_sector, reclamo_objeto
- **Columnas:** usuario_nick, nombre_completo, nombre_rol, prestamos, reservas, reclamos, total_actividad
- **Nota:** **HAVING justificado:** la condición `total > 0` es sobre agregados (suma de `COUNT DISTINCT`), que no existen en el `WHERE`; deja afuera a los usuarios sin actividad. Los `COUNT(DISTINCT …)` son necesarios porque los 3 `LEFT JOIN` multiplican filas (eso es lo que corrige el tuneado). Préstamos = como solicitante.
- **Ejemplo:** `CALL sp_rep_actividad_por_usuario('2026-10-01', '2026-10-31');`

### 9. `sp_rep_auditoria(p_desde, p_hasta, p_evento, p_nick, p_resultado)`
- **Pregunta de negocio:** ¿Qué pasó en el sistema, quién lo hizo y con qué resultado en un período?
- **Parámetros:** rango de fechas **obligatorio** (si `p_desde` o `p_hasta` es NULL: `ERROR` 1644 «El rango de fechas es obligatorio…»; rango invertido: `ERROR` 1644). `p_evento` (nombre del tipo de evento, p. ej. `'Inicio de sesión'`), `p_nick` y `p_resultado` (`'Exitoso'`/`'Fallido'`) son **opcionales**: `NULL` o `''` = sin filtro; un valor inexistente devuelve 0 filas.
- **Tablas reunidas:** log_auditoria, tipo_log, entidad_log, resultado_log y `LEFT JOIN` usuario (hay eventos sin usuario: se muestran como `(sin usuario)`).
- **Columnas:** fecha, nombre_evento, nombre_entidad, nombre_resultado, nick, cantidad_eventos, primera_hora, ultima_hora, ips_distintas
- **Nota:** es un reporte **agrupado** (por día, evento, entidad, resultado y usuario), como pide la consigna para todos los reportes; no lista cada log por separado.
- **Ejemplo:** `CALL sp_rep_auditoria('2026-10-01', '2026-10-31', 'Inicio de sesión', NULL, 'Fallido');`

### 10. `sp_rep_ventas_por_producto_tuneado(p_desde, p_hasta)`
- **Pregunta:** la misma que la 5, con menos trabajo.
- **Qué cambia:** tabla temporal con las ventas Entregadas del rango, pre-agregado por producto y reunión final mínima. Mismas columnas, filas y orden.
- **Ejemplo:** `CALL sp_rep_ventas_por_producto_tuneado('2026-10-01', '2026-10-31');`
- **Detalle del árbol antes/después:** `TUNING_REPORTES.md` §1.

### 11. `sp_rep_actividad_por_usuario_tuneado(p_desde, p_hasta)`
- **Pregunta:** la misma que la 8.
- **Qué cambia:** 3 subconsultas (una por tipo de actividad) ya filtradas y agrupadas por usuario; desaparecen el `COUNT(DISTINCT)` y el `GROUP BY` externo; el `HAVING` pasa a `WHERE`. Mismas columnas, filas y orden.
- **Ejemplo:** `CALL sp_rep_actividad_por_usuario_tuneado('2026-10-01', '2026-10-31');`
- **Detalle:** `TUNING_REPORTES.md` §2.

## Índices (sección final del `.sql`)

No se repiten los de las claves (PK, `UNIQUE`, FK). Se crean con `CREATE INDEX` al final de `03_ModeloSQL_Grupo06.sql`, después de las tablas: como el 03 borra y vuelve a crear las tablas, los índices se recrean en cada carga.

| Índice | Tabla (columnas) | Para qué |
|---|---|---|
| `ix_prestamo_fecha_recurso` | `prestamo_ct` (fecha_prestamo, id_recurso) | rango de fechas + reunion con recurso (sp_rep_prestamos_por_carro) |
| `ix_prestamo_solic_fecha` | `prestamo_ct` (id_usuario_solicitante, fecha_prestamo) | conteo por usuario y fecha (actividad_por_usuario y su tuneado) |
| `ix_reserva_fecha_sector` | `reserva_sector` (fecha_reserva, id_sector) | rango de fechas + sector (sp_rep_ocupacion_sectores) |
| `ix_reserva_usuario_fecha` | `reserva_sector` (id_usuario, fecha_reserva) | conteo por usuario y fecha (actividad_por_usuario y su tuneado) |
| `ix_reclamo_usuario_fecha` | `reclamo_objeto` (id_usuario, fecha_reclamo) | conteo por usuario y fecha (actividad_por_usuario y su tuneado) |
| `ix_objeto_fecha_cat_estado` | `objeto_perdido` (fecha_registro, id_categoria_objeto, id_estado_objeto) | indice cubridor de sp_rep_objetos_por_categoria_estado |
| `ix_higiene_fecha_sector` | `reporte_higiene` (fecha_hora, id_sector) | rango de fechas (sp_rep_higiene_por_sector) |
| `ix_venta_estado_fecha` | `venta_buffet` (id_estado_venta, fecha_hora) | igualdad por estado + rango de fechas (ventas_por_producto y su tuneado, recaudado_por_grupo) |
| `ix_donacion_fecha_grupo` | `donacion_buffet` (fecha_hora, id_grupo) | rango de fechas (sp_rep_recaudado_por_grupo) |
| `ix_inscripcion_fecha_oferta` | `inscripcion_ed_fisica` (fecha_inscripcion, id_oferta) | rango de fechas (sp_rep_inscriptos_por_deporte) |
| `ix_log_fecha_tipo` | `log_auditoria` (fecha_hora, id_tipo_log) | rango de fechas obligatorio (sp_rep_auditoria) |
| `ix_log_usuario_fecha` | `log_auditoria` (id_usuario, fecha_hora) | filtro por usuario + fecha (sp_rep_auditoria) |

## Preguntas probables de la defensa
- **¿Por qué el rango es inclusivo?** Porque el usuario piensa en días: «hasta el 31» incluye todo el 31. En columnas `DATETIME` se logra comparando contra el día siguiente (`< hasta + 1 día`).
- **¿Por qué `NULL` = sin límite?** Para poder pedir «todo» o «desde tal fecha» con el mismo SP, sin inventar fechas extremas.
- **¿Por qué los reportes devuelven la tabla y no `estado='OK'`?** Para poder compararlos directamente con un `SELECT` (caso 04 de las pruebas); el error sí viene como fila `estado='ERROR'`, igual que en la clase 006.
- **¿Qué es el HAVING?** Un filtro que se aplica **después** del `GROUP BY`, sobre agregados; el `WHERE` filtra antes y no puede usar `COUNT`/`SUM`.

## Desvíos
- Nada se ejecutó (sin MySQL/MariaDB en el entorno): todo revisado a mano contra `03_ModeloSQL_Grupo06.sql y 04_DatosSQL_Grupo06.sql`.
- La auditoría devuelve un resumen agrupado, no el detalle de cada log.

## Datos que faltan
- `[COMPLETAR: cupo_maximo de la oferta Handball/Lunes]` para el caso `TC_SP_REP_INSCRIPTOS_POR_DEPORTE_01`.
- Resultados de `EXPLAIN` (en `TUNING_REPORTES.md`).
