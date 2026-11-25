-- 06_Guia_Ejecucion_PruebasSQL.sql - PROYECTO IQUAL (SGE) - Grupo 06
-- Guia para ejecutar a mano los 104 casos de 06_PruebasSQL.xlsx en MySQL Workbench (o DBeaver).
-- Todo en la MISMA pestaña de consulta: las variables (@l, @obj, ...) viven solo en esa conexion.
-- 1. Cargar desde cero 03_ModeloSQL, 04_DatosSQL y 05_Backend (Alt+X en cada uno).
-- 2. Abrir este archivo con la conexion a la base iqual.
-- 3. Ir caso por caso: poner el cursor en cada sentencia y ejecutarla con Ctrl+Enter, en orden.
-- 4. Comparar lo que devuelve con el ESPERADO del caso y anotar en la planilla:
--    ACTUAL RESULT = lo que devolvio (resumido) y PASS = PASS o FAIL.
-- 5. Si el caso tiene VOLVER ATRAS, ejecutarlo despues de anotar, asi el caso siguiente arranca igual.
-- 6. Donde dice RECARGAR, ejecutar de nuevo 04_DatosSQL completo antes de ese caso (el caso lo pide asi).
-- Si algo queda raro, volver a cargar 04_DatosSQL y seguir desde el caso donde estabas.

USE iqual;
SET SQL_SAFE_UPDATES = 0;

-- ====================================================================================================
-- TC_SP_REGISTRAR_LOG_01 · Éxito: evento válido con usuario existente
-- ====================================================================================================
-- ANTES: 1. Base iqual cargada con 03_ModeloSQL y 04_DatosSQL (catálogos tipo_log, entidad_log y resultado_log cargados).
--        2. Existe el usuario alumno1.
--        3. Sesión abierta con USE iqual.
-- ESPERADO: El CALL no devuelve filas: solo guarda el registro.
--           El SELECT devuelve 1 fila: descripcion_evento 'Inicio de sesión exitoso de alumno1', direccion_ip 'PC-LAB-01', nombre_evento 'Inicio de sesión', nombre_entidad 'usuario', usuario_nick 'alumno1', nombre_resultado 'Exitoso'. La fecha_hora del registro es la actual.
-- 1. Contar los registros del log antes
SELECT COUNT(*) INTO @antes FROM seguridad.log_auditoria;
-- 2. Ejecutar el procedimiento
CALL sp_registrar_log('Inicio de sesión', 'Inicio de sesión exitoso de alumno1', 'usuario', 'alumno1', 'Exitoso', 'PC-LAB-01');
-- 3. Consultar el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
SET @ultimo_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria); DELETE FROM seguridad.log_auditoria WHERE id_log = @ultimo_log;

-- ====================================================================================================
-- TC_SP_REGISTRAR_LOG_02 · Sin coincidencias: usuario inexistente (el evento se guarda sin usuario)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe el usuario 'usuario_fantasma': SELECT COUNT(*) FROM seguridad.usuario WHERE usuario_nick = 'usuario_fantasma'; da 0.
-- ESPERADO: El CALL no da error de ejecución ni devuelve filas: solo guarda el registro.
--           El SELECT devuelve usuario_nick = NULL (id_usuario NULL), nombre_resultado 'Fallido', direccion_ip 'PC-LAB-02', descripcion_evento 'Intento de inicio de sesión con usuario inexistente'.
-- 1. Contar los registros del log antes
SELECT COUNT(*) INTO @antes FROM seguridad.log_auditoria;
-- 2. Ejecutar el procedimiento con un nick que no existe
CALL sp_registrar_log('Inicio de sesión', 'Intento de inicio de sesión con usuario inexistente', 'usuario', 'usuario_fantasma', 'Fallido', 'PC-LAB-02');
-- 3. Consultar el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
SET @ultimo_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria); DELETE FROM seguridad.log_auditoria WHERE id_log = @ultimo_log;

-- ====================================================================================================
-- TC_SP_REGISTRAR_LOG_03 · Parámetros vacíos o NULL: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
-- ESPERADO: Paso 2: 1 fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'La descripción del evento es obligatoria.'.
--           Paso 3: 1 fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El tipo de evento no existe en el catálogo.'.
--           Paso 4: sin_cambios = 1. No hay error de ejecución de MySQL ni filas con datos erróneos.
-- 1. Contar los registros del log antes
SELECT COUNT(*) INTO @antes FROM seguridad.log_auditoria;
-- 2. Descripción vacía
CALL sp_registrar_log('Inicio de sesión', '', 'usuario', 'alumno1', 'Exitoso', NULL);
-- 3. Tipo de evento NULL
CALL sp_registrar_log(NULL, 'Evento sin tipo', 'usuario', 'alumno1', 'Exitoso', NULL);
-- 4. Verificar que no se insertó nada
SELECT COUNT(*) = @antes AS sin_cambios FROM seguridad.log_auditoria;

-- ====================================================================================================
-- TC_SP_REGISTRAR_LOG_04 · Equivalencia: el registro guardado es igual al SELECT directo (IP vacía = host del cliente)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. Existe el usuario alumno1.
-- ESPERADO: El CALL no devuelve filas. El SELECT del paso 3 devuelve exactamente la misma fila (6 columnas, mismos valores) que el SELECT directo del paso 4.
-- 1. Contar los registros del log antes
SELECT COUNT(*) INTO @antes FROM seguridad.log_auditoria;
-- 2. Ejecutar el procedimiento con la IP en NULL
CALL sp_registrar_log('Cierre de sesión', 'Cierre de sesión de alumno1', 'usuario', 'alumno1', 'Exitoso', NULL);
-- 3. Leer el registro guardado
SELECT l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. SELECT directo esperado (se compara con el paso 3)
SELECT 'Cierre de sesión de alumno1' AS descripcion_evento, SUBSTRING_INDEX(USER(), '@', -1) AS direccion_ip, 'Cierre de sesión' AS nombre_evento, 'usuario' AS nombre_entidad, 'alumno1' AS usuario_nick, 'Exitoso' AS nombre_resultado;
-- VOLVER ATRAS (despues de anotar el resultado):
SET @ultimo_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria); DELETE FROM seguridad.log_auditoria WHERE id_log = @ultimo_log;

-- ====================================================================================================
-- TC_SP_REGISTRAR_USUARIO_01 · Éxito: alta de un alumno de 4° 1° Computación
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04.
--        2. No existe un usuario con nick 'prueba.alumno', DNI 45123456 ni correo 'prueba.alumno@iqual.demo' (datos ficticios; si ya existen, cambiar los tres por otros ficticios).
--        3. Existe el curso 4° 1° Computación (lo usa alumno1) y se reutiliza.
-- ESPERADO: Paso 1: 0.
--           Paso 2: 1 fila: estado = 'OK', id_usuario = el id nuevo, mensaje = 'Cuenta creada. Ya podés iniciar sesión.'.
--           Paso 3: 45123456, 'Prueba Alumno', 'prueba.alumno', 'prueba.alumno@iqual.demo', '1155559999', 'Alumno'.
--           Paso 4: 4, 1, 'Computación' (no se creó un curso nuevo: es el mismo id_curso que alumno1).
--           Paso 5: descripcion_evento 'Se creó la cuenta prueba.alumno', nombre_evento 'Registro de usuario', nombre_entidad 'usuario', usuario_nick 'prueba.alumno', nombre_resultado 'Exitoso'.
-- 1. Verificar que los datos están libres
SELECT COUNT(*) AS debe_dar_0 FROM seguridad.usuario WHERE usuario_nick = 'prueba.alumno' OR dni = 45123456 OR email = 'prueba.alumno@iqual.demo';
-- 2. Ejecutar el procedimiento
CALL sp_registrar_usuario('45123456', 'Prueba Alumno', 'prueba.alumno', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'prueba.alumno@iqual.demo', '1155559999', 'Alumno', 4, 1, 'Computación');
-- 3. Leer el usuario creado
SELECT u.dni, u.nombre_completo, u.usuario_nick, u.email, u.contacto_telefono, r.nombre_rol FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.usuario_nick = 'prueba.alumno';
-- 4. Leer su curso
SELECT a.numero_anio, d.numero_division, e.nombre_especialidad FROM seguridad.usuario u JOIN academico.curso c ON c.id_curso = u.id_curso JOIN academico.anio a ON a.id_anio = c.id_anio JOIN academico.division d ON d.id_division = c.id_division JOIN academico.especialidad e ON e.id_especialidad = c.id_especialidad WHERE u.usuario_nick = 'prueba.alumno';
-- 5. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
SET @id = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'prueba.alumno'); DELETE FROM seguridad.log_auditoria WHERE id_usuario = @id; DELETE FROM seguridad.usuario WHERE id_usuario = @id;

-- ====================================================================================================
-- TC_SP_REGISTRAR_USUARIO_02 · Sin coincidencias: especialidad inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. La especialidad 'Astronomía' no existe en la tabla especialidad.
--        3. No existe el nick 'prueba.dos'.
-- ESPERADO: Paso 2: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'La especialidad elegida no existe.'. No hay error de ejecución de MySQL.
--           Paso 3: usuarios_igual = 1 y cursos_igual = 1.
--           Paso 4: descripcion_evento 'La especialidad elegida no existe.', nombre_evento 'Registro de usuario', usuario_nick NULL, nombre_resultado 'Fallido'.
-- 1. Contar usuarios y cursos antes
SELECT COUNT(*) INTO @u0 FROM seguridad.usuario; SELECT COUNT(*) INTO @c0 FROM academico.curso; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_registrar_usuario('45123457', 'Prueba Dos', 'prueba.dos', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'prueba.dos@iqual.demo', '1155559998', 'Alumno', 4, 1, 'Astronomía');
-- 3. Verificar que no se creó nada
SELECT (SELECT COUNT(*) FROM seguridad.usuario) = @u0 AS usuarios_igual, (SELECT COUNT(*) FROM academico.curso) = @c0 AS cursos_igual;
-- 4. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_REGISTRAR_USUARIO_03 · Parámetros NULL o cadenas vacías: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
-- ESPERADO: Pasos 2 y 3: cada CALL devuelve 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Escribí tu nombre y apellido separados por un espacio.'.
--           Paso 4: sin_cambios = 1.
--           Se guardan 2 filas de log 'Fallido' (tipo 'Registro de usuario', usuario NULL). No hay error de ejecución de MySQL.
-- 1. Contar usuarios antes
SELECT COUNT(*) INTO @u0 FROM seguridad.usuario; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Todos los parámetros en NULL
CALL sp_registrar_usuario(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
-- 3. Todos los textos vacíos
CALL sp_registrar_usuario('', '', '', '', '', '', '', NULL, NULL, '');
-- 4. Verificar que no se creó ningún usuario
SELECT COUNT(*) = @u0 AS sin_cambios FROM seguridad.usuario;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_REGISTRAR_USUARIO_04 · Equivalencia: el usuario guardado es igual al SELECT directo (Profesor, nick normalizado)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe el nick 'prueba.profe', el DNI 45123458 ni el correo 'prueba.profe@iqual.demo' (datos ficticios).
-- ESPERADO: Paso 1: estado = 'OK', id_usuario = el id nuevo, mensaje = 'Cuenta creada. Ya podés iniciar sesión.'.
--           El SELECT del paso 2 devuelve exactamente la misma fila (8 columnas, mismos valores) que el SELECT directo del paso 3: el nick se guardó en minúsculas y sin espacios y id_curso quedó NULL.
-- 1. Ejecutar el procedimiento con el nick en mayúsculas y con espacios
CALL sp_registrar_usuario('45123458', 'Prueba Profesor', '  Prueba.Profe ', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'prueba.profe@iqual.demo', '1155559997', 'Profesor', NULL, NULL, NULL);
-- 2. Leer el usuario guardado
SELECT u.dni, u.nombre_completo, u.usuario_nick, u.password_hash, u.email, u.contacto_telefono, r.nombre_rol, u.id_curso FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.usuario_nick = 'prueba.profe';
-- 3. SELECT directo esperado (se compara con el paso 2)
SELECT 45123458 AS dni, 'Prueba Profesor' AS nombre_completo, 'prueba.profe' AS usuario_nick, '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4' AS password_hash, 'prueba.profe@iqual.demo' AS email, '1155559997' AS contacto_telefono, 'Profesor' AS nombre_rol, NULL AS id_curso;
-- VOLVER ATRAS (despues de anotar el resultado):
SET @id = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'prueba.profe'); DELETE FROM seguridad.log_auditoria WHERE id_usuario = @id; DELETE FROM seguridad.usuario WHERE id_usuario = @id;

-- ====================================================================================================
-- TC_SP_PUBLICAR_OBJETO_01 · Éxito: el Preceptor publica un objeto con todos los datos
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04.
--        2. Existe preceptor1 (rol Preceptor), la categoría 'Otros' y el sector 'Patio'.
--        3. No existe ya un objeto con título 'Mochila de prueba'.
-- ESPERADO: Paso 1: 1 fila: estado = 'OK', id_objeto = el id nuevo, mensaje = 'Objeto publicado.'.
--           Paso 3: 'Mochila de prueba', 'Mochila negra con un llavero de Qt', 'mochila_negra.png', 'Tiene un cuaderno de Bases de Datos adentro', fecha_registro = la fecha de hoy, 'preceptor1', 'Otros', 'Disponible', 'Patio'.
--           Paso 4: descripcion_evento 'Objeto publicado: Mochila de prueba', nombre_evento 'Publicación de objeto', nombre_entidad 'objeto_perdido', usuario_nick 'preceptor1', nombre_resultado 'Exitoso'.
-- 1. Ejecutar el procedimiento
CALL sp_publicar_objeto('preceptor1', 'Mochila de prueba', 'Mochila negra con un llavero de Qt', 'Otros', 'Patio', 'Tiene un cuaderno de Bases de Datos adentro', 'mochila_negra.png');
-- 2. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 3. Leer el objeto creado
SELECT o.titulo, o.descripcion, o.ruta_foto, o.detalle_reservado, o.fecha_registro, u.usuario_nick, c.nombre_categoria, e.nombre_estado, s.nombre_sector FROM objetos.objeto_perdido o JOIN seguridad.usuario u ON u.id_usuario = o.id_usuario JOIN objetos.categoria_objeto c ON c.id_categoria_objeto = o.id_categoria_objeto JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto JOIN instalaciones.sector s ON s.id_sector = o.id_sector WHERE o.titulo = 'Mochila de prueba';
-- 4. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log = @l; DELETE FROM objetos.objeto_perdido WHERE titulo = 'Mochila de prueba';

-- ====================================================================================================
-- TC_SP_PUBLICAR_OBJETO_02 · Sin coincidencias: categoría inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. La categoría 'Mascotas' no existe en categoria_objeto.
-- ESPERADO: Paso 2: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí la categoría del objeto.'. No hay error de ejecución de MySQL.
--           Paso 3: sin_cambios = 1.
--           Paso 4: nombre_evento 'Publicación de objeto', usuario_nick 'preceptor1', nombre_resultado 'Fallido'.
-- 1. Contar objetos antes
SELECT COUNT(*) INTO @o0 FROM objetos.objeto_perdido; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_publicar_objeto('preceptor1', 'Mochila azul', NULL, 'Mascotas', 'Patio', NULL, NULL);
-- 3. Verificar que no se creó el objeto
SELECT COUNT(*) = @o0 AS sin_cambios FROM objetos.objeto_perdido;
-- 4. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_PUBLICAR_OBJETO_03 · Parámetros vacíos o NULL: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
-- ESPERADO: Paso 2: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Escribí un título para el objeto.'.
--           Paso 3: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No se encontró el usuario indicado.'.
--           Paso 4: sin_cambios = 1. Se guardan 2 filas de log 'Fallido' (la segunda con usuario NULL).
-- 1. Contar objetos antes
SELECT COUNT(*) INTO @o0 FROM objetos.objeto_perdido; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Título vacío y el resto NULL
CALL sp_publicar_objeto('preceptor1', '', NULL, NULL, NULL, NULL, NULL);
-- 3. Todo NULL, incluido el usuario
CALL sp_publicar_objeto(NULL, NULL, NULL, NULL, NULL, NULL, NULL);
-- 4. Verificar que no se creó ningún objeto
SELECT COUNT(*) = @o0 AS sin_cambios FROM objetos.objeto_perdido;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_PUBLICAR_OBJETO_04 · Equivalencia: el objeto guardado es igual al SELECT directo (texto con espacios y opcionales vacíos)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. Existen preceptor1, la categoría 'Otros' y el sector 'Salón 1'.
--        3. No existe ya un objeto 'Botella térmica'.
-- ESPERADO: Paso 1: estado = 'OK', id_objeto = el id nuevo, mensaje = 'Objeto publicado.'.
--           El SELECT del paso 3 devuelve exactamente la misma fila (9 columnas, mismos valores) que el SELECT directo del paso 4: título sin espacios y descripción, foto y dato reservado en NULL.
-- 1. Ejecutar el procedimiento con espacios y opcionales vacíos
CALL sp_publicar_objeto('preceptor1', '  Botella térmica  ', '', 'Otros', 'Salón 1', '   ', NULL);
-- 2. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 3. Leer el objeto guardado
SELECT o.titulo, o.descripcion, o.ruta_foto, o.detalle_reservado, o.fecha_registro, u.usuario_nick, c.nombre_categoria, e.nombre_estado, s.nombre_sector FROM objetos.objeto_perdido o JOIN seguridad.usuario u ON u.id_usuario = o.id_usuario JOIN objetos.categoria_objeto c ON c.id_categoria_objeto = o.id_categoria_objeto JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto JOIN instalaciones.sector s ON s.id_sector = o.id_sector WHERE o.id_objeto = (SELECT MAX(id_objeto) FROM objetos.objeto_perdido);
-- 4. SELECT directo esperado (se compara con el paso 3)
SELECT 'Botella térmica' AS titulo, NULL AS descripcion, NULL AS ruta_foto, NULL AS detalle_reservado, CURDATE() AS fecha_registro, 'preceptor1' AS usuario_nick, 'Otros' AS nombre_categoria, 'Disponible' AS nombre_estado, 'Salón 1' AS nombre_sector;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log = @l; DELETE FROM objetos.objeto_perdido WHERE titulo = 'Botella térmica';

-- ====================================================================================================
-- TC_SP_RECLAMAR_OBJETO_01 · Éxito: alumno1 reclama la 'Campera azul'
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04.
--        2. El objeto 'Campera azul' está Disponible.
--        3. alumno1 (rol Alumno) todavía no reclamó la 'Campera azul'.
-- ESPERADO: Paso 2: 1 fila: estado = 'OK', id_reclamo = el id nuevo, mensaje = 'Reclamo enviado. El preceptor lo va a revisar.'.
--           Paso 4: 'Es mi campera, tiene un parche en la manga izquierda', fecha de hoy, estado_reclamo 'Pendiente', estado_objeto 'Disponible' (el objeto no cambia de estado hasta que el Preceptor resuelva).
--           Paso 5: descripcion_evento = 'Reclamo sobre el objeto ' + el id del objeto, nombre_evento 'Reclamo de objeto', nombre_entidad 'reclamo_objeto', usuario_nick 'alumno1', nombre_resultado 'Exitoso'.
-- 1. Buscar el id del objeto
SET @obj = (SELECT id_objeto FROM objetos.objeto_perdido WHERE titulo = 'Campera azul');
-- 2. Ejecutar el procedimiento
CALL sp_reclamar_objeto('alumno1', @obj, 'Es mi campera, tiene un parche en la manga izquierda');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el reclamo creado y el estado del objeto
SELECT r.prueba_pertenencia, r.fecha_reclamo, e.nombre_estado AS estado_reclamo, (SELECT es.nombre_estado FROM objetos.objeto_perdido o JOIN objetos.estado_objeto es ON es.id_estado_objeto = o.id_estado_objeto WHERE o.id_objeto = @obj) AS estado_objeto FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo WHERE u.usuario_nick = 'alumno1' AND r.id_objeto = @obj;
-- 5. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log = @l; DELETE FROM objetos.reclamo_objeto WHERE id_objeto = @obj AND id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno1');

-- ====================================================================================================
-- TC_SP_RECLAMAR_OBJETO_02 · Sin coincidencias: id de objeto inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe ningún objeto con id 999999.
-- ESPERADO: Paso 2: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No se encontró el objeto indicado.'. No hay error de ejecución de MySQL.
--           Paso 3: sin_cambios = 1. Se guarda 1 fila de log 'Fallido' (tipo 'Reclamo de objeto', usuario 'alumno1').
-- 1. Contar reclamos antes
SELECT COUNT(*) INTO @r0 FROM objetos.reclamo_objeto; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_reclamar_objeto('alumno1', 999999, 'Detalle de prueba suficientemente largo');
-- 3. Verificar que no se creó el reclamo
SELECT COUNT(*) = @r0 AS sin_cambios FROM objetos.reclamo_objeto;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_RECLAMAR_OBJETO_03 · Parámetros NULL o vacíos: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. El objeto 'Campera azul' existe y alumno1 no la reclamó.
-- ESPERADO: Paso 2: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un objeto de la lista.'.
--           Paso 3: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Contanos un poco más: el detalle necesita 10 caracteres o más.'.
--           Paso 4: sin_cambios = 1. Se guardan 2 filas de log 'Fallido'.
-- 1. Buscar el id y contar reclamos antes
SET @obj = (SELECT id_objeto FROM objetos.objeto_perdido WHERE titulo = 'Campera azul'); SELECT COUNT(*) INTO @r0 FROM objetos.reclamo_objeto; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Objeto y detalle en NULL
CALL sp_reclamar_objeto('alumno1', NULL, NULL);
-- 3. Detalle vacío con un objeto válido
CALL sp_reclamar_objeto('alumno1', @obj, '');
-- 4. Verificar que no se creó ningún reclamo
SELECT COUNT(*) = @r0 AS sin_cambios FROM objetos.reclamo_objeto;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_RECLAMAR_OBJETO_04 · Equivalencia: el reclamo guardado es igual al SELECT directo (detalle con espacios)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. alumno2 (rol Alumno) todavía no reclamó la 'Campera azul'.
-- ESPERADO: Paso 2: estado = 'OK', id_reclamo = el id nuevo, mensaje = 'Reclamo enviado. El preceptor lo va a revisar.'.
--           El SELECT del paso 4 devuelve exactamente la misma fila (5 columnas, mismos valores) que el SELECT directo del paso 5: el detalle se guardó sin los espacios de los costados.
-- 1. Buscar el id del objeto
SET @obj = (SELECT id_objeto FROM objetos.objeto_perdido WHERE titulo = 'Campera azul');
-- 2. Ejecutar el procedimiento con espacios alrededor del detalle
CALL sp_reclamar_objeto('alumno2', @obj, '   Es mi campera, tiene un parche en la manga   ');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el reclamo guardado
SELECT r.prueba_pertenencia, r.fecha_reclamo, u.usuario_nick, o.titulo, e.nombre_estado AS estado_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo WHERE u.usuario_nick = 'alumno2' AND o.id_objeto = @obj;
-- 5. SELECT directo esperado (se compara con el paso 4)
SELECT 'Es mi campera, tiene un parche en la manga' AS prueba_pertenencia, CURDATE() AS fecha_reclamo, 'alumno2' AS usuario_nick, 'Campera azul' AS titulo, 'Pendiente' AS estado_reclamo;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log = @l; DELETE FROM objetos.reclamo_objeto WHERE id_objeto = @obj AND id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno2');

-- ====================================================================================================
-- TC_SP_RESOLVER_RECLAMO_01 · Éxito: preceptor1 aprueba el reclamo de alumno1 sobre las llaves
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04, datos de demostración sin tocar.
--        2. 'Llaves con llavero rojo' está Disponible y tiene 2 reclamos Pendientes (alumno1 y alumno2).
--        3. preceptor1 tiene rol Preceptor.
-- ESPERADO: Paso 2: 1 fila: estado = 'OK', id_reclamo = @rec, resultado = 'Aprobado', mensaje = 'Reclamo aprobado. El objeto figura como Devuelto y los otros reclamos se rechazaron.'.
--           Paso 4: 2 filas: ('alumno1', 'Aprobado') y ('alumno2', 'Rechazado').
--           Paso 5: 'Devuelto'.
--           Paso 6: descripcion_evento = 'Reclamo ' + @rec + ': Aprobado', nombre_evento 'Resolución de reclamo', nombre_entidad 'reclamo_objeto', usuario_nick 'preceptor1', nombre_resultado 'Exitoso'.
-- 1. Buscar el id del reclamo de alumno1
SET @rec = (SELECT r.id_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto WHERE u.usuario_nick = 'alumno1' AND o.titulo = 'Llaves con llavero rojo');
-- 2. Ejecutar el procedimiento (1 = aprobar)
CALL sp_resolver_reclamo('preceptor1', @rec, 1);
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el estado de los reclamos de las llaves
SELECT u.usuario_nick, e.nombre_estado AS estado_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto WHERE o.titulo = 'Llaves con llavero rojo' ORDER BY u.usuario_nick;
-- 5. Leer el estado del objeto
SELECT e.nombre_estado AS estado_objeto FROM objetos.objeto_perdido o JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto WHERE o.titulo = 'Llaves con llavero rojo';
-- 6. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
UPDATE objetos.reclamo_objeto SET id_estado_reclamo = (SELECT id_estado_reclamo FROM objetos.estado_reclamo WHERE nombre_estado = 'Pendiente') WHERE id_objeto = (SELECT id_objeto FROM objetos.objeto_perdido WHERE titulo = 'Llaves con llavero rojo'); UPDATE objetos.objeto_perdido SET id_estado_objeto = (SELECT id_estado_objeto FROM objetos.estado_objeto WHERE nombre_estado = 'Disponible') WHERE titulo = 'Llaves con llavero rojo'; DELETE FROM seguridad.log_auditoria WHERE id_log = @l;

-- ====================================================================================================
-- TC_SP_RESOLVER_RECLAMO_02 · Sin coincidencias: id de reclamo inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe ningún reclamo con id 999999.
-- ESPERADO: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No se encontró el reclamo indicado.'. No hay error de ejecución de MySQL y no cambia ningún reclamo ni objeto.
--           Se guarda 1 fila de log 'Fallido' (tipo 'Resolución de reclamo', usuario 'preceptor1').
-- 1. Anotar el último log antes
SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_resolver_reclamo('preceptor1', 999999, 1);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_RESOLVER_RECLAMO_03 · Parámetros NULL: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01 (estado de las llaves como en la demostración).
-- ESPERADO: Paso 2: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un reclamo de la lista.'.
--           Paso 3: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Indicá si aprobás (1) o rechazás (0) el reclamo.'.
--           Paso 4: ('alumno1', 'Pendiente') y ('alumno2', 'Pendiente'). Se guardan 2 filas de log 'Fallido'.
-- 1. Buscar un reclamo válido y anotar el log
SET @rec = (SELECT r.id_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto WHERE u.usuario_nick = 'alumno1' AND o.titulo = 'Llaves con llavero rojo'); SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Reclamo y acción en NULL
CALL sp_resolver_reclamo('preceptor1', NULL, NULL);
-- 3. Reclamo válido y acción en NULL
CALL sp_resolver_reclamo('preceptor1', @rec, NULL);
-- 4. Verificar que no cambió ningún estado
SELECT u.usuario_nick, e.nombre_estado AS estado_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto WHERE o.titulo = 'Llaves con llavero rojo' ORDER BY u.usuario_nick;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_RESOLVER_RECLAMO_04 · Equivalencia: tras rechazar, los estados son iguales al SELECT directo (el objeto no cambia)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01, con las llaves otra vez Disponibles y los 2 reclamos Pendientes (si se corrió el caso 01, aplicar primero su 'volver atrás').
-- ESPERADO: Paso 2: estado = 'OK', id_reclamo = @rec, resultado = 'Rechazado', mensaje = 'Reclamo rechazado. El objeto sigue en la lista.'.
--           El SELECT del paso 4 devuelve exactamente las mismas 2 filas (mismos valores) que el SELECT directo del paso 5.
--           Paso 6: 'Disponible' (rechazar un reclamo no cambia el objeto mientras quede otro reclamo Pendiente).
-- 1. Buscar el id del reclamo de alumno2
SET @rec = (SELECT r.id_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto WHERE u.usuario_nick = 'alumno2' AND o.titulo = 'Llaves con llavero rojo');
-- 2. Ejecutar el procedimiento (0 = rechazar)
CALL sp_resolver_reclamo('preceptor1', @rec, 0);
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el estado de los reclamos de las llaves
SELECT u.usuario_nick, e.nombre_estado AS estado_reclamo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto WHERE o.titulo = 'Llaves con llavero rojo' ORDER BY u.usuario_nick;
-- 5. SELECT directo esperado (se compara con el paso 4)
SELECT 'alumno1' AS usuario_nick, 'Pendiente' AS estado_reclamo UNION ALL SELECT 'alumno2', 'Rechazado';
-- 6. Leer el estado del objeto
SELECT e.nombre_estado AS estado_objeto FROM objetos.objeto_perdido o JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto WHERE o.titulo = 'Llaves con llavero rojo';
-- VOLVER ATRAS (despues de anotar el resultado):
UPDATE objetos.reclamo_objeto SET id_estado_reclamo = (SELECT id_estado_reclamo FROM objetos.estado_reclamo WHERE nombre_estado = 'Pendiente') WHERE id_objeto = (SELECT id_objeto FROM objetos.objeto_perdido WHERE titulo = 'Llaves con llavero rojo'); UPDATE objetos.objeto_perdido SET id_estado_objeto = (SELECT id_estado_objeto FROM objetos.estado_objeto WHERE nombre_estado = 'Disponible') WHERE titulo = 'Llaves con llavero rojo'; DELETE FROM seguridad.log_auditoria WHERE id_log = @l;

-- ====================================================================================================
-- TC_SP_PRESTAR_EQUIPO_01 · Éxito: profe1 le presta la computadora C4-01 a alumno2
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04, préstamos de demostración sin tocar.
--        2. La computadora C4-01 está Disponible.
--        3. alumno2 no tiene préstamos sin devolver (SELECT COUNT(*) FROM equipos.prestamo_ct p JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario_solicitante WHERE u.usuario_nick = 'alumno2' AND p.hora_devolucion IS NULL; da 0).
-- ESPERADO: Paso 2: 1 fila: estado = 'OK', id_prestamo = el id nuevo, equipo = 'C4-01', mensaje = 'Préstamo registrado.'.
--           Paso 4: 1 fila: fecha de hoy, hora_prestamo con formato HH:MM (la hora actual), hora_devolucion NULL, 'Para la clase de Bases de Datos', 'alumno2', 'profe1'.
--           Paso 5: 'Prestado'.
--           Paso 6: descripcion_evento 'Equipo C4-01 prestado a alumno2', nombre_evento 'Préstamo de recurso', nombre_entidad 'prestamo_ct', usuario_nick 'profe1', nombre_resultado 'Exitoso'.
-- 1. Buscar el id del recurso C4-01
SET @rec = (SELECT r.id_recurso FROM equipos.recursos_ct r JOIN equipos.carro c ON c.id_carro = r.id_carro WHERE c.nombre_carro = 'C4' AND r.numero_equipo = 1);
-- 2. Ejecutar el procedimiento
CALL sp_prestar_equipo('alumno2', 'profe1', @rec, 'Para la clase de Bases de Datos');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el préstamo abierto del equipo
SELECT p.fecha_prestamo, p.hora_prestamo, p.hora_devolucion, p.observaciones, s.usuario_nick AS solicitante, a.usuario_nick AS autorizador FROM equipos.prestamo_ct p JOIN seguridad.usuario s ON s.id_usuario = p.id_usuario_solicitante JOIN seguridad.usuario a ON a.id_usuario = p.id_usuario_autorizador WHERE p.id_recurso = @rec AND p.hora_devolucion IS NULL;
-- 5. Leer el estado del equipo
SELECT e.nombre_estado FROM equipos.recursos_ct r JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = @rec;
-- 6. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM equipos.prestamo_ct WHERE id_recurso = @rec AND hora_devolucion IS NULL; UPDATE equipos.recursos_ct SET id_estado_recurso = (SELECT id_estado_recurso FROM equipos.estado_recurso WHERE nombre_estado = 'Disponible') WHERE id_recurso = @rec; DELETE FROM seguridad.log_auditoria WHERE id_log = @l;

-- ====================================================================================================
-- TC_SP_PRESTAR_EQUIPO_02 · Sin coincidencias: id de recurso inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe ningún recurso con id 999999.
--        3. alumno2 no tiene préstamos sin devolver.
-- ESPERADO: Paso 2: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No se encontró el equipo indicado.'. No hay error de ejecución de MySQL.
--           Paso 3: sin_cambios = 1. Se guarda 1 fila de log 'Fallido' (tipo 'Préstamo de recurso', usuario 'profe1').
-- 1. Contar préstamos antes
SELECT COUNT(*) INTO @p0 FROM equipos.prestamo_ct; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_prestar_equipo('alumno2', 'profe1', 999999, NULL);
-- 3. Verificar que no se creó el préstamo
SELECT COUNT(*) = @p0 AS sin_cambios FROM equipos.prestamo_ct;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_PRESTAR_EQUIPO_03 · Parámetros NULL: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. La computadora C4-01 existe.
-- ESPERADO: Paso 2: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un equipo de la lista de disponibles.'.
--           Paso 3: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí quién se lleva el equipo.'.
--           Paso 4: sin_cambios = 1. Se guardan 2 filas de log 'Fallido'.
-- 1. Buscar el recurso, contar préstamos y anotar el log
SET @rec = (SELECT r.id_recurso FROM equipos.recursos_ct r JOIN equipos.carro c ON c.id_carro = r.id_carro WHERE c.nombre_carro = 'C4' AND r.numero_equipo = 1); SELECT COUNT(*) INTO @p0 FROM equipos.prestamo_ct; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Solicitante, recurso y observaciones en NULL
CALL sp_prestar_equipo(NULL, 'profe1', NULL, NULL);
-- 3. Solicitante NULL con un recurso válido
CALL sp_prestar_equipo(NULL, 'profe1', @rec, NULL);
-- 4. Verificar que no se creó ningún préstamo
SELECT COUNT(*) = @p0 AS sin_cambios FROM equipos.prestamo_ct;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_PRESTAR_EQUIPO_04 · Equivalencia: el préstamo guardado es igual al SELECT directo (C5-01, sin observaciones)
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01 (si se corrió, aplicar antes su 'volver atrás': alumno2 no puede tener otro préstamo abierto).
--        2. La computadora C5-01 está Disponible.
-- ESPERADO: Paso 2: estado = 'OK', id_prestamo = el id nuevo, equipo = 'C5-01', mensaje = 'Préstamo registrado.'.
--           El SELECT del paso 4 devuelve exactamente la misma fila (6 columnas, mismos valores) que el SELECT directo del paso 5.
--           Paso 6: 'Prestado'.
-- 1. Buscar el id del recurso C5-01
SET @rec = (SELECT r.id_recurso FROM equipos.recursos_ct r JOIN equipos.carro c ON c.id_carro = r.id_carro WHERE c.nombre_carro = 'C5' AND r.numero_equipo = 1);
-- 2. Ejecutar el procedimiento sin observaciones
CALL sp_prestar_equipo('alumno2', 'profe1', @rec, NULL);
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el préstamo guardado
SELECT p.id_usuario_solicitante, p.id_usuario_autorizador, p.id_recurso, p.observaciones, p.hora_devolucion, p.fecha_prestamo FROM equipos.prestamo_ct p WHERE p.id_prestamo = (SELECT MAX(id_prestamo) FROM equipos.prestamo_ct);
-- 5. SELECT directo esperado (se compara con el paso 4)
SELECT (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno2') AS id_usuario_solicitante, (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'profe1') AS id_usuario_autorizador, @rec AS id_recurso, NULL AS observaciones, NULL AS hora_devolucion, CURDATE() AS fecha_prestamo;
-- 6. Leer el estado del equipo
SELECT e.nombre_estado FROM equipos.recursos_ct r JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = @rec;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM equipos.prestamo_ct WHERE id_recurso = @rec AND hora_devolucion IS NULL; UPDATE equipos.recursos_ct SET id_estado_recurso = (SELECT id_estado_recurso FROM equipos.estado_recurso WHERE nombre_estado = 'Disponible') WHERE id_recurso = @rec; DELETE FROM seguridad.log_auditoria WHERE id_log = @l;

-- ====================================================================================================
-- TC_SP_DEVOLVER_EQUIPO_01 · Éxito: alumno1 devuelve la C4-05 que funciona
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04, préstamos de demostración sin tocar.
--        2. alumno1 tiene el préstamo de la C4-05 sin devolver (autorizó profe1, sin observaciones) y la C4-05 está Prestado.
-- ESPERADO: Paso 2: 1 fila: estado = 'OK', id_prestamo = @pre, estado_recurso = 'Disponible', mensaje = 'Devolución registrada.'.
--           Paso 4: hora_devolucion con formato HH:MM (la hora actual), observaciones 'Todo bien', estado_equipo 'Disponible'.
--           Paso 5: descripcion_evento = 'Préstamo ' + @pre + ' devuelto, queda: Disponible', nombre_evento 'Devolución de recurso', nombre_entidad 'prestamo_ct', usuario_nick 'alumno1', nombre_resultado 'Exitoso'.
-- 1. Buscar el id del préstamo abierto de alumno1
SET @pre = (SELECT p.id_prestamo FROM equipos.prestamo_ct p JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario_solicitante WHERE u.usuario_nick = 'alumno1' AND p.hora_devolucion IS NULL);
-- 2. Ejecutar el procedimiento (1 = funciona)
CALL sp_devolver_equipo(@pre, 'alumno1', 1, 'Todo bien');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el préstamo y el estado del equipo
SELECT p.hora_devolucion, p.observaciones, e.nombre_estado AS estado_equipo FROM equipos.prestamo_ct p JOIN equipos.recursos_ct r ON r.id_recurso = p.id_recurso JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso WHERE p.id_prestamo = @pre;
-- 5. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
UPDATE equipos.prestamo_ct SET hora_devolucion = NULL, observaciones = NULL WHERE id_prestamo = @pre; UPDATE equipos.recursos_ct SET id_estado_recurso = (SELECT id_estado_recurso FROM equipos.estado_recurso WHERE nombre_estado = 'Prestado') WHERE id_recurso = (SELECT id_recurso FROM equipos.prestamo_ct WHERE id_prestamo = @pre); DELETE FROM seguridad.log_auditoria WHERE id_log = @l;

-- ====================================================================================================
-- TC_SP_DEVOLVER_EQUIPO_02 · Sin coincidencias: id de préstamo inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe ningún préstamo con id 999999.
-- ESPERADO: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No se encontró el préstamo indicado.'. No hay error de ejecución de MySQL y no cambia ningún préstamo ni equipo.
--           Se guarda 1 fila de log 'Fallido' (tipo 'Devolución de recurso', usuario 'alumno1').
-- 1. Anotar el último log antes
SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_devolver_equipo(999999, 'alumno1', 1, NULL);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_DEVOLVER_EQUIPO_03 · Parámetros NULL: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01 (el préstamo de alumno1 sigue abierto).
-- ESPERADO: Paso 2: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un préstamo de la lista.'.
--           Paso 3: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Indicá si el equipo funciona (1) o no funciona (0).'.
--           Paso 4: sigue_abierto = 1. Se guardan 2 filas de log 'Fallido'.
-- 1. Buscar el préstamo abierto y anotar el log
SET @pre = (SELECT p.id_prestamo FROM equipos.prestamo_ct p JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario_solicitante WHERE u.usuario_nick = 'alumno1' AND p.hora_devolucion IS NULL); SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Préstamo y funciona en NULL
CALL sp_devolver_equipo(NULL, 'profe1', NULL, NULL);
-- 3. Préstamo válido y funciona en NULL
CALL sp_devolver_equipo(@pre, 'profe1', NULL, NULL);
-- 4. Verificar que el préstamo sigue abierto
SELECT hora_devolucion IS NULL AS sigue_abierto FROM equipos.prestamo_ct WHERE id_prestamo = @pre;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_DEVOLVER_EQUIPO_04 · Equivalencia: tras devolver como 'no funciona', el resultado es igual al SELECT directo
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01, con el préstamo de alumno1 otra vez abierto (si se corrió el caso 01, aplicar primero su 'volver atrás').
--        2. profe1 tiene rol Profesor.
-- ESPERADO: Paso 2: estado = 'OK', id_prestamo = @pre, estado_recurso = 'Fuera de servicio', mensaje = 'Devolución registrada.'.
--           El SELECT del paso 4 devuelve exactamente la misma fila (3 columnas, mismos valores) que el SELECT directo del paso 5.
-- 1. Buscar el id del préstamo abierto de alumno1
SET @pre = (SELECT p.id_prestamo FROM equipos.prestamo_ct p JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario_solicitante WHERE u.usuario_nick = 'alumno1' AND p.hora_devolucion IS NULL);
-- 2. Ejecutar el procedimiento como profe1 (0 = no funciona)
CALL sp_devolver_equipo(@pre, 'profe1', 0, 'Teclado roto');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer el préstamo y el estado del equipo
SELECT (p.hora_devolucion IS NOT NULL) AS devuelto, p.observaciones, e.nombre_estado AS estado_equipo FROM equipos.prestamo_ct p JOIN equipos.recursos_ct r ON r.id_recurso = p.id_recurso JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso WHERE p.id_prestamo = @pre;
-- 5. SELECT directo esperado (se compara con el paso 4)
SELECT 1 AS devuelto, 'Teclado roto' AS observaciones, 'Fuera de servicio' AS estado_equipo;
-- VOLVER ATRAS (despues de anotar el resultado):
UPDATE equipos.prestamo_ct SET hora_devolucion = NULL, observaciones = NULL WHERE id_prestamo = @pre; UPDATE equipos.recursos_ct SET id_estado_recurso = (SELECT id_estado_recurso FROM equipos.estado_recurso WHERE nombre_estado = 'Prestado') WHERE id_recurso = (SELECT id_recurso FROM equipos.prestamo_ct WHERE id_prestamo = @pre); DELETE FROM seguridad.log_auditoria WHERE id_log = @l;

-- ====================================================================================================
-- TC_SP_RESERVAR_SECTOR_01 · Éxito: profe1 reserva la Biblioteca (queda Pendiente)
-- ====================================================================================================
-- ANTES: 1. Base cargada con 03 y 04.
--        2. La Biblioteca es un sector 'Reservable' y no tiene reservas Pendiente o Aprobada el día de hoy + 30 de 16:00 a 17:00 (lo verifica el paso 1; si da distinto de 0, cambiar el horario).
--        3. profe1 tiene rol Profesor.
-- ESPERADO: Paso 1: 0.
--           Paso 2: 1 fila: estado = 'OK', id_reserva = el id nuevo, estado_reserva = 'Pendiente', mensaje = 'Reserva enviada. Queda pendiente hasta que un preceptor la apruebe.'.
--           Paso 4: fecha_ok = 1, '16:00', '17:00', 'profe1', 'Biblioteca', 'Pendiente', id_usuario_autorizador NULL.
--           Paso 5: descripcion_evento 'Reserva dd/MM de 16:00 a 17:00 (Pendiente)' (dd/MM = la fecha de hoy + 30 días), nombre_evento 'Reserva de sector', nombre_entidad 'reserva_sector', usuario_nick 'profe1', nombre_resultado 'Exitoso'.
-- 1. Verificar que el horario está libre
SELECT COUNT(*) AS debe_dar_0 FROM instalaciones.reserva_sector r JOIN instalaciones.sector s ON s.id_sector = r.id_sector JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva WHERE s.nombre_sector = 'Biblioteca' AND r.fecha_reserva = DATE_ADD(CURDATE(), INTERVAL 30 DAY) AND e.nombre_estado IN ('Pendiente', 'Aprobada') AND r.hora_inicio < '17:00' AND r.hora_fin > '16:00';
-- 2. Ejecutar el procedimiento
CALL sp_reservar_sector('profe1', 'Biblioteca', DATE_ADD(CURDATE(), INTERVAL 30 DAY), '16:00', '17:00');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer la reserva creada
SELECT r.fecha_reserva = DATE_ADD(CURDATE(), INTERVAL 30 DAY) AS fecha_ok, r.hora_inicio, r.hora_fin, u.usuario_nick, s.nombre_sector, e.nombre_estado, r.id_usuario_autorizador FROM instalaciones.reserva_sector r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN instalaciones.sector s ON s.id_sector = r.id_sector JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = (SELECT MAX(id_reserva) FROM instalaciones.reserva_sector);
-- 5. Leer el último registro del log
SELECT l.id_log, l.descripcion_evento, l.direccion_ip, t.nombre_evento, e.nombre_entidad, u.usuario_nick, r.nombre_resultado FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN seguridad.entidad_log e ON e.id_entidad = l.id_entidad JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario WHERE l.id_log = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log = @l; DELETE FROM instalaciones.reserva_sector WHERE id_reserva = (SELECT id_reserva FROM (SELECT MAX(id_reserva) AS id_reserva FROM instalaciones.reserva_sector) t);

-- ====================================================================================================
-- TC_SP_RESERVAR_SECTOR_02 · Sin coincidencias: sector inexistente
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. No existe un sector llamado 'Gimnasio'.
-- ESPERADO: Paso 2: 1 fila: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No se encontró el sector indicado.'. No hay error de ejecución de MySQL.
--           Paso 3: sin_cambios = 1. Se guarda 1 fila de log 'Fallido' (tipo 'Reserva de sector', usuario 'profe1').
-- 1. Contar reservas antes
SELECT COUNT(*) INTO @r0 FROM instalaciones.reserva_sector; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Ejecutar el procedimiento
CALL sp_reservar_sector('profe1', 'Sector inexistente', DATE_ADD(CURDATE(), INTERVAL 30 DAY), '16:00', '17:00');
-- 3. Verificar que no se creó la reserva
SELECT COUNT(*) = @r0 AS sin_cambios FROM instalaciones.reserva_sector;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_RESERVAR_SECTOR_03 · Parámetros NULL o vacíos: error de negocio controlado
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
-- ESPERADO: Paso 2: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un sector para reservar.'.
--           Paso 3: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí la fecha de la reserva.'.
--           Paso 4: estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El horario tiene que estar entre 07:00 y 19:00.'.
--           Paso 5: sin_cambios = 1. Se guardan 3 filas de log 'Fallido'.
-- 1. Contar reservas antes
SELECT COUNT(*) INTO @r0 FROM instalaciones.reserva_sector; SET @l0 = (SELECT COALESCE(MAX(id_log), 0) FROM seguridad.log_auditoria);
-- 2. Sector vacío y el resto NULL
CALL sp_reservar_sector('profe1', '', NULL, NULL, NULL);
-- 3. Sector válido y fecha NULL
CALL sp_reservar_sector('profe1', 'Biblioteca', NULL, NULL, NULL);
-- 4. Sector y fecha válidos y hora de inicio NULL
CALL sp_reservar_sector('profe1', 'Biblioteca', DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, '17:00');
-- 5. Verificar que no se creó ninguna reserva
SELECT COUNT(*) = @r0 AS sin_cambios FROM instalaciones.reserva_sector;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log > @l0;

-- ====================================================================================================
-- TC_SP_RESERVAR_SECTOR_04 · Equivalencia: la reserva del Preceptor (Aprobada, hora '9:00' normalizada) es igual al SELECT directo
-- ====================================================================================================
-- ANTES: 1. Mismo entorno que el caso 01.
--        2. La Biblioteca no tiene reservas Pendiente o Aprobada el día de hoy + 31 de 09:00 a 10:30 (lo verifica el paso 1).
--        3. preceptor1 tiene rol Preceptor.
-- ESPERADO: Paso 1: 0.
--           Paso 2: estado = 'OK', id_reserva = el id nuevo, estado_reserva = 'Aprobada', mensaje = 'Reserva aprobada.'.
--           El SELECT del paso 4 devuelve exactamente la misma fila (7 columnas, mismos valores) que el SELECT directo del paso 5: la hora se guardó como '09:00' y el Preceptor figura como autorizador.
-- 1. Verificar que el horario está libre
SELECT COUNT(*) AS debe_dar_0 FROM instalaciones.reserva_sector r JOIN instalaciones.sector s ON s.id_sector = r.id_sector JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva WHERE s.nombre_sector = 'Biblioteca' AND r.fecha_reserva = DATE_ADD(CURDATE(), INTERVAL 31 DAY) AND e.nombre_estado IN ('Pendiente', 'Aprobada') AND r.hora_inicio < '10:30' AND r.hora_fin > '09:00';
-- 2. Ejecutar el procedimiento con la hora de inicio sin cero adelante
CALL sp_reservar_sector('preceptor1', 'Biblioteca', DATE_ADD(CURDATE(), INTERVAL 31 DAY), '9:00', '10:30');
-- 3. Anotar el id del log generado
SET @l = (SELECT MAX(id_log) FROM seguridad.log_auditoria);
-- 4. Leer la reserva guardada
SELECT r.fecha_reserva, r.hora_inicio, r.hora_fin, u.usuario_nick, s.nombre_sector, e.nombre_estado, a.usuario_nick AS autorizador FROM instalaciones.reserva_sector r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN instalaciones.sector s ON s.id_sector = r.id_sector JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva LEFT JOIN seguridad.usuario a ON a.id_usuario = r.id_usuario_autorizador WHERE r.id_reserva = (SELECT MAX(id_reserva) FROM instalaciones.reserva_sector);
-- 5. SELECT directo esperado (se compara con el paso 4)
SELECT DATE_ADD(CURDATE(), INTERVAL 31 DAY) AS fecha_reserva, '09:00' AS hora_inicio, '10:30' AS hora_fin, 'preceptor1' AS usuario_nick, 'Biblioteca' AS nombre_sector, 'Aprobada' AS nombre_estado, 'preceptor1' AS autorizador;
-- VOLVER ATRAS (despues de anotar el resultado):
DELETE FROM seguridad.log_auditoria WHERE id_log = @l; DELETE FROM instalaciones.reserva_sector WHERE id_reserva = (SELECT id_reserva FROM (SELECT MAX(id_reserva) AS id_reserva FROM instalaciones.reserva_sector) t);

-- ====================================================================================================
-- TC_SP_RESOLVER_RESERVA_SECTOR_01 · Éxito: el Preceptor aprueba una reserva Pendiente
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). La reserva 1 (Biblioteca, de profe1) está en estado Pendiente. preceptor1 tiene rol Preceptor.
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_reserva = 1, estado_reserva = 'Aprobada'. La consulta del paso 2 devuelve nombre_estado = 'Aprobada' y autorizo_preceptor1 = 1. El log muestra: 'Reserva de sector', 'Exitoso', 'Reserva 1: Aprobada', 'preceptor1'.
-- 1. Ejecutar el SP
CALL sp_resolver_reserva_sector(1, 'preceptor1', 'Aprobar');
-- 2. Verificar la reserva en la tabla
SELECT e.nombre_estado, (r.id_usuario_autorizador = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'preceptor1')) AS autorizo_preceptor1
FROM instalaciones.reserva_sector r
JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE r.id_reserva = 1;
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_RESOLVER_RESERVA_SECTOR_02 · Sin coincidencias: reserva inexistente
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe la reserva 99999.
-- ESPERADO: Una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Esa reserva no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra una fila nueva con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_estado_reserva) AS suma_estados FROM instalaciones.reserva_sector;
-- 2. Ejecutar el SP
CALL sp_resolver_reserva_sector(99999, 'preceptor1', 'Aprobar');
-- 3. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_estado_reserva) AS suma_estados FROM instalaciones.reserva_sector;
-- 4. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_RESOLVER_RESERVA_SECTOR_03 · Parámetros NULL o cadenas vacías: error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). 
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Acción inválida: usá Aprobar, Rechazar o Cancelar.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí una reserva de la lista.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 3 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_estado_reserva) AS suma_estados FROM instalaciones.reserva_sector;
-- 2. Ejecutar el SP (llamada 1 de 3)
CALL sp_resolver_reserva_sector(NULL, '', NULL);
-- 3. Ejecutar el SP (llamada 2 de 3)
CALL sp_resolver_reserva_sector(1, NULL, 'Aprobar');
-- 4. Ejecutar el SP (llamada 3 de 3)
CALL sp_resolver_reserva_sector(NULL, 'preceptor1', 'Aprobar');
-- 5. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_estado_reserva) AS suma_estados FROM instalaciones.reserva_sector;
-- 6. Verificar el registro de auditoría (últimas 3 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 3;

-- ====================================================================================================
-- TC_SP_RESOLVER_RESERVA_SECTOR_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo (cancelar una reserva Aprobada)
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). La reserva 4 (Laboratorio 1, de profe1) está en estado Aprobada. preceptor1 puede cancelar reservas de cualquier usuario.
-- ESPERADO: El SP y el SELECT directo devuelven exactamente una fila idéntica: estado = 'OK', id_reserva = 4, estado_reserva = 'Cancelada'. El log muestra 'Reserva de sector', 'Exitoso', 'Reserva 4: Cancelada'.
-- 1. Ejecutar el SP
CALL sp_resolver_reserva_sector(4, 'preceptor1', 'Cancelar');
-- 2. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, r.id_reserva, e.nombre_estado AS estado_reserva
FROM instalaciones.reserva_sector r
JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva
WHERE r.id_reserva = 4;
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_REPORTAR_HIGIENE_01 · Éxito: un alumno reporta una rotura en un sector
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). Existen el sector 'Baño 2' y el tipo 'Rotura'. alumno1 existe.
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_reporte = el valor de SELECT MAX(id_reporte) FROM reporte_higiene. La consulta del paso 2 devuelve: 'La canilla pierde agua', 'Baño 2', 'Rotura', 'Pendiente', 'alumno1', NULL. El log muestra: 'Reporte de higiene', 'Exitoso', 'Reporte en Baño 2', 'alumno1'.
-- 1. Ejecutar el SP
CALL sp_reportar_higiene('alumno1', 'Baño 2', 'Rotura', 'La canilla pierde agua');
-- 2. Verificar el reporte creado
SELECT r.observaciones, s.nombre_sector, t.nombre_tipo, e.nombre_estado, u.usuario_nick, r.fecha_hora_resolucion
FROM instalaciones.reporte_higiene r
JOIN instalaciones.sector s ON s.id_sector = r.id_sector
JOIN instalaciones.tipo_reporte t ON t.id_tipo_reporte = r.id_tipo_reporte
JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte
JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario
WHERE r.id_reporte = (SELECT MAX(id_reporte) FROM instalaciones.reporte_higiene);
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_REPORTAR_HIGIENE_02 · Sin coincidencias: sector y usuario inexistentes
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe el sector 'Sector inexistente' ni el usuario 'usuario_fantasma'.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Ese sector no existe.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 2 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 2. Ejecutar el SP (llamada 1 de 2)
CALL sp_reportar_higiene('alumno1', 'Sector inexistente', 'Rotura', 'Algo roto');
-- 3. Ejecutar el SP (llamada 2 de 2)
CALL sp_reportar_higiene('usuario_fantasma', 'Salón 1', 'Limpieza', 'Hay basura');
-- 4. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 5. Verificar el registro de auditoría (últimas 2 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 2;

-- ====================================================================================================
-- TC_SP_REPORTAR_HIGIENE_03 · Parámetros NULL, vacíos y límite de 200 caracteres: error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). 
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Contanos qué pasa para poder resolverlo.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Contanos qué pasa para poder resolverlo.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un sector para reportar.'. Llamada 4: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un tipo de problema.'. Llamada 5: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'La observación puede tener hasta 200 caracteres.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 5 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 2. Ejecutar el SP (llamada 1 de 5)
CALL sp_reportar_higiene('alumno1', 'Salón 1', 'Limpieza', '   ');
-- 3. Ejecutar el SP (llamada 2 de 5)
CALL sp_reportar_higiene('alumno1', 'Salón 1', 'Limpieza', NULL);
-- 4. Ejecutar el SP (llamada 3 de 5)
CALL sp_reportar_higiene('alumno1', '', 'Limpieza', 'Falta papel');
-- 5. Ejecutar el SP (llamada 4 de 5)
CALL sp_reportar_higiene('alumno1', 'Salón 1', NULL, 'Falta papel');
-- 6. Ejecutar el SP (llamada 5 de 5)
CALL sp_reportar_higiene('alumno1', 'Salón 1', 'Limpieza', REPEAT('a', 201));
-- 7. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 8. Verificar el registro de auditoría (últimas 5 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 5;

-- ====================================================================================================
-- TC_SP_REPORTAR_HIGIENE_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). Existen el sector 'Patio', el tipo 'Limpieza' y el usuario maestranza1 (cualquier rol puede reportar).
-- ESPERADO: El SP y el SELECT directo devuelven exactamente una fila idéntica: estado = 'OK' y el mismo id_reporte. El log muestra 'Reporte de higiene', 'Exitoso', 'Reporte en Patio', 'maestranza1'.
-- 1. Ejecutar el SP
CALL sp_reportar_higiene('maestranza1', 'Patio', 'Limpieza', 'Hay basura en el patio');
-- 2. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, MAX(id_reporte) AS id_reporte FROM instalaciones.reporte_higiene;
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_RESOLVER_REPORTE_HIGIENE_01 · Éxito: Maestranza marca resuelto un reporte Pendiente
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El reporte 1 (Baño 1, de alumno1) está Pendiente. maestranza1 tiene rol Maestranza.
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_reporte = 1. La consulta del paso 2 devuelve: 'Resuelto', 'maestranza1', 1. El log muestra: 'Resolución de reporte', 'Exitoso', 'Reporte 1 resuelto', 'maestranza1'.
-- 1. Ejecutar el SP
CALL sp_resolver_reporte_higiene(1, 'maestranza1');
-- 2. Verificar el reporte en la tabla
SELECT e.nombre_estado, u.usuario_nick AS resolutor, (r.fecha_hora_resolucion IS NOT NULL) AS con_fecha
FROM instalaciones.reporte_higiene r
JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte
LEFT JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario_resolutor
WHERE r.id_reporte = 1;
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_RESOLVER_REPORTE_HIGIENE_02 · Sin coincidencias: reporte y usuario inexistentes
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe el reporte 99999 ni el usuario 'usuario_fantasma'.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Ese reporte no existe.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 2 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 2. Ejecutar el SP (llamada 1 de 2)
CALL sp_resolver_reporte_higiene(99999, 'maestranza1');
-- 3. Ejecutar el SP (llamada 2 de 2)
CALL sp_resolver_reporte_higiene(1, 'usuario_fantasma');
-- 4. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 5. Verificar el registro de auditoría (últimas 2 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 2;

-- ====================================================================================================
-- TC_SP_RESOLVER_REPORTE_HIGIENE_03 · Parámetros NULL, vacíos y límites (rol no permitido, reporte ya resuelto): error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El reporte 2 (Aula) ya está Resuelto en la base de demostración. alumno1 tiene rol Alumno.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un reporte de la lista.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Esta acción es solo para estos roles: Profesor, Preceptor, Maestranza.'. Llamada 4: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Ese reporte ya está resuelto.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 4 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 2. Ejecutar el SP (llamada 1 de 4)
CALL sp_resolver_reporte_higiene(NULL, 'maestranza1');
-- 3. Ejecutar el SP (llamada 2 de 4)
CALL sp_resolver_reporte_higiene(1, '');
-- 4. Ejecutar el SP (llamada 3 de 4)
CALL sp_resolver_reporte_higiene(1, 'alumno1');
-- 5. Ejecutar el SP (llamada 4 de 4)
CALL sp_resolver_reporte_higiene(2, 'maestranza1');
-- 6. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_estado_reporte) AS suma_estados FROM instalaciones.reporte_higiene;
-- 7. Verificar el registro de auditoría (últimas 4 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 4;

-- ====================================================================================================
-- TC_SP_RESOLVER_REPORTE_HIGIENE_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). Se crea un reporte Pendiente nuevo para este caso. profe1 tiene rol Profesor.
-- ESPERADO: El SP (paso 3) y el SELECT directo (paso 4) devuelven exactamente una fila idéntica: estado = 'OK' y id_reporte = @id_nuevo. El log muestra 'Resolución de reporte', 'Exitoso', 'Reporte <id> resuelto', 'profe1'.
-- 1. Crear un reporte Pendiente
CALL sp_reportar_higiene('alumno2', 'Patio', 'Limpieza', 'Prueba de equivalencia');
-- 2. Guardar el id del reporte nuevo
SET @id_nuevo = (SELECT MAX(id_reporte) FROM instalaciones.reporte_higiene);
-- 3. Ejecutar el SP
CALL sp_resolver_reporte_higiene(@id_nuevo, 'profe1');
-- 4. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, id_reporte
FROM instalaciones.reporte_higiene
WHERE id_reporte = @id_nuevo
  AND id_estado_reporte = (SELECT id_estado_reporte FROM instalaciones.estado_reporte WHERE nombre_estado = 'Resuelto')
  AND id_usuario_resolutor = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'profe1');
-- 5. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_COMPRAR_PRODUCTO_01 · Éxito: un alumno reserva 2 unidades de un producto de otro vendedor
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El producto 1 (Alfajor de dulce de leche, $800, vendedor alumno1) tiene stock suficiente (18 en la demo). alumno2 no es el vendedor.
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_venta = el valor de SELECT MAX(id_venta) FROM tienda.venta_buffet, total = 1600. La consulta del paso 3 devuelve: 'Reservada', 'alumno2', 2, 800 y un stock igual al del paso 1 menos 2. El log muestra: 'Reserva de producto', 'Exitoso', 'Venta <id>: producto 1 x2', 'alumno2'.
-- 1. Anotar el stock antes
SELECT stock FROM tienda.producto_buffet WHERE id_producto = 1;
-- 2. Ejecutar el SP
CALL sp_comprar_producto('alumno2', 1, 2);
-- 3. Verificar la venta, el detalle y el stock
SELECT e.nombre_estado, u.usuario_nick AS comprador, d.cantidad, d.precio_unitario, p.stock
FROM tienda.venta_buffet v
JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta
JOIN seguridad.usuario u ON u.id_usuario = v.id_usuario
JOIN tienda.detalle_venta d ON d.id_venta = v.id_venta
JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto
WHERE v.id_venta = (SELECT MAX(id_venta) FROM tienda.venta_buffet);
-- 4. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_COMPRAR_PRODUCTO_02 · Sin coincidencias: producto y usuario inexistentes
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe el producto 99999 ni el usuario 'usuario_fantasma'.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Ese producto ya no existe.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 2 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT (SELECT COUNT(*) FROM tienda.venta_buffet) AS ventas, (SELECT SUM(stock) FROM tienda.producto_buffet) AS stock_total;
-- 2. Ejecutar el SP (llamada 1 de 2)
CALL sp_comprar_producto('alumno2', 99999, 1);
-- 3. Ejecutar el SP (llamada 2 de 2)
CALL sp_comprar_producto('usuario_fantasma', 1, 1);
-- 4. Volver a ejecutar la consulta del primer paso
SELECT (SELECT COUNT(*) FROM tienda.venta_buffet) AS ventas, (SELECT SUM(stock) FROM tienda.producto_buffet) AS stock_total;
-- 5. Verificar el registro de auditoría (últimas 2 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 2;

-- ====================================================================================================
-- TC_SP_COMPRAR_PRODUCTO_03 · Parámetros NULL, cantidad 0 y límites (stock insuficiente, producto propio): error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El producto 4 (Buzo de egresados) es de alumno2 y tiene stock 4. El producto 1 es de alumno1.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'La cantidad tiene que ser 1 o más.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'La cantidad tiene que ser 1 o más.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Elegí un producto de la lista.'. Llamada 4: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No hay stock suficiente: quedan 4 unidades.'. Llamada 5: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No podés reservar tus propios productos.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 5 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT (SELECT COUNT(*) FROM tienda.venta_buffet) AS ventas, (SELECT SUM(stock) FROM tienda.producto_buffet) AS stock_total;
-- 2. Ejecutar el SP (llamada 1 de 5)
CALL sp_comprar_producto('alumno2', 1, NULL);
-- 3. Ejecutar el SP (llamada 2 de 5)
CALL sp_comprar_producto('alumno2', 1, 0);
-- 4. Ejecutar el SP (llamada 3 de 5)
CALL sp_comprar_producto('alumno2', NULL, 1);
-- 5. Ejecutar el SP (llamada 4 de 5)
CALL sp_comprar_producto('alumno1', 4, 5);
-- 6. Ejecutar el SP (llamada 5 de 5)
CALL sp_comprar_producto('alumno1', 1, 1);
-- 7. Volver a ejecutar la consulta del primer paso
SELECT (SELECT COUNT(*) FROM tienda.venta_buffet) AS ventas, (SELECT SUM(stock) FROM tienda.producto_buffet) AS stock_total;
-- 8. Verificar el registro de auditoría (últimas 5 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 5;

-- ====================================================================================================
-- TC_SP_COMPRAR_PRODUCTO_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El producto 3 (Jugo en caja, $700, vendedor alumno2) tiene stock mayor o igual a 1. profe1 no es el vendedor.
-- ESPERADO: El SP y el SELECT directo devuelven exactamente una fila idéntica: estado = 'OK', el mismo id_venta y total = 700. El stock del paso 4 es el del paso 1 menos 1. El log muestra 'Reserva de producto', 'Exitoso', 'Venta <id>: producto 3 x1', 'profe1'.
-- 1. Anotar el stock antes
SELECT stock FROM tienda.producto_buffet WHERE id_producto = 3;
-- 2. Ejecutar el SP
CALL sp_comprar_producto('profe1', 3, 1);
-- 3. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, d.id_venta, d.cantidad * d.precio_unitario AS total
FROM tienda.detalle_venta d
WHERE d.id_venta = (SELECT MAX(id_venta) FROM tienda.venta_buffet);
-- 4. Anotar el stock después
SELECT stock FROM tienda.producto_buffet WHERE id_producto = 3;
-- 5. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_DONAR_GRUPO_01 · Éxito: un alumno dona $500 a un grupo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El grupo 1 (Viaje de Estudios 4to 1ra) existe. alumno1 existe.
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_donacion = el valor de SELECT MAX(id_donacion) FROM tienda.donacion_buffet, monto = 500. La consulta del paso 3 devuelve: 500, 'alumno1', 'Viaje de Estudios 4to 1ra' y donado_ahora = el valor del paso 1 más 500. El log muestra: 'Donación', 'Exitoso', 'Donó $500 al grupo 1', 'alumno1'.
-- 1. Anotar lo donado al grupo antes
SELECT COALESCE(SUM(monto), 0) AS donado FROM tienda.donacion_buffet WHERE id_grupo = 1;
-- 2. Ejecutar el SP
CALL sp_donar_grupo('alumno1', 1, 500);
-- 3. Verificar la donación creada y el total donado
SELECT d.monto, u.usuario_nick, g.nombre_grupo, (SELECT SUM(monto) FROM tienda.donacion_buffet WHERE id_grupo = 1) AS donado_ahora
FROM tienda.donacion_buffet d
JOIN seguridad.usuario u ON u.id_usuario = d.id_usuario
JOIN tienda.grupo_buffet g ON g.id_grupo = d.id_grupo
WHERE d.id_donacion = (SELECT MAX(id_donacion) FROM tienda.donacion_buffet);
-- 4. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_DONAR_GRUPO_02 · Sin coincidencias: grupo y usuario inexistentes
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe el grupo 99999 ni el usuario 'usuario_fantasma'.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Ese grupo no existe.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 2 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(monto) AS suma_montos FROM tienda.donacion_buffet;
-- 2. Ejecutar el SP (llamada 1 de 2)
CALL sp_donar_grupo('alumno1', 99999, 500);
-- 3. Ejecutar el SP (llamada 2 de 2)
CALL sp_donar_grupo('usuario_fantasma', 1, 500);
-- 4. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(monto) AS suma_montos FROM tienda.donacion_buffet;
-- 5. Verificar el registro de auditoría (últimas 2 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 2;

-- ====================================================================================================
-- TC_SP_DONAR_GRUPO_03 · Parámetros NULL, vacíos y monto límite (0 y negativo): error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). 
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Escribí un monto en pesos, mayor a 0 y sin centavos.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Escribí un monto en pesos, mayor a 0 y sin centavos.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Escribí un monto en pesos, mayor a 0 y sin centavos.'. Llamada 4: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Todavía no hay grupos para donar.'. Llamada 5: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 5 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(monto) AS suma_montos FROM tienda.donacion_buffet;
-- 2. Ejecutar el SP (llamada 1 de 5)
CALL sp_donar_grupo('alumno1', 1, 0);
-- 3. Ejecutar el SP (llamada 2 de 5)
CALL sp_donar_grupo('alumno1', 1, -100);
-- 4. Ejecutar el SP (llamada 3 de 5)
CALL sp_donar_grupo('alumno1', 1, NULL);
-- 5. Ejecutar el SP (llamada 4 de 5)
CALL sp_donar_grupo('alumno1', NULL, 500);
-- 6. Ejecutar el SP (llamada 5 de 5)
CALL sp_donar_grupo('', 1, 500);
-- 7. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(monto) AS suma_montos FROM tienda.donacion_buffet;
-- 8. Verificar el registro de auditoría (últimas 5 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 5;

-- ====================================================================================================
-- TC_SP_DONAR_GRUPO_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). El grupo 1 existe. profe1 existe (cualquier rol puede donar).
-- ESPERADO: El SP y el SELECT directo devuelven exactamente una fila idéntica: estado = 'OK', el mismo id_donacion y monto = 1000. El log muestra 'Donación', 'Exitoso', 'Donó $1000 al grupo 1', 'profe1'.
-- 1. Ejecutar el SP
CALL sp_donar_grupo('profe1', 1, 1000);
-- 2. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, id_donacion, monto
FROM tienda.donacion_buffet
WHERE id_donacion = (SELECT MAX(id_donacion) FROM tienda.donacion_buffet);
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_INSCRIBIR_ED_FISICA_01 · Éxito: un alumno se inscribe a una oferta con cupo y sin superposición de horario
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). alumno1 no tiene inscripción a Ed. Física (si un caso anterior la dejó creada, ejecutar antes CALL sp_cancelar_inscripcion_ed_fisica('alumno1');). La oferta 1 (Fútbol, lunes 10:00 a 12:00, cupo 20) tiene cupo y no se superpone con el horario de 4° 1° Computación (curso de alumno1).
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_inscripcion = el valor de SELECT MAX(id_inscripcion) FROM deportes.inscripcion_ed_fisica, id_oferta = 1. La consulta del paso 2 devuelve: 1, 'Fútbol', 1. El log muestra: 'Inscripción a Ed. Física', 'Exitoso', 'Inscripción a la oferta 1', 'alumno1'.
-- 1. Ejecutar el SP
CALL sp_inscribir_ed_fisica('alumno1', 1);
-- 2. Verificar la inscripción
SELECT o.id_oferta, d.nombre_deporte, (i.fecha_inscripcion = CURDATE()) AS es_de_hoy
FROM deportes.inscripcion_ed_fisica i
JOIN deportes.oferta_deporte o ON o.id_oferta = i.id_oferta
JOIN deportes.deporte d ON d.id_deporte = o.id_deporte
WHERE i.id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno1');
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_INSCRIBIR_ED_FISICA_02 · Sin coincidencias: oferta y usuario inexistentes
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe la oferta 99999 ni el usuario 'usuario_fantasma'.
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No hay clase de ese deporte en ese día y horario. Probá con otra combinación.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 2 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 2. Ejecutar el SP (llamada 1 de 2)
CALL sp_inscribir_ed_fisica('alumno1', 99999);
-- 3. Ejecutar el SP (llamada 2 de 2)
CALL sp_inscribir_ed_fisica('usuario_fantasma', 1);
-- 4. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 5. Verificar el registro de auditoría (últimas 2 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 2;

-- ====================================================================================================
-- TC_SP_INSCRIBIR_ED_FISICA_03 · Parámetros NULL, vacíos y límites (rol, ya inscripto, cupo lleno, superposición): error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). alumno1 no tiene inscripción a Ed. Física (si un caso anterior la dejó creada, ejecutar antes CALL sp_cancelar_inscripcion_ed_fisica('alumno1');). alumno2 sigue inscripto a la oferta 16 (Handball, lunes 08:00 a 10:00, cupo 1 de 1; estado inicial de la demo, por eso este caso va antes que TC_SP_CANCELAR_INSCRIPCION_ED_FISICA_01). La oferta 17 es Handball martes 16:00 a 18:00. La oferta 7 (Vóley, martes 14:00 a 16:00) se superpone con una materia del curso de alumno1 (en la demo, Bases de Datos; si hay más de una, el mensaje nombra la primera por orden alfabético, MIN(nombre_materia)).
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No hay clase de ese deporte en ese día y horario. Probá con otra combinación.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Esta acción es solo para estos roles: Alumno.'. Llamada 4: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Ya estás inscripto. Cancelá tu inscripción antes de elegir otra.'. Llamada 5: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Esa opción ya no tiene cupo.'. Llamada 6: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Esa opción se superpone con Bases de Datos en tu horario.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 6 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción. Para la última llamada, el nombre de la materia coincide con el resultado de: SELECT MIN(m.nombre_materia) FROM deportes.oferta_deporte o JOIN academico.franja_horaria f ON f.id_franja = o.id_franja JOIN academico.horario_dia hd ON hd.id_dia = o.id_dia JOIN academico.horario_escolar he ON he.id_bloque = hd.id_bloque JOIN academico.materia m ON m.id_materia = he.id_materia WHERE o.id_oferta = 7 AND he.id_curso = (SELECT id_curso FROM seguridad.usuario WHERE usuario_nick = 'alumno1') AND he.hora_inicio < f.hora_fin AND he.hora_fin > f.hora_inicio;
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 2. Ejecutar el SP (llamada 1 de 6)
CALL sp_inscribir_ed_fisica('alumno1', NULL);
-- 3. Ejecutar el SP (llamada 2 de 6)
CALL sp_inscribir_ed_fisica('', 1);
-- 4. Ejecutar el SP (llamada 3 de 6)
CALL sp_inscribir_ed_fisica('profe1', 1);
-- 5. Ejecutar el SP (llamada 4 de 6)
CALL sp_inscribir_ed_fisica('alumno2', 17);
-- 6. Ejecutar el SP (llamada 5 de 6)
CALL sp_inscribir_ed_fisica('alumno1', 16);
-- 7. Ejecutar el SP (llamada 6 de 6)
CALL sp_inscribir_ed_fisica('alumno1', 7);
-- 8. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 9. Verificar el registro de auditoría (últimas 6 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 6;

-- ====================================================================================================
-- TC_SP_INSCRIBIR_ED_FISICA_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). alumno1 no tiene inscripción a Ed. Física (si un caso anterior la dejó creada, ejecutar antes CALL sp_cancelar_inscripcion_ed_fisica('alumno1');). La oferta 1 tiene cupo y no se superpone con el horario de alumno1.
-- ESPERADO: El SP y el SELECT directo devuelven exactamente una fila idéntica: estado = 'OK', el mismo id_inscripcion e id_oferta = 1. El log muestra 'Inscripción a Ed. Física', 'Exitoso', 'Inscripción a la oferta 1', 'alumno1'.
-- 1. Ejecutar el SP
CALL sp_inscribir_ed_fisica('alumno1', 1);
-- 2. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, i.id_inscripcion, i.id_oferta
FROM deportes.inscripcion_ed_fisica i
WHERE i.id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno1');
-- 3. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_CANCELAR_INSCRIPCION_ED_FISICA_01 · Éxito: un alumno cancela su inscripción
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). alumno2 está inscripto a la oferta 16 (Handball, lunes 08:00 a 10:00, cupo 1 de 1), estado inicial de la demo.
-- ESPERADO: El SP devuelve una fila: estado = 'OK', id_oferta = 16 (el valor del paso 1). La consulta del paso 3 devuelve inscripciones_de_alumno2 = 0 y cupos_libres_oferta_16 = 1. El log muestra: 'Inscripción a Ed. Física', 'Exitoso', 'Inscripción a la oferta 16 cancelada', 'alumno2'.
-- 1. Anotar la oferta de la inscripción antes
SELECT id_oferta FROM deportes.inscripcion_ed_fisica WHERE id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno2');
-- 2. Ejecutar el SP
CALL sp_cancelar_inscripcion_ed_fisica('alumno2');
-- 3. Verificar que no queda inscripción y que el cupo se liberó
SELECT (SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica WHERE id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno2')) AS inscripciones_de_alumno2,
       (SELECT o.cupo_maximo - COUNT(i.id_inscripcion) FROM deportes.oferta_deporte o LEFT JOIN deportes.inscripcion_ed_fisica i ON i.id_oferta = o.id_oferta WHERE o.id_oferta = 16 GROUP BY o.id_oferta, o.cupo_maximo) AS cupos_libres_oferta_16;
-- 4. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_CANCELAR_INSCRIPCION_ED_FISICA_02 · Sin coincidencias: usuario inexistente
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). No existe el usuario 'usuario_fantasma'.
-- ESPERADO: Una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra una fila nueva con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 2. Ejecutar el SP
CALL sp_cancelar_inscripcion_ed_fisica('usuario_fantasma');
-- 3. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 4. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_CANCELAR_INSCRIPCION_ED_FISICA_03 · Parámetros NULL, vacíos y límite (alumno sin inscripción): error de negocio controlado
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). alumno1 no tiene inscripción a Ed. Física (si un caso anterior la dejó creada, ejecutar antes CALL sp_cancelar_inscripcion_ed_fisica('alumno1');). 
-- ESPERADO: Llamada 1: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. Llamada 2: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'El usuario no existe.'. Llamada 3: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'Esta acción es solo para estos roles: Alumno.'. Llamada 4: una fila con estado = 'ERROR', codigo_sql = 1644, descripcion_error = 'No tenés ninguna inscripción para cancelar.'. La consulta del paso final de la tabla devuelve exactamente los mismos valores que antes (no se modificó ningún dato). El log muestra 4 filas nuevas con evento propio del SP, resultado 'Fallido' y el mismo mensaje de error como descripción.
-- 1. Anotar el estado de la tabla antes de llamar
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 2. Ejecutar el SP (llamada 1 de 4)
CALL sp_cancelar_inscripcion_ed_fisica(NULL);
-- 3. Ejecutar el SP (llamada 2 de 4)
CALL sp_cancelar_inscripcion_ed_fisica('');
-- 4. Ejecutar el SP (llamada 3 de 4)
CALL sp_cancelar_inscripcion_ed_fisica('profe1');
-- 5. Ejecutar el SP (llamada 4 de 4)
CALL sp_cancelar_inscripcion_ed_fisica('alumno1');
-- 6. Volver a ejecutar la consulta del primer paso
SELECT COUNT(*) AS filas, SUM(id_oferta) AS suma_ofertas FROM deportes.inscripcion_ed_fisica;
-- 7. Verificar el registro de auditoría (últimas 4 filas)
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 4;

-- ====================================================================================================
-- TC_SP_CANCELAR_INSCRIPCION_ED_FISICA_04 · Equivalencia: el resultado del SP es idéntico a un SELECT directo
-- ====================================================================================================
-- >>> RECARGAR: antes de este caso ejecuta de nuevo 04_DatosSQL_Grupo06.sql completo (Alt+X): deja los datos como recien cargados. <<<
-- ANTES: Base recargada con 04_DatosSQL (datos de demostración) y 05_Backend ejecutado (incluye sp_registrar_log). alumno1 no tiene inscripción a Ed. Física (si un caso anterior la dejó creada, ejecutar antes CALL sp_cancelar_inscripcion_ed_fisica('alumno1');). Este caso primero inscribe a alumno1 a la oferta 1 (sin superposición).
-- ESPERADO: El SP (paso 3) y el SELECT directo (paso 4) devuelven exactamente una fila idéntica: estado = 'OK' e id_oferta = 1. El paso 5 devuelve inscripciones = 0. El log muestra 'Inscripción a Ed. Física', 'Exitoso', 'Inscripción a la oferta 1 cancelada', 'alumno1'.
-- 1. Inscribir a alumno1
CALL sp_inscribir_ed_fisica('alumno1', 1);
-- 2. Guardar la oferta de la inscripción
SET @oferta_antes = (SELECT id_oferta FROM deportes.inscripcion_ed_fisica WHERE id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno1'));
-- 3. Ejecutar el SP
CALL sp_cancelar_inscripcion_ed_fisica('alumno1');
-- 4. Ejecutar el SELECT directo y comparar con el resultado del SP
SELECT 'OK' AS estado, @oferta_antes AS id_oferta;
-- 5. Verificar que ya no hay inscripción
SELECT COUNT(*) AS inscripciones FROM deportes.inscripcion_ed_fisica WHERE id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = 'alumno1');
-- 6. Verificar el registro de auditoría
SELECT t.nombre_evento, r.nombre_resultado, l.descripcion_evento, u.usuario_nick
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
ORDER BY l.id_log DESC LIMIT 1;

-- ====================================================================================================
-- TC_SP_REP_PRESTAMOS_POR_CARRO_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: nombre_carro, total_prestamos, equipos_distintos, sin_devolver, primer_prestamo, ultimo_prestamo, dias_entre_extremos. 2 filas con los datos de la semilla ampliada (62 usuarios); primera fila: nombre_carro=C4, total_prestamos=1, equipos_distintos=1, sin_devolver=1, primer_prestamo=2026-10-23, ultimo_prestamo=2026-10-23, dias_entre_extremos=0. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_prestamos_por_carro('2026-10-22', '2026-10-23');

-- ====================================================================================================
-- TC_SP_REP_PRESTAMOS_POR_CARRO_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_prestamos_por_carro('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_PRESTAMOS_POR_CARRO_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de total_prestamos = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna total_prestamos de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_prestamos_por_carro(NULL, NULL);
SELECT COUNT(*) FROM equipos.prestamo_ct pc JOIN equipos.recursos_ct rc ON rc.id_recurso = pc.id_recurso WHERE rc.id_carro IS NOT NULL;
CALL sp_rep_prestamos_por_carro('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_PRESTAMOS_POR_CARRO_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_prestamos_por_carro('2026-10-22', '2026-10-23');
-- SELECT directo:
SELECT c.nombre_carro,
       COUNT(*) AS total_prestamos,
       COUNT(DISTINCT pc.id_recurso) AS equipos_distintos,
       COUNT(*) - COUNT(pc.hora_devolucion) AS sin_devolver,
       MIN(pc.fecha_prestamo) AS primer_prestamo,
       MAX(pc.fecha_prestamo) AS ultimo_prestamo,
       DATEDIFF(MAX(pc.fecha_prestamo), MIN(pc.fecha_prestamo)) AS dias_entre_extremos
FROM equipos.prestamo_ct pc
JOIN equipos.recursos_ct rc ON rc.id_recurso = pc.id_recurso
JOIN equipos.carro c ON c.id_carro = rc.id_carro
WHERE pc.fecha_prestamo >= '2026-10-22'
  AND pc.fecha_prestamo <= '2026-10-23'
GROUP BY c.id_carro, c.nombre_carro
ORDER BY total_prestamos DESC, c.nombre_carro;

-- ====================================================================================================
-- TC_SP_REP_OBJETOS_POR_CATEGORIA_ESTADO_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: nombre_categoria, nombre_estado, cantidad_objetos, primer_registro, ultimo_registro, dias_desde_el_mas_antiguo. 14 filas con los datos de la semilla ampliada (62 usuarios); primera fila: nombre_categoria=Documentación, nombre_estado=Archivado, cantidad_objetos=1, primer_registro=2026-10-13, ultimo_registro=2026-10-13, dias_desde_el_mas_antiguo = días desde 2026-10-13 hasta el día de la ejecución (cambia con la fecha: el 25/11/2026 da 43). Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_objetos_por_categoria_estado('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_OBJETOS_POR_CATEGORIA_ESTADO_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_objetos_por_categoria_estado('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_OBJETOS_POR_CATEGORIA_ESTADO_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de cantidad_objetos = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna cantidad_objetos de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_objetos_por_categoria_estado(NULL, NULL);
SELECT COUNT(*) FROM objetos.objeto_perdido;
CALL sp_rep_objetos_por_categoria_estado('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_OBJETOS_POR_CATEGORIA_ESTADO_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_objetos_por_categoria_estado('2026-10-01', '2026-10-31');
-- SELECT directo:
SELECT ca.nombre_categoria,
       es.nombre_estado,
       COUNT(*) AS cantidad_objetos,
       MIN(o.fecha_registro) AS primer_registro,
       MAX(o.fecha_registro) AS ultimo_registro,
       DATEDIFF(CURDATE(), MIN(o.fecha_registro)) AS dias_desde_el_mas_antiguo
FROM objetos.objeto_perdido o
JOIN objetos.categoria_objeto ca ON ca.id_categoria_objeto = o.id_categoria_objeto
JOIN objetos.estado_objeto es ON es.id_estado_objeto = o.id_estado_objeto
WHERE o.fecha_registro >= '2026-10-01'
  AND o.fecha_registro <= '2026-10-31'
GROUP BY ca.id_categoria_objeto, ca.nombre_categoria, es.id_estado_objeto, es.nombre_estado
ORDER BY ca.nombre_categoria, es.nombre_estado;

-- ====================================================================================================
-- TC_SP_REP_HIGIENE_POR_SECTOR_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: nombre_sector, nombre_tipo, total_reportes, resueltos, pendientes, primer_reporte, ultimo_reporte, dias_promedio_resolucion. 16 filas con los datos de la semilla ampliada (62 usuarios); primera fila: nombre_sector=Baño 1, nombre_tipo=Limpieza, total_reportes=2, resueltos=0, pendientes=2, primer_reporte=2026-10-21, ultimo_reporte=2026-10-24, dias_promedio_resolucion=NULL. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_higiene_por_sector('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_HIGIENE_POR_SECTOR_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_higiene_por_sector('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_HIGIENE_POR_SECTOR_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de total_reportes = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna total_reportes de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_higiene_por_sector(NULL, NULL);
SELECT COUNT(*) FROM instalaciones.reporte_higiene;
CALL sp_rep_higiene_por_sector('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_HIGIENE_POR_SECTOR_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_higiene_por_sector('2026-10-01', '2026-10-31');
-- SELECT directo:
SELECT s.nombre_sector,
       t.nombre_tipo,
       COUNT(*) AS total_reportes,
       COUNT(h.fecha_hora_resolucion) AS resueltos,
       COUNT(*) - COUNT(h.fecha_hora_resolucion) AS pendientes,
       MIN(DATE(h.fecha_hora)) AS primer_reporte,
       MAX(DATE(h.fecha_hora)) AS ultimo_reporte,
       ROUND(AVG(DATEDIFF(h.fecha_hora_resolucion, h.fecha_hora)), 1) AS dias_promedio_resolucion
FROM instalaciones.reporte_higiene h
JOIN instalaciones.sector s ON s.id_sector = h.id_sector
JOIN instalaciones.tipo_reporte t ON t.id_tipo_reporte = h.id_tipo_reporte
WHERE h.fecha_hora >= '2026-10-01'
  AND h.fecha_hora < DATE_ADD('2026-10-31', INTERVAL 1 DAY)
GROUP BY s.id_sector, s.nombre_sector, t.id_tipo_reporte, t.nombre_tipo
ORDER BY pendientes DESC, total_reportes DESC, s.nombre_sector, t.nombre_tipo;

-- ====================================================================================================
-- TC_SP_REP_OCUPACION_SECTORES_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: nombre_sector, nombre_tipo, nombre_estado, cantidad_reservas, dias_con_reservas, horas_reservadas, primera_fecha, ultima_fecha. 4 filas con los datos de la semilla ampliada (62 usuarios); primera fila: nombre_sector=Biblioteca, nombre_tipo=Reservable, nombre_estado=Cancelada, cantidad_reservas=1, dias_con_reservas=1, horas_reservadas=1.00, primera_fecha=2026-11-19, ultima_fecha=2026-11-19. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_ocupacion_sectores(CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 DAY));

-- ====================================================================================================
-- TC_SP_REP_OCUPACION_SECTORES_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_ocupacion_sectores('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_OCUPACION_SECTORES_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de cantidad_reservas = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna cantidad_reservas de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_ocupacion_sectores(NULL, NULL);
SELECT COUNT(*) FROM instalaciones.reserva_sector;
CALL sp_rep_ocupacion_sectores('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_OCUPACION_SECTORES_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_ocupacion_sectores(CURDATE(), DATE_ADD(CURDATE(), INTERVAL 2 DAY));
-- SELECT directo:
SELECT s.nombre_sector,
       ts.nombre_tipo,
       es.nombre_estado,
       COUNT(*) AS cantidad_reservas,
       COUNT(DISTINCT r.fecha_reserva) AS dias_con_reservas,
       ROUND(SUM(TIME_TO_SEC(r.hora_fin) - TIME_TO_SEC(r.hora_inicio)) / 3600, 2) AS horas_reservadas,
       MIN(r.fecha_reserva) AS primera_fecha,
       MAX(r.fecha_reserva) AS ultima_fecha
FROM instalaciones.reserva_sector r
JOIN instalaciones.sector s ON s.id_sector = r.id_sector
JOIN instalaciones.tipo_sector ts ON ts.id_tipo_sector = s.id_tipo_sector
JOIN instalaciones.estado_reserva es ON es.id_estado_reserva = r.id_estado_reserva
WHERE r.fecha_reserva >= CURDATE()
  AND r.fecha_reserva <= DATE_ADD(CURDATE(), INTERVAL 2 DAY)
GROUP BY s.id_sector, s.nombre_sector, ts.id_tipo_sector, ts.nombre_tipo, es.id_estado_reserva, es.nombre_estado
ORDER BY s.nombre_sector, es.nombre_estado;

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: id_producto, nombre_producto, nombre_categoria, unidades_vendidas, cantidad_ventas, monto_total, primera_venta, ultima_venta. 10 filas con los datos de la semilla ampliada (62 usuarios); primera fila: id_producto=30, nombre_producto=Buzo personalizado, nombre_categoria=Ropa, unidades_vendidas=2, cantidad_ventas=1, monto_total=28000, primera_venta=2026-10-27, ultima_venta=2026-10-27. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_ventas_por_producto('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_ventas_por_producto('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de monto_total = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna monto_total de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_ventas_por_producto(NULL, NULL);
SELECT SUM(d.cantidad * d.precio_unitario) FROM tienda.detalle_venta d JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE e.nombre_estado = 'Entregada';
CALL sp_rep_ventas_por_producto('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_ventas_por_producto('2026-10-01', '2026-10-31');
-- SELECT directo:
SELECT p.id_producto,
       p.nombre_producto,
       cp.nombre_categoria,
       SUM(d.cantidad) AS unidades_vendidas,
       COUNT(*) AS cantidad_ventas,
       SUM(d.cantidad * d.precio_unitario) AS monto_total,
       MIN(DATE(v.fecha_hora)) AS primera_venta,
       MAX(DATE(v.fecha_hora)) AS ultima_venta
FROM tienda.detalle_venta d
JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta
JOIN tienda.estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto
JOIN tienda.categoria_producto cp ON cp.id_categoria_producto = p.id_categoria_producto
WHERE ev.nombre_estado = 'Entregada'
  AND v.fecha_hora >= '2026-10-01'
  AND v.fecha_hora < DATE_ADD('2026-10-31', INTERVAL 1 DAY)
GROUP BY p.id_producto, p.nombre_producto, cp.nombre_categoria
ORDER BY monto_total DESC, p.nombre_producto, p.id_producto;

-- ====================================================================================================
-- TC_SP_REP_RECAUDADO_POR_GRUPO_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: nombre_grupo, meta_monto, donaciones, ventas_entregadas, recaudado, porcentaje_meta, cantidad_movimientos, ultimo_movimiento. 14 filas con los datos de la semilla ampliada (62 usuarios); primera fila: nombre_grupo=Viaje de Estudios 5to 1ra Óptica, meta_monto=80000, donaciones=5000, ventas_entregadas=1800, recaudado=6800, porcentaje_meta=8.5, cantidad_movimientos=2, ultimo_movimiento=2026-10-28. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_recaudado_por_grupo('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_RECAUDADO_POR_GRUPO_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_recaudado_por_grupo('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_RECAUDADO_POR_GRUPO_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de recaudado = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna recaudado de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_recaudado_por_grupo(NULL, NULL);
SELECT (SELECT COALESCE(SUM(dn.monto), 0) FROM tienda.donacion_buffet dn) + (SELECT COALESCE(SUM(d.cantidad * d.precio_unitario), 0) FROM tienda.detalle_venta d JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto WHERE e.nombre_estado = 'Entregada' AND p.id_grupo IS NOT NULL);
CALL sp_rep_recaudado_por_grupo('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_RECAUDADO_POR_GRUPO_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_recaudado_por_grupo('2026-10-01', '2026-10-31');
-- SELECT directo:
SELECT g.nombre_grupo,
       g.meta_monto,
       SUM(m.donacion) AS donaciones,
       SUM(m.venta) AS ventas_entregadas,
       SUM(m.donacion) + SUM(m.venta) AS recaudado,
       ROUND((SUM(m.donacion) + SUM(m.venta)) * 100 / g.meta_monto, 1) AS porcentaje_meta,
       COUNT(*) AS cantidad_movimientos,
       MAX(DATE(m.fecha_hora)) AS ultimo_movimiento
FROM tienda.grupo_buffet g
JOIN (SELECT dn.id_grupo, dn.monto AS donacion, 0 AS venta, dn.fecha_hora
      FROM tienda.donacion_buffet dn
      UNION ALL
      SELECT pb.id_grupo, 0, d.cantidad * d.precio_unitario, v.fecha_hora
      FROM tienda.detalle_venta d
      JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta
      JOIN tienda.estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
      JOIN tienda.producto_buffet pb ON pb.id_producto = d.id_producto
      WHERE ev.nombre_estado = 'Entregada' AND pb.id_grupo IS NOT NULL) m
  ON m.id_grupo = g.id_grupo
WHERE m.fecha_hora >= '2026-10-01'
  AND m.fecha_hora < DATE_ADD('2026-10-31', INTERVAL 1 DAY)
GROUP BY g.id_grupo, g.nombre_grupo, g.meta_monto
ORDER BY recaudado DESC, g.nombre_grupo;

-- ====================================================================================================
-- TC_SP_REP_INSCRIPTOS_POR_DEPORTE_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: nombre_deporte, nombre_dia, hora_inicio, hora_fin, cupo_maximo, inscriptos, cupos_libres, primera_inscripcion, ultima_inscripcion. 13 filas con los datos de la semilla ampliada (62 usuarios); primera fila: nombre_deporte=Vóley, nombre_dia=Miércoles, hora_inicio=10:00, hora_fin=12:00, cupo_maximo=12, inscriptos=3, cupos_libres=9, primera_inscripcion=2026-10-27, ultima_inscripcion=2026-10-28. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_inscriptos_por_deporte('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_INSCRIPTOS_POR_DEPORTE_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_inscriptos_por_deporte('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_INSCRIPTOS_POR_DEPORTE_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de inscriptos = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna inscriptos de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_inscriptos_por_deporte(NULL, NULL);
SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica;
CALL sp_rep_inscriptos_por_deporte('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_INSCRIPTOS_POR_DEPORTE_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_inscriptos_por_deporte('2026-10-01', '2026-10-31');
-- SELECT directo:
SELECT d.nombre_deporte,
       ds.nombre_dia,
       f.hora_inicio,
       f.hora_fin,
       o.cupo_maximo,
       COUNT(*) AS inscriptos,
       o.cupo_maximo - COUNT(*) AS cupos_libres,
       MIN(i.fecha_inscripcion) AS primera_inscripcion,
       MAX(i.fecha_inscripcion) AS ultima_inscripcion
FROM deportes.inscripcion_ed_fisica i
JOIN deportes.oferta_deporte o ON o.id_oferta = i.id_oferta
JOIN deportes.deporte d ON d.id_deporte = o.id_deporte
JOIN academico.dia_semana ds ON ds.id_dia = o.id_dia
JOIN academico.franja_horaria f ON f.id_franja = o.id_franja
WHERE i.fecha_inscripcion >= '2026-10-01'
  AND i.fecha_inscripcion <= '2026-10-31'
GROUP BY o.id_oferta, d.nombre_deporte, ds.id_dia, ds.nombre_dia, f.hora_inicio, f.hora_fin, o.cupo_maximo
ORDER BY inscriptos DESC, d.nombre_deporte, ds.id_dia, f.hora_inicio;

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_01 · Rango válido con datos: devuelve el agrupamiento esperado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04 (los esperados valen para esa semilla; si 04 trae más datos en el rango, usar como esperado el resultado del caso 04).
-- ESPERADO: Columnas, en este orden: usuario_nick, nombre_completo, nombre_rol, prestamos, reservas, reclamos, total_actividad. 29 filas con los datos de la semilla ampliada (62 usuarios); primera fila: usuario_nick=alumno2, nombre_completo=Alumno Dos, nombre_rol=Alumno, prestamos=1, reservas=0, reclamos=2, total_actividad=3. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar filas, columnas y orden
CALL sp_rep_actividad_por_usuario('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_02 · Rango sin coincidencias: 0 filas y sin error de ejecución
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) con las columnas de siempre; no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000 (sin datos)
-- 2. Verificar que no hay fila de error
CALL sp_rep_actividad_por_usuario('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_03 · Parámetros NULL (sin límite): no agrupa de más ni deja datos afuera; rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error, una fila por grupo (nunca una fila por registro). Paso 2: la suma de total_actividad = valor de la consulta de control (ningún registro queda afuera ni se cuenta dos veces). Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar la columna total_actividad de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_actividad_por_usuario(NULL, NULL);
SELECT (SELECT COUNT(*) FROM equipos.prestamo_ct) + (SELECT COUNT(*) FROM instalaciones.reserva_sector) + (SELECT COUNT(*) FROM objetos.reclamo_objeto);
CALL sp_rep_actividad_por_usuario('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo (mismos literales)
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_actividad_por_usuario('2026-10-01', '2026-10-31');
-- SELECT directo:
SELECT u.usuario_nick,
       u.nombre_completo,
       r.nombre_rol,
       COUNT(DISTINCT pr.id_prestamo) AS prestamos,
       COUNT(DISTINCT rs.id_reserva) AS reservas,
       COUNT(DISTINCT ro.id_reclamo) AS reclamos,
       COUNT(DISTINCT pr.id_prestamo) + COUNT(DISTINCT rs.id_reserva) + COUNT(DISTINCT ro.id_reclamo) AS total_actividad
FROM seguridad.usuario u
JOIN seguridad.rol r ON r.id_rol = u.id_rol
LEFT JOIN equipos.prestamo_ct pr ON pr.id_usuario_solicitante = u.id_usuario
      AND pr.fecha_prestamo >= '2026-10-01'
      AND pr.fecha_prestamo <= '2026-10-31'
LEFT JOIN instalaciones.reserva_sector rs ON rs.id_usuario = u.id_usuario
      AND rs.fecha_reserva >= '2026-10-01'
      AND rs.fecha_reserva <= '2026-10-31'
LEFT JOIN objetos.reclamo_objeto ro ON ro.id_usuario = u.id_usuario
      AND ro.fecha_reclamo >= '2026-10-01'
      AND ro.fecha_reclamo <= '2026-10-31'
GROUP BY u.id_usuario, u.usuario_nick, u.nombre_completo, r.nombre_rol
HAVING COUNT(DISTINCT pr.id_prestamo) + COUNT(DISTINCT rs.id_reserva) + COUNT(DISTINCT ro.id_reclamo) > 0
ORDER BY total_actividad DESC, u.usuario_nick;

-- ====================================================================================================
-- TC_SP_REP_AUDITORIA_01 · Rango del día con filtros: devuelve el evento agrupado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04, log_auditoria vacía) y SP creado. Los logs se generan con sp_registrar_log (SP de Arce Thiago y Cabrera Ulises).
-- ESPERADO: 1 fila: fecha = CURDATE(), nombre_evento 'Inicio de sesión', nombre_entidad 'usuario', nombre_resultado 'Exitoso', nick 'alumno1', cantidad_eventos = 2, primera_hora <= ultima_hora, ips_distintas 1. Sin fila de error.
-- 1. Ejecutar 2 veces: CALL sp_registrar_log('Inicio de sesión', 'Inicio de sesión exitoso de alumno1', 'usuario', 'alumno1', 'Exitoso', 'PC-LAB-01');
-- 2. Ejecutar el CALL de TEST DATA
CALL sp_registrar_log('Inicio de sesión', 'Inicio de sesión exitoso de alumno1', 'usuario', 'alumno1', 'Exitoso', 'PC-LAB-01');
CALL sp_rep_auditoria(CURDATE(), CURDATE(), 'Inicio de sesión', 'alumno1', 'Exitoso');
CALL sp_registrar_log('Inicio de sesión', 'Inicio de sesión exitoso de alumno1', 'usuario', 'alumno1', 'Exitoso', 'PC-LAB-01');
CALL sp_rep_auditoria(CURDATE(), CURDATE(), 'Inicio de sesión', 'alumno1', 'Exitoso');

-- ====================================================================================================
-- TC_SP_REP_AUDITORIA_02 · Búsqueda sin coincidencias: evento, usuario y resultado inexistentes
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04, log_auditoria vacía) y SP creado. Los logs se generan con sp_registrar_log (SP de Arce Thiago y Cabrera Ulises).
-- ESPERADO: Las dos llamadas devuelven conjunto vacío (0 filas) y no devuelve fila con estado='ERROR'.
-- 1. Ejecutar CALL con un evento que no existe
-- 2. Ejecutar CALL con un usuario que no existe
-- 3. Verificar que ninguno da error
CALL sp_rep_auditoria(CURDATE(), CURDATE(), 'Evento inexistente', NULL, NULL);
CALL sp_rep_auditoria(CURDATE(), CURDATE(), NULL, 'usuario_que_no_existe', NULL);

-- ====================================================================================================
-- TC_SP_REP_AUDITORIA_03 · Filtros NULL o vacíos = sin filtro; fechas NULL y rango invertido: error controlado
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04, log_auditoria vacía) y SP creado. Los logs se generan con sp_registrar_log (SP de Arce Thiago y Cabrera Ulises). Haber ejecutado antes al menos un SP que registre logs (p. ej. el caso 01).
-- ESPERADO: Pasos 1 y 2: mismo resultado (todas las filas del día, sin filtrar), sin fila de error. Paso 3: la suma de cantidad_eventos = valor de control. Paso 4: UNA fila estado='ERROR', codigo_sql=1644, descripcion_error='El rango de fechas es obligatorio: desde y hasta no pueden ser NULL'. Paso 5: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con los 3 filtros en NULL
-- 2. Ejecutar CALL con los 3 filtros en cadena vacía ('')
-- 3. Sumar cantidad_eventos del paso 1 y compararla con la consulta de control
-- 4. Ejecutar CALL con p_desde NULL
-- 5. Ejecutar CALL con rango invertido (desde > hasta)
CALL sp_rep_auditoria(CURDATE(), CURDATE(), NULL, NULL, NULL);
CALL sp_rep_auditoria(CURDATE(), CURDATE(), '', '', '');
SELECT COUNT(*) FROM seguridad.log_auditoria WHERE fecha_hora >= CURDATE() AND fecha_hora < DATE_ADD(CURDATE(), INTERVAL 1 DAY);
CALL sp_rep_auditoria(NULL, CURDATE(), NULL, NULL, NULL);
CALL sp_rep_auditoria('2026-10-31', '2026-10-01', NULL, NULL, NULL);

-- ====================================================================================================
-- TC_SP_REP_AUDITORIA_04 · Equivalencia: el SP devuelve lo mismo que un SELECT directo
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04, log_auditoria vacía) y SP creado. Los logs se generan con sp_registrar_log (SP de Arce Thiago y Cabrera Ulises). Haber ejecutado el caso 01.
-- ESPERADO: Idénticas filas, columnas, valores y orden en ambos resultados.
-- 1. Ejecutar el CALL
-- 2. Ejecutar el SELECT directo
-- 3. Comparar fila a fila y valor a valor
CALL sp_rep_auditoria(CURDATE(), CURDATE(), 'Inicio de sesión', 'alumno1', 'Exitoso');
-- SELECT directo:
SELECT DATE(l.fecha_hora) AS fecha,
       t.nombre_evento,
       en.nombre_entidad,
       rl.nombre_resultado,
       COALESCE(u.usuario_nick, '(sin usuario)') AS nick,
       COUNT(*) AS cantidad_eventos,
       MIN(TIME(l.fecha_hora)) AS primera_hora,
       MAX(TIME(l.fecha_hora)) AS ultima_hora,
       COUNT(DISTINCT l.direccion_ip) AS ips_distintas
FROM seguridad.log_auditoria l
JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log
JOIN seguridad.entidad_log en ON en.id_entidad = l.id_entidad
JOIN seguridad.resultado_log rl ON rl.id_resultado = l.id_resultado
LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario
WHERE l.fecha_hora >= CURDATE()
  AND l.fecha_hora < DATE_ADD(CURDATE(), INTERVAL 1 DAY)
  AND t.nombre_evento = 'Inicio de sesión'
  AND u.usuario_nick = 'alumno1'
  AND rl.nombre_resultado = 'Exitoso'
GROUP BY DATE(l.fecha_hora), t.id_tipo_log, t.nombre_evento, en.id_entidad, en.nombre_entidad,
         rl.id_resultado, rl.nombre_resultado, u.id_usuario, u.usuario_nick
ORDER BY fecha, t.nombre_evento, rl.nombre_resultado, nick;

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_TUNEADO_01 · Rango válido con datos: mismo resultado esperado que el original
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04.
-- ESPERADO: Columnas, en este orden: id_producto, nombre_producto, nombre_categoria, unidades_vendidas, cantidad_ventas, monto_total, primera_venta, ultima_venta. 10 filas con los datos de la semilla ampliada (62 usuarios); primera fila: id_producto=30, nombre_producto=Buzo personalizado, nombre_categoria=Ropa, unidades_vendidas=2, cantidad_ventas=1, monto_total=28000, primera_venta=2026-10-27, ultima_venta=2026-10-27. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'. Mismo resultado que el SP original.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar con lo esperado
CALL sp_rep_ventas_por_producto_tuneado('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_TUNEADO_02 · Rango sin coincidencias: 0 filas y sin error
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) y no devuelve fila con estado='ERROR'. El SELECT a tmp_ventas_entregadas da error 1146 (la tabla temporal se borra al terminar).
-- 1. Ejecutar el CALL con un rango en el año 2000
-- 2. Verificar que no hay fila de error
-- 3. En el de ventas, verificar además que la tabla temporal no queda creada
CALL sp_rep_ventas_por_producto_tuneado('2000-01-01', '2000-01-31');
-- debe fallar con 'table doesn't exist':
SELECT * FROM tmp_ventas_entregadas;

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_TUNEADO_03 · Parámetros NULL (sin límite) y rango invertido
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error. Paso 2: la suma de monto_total = valor de control. Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar monto_total de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_ventas_por_producto_tuneado(NULL, NULL);
SELECT SUM(d.cantidad * d.precio_unitario) FROM tienda.detalle_venta d JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE e.nombre_estado = 'Entregada';
CALL sp_rep_ventas_por_producto_tuneado('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_VENTAS_POR_PRODUCTO_TUNEADO_04 · Equivalencia con el SP original: mismas filas, columnas y orden
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Original y tuneado creados.
-- ESPERADO: Resultados idénticos en cantidad de filas, nombres y orden de columnas, valores y orden de filas. Los dos devuelven conjunto vacío con el rango sin datos.
-- 1. Ejecutar el CALL del original
-- 2. Ejecutar el CALL del tuneado con los mismos parámetros
-- 3. Comparar fila a fila y valor a valor
-- 4. Repetir con (NULL, NULL) y con un rango sin datos
CALL sp_rep_ventas_por_producto('2026-10-01', '2026-10-31');
CALL sp_rep_ventas_por_producto_tuneado('2026-10-01', '2026-10-31');
CALL sp_rep_ventas_por_producto(NULL, NULL);
CALL sp_rep_ventas_por_producto_tuneado(NULL, NULL);

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_TUNEADO_01 · Rango válido con datos: mismo resultado esperado que el original
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Semilla original de 04.
-- ESPERADO: Columnas, en este orden: usuario_nick, nombre_completo, nombre_rol, prestamos, reservas, reclamos, total_actividad. 29 filas con los datos de la semilla ampliada (62 usuarios); primera fila: usuario_nick=alumno2, nombre_completo=Alumno Dos, nombre_rol=Alumno, prestamos=1, reservas=0, reclamos=2, total_actividad=3. Los totales se verificaron con una consulta directa a las tablas. Sin fila estado='ERROR'. Mismo resultado que el SP original.
-- 1. Ejecutar el CALL de TEST DATA
-- 2. Comparar con lo esperado
CALL sp_rep_actividad_por_usuario_tuneado('2026-10-01', '2026-10-31');

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_TUNEADO_02 · Rango sin coincidencias: 0 filas y sin error
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Conjunto vacío (0 filas) y no devuelve fila con estado='ERROR'.
-- 1. Ejecutar el CALL con un rango en el año 2000
-- 2. Verificar que no hay fila de error
-- 3. En el de ventas, verificar además que la tabla temporal no queda creada
CALL sp_rep_actividad_por_usuario_tuneado('2000-01-01', '2000-01-31');

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_TUNEADO_03 · Parámetros NULL (sin límite) y rango invertido
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql).
-- ESPERADO: Paso 1: sin fila de error. Paso 2: la suma de total_actividad = valor de control. Paso 3: La segunda llamada devuelve UNA fila: estado='ERROR', codigo_sql=1644, descripcion_error='Rango de fechas invalido: desde es mayor que hasta'.
-- 1. Ejecutar CALL con (NULL, NULL)
-- 2. Sumar total_actividad de todas las filas y compararla con la consulta de control
-- 3. Ejecutar CALL con rango invertido
CALL sp_rep_actividad_por_usuario_tuneado(NULL, NULL);
SELECT (SELECT COUNT(*) FROM equipos.prestamo_ct) + (SELECT COUNT(*) FROM instalaciones.reserva_sector) + (SELECT COUNT(*) FROM objetos.reclamo_objeto);
CALL sp_rep_actividad_por_usuario_tuneado('2026-10-31', '2026-10-01');

-- ====================================================================================================
-- TC_SP_REP_ACTIVIDAD_POR_USUARIO_TUNEADO_04 · Equivalencia con el SP original: mismas filas, columnas y orden
-- ====================================================================================================
-- ANTES: Base iqual cargada (03 + 04) y SP creado (05_Backend_Grupo06.sql). Original y tuneado creados.
-- ESPERADO: Resultados idénticos en cantidad de filas, nombres y orden de columnas, valores y orden de filas. Los dos devuelven conjunto vacío con el rango sin datos.
-- 1. Ejecutar el CALL del original
-- 2. Ejecutar el CALL del tuneado con los mismos parámetros
-- 3. Comparar fila a fila y valor a valor
-- 4. Repetir con (NULL, NULL) y con un rango sin datos
CALL sp_rep_actividad_por_usuario('2026-10-01', '2026-10-31');
CALL sp_rep_actividad_por_usuario_tuneado('2026-10-01', '2026-10-31');
CALL sp_rep_actividad_por_usuario(NULL, NULL);
CALL sp_rep_actividad_por_usuario_tuneado(NULL, NULL);

