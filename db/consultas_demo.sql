-- PROYECTO IQUAL (SGE) - consultas para mostrar en la defensa (10, de menor a mayor dificultad)
-- Base: iqual cargada con 03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql (MySQL) o con las versiones _sqlserver (SQL Server 2005), con los datos de ejemplo (62 usuarios). Antes de empezar: USE iqual;
-- Cada consulta dice cuántas filas tiene que devolver con esos datos.
-- Solo se usa lo del nivel de la materia (CONTEXTO 11): JOIN, WHERE, GROUP BY con COUNT y SUM, HAVING, subconsultas escalares y EXISTS.
-- Las consultas 1 a 7, 9 y 10 son iguales en MySQL y SQL Server. Solo la 8 cambia (la fecha de hoy): tiene una versión para cada motor.
-- Verificación del 19/11/2026: se cargaron 03 y 04 (MySQL) en una copia SQLite con claves foráneas y CHECK activos y las 10 devuelven la cantidad de filas indicada. En MariaDB 10.11 ya habían corrido sin errores (CONTEXTO §19.1, con los datos anteriores). No se ejecutaron en MySQL 8 de Oracle ni en SQL Server.

-- 1. JOIN simple: cada usuario con su rol.
--    Esperado: 62 filas (46 Alumno, 9 Profesor, 4 Preceptor, 3 Maestranza).
--    Muestra: que el rol no se repite como texto en cada usuario, sino que se busca en la tabla rol por la clave foránea.
SELECT u.usuario_nick, u.nombre_completo, r.nombre_rol
FROM usuario u
JOIN rol r ON r.id_rol = u.id_rol
ORDER BY r.nombre_rol, u.usuario_nick;

-- 2. JOIN de varias tablas: los cursos con año, división y especialidad.
--    Esperado: 24 filas.
--    Muestra: que el curso solo guarda tres claves y cada dato vive en su catálogo (anio, division, especialidad).
SELECT a.numero_anio AS anio, d.numero_division AS division, e.nombre_especialidad AS especialidad
FROM curso c
JOIN anio a ON a.id_anio = c.id_anio
JOIN division d ON d.id_division = c.id_division
JOIN especialidad e ON e.id_especialidad = c.id_especialidad
ORDER BY a.numero_anio, d.numero_division, e.nombre_especialidad;

-- 3. JOIN con filtro: los sectores que se pueden reservar.
--    Esperado: 10 filas.
--    Muestra: cómo el tipo de sector (Reservable o Uso común) está en un catálogo y se filtra por su nombre.
SELECT s.nombre_sector, t.nombre_tipo
FROM sector s
JOIN tipo_sector t ON t.id_tipo_sector = s.id_tipo_sector
WHERE t.nombre_tipo = 'Reservable'
ORDER BY s.nombre_sector;

-- 4. Agrupamiento: cuántos equipos hay de cada tipo y en qué estado.
--    Esperado: 5 filas (60 equipos: 49 disponibles, 7 prestados, 4 fuera de servicio).
--    Muestra: el uso de GROUP BY y COUNT con tres tablas unidas (Préstamo de equipos).
SELECT t.nombre_tipo, e.nombre_estado, COUNT(*) AS cantidad
FROM recursos_ct r
JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso
JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
GROUP BY t.nombre_tipo, e.nombre_estado
ORDER BY t.nombre_tipo, e.nombre_estado;

-- 5. LEFT JOIN y SUM: productos de la tienda y stock total por categoría.
--    Esperado: 5 filas (Comida 15 productos, Bebida 5, Accesorios 4, Ropa 4, Otros 2).
--    Muestra: que las categorías sin productos igual aparecen (con 0), porque se usa LEFT JOIN.
SELECT cp.nombre_categoria, COUNT(p.id_producto) AS productos, COALESCE(SUM(p.stock), 0) AS stock_total
FROM categoria_producto cp
LEFT JOIN producto_buffet p ON p.id_categoria_producto = cp.id_categoria_producto
GROUP BY cp.id_categoria_producto, cp.nombre_categoria
ORDER BY cp.id_categoria_producto;

-- 6. Dato derivado: el total de cada venta.
--    Esperado: 28 filas.
--    Muestra: que el total NO se guarda en la base (criterio de 3FN del profesor): se calcula con SUM(cantidad * precio_unitario).
SELECT v.id_venta, v.fecha_hora, es.nombre_estado, SUM(d.cantidad * d.precio_unitario) AS total_venta
FROM venta_buffet v
JOIN estado_venta es ON es.id_estado_venta = v.id_estado_venta
JOIN detalle_venta d ON d.id_venta = v.id_venta
GROUP BY v.id_venta, v.fecha_hora, es.nombre_estado
ORDER BY v.id_venta;

-- 7. HAVING: los objetos perdidos que tienen más de un reclamo.
--    Esperado: 5 filas.
--    Muestra: que "la cantidad de reclamos" también es un dato derivado (se cuenta) y cómo filtrar por un resultado agrupado.
SELECT o.titulo, COUNT(r.id_reclamo) AS reclamos
FROM objeto_perdido o
JOIN reclamo_objeto r ON r.id_objeto = o.id_objeto
GROUP BY o.id_objeto, o.titulo
HAVING COUNT(r.id_reclamo) > 1;

-- 8. Reservas de sectores desde hoy (la fecha de hoy es lo único que cambia entre motores).
--    Muestra: quién reservó qué sector, con qué horario y en qué estado; las reservas de ejemplo son de mañana y pasado mañana y las nuevas de los días siguientes. Esperado: 28 filas.
-- 8 (MySQL)
SELECT r.fecha_reserva, s.nombre_sector, r.hora_inicio, r.hora_fin, u.nombre_completo AS reservo, e.nombre_estado AS estado
FROM reserva_sector r
JOIN sector s ON s.id_sector = r.id_sector
JOIN usuario u ON u.id_usuario = r.id_usuario
JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE r.fecha_reserva >= CURDATE()
ORDER BY r.fecha_reserva, s.nombre_sector, r.hora_inicio;

-- 8 (SQL Server 2005): borrar el bloque anterior y usar este
-- SELECT r.fecha_reserva, s.nombre_sector, r.hora_inicio, r.hora_fin, u.nombre_completo AS reservo, e.nombre_estado AS estado
-- FROM reserva_sector r
-- JOIN sector s ON s.id_sector = r.id_sector
-- JOIN usuario u ON u.id_usuario = r.id_usuario
-- JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
-- WHERE r.fecha_reserva >= DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)
-- ORDER BY r.fecha_reserva, s.nombre_sector, r.hora_inicio;

-- 9. Subconsultas escalares: el recaudado del grupo del buffet y el porcentaje de la meta.
--    Muestra: que "recaudado" tampoco se guarda: es donaciones + ventas ENTREGADAS. Esperado: 21 filas; la primera (Viaje de Estudios 4to 1ra) da 2000 + 1500 = 3500.
SELECT g.nombre_grupo, g.meta_monto,
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

-- 10. NOT EXISTS: las ofertas de Educación Física que alumno1 puede elegir (no se superponen con las clases de su curso).
--     Esperado: 9 filas.
--     Muestra: una subconsulta correlacionada que compara horarios (hora_inicio < fin AND hora_fin > inicio) para detectar el choque.
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
