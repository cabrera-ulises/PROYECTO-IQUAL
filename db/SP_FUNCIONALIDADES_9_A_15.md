# Fichas de los Stored Procedures 9 a 15 (para la defensa)

**Proyecto:** PROYECTO IQUAL® (SGE) · **Archivo:** `05c_Backend_funcionalidades_9_a_15.sql` · **Motor:** MySQL 8 / MariaDB 10.11 · **Pruebas:** `06_PruebasSQL_claude4.xlsx` (4 casos por SP)

## Lo que tienen en común los siete
- **Estilo de la clase 006:** `DELIMITER //`, `DROP PROCEDURE IF EXISTS` (se pueden ejecutar varias veces), parámetros `p_...` y un `DECLARE EXIT HANDLER FOR SQLEXCEPTION` con `GET DIAGNOSTICS CONDITION 1` que devuelve una fila `estado = 'ERROR'`, `codigo_sql`, `descripcion_error`.
- **Reglas de negocio:** se cortan con `SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '...'` (el equivalente al `RAISERROR` de la clase 003). Las atrapa el mismo handler, así que el SP nunca "explota": siempre devuelve una fila.
- **Mismos mensajes que la app:** los textos salen de `mainwindow.cpp` (ver el cuadro de cada ficha).
- **Éxito:** fila con `estado = 'OK'` y lo que se creó (el id).
- **Auditoría:** al terminar bien llaman a `sp_registrar_log(..., 'Exitoso', ...)` y, si algo falla, el handler llama a `sp_registrar_log(..., 'Fallido', ...)`. Así `log_auditoria` se llena sola al ejecutar los SP, sin cargarla a mano (consigna punto 4c).
- **Se identifica al usuario por `usuario_nick`** y los catálogos por nombre, como hace la app.
- **Solo SQL visto en clase:** `JOIN`, subconsultas escalares y `EXISTS`, `COALESCE`, `IF/ELSEIF`, variables `DECLARE`, `INSERT/UPDATE/DELETE`, `NOW()`/`CURDATE()`. No usan cursores, triggers, SQL dinámico ni funciones de ventana.

---

## 9. `sp_resolver_reserva_sector(p_id_reserva, p_nick_autorizador, p_accion)`
**Qué hace:** aprueba, rechaza o cancela una reserva de sector.
| Acción | Quién puede | Condición | Resultado |
|---|---|---|---|
| `Aprobar` / `Rechazar` | Preceptor | la reserva está `Pendiente` | estado `Aprobada` / `Rechazada` y guarda el autorizador |
| `Cancelar` | Profesor o Preceptor (el dueño o cualquier Preceptor) | la reserva está `Pendiente` o `Aprobada` | estado `Cancelada` |

**Mensajes (de la app):** «Solo se pueden aprobar o rechazar reservas pendientes.», «Solo podés cancelar tus propias reservas.», «Esa reserva ya está rechazada o cancelada.», «Esta acción es solo para estos roles: …». Nuevos: «Acción inválida: usá Aprobar, Rechazar o Cancelar.», «Esa reserva no existe.».
**Tablas:** `reserva_sector`, `estado_reserva`, `usuario`, `rol`. **Log:** evento `Reserva de sector`, entidad `reserva_sector`.
**Devuelve:** `estado, id_reserva, estado_reserva`.
**Ejemplo:** `CALL sp_resolver_reserva_sector(1, 'preceptor1', 'Aprobar');`

## 10. `sp_reportar_higiene(p_nick, p_sector, p_tipo, p_observaciones)`
**Qué hace:** da de alta un reporte de higiene con la fecha y hora actual y estado `Pendiente`. Puede reportar cualquier rol.
**Reglas:** observación no vacía («Contanos qué pasa para poder resolverlo.»), de hasta 200 caracteres, sector y tipo existentes.
**Tablas:** `reporte_higiene`, `sector`, `tipo_reporte`, `estado_reporte`, `usuario`. **Log:** `Reporte de higiene`, entidad `reporte_higiene`.
**Devuelve:** `estado, id_reporte`.
**Ejemplo:** `CALL sp_reportar_higiene('alumno1', 'Baño planta alta', 'Rotura', 'La canilla pierde agua');`

## 11. `sp_resolver_reporte_higiene(p_id_reporte, p_nick_resolutor)`
**Qué hace:** marca el reporte como `Resuelto` y guarda fecha y hora de resolución y quién lo resolvió (alimenta el «último mantenimiento» de cada sector).
**Reglas:** solo Profesor, Preceptor o Maestranza; el reporte debe existir y estar `Pendiente` («Ese reporte ya está resuelto.»).
**Tablas:** `reporte_higiene`, `estado_reporte`, `usuario`, `rol`. **Log:** `Resolución de reporte`, entidad `reporte_higiene`.
**Devuelve:** `estado, id_reporte`.
**Ejemplo:** `CALL sp_resolver_reporte_higiene(1, 'maestranza1');`

## 12. `sp_comprar_producto(p_nick, p_id_producto, p_cantidad)`
**Qué hace:** reserva un producto del buffet: crea la venta en estado `Reservada`, su detalle (con el precio del momento) y descuenta el stock. El total no se guarda: se devuelve calculado (`cantidad * precio`).
**Reglas:** cantidad 1 o más; producto existente; no se puede reservar un producto propio («No podés reservar tus propios productos.»); stock suficiente («No hay stock suficiente: quedan N unidades.»).
**Transacción:** los tres pasos (venta, detalle, stock) van dentro de `START TRANSACTION … COMMIT`; si algo falla, el handler hace `ROLLBACK` y no queda nada a medias (igual que la app con `db.transaction()`).
**Tablas:** `venta_buffet`, `detalle_venta`, `producto_buffet`, `estado_venta`, `usuario`. **Log:** `Reserva de producto`, entidad `venta_buffet`.
**Devuelve:** `estado, id_venta, total`.
**Ejemplo:** `CALL sp_comprar_producto('alumno2', 1, 2);`

## 13. `sp_donar_grupo(p_nick, p_id_grupo, p_monto)`
**Qué hace:** registra una donación a un grupo del buffet con la fecha y hora actual. Puede donar cualquier rol. El «recaudado» del grupo no se guarda: se calcula en los reportes.
**Reglas:** monto entero mayor a 0 («Escribí un monto en pesos, mayor a 0 y sin centavos.»); el grupo debe existir.
**Tablas:** `donacion_buffet`, `grupo_buffet`, `usuario`. **Log:** `Donación`, entidad `donacion_buffet`.
**Devuelve:** `estado, id_donacion, monto`.
**Ejemplo:** `CALL sp_donar_grupo('alumno1', 1, 500);`

## 14. `sp_inscribir_ed_fisica(p_nick, p_id_oferta)`
**Qué hace:** inscribe a un alumno a una oferta de Educación Física.
**Reglas, en este orden:** el usuario es Alumno; la oferta existe; el alumno no tiene otra inscripción («Ya estás inscripto. Cancelá tu inscripción antes de elegir otra.»); hay cupo (`COUNT` de inscriptos menor al `cupo_maximo`: «Esa opción ya no tiene cupo.»); no se superpone con el horario de su curso. La superposición usa `horario_escolar` y `horario_dia` del curso en ese día con la condición `hora_inicio < fin_franja AND hora_fin > inicio_franja` y avisa la materia: «Esa opción se superpone con <materia> en tu horario.».
**Tablas:** `inscripcion_ed_fisica`, `oferta_deporte`, `franja_horaria`, `horario_dia`, `horario_escolar`, `materia`, `usuario`, `rol`. **Log:** `Inscripción a Ed. Física`, entidad `inscripcion_ed_fisica`.
**Devuelve:** `estado, id_inscripcion, id_oferta`.
**Ejemplo:** `CALL sp_inscribir_ed_fisica('alumno1', 1);`

## 15. `sp_cancelar_inscripcion_ed_fisica(p_nick)`
**Qué hace:** borra la inscripción del alumno (queda libre el cupo).
**Reglas:** el usuario es Alumno y tiene una inscripción («No tenés ninguna inscripción para cancelar.»).
**Tablas:** `inscripcion_ed_fisica`, `usuario`, `rol`. **Log:** `Inscripción a Ed. Física` con la descripción «Inscripción a la oferta N cancelada», entidad `inscripcion_ed_fisica`.
**Devuelve:** `estado, id_oferta` (la oferta que se canceló).
**Ejemplo:** `CALL sp_cancelar_inscripcion_ed_fisica('alumno2');`

---

## Qué decir si preguntan en la defensa
- **¿Por qué usan `SIGNAL`?** Para cortar el SP cuando se rompe una regla de negocio (cupo lleno, stock insuficiente) con un mensaje claro; es el `RAISERROR` de SQL Server (clase 003) en MySQL. El mismo handler que atrapa los errores de SQL atrapa estos.
- **¿Cómo se llenan los logs?** Solos: cada SP llama a `sp_registrar_log`, tanto si sale bien como si falla. La tabla `log_auditoria` no se carga a mano.
- **¿Qué pasa si se corta a la mitad?** `sp_comprar_producto`, que escribe en tres tablas, usa transacción y `ROLLBACK`; los demás escriben en una sola tabla, así que o se hace o no se hace.
- **Limitación conocida:** el control de cupo y de stock se hace leyendo y después escribiendo; con varios usuarios al mismo tiempo podrían pisarse. Para el uso de una escuela con una sola base alcanza; se menciona como limitación.
