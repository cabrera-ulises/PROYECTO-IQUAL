-- PROYECTO IQUAL (SGE) - MySQL 8 - modelo en 3FN (CONTEXTO_IQUAL v2.3)
CREATE DATABASE IF NOT EXISTS iqual CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE iqual;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS log_auditoria;
DROP TABLE IF EXISTS inscripcion_ed_fisica;
DROP TABLE IF EXISTS oferta_deporte;
DROP TABLE IF EXISTS reserva_sector;
DROP TABLE IF EXISTS prestamo_ct;
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
  CONSTRAINT pk_producto_buffet PRIMARY KEY (id_producto),
  CONSTRAINT fk_producto_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_producto_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo),
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

INSERT INTO rol (nombre_rol) VALUES ('Alumno');
INSERT INTO rol (nombre_rol) VALUES ('Profesor');
INSERT INTO rol (nombre_rol) VALUES ('Preceptor');
INSERT INTO rol (nombre_rol) VALUES ('Maestranza');
INSERT INTO especialidad (nombre_especialidad) VALUES ('Computación');
INSERT INTO especialidad (nombre_especialidad) VALUES ('Electrónica');
INSERT INTO especialidad (nombre_especialidad) VALUES ('Mecánica');
INSERT INTO turno (nombre_turno) VALUES ('Mañana');
INSERT INTO turno (nombre_turno) VALUES ('Tarde');
INSERT INTO dia_semana (nombre_dia) VALUES ('Lunes');
INSERT INTO dia_semana (nombre_dia) VALUES ('Martes');
INSERT INTO dia_semana (nombre_dia) VALUES ('Miércoles');
INSERT INTO dia_semana (nombre_dia) VALUES ('Jueves');
INSERT INTO dia_semana (nombre_dia) VALUES ('Viernes');
INSERT INTO categoria_objeto (nombre_categoria) VALUES ('Útiles');
INSERT INTO categoria_objeto (nombre_categoria) VALUES ('Ropa');
INSERT INTO categoria_objeto (nombre_categoria) VALUES ('Llaves');
INSERT INTO categoria_objeto (nombre_categoria) VALUES ('Electrónica');
INSERT INTO categoria_objeto (nombre_categoria) VALUES ('Documentación');
INSERT INTO categoria_objeto (nombre_categoria) VALUES ('Otros');
INSERT INTO estado_objeto (nombre_estado) VALUES ('Disponible');
INSERT INTO estado_objeto (nombre_estado) VALUES ('En reclamo');
INSERT INTO estado_objeto (nombre_estado) VALUES ('Devuelto');
INSERT INTO estado_objeto (nombre_estado) VALUES ('Archivado');
INSERT INTO estado_reclamo (nombre_estado) VALUES ('Pendiente');
INSERT INTO estado_reclamo (nombre_estado) VALUES ('Aprobado');
INSERT INTO estado_reclamo (nombre_estado) VALUES ('Rechazado');
INSERT INTO tipo_reporte (nombre_tipo) VALUES ('Rotura');
INSERT INTO tipo_reporte (nombre_tipo) VALUES ('Limpieza');
INSERT INTO estado_reporte (nombre_estado) VALUES ('Pendiente');
INSERT INTO estado_reporte (nombre_estado) VALUES ('Resuelto');
INSERT INTO estado_reserva (nombre_estado) VALUES ('Pendiente');
INSERT INTO estado_reserva (nombre_estado) VALUES ('Aprobada');
INSERT INTO estado_reserva (nombre_estado) VALUES ('Rechazada');
INSERT INTO estado_reserva (nombre_estado) VALUES ('Cancelada');
INSERT INTO estado_venta (nombre_estado) VALUES ('Reservada');
INSERT INTO estado_venta (nombre_estado) VALUES ('Entregada');
INSERT INTO estado_venta (nombre_estado) VALUES ('Cancelada');
INSERT INTO tipo_recurso (nombre_tipo) VALUES ('Computadora');
INSERT INTO tipo_recurso (nombre_tipo) VALUES ('Tablero de dibujo');
INSERT INTO estado_recurso (nombre_estado) VALUES ('Disponible');
INSERT INTO estado_recurso (nombre_estado) VALUES ('Prestado');
INSERT INTO estado_recurso (nombre_estado) VALUES ('Fuera de servicio');
INSERT INTO carro (nombre_carro) VALUES ('C1');
INSERT INTO carro (nombre_carro) VALUES ('C2');
INSERT INTO carro (nombre_carro) VALUES ('C3');
INSERT INTO carro (nombre_carro) VALUES ('C4');
INSERT INTO carro (nombre_carro) VALUES ('C5');
INSERT INTO deporte (nombre_deporte) VALUES ('Fútbol');
INSERT INTO deporte (nombre_deporte) VALUES ('Vóley');
INSERT INTO deporte (nombre_deporte) VALUES ('Básquet');
INSERT INTO deporte (nombre_deporte) VALUES ('Handball');
INSERT INTO tipo_log (nombre_evento) VALUES ('Inicio de sesión');
INSERT INTO tipo_log (nombre_evento) VALUES ('Cierre de sesión');
INSERT INTO tipo_log (nombre_evento) VALUES ('Registro de usuario');
INSERT INTO tipo_log (nombre_evento) VALUES ('Publicación de objeto');
INSERT INTO tipo_log (nombre_evento) VALUES ('Reclamo de objeto');
INSERT INTO tipo_log (nombre_evento) VALUES ('Resolución de reclamo');
INSERT INTO tipo_log (nombre_evento) VALUES ('Reporte de higiene');
INSERT INTO tipo_log (nombre_evento) VALUES ('Resolución de reporte');
INSERT INTO tipo_log (nombre_evento) VALUES ('Reserva de producto');
INSERT INTO tipo_log (nombre_evento) VALUES ('Donación');
INSERT INTO tipo_log (nombre_evento) VALUES ('Préstamo de recurso');
INSERT INTO tipo_log (nombre_evento) VALUES ('Devolución de recurso');
INSERT INTO tipo_log (nombre_evento) VALUES ('Reserva de sector');
INSERT INTO tipo_log (nombre_evento) VALUES ('Inscripción a Ed. Física');
INSERT INTO resultado_log (nombre_resultado) VALUES ('Exitoso');
INSERT INTO resultado_log (nombre_resultado) VALUES ('Fallido');
INSERT INTO entidad_log (nombre_entidad) VALUES ('usuario');
INSERT INTO entidad_log (nombre_entidad) VALUES ('objeto_perdido');
INSERT INTO entidad_log (nombre_entidad) VALUES ('reclamo_objeto');
INSERT INTO entidad_log (nombre_entidad) VALUES ('consulta_objeto');
INSERT INTO entidad_log (nombre_entidad) VALUES ('reporte_higiene');
INSERT INTO entidad_log (nombre_entidad) VALUES ('grupo_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES ('producto_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES ('venta_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES ('donacion_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES ('prestamo_ct');
INSERT INTO entidad_log (nombre_entidad) VALUES ('reserva_sector');
INSERT INTO entidad_log (nombre_entidad) VALUES ('inscripcion_ed_fisica');
INSERT INTO tipo_sector (nombre_tipo) VALUES ('Reservable');
INSERT INTO tipo_sector (nombre_tipo) VALUES ('Uso común');
INSERT INTO anio (numero_anio) VALUES (1);
INSERT INTO anio (numero_anio) VALUES (2);
INSERT INTO anio (numero_anio) VALUES (3);
INSERT INTO anio (numero_anio) VALUES (4);
INSERT INTO anio (numero_anio) VALUES (5);
INSERT INTO anio (numero_anio) VALUES (6);
INSERT INTO anio (numero_anio) VALUES (7);
INSERT INTO division (numero_division) VALUES (1);
INSERT INTO division (numero_division) VALUES (2);
INSERT INTO division (numero_division) VALUES (3);
INSERT INTO division (numero_division) VALUES (4);
INSERT INTO division (numero_division) VALUES (5);
INSERT INTO division (numero_division) VALUES (6);
INSERT INTO division (numero_division) VALUES (7);
INSERT INTO division (numero_division) VALUES (8);
INSERT INTO division (numero_division) VALUES (9);
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES ('08:00', '10:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES ('10:00', '12:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES ('12:00', '14:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES ('14:00', '16:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES ('16:00', '18:00');
INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES ((SELECT id_anio FROM anio WHERE numero_anio = 4), (SELECT id_division FROM division WHERE numero_division = 1), (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación'));
INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES ((SELECT id_anio FROM anio WHERE numero_anio = 4), (SELECT id_division FROM division WHERE numero_division = 2), (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación'));
INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES ((SELECT id_anio FROM anio WHERE numero_anio = 5), (SELECT id_division FROM division WHERE numero_division = 2), (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Electrónica'));
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (40000001, 'Alumno Uno', 'alumno1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'alumno1@iqual.demo', '1155550001', (SELECT id_rol FROM rol WHERE nombre_rol = 'Alumno'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')));
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (40000002, 'Alumno Dos', 'alumno2', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'alumno2@iqual.demo', '1155550002', (SELECT id_rol FROM rol WHERE nombre_rol = 'Alumno'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 5) AND id_division = (SELECT id_division FROM division WHERE numero_division = 2) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Electrónica')));
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (30000003, 'Profesor Uno', 'profe1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'profe1@iqual.demo', '1155550003', (SELECT id_rol FROM rol WHERE nombre_rol = 'Profesor'), NULL);
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (30000004, 'Preceptor Uno', 'preceptor1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'preceptor1@iqual.demo', '1155550004', (SELECT id_rol FROM rol WHERE nombre_rol = 'Preceptor'), NULL);
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (30000005, 'Maestranza Uno', 'maestranza1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'maestranza1@iqual.demo', '1155550005', (SELECT id_rol FROM rol WHERE nombre_rol = 'Maestranza'), NULL);
INSERT INTO materia (nombre_materia, codigo_materia) VALUES ('Programación', 'PRG-401');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES ('Bases de Datos', 'BDD-402');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES ('Matemática', 'MAT-403');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES ('Lengua y Literatura', 'LEN-404');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES ('Proyecto Informático I', 'PRY-405');
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES ('13:00', '14:40', (SELECT id_materia FROM materia WHERE nombre_materia = 'Programación'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = 'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES ('14:50', '16:30', (SELECT id_materia FROM materia WHERE nombre_materia = 'Bases de Datos'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = 'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES ('13:00', '14:40', (SELECT id_materia FROM materia WHERE nombre_materia = 'Matemática'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = 'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES ('14:50', '16:30', (SELECT id_materia FROM materia WHERE nombre_materia = 'Lengua y Literatura'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = 'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES ('14:50', '16:30', (SELECT id_materia FROM materia WHERE nombre_materia = 'Proyecto Informático I'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = 'Tarde'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Programación') AND hora_inicio = '13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Programación') AND hora_inicio = '13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Miércoles'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Bases de Datos') AND hora_inicio = '14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Martes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Bases de Datos') AND hora_inicio = '14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Jueves'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Matemática') AND hora_inicio = '13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Martes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Matemática') AND hora_inicio = '13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Viernes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Lengua y Literatura') AND hora_inicio = '14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Miércoles'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Lengua y Literatura') AND hora_inicio = '14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Viernes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = 'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = 'Proyecto Informático I') AND hora_inicio = '14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Laboratorio de química', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Reservable'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Biblioteca', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Reservable'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('SUM', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Reservable'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Baño planta baja', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Baño planta alta', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Aula', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Patio', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Preceptoría', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Taller de computación', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Uso común'));
INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES ('Campera azul', 'Campera azul de abrigo con capucha, talle M', NULL, '2026-10-19', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_categoria_objeto FROM categoria_objeto WHERE nombre_categoria = 'Ropa'), (SELECT id_estado_objeto FROM estado_objeto WHERE nombre_estado = 'Disponible'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Patio'));
INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES ('Llaves con llavero rojo', 'Dos llaves con un llavero rojo de goma', NULL, '2026-10-20', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_categoria_objeto FROM categoria_objeto WHERE nombre_categoria = 'Llaves'), (SELECT id_estado_objeto FROM estado_objeto WHERE nombre_estado = 'En reclamo'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Aula'));
INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES ('Calculadora científica', 'Calculadora científica negra con funda', NULL, '2026-10-15', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_categoria_objeto FROM categoria_objeto WHERE nombre_categoria = 'Electrónica'), (SELECT id_estado_objeto FROM estado_objeto WHERE nombre_estado = 'Devuelto'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Biblioteca'));
INSERT INTO reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) VALUES ('El llavero tiene mi nombre grabado en la parte de atrás', '2026-10-21', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_objeto FROM objeto_perdido WHERE titulo = 'Llaves con llavero rojo'), (SELECT id_estado_reclamo FROM estado_reclamo WHERE nombre_estado = 'Pendiente'));
INSERT INTO reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) VALUES ('Tiene mis iniciales escritas en la funda de la calculadora', '2026-10-16', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), (SELECT id_objeto FROM objeto_perdido WHERE titulo = 'Calculadora científica'), (SELECT id_estado_reclamo FROM estado_reclamo WHERE nombre_estado = 'Aprobado'));
INSERT INTO consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES ('2026-10-22', 'Perdí un buzo gris en el patio, alguien lo vio?', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'));
INSERT INTO consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES ('2026-10-23', 'Busco una botella térmica verde que dejé en el aula', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'));
INSERT INTO reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte, fecha_hora_resolucion, id_usuario_resolutor) VALUES ('2026-10-21 09:15:00', 'Falta papel y hay que limpiar el piso', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Baño planta baja'), (SELECT id_tipo_reporte FROM tipo_reporte WHERE nombre_tipo = 'Limpieza'), (SELECT id_estado_reporte FROM estado_reporte WHERE nombre_estado = 'Pendiente'), NULL, NULL);
INSERT INTO reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte, fecha_hora_resolucion, id_usuario_resolutor) VALUES ('2026-10-19 10:30:00', 'Hay una silla rota en el fondo del aula', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Aula'), (SELECT id_tipo_reporte FROM tipo_reporte WHERE nombre_tipo = 'Rotura'), (SELECT id_estado_reporte FROM estado_reporte WHERE nombre_estado = 'Resuelto'), '2026-10-20 08:45:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'maestranza1'));
INSERT INTO grupo_buffet (nombre_grupo, pin_acceso, meta_monto) VALUES ('Viaje de Estudios 4to 1ra', '2468', 50000);
INSERT INTO integrante_grupo (id_usuario, id_grupo) VALUES ((SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = 'Viaje de Estudios 4to 1ra'));
INSERT INTO integrante_grupo (id_usuario, id_grupo) VALUES ((SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = 'Viaje de Estudios 4to 1ra'));
INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES ('Alfajor de dulce de leche', 800, 18, (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = 'Viaje de Estudios 4to 1ra'));
INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES ('Sándwich de miga', 1500, 9, (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = 'Viaje de Estudios 4to 1ra'));
INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES ('Jugo en caja', 700, 15, (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), NULL);
INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES ('2026-10-22 10:20:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = 'Reservada'));
INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES ('2026-10-22 11:05:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = 'Entregada'));
INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES ('2026-10-23 09:40:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = 'Cancelada'));
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES ((SELECT id_venta FROM venta_buffet WHERE fecha_hora = '2026-10-22 10:20:00' AND id_usuario = (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1')), (SELECT id_producto FROM producto_buffet WHERE nombre_producto = 'Alfajor de dulce de leche'), 2, 800);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES ((SELECT id_venta FROM venta_buffet WHERE fecha_hora = '2026-10-22 11:05:00' AND id_usuario = (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1')), (SELECT id_producto FROM producto_buffet WHERE nombre_producto = 'Sándwich de miga'), 1, 1500);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES ((SELECT id_venta FROM venta_buffet WHERE fecha_hora = '2026-10-23 09:40:00' AND id_usuario = (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2')), (SELECT id_producto FROM producto_buffet WHERE nombre_producto = 'Alfajor de dulce de leche'), 1, 800);
INSERT INTO donacion_buffet (monto, fecha_hora, id_usuario, id_grupo) VALUES (2000, '2026-10-22 12:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = 'Viaje de Estudios 4to 1ra'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 2, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 3, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 4, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 5, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Prestado'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 6, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 7, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 8, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 9, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 10, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 2, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 3, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 4, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 5, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 6, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 7, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 8, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 9, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C5'), 10, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 2, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 3, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 4, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 5, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 6, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 7, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Fuera de servicio'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 8, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 9, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 10, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) VALUES ('2026-10-23', '14:10', NULL, NULL, (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_recurso FROM recursos_ct WHERE id_tipo_recurso = (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora') AND id_carro = (SELECT id_carro FROM carro WHERE nombre_carro = 'C4') AND numero_equipo = 5));
INSERT INTO prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) VALUES ('2026-10-22', '13:30', '15:10', 'Funciona', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_recurso FROM recursos_ct WHERE id_tipo_recurso = (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora') AND id_carro = (SELECT id_carro FROM carro WHERE nombre_carro = 'C5') AND numero_equipo = 2));
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('2026-11-05', '10:00', '11:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Biblioteca'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = 'Pendiente'), NULL);
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('2026-11-05', '09:00', '11:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_sector FROM sector WHERE nombre_sector = 'SUM'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = 'Aprobada'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'));
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('2026-11-05', '11:30', '12:30', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Biblioteca'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = 'Cancelada'), NULL);
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('2026-11-06', '08:00', '10:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = 'Laboratorio de química'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = 'Aprobada'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'));
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '10:00' AND hora_fin = '12:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '08:00' AND hora_fin = '10:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '16:00' AND hora_fin = '18:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '12:00' AND hora_fin = '14:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '14:00' AND hora_fin = '16:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '14:00' AND hora_fin = '16:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '14:00' AND hora_fin = '16:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '10:00' AND hora_fin = '12:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '16:00' AND hora_fin = '18:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '08:00' AND hora_fin = '10:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '16:00' AND hora_fin = '18:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '10:00' AND hora_fin = '12:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '12:00' AND hora_fin = '14:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '14:00' AND hora_fin = '16:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '10:00' AND hora_fin = '12:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '08:00' AND hora_fin = '10:00'), 1);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '16:00' AND hora_fin = '18:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '14:00' AND hora_fin = '16:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '08:00' AND hora_fin = '10:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '12:00' AND hora_fin = '14:00'), 15);
INSERT INTO inscripcion_ed_fisica (fecha_inscripcion, id_usuario, id_oferta) VALUES ('2026-10-22', (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), (SELECT id_oferta FROM oferta_deporte WHERE id_deporte = (SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Handball') AND id_dia = (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes') AND id_franja = (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '08:00' AND hora_fin = '10:00')));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-21 08:00:05', 'PC-PRECEPTORIA', 'Inicio de sesión exitoso de preceptor1', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'usuario'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Inicio de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-21 08:05:40', 'PC-PRECEPTORIA', 'Publicación del objeto Llaves con llavero rojo', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'objeto_perdido'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Publicación de objeto'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-21 09:14:50', 'PC-LAB-01', 'Inicio de sesión exitoso de alumno1', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'usuario'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Inicio de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-21 09:15:10', 'PC-LAB-01', 'Reporte de higiene en Baño planta baja', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'reporte_higiene'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Reporte de higiene'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-21 09:30:00', 'PC-LAB-01', 'Reclamo del objeto Llaves con llavero rojo', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'reclamo_objeto'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Reclamo de objeto'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-21 10:02:11', 'PC-LAB-02', 'Intento de inicio de sesión con usuario inexistente', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'usuario'), NULL, (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Inicio de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Fallido'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-22 10:20:00', 'PC-PRECEPTORIA', 'Reserva de Alfajor de dulce de leche', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'venta_buffet'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Reserva de producto'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-22 12:00:00', 'PC-SALA-PROF', 'Donación de 2000 al grupo Viaje de Estudios 4to 1ra', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'donacion_buffet'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Donación'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-22 13:30:00', 'PC-PRECEPTORIA', 'Préstamo del recurso C5-02', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'prestamo_ct'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Préstamo de recurso'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-22 15:10:00', 'PC-PRECEPTORIA', 'Devolución del recurso C5-02', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'prestamo_ct'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Devolución de recurso'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-22 16:00:00', 'PC-LAB-01', 'Inscripción a Ed. Física Handball lunes', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'inscripcion_ed_fisica'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno2'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Inscripción a Ed. Física'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-23 08:10:00', 'PC-LAB-01', 'Inscripción rechazada por superposición con Bases de Datos', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'inscripcion_ed_fisica'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Inscripción a Ed. Física'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Fallido'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-23 08:20:00', 'PC-LAB-01', 'Inscripción rechazada por cupo lleno', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'inscripcion_ed_fisica'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Inscripción a Ed. Física'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Fallido'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-23 09:00:00', 'PC-SALA-PROF', 'Reserva del sector Biblioteca', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'reserva_sector'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'profe1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Reserva de sector'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('2026-10-23 09:45:00', 'PC-LAB-01', 'Cierre de sesión de alumno1', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = 'usuario'), (SELECT id_usuario FROM usuario WHERE usuario_nick = 'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = 'Cierre de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso'));
