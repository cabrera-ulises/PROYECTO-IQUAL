-- PROYECTO IQUAL (SGE) - consultas para mostrar en la defensa (10, de menor a mayor dificultad)
-- Base: iqual cargada con 03_ModeloSQL_Grupo06.sql y 04_DatosSQL_Grupo06.sql (MySQL) o con las versiones _sqlserver (SQL Server 2005), con los datos de ejemplo (62 usuarios). Antes de empezar: USE iqual;
-- Cada consulta dice cuántas filas tiene que devolver con esos datos.
-- Solo se usa lo del nivel de la materia (CONTEXTO 11): JOIN, WHERE, GROUP BY con COUNT y SUM, HAVING, subconsultas escalares y EXISTS.
-- Esta es la versión para SQL Server 2005: las tablas llevan su schema y la consulta 8 usa GETDATE(). La versión para MySQL es consultas_demo.sql.
-- Verificación del 19/11/2026: las 10 se compararon sentencia por sentencia con consultas_demo.sql (solo cambian el schema y la 8) y los resultados esperados salen de una carga de prueba de 03 y 04 hecha fuera de SQL Server. No se ejecutaron en SQL Server (revisión estática en guias/REVISION_ESTATICA_SQLSERVER.md).

-- 1. JOIN simple: cada usuario con su rol.
--    Esperado: 62 filas (46 Alumno, 9 Profesor, 4 Preceptor, 3 Maestranza).
--    Muestra: que el rol no se repite como texto en cada usuario, sino que se busca en la tabla rol por la clave foránea.
SELECT u.usuario_nick, u.nombre_completo, r.nombre_rol
FROM seguridad.usuario u
JOIN seguridad.rol r ON r.id_rol = u.id_rol
ORDER BY r.nombre_rol, u.usuario_nick;

-- 2. JOIN de varias tablas: los cursos con año, división y especialidad.
--    Esperado: 24 filas.
--    Muestra: que el curso solo guarda tres claves y cada dato vive en su catálogo (anio, division, especialidad).
SELECT a.numero_anio AS anio, d.numero_division AS division, e.nombre_especialidad AS especialidad
FROM academico.curso c
JOIN academico.anio a ON a.id_anio = c.id_anio
JOIN academico.division d ON d.id_division = c.id_division
JOIN academico.especialidad e ON e.id_especialidad = c.id_especialidad
ORDER BY a.numero_anio, d.numero_division, e.nombre_especialidad;

-- 3. JOIN con filtro: los sectores que se pueden reservar.
--    Esperado: 10 filas.
--    Muestra: cómo el tipo de sector (Reservable o Uso común) está en un catálogo y se filtra por su nombre.
SELECT s.nombre_sector, t.nombre_tipo
FROM instalaciones.sector s
JOIN instalaciones.tipo_sector t ON t.id_tipo_sector = s.id_tipo_sector
WHERE t.nombre_tipo = 'Reservable'
ORDER BY s.nombre_sector;

-- 4. Agrupamiento: cuántos equipos hay de cada tipo y en qué estado.
--    Esperado: 5 filas (60 equipos: 49 disponibles, 7 prestados, 4 fuera de servicio).
--    Muestra: el uso de GROUP BY y COUNT con tres tablas unidas (Préstamo de equipos).
SELECT t.nombre_tipo, e.nombre_estado, COUNT(*) AS cantidad
FROM equipos.recursos_ct r
JOIN equipos.tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso
JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
GROUP BY t.nombre_tipo, e.nombre_estado
ORDER BY t.nombre_tipo, e.nombre_estado;

-- 5. LEFT JOIN y SUM: productos de la tienda y stock total por categoría.
--    Esperado: 5 filas (Comida 15 productos, Bebida 5, Accesorios 4, Ropa 4, Otros 2).
--    Muestra: que las categorías sin productos igual aparecen (con 0), porque se usa LEFT JOIN.
SELECT cp.nombre_categoria, COUNT(p.id_producto) AS productos, COALESCE(SUM(p.stock), 0) AS stock_total
FROM tienda.categoria_producto cp
LEFT JOIN tienda.producto_buffet p ON p.id_categoria_producto = cp.id_categoria_producto
GROUP BY cp.id_categoria_producto, cp.nombre_categoria
ORDER BY cp.id_categoria_producto;

-- 6. Dato derivado: el total de cada venta.
--    Esperado: 28 filas.
--    Muestra: que el total NO se guarda en la base (criterio de 3FN del profesor): se calcula con SUM(cantidad * precio_unitario).
SELECT v.id_venta, v.fecha_hora, es.nombre_estado, SUM(d.cantidad * d.precio_unitario) AS total_venta
FROM tienda.venta_buffet v
JOIN tienda.estado_venta es ON es.id_estado_venta = v.id_estado_venta
JOIN tienda.detalle_venta d ON d.id_venta = v.id_venta
GROUP BY v.id_venta, v.fecha_hora, es.nombre_estado
ORDER BY v.id_venta;

-- 7. HAVING: los objetos perdidos que tienen más de un reclamo.
--    Esperado: 5 filas.
--    Muestra: que "la cantidad de reclamos" también es un dato derivado (se cuenta) y cómo filtrar por un resultado agrupado.
SELECT o.titulo, COUNT(r.id_reclamo) AS reclamos
FROM objetos.objeto_perdido o
JOIN objetos.reclamo_objeto r ON r.id_objeto = o.id_objeto
GROUP BY o.id_objeto, o.titulo
HAVING COUNT(r.id_reclamo) > 1;

-- 8. Reservas de sectores desde hoy (la fecha de hoy es lo único que cambia entre motores).
--    Muestra: quién reservó qué sector, con qué horario y en qué estado; las reservas de ejemplo son de mañana y pasado mañana y las nuevas de los días siguientes. Esperado: 28 filas.
-- 8 (SQL Server 2005)
SELECT r.fecha_reserva, s.nombre_sector, r.hora_inicio, r.hora_fin, u.nombre_completo AS reservo, e.nombre_estado AS estado
FROM instalaciones.reserva_sector r
JOIN instalaciones.sector s ON s.id_sector = r.id_sector
JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario
JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE r.fecha_reserva >= DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)
ORDER BY r.fecha_reserva, s.nombre_sector, r.hora_inicio;

-- 9. Subconsultas escalares: el recaudado del grupo del buffet y el porcentaje de la meta.
--    Muestra: que "recaudado" tampoco se guarda: es donaciones + ventas ENTREGADAS. Esperado: 21 filas; la primera (Viaje de Estudios 4to 1ra) da 2000 + 1500 = 3500.
SELECT g.nombre_grupo, g.meta_monto,
       COALESCE((SELECT SUM(dn.monto) FROM tienda.donacion_buffet dn WHERE dn.id_grupo = g.id_grupo), 0) AS donaciones,
       COALESCE((SELECT SUM(d.cantidad * d.precio_unitario)
                 FROM tienda.detalle_venta d
                 JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto
                 JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta
                 JOIN tienda.estado_venta es ON es.id_estado_venta = v.id_estado_venta
                 WHERE p.id_grupo = g.id_grupo AND es.nombre_estado = 'Entregada'), 0) AS ventas_entregadas,
       COALESCE((SELECT SUM(dn.monto) FROM tienda.donacion_buffet dn WHERE dn.id_grupo = g.id_grupo), 0)
       + COALESCE((SELECT SUM(d.cantidad * d.precio_unitario)
                   FROM tienda.detalle_venta d
                   JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto
                   JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta
                   JOIN tienda.estado_venta es ON es.id_estado_venta = v.id_estado_venta
                   WHERE p.id_grupo = g.id_grupo AND es.nombre_estado = 'Entregada'), 0) AS recaudado
FROM tienda.grupo_buffet g
ORDER BY g.id_grupo;

-- 10. NOT EXISTS: las ofertas de Educación Física que alumno1 puede elegir (no se superponen con las clases de su curso).
--     Esperado: 9 filas.
--     Muestra: una subconsulta correlacionada que compara horarios (hora_inicio < fin AND hora_fin > inicio) para detectar el choque.
SELECT dp.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin
FROM deportes.oferta_deporte o
JOIN academico.franja_horaria f ON f.id_franja = o.id_franja
JOIN deportes.deporte dp ON dp.id_deporte = o.id_deporte
JOIN academico.dia_semana ds ON ds.id_dia = o.id_dia
WHERE NOT EXISTS (
    SELECT 1
    FROM seguridad.usuario a
    JOIN academico.horario_escolar h ON h.id_curso = a.id_curso
    JOIN academico.horario_dia hd ON hd.id_bloque = h.id_bloque
    WHERE a.usuario_nick = 'alumno1'
      AND hd.id_dia = o.id_dia
      AND h.hora_inicio < f.hora_fin
      AND h.hora_fin > f.hora_inicio)
ORDER BY ds.id_dia, f.hora_inicio, dp.nombre_deporte;
