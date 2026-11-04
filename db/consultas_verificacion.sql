-- PROYECTO IQUAL (SGE) - consultas de verificación (CONTEXTO_IQUAL v2.3)
-- Se prueban sobre iqual_sqlite.sql. Funcionan igual en MySQL 8 y SQL Server 2005,
-- salvo LIMIT (en SQL Server se usa TOP, ver la consulta 9).
-- Valores de la demo: fechas 'yyyy-MM-dd' y horas 'HH:mm' (D14). En SQL Server las fechas se escriben 'yyyymmdd'.

-- 1A. Solape de reservas: se quiere reservar Biblioteca el 2026-11-05 de 10:30 a 11:30.
--     Debe devolver 1 fila (la reserva Pendiente de 10:00 a 11:00): HAY conflicto y se nombra quién la ocupa.
SELECT u.nombre_completo AS ocupa, r.hora_inicio, r.hora_fin, e.nombre_estado
FROM reserva_sector r
JOIN sector s ON s.id_sector = r.id_sector
JOIN usuario u ON u.id_usuario = r.id_usuario
JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE s.nombre_sector = 'Biblioteca'
  AND r.fecha_reserva = '2026-11-05'
  AND e.nombre_estado IN ('Pendiente', 'Aprobada')
  AND r.hora_inicio < '11:30'
  AND r.hora_fin > '10:30';

-- 1B. Misma consulta para 11:00 a 12:00. Debe devolver 0 filas: NO hay conflicto
--     (la de 10:00 a 11:00 termina justo cuando empieza la nueva y la de 11:30 está Cancelada).
SELECT u.nombre_completo AS ocupa, r.hora_inicio, r.hora_fin, e.nombre_estado
FROM reserva_sector r
JOIN sector s ON s.id_sector = r.id_sector
JOIN usuario u ON u.id_usuario = r.id_usuario
JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE s.nombre_sector = 'Biblioteca'
  AND r.fecha_reserva = '2026-11-05'
  AND e.nombre_estado IN ('Pendiente', 'Aprobada')
  AND r.hora_inicio < '12:00'
  AND r.hora_fin > '11:00';

-- 2A. Total de cada venta (dato derivado: no se guarda, se calcula).
SELECT v.id_venta, v.fecha_hora, es.nombre_estado, SUM(d.cantidad * d.precio_unitario) AS total_venta
FROM venta_buffet v
JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
JOIN detalle_venta d ON d.id_venta = v.id_venta
GROUP BY v.id_venta, v.fecha_hora, es.nombre_estado
ORDER BY v.id_venta;

-- 2B. Recaudado de un grupo (derivado) = donaciones + ventas no canceladas de sus productos, y % de la meta.
SELECT g.nombre_grupo,
       g.meta_monto,
       COALESCE((SELECT SUM(dn.monto) FROM donacion_buffet dn WHERE dn.id_grupo = g.id_grupo), 0) AS donaciones,
       COALESCE((SELECT SUM(d.cantidad * d.precio_unitario)
                 FROM detalle_venta d
                 JOIN producto_buffet p ON p.id_producto = d.id_producto
                 JOIN venta_buffet v ON v.id_venta = d.id_venta
                 JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
                 WHERE p.id_grupo = g.id_grupo AND es.nombre_estado <> 'Cancelada'), 0) AS ventas,
       COALESCE((SELECT SUM(dn.monto) FROM donacion_buffet dn WHERE dn.id_grupo = g.id_grupo), 0)
       + COALESCE((SELECT SUM(d.cantidad * d.precio_unitario)
                   FROM detalle_venta d
                   JOIN producto_buffet p ON p.id_producto = d.id_producto
                   JOIN venta_buffet v ON v.id_venta = d.id_venta
                   JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
                   WHERE p.id_grupo = g.id_grupo AND es.nombre_estado <> 'Cancelada'), 0) AS recaudado
FROM grupo_buffet g;

-- 3A. Ed. Física del alumno1: ofertas que SÍ se superponen con el horario de su curso (4 1 Computación).
--     Ejemplo esperado: Vóley martes 14:00-16:00 se superpone con Matemática y Bases de Datos.
SELECT dp.nombre_deporte, ds.nombre_dia, f.hora_inicio AS franja_inicio, f.hora_fin AS franja_fin,
       m.nombre_materia AS se_superpone_con, h.hora_inicio AS clase_inicio, h.hora_fin AS clase_fin
FROM usuario a
JOIN horario_escolar h ON h.id_curso = a.id_curso
JOIN horario_dia hd ON hd.id_bloque = h.id_bloque
JOIN materia m ON m.id_materia = h.id_materia
JOIN oferta_deporte o ON o.id_dia = hd.id_dia
JOIN franja_horaria f ON f.id_franja = o.id_franja
JOIN deporte dp ON dp.id_deporte = o.id_deporte
JOIN dia_semana ds ON ds.id_dia = o.id_dia
WHERE a.usuario_nick = 'alumno1'
  AND h.hora_inicio < f.hora_fin
  AND h.hora_fin > f.hora_inicio
ORDER BY ds.id_dia, f.hora_inicio, dp.nombre_deporte;

-- 3B. Ed. Física del alumno1: ofertas que NO se superponen y se pueden elegir
--     (ejemplo esperado: Fútbol lunes 10:00-12:00).
SELECT dp.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin
FROM oferta_deporte o
JOIN franja_horaria f ON f.id_franja = o.id_franja
JOIN deporte dp ON dp.id_deporte = o.id_deporte
JOIN dia_semana ds ON ds.id_dia = o.id_dia
WHERE NOT EXISTS (
    SELECT 1
    FROM usuario a
    JOIN horario_escolar h ON h.id_curso = a.id_curso
    JOIN horario_dia hd ON hd.id_bloque = h.id_bloque
    WHERE a.usuario_nick = 'alumno1'
      AND hd.id_dia = o.id_dia
      AND h.hora_inicio < f.hora_fin
      AND h.hora_fin > f.hora_inicio)
ORDER BY ds.id_dia, f.hora_inicio, dp.nombre_deporte;

-- 4. Cupos usados por oferta (derivado: se cuenta, no se guarda). Handball lunes 08:00-10:00 queda lleno (1 de 1).
SELECT dp.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin, o.cupo_maximo,
       COUNT(i.id_inscripcion) AS usados,
       o.cupo_maximo - COUNT(i.id_inscripcion) AS libres
FROM oferta_deporte o
JOIN deporte dp ON dp.id_deporte = o.id_deporte
JOIN dia_semana ds ON ds.id_dia = o.id_dia
JOIN franja_horaria f ON f.id_franja = o.id_franja
LEFT JOIN inscripcion_ed_fisica i ON i.id_oferta = o.id_oferta
GROUP BY o.id_oferta, dp.nombre_deporte, ds.id_dia, ds.nombre_dia, f.hora_inicio, f.hora_fin, o.cupo_maximo
ORDER BY ds.id_dia, f.hora_inicio, dp.nombre_deporte;

-- 5. Último mantenimiento por sector (reportes resueltos). Los sectores sin resolución muestran NULL ("ninguno registrado").
SELECT s.nombre_sector, r.fecha_hora_resolucion AS ultimo_mantenimiento, u.nombre_completo AS resolvio
FROM sector s
LEFT JOIN reporte_higiene r
       ON r.id_sector = s.id_sector
      AND r.fecha_hora_resolucion = (SELECT MAX(r2.fecha_hora_resolucion) FROM reporte_higiene r2 WHERE r2.id_sector = s.id_sector)
LEFT JOIN usuario u ON u.id_usuario = r.id_usuario_resolutor
ORDER BY s.nombre_sector;

-- 6. Recursos disponibles (Planillas): el código "C4-05" o "Tablero 03" se arma en la app; acá van las partes.
SELECT t.nombre_tipo, COALESCE(c.nombre_carro, 'sin carro') AS carro, r.numero_equipo
FROM recursos_ct r
JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
LEFT JOIN carro c ON c.id_carro = r.id_carro
WHERE e.nombre_estado = 'Disponible'
ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo;

-- 7. Préstamos activos (sin hora de devolución) con solicitante, autorizador y recurso.
SELECT p.fecha_prestamo, p.hora_prestamo, sol.nombre_completo AS solicitante, aut.nombre_completo AS autorizador,
       t.nombre_tipo, COALESCE(c.nombre_carro, 'sin carro') AS carro, r.numero_equipo
FROM prestamo_ct p
JOIN usuario sol ON sol.id_usuario = p.id_usuario_solicitante
JOIN usuario aut ON aut.id_usuario = p.id_usuario_autorizador
JOIN recursos_ct r ON r.id_recurso = p.id_recurso
JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso
LEFT JOIN carro c ON c.id_carro = r.id_carro
WHERE p.hora_devolucion IS NULL;

-- 8. Auditoría (log_auditoria). La auditoría no tiene pantalla en la app: se consulta así (D15).
-- 8A. Eventos completos con tipo, resultado, entidad y usuario (id_usuario puede ser NULL).
SELECT l.id_log, l.fecha_hora, l.direccion_ip AS equipo, tl.nombre_evento, rl.nombre_resultado,
       el.nombre_entidad, COALESCE(u.usuario_nick, 'sin usuario') AS usuario, l.descripcion_evento
FROM log_auditoria l
JOIN tipo_log tl ON tl.id_tipo_log = l.id_tipo_log
JOIN resultado_log rl ON rl.id_resultado = l.id_resultado
JOIN entidad_log el ON el.id_entidad = l.id_entidad
LEFT JOIN usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.fecha_hora DESC;

-- 8B. Cantidad de eventos por tipo y resultado.
SELECT tl.nombre_evento, rl.nombre_resultado, COUNT(*) AS cantidad
FROM log_auditoria l
JOIN tipo_log tl ON tl.id_tipo_log = l.id_tipo_log
JOIN resultado_log rl ON rl.id_resultado = l.id_resultado
GROUP BY tl.nombre_evento, rl.nombre_resultado
ORDER BY cantidad DESC, tl.nombre_evento;

-- 8C. Eventos fallidos (validaciones rechazadas y logins inexistentes), con el usuario si existe.
SELECT l.fecha_hora, tl.nombre_evento, COALESCE(u.usuario_nick, 'sin usuario') AS usuario, l.descripcion_evento
FROM log_auditoria l
JOIN tipo_log tl ON tl.id_tipo_log = l.id_tipo_log
JOIN resultado_log rl ON rl.id_resultado = l.id_resultado
LEFT JOIN usuario u ON u.id_usuario = l.id_usuario
WHERE rl.nombre_resultado = 'Fallido'
ORDER BY l.fecha_hora;

-- 8D. Actividad por usuario (cuántos eventos generó cada uno; los sin usuario salen aparte).
SELECT COALESCE(u.usuario_nick, 'sin usuario') AS usuario, COUNT(*) AS eventos
FROM log_auditoria l
LEFT JOIN usuario u ON u.id_usuario = l.id_usuario
GROUP BY COALESCE(u.usuario_nick, 'sin usuario')
ORDER BY eventos DESC, usuario;

-- 8E. Eventos de un día y de una entidad (ejemplo: inscripciones a Ed. Física del 2026-10-23).
SELECT l.fecha_hora, rl.nombre_resultado, COALESCE(u.usuario_nick, 'sin usuario') AS usuario, l.descripcion_evento
FROM log_auditoria l
JOIN entidad_log el ON el.id_entidad = l.id_entidad
JOIN resultado_log rl ON rl.id_resultado = l.id_resultado
LEFT JOIN usuario u ON u.id_usuario = l.id_usuario
WHERE el.nombre_entidad = 'inscripcion_ed_fisica'
  AND l.fecha_hora >= '2026-10-23 00:00:00'
  AND l.fecha_hora < '2026-10-24 00:00:00';

-- 9. Últimos 3 eventos (MySQL y SQLite usan LIMIT; en SQL Server 2005 va SELECT TOP 3 ... ORDER BY fecha_hora DESC).
SELECT l.fecha_hora, tl.nombre_evento, l.descripcion_evento
FROM log_auditoria l
JOIN tipo_log tl ON tl.id_tipo_log = l.id_tipo_log
ORDER BY l.fecha_hora DESC
LIMIT 3;

-- 10. Controles de integridad (cada uno debe devolver 0).
SELECT COUNT(*) AS alumnos_sin_curso
FROM usuario u JOIN rol r ON r.id_rol = u.id_rol
WHERE r.nombre_rol = 'Alumno' AND u.id_curso IS NULL;

SELECT COUNT(*) AS bloques_con_fin_menor_o_igual_al_inicio FROM horario_escolar WHERE hora_fin <= hora_inicio;

SELECT COUNT(*) AS productos_con_stock_negativo FROM producto_buffet WHERE stock < 0;
