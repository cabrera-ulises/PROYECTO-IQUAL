-- 03_ModeloSQL_Grupo06.sql - PROYECTO IQUAL (SGE) - modelo de datos para MySQL 8 / MariaDB 10.11 (47 tablas en 3FN)
-- Se puede ejecutar muchas veces: borra las tablas y las vuelve a crear, vacias. Los datos van en 04_DatosSQL.
-- MAPA DE SCHEMAS (47 tablas, CONTEXTO_IQUAL 21):
--   seguridad      (6) rol, usuario, log_auditoria, tipo_log, resultado_log, entidad_log
--   academico      (10) especialidad, turno, dia_semana, anio, division, franja_horaria, curso, materia, horario_escolar, horario_dia
--   objetos        (6) categoria_objeto, estado_objeto, estado_reclamo, objeto_perdido, reclamo_objeto, consulta_objeto
--   instalaciones  (7) tipo_reporte, estado_reporte, estado_reserva, tipo_sector, sector, reporte_higiene, reserva_sector
--   tienda         (8) estado_venta, categoria_producto, grupo_buffet, integrante_grupo, producto_buffet, venta_buffet, detalle_venta, donacion_buffet
--   equipos        (7) tipo_recurso, estado_recurso, carro, software, recursos_ct, recurso_software, prestamo_ct
--   deportes       (3) deporte, oferta_deporte, inscripcion_ed_fisica
-- En MySQL schema y base de datos son lo mismo. Si cada schema fuera una base, la app y las consultas tendrian que
-- escribir base.tabla en todos lados. Por eso aca queda UNA base (iqual), las tablas conservan su nombre y el mapa
-- se documenta en este comentario y en SCHEMAS.md. La version de SQL Server si crea los 7 schemas reales.
CREATE DATABASE IF NOT EXISTS iqual CHARACTER SET utf8mb4;
USE iqual;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS log_auditoria;
DROP TABLE IF EXISTS inscripcion_ed_fisica;
DROP TABLE IF EXISTS oferta_deporte;
DROP TABLE IF EXISTS reserva_sector;
DROP TABLE IF EXISTS prestamo_ct;
DROP TABLE IF EXISTS recurso_software;
DROP TABLE IF EXISTS recursos_ct;
DROP TABLE IF EXISTS donacion_buffet;
DROP TABLE IF EXISTS detalle_venta;
DROP TABLE IF EXISTS venta_buffet;
DROP TABLE IF EXISTS producto_buffet;
DROP TABLE IF EXISTS integrante_grupo;
DROP TABLE IF EXISTS grupo_buffet;
DROP TABLE IF EXISTS reporte_higiene;
DROP TABLE IF EXISTS consulta_objeto;
DROP TABLE IF EXISTS reclamo_objeto;
DROP TABLE IF EXISTS objeto_perdido;
DROP TABLE IF EXISTS sector;
DROP TABLE IF EXISTS horario_dia;
DROP TABLE IF EXISTS horario_escolar;
DROP TABLE IF EXISTS materia;
DROP TABLE IF EXISTS usuario;
DROP TABLE IF EXISTS curso;
DROP TABLE IF EXISTS franja_horaria;
DROP TABLE IF EXISTS division;
DROP TABLE IF EXISTS anio;
DROP TABLE IF EXISTS software;
DROP TABLE IF EXISTS categoria_producto;
DROP TABLE IF EXISTS tipo_sector;
DROP TABLE IF EXISTS entidad_log;
DROP TABLE IF EXISTS resultado_log;
DROP TABLE IF EXISTS tipo_log;
DROP TABLE IF EXISTS deporte;
DROP TABLE IF EXISTS carro;
DROP TABLE IF EXISTS estado_recurso;
DROP TABLE IF EXISTS tipo_recurso;
DROP TABLE IF EXISTS estado_venta;
DROP TABLE IF EXISTS estado_reserva;
DROP TABLE IF EXISTS estado_reporte;
DROP TABLE IF EXISTS tipo_reporte;
DROP TABLE IF EXISTS estado_reclamo;
DROP TABLE IF EXISTS estado_objeto;
DROP TABLE IF EXISTS categoria_objeto;
DROP TABLE IF EXISTS dia_semana;
DROP TABLE IF EXISTS turno;
DROP TABLE IF EXISTS especialidad;
DROP TABLE IF EXISTS rol;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE rol (
  id_rol INT NOT NULL AUTO_INCREMENT,
  nombre_rol VARCHAR(30) NOT NULL,
  CONSTRAINT pk_rol PRIMARY KEY (id_rol),
  CONSTRAINT uq_rol_nombre_rol UNIQUE (nombre_rol)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE especialidad (
  id_especialidad INT NOT NULL AUTO_INCREMENT,
  nombre_especialidad VARCHAR(50) NOT NULL,
  CONSTRAINT pk_especialidad PRIMARY KEY (id_especialidad),
  CONSTRAINT uq_especialidad_nombre_especialidad UNIQUE (nombre_especialidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE turno (
  id_turno INT NOT NULL AUTO_INCREMENT,
  nombre_turno VARCHAR(30) NOT NULL,
  CONSTRAINT pk_turno PRIMARY KEY (id_turno),
  CONSTRAINT uq_turno_nombre_turno UNIQUE (nombre_turno)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dia_semana (
  id_dia INT NOT NULL AUTO_INCREMENT,
  nombre_dia VARCHAR(30) NOT NULL,
  CONSTRAINT pk_dia_semana PRIMARY KEY (id_dia),
  CONSTRAINT uq_dia_semana_nombre_dia UNIQUE (nombre_dia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categoria_objeto (
  id_categoria_objeto INT NOT NULL AUTO_INCREMENT,
  nombre_categoria VARCHAR(50) NOT NULL,
  CONSTRAINT pk_categoria_objeto PRIMARY KEY (id_categoria_objeto),
  CONSTRAINT uq_categoria_objeto_nombre_categoria UNIQUE (nombre_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estado_objeto (
  id_estado_objeto INT NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_objeto PRIMARY KEY (id_estado_objeto),
  CONSTRAINT uq_estado_objeto_nombre_estado UNIQUE (nombre_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estado_reclamo (
  id_estado_reclamo INT NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reclamo PRIMARY KEY (id_estado_reclamo),
  CONSTRAINT uq_estado_reclamo_nombre_estado UNIQUE (nombre_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tipo_reporte (
  id_tipo_reporte INT NOT NULL AUTO_INCREMENT,
  nombre_tipo VARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_reporte PRIMARY KEY (id_tipo_reporte),
  CONSTRAINT uq_tipo_reporte_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estado_reporte (
  id_estado_reporte INT NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reporte PRIMARY KEY (id_estado_reporte),
  CONSTRAINT uq_estado_reporte_nombre_estado UNIQUE (nombre_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estado_reserva (
  id_estado_reserva INT NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reserva PRIMARY KEY (id_estado_reserva),
  CONSTRAINT uq_estado_reserva_nombre_estado UNIQUE (nombre_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estado_venta (
  id_estado_venta INT NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_venta PRIMARY KEY (id_estado_venta),
  CONSTRAINT uq_estado_venta_nombre_estado UNIQUE (nombre_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tipo_recurso (
  id_tipo_recurso INT NOT NULL AUTO_INCREMENT,
  nombre_tipo VARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_recurso PRIMARY KEY (id_tipo_recurso),
  CONSTRAINT uq_tipo_recurso_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE estado_recurso (
  id_estado_recurso INT NOT NULL AUTO_INCREMENT,
  nombre_estado VARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_recurso PRIMARY KEY (id_estado_recurso),
  CONSTRAINT uq_estado_recurso_nombre_estado UNIQUE (nombre_estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE carro (
  id_carro INT NOT NULL AUTO_INCREMENT,
  nombre_carro VARCHAR(30) NOT NULL,
  CONSTRAINT pk_carro PRIMARY KEY (id_carro),
  CONSTRAINT uq_carro_nombre_carro UNIQUE (nombre_carro)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE deporte (
  id_deporte INT NOT NULL AUTO_INCREMENT,
  nombre_deporte VARCHAR(50) NOT NULL,
  CONSTRAINT pk_deporte PRIMARY KEY (id_deporte),
  CONSTRAINT uq_deporte_nombre_deporte UNIQUE (nombre_deporte)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tipo_log (
  id_tipo_log INT NOT NULL AUTO_INCREMENT,
  nombre_evento VARCHAR(80) NOT NULL,
  CONSTRAINT pk_tipo_log PRIMARY KEY (id_tipo_log),
  CONSTRAINT uq_tipo_log_nombre_evento UNIQUE (nombre_evento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE resultado_log (
  id_resultado INT NOT NULL AUTO_INCREMENT,
  nombre_resultado VARCHAR(30) NOT NULL,
  CONSTRAINT pk_resultado_log PRIMARY KEY (id_resultado),
  CONSTRAINT uq_resultado_log_nombre_resultado UNIQUE (nombre_resultado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE entidad_log (
  id_entidad INT NOT NULL AUTO_INCREMENT,
  nombre_entidad VARCHAR(50) NOT NULL,
  CONSTRAINT pk_entidad_log PRIMARY KEY (id_entidad),
  CONSTRAINT uq_entidad_log_nombre_entidad UNIQUE (nombre_entidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE tipo_sector (
  id_tipo_sector INT NOT NULL AUTO_INCREMENT,
  nombre_tipo VARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_sector PRIMARY KEY (id_tipo_sector),
  CONSTRAINT uq_tipo_sector_nombre_tipo UNIQUE (nombre_tipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categoria_producto (
  id_categoria_producto INT NOT NULL AUTO_INCREMENT,
  nombre_categoria VARCHAR(80) NOT NULL,
  CONSTRAINT pk_categoria_producto PRIMARY KEY (id_categoria_producto),
  CONSTRAINT uq_categoria_producto_nombre_categoria UNIQUE (nombre_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE software (
  id_software INT NOT NULL AUTO_INCREMENT,
  nombre_software VARCHAR(80) NOT NULL,
  CONSTRAINT pk_software PRIMARY KEY (id_software),
  CONSTRAINT uq_software_nombre_software UNIQUE (nombre_software)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE anio (
  id_anio INT NOT NULL AUTO_INCREMENT,
  numero_anio INT NOT NULL,
  CONSTRAINT pk_anio PRIMARY KEY (id_anio),
  CONSTRAINT uq_anio_numero_anio UNIQUE (numero_anio),
  CONSTRAINT ck_anio CHECK (numero_anio BETWEEN 1 AND 7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE division (
  id_division INT NOT NULL AUTO_INCREMENT,
  numero_division INT NOT NULL,
  CONSTRAINT pk_division PRIMARY KEY (id_division),
  CONSTRAINT uq_division_numero_division UNIQUE (numero_division),
  CONSTRAINT ck_division CHECK (numero_division BETWEEN 1 AND 9)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE franja_horaria (
  id_franja INT NOT NULL AUTO_INCREMENT,
  hora_inicio VARCHAR(5) NOT NULL,
  hora_fin VARCHAR(5) NOT NULL,
  CONSTRAINT pk_franja_horaria PRIMARY KEY (id_franja),
  CONSTRAINT ck_franja CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE curso (
  id_curso INT NOT NULL AUTO_INCREMENT,
  id_anio INT NOT NULL,
  id_division INT NOT NULL,
  id_especialidad INT NOT NULL,
  CONSTRAINT pk_curso PRIMARY KEY (id_curso),
  CONSTRAINT fk_curso_id_anio FOREIGN KEY (id_anio) REFERENCES anio (id_anio),
  CONSTRAINT fk_curso_id_division FOREIGN KEY (id_division) REFERENCES division (id_division),
  CONSTRAINT fk_curso_id_especialidad FOREIGN KEY (id_especialidad) REFERENCES especialidad (id_especialidad),
  CONSTRAINT uq_curso_id_anio_id_division_id_especialidad UNIQUE (id_anio, id_division, id_especialidad)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuario (
  id_usuario INT NOT NULL AUTO_INCREMENT,
  dni INT NOT NULL,
  nombre_completo VARCHAR(80) NOT NULL,
  usuario_nick VARCHAR(50) NOT NULL,
  password_hash CHAR(64) NOT NULL,
  email VARCHAR(80) NOT NULL,
  contacto_telefono VARCHAR(15) NOT NULL,
  id_rol INT NOT NULL,
  id_curso INT NULL,
  CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_dni UNIQUE (dni),
  CONSTRAINT uq_usuario_usuario_nick UNIQUE (usuario_nick),
  CONSTRAINT uq_usuario_email UNIQUE (email),
  CONSTRAINT fk_usuario_id_rol FOREIGN KEY (id_rol) REFERENCES rol (id_rol),
  CONSTRAINT fk_usuario_id_curso FOREIGN KEY (id_curso) REFERENCES curso (id_curso),
  CONSTRAINT ck_usuario_dni CHECK (dni BETWEEN 1000000 AND 99999999)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE materia (
  id_materia INT NOT NULL AUTO_INCREMENT,
  nombre_materia VARCHAR(80) NOT NULL,
  codigo_materia VARCHAR(20) NOT NULL,
  CONSTRAINT pk_materia PRIMARY KEY (id_materia),
  CONSTRAINT uq_materia_codigo_materia UNIQUE (codigo_materia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE horario_escolar (
  id_bloque INT NOT NULL AUTO_INCREMENT,
  hora_inicio VARCHAR(5) NOT NULL,
  hora_fin VARCHAR(5) NOT NULL,
  id_materia INT NOT NULL,
  id_curso INT NOT NULL,
  id_usuario INT NULL,
  id_turno INT NOT NULL,
  CONSTRAINT pk_horario_escolar PRIMARY KEY (id_bloque),
  CONSTRAINT fk_horario_escolar_id_materia FOREIGN KEY (id_materia) REFERENCES materia (id_materia),
  CONSTRAINT fk_horario_escolar_id_curso FOREIGN KEY (id_curso) REFERENCES curso (id_curso),
  CONSTRAINT fk_horario_escolar_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_horario_escolar_id_turno FOREIGN KEY (id_turno) REFERENCES turno (id_turno),
  CONSTRAINT ck_horario_horas CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE horario_dia (
  id_bloque INT NOT NULL,
  id_dia INT NOT NULL,
  CONSTRAINT pk_horario_dia PRIMARY KEY (id_bloque, id_dia),
  CONSTRAINT fk_horario_dia_id_bloque FOREIGN KEY (id_bloque) REFERENCES horario_escolar (id_bloque),
  CONSTRAINT fk_horario_dia_id_dia FOREIGN KEY (id_dia) REFERENCES dia_semana (id_dia)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sector (
  id_sector INT NOT NULL AUTO_INCREMENT,
  nombre_sector VARCHAR(80) NOT NULL,
  id_tipo_sector INT NOT NULL,
  CONSTRAINT pk_sector PRIMARY KEY (id_sector),
  CONSTRAINT uq_sector_nombre_sector UNIQUE (nombre_sector),
  CONSTRAINT fk_sector_id_tipo_sector FOREIGN KEY (id_tipo_sector) REFERENCES tipo_sector (id_tipo_sector)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE objeto_perdido (
  id_objeto INT NOT NULL AUTO_INCREMENT,
  titulo VARCHAR(80) NOT NULL,
  descripcion VARCHAR(200) NULL,
  ruta_foto VARCHAR(150) NULL,
  fecha_registro DATE NOT NULL,
  id_usuario INT NOT NULL,
  id_categoria_objeto INT NOT NULL,
  id_estado_objeto INT NOT NULL,
  id_sector INT NOT NULL,
  detalle_reservado VARCHAR(200) NULL,
  CONSTRAINT pk_objeto_perdido PRIMARY KEY (id_objeto),
  CONSTRAINT fk_objeto_perdido_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_objeto_perdido_id_categoria_objeto FOREIGN KEY (id_categoria_objeto) REFERENCES categoria_objeto (id_categoria_objeto),
  CONSTRAINT fk_objeto_perdido_id_estado_objeto FOREIGN KEY (id_estado_objeto) REFERENCES estado_objeto (id_estado_objeto),
  CONSTRAINT fk_objeto_perdido_id_sector FOREIGN KEY (id_sector) REFERENCES sector (id_sector)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reclamo_objeto (
  id_reclamo INT NOT NULL AUTO_INCREMENT,
  prueba_pertenencia VARCHAR(200) NOT NULL,
  fecha_reclamo DATE NOT NULL,
  id_usuario INT NOT NULL,
  id_objeto INT NOT NULL,
  id_estado_reclamo INT NOT NULL,
  CONSTRAINT pk_reclamo_objeto PRIMARY KEY (id_reclamo),
  CONSTRAINT fk_reclamo_objeto_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_reclamo_objeto_id_objeto FOREIGN KEY (id_objeto) REFERENCES objeto_perdido (id_objeto),
  CONSTRAINT fk_reclamo_objeto_id_estado_reclamo FOREIGN KEY (id_estado_reclamo) REFERENCES estado_reclamo (id_estado_reclamo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE UNIQUE INDEX ux_reclamo_usuario_objeto ON reclamo_objeto (id_usuario, id_objeto);

CREATE TABLE consulta_objeto (
  id_consulta INT NOT NULL AUTO_INCREMENT,
  fecha_publicacion DATE NOT NULL,
  descripcion_busqueda VARCHAR(200) NOT NULL,
  id_usuario INT NOT NULL,
  CONSTRAINT pk_consulta_objeto PRIMARY KEY (id_consulta),
  CONSTRAINT fk_consulta_objeto_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reporte_higiene (
  id_reporte INT NOT NULL AUTO_INCREMENT,
  fecha_hora DATETIME NOT NULL,
  observaciones VARCHAR(200) NOT NULL,
  id_usuario INT NOT NULL,
  id_sector INT NOT NULL,
  id_tipo_reporte INT NOT NULL,
  id_estado_reporte INT NOT NULL,
  fecha_hora_resolucion DATETIME NULL,
  id_usuario_resolutor INT NULL,
  CONSTRAINT pk_reporte_higiene PRIMARY KEY (id_reporte),
  CONSTRAINT fk_reporte_higiene_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_reporte_higiene_id_sector FOREIGN KEY (id_sector) REFERENCES sector (id_sector),
  CONSTRAINT fk_reporte_higiene_id_tipo_reporte FOREIGN KEY (id_tipo_reporte) REFERENCES tipo_reporte (id_tipo_reporte),
  CONSTRAINT fk_reporte_higiene_id_estado_reporte FOREIGN KEY (id_estado_reporte) REFERENCES estado_reporte (id_estado_reporte),
  CONSTRAINT fk_reporte_higiene_id_usuario_resolutor FOREIGN KEY (id_usuario_resolutor) REFERENCES usuario (id_usuario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE grupo_buffet (
  id_grupo INT NOT NULL AUTO_INCREMENT,
  nombre_grupo VARCHAR(50) NOT NULL,
  pin_acceso VARCHAR(20) NOT NULL,
  meta_monto INT NOT NULL,
  CONSTRAINT pk_grupo_buffet PRIMARY KEY (id_grupo),
  CONSTRAINT uq_grupo_buffet_nombre_grupo UNIQUE (nombre_grupo),
  CONSTRAINT ck_grupo_meta CHECK (meta_monto > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE integrante_grupo (
  id_usuario INT NOT NULL,
  id_grupo INT NOT NULL,
  CONSTRAINT pk_integrante_grupo PRIMARY KEY (id_usuario, id_grupo),
  CONSTRAINT fk_integrante_grupo_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_integrante_grupo_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE producto_buffet (
  id_producto INT NOT NULL AUTO_INCREMENT,
  nombre_producto VARCHAR(80) NOT NULL,
  precio INT NOT NULL,
  stock INT NOT NULL,
  id_usuario INT NOT NULL,
  id_grupo INT NULL,
  id_categoria_producto INT NOT NULL DEFAULT 1,
  ruta_foto VARCHAR(150) NULL,
  CONSTRAINT pk_producto_buffet PRIMARY KEY (id_producto),
  CONSTRAINT fk_producto_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_producto_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo),
  CONSTRAINT fk_producto_buffet_id_categoria_producto FOREIGN KEY (id_categoria_producto) REFERENCES categoria_producto (id_categoria_producto),
  CONSTRAINT ck_producto_precio CHECK (precio > 0),
  CONSTRAINT ck_producto_stock CHECK (stock >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE venta_buffet (
  id_venta INT NOT NULL AUTO_INCREMENT,
  fecha_hora DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_estado_venta INT NOT NULL,
  CONSTRAINT pk_venta_buffet PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_venta_buffet_id_estado_venta FOREIGN KEY (id_estado_venta) REFERENCES estado_venta (id_estado_venta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE detalle_venta (
  id_venta INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario INT NOT NULL,
  CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
  CONSTRAINT fk_detalle_venta_id_venta FOREIGN KEY (id_venta) REFERENCES venta_buffet (id_venta),
  CONSTRAINT fk_detalle_venta_id_producto FOREIGN KEY (id_producto) REFERENCES producto_buffet (id_producto),
  CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE donacion_buffet (
  id_donacion INT NOT NULL AUTO_INCREMENT,
  monto INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_grupo INT NOT NULL,
  CONSTRAINT pk_donacion_buffet PRIMARY KEY (id_donacion),
  CONSTRAINT fk_donacion_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_donacion_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo),
  CONSTRAINT ck_donacion_monto CHECK (monto > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recursos_ct (
  id_recurso INT NOT NULL AUTO_INCREMENT,
  id_carro INT NULL,
  numero_equipo INT NOT NULL,
  id_tipo_recurso INT NOT NULL,
  id_estado_recurso INT NOT NULL,
  CONSTRAINT pk_recursos_ct PRIMARY KEY (id_recurso),
  CONSTRAINT fk_recursos_ct_id_carro FOREIGN KEY (id_carro) REFERENCES carro (id_carro),
  CONSTRAINT fk_recursos_ct_id_tipo_recurso FOREIGN KEY (id_tipo_recurso) REFERENCES tipo_recurso (id_tipo_recurso),
  CONSTRAINT fk_recursos_ct_id_estado_recurso FOREIGN KEY (id_estado_recurso) REFERENCES estado_recurso (id_estado_recurso),
  CONSTRAINT uq_recursos_ct_id_tipo_recurso_id_carro_numero_equipo UNIQUE (id_tipo_recurso, id_carro, numero_equipo)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recurso_software (
  id_recurso_software INT NOT NULL AUTO_INCREMENT,
  id_recurso INT NOT NULL,
  id_software INT NOT NULL,
  CONSTRAINT pk_recurso_software PRIMARY KEY (id_recurso_software),
  CONSTRAINT fk_recurso_software_id_recurso FOREIGN KEY (id_recurso) REFERENCES recursos_ct (id_recurso),
  CONSTRAINT fk_recurso_software_id_software FOREIGN KEY (id_software) REFERENCES software (id_software),
  CONSTRAINT uq_recurso_software_id_recurso_id_software UNIQUE (id_recurso, id_software)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE prestamo_ct (
  id_prestamo INT NOT NULL AUTO_INCREMENT,
  fecha_prestamo DATE NOT NULL,
  hora_prestamo VARCHAR(5) NOT NULL,
  hora_devolucion VARCHAR(5) NULL,
  observaciones VARCHAR(200) NULL,
  id_usuario_solicitante INT NOT NULL,
  id_usuario_autorizador INT NOT NULL,
  id_recurso INT NOT NULL,
  CONSTRAINT pk_prestamo_ct PRIMARY KEY (id_prestamo),
  CONSTRAINT fk_prestamo_ct_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_prestamo_ct_id_usuario_autorizador FOREIGN KEY (id_usuario_autorizador) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_prestamo_ct_id_recurso FOREIGN KEY (id_recurso) REFERENCES recursos_ct (id_recurso)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE reserva_sector (
  id_reserva INT NOT NULL AUTO_INCREMENT,
  fecha_reserva DATE NOT NULL,
  hora_inicio VARCHAR(5) NOT NULL,
  hora_fin VARCHAR(5) NOT NULL,
  id_usuario INT NOT NULL,
  id_sector INT NOT NULL,
  id_estado_reserva INT NOT NULL,
  id_usuario_autorizador INT NULL,
  CONSTRAINT pk_reserva_sector PRIMARY KEY (id_reserva),
  CONSTRAINT fk_reserva_sector_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_reserva_sector_id_sector FOREIGN KEY (id_sector) REFERENCES sector (id_sector),
  CONSTRAINT fk_reserva_sector_id_estado_reserva FOREIGN KEY (id_estado_reserva) REFERENCES estado_reserva (id_estado_reserva),
  CONSTRAINT fk_reserva_sector_id_usuario_autorizador FOREIGN KEY (id_usuario_autorizador) REFERENCES usuario (id_usuario),
  CONSTRAINT ck_reserva_horas CHECK (hora_fin > hora_inicio)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE oferta_deporte (
  id_oferta INT NOT NULL AUTO_INCREMENT,
  id_deporte INT NOT NULL,
  id_dia INT NOT NULL,
  id_franja INT NOT NULL,
  cupo_maximo INT NOT NULL,
  CONSTRAINT pk_oferta_deporte PRIMARY KEY (id_oferta),
  CONSTRAINT fk_oferta_deporte_id_deporte FOREIGN KEY (id_deporte) REFERENCES deporte (id_deporte),
  CONSTRAINT fk_oferta_deporte_id_dia FOREIGN KEY (id_dia) REFERENCES dia_semana (id_dia),
  CONSTRAINT fk_oferta_deporte_id_franja FOREIGN KEY (id_franja) REFERENCES franja_horaria (id_franja),
  CONSTRAINT uq_oferta_deporte_id_deporte_id_dia_id_franja UNIQUE (id_deporte, id_dia, id_franja),
  CONSTRAINT ck_oferta_cupo CHECK (cupo_maximo > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE inscripcion_ed_fisica (
  id_inscripcion INT NOT NULL AUTO_INCREMENT,
  fecha_inscripcion DATE NOT NULL,
  id_usuario INT NOT NULL,
  id_oferta INT NOT NULL,
  CONSTRAINT pk_inscripcion_ed_fisica PRIMARY KEY (id_inscripcion),
  CONSTRAINT uq_inscripcion_ed_fisica_id_usuario UNIQUE (id_usuario),
  CONSTRAINT fk_inscripcion_ed_fisica_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_inscripcion_ed_fisica_id_oferta FOREIGN KEY (id_oferta) REFERENCES oferta_deporte (id_oferta)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE log_auditoria (
  id_log INT NOT NULL AUTO_INCREMENT,
  fecha_hora DATETIME NOT NULL,
  direccion_ip VARCHAR(80) NOT NULL,
  descripcion_evento VARCHAR(200) NOT NULL,
  id_entidad INT NOT NULL,
  id_usuario INT NULL,
  id_tipo_log INT NOT NULL,
  id_resultado INT NOT NULL,
  CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log),
  CONSTRAINT fk_log_auditoria_id_entidad FOREIGN KEY (id_entidad) REFERENCES entidad_log (id_entidad),
  CONSTRAINT fk_log_auditoria_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_log_auditoria_id_tipo_log FOREIGN KEY (id_tipo_log) REFERENCES tipo_log (id_tipo_log),
  CONSTRAINT fk_log_auditoria_id_resultado FOREIGN KEY (id_resultado) REFERENCES resultado_log (id_resultado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indices para el tuning de los reportes (ver 05_Backend, seccion reportes). No repiten los de PK, UNIQUE y FK.
-- rango de fechas + reunion con recurso (sp_rep_prestamos_por_carro)
CREATE INDEX ix_prestamo_fecha_recurso ON prestamo_ct (fecha_prestamo, id_recurso);
-- conteo por usuario y fecha (actividad_por_usuario y su tuneado)
CREATE INDEX ix_prestamo_solic_fecha ON prestamo_ct (id_usuario_solicitante, fecha_prestamo);
-- rango de fechas + sector (sp_rep_ocupacion_sectores)
CREATE INDEX ix_reserva_fecha_sector ON reserva_sector (fecha_reserva, id_sector);
-- conteo por usuario y fecha (actividad_por_usuario y su tuneado)
CREATE INDEX ix_reserva_usuario_fecha ON reserva_sector (id_usuario, fecha_reserva);
-- conteo por usuario y fecha (actividad_por_usuario y su tuneado)
CREATE INDEX ix_reclamo_usuario_fecha ON reclamo_objeto (id_usuario, fecha_reclamo);
-- indice cubridor de sp_rep_objetos_por_categoria_estado
CREATE INDEX ix_objeto_fecha_cat_estado ON objeto_perdido (fecha_registro, id_categoria_objeto, id_estado_objeto);
-- rango de fechas (sp_rep_higiene_por_sector)
CREATE INDEX ix_higiene_fecha_sector ON reporte_higiene (fecha_hora, id_sector);
-- igualdad por estado + rango de fechas (ventas_por_producto y su tuneado, recaudado_por_grupo)
CREATE INDEX ix_venta_estado_fecha ON venta_buffet (id_estado_venta, fecha_hora);
-- rango de fechas (sp_rep_recaudado_por_grupo)
CREATE INDEX ix_donacion_fecha_grupo ON donacion_buffet (fecha_hora, id_grupo);
-- rango de fechas (sp_rep_inscriptos_por_deporte)
CREATE INDEX ix_inscripcion_fecha_oferta ON inscripcion_ed_fisica (fecha_inscripcion, id_oferta);
-- rango de fechas obligatorio (sp_rep_auditoria)
CREATE INDEX ix_log_fecha_tipo ON log_auditoria (fecha_hora, id_tipo_log);
-- filtro por usuario + fecha (sp_rep_auditoria)
CREATE INDEX ix_log_usuario_fecha ON log_auditoria (id_usuario, fecha_hora);
