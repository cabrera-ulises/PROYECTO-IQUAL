-- PROYECTO IQUAL (SGE) - consultas de verificación (CONTEXTO_IQUAL v3.2) - versión MySQL 8
-- Se corren sobre la base iqual cargada con 03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql (47 tablas, 62 usuarios).
-- Versión para SQL Server 2005: consultas_verificacion_sqlserver.sql.
-- Las reservas de ejemplo de sectores tienen fecha relativa a hoy (mañana y pasado mañana), por eso se usa DATE_ADD(CURDATE(), ...).
-- Horas 'HH:mm' como texto (D14). Antes de empezar: USE iqual;

-- 1A. Solape de reservas: se quiere reservar Biblioteca MAÑANA de 10:30 a 11:30 (las reservas de ejemplo están a fecha relativa a hoy).
--     Debe devolver 1 fila (la reserva Pendiente de 10:00 a 11:00, de profe1): HAY conflicto y se nombra quién la ocupa.
SELECT u.nombre_completo AS ocupa, r.hora_inicio, r.hora_fin, e.nombre_estado
FROM reserva_sector r
JOIN sector s ON s.id_sector = r.id_sector
JOIN usuario u ON u.id_usuario = r.id_usuario
JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE s.nombre_sector = 'Biblioteca'
  AND r.fecha_reserva = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
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
  AND r.fecha_reserva = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
  AND e.nombre_estado IN ('Pendiente', 'Aprobada')
  AND r.hora_inicio < '12:00'
  AND r.hora_fin > '11:00';

-- 2A. Total de cada venta (dato derivado: no se guarda, se calcula). Esperado: 28 filas (3 ventas de ejemplo y 25 nuevas).
SELECT v.id_venta, v.fecha_hora, es.nombre_estado, SUM(d.cantidad * d.precio_unitario) AS total_venta
FROM venta_buffet v
JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
JOIN detalle_venta d ON d.id_venta = v.id_venta
GROUP BY v.id_venta, v.fecha_hora, es.nombre_estado
ORDER BY v.id_venta;

-- 2B. Recaudado de un grupo (derivado) = donaciones + ventas ENTREGADAS de sus productos (regla de CONTEXTO v2.5). No se guarda: se calcula.
--     Esperado: 21 filas (una por grupo). La primera, 'Viaje de Estudios 4to 1ra', da donaciones 2000 + ventas entregadas 1500 = 3500 (no cambia). Los 20 grupos nuevos tienen sus propios valores.
SELECT g.nombre_grupo,
       g.meta_monto,
       COALESCE((SELECT SUM(dn.monto) FROM donacion_buffet dn WHERE dn.id_grupo = g.id_grupo), 0) AS donaciones,
       COALESCE((SELECT SUM(d.cantidad * d.precio_unitario)
                 FROM detalle_venta d
                 JOIN producto_buffet p ON p.id_producto = d.id_producto
                 JOIN venta_buffet v ON v.id_venta = d.id_venta
                 JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
                 WHERE p.id_grupo = g.id_grupo AND es.nombre_estado = 'Entregada'), 0) AS ventas_entregadas,
       COALESCE((SELECT SUM(dn.monto) FROM donacion_buffet dn WHERE dn.id_grupo = g.id_grupo), 0)
       + COALESCE((SELECT SUM(d.cantidad * d.precio_unitario)
                   FROM detalle_venta d
                   JOIN producto_buffet p ON p.id_producto = d.id_producto
                   JOIN venta_buffet v ON v.id_venta = d.id_venta
                   JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
                   WHERE p.id_grupo = g.id_grupo AND es.nombre_estado = 'Entregada'), 0) AS recaudado
FROM grupo_buffet g
ORDER BY g.id_grupo;

-- 3A. Ed. Física del alumno1: ofertas que SÍ se superponen con el horario de su curso (4 1 Computación).
--     Esperado con los datos actuales: 15 filas; las primeras son Vóley lunes 14:00-16:00 contra Programación y Proyecto Informático I.
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
--     (esperado: 9 filas; ejemplo, Handball lunes 08:00-10:00).
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

-- 4. Cupos usados por oferta (derivado: se cuenta, no se guarda). Esperado: 20 filas. Handball lunes 08:00-10:00 queda lleno (1 de 1). Hay 37 inscriptos en total.
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

-- 5. Esperado: 22 filas, una por sector. Último mantenimiento por sector (reportes resueltos). Los sectores sin resolución muestran NULL ("ninguno registrado").
SELECT s.nombre_sector, r.fecha_hora_resolucion AS ultimo_mantenimiento, u.nombre_completo AS resolvio
FROM sector s
LEFT JOIN reporte_higiene r
       ON r.id_sector = s.id_sector
      AND r.fecha_hora_resolucion = (SELECT MAX(r2.fecha_hora_resolucion) FROM reporte_higiene r2 WHERE r2.id_sector = s.id_sector)
LEFT JOIN usuario u ON u.id_usuario = r.id_usuario_resolutor
ORDER BY s.nombre_sector;

-- 6. Esperado: 49 filas (Disponibles; 4 están Fuera de servicio y 7 Prestados, 60 en total). Recursos disponibles (Planillas): el código "C4-05" o "Tablero 03" se arma en la app; acá van las partes.
SELECT t.nombre_tipo, COALESCE(c.nombre_carro, 'sin carro') AS carro, r.numero_equipo
FROM recursos_ct r
JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
LEFT JOIN carro c ON c.id_carro = r.id_carro
WHERE e.nombre_estado = 'Disponible'
ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo;

-- 7. Préstamos activos (sin hora de devolución) con solicitante, autorizador y recurso. Esperado: 7 filas (1 de ejemplo en C4 y 6 nuevas en C1, C2 y C3).
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
--    OJO: 04_DatosSQL deja log_auditoria VACÍA. Las consultas 8A a 8E y la 9 devuelven 0 filas hasta que se ejecuten los procedimientos de 05_Backend o se use la app. Eso es lo esperado.
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

-- 9. Últimos 3 eventos.
SELECT  l.fecha_hora, tl.nombre_evento, l.descripcion_evento
FROM log_auditoria l
JOIN tipo_log tl ON tl.id_tipo_log = l.id_tipo_log
ORDER BY l.fecha_hora DESC
LIMIT 3;

-- 10. Programas instalados por carro (tabla intermedia recurso_software): cuántos equipos de cada carro tienen cada programa.
--     Esperado: 17 filas (3 programas por carro en C1, C2, C3 y C5, y 5 en C4). Total de instalaciones: 160 (C4 tiene 40 y los otros cuatro carros 30 cada uno).
SELECT c.nombre_carro, s.nombre_software, COUNT(*) AS equipos
FROM recurso_software rs
JOIN recursos_ct r ON r.id_recurso = rs.id_recurso
JOIN carro c ON c.id_carro = r.id_carro
JOIN software s ON s.id_software = rs.id_software
GROUP BY c.nombre_carro, s.nombre_software
ORDER BY c.nombre_carro, s.nombre_software;

-- 11. Filtro por programa (lo que hace la pantalla de Préstamo de equipos): equipos DISPONIBLES que tienen instalado AutoCAD. Esperado: 17 filas (7 de C3 y 10 de C5).
SELECT c.nombre_carro, r.numero_equipo
FROM recursos_ct r
JOIN carro c ON c.id_carro = r.id_carro
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
WHERE e.nombre_estado = 'Disponible'
  AND EXISTS (SELECT 1
              FROM recurso_software rs
              JOIN software s ON s.id_software = rs.id_software
              WHERE rs.id_recurso = r.id_recurso AND s.nombre_software = 'AutoCAD')
ORDER BY c.nombre_carro, r.numero_equipo;

-- 12. Productos de la tienda por categoría (las categorías sin productos salen con 0). Esperado: Comida 15 (stock 278), Bebida 5 (98), Accesorios 4 (72), Ropa 4 (60), Otros 2 (39): 30 productos.
SELECT cp.nombre_categoria, COUNT(p.id_producto) AS productos, COALESCE(SUM(p.stock), 0) AS stock_total
FROM categoria_producto cp
LEFT JOIN producto_buffet p ON p.id_categoria_producto = cp.id_categoria_producto
GROUP BY cp.id_categoria_producto, cp.nombre_categoria
ORDER BY cp.id_categoria_producto;

-- 13. Esperado: 23 filas (10 con dato reservado y 13 sin). Objetos perdidos: si tienen dato reservado (el contenido NO se muestra acá a propósito) y cuántos reclamos tienen (derivado: se cuenta).
SELECT o.titulo, eo.nombre_estado, CASE WHEN o.detalle_reservado IS NULL THEN 'sin dato reservado' ELSE 'con dato reservado' END AS dato_reservado,
       COUNT(r.id_reclamo) AS reclamos
FROM objeto_perdido o
JOIN estado_objeto eo ON eo.id_estado_objeto = o.id_estado_objeto
LEFT JOIN reclamo_objeto r ON r.id_objeto = o.id_objeto
GROUP BY o.id_objeto, o.titulo, eo.nombre_estado, o.detalle_reservado
ORDER BY o.id_objeto;

-- 14. Filas de cada catálogo (24 catálogos). Con los datos de ejemplo:
--     rol 4, especialidad 3, turno 2, dia_semana 5, categoria_objeto 6, estado_objeto 4, estado_reclamo 3, tipo_reporte 2, estado_reporte 2, estado_reserva 4, estado_venta 3, tipo_recurso 2, estado_recurso 3, carro 5, deporte 4, tipo_log 16, resultado_log 2, entidad_log 12, tipo_sector 2, anio 7, division 9, franja_horaria 5, categoria_producto 5, software 6.
SELECT 'rol' AS catalogo, COUNT(*) AS filas FROM rol
UNION ALL
SELECT 'especialidad' AS catalogo, COUNT(*) AS filas FROM especialidad
UNION ALL
SELECT 'turno' AS catalogo, COUNT(*) AS filas FROM turno
UNION ALL
SELECT 'dia_semana' AS catalogo, COUNT(*) AS filas FROM dia_semana
UNION ALL
SELECT 'categoria_objeto' AS catalogo, COUNT(*) AS filas FROM categoria_objeto
UNION ALL
SELECT 'estado_objeto' AS catalogo, COUNT(*) AS filas FROM estado_objeto
UNION ALL
SELECT 'estado_reclamo' AS catalogo, COUNT(*) AS filas FROM estado_reclamo
UNION ALL
SELECT 'tipo_reporte' AS catalogo, COUNT(*) AS filas FROM tipo_reporte
UNION ALL
SELECT 'estado_reporte' AS catalogo, COUNT(*) AS filas FROM estado_reporte
UNION ALL
SELECT 'estado_reserva' AS catalogo, COUNT(*) AS filas FROM estado_reserva
UNION ALL
SELECT 'estado_venta' AS catalogo, COUNT(*) AS filas FROM estado_venta
UNION ALL
SELECT 'tipo_recurso' AS catalogo, COUNT(*) AS filas FROM tipo_recurso
UNION ALL
SELECT 'estado_recurso' AS catalogo, COUNT(*) AS filas FROM estado_recurso
UNION ALL
SELECT 'carro' AS catalogo, COUNT(*) AS filas FROM carro
UNION ALL
SELECT 'deporte' AS catalogo, COUNT(*) AS filas FROM deporte
UNION ALL
SELECT 'tipo_log' AS catalogo, COUNT(*) AS filas FROM tipo_log
UNION ALL
SELECT 'resultado_log' AS catalogo, COUNT(*) AS filas FROM resultado_log
UNION ALL
SELECT 'entidad_log' AS catalogo, COUNT(*) AS filas FROM entidad_log
UNION ALL
SELECT 'tipo_sector' AS catalogo, COUNT(*) AS filas FROM tipo_sector
UNION ALL
SELECT 'anio' AS catalogo, COUNT(*) AS filas FROM anio
UNION ALL
SELECT 'division' AS catalogo, COUNT(*) AS filas FROM division
UNION ALL
SELECT 'franja_horaria' AS catalogo, COUNT(*) AS filas FROM franja_horaria
UNION ALL
SELECT 'categoria_producto' AS catalogo, COUNT(*) AS filas FROM categoria_producto
UNION ALL
SELECT 'software' AS catalogo, COUNT(*) AS filas FROM software;

-- 15. Controles de integridad (cada uno debe devolver 0). Son 21: los 6 de siempre y 15 nuevos de coherencia de los datos (usuarios, préstamos, ventas, cupos, reservas, reclamos, reportes).
SELECT COUNT(*) AS alumnos_sin_curso
FROM usuario u JOIN rol r ON r.id_rol = u.id_rol
WHERE r.nombre_rol = 'Alumno' AND u.id_curso IS NULL;

SELECT COUNT(*) AS bloques_con_fin_menor_o_igual_al_inicio FROM horario_escolar WHERE hora_fin <= hora_inicio;

SELECT COUNT(*) AS productos_con_stock_negativo FROM producto_buffet WHERE stock < 0;

SELECT COUNT(*) AS usuarios_con_reclamo_repetido_sobre_un_objeto
FROM (SELECT id_usuario, id_objeto FROM reclamo_objeto GROUP BY id_usuario, id_objeto HAVING COUNT(*) > 1) x;

SELECT COUNT(*) AS programas_repetidos_en_un_equipo
FROM (SELECT id_recurso, id_software FROM recurso_software GROUP BY id_recurso, id_software HAVING COUNT(*) > 1) x;

SELECT COUNT(*) AS productos_sin_categoria
FROM producto_buffet p LEFT JOIN categoria_producto c ON c.id_categoria_producto = p.id_categoria_producto
WHERE c.id_categoria_producto IS NULL;

-- 15 (cont.). Controles nuevos, cada uno debe devolver 0.
SELECT CASE WHEN COUNT(*) >= 50 THEN 0 ELSE 1 END AS menos_de_50_usuarios FROM usuario;

SELECT COUNT(*) AS prestamos_activos_sobre_equipo_no_prestado
FROM prestamo_ct p
JOIN recursos_ct r ON r.id_recurso = p.id_recurso
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
WHERE p.hora_devolucion IS NULL AND e.nombre_estado <> 'Prestado';

SELECT COUNT(*) AS equipos_prestados_sin_prestamo_activo
FROM recursos_ct r
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
WHERE e.nombre_estado = 'Prestado'
  AND NOT EXISTS (SELECT 1 FROM prestamo_ct p WHERE p.id_recurso = r.id_recurso AND p.hora_devolucion IS NULL);

SELECT COUNT(*) AS equipos_con_dos_prestamos_activos
FROM (SELECT id_recurso FROM prestamo_ct WHERE hora_devolucion IS NULL GROUP BY id_recurso HAVING COUNT(*) > 1) x;

SELECT COUNT(*) AS devueltos_con_falla_y_equipo_no_fuera_de_servicio
FROM prestamo_ct p
JOIN recursos_ct r ON r.id_recurso = p.id_recurso
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
WHERE p.observaciones LIKE 'No funciona%' AND e.nombre_estado <> 'Fuera de servicio';

SELECT COUNT(*) AS devoluciones_antes_del_prestamo
FROM prestamo_ct WHERE hora_devolucion IS NOT NULL AND hora_devolucion <= hora_prestamo;

SELECT COUNT(*) AS ventas_sin_detalle
FROM venta_buffet v WHERE NOT EXISTS (SELECT 1 FROM detalle_venta d WHERE d.id_venta = v.id_venta);

SELECT COUNT(*) AS compras_de_productos_propios
FROM detalle_venta d
JOIN venta_buffet v ON v.id_venta = d.id_venta
JOIN producto_buffet p ON p.id_producto = d.id_producto
WHERE p.id_usuario = v.id_usuario;

SELECT COUNT(*) AS ofertas_con_mas_inscriptos_que_cupo
FROM (SELECT o.id_oferta FROM oferta_deporte o
      JOIN inscripcion_ed_fisica i ON i.id_oferta = o.id_oferta
      GROUP BY o.id_oferta, o.cupo_maximo HAVING COUNT(*) > o.cupo_maximo) x;

SELECT COUNT(*) AS inscripciones_que_chocan_con_el_horario_del_curso
FROM inscripcion_ed_fisica i
JOIN usuario u ON u.id_usuario = i.id_usuario
JOIN oferta_deporte o ON o.id_oferta = i.id_oferta
JOIN franja_horaria f ON f.id_franja = o.id_franja
JOIN horario_escolar h ON h.id_curso = u.id_curso
JOIN horario_dia hd ON hd.id_bloque = h.id_bloque AND hd.id_dia = o.id_dia
WHERE h.hora_inicio < f.hora_fin AND h.hora_fin > f.hora_inicio;

SELECT COUNT(*) AS reservas_activas_superpuestas
FROM reserva_sector a
JOIN reserva_sector b ON a.id_sector = b.id_sector AND a.fecha_reserva = b.fecha_reserva AND a.id_reserva < b.id_reserva
JOIN estado_reserva ea ON ea.id_estado_reserva = a.id_estado_reserva
JOIN estado_reserva eb ON eb.id_estado_reserva = b.id_estado_reserva
WHERE ea.nombre_estado IN ('Pendiente', 'Aprobada') AND eb.nombre_estado IN ('Pendiente', 'Aprobada')
  AND a.hora_inicio < b.hora_fin AND a.hora_fin > b.hora_inicio;

SELECT COUNT(*) AS objetos_en_reclamo_sin_reclamo_pendiente
FROM objeto_perdido o
JOIN estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto
WHERE e.nombre_estado = 'En reclamo'
  AND NOT EXISTS (SELECT 1 FROM reclamo_objeto r JOIN estado_reclamo er ON er.id_estado_reclamo = r.id_estado_reclamo
                  WHERE r.id_objeto = o.id_objeto AND er.nombre_estado = 'Pendiente');

SELECT COUNT(*) AS objetos_devueltos_sin_reclamo_aprobado
FROM objeto_perdido o
JOIN estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto
WHERE e.nombre_estado = 'Devuelto'
  AND NOT EXISTS (SELECT 1 FROM reclamo_objeto r JOIN estado_reclamo er ON er.id_estado_reclamo = r.id_estado_reclamo
                  WHERE r.id_objeto = o.id_objeto AND er.nombre_estado = 'Aprobado');

SELECT COUNT(*) AS reclamos_anteriores_al_registro_del_objeto
FROM reclamo_objeto r JOIN objeto_perdido o ON o.id_objeto = r.id_objeto
WHERE r.fecha_reclamo < o.fecha_registro;

SELECT COUNT(*) AS reportes_con_estado_y_resolucion_incoherentes
FROM reporte_higiene r JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte
WHERE (e.nombre_estado = 'Resuelto' AND (r.fecha_hora_resolucion IS NULL OR r.id_usuario_resolutor IS NULL))
   OR (e.nombre_estado = 'Pendiente' AND (r.fecha_hora_resolucion IS NOT NULL OR r.id_usuario_resolutor IS NOT NULL));

-- 16. Cantidad de tablas (tiene que dar 47).
SELECT COUNT(*) AS tablas FROM information_schema.tables WHERE table_schema = 'iqual' AND table_type = 'BASE TABLE';

-- 17. Filas de cada tabla justo despues de cargar 03 y 04 (47 filas de resultado). log_auditoria queda en 0 hasta que se usen los procedimientos.
--     Valores esperados: rol 4, especialidad 3, turno 2, dia_semana 5, categoria_objeto 6, estado_objeto 4, estado_reclamo 3, tipo_reporte 2, estado_reporte 2, estado_reserva 4, estado_venta 3, tipo_recurso 2, estado_recurso 3, carro 5, deporte 4, tipo_log 16, resultado_log 2, entidad_log 12, tipo_sector 2, categoria_producto 5, software 6, anio 7, division 9, franja_horaria 5, curso 24, usuario 62, materia 21, horario_escolar 137, horario_dia 229, sector 22, objeto_perdido 23, reclamo_objeto 25, consulta_objeto 22, reporte_higiene 22, grupo_buffet 21, integrante_grupo 62, producto_buffet 30, venta_buffet 28, detalle_venta 37, donacion_buffet 26, recursos_ct 60, recurso_software 160, prestamo_ct 24, reserva_sector 28, oferta_deporte 20, inscripcion_ed_fisica 37, log_auditoria 0.
SELECT 'rol' AS tabla, COUNT(*) AS filas FROM rol
UNION ALL SELECT 'especialidad' AS tabla, COUNT(*) AS filas FROM especialidad
UNION ALL SELECT 'turno' AS tabla, COUNT(*) AS filas FROM turno
UNION ALL SELECT 'dia_semana' AS tabla, COUNT(*) AS filas FROM dia_semana
UNION ALL SELECT 'categoria_objeto' AS tabla, COUNT(*) AS filas FROM categoria_objeto
UNION ALL SELECT 'estado_objeto' AS tabla, COUNT(*) AS filas FROM estado_objeto
UNION ALL SELECT 'estado_reclamo' AS tabla, COUNT(*) AS filas FROM estado_reclamo
UNION ALL SELECT 'tipo_reporte' AS tabla, COUNT(*) AS filas FROM tipo_reporte
UNION ALL SELECT 'estado_reporte' AS tabla, COUNT(*) AS filas FROM estado_reporte
UNION ALL SELECT 'estado_reserva' AS tabla, COUNT(*) AS filas FROM estado_reserva
UNION ALL SELECT 'estado_venta' AS tabla, COUNT(*) AS filas FROM estado_venta
UNION ALL SELECT 'tipo_recurso' AS tabla, COUNT(*) AS filas FROM tipo_recurso
UNION ALL SELECT 'estado_recurso' AS tabla, COUNT(*) AS filas FROM estado_recurso
UNION ALL SELECT 'carro' AS tabla, COUNT(*) AS filas FROM carro
UNION ALL SELECT 'deporte' AS tabla, COUNT(*) AS filas FROM deporte
UNION ALL SELECT 'tipo_log' AS tabla, COUNT(*) AS filas FROM tipo_log
UNION ALL SELECT 'resultado_log' AS tabla, COUNT(*) AS filas FROM resultado_log
UNION ALL SELECT 'entidad_log' AS tabla, COUNT(*) AS filas FROM entidad_log
UNION ALL SELECT 'tipo_sector' AS tabla, COUNT(*) AS filas FROM tipo_sector
UNION ALL SELECT 'categoria_producto' AS tabla, COUNT(*) AS filas FROM categoria_producto
UNION ALL SELECT 'software' AS tabla, COUNT(*) AS filas FROM software
UNION ALL SELECT 'anio' AS tabla, COUNT(*) AS filas FROM anio
UNION ALL SELECT 'division' AS tabla, COUNT(*) AS filas FROM division
UNION ALL SELECT 'franja_horaria' AS tabla, COUNT(*) AS filas FROM franja_horaria
UNION ALL SELECT 'curso' AS tabla, COUNT(*) AS filas FROM curso
UNION ALL SELECT 'usuario' AS tabla, COUNT(*) AS filas FROM usuario
UNION ALL SELECT 'materia' AS tabla, COUNT(*) AS filas FROM materia
UNION ALL SELECT 'horario_escolar' AS tabla, COUNT(*) AS filas FROM horario_escolar
UNION ALL SELECT 'horario_dia' AS tabla, COUNT(*) AS filas FROM horario_dia
UNION ALL SELECT 'sector' AS tabla, COUNT(*) AS filas FROM sector
UNION ALL SELECT 'objeto_perdido' AS tabla, COUNT(*) AS filas FROM objeto_perdido
UNION ALL SELECT 'reclamo_objeto' AS tabla, COUNT(*) AS filas FROM reclamo_objeto
UNION ALL SELECT 'consulta_objeto' AS tabla, COUNT(*) AS filas FROM consulta_objeto
UNION ALL SELECT 'reporte_higiene' AS tabla, COUNT(*) AS filas FROM reporte_higiene
UNION ALL SELECT 'grupo_buffet' AS tabla, COUNT(*) AS filas FROM grupo_buffet
UNION ALL SELECT 'integrante_grupo' AS tabla, COUNT(*) AS filas FROM integrante_grupo
UNION ALL SELECT 'producto_buffet' AS tabla, COUNT(*) AS filas FROM producto_buffet
UNION ALL SELECT 'venta_buffet' AS tabla, COUNT(*) AS filas FROM venta_buffet
UNION ALL SELECT 'detalle_venta' AS tabla, COUNT(*) AS filas FROM detalle_venta
UNION ALL SELECT 'donacion_buffet' AS tabla, COUNT(*) AS filas FROM donacion_buffet
UNION ALL SELECT 'recursos_ct' AS tabla, COUNT(*) AS filas FROM recursos_ct
UNION ALL SELECT 'recurso_software' AS tabla, COUNT(*) AS filas FROM recurso_software
UNION ALL SELECT 'prestamo_ct' AS tabla, COUNT(*) AS filas FROM prestamo_ct
UNION ALL SELECT 'reserva_sector' AS tabla, COUNT(*) AS filas FROM reserva_sector
UNION ALL SELECT 'oferta_deporte' AS tabla, COUNT(*) AS filas FROM oferta_deporte
UNION ALL SELECT 'inscripcion_ed_fisica' AS tabla, COUNT(*) AS filas FROM inscripcion_ed_fisica
UNION ALL SELECT 'log_auditoria' AS tabla, COUNT(*) AS filas FROM log_auditoria;
