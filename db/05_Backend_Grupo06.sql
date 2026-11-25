-- 05_Backend_Grupo06.sql - PROYECTO IQUAL (SGE) - Stored Procedures: funcionalidades (1 a 15), reportes, auditoria y tuneados
-- Orden: funcionalidades 1 a 8, funcionalidades 9 a 15 y reportes. Re-ejecutable. Ejecutar completo (Alt+X en DBeaver).

-- PROYECTO IQUAL (SGE) - 05a Backend: funcionalidades 1 a 8 (MySQL 8 / MariaDB 10.11)
-- Re-ejecutable: cada procedimiento se borra y se vuelve a crear.
-- En DBeaver o Workbench ejecutar el script completo (Alt+X) para que respete el DELIMITER.
-- Convención de log: cada SP llama a sp_registrar_log para dejar su evento en log_auditoria.
-- sp_registrar_log solo inserta el registro (no devuelve filas, salvo la de ERROR si algo falla).

USE iqual;
SET NAMES utf8mb4;

-- 1. sp_registrar_log: inserta un evento en log_auditoria con la fecha y hora actual.
--    Busca tipo de evento, entidad y resultado por nombre. Si el usuario es NULL o no existe, id_usuario queda en NULL.
--    Si p_ip viene vacía se guarda el host del cliente que ejecuta el CALL.
DROP PROCEDURE IF EXISTS sp_registrar_log;

DELIMITER //
CREATE PROCEDURE sp_registrar_log(
    p_evento VARCHAR(80),
    p_descripcion VARCHAR(500),
    p_entidad VARCHAR(50),
    p_nick VARCHAR(50),
    p_resultado VARCHAR(30),
    p_ip VARCHAR(80))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_id_tipo INT DEFAULT NULL;
    DECLARE v_id_entidad INT DEFAULT NULL;
    DECLARE v_id_resultado INT DEFAULT NULL;
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_descripcion VARCHAR(200) DEFAULT '';
    DECLARE v_ip VARCHAR(80) DEFAULT '';

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_descripcion = LEFT(TRIM(COALESCE(p_descripcion, '')), 200);
    IF v_descripcion = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción del evento es obligatoria.';
    END IF;

    SELECT id_tipo_log INTO v_id_tipo FROM seguridad.tipo_log WHERE nombre_evento = TRIM(COALESCE(p_evento, ''));
    IF v_id_tipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de evento no existe en el catálogo.';
    END IF;

    SELECT id_entidad INTO v_id_entidad FROM seguridad.entidad_log WHERE nombre_entidad = TRIM(COALESCE(p_entidad, ''));
    IF v_id_entidad IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La entidad no existe en el catálogo.';
    END IF;

    SELECT id_resultado INTO v_id_resultado FROM seguridad.resultado_log WHERE nombre_resultado = TRIM(COALESCE(p_resultado, ''));
    IF v_id_resultado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El resultado no existe en el catálogo.';
    END IF;

    SELECT id_usuario INTO v_id_usuario FROM seguridad.usuario WHERE usuario_nick = TRIM(COALESCE(p_nick, ''));

    SET v_ip = LEFT(TRIM(COALESCE(p_ip, '')), 80);
    IF v_ip = '' THEN
        SET v_ip = SUBSTRING_INDEX(USER(), '@', -1);
    END IF;

    INSERT INTO seguridad.log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado)
    VALUES (NOW(), v_ip, v_descripcion, v_id_entidad, v_id_usuario, v_id_tipo, v_id_resultado);
END //

DELIMITER ;

-- Auxiliar: dice si un texto tiene solo dígitos y una cantidad de caracteres entre p_min y p_max (reemplaza al control con toLongLong de la app).
DROP PROCEDURE IF EXISTS sp_aux_solo_digitos;

DELIMITER //
CREATE PROCEDURE sp_aux_solo_digitos(p_texto VARCHAR(100), p_min INT, p_max INT, OUT p_valido TINYINT)
BEGIN
    DECLARE v_resto VARCHAR(100) DEFAULT '';

    SET v_resto = COALESCE(p_texto, '');
    SET v_resto = REPLACE(v_resto, '0', '');
    SET v_resto = REPLACE(v_resto, '1', '');
    SET v_resto = REPLACE(v_resto, '2', '');
    SET v_resto = REPLACE(v_resto, '3', '');
    SET v_resto = REPLACE(v_resto, '4', '');
    SET v_resto = REPLACE(v_resto, '5', '');
    SET v_resto = REPLACE(v_resto, '6', '');
    SET v_resto = REPLACE(v_resto, '7', '');
    SET v_resto = REPLACE(v_resto, '8', '');
    SET v_resto = REPLACE(v_resto, '9', '');

    SET p_valido = 0;
    IF CHAR_LENGTH(COALESCE(p_texto, '')) BETWEEN p_min AND p_max AND v_resto = '' THEN
        SET p_valido = 1;
    END IF;
END //

DELIMITER ;

-- 2. sp_registrar_usuario: alta de usuario con las validaciones del registro de la app.
--    p_hash es el SHA-256 de la clave en hexadecimal (64 caracteres). Si el rol es Alumno se busca el curso (año, división, especialidad) y, si no existe, se crea.
--    Para los demás roles el curso queda en NULL y se ignoran año, división y especialidad.
DROP PROCEDURE IF EXISTS sp_registrar_usuario;

DELIMITER //
CREATE PROCEDURE sp_registrar_usuario(
    p_dni VARCHAR(20),
    p_nombre VARCHAR(100),
    p_nick VARCHAR(50),
    p_hash VARCHAR(100),
    p_email VARCHAR(100),
    p_telefono VARCHAR(30),
    p_rol VARCHAR(30),
    p_anio INT,
    p_division INT,
    p_especialidad VARCHAR(50))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_dni VARCHAR(20) DEFAULT '';
    DECLARE v_nombre VARCHAR(100) DEFAULT '';
    DECLARE v_nick VARCHAR(50) DEFAULT '';
    DECLARE v_hash VARCHAR(100) DEFAULT '';
    DECLARE v_email VARCHAR(100) DEFAULT '';
    DECLARE v_telefono VARCHAR(30) DEFAULT '';
    DECLARE v_valido TINYINT DEFAULT 0;
    DECLARE v_id_rol INT DEFAULT NULL;
    DECLARE v_nombre_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_anio INT DEFAULT NULL;
    DECLARE v_id_division INT DEFAULT NULL;
    DECLARE v_id_especialidad INT DEFAULT NULL;
    DECLARE v_id_curso INT DEFAULT NULL;
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_id_usuario INT DEFAULT 0;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Registro de usuario', mensaje_error, 'usuario', NULL, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_dni = TRIM(COALESCE(p_dni, ''));
    SET v_nombre = TRIM(COALESCE(p_nombre, ''));
    SET v_nick = LOWER(TRIM(COALESCE(p_nick, '')));
    SET v_hash = TRIM(COALESCE(p_hash, ''));
    SET v_email = TRIM(COALESCE(p_email, ''));
    SET v_telefono = TRIM(COALESCE(p_telefono, ''));

    IF LOCATE(' ', v_nombre) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Escribí tu nombre y apellido separados por un espacio.';
    END IF;
    IF CHAR_LENGTH(v_nombre) > 80 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre no puede pasar de 80 caracteres.';
    END IF;
    IF CHAR_LENGTH(v_nick) < 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario tiene que tener al menos 3 caracteres.';
    END IF;
    IF CHAR_LENGTH(v_nick) > 50 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no puede pasar de 50 caracteres.';
    END IF;
    IF CHAR_LENGTH(v_hash) <> 64 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña tiene que llegar cifrada (SHA-256, 64 caracteres).';
    END IF;

    CALL sp_aux_solo_digitos(v_dni, 7, 8, v_valido);
    IF v_valido = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI tiene que tener 7 u 8 números, sin puntos.';
    END IF;
    IF CAST(v_dni AS UNSIGNED) < 1000000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El DNI tiene que tener 7 u 8 números, sin puntos.';
    END IF;

    IF LOCATE('@', v_email) = 0 OR LOCATE('.', v_email) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo tiene que llevar un @ y un punto.';
    END IF;
    IF CHAR_LENGTH(v_email) > 80 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El correo no puede pasar de 80 caracteres.';
    END IF;

    CALL sp_aux_solo_digitos(v_telefono, 8, 15, v_valido);
    IF v_valido = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El teléfono tiene que tener entre 8 y 15 números.';
    END IF;

    SELECT id_rol, nombre_rol INTO v_id_rol, v_nombre_rol FROM seguridad.rol WHERE nombre_rol = TRIM(COALESCE(p_rol, ''));
    IF v_id_rol IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un rol válido: Alumno, Profesor, Preceptor o Maestranza.';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_existe FROM seguridad.usuario WHERE LOWER(usuario_nick) = v_nick;
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese usuario ya existe, probá con otro.';
    END IF;
    SELECT COUNT(*) INTO v_existe FROM seguridad.usuario WHERE dni = CAST(v_dni AS UNSIGNED);
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya hay una cuenta con ese DNI.';
    END IF;
    SELECT COUNT(*) INTO v_existe FROM seguridad.usuario WHERE email = v_email;
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya hay una cuenta con ese correo.';
    END IF;

    IF v_nombre_rol = 'Alumno' THEN
        IF p_anio IS NULL OR p_division IS NULL OR TRIM(COALESCE(p_especialidad, '')) = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí el año, la división y la especialidad del curso.';
        END IF;
        SELECT id_anio INTO v_id_anio FROM academico.anio WHERE numero_anio = p_anio;
        IF v_id_anio IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El año elegido no existe.';
        END IF;
        SELECT id_division INTO v_id_division FROM academico.division WHERE numero_division = p_division;
        IF v_id_division IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La división elegida no existe.';
        END IF;
        SELECT id_especialidad INTO v_id_especialidad FROM academico.especialidad WHERE nombre_especialidad = TRIM(p_especialidad);
        IF v_id_especialidad IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La especialidad elegida no existe.';
        END IF;
        SELECT id_curso INTO v_id_curso FROM academico.curso
        WHERE id_anio = v_id_anio AND id_division = v_id_division AND id_especialidad = v_id_especialidad;
        IF v_id_curso IS NULL THEN
            INSERT INTO academico.curso (id_anio, id_division, id_especialidad) VALUES (v_id_anio, v_id_division, v_id_especialidad);
            SET v_id_curso = LAST_INSERT_ID();
        END IF;
    END IF;

    INSERT INTO seguridad.usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso)
    VALUES (CAST(v_dni AS UNSIGNED), v_nombre, v_nick, v_hash, v_email, v_telefono, v_id_rol, v_id_curso);
    SET v_id_usuario = LAST_INSERT_ID();

    CALL sp_registrar_log('Registro de usuario', CONCAT('Se creó la cuenta ', v_nick), 'usuario', v_nick, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_usuario AS id_usuario, 'Cuenta creada. Ya podés iniciar sesión.' AS mensaje;
END //

DELIMITER ;

-- 3. sp_publicar_objeto: alta de un objeto perdido. Solo el Preceptor publica. Estado inicial Disponible, fecha de hoy.
--    Categoría y sector se buscan por nombre. Descripción, dato reservado y foto son opcionales (vacío = NULL).
DROP PROCEDURE IF EXISTS sp_publicar_objeto;

DELIMITER //
CREATE PROCEDURE sp_publicar_objeto(
    p_nick VARCHAR(50),
    p_titulo VARCHAR(200),
    p_descripcion VARCHAR(500),
    p_categoria VARCHAR(50),
    p_sector VARCHAR(80),
    p_detalle_reservado VARCHAR(500),
    p_ruta_foto VARCHAR(300))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_titulo VARCHAR(200) DEFAULT '';
    DECLARE v_descripcion VARCHAR(500) DEFAULT NULL;
    DECLARE v_reservado VARCHAR(500) DEFAULT NULL;
    DECLARE v_foto VARCHAR(300) DEFAULT NULL;
    DECLARE v_id_categoria INT DEFAULT NULL;
    DECLARE v_id_sector INT DEFAULT NULL;
    DECLARE v_id_estado INT DEFAULT NULL;
    DECLARE v_id_objeto INT DEFAULT 0;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Publicación de objeto', mensaje_error, 'objeto_perdido', p_nick, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SELECT u.id_usuario, r.nombre_rol INTO v_id_usuario, v_rol
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick, ''));
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el usuario indicado.';
    END IF;
    IF v_rol <> 'Preceptor' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Preceptor.';
    END IF;

    SET v_titulo = TRIM(COALESCE(p_titulo, ''));
    IF v_titulo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Escribí un título para el objeto.';
    END IF;
    IF CHAR_LENGTH(v_titulo) > 80 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El título no puede pasar de 80 caracteres.';
    END IF;

    SELECT id_categoria_objeto INTO v_id_categoria FROM objetos.categoria_objeto WHERE nombre_categoria = TRIM(COALESCE(p_categoria, ''));
    IF v_id_categoria IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí la categoría del objeto.';
    END IF;

    SELECT id_sector INTO v_id_sector FROM instalaciones.sector WHERE nombre_sector = TRIM(COALESCE(p_sector, ''));
    IF v_id_sector IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí el sector donde lo encontraron.';
    END IF;

    SET v_descripcion = NULLIF(TRIM(COALESCE(p_descripcion, '')), '');
    SET v_reservado = NULLIF(TRIM(COALESCE(p_detalle_reservado, '')), '');
    SET v_foto = NULLIF(TRIM(COALESCE(p_ruta_foto, '')), '');
    IF CHAR_LENGTH(COALESCE(v_descripcion, '')) > 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción no puede pasar de 200 caracteres.';
    END IF;
    IF CHAR_LENGTH(COALESCE(v_reservado, '')) > 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El dato reservado no puede pasar de 200 caracteres.';
    END IF;
    IF CHAR_LENGTH(COALESCE(v_foto, '')) > 150 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre de la foto no puede pasar de 150 caracteres.';
    END IF;

    SELECT id_estado_objeto INTO v_id_estado FROM objetos.estado_objeto WHERE nombre_estado = 'Disponible';

    START TRANSACTION;

    INSERT INTO objetos.objeto_perdido (titulo, descripcion, ruta_foto, detalle_reservado, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector)
    VALUES (v_titulo, v_descripcion, v_foto, v_reservado, CURDATE(), v_id_usuario, v_id_categoria, v_id_estado, v_id_sector);
    SET v_id_objeto = LAST_INSERT_ID();

    CALL sp_registrar_log('Publicación de objeto', CONCAT('Objeto publicado: ', v_titulo), 'objeto_perdido', p_nick, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_objeto AS id_objeto, 'Objeto publicado.' AS mensaje;
END //

DELIMITER ;

-- 4. sp_reclamar_objeto: alta de un reclamo en estado Pendiente. Solo el Alumno reclama.
--    No se puede reclamar un objeto Devuelto o Archivado, el detalle necesita 10 caracteres o más y se reclama una sola vez por objeto.
DROP PROCEDURE IF EXISTS sp_reclamar_objeto;

DELIMITER //
CREATE PROCEDURE sp_reclamar_objeto(
    p_nick VARCHAR(50),
    p_id_objeto INT,
    p_prueba VARCHAR(500))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_objeto INT DEFAULT NULL;
    DECLARE v_estado_objeto VARCHAR(50) DEFAULT NULL;
    DECLARE v_prueba VARCHAR(500) DEFAULT '';
    DECLARE v_existe INT DEFAULT 0;
    DECLARE v_id_estado INT DEFAULT NULL;
    DECLARE v_id_reclamo INT DEFAULT 0;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Reclamo de objeto', mensaje_error, 'reclamo_objeto', p_nick, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SELECT u.id_usuario, r.nombre_rol INTO v_id_usuario, v_rol
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick, ''));
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el usuario indicado.';
    END IF;
    IF v_rol <> 'Alumno' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Alumno.';
    END IF;

    IF p_id_objeto IS NULL OR p_id_objeto <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un objeto de la lista.';
    END IF;
    SELECT o.id_objeto, e.nombre_estado INTO v_id_objeto, v_estado_objeto
    FROM objetos.objeto_perdido o JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto
    WHERE o.id_objeto = p_id_objeto;
    IF v_id_objeto IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el objeto indicado.';
    END IF;
    IF v_estado_objeto = 'Devuelto' OR v_estado_objeto = 'Archivado' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Este objeto ya no se puede reclamar: se devolvió o se archivó.';
    END IF;

    SET v_prueba = TRIM(COALESCE(p_prueba, ''));
    IF CHAR_LENGTH(v_prueba) < 10 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contanos un poco más: el detalle necesita 10 caracteres o más.';
    END IF;
    IF CHAR_LENGTH(v_prueba) > 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El detalle no puede pasar de 200 caracteres.';
    END IF;

    SELECT COUNT(*) INTO v_existe FROM objetos.reclamo_objeto WHERE id_usuario = v_id_usuario AND id_objeto = v_id_objeto;
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya reclamaste este objeto. Solo se puede reclamar una vez.';
    END IF;

    SELECT id_estado_reclamo INTO v_id_estado FROM objetos.estado_reclamo WHERE nombre_estado = 'Pendiente';

    START TRANSACTION;

    INSERT INTO objetos.reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo)
    VALUES (v_prueba, CURDATE(), v_id_usuario, v_id_objeto, v_id_estado);
    SET v_id_reclamo = LAST_INSERT_ID();

    CALL sp_registrar_log('Reclamo de objeto', CONCAT('Reclamo sobre el objeto ', v_id_objeto), 'reclamo_objeto', p_nick, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_reclamo AS id_reclamo, 'Reclamo enviado. El preceptor lo va a revisar.' AS mensaje;
END //

DELIMITER ;

-- 5. sp_resolver_reclamo: el Preceptor aprueba (p_aprobar = 1) o rechaza (p_aprobar = 0) un reclamo Pendiente.
--    Aprobar: reclamo Aprobado, los otros reclamos Pendientes del objeto pasan a Rechazado y el objeto queda Devuelto.
--    Rechazar: reclamo Rechazado; si el objeto estaba En reclamo y no le quedan reclamos Pendientes, vuelve a Disponible.
DROP PROCEDURE IF EXISTS sp_resolver_reclamo;

DELIMITER //
CREATE PROCEDURE sp_resolver_reclamo(
    p_nick_preceptor VARCHAR(50),
    p_id_reclamo INT,
    p_aprobar TINYINT)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_reclamo INT DEFAULT NULL;
    DECLARE v_id_objeto INT DEFAULT NULL;
    DECLARE v_estado_reclamo VARCHAR(50) DEFAULT NULL;
    DECLARE v_estado_objeto VARCHAR(50) DEFAULT NULL;
    DECLARE v_pendientes INT DEFAULT 0;
    DECLARE v_id_pendiente INT DEFAULT NULL;
    DECLARE v_id_aprobado INT DEFAULT NULL;
    DECLARE v_id_rechazado INT DEFAULT NULL;
    DECLARE v_id_devuelto INT DEFAULT NULL;
    DECLARE v_id_disponible INT DEFAULT NULL;
    DECLARE v_resultado VARCHAR(20) DEFAULT '';
    DECLARE v_texto VARCHAR(120) DEFAULT '';

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Resolución de reclamo', mensaje_error, 'reclamo_objeto', p_nick_preceptor, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SELECT u.id_usuario, r.nombre_rol INTO v_id_usuario, v_rol
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick_preceptor, ''));
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el usuario indicado.';
    END IF;
    IF v_rol <> 'Preceptor' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Preceptor.';
    END IF;

    IF p_id_reclamo IS NULL OR p_id_reclamo <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un reclamo de la lista.';
    END IF;
    IF p_aprobar IS NULL OR p_aprobar NOT IN (0, 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Indicá si aprobás (1) o rechazás (0) el reclamo.';
    END IF;

    START TRANSACTION;

    SELECT r.id_reclamo, r.id_objeto, e.nombre_estado INTO v_id_reclamo, v_id_objeto, v_estado_reclamo
    FROM objetos.reclamo_objeto r JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo
    WHERE r.id_reclamo = p_id_reclamo;
    IF v_id_reclamo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el reclamo indicado.';
    END IF;
    IF v_estado_reclamo <> 'Pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese reclamo ya fue resuelto.';
    END IF;

    SELECT id_estado_reclamo INTO v_id_pendiente FROM objetos.estado_reclamo WHERE nombre_estado = 'Pendiente';
    SELECT id_estado_reclamo INTO v_id_aprobado FROM objetos.estado_reclamo WHERE nombre_estado = 'Aprobado';
    SELECT id_estado_reclamo INTO v_id_rechazado FROM objetos.estado_reclamo WHERE nombre_estado = 'Rechazado';
    SELECT id_estado_objeto INTO v_id_devuelto FROM objetos.estado_objeto WHERE nombre_estado = 'Devuelto';
    SELECT id_estado_objeto INTO v_id_disponible FROM objetos.estado_objeto WHERE nombre_estado = 'Disponible';

    IF p_aprobar = 1 THEN
        SET v_resultado = 'Aprobado';
        UPDATE objetos.reclamo_objeto SET id_estado_reclamo = v_id_aprobado WHERE id_reclamo = v_id_reclamo;
        UPDATE objetos.reclamo_objeto SET id_estado_reclamo = v_id_rechazado
        WHERE id_objeto = v_id_objeto AND id_reclamo <> v_id_reclamo AND id_estado_reclamo = v_id_pendiente;
        UPDATE objetos.objeto_perdido SET id_estado_objeto = v_id_devuelto WHERE id_objeto = v_id_objeto;
        SET v_texto = 'Reclamo aprobado. El objeto figura como Devuelto y los otros reclamos se rechazaron.';
    ELSE
        SET v_resultado = 'Rechazado';
        UPDATE objetos.reclamo_objeto SET id_estado_reclamo = v_id_rechazado WHERE id_reclamo = v_id_reclamo;
        SELECT e.nombre_estado INTO v_estado_objeto
        FROM objetos.objeto_perdido o JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto
        WHERE o.id_objeto = v_id_objeto;
        SELECT COUNT(*) INTO v_pendientes FROM objetos.reclamo_objeto WHERE id_objeto = v_id_objeto AND id_estado_reclamo = v_id_pendiente;
        IF v_estado_objeto = 'En reclamo' AND v_pendientes = 0 THEN
            UPDATE objetos.objeto_perdido SET id_estado_objeto = v_id_disponible WHERE id_objeto = v_id_objeto;
        END IF;
        SET v_texto = 'Reclamo rechazado. El objeto sigue en la lista.';
    END IF;

    CALL sp_registrar_log('Resolución de reclamo', CONCAT('Reclamo ', v_id_reclamo, ': ', v_resultado), 'reclamo_objeto', p_nick_preceptor, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_reclamo AS id_reclamo, v_resultado AS resultado, v_texto AS mensaje;
END //

DELIMITER ;

-- 6. sp_prestar_equipo: registra un préstamo de un recurso Disponible y lo pasa a Prestado.
--    Autoriza un Alumno (solo a su propio nombre), un Profesor o un Preceptor. El solicitante tiene que ser Alumno y no puede tener otro equipo sin devolver.
DROP PROCEDURE IF EXISTS sp_prestar_equipo;

DELIMITER //
CREATE PROCEDURE sp_prestar_equipo(
    p_nick_solicitante VARCHAR(50),
    p_nick_autorizador VARCHAR(50),
    p_id_recurso INT,
    p_observaciones VARCHAR(500))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_id_autorizador INT DEFAULT NULL;
    DECLARE v_rol_autorizador VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_solicitante INT DEFAULT NULL;
    DECLARE v_rol_solicitante VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_recurso INT DEFAULT NULL;
    DECLARE v_estado_recurso VARCHAR(50) DEFAULT NULL;
    DECLARE v_nombre_carro VARCHAR(50) DEFAULT NULL;
    DECLARE v_numero INT DEFAULT 0;
    DECLARE v_codigo_recurso VARCHAR(30) DEFAULT '';
    DECLARE v_abiertos INT DEFAULT 0;
    DECLARE v_observaciones VARCHAR(500) DEFAULT NULL;
    DECLARE v_id_prestado INT DEFAULT NULL;
    DECLARE v_id_prestamo INT DEFAULT 0;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Préstamo de recurso', mensaje_error, 'prestamo_ct', p_nick_autorizador, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SELECT u.id_usuario, r.nombre_rol INTO v_id_autorizador, v_rol_autorizador
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick_autorizador, ''));
    IF v_id_autorizador IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el usuario que autoriza.';
    END IF;
    IF v_rol_autorizador NOT IN ('Alumno', 'Profesor', 'Preceptor') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Alumno, Profesor, Preceptor.';
    END IF;

    IF p_id_recurso IS NULL OR p_id_recurso <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un equipo de la lista de disponibles.';
    END IF;

    SELECT u.id_usuario, r.nombre_rol INTO v_id_solicitante, v_rol_solicitante
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick_solicitante, ''));
    IF v_id_solicitante IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí quién se lleva el equipo.';
    END IF;
    IF v_rol_solicitante <> 'Alumno' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quien se lleva el equipo tiene que ser un alumno.';
    END IF;
    IF v_rol_autorizador = 'Alumno' AND v_id_autorizador <> v_id_solicitante THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un alumno solo puede retirar un equipo a su propio nombre.';
    END IF;

    SELECT COUNT(*) INTO v_abiertos FROM equipos.prestamo_ct WHERE id_usuario_solicitante = v_id_solicitante AND hora_devolucion IS NULL;
    IF v_abiertos > 0 THEN
        IF v_rol_autorizador = 'Alumno' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya tenés un equipo prestado. Devolvelo antes de retirar otro.';
        END IF;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese alumno ya tiene un equipo prestado. Tiene que devolverlo antes de retirar otro.';
    END IF;

    SET v_observaciones = NULLIF(TRIM(COALESCE(p_observaciones, '')), '');
    IF CHAR_LENGTH(COALESCE(v_observaciones, '')) > 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las observaciones no pueden pasar de 200 caracteres.';
    END IF;

    START TRANSACTION;

    SELECT r.id_recurso, e.nombre_estado, c.nombre_carro, r.numero_equipo
    INTO v_id_recurso, v_estado_recurso, v_nombre_carro, v_numero
    FROM equipos.recursos_ct r
    JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso
    LEFT JOIN equipos.carro c ON c.id_carro = r.id_carro
    WHERE r.id_recurso = p_id_recurso;
    IF v_id_recurso IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el equipo indicado.';
    END IF;
    IF v_estado_recurso <> 'Disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese equipo no está disponible.';
    END IF;

    IF v_nombre_carro IS NULL THEN
        SET v_codigo_recurso = CONCAT('Tablero ', LPAD(v_numero, 2, '0'));
    ELSE
        SET v_codigo_recurso = CONCAT(v_nombre_carro, '-', LPAD(v_numero, 2, '0'));
    END IF;

    SELECT id_estado_recurso INTO v_id_prestado FROM equipos.estado_recurso WHERE nombre_estado = 'Prestado';

    INSERT INTO equipos.prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso)
    VALUES (CURDATE(), TIME_FORMAT(CURTIME(), '%H:%i'), NULL, v_observaciones, v_id_solicitante, v_id_autorizador, v_id_recurso);
    SET v_id_prestamo = LAST_INSERT_ID();
    UPDATE equipos.recursos_ct SET id_estado_recurso = v_id_prestado WHERE id_recurso = v_id_recurso;

    CALL sp_registrar_log('Préstamo de recurso', CONCAT('Equipo ', v_codigo_recurso, ' prestado a ', TRIM(p_nick_solicitante)), 'prestamo_ct', p_nick_autorizador, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_prestamo AS id_prestamo, v_codigo_recurso AS equipo, 'Préstamo registrado.' AS mensaje;
END //

DELIMITER ;

-- 7. sp_devolver_equipo: cierra un préstamo activo con la hora actual y deja el recurso Disponible (p_funciona = 1) o Fuera de servicio (p_funciona = 0).
--    Un Alumno solo devuelve sus propios préstamos. Si hay observaciones nuevas se agregan a las anteriores.
DROP PROCEDURE IF EXISTS sp_devolver_equipo;

DELIMITER //
CREATE PROCEDURE sp_devolver_equipo(
    p_id_prestamo INT,
    p_nick_autorizador VARCHAR(50),
    p_funciona TINYINT,
    p_observaciones VARCHAR(500))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_id_autorizador INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_prestamo INT DEFAULT NULL;
    DECLARE v_id_recurso INT DEFAULT NULL;
    DECLARE v_id_solicitante INT DEFAULT NULL;
    DECLARE v_hora_devolucion VARCHAR(5) DEFAULT NULL;
    DECLARE v_anterior VARCHAR(200) DEFAULT NULL;
    DECLARE v_nuevas VARCHAR(500) DEFAULT NULL;
    DECLARE v_final VARCHAR(700) DEFAULT NULL;
    DECLARE v_nuevo_estado VARCHAR(50) DEFAULT '';
    DECLARE v_id_estado INT DEFAULT NULL;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Devolución de recurso', mensaje_error, 'prestamo_ct', p_nick_autorizador, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SELECT u.id_usuario, r.nombre_rol INTO v_id_autorizador, v_rol
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick_autorizador, ''));
    IF v_id_autorizador IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el usuario indicado.';
    END IF;
    IF v_rol NOT IN ('Alumno', 'Profesor', 'Preceptor') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Alumno, Profesor, Preceptor.';
    END IF;

    IF p_id_prestamo IS NULL OR p_id_prestamo <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un préstamo de la lista.';
    END IF;
    IF p_funciona IS NULL OR p_funciona NOT IN (0, 1) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Indicá si el equipo funciona (1) o no funciona (0).';
    END IF;

    START TRANSACTION;

    SELECT id_prestamo, id_recurso, id_usuario_solicitante, hora_devolucion, observaciones
    INTO v_id_prestamo, v_id_recurso, v_id_solicitante, v_hora_devolucion, v_anterior
    FROM equipos.prestamo_ct
    WHERE id_prestamo = p_id_prestamo;
    IF v_id_prestamo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el préstamo indicado.';
    END IF;
    IF v_hora_devolucion IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese préstamo ya fue devuelto.';
    END IF;
    IF v_rol = 'Alumno' AND v_id_solicitante <> v_id_autorizador THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo podés devolver tus propios préstamos.';
    END IF;

    SET v_nuevas = NULLIF(TRIM(COALESCE(p_observaciones, '')), '');
    SET v_final = v_anterior;
    IF v_nuevas IS NOT NULL THEN
        IF v_anterior IS NULL OR v_anterior = '' THEN
            SET v_final = v_nuevas;
        ELSE
            SET v_final = CONCAT(v_anterior, ' / Devolución: ', v_nuevas);
        END IF;
    END IF;
    IF CHAR_LENGTH(COALESCE(v_final, '')) > 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Las observaciones no pueden pasar de 200 caracteres.';
    END IF;

    IF p_funciona = 1 THEN
        SET v_nuevo_estado = 'Disponible';
    ELSE
        SET v_nuevo_estado = 'Fuera de servicio';
    END IF;
    SELECT id_estado_recurso INTO v_id_estado FROM equipos.estado_recurso WHERE nombre_estado = v_nuevo_estado;

    UPDATE equipos.prestamo_ct
    SET hora_devolucion = TIME_FORMAT(CURTIME(), '%H:%i'), observaciones = v_final
    WHERE id_prestamo = v_id_prestamo;
    UPDATE equipos.recursos_ct SET id_estado_recurso = v_id_estado WHERE id_recurso = v_id_recurso;

    CALL sp_registrar_log('Devolución de recurso', CONCAT('Préstamo ', v_id_prestamo, ' devuelto, queda: ', v_nuevo_estado), 'prestamo_ct', p_nick_autorizador, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_prestamo AS id_prestamo, v_nuevo_estado AS estado_recurso, 'Devolución registrada.' AS mensaje;
END //

DELIMITER ;

-- 8. sp_reservar_sector: reserva de un sector Reservable. La hacen el Profesor y el Preceptor.
--    Controla fecha (hoy o futura), hora fin > inicio, horario entre 07:00 y 19:00 y solapamiento con reservas Pendiente o Aprobada del mismo sector y día.
--    El Preceptor queda con la reserva Aprobada y como autorizador; el Profesor la deja Pendiente.
DROP PROCEDURE IF EXISTS sp_reservar_sector;

DELIMITER //
CREATE PROCEDURE sp_reservar_sector(
    p_nick VARCHAR(50),
    p_sector VARCHAR(80),
    p_fecha DATE,
    p_hora_inicio VARCHAR(10),
    p_hora_fin VARCHAR(10))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_apertura VARCHAR(5) DEFAULT '07:00';
    DECLARE v_cierre VARCHAR(5) DEFAULT '19:00';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_id_sector INT DEFAULT NULL;
    DECLARE v_tipo_sector VARCHAR(50) DEFAULT NULL;
    DECLARE v_inicio VARCHAR(5) DEFAULT NULL;
    DECLARE v_fin VARCHAR(5) DEFAULT NULL;
    DECLARE v_ocupa_nombre VARCHAR(80) DEFAULT NULL;
    DECLARE v_ocupa_inicio VARCHAR(5) DEFAULT NULL;
    DECLARE v_ocupa_fin VARCHAR(5) DEFAULT NULL;
    DECLARE v_estado VARCHAR(50) DEFAULT 'Pendiente';
    DECLARE v_id_estado INT DEFAULT NULL;
    DECLARE v_id_pendiente INT DEFAULT NULL;
    DECLARE v_id_aprobada INT DEFAULT NULL;
    DECLARE v_autorizador INT DEFAULT NULL;
    DECLARE v_texto VARCHAR(120) DEFAULT '';
    DECLARE v_id_reserva INT DEFAULT 0;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log('Reserva de sector', mensaje_error, 'reserva_sector', p_nick, 'Fallido', NULL);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SELECT u.id_usuario, r.nombre_rol INTO v_id_usuario, v_rol
    FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol
    WHERE u.usuario_nick = TRIM(COALESCE(p_nick, ''));
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el usuario indicado.';
    END IF;
    IF v_rol NOT IN ('Profesor', 'Preceptor') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Profesor, Preceptor.';
    END IF;

    IF TRIM(COALESCE(p_sector, '')) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un sector para reservar.';
    END IF;
    SELECT s.id_sector, t.nombre_tipo INTO v_id_sector, v_tipo_sector
    FROM instalaciones.sector s JOIN instalaciones.tipo_sector t ON t.id_tipo_sector = s.id_tipo_sector
    WHERE s.nombre_sector = TRIM(p_sector);
    IF v_id_sector IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el sector indicado.';
    END IF;
    IF v_tipo_sector <> 'Reservable' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese sector no se puede reservar.';
    END IF;

    IF p_fecha IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí la fecha de la reserva.';
    END IF;
    IF p_fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede reservar en una fecha que ya pasó.';
    END IF;

    SET v_inicio = TIME_FORMAT(STR_TO_DATE(TRIM(COALESCE(p_hora_inicio, '')), '%H:%i'), '%H:%i');
    SET v_fin = TIME_FORMAT(STR_TO_DATE(TRIM(COALESCE(p_hora_fin, '')), '%H:%i'), '%H:%i');
    IF v_inicio IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora de inicio no es válida. Usá el formato HH:MM.';
    END IF;
    IF v_fin IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora de fin no es válida. Usá el formato HH:MM.';
    END IF;
    IF v_fin <= v_inicio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora de fin tiene que ser después de la de inicio.';
    END IF;
    IF v_inicio < v_apertura OR v_fin > v_cierre THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El horario tiene que estar entre 07:00 y 19:00.';
    END IF;
    IF p_fecha = CURDATE() AND v_inicio < TIME_FORMAT(CURTIME(), '%H:%i') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese horario de inicio ya pasó. Elegí uno más tarde.';
    END IF;

    START TRANSACTION;

    SELECT id_estado_reserva INTO v_id_pendiente FROM instalaciones.estado_reserva WHERE nombre_estado = 'Pendiente';
    SELECT id_estado_reserva INTO v_id_aprobada FROM instalaciones.estado_reserva WHERE nombre_estado = 'Aprobada';

    SELECT u.nombre_completo, r.hora_inicio, r.hora_fin INTO v_ocupa_nombre, v_ocupa_inicio, v_ocupa_fin
    FROM instalaciones.reserva_sector r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario
    WHERE r.id_sector = v_id_sector
      AND r.fecha_reserva = p_fecha
      AND r.id_estado_reserva IN (v_id_pendiente, v_id_aprobada)
      AND r.hora_inicio < v_fin
      AND r.hora_fin > v_inicio
    ORDER BY r.hora_inicio
    LIMIT 1;
    IF v_ocupa_nombre IS NOT NULL THEN
        SET mensaje_error = CONCAT('Ese horario está ocupado: ', v_ocupa_nombre, ' tiene el sector de ', v_ocupa_inicio, ' a ', v_ocupa_fin, '. Probá con otro.');
        SET mensaje_error = LEFT(mensaje_error, 128);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensaje_error;
    END IF;

    SET v_id_estado = v_id_pendiente;
    SET v_texto = 'Reserva enviada. Queda pendiente hasta que un preceptor la apruebe.';
    IF v_rol = 'Preceptor' THEN
        SET v_estado = 'Aprobada';
        SET v_id_estado = v_id_aprobada;
        SET v_autorizador = v_id_usuario;
        SET v_texto = 'Reserva aprobada.';
    END IF;

    INSERT INTO instalaciones.reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador)
    VALUES (p_fecha, v_inicio, v_fin, v_id_usuario, v_id_sector, v_id_estado, v_autorizador);
    SET v_id_reserva = LAST_INSERT_ID();

    CALL sp_registrar_log('Reserva de sector',
        CONCAT('Reserva ', DATE_FORMAT(p_fecha, '%d/%m'), ' de ', v_inicio, ' a ', v_fin, ' (', v_estado, ')'),
        'reserva_sector', p_nick, 'Exitoso', NULL);
    COMMIT;

    SELECT 'OK' AS estado, v_id_reserva AS id_reserva, v_estado AS estado_reserva, v_texto AS mensaje;
END //

DELIMITER ;

-- PROYECTO IQUAL (SGE) - 05c_Backend_funcionalidades_9_a_15.sql
-- Funcionalidades 9 a 15 por Stored Procedures (CONTEXTO_IQUAL.md, seccion 21). MySQL 8 y MariaDB 10.11.
-- Requiere: base iqual cargada (03_ModeloSQL y 04_DatosSQL) y el procedimiento sp_registrar_log (SP 1, Arce Thiago y Cabrera Ulises).
-- Estilo de la clase 006: DELIMITER //, DROP PROCEDURE IF EXISTS, handler de SQLEXCEPTION con GET DIAGNOSTICS.
-- Las reglas de negocio se cortan con SIGNAL SQLSTATE '45000' (equivalente al RAISERROR de la clase 003) y las atrapa el mismo handler.
-- Exito: fila con estado = 'OK' mas el id creado. Error: fila con estado = 'ERROR', codigo_sql y descripcion_error.
-- Cada SP deja un registro en log_auditoria llamando a sp_registrar_log ('Exitoso' al terminar bien, 'Fallido' desde el handler).
-- Se puede ejecutar varias veces: cada procedimiento se borra y se vuelve a crear.
-- En DBeaver ejecutar todo el script con Alt+X para que respete el DELIMITER.

USE iqual;

-- 9. Aprueba, rechaza o cancela una reserva de sector (Aprobar y Rechazar: Preceptor sobre reservas Pendiente; Cancelar: el dueño o un Preceptor)
DROP PROCEDURE IF EXISTS sp_resolver_reserva_sector;

DELIMITER //
CREATE PROCEDURE sp_resolver_reserva_sector(p_id_reserva INT, p_nick_autorizador VARCHAR(50), p_accion VARCHAR(20))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Reserva de sector';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'reserva_sector';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_estado VARCHAR(50) DEFAULT NULL;
    DECLARE v_dueno INT DEFAULT NULL;
    DECLARE v_nuevo VARCHAR(50) DEFAULT NULL;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick_autorizador, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    IF p_accion IS NULL OR p_accion NOT IN ('Aprobar', 'Rechazar', 'Cancelar') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acción inválida: usá Aprobar, Rechazar o Cancelar.';
    END IF;
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick_autorizador);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    SET v_rol = (SELECT r.nombre_rol FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.id_usuario = v_id_usuario);
    IF p_id_reserva IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí una reserva de la lista.';
    END IF;
    SET v_estado = (SELECT e.nombre_estado FROM instalaciones.reserva_sector r JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = p_id_reserva);
    SET v_dueno = (SELECT id_usuario FROM instalaciones.reserva_sector WHERE id_reserva = p_id_reserva);
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa reserva no existe.';
    END IF;

    IF p_accion = 'Cancelar' THEN
        IF v_rol NOT IN ('Profesor', 'Preceptor') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Profesor, Preceptor.';
        END IF;
        IF v_dueno <> v_id_usuario AND v_rol <> 'Preceptor' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo podés cancelar tus propias reservas.';
        END IF;
        IF v_estado NOT IN ('Pendiente', 'Aprobada') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa reserva ya está rechazada o cancelada.';
        END IF;
        SET v_nuevo = 'Cancelada';
        UPDATE instalaciones.reserva_sector
        SET id_estado_reserva = (SELECT id_estado_reserva FROM instalaciones.estado_reserva WHERE nombre_estado = v_nuevo)
        WHERE id_reserva = p_id_reserva;
    ELSE
        IF v_rol NOT IN ('Preceptor') THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Preceptor.';
        END IF;
        IF v_estado <> 'Pendiente' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se pueden aprobar o rechazar reservas pendientes.';
        END IF;
        IF p_accion = 'Aprobar' THEN
            SET v_nuevo = 'Aprobada';
        ELSE
            SET v_nuevo = 'Rechazada';
        END IF;
        UPDATE instalaciones.reserva_sector
        SET id_estado_reserva = (SELECT id_estado_reserva FROM instalaciones.estado_reserva WHERE nombre_estado = v_nuevo),
            id_usuario_autorizador = v_id_usuario
        WHERE id_reserva = p_id_reserva;
    END IF;

    CALL sp_registrar_log(v_evento, CONCAT('Reserva ', p_id_reserva, ': ', v_nuevo), v_entidad, p_nick_autorizador, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, p_id_reserva AS id_reserva, v_nuevo AS estado_reserva;
END //

DELIMITER ;

-- 10. Alta de un reporte de higiene en estado Pendiente (cualquier rol)
DROP PROCEDURE IF EXISTS sp_reportar_higiene;

DELIMITER //
CREATE PROCEDURE sp_reportar_higiene(p_nick VARCHAR(50), p_sector VARCHAR(80), p_tipo VARCHAR(50), p_observaciones VARCHAR(500))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Reporte de higiene';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'reporte_higiene';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_sector INT DEFAULT NULL;
    DECLARE v_tipo INT DEFAULT NULL;
    DECLARE v_id_reporte INT DEFAULT NULL;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    IF p_observaciones IS NULL OR TRIM(p_observaciones) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Contanos qué pasa para poder resolverlo.';
    END IF;
    IF CHAR_LENGTH(TRIM(p_observaciones)) > 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La observación puede tener hasta 200 caracteres.';
    END IF;
    IF p_sector IS NULL OR TRIM(p_sector) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un sector para reportar.';
    END IF;
    IF p_tipo IS NULL OR TRIM(p_tipo) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un tipo de problema.';
    END IF;
    SET v_sector = (SELECT id_sector FROM instalaciones.sector WHERE nombre_sector = p_sector);
    IF v_sector IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese sector no existe.';
    END IF;
    SET v_tipo = (SELECT id_tipo_reporte FROM instalaciones.tipo_reporte WHERE nombre_tipo = p_tipo);
    IF v_tipo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese tipo de reporte no existe.';
    END IF;

    INSERT INTO instalaciones.reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte)
    VALUES (NOW(), TRIM(p_observaciones), v_id_usuario, v_sector, v_tipo,
            (SELECT id_estado_reporte FROM instalaciones.estado_reporte WHERE nombre_estado = 'Pendiente'));
    SET v_id_reporte = LAST_INSERT_ID();

    CALL sp_registrar_log(v_evento, CONCAT('Reporte en ', p_sector), v_entidad, p_nick, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, v_id_reporte AS id_reporte;
END //

DELIMITER ;

-- 11. Marca como Resuelto un reporte Pendiente con fecha, hora y resolutor (Profesor, Preceptor o Maestranza)
DROP PROCEDURE IF EXISTS sp_resolver_reporte_higiene;

DELIMITER //
CREATE PROCEDURE sp_resolver_reporte_higiene(p_id_reporte INT, p_nick_resolutor VARCHAR(50))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Resolución de reporte';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'reporte_higiene';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_estado VARCHAR(50) DEFAULT NULL;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick_resolutor, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    IF p_id_reporte IS NULL OR p_id_reporte < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un reporte de la lista.';
    END IF;
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick_resolutor);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    SET v_rol = (SELECT r.nombre_rol FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.id_usuario = v_id_usuario);
    IF v_rol NOT IN ('Profesor', 'Preceptor', 'Maestranza') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Profesor, Preceptor, Maestranza.';
    END IF;
    SET v_estado = (SELECT e.nombre_estado FROM instalaciones.reporte_higiene r JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte WHERE r.id_reporte = p_id_reporte);
    IF v_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese reporte no existe.';
    END IF;
    IF v_estado <> 'Pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese reporte ya está resuelto.';
    END IF;

    UPDATE instalaciones.reporte_higiene
    SET id_estado_reporte = (SELECT id_estado_reporte FROM instalaciones.estado_reporte WHERE nombre_estado = 'Resuelto'),
        fecha_hora_resolucion = NOW(),
        id_usuario_resolutor = v_id_usuario
    WHERE id_reporte = p_id_reporte;

    CALL sp_registrar_log(v_evento, CONCAT('Reporte ', p_id_reporte, ' resuelto'), v_entidad, p_nick_resolutor, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, p_id_reporte AS id_reporte;
END //

DELIMITER ;

-- 12. Reserva un producto del buffet: crea la venta (Reservada) y su detalle y descuenta el stock; controla stock y que no sea un producto propio
DROP PROCEDURE IF EXISTS sp_comprar_producto;

DELIMITER //
CREATE PROCEDURE sp_comprar_producto(p_nick VARCHAR(50), p_id_producto INT, p_cantidad INT)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Reserva de producto';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'venta_buffet';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_stock INT DEFAULT NULL;
    DECLARE v_precio INT DEFAULT NULL;
    DECLARE v_vendedor INT DEFAULT NULL;
    DECLARE v_id_venta INT DEFAULT NULL;
    DECLARE v_mensaje VARCHAR(255) DEFAULT '';

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        ROLLBACK;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    IF p_id_producto IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Elegí un producto de la lista.';
    END IF;
    IF p_cantidad IS NULL OR p_cantidad < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La cantidad tiene que ser 1 o más.';
    END IF;
    SET v_stock = (SELECT stock FROM tienda.producto_buffet WHERE id_producto = p_id_producto);
    IF v_stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese producto ya no existe.';
    END IF;
    SET v_precio = (SELECT precio FROM tienda.producto_buffet WHERE id_producto = p_id_producto);
    SET v_vendedor = (SELECT id_usuario FROM tienda.producto_buffet WHERE id_producto = p_id_producto);
    IF v_vendedor = v_id_usuario THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No podés reservar tus propios productos.';
    END IF;
    IF p_cantidad > v_stock THEN
        IF v_stock = 1 THEN
            SET v_mensaje = 'No hay stock suficiente: queda 1 unidad.';
        ELSE
            SET v_mensaje = CONCAT('No hay stock suficiente: quedan ', v_stock, ' unidades.');
        END IF;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje;
    END IF;

    START TRANSACTION;
    INSERT INTO tienda.venta_buffet (fecha_hora, id_usuario, id_estado_venta)
    VALUES (NOW(), v_id_usuario, (SELECT id_estado_venta FROM tienda.estado_venta WHERE nombre_estado = 'Reservada'));
    SET v_id_venta = LAST_INSERT_ID();
    INSERT INTO tienda.detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (v_id_venta, p_id_producto, p_cantidad, v_precio);
    UPDATE tienda.producto_buffet SET stock = stock - p_cantidad WHERE id_producto = p_id_producto;
    COMMIT;

    CALL sp_registrar_log(v_evento, CONCAT('Venta ', v_id_venta, ': producto ', p_id_producto, ' x', p_cantidad), v_entidad, p_nick, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, v_id_venta AS id_venta, p_cantidad * v_precio AS total;
END //

DELIMITER ;

-- 13. Alta de una donación a un grupo del buffet (monto entero mayor a 0; cualquier rol)
DROP PROCEDURE IF EXISTS sp_donar_grupo;

DELIMITER //
CREATE PROCEDURE sp_donar_grupo(p_nick VARCHAR(50), p_id_grupo INT, p_monto INT)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Donación';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'donacion_buffet';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_grupo INT DEFAULT NULL;
    DECLARE v_id_donacion INT DEFAULT NULL;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    IF p_id_grupo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Todavía no hay grupos para donar.';
    END IF;
    IF p_monto IS NULL OR p_monto <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Escribí un monto en pesos, mayor a 0 y sin centavos.';
    END IF;
    SET v_grupo = (SELECT id_grupo FROM tienda.grupo_buffet WHERE id_grupo = p_id_grupo);
    IF v_grupo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ese grupo no existe.';
    END IF;

    INSERT INTO tienda.donacion_buffet (monto, fecha_hora, id_usuario, id_grupo)
    VALUES (p_monto, NOW(), v_id_usuario, p_id_grupo);
    SET v_id_donacion = LAST_INSERT_ID();

    CALL sp_registrar_log(v_evento, CONCAT('Donó $', p_monto, ' al grupo ', p_id_grupo), v_entidad, p_nick, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, v_id_donacion AS id_donacion, p_monto AS monto;
END //

DELIMITER ;

-- 14. Inscribe a un alumno a una oferta de Ed. Física si no tiene otra inscripción, hay cupo y no se superpone con el horario de su curso
DROP PROCEDURE IF EXISTS sp_inscribir_ed_fisica;

DELIMITER //
CREATE PROCEDURE sp_inscribir_ed_fisica(p_nick VARCHAR(50), p_id_oferta INT)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Inscripción a Ed. Física';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'inscripcion_ed_fisica';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_cupo INT DEFAULT NULL;
    DECLARE v_curso INT DEFAULT 0;
    DECLARE v_materia VARCHAR(80) DEFAULT NULL;
    DECLARE v_id_inscripcion INT DEFAULT NULL;
    DECLARE v_mensaje VARCHAR(255) DEFAULT '';

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    SET v_rol = (SELECT r.nombre_rol FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.id_usuario = v_id_usuario);
    IF v_rol NOT IN ('Alumno') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Alumno.';
    END IF;
    SET v_cupo = (SELECT cupo_maximo FROM deportes.oferta_deporte WHERE id_oferta = p_id_oferta);
    IF v_cupo IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay clase de ese deporte en ese día y horario. Probá con otra combinación.';
    END IF;
    IF EXISTS (SELECT 1 FROM deportes.inscripcion_ed_fisica WHERE id_usuario = v_id_usuario) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya estás inscripto. Cancelá tu inscripción antes de elegir otra.';
    END IF;
    IF (SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica WHERE id_oferta = p_id_oferta) >= v_cupo THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esa opción ya no tiene cupo.';
    END IF;
    SET v_curso = COALESCE((SELECT id_curso FROM seguridad.usuario WHERE id_usuario = v_id_usuario), 0);
    SET v_materia = (SELECT MIN(m.nombre_materia)
                     FROM deportes.oferta_deporte o
                     JOIN academico.franja_horaria f ON f.id_franja = o.id_franja
                     JOIN academico.horario_dia hd ON hd.id_dia = o.id_dia
                     JOIN academico.horario_escolar he ON he.id_bloque = hd.id_bloque
                     JOIN academico.materia m ON m.id_materia = he.id_materia
                     WHERE o.id_oferta = p_id_oferta
                       AND he.id_curso = v_curso
                       AND he.hora_inicio < f.hora_fin
                       AND he.hora_fin > f.hora_inicio);
    IF v_materia IS NOT NULL THEN
        SET v_mensaje = CONCAT('Esa opción se superpone con ', v_materia, ' en tu horario.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje;
    END IF;

    INSERT INTO deportes.inscripcion_ed_fisica (fecha_inscripcion, id_usuario, id_oferta)
    VALUES (CURDATE(), v_id_usuario, p_id_oferta);
    SET v_id_inscripcion = LAST_INSERT_ID();

    CALL sp_registrar_log(v_evento, CONCAT('Inscripción a la oferta ', p_id_oferta), v_entidad, p_nick, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, v_id_inscripcion AS id_inscripcion, p_id_oferta AS id_oferta;
END //

DELIMITER ;

-- 15. Cancela la inscripción de Ed. Física del alumno
DROP PROCEDURE IF EXISTS sp_cancelar_inscripcion_ed_fisica;

DELIMITER //
CREATE PROCEDURE sp_cancelar_inscripcion_ed_fisica(p_nick VARCHAR(50))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_evento VARCHAR(80) DEFAULT 'Inscripción a Ed. Física';
    DECLARE v_entidad VARCHAR(50) DEFAULT 'inscripcion_ed_fisica';
    DECLARE v_id_usuario INT DEFAULT NULL;
    DECLARE v_rol VARCHAR(30) DEFAULT NULL;
    DECLARE v_oferta INT DEFAULT NULL;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        CALL sp_registrar_log(v_evento, LEFT(mensaje_error, 200), v_entidad, p_nick, 'Fallido', @@hostname);
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    SET v_id_usuario = (SELECT id_usuario FROM seguridad.usuario WHERE usuario_nick = p_nick);
    IF v_id_usuario IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usuario no existe.';
    END IF;
    SET v_rol = (SELECT r.nombre_rol FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.id_usuario = v_id_usuario);
    IF v_rol NOT IN ('Alumno') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esta acción es solo para estos roles: Alumno.';
    END IF;
    SET v_oferta = (SELECT id_oferta FROM deportes.inscripcion_ed_fisica WHERE id_usuario = v_id_usuario);
    IF v_oferta IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No tenés ninguna inscripción para cancelar.';
    END IF;

    DELETE FROM deportes.inscripcion_ed_fisica WHERE id_usuario = v_id_usuario;

    CALL sp_registrar_log(v_evento, CONCAT('Inscripción a la oferta ', v_oferta, ' cancelada'), v_entidad, p_nick, 'Exitoso', @@hostname);
    SELECT 'OK' AS estado, v_oferta AS id_oferta;
END //

DELIMITER ;

-- PROYECTO IQUAL (SGE) - 05b_Backend_reportes.sql (Arce Thiago y Cabrera Ulises, ronda BBDD 14/11/2026)
-- 8 reportes + 1 de auditoria + 2 tuneados (los indices del tuning estan en 03_ModeloSQL). Solo MySQL (compatible con MySQL 8 y MariaDB 10.11).
-- Estilo de la clase 006: DELIMITER //, DROP PROCEDURE IF EXISTS, parametros p_..., EXIT HANDLER con GET DIAGNOSTICS.
-- Todos devuelven su tabla de resultado, o una fila estado='ERROR', codigo_sql, descripcion_error si algo falla.
-- Parametros de fecha: NULL = sin limite de ese lado. Rango invertido (desde > hasta) = ERROR de negocio (codigo_sql 1644).
-- Re-ejecutable: DROP PROCEDURE IF EXISTS en cada SP.
-- En DBeaver hay que ejecutar el archivo como script (Alt+X) para que respete el DELIMITER.
-- Schemas que usa cada reporte: equipos -> prestamos por carro; objetos -> objetos por
-- categoria/estado; instalaciones -> higiene y ocupacion; tienda -> ventas y recaudado; deportes -> inscriptos;
-- seguridad -> actividad por usuario (usa tambien equipos/instalaciones/objetos) y auditoria.

USE iqual;

-- 1. Prestamos de equipos por carro entre dos fechas.
-- Pregunta: que carros se usan mas y cuantos prestamos siguen sin devolverse.
-- GROUP BY por carro; JOIN prestamo -> recurso -> carro; fechas: rango, MIN/MAX y DATEDIFF.
DROP PROCEDURE IF EXISTS sp_rep_prestamos_por_carro;

DELIMITER //
CREATE PROCEDURE sp_rep_prestamos_por_carro(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
    WHERE (p_desde IS NULL OR pc.fecha_prestamo >= p_desde)
      AND (p_hasta IS NULL OR pc.fecha_prestamo <= p_hasta)
    GROUP BY c.id_carro, c.nombre_carro
    ORDER BY total_prestamos DESC, c.nombre_carro;
END //

DELIMITER ;

-- 2. Objetos perdidos por categoria y estado, segun la fecha de registro.
-- Pregunta: cuantos objetos hay de cada categoria en cada estado y cuanto hace que esta el mas antiguo.
-- GROUP BY categoria y estado; JOIN con los dos catalogos; fechas: rango, MIN/MAX y DATEDIFF contra CURDATE().
DROP PROCEDURE IF EXISTS sp_rep_objetos_por_categoria_estado;

DELIMITER //
CREATE PROCEDURE sp_rep_objetos_por_categoria_estado(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

    SELECT ca.nombre_categoria,
           es.nombre_estado,
           COUNT(*) AS cantidad_objetos,
           MIN(o.fecha_registro) AS primer_registro,
           MAX(o.fecha_registro) AS ultimo_registro,
           DATEDIFF(CURDATE(), MIN(o.fecha_registro)) AS dias_desde_el_mas_antiguo
    FROM objetos.objeto_perdido o
    JOIN objetos.categoria_objeto ca ON ca.id_categoria_objeto = o.id_categoria_objeto
    JOIN objetos.estado_objeto es ON es.id_estado_objeto = o.id_estado_objeto
    WHERE (p_desde IS NULL OR o.fecha_registro >= p_desde)
      AND (p_hasta IS NULL OR o.fecha_registro <= p_hasta)
    GROUP BY ca.id_categoria_objeto, ca.nombre_categoria, es.id_estado_objeto, es.nombre_estado
    ORDER BY ca.nombre_categoria, es.nombre_estado;
END //

DELIMITER ;

-- 3. Reportes de higiene por sector y tipo de reporte, segun la fecha del reporte (DATETIME).
-- Pregunta: donde se acumulan los problemas y cuanto tardan en resolverse.
-- GROUP BY sector y tipo; JOIN con sector y tipo_reporte; fechas: rango con dia inclusivo y DATEDIFF entre reporte y resolucion.
-- COUNT(columna) no cuenta los NULL: resueltos = reportes con fecha de resolucion.
DROP PROCEDURE IF EXISTS sp_rep_higiene_por_sector;

DELIMITER //
CREATE PROCEDURE sp_rep_higiene_por_sector(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
    WHERE (p_desde IS NULL OR h.fecha_hora >= p_desde)
      AND (v_hasta_sig IS NULL OR h.fecha_hora < v_hasta_sig)
    GROUP BY s.id_sector, s.nombre_sector, t.id_tipo_reporte, t.nombre_tipo
    ORDER BY pendientes DESC, total_reportes DESC, s.nombre_sector, t.nombre_tipo;
END //

DELIMITER ;

-- 4. Ocupacion de sectores: reservas por sector y estado, segun la fecha reservada.
-- Pregunta: que sectores se reservan mas, cuantas horas y cuantas reservas se cancelaron o rechazaron.
-- GROUP BY sector, tipo y estado; JOIN con sector, tipo_sector y estado_reserva; fechas: rango, MIN/MAX y duracion en horas
-- (las horas se guardan como texto HH:MM; TIME_TO_SEC las pasa a segundos).
DROP PROCEDURE IF EXISTS sp_rep_ocupacion_sectores;

DELIMITER //
CREATE PROCEDURE sp_rep_ocupacion_sectores(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
    WHERE (p_desde IS NULL OR r.fecha_reserva >= p_desde)
      AND (p_hasta IS NULL OR r.fecha_reserva <= p_hasta)
    GROUP BY s.id_sector, s.nombre_sector, ts.id_tipo_sector, ts.nombre_tipo, es.id_estado_reserva, es.nombre_estado
    ORDER BY s.nombre_sector, es.nombre_estado;
END //

DELIMITER ;

-- 5. Ventas del buffet por producto (solo ventas Entregadas), segun la fecha y hora de la venta (DATETIME).
-- Pregunta: que productos venden mas, en unidades y en pesos.
-- GROUP BY producto; JOIN detalle -> venta -> estado, producto y categoria; fechas: rango con dia inclusivo, DATE(), MIN/MAX.
-- Version SIN tuning (reune las 5 tablas y recien despues filtra): la optimizada es sp_rep_ventas_por_producto_tuneado.
DROP PROCEDURE IF EXISTS sp_rep_ventas_por_producto;

DELIMITER //
CREATE PROCEDURE sp_rep_ventas_por_producto(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
      AND (p_desde IS NULL OR v.fecha_hora >= p_desde)
      AND (v_hasta_sig IS NULL OR v.fecha_hora < v_hasta_sig)
    GROUP BY p.id_producto, p.nombre_producto, cp.nombre_categoria
    ORDER BY monto_total DESC, p.nombre_producto, p.id_producto;
END //

DELIMITER ;

-- 6. Recaudado por grupo del buffet en un rango: donaciones + ventas Entregadas de los productos del grupo (regla vigente, CONTEXTO).
-- Pregunta: cuanto junto cada grupo en el periodo y que porcentaje de su meta representa.
-- GROUP BY grupo; JOIN grupo con la UNION ALL de sus dos fuentes de ingreso; fechas: rango con dia inclusivo, MAX(DATE()).
-- Solo aparecen los grupos con movimientos en el rango.
DROP PROCEDURE IF EXISTS sp_rep_recaudado_por_grupo;

DELIMITER //
CREATE PROCEDURE sp_rep_recaudado_por_grupo(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
    WHERE (p_desde IS NULL OR m.fecha_hora >= p_desde)
      AND (v_hasta_sig IS NULL OR m.fecha_hora < v_hasta_sig)
    GROUP BY g.id_grupo, g.nombre_grupo, g.meta_monto
    ORDER BY recaudado DESC, g.nombre_grupo;
END //

DELIMITER ;

-- 7. Inscriptos de Educacion Fisica por oferta (deporte + dia + franja), segun la fecha de inscripcion.
-- Pregunta: cuantos alumnos se anotaron en cada deporte y cuantos cupos quedan.
-- GROUP BY oferta; JOIN inscripcion -> oferta -> deporte, dia y franja; fechas: rango, MIN/MAX.
-- Los cupos libres comparan los inscriptos DEL RANGO con el cupo maximo: para el cupo real hay que usar el rango completo (NULL, NULL).
DROP PROCEDURE IF EXISTS sp_rep_inscriptos_por_deporte;

DELIMITER //
CREATE PROCEDURE sp_rep_inscriptos_por_deporte(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
    WHERE (p_desde IS NULL OR i.fecha_inscripcion >= p_desde)
      AND (p_hasta IS NULL OR i.fecha_inscripcion <= p_hasta)
    GROUP BY o.id_oferta, d.nombre_deporte, ds.id_dia, ds.nombre_dia, f.hora_inicio, f.hora_fin, o.cupo_maximo
    ORDER BY inscriptos DESC, d.nombre_deporte, ds.id_dia, f.hora_inicio;
END //

DELIMITER ;

-- 8. Actividad por usuario: prestamos de equipos (como solicitante), reservas de sectores y reclamos de objetos en el rango.
-- Pregunta: quienes usan mas el sistema y en que.
-- GROUP BY usuario; JOIN seguridad.usuario -> rol y 3 LEFT JOIN (uno por tipo de actividad); fechas: rango aplicado en cada ON.
-- HAVING: la condicion es sobre un agregado (suma de conteos), no se puede poner en WHERE; deja afuera a los usuarios sin actividad.
-- Version SIN tuning: los 3 LEFT JOIN se multiplican entre si (por eso COUNT DISTINCT). La optimizada es sp_rep_actividad_por_usuario_tuneado.
DROP PROCEDURE IF EXISTS sp_rep_actividad_por_usuario;

DELIMITER //
CREATE PROCEDURE sp_rep_actividad_por_usuario(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

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
          AND (p_desde IS NULL OR pr.fecha_prestamo >= p_desde)
          AND (p_hasta IS NULL OR pr.fecha_prestamo <= p_hasta)
    LEFT JOIN instalaciones.reserva_sector rs ON rs.id_usuario = u.id_usuario
          AND (p_desde IS NULL OR rs.fecha_reserva >= p_desde)
          AND (p_hasta IS NULL OR rs.fecha_reserva <= p_hasta)
    LEFT JOIN objetos.reclamo_objeto ro ON ro.id_usuario = u.id_usuario
          AND (p_desde IS NULL OR ro.fecha_reclamo >= p_desde)
          AND (p_hasta IS NULL OR ro.fecha_reclamo <= p_hasta)
    GROUP BY u.id_usuario, u.usuario_nick, u.nombre_completo, r.nombre_rol
    HAVING COUNT(DISTINCT pr.id_prestamo) + COUNT(DISTINCT rs.id_reserva) + COUNT(DISTINCT ro.id_reclamo) > 0
    ORDER BY total_actividad DESC, u.usuario_nick;
END //

DELIMITER ;

-- 9. Auditoria: eventos del log agrupados por dia, evento, entidad, resultado y usuario.
-- Pregunta: que paso, quien lo hizo y con que resultado en un periodo.
-- Rango de fechas OBLIGATORIO (NULL = error de negocio). p_evento (nombre del tipo de evento), p_nick y p_resultado son opcionales:
-- NULL o cadena vacia = sin filtro. Un valor que no existe devuelve 0 filas (no es error).
-- GROUP BY; JOIN con tipo_log, entidad_log, resultado_log y LEFT JOIN seguridad.usuario (hay eventos sin usuario, p. ej. login con nick inexistente);
-- fechas: DATE(), TIME(), rango con dia inclusivo.
DROP PROCEDURE IF EXISTS sp_rep_auditoria;

DELIMITER //
CREATE PROCEDURE sp_rep_auditoria(p_desde DATE, p_hasta DATE, p_evento VARCHAR(80), p_nick VARCHAR(50), p_resultado VARCHAR(30))
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

    IF p_desde IS NULL OR p_hasta IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El rango de fechas es obligatorio: desde y hasta no pueden ser NULL';
    END IF;

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
    WHERE l.fecha_hora >= p_desde
      AND l.fecha_hora < v_hasta_sig
      AND (p_evento IS NULL OR p_evento = '' OR t.nombre_evento = p_evento)
      AND (p_nick IS NULL OR p_nick = '' OR u.usuario_nick = p_nick)
      AND (p_resultado IS NULL OR p_resultado = '' OR rl.nombre_resultado = p_resultado)
    GROUP BY DATE(l.fecha_hora), t.id_tipo_log, t.nombre_evento, en.id_entidad, en.nombre_entidad,
             rl.id_resultado, rl.nombre_resultado, u.id_usuario, u.usuario_nick
    ORDER BY fecha, t.nombre_evento, rl.nombre_resultado, nick;
END //

DELIMITER ;

-- 10. TUNEADO de sp_rep_ventas_por_producto: mismas filas, columnas y orden. Ver TUNING_REPORTES.md.
-- Tecnica de la clase 004: seleccion y proyeccion antes de la reunion (tabla temporal) + pre-agregado + indices.
DROP PROCEDURE IF EXISTS sp_rep_ventas_por_producto_tuneado;

DELIMITER //
CREATE PROCEDURE sp_rep_ventas_por_producto_tuneado(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        DROP TEMPORARY TABLE IF EXISTS tmp_ventas_entregadas;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

    -- Paso 1 (seleccion antes de reunir): solo las ventas Entregadas del rango, proyectadas a 2 columnas
    DROP TEMPORARY TABLE IF EXISTS tmp_ventas_entregadas;
    CREATE TEMPORARY TABLE tmp_ventas_entregadas AS
        SELECT v.id_venta, DATE(v.fecha_hora) AS fecha
        FROM tienda.venta_buffet v
        JOIN tienda.estado_venta ev ON ev.id_estado_venta = v.id_estado_venta
        WHERE ev.nombre_estado = 'Entregada'
          AND (p_desde IS NULL OR v.fecha_hora >= p_desde)
          AND (v_hasta_sig IS NULL OR v.fecha_hora < v_hasta_sig);

    -- Paso 2 (pre-agregado): se agrupa por producto reuniendo solo detalle + ventas ya filtradas
    -- Paso 3: recien con el resultado chico se reune con producto y categoria
    SELECT p.id_producto,
           p.nombre_producto,
           cp.nombre_categoria,
           t.unidades_vendidas,
           t.cantidad_ventas,
           t.monto_total,
           t.primera_venta,
           t.ultima_venta
    FROM (SELECT d.id_producto,
                 SUM(d.cantidad) AS unidades_vendidas,
                 COUNT(*) AS cantidad_ventas,
                 SUM(d.cantidad * d.precio_unitario) AS monto_total,
                 MIN(tv.fecha) AS primera_venta,
                 MAX(tv.fecha) AS ultima_venta
          FROM tienda.detalle_venta d
          JOIN tmp_ventas_entregadas tv ON tv.id_venta = d.id_venta
          GROUP BY d.id_producto) t
    JOIN tienda.producto_buffet p ON p.id_producto = t.id_producto
    JOIN tienda.categoria_producto cp ON cp.id_categoria_producto = p.id_categoria_producto
    ORDER BY t.monto_total DESC, p.nombre_producto, p.id_producto;

    DROP TEMPORARY TABLE IF EXISTS tmp_ventas_entregadas;
END //

DELIMITER ;

-- 11. TUNEADO de sp_rep_actividad_por_usuario: mismas filas, columnas y orden. Ver TUNING_REPORTES.md.
-- Tecnica de la clase 004: seleccion y agrupamiento en subconsultas ANTES de la reunion + indices.
-- El HAVING del original pasa a WHERE: ya no hay GROUP BY en la consulta externa (cada subconsulta ya devuelve una fila por usuario).
DROP PROCEDURE IF EXISTS sp_rep_actividad_por_usuario_tuneado;

DELIMITER //
CREATE PROCEDURE sp_rep_actividad_por_usuario_tuneado(p_desde DATE, p_hasta DATE)
BEGIN
    -- Declaración de variables para captura de errores
    DECLARE codigo_error INT DEFAULT 0;
    DECLARE mensaje_error VARCHAR(255) DEFAULT '';
    DECLARE v_hasta_sig DATE;

    -- MANEJADOR DE EXCEPCIONES: se activa si ocurre cualquier error SQL (SQLEXCEPTION)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Capturar el número y mensaje exacto del error que ocurrió
        GET DIAGNOSTICS CONDITION 1
            codigo_error = MYSQL_ERRNO,
            mensaje_error = MESSAGE_TEXT;
        -- Devolver una respuesta estructurada indicando el fallo
        SELECT
            'ERROR' AS estado,
            codigo_error AS codigo_sql,
            mensaje_error AS descripcion_error;
    END;

    -- CÓDIGO PRINCIPAL
    -- Regla de negocio: el rango no puede estar invertido (si falta una punta, ese lado queda sin limite)
    IF p_desde IS NOT NULL AND p_hasta IS NOT NULL AND p_desde > p_hasta THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rango de fechas invalido: desde es mayor que hasta';
    END IF;
    -- Para columnas DATETIME: "hasta" incluye todo el dia, por eso se compara contra el dia siguiente (exclusivo)
    SET v_hasta_sig = DATE_ADD(p_hasta, INTERVAL 1 DAY);

    -- Seleccion y agregado ANTES de reunir: cada tipo de actividad se cuenta por separado ya filtrada por fecha
    -- y recien despues se reune con usuario y rol (sin multiplicar filas entre los 3 tipos).
    SELECT u.usuario_nick,
           u.nombre_completo,
           r.nombre_rol,
           COALESCE(a.cantidad, 0) AS prestamos,
           COALESCE(b.cantidad, 0) AS reservas,
           COALESCE(c.cantidad, 0) AS reclamos,
           COALESCE(a.cantidad, 0) + COALESCE(b.cantidad, 0) + COALESCE(c.cantidad, 0) AS total_actividad
    FROM seguridad.usuario u
    JOIN seguridad.rol r ON r.id_rol = u.id_rol
    LEFT JOIN (SELECT pr.id_usuario_solicitante AS id_usuario, COUNT(*) AS cantidad
               FROM equipos.prestamo_ct pr
               WHERE (p_desde IS NULL OR pr.fecha_prestamo >= p_desde)
                 AND (p_hasta IS NULL OR pr.fecha_prestamo <= p_hasta)
               GROUP BY pr.id_usuario_solicitante) a ON a.id_usuario = u.id_usuario
    LEFT JOIN (SELECT rs.id_usuario, COUNT(*) AS cantidad
               FROM instalaciones.reserva_sector rs
               WHERE (p_desde IS NULL OR rs.fecha_reserva >= p_desde)
                 AND (p_hasta IS NULL OR rs.fecha_reserva <= p_hasta)
               GROUP BY rs.id_usuario) b ON b.id_usuario = u.id_usuario
    LEFT JOIN (SELECT ro.id_usuario, COUNT(*) AS cantidad
               FROM objetos.reclamo_objeto ro
               WHERE (p_desde IS NULL OR ro.fecha_reclamo >= p_desde)
                 AND (p_hasta IS NULL OR ro.fecha_reclamo <= p_hasta)
               GROUP BY ro.id_usuario) c ON c.id_usuario = u.id_usuario
    WHERE COALESCE(a.cantidad, 0) + COALESCE(b.cantidad, 0) + COALESCE(c.cantidad, 0) > 0
    ORDER BY total_actividad DESC, u.usuario_nick;
END //

DELIMITER ;

