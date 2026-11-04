-- PROYECTO IQUAL (SGE) - SQL Server 2005 - modelo en 3FN (CONTEXTO_IQUAL v2.3)
IF DB_ID('iqual') IS NULL CREATE DATABASE iqual;
GO
USE iqual;
GO
IF OBJECT_ID('log_auditoria', 'U') IS NOT NULL DROP TABLE log_auditoria;
IF OBJECT_ID('inscripcion_ed_fisica', 'U') IS NOT NULL DROP TABLE inscripcion_ed_fisica;
IF OBJECT_ID('oferta_deporte', 'U') IS NOT NULL DROP TABLE oferta_deporte;
IF OBJECT_ID('reserva_sector', 'U') IS NOT NULL DROP TABLE reserva_sector;
IF OBJECT_ID('prestamo_ct', 'U') IS NOT NULL DROP TABLE prestamo_ct;
IF OBJECT_ID('recursos_ct', 'U') IS NOT NULL DROP TABLE recursos_ct;
IF OBJECT_ID('donacion_buffet', 'U') IS NOT NULL DROP TABLE donacion_buffet;
IF OBJECT_ID('detalle_venta', 'U') IS NOT NULL DROP TABLE detalle_venta;
IF OBJECT_ID('venta_buffet', 'U') IS NOT NULL DROP TABLE venta_buffet;
IF OBJECT_ID('producto_buffet', 'U') IS NOT NULL DROP TABLE producto_buffet;
IF OBJECT_ID('integrante_grupo', 'U') IS NOT NULL DROP TABLE integrante_grupo;
IF OBJECT_ID('grupo_buffet', 'U') IS NOT NULL DROP TABLE grupo_buffet;
IF OBJECT_ID('reporte_higiene', 'U') IS NOT NULL DROP TABLE reporte_higiene;
IF OBJECT_ID('consulta_objeto', 'U') IS NOT NULL DROP TABLE consulta_objeto;
IF OBJECT_ID('reclamo_objeto', 'U') IS NOT NULL DROP TABLE reclamo_objeto;
IF OBJECT_ID('objeto_perdido', 'U') IS NOT NULL DROP TABLE objeto_perdido;
IF OBJECT_ID('sector', 'U') IS NOT NULL DROP TABLE sector;
IF OBJECT_ID('horario_dia', 'U') IS NOT NULL DROP TABLE horario_dia;
IF OBJECT_ID('horario_escolar', 'U') IS NOT NULL DROP TABLE horario_escolar;
IF OBJECT_ID('materia', 'U') IS NOT NULL DROP TABLE materia;
IF OBJECT_ID('usuario', 'U') IS NOT NULL DROP TABLE usuario;
IF OBJECT_ID('curso', 'U') IS NOT NULL DROP TABLE curso;
IF OBJECT_ID('franja_horaria', 'U') IS NOT NULL DROP TABLE franja_horaria;
IF OBJECT_ID('division', 'U') IS NOT NULL DROP TABLE division;
IF OBJECT_ID('anio', 'U') IS NOT NULL DROP TABLE anio;
IF OBJECT_ID('tipo_sector', 'U') IS NOT NULL DROP TABLE tipo_sector;
IF OBJECT_ID('entidad_log', 'U') IS NOT NULL DROP TABLE entidad_log;
IF OBJECT_ID('resultado_log', 'U') IS NOT NULL DROP TABLE resultado_log;
IF OBJECT_ID('tipo_log', 'U') IS NOT NULL DROP TABLE tipo_log;
IF OBJECT_ID('deporte', 'U') IS NOT NULL DROP TABLE deporte;
IF OBJECT_ID('carro', 'U') IS NOT NULL DROP TABLE carro;
IF OBJECT_ID('estado_recurso', 'U') IS NOT NULL DROP TABLE estado_recurso;
IF OBJECT_ID('tipo_recurso', 'U') IS NOT NULL DROP TABLE tipo_recurso;
IF OBJECT_ID('estado_venta', 'U') IS NOT NULL DROP TABLE estado_venta;
IF OBJECT_ID('estado_reserva', 'U') IS NOT NULL DROP TABLE estado_reserva;
IF OBJECT_ID('estado_reporte', 'U') IS NOT NULL DROP TABLE estado_reporte;
IF OBJECT_ID('tipo_reporte', 'U') IS NOT NULL DROP TABLE tipo_reporte;
IF OBJECT_ID('estado_reclamo', 'U') IS NOT NULL DROP TABLE estado_reclamo;
IF OBJECT_ID('estado_objeto', 'U') IS NOT NULL DROP TABLE estado_objeto;
IF OBJECT_ID('categoria_objeto', 'U') IS NOT NULL DROP TABLE categoria_objeto;
IF OBJECT_ID('dia_semana', 'U') IS NOT NULL DROP TABLE dia_semana;
IF OBJECT_ID('turno', 'U') IS NOT NULL DROP TABLE turno;
IF OBJECT_ID('especialidad', 'U') IS NOT NULL DROP TABLE especialidad;
IF OBJECT_ID('rol', 'U') IS NOT NULL DROP TABLE rol;
GO
CREATE TABLE rol (
  id_rol INT IDENTITY(1,1) NOT NULL,
  nombre_rol NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_rol PRIMARY KEY (id_rol),
  CONSTRAINT uq_rol_nombre_rol UNIQUE (nombre_rol)
);

CREATE TABLE especialidad (
  id_especialidad INT IDENTITY(1,1) NOT NULL,
  nombre_especialidad NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_especialidad PRIMARY KEY (id_especialidad),
  CONSTRAINT uq_especialidad_nombre_especialidad UNIQUE (nombre_especialidad)
);

CREATE TABLE turno (
  id_turno INT IDENTITY(1,1) NOT NULL,
  nombre_turno NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_turno PRIMARY KEY (id_turno),
  CONSTRAINT uq_turno_nombre_turno UNIQUE (nombre_turno)
);

CREATE TABLE dia_semana (
  id_dia INT IDENTITY(1,1) NOT NULL,
  nombre_dia NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_dia_semana PRIMARY KEY (id_dia),
  CONSTRAINT uq_dia_semana_nombre_dia UNIQUE (nombre_dia)
);

CREATE TABLE categoria_objeto (
  id_categoria_objeto INT IDENTITY(1,1) NOT NULL,
  nombre_categoria NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_categoria_objeto PRIMARY KEY (id_categoria_objeto),
  CONSTRAINT uq_categoria_objeto_nombre_categoria UNIQUE (nombre_categoria)
);

CREATE TABLE estado_objeto (
  id_estado_objeto INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_objeto PRIMARY KEY (id_estado_objeto),
  CONSTRAINT uq_estado_objeto_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE estado_reclamo (
  id_estado_reclamo INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reclamo PRIMARY KEY (id_estado_reclamo),
  CONSTRAINT uq_estado_reclamo_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE tipo_reporte (
  id_tipo_reporte INT IDENTITY(1,1) NOT NULL,
  nombre_tipo NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_reporte PRIMARY KEY (id_tipo_reporte),
  CONSTRAINT uq_tipo_reporte_nombre_tipo UNIQUE (nombre_tipo)
);

CREATE TABLE estado_reporte (
  id_estado_reporte INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reporte PRIMARY KEY (id_estado_reporte),
  CONSTRAINT uq_estado_reporte_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE estado_reserva (
  id_estado_reserva INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reserva PRIMARY KEY (id_estado_reserva),
  CONSTRAINT uq_estado_reserva_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE estado_venta (
  id_estado_venta INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_venta PRIMARY KEY (id_estado_venta),
  CONSTRAINT uq_estado_venta_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE tipo_recurso (
  id_tipo_recurso INT IDENTITY(1,1) NOT NULL,
  nombre_tipo NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_recurso PRIMARY KEY (id_tipo_recurso),
  CONSTRAINT uq_tipo_recurso_nombre_tipo UNIQUE (nombre_tipo)
);

CREATE TABLE estado_recurso (
  id_estado_recurso INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_recurso PRIMARY KEY (id_estado_recurso),
  CONSTRAINT uq_estado_recurso_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE carro (
  id_carro INT IDENTITY(1,1) NOT NULL,
  nombre_carro NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_carro PRIMARY KEY (id_carro),
  CONSTRAINT uq_carro_nombre_carro UNIQUE (nombre_carro)
);

CREATE TABLE deporte (
  id_deporte INT IDENTITY(1,1) NOT NULL,
  nombre_deporte NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_deporte PRIMARY KEY (id_deporte),
  CONSTRAINT uq_deporte_nombre_deporte UNIQUE (nombre_deporte)
);

CREATE TABLE tipo_log (
  id_tipo_log INT IDENTITY(1,1) NOT NULL,
  nombre_evento NVARCHAR(80) NOT NULL,
  CONSTRAINT pk_tipo_log PRIMARY KEY (id_tipo_log),
  CONSTRAINT uq_tipo_log_nombre_evento UNIQUE (nombre_evento)
);

CREATE TABLE resultado_log (
  id_resultado INT IDENTITY(1,1) NOT NULL,
  nombre_resultado NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_resultado_log PRIMARY KEY (id_resultado),
  CONSTRAINT uq_resultado_log_nombre_resultado UNIQUE (nombre_resultado)
);

CREATE TABLE entidad_log (
  id_entidad INT IDENTITY(1,1) NOT NULL,
  nombre_entidad NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_entidad_log PRIMARY KEY (id_entidad),
  CONSTRAINT uq_entidad_log_nombre_entidad UNIQUE (nombre_entidad)
);

CREATE TABLE tipo_sector (
  id_tipo_sector INT IDENTITY(1,1) NOT NULL,
  nombre_tipo NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_sector PRIMARY KEY (id_tipo_sector),
  CONSTRAINT uq_tipo_sector_nombre_tipo UNIQUE (nombre_tipo)
);

CREATE TABLE anio (
  id_anio INT IDENTITY(1,1) NOT NULL,
  numero_anio INT NOT NULL,
  CONSTRAINT pk_anio PRIMARY KEY (id_anio),
  CONSTRAINT uq_anio_numero_anio UNIQUE (numero_anio),
  CONSTRAINT ck_anio CHECK (numero_anio BETWEEN 1 AND 7)
);

CREATE TABLE division (
  id_division INT IDENTITY(1,1) NOT NULL,
  numero_division INT NOT NULL,
  CONSTRAINT pk_division PRIMARY KEY (id_division),
  CONSTRAINT uq_division_numero_division UNIQUE (numero_division),
  CONSTRAINT ck_division CHECK (numero_division BETWEEN 1 AND 9)
);

CREATE TABLE franja_horaria (
  id_franja INT IDENTITY(1,1) NOT NULL,
  hora_inicio NVARCHAR(5) NOT NULL,
  hora_fin NVARCHAR(5) NOT NULL,
  CONSTRAINT pk_franja_horaria PRIMARY KEY (id_franja),
  CONSTRAINT ck_franja CHECK (hora_fin > hora_inicio)
);

CREATE TABLE curso (
  id_curso INT IDENTITY(1,1) NOT NULL,
  id_anio INT NOT NULL,
  id_division INT NOT NULL,
  id_especialidad INT NOT NULL,
  CONSTRAINT pk_curso PRIMARY KEY (id_curso),
  CONSTRAINT fk_curso_id_anio FOREIGN KEY (id_anio) REFERENCES anio (id_anio),
  CONSTRAINT fk_curso_id_division FOREIGN KEY (id_division) REFERENCES division (id_division),
  CONSTRAINT fk_curso_id_especialidad FOREIGN KEY (id_especialidad) REFERENCES especialidad (id_especialidad),
  CONSTRAINT uq_curso_id_anio_id_division_id_especialidad UNIQUE (id_anio, id_division, id_especialidad)
);

CREATE TABLE usuario (
  id_usuario INT IDENTITY(1,1) NOT NULL,
  dni INT NOT NULL,
  nombre_completo NVARCHAR(80) NOT NULL,
  usuario_nick NVARCHAR(50) NOT NULL,
  password_hash CHAR(64) NOT NULL,
  email NVARCHAR(80) NOT NULL,
  contacto_telefono NVARCHAR(15) NOT NULL,
  id_rol INT NOT NULL,
  id_curso INT NULL,
  CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuario_dni UNIQUE (dni),
  CONSTRAINT uq_usuario_usuario_nick UNIQUE (usuario_nick),
  CONSTRAINT uq_usuario_email UNIQUE (email),
  CONSTRAINT fk_usuario_id_rol FOREIGN KEY (id_rol) REFERENCES rol (id_rol),
  CONSTRAINT fk_usuario_id_curso FOREIGN KEY (id_curso) REFERENCES curso (id_curso),
  CONSTRAINT ck_usuario_dni CHECK (dni BETWEEN 1000000 AND 99999999)
);

CREATE TABLE materia (
  id_materia INT IDENTITY(1,1) NOT NULL,
  nombre_materia NVARCHAR(80) NOT NULL,
  codigo_materia NVARCHAR(20) NOT NULL,
  CONSTRAINT pk_materia PRIMARY KEY (id_materia),
  CONSTRAINT uq_materia_codigo_materia UNIQUE (codigo_materia)
);

CREATE TABLE horario_escolar (
  id_bloque INT IDENTITY(1,1) NOT NULL,
  hora_inicio NVARCHAR(5) NOT NULL,
  hora_fin NVARCHAR(5) NOT NULL,
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
);

CREATE TABLE horario_dia (
  id_bloque INT NOT NULL,
  id_dia INT NOT NULL,
  CONSTRAINT pk_horario_dia PRIMARY KEY (id_bloque, id_dia),
  CONSTRAINT fk_horario_dia_id_bloque FOREIGN KEY (id_bloque) REFERENCES horario_escolar (id_bloque),
  CONSTRAINT fk_horario_dia_id_dia FOREIGN KEY (id_dia) REFERENCES dia_semana (id_dia)
);

CREATE TABLE sector (
  id_sector INT IDENTITY(1,1) NOT NULL,
  nombre_sector NVARCHAR(80) NOT NULL,
  id_tipo_sector INT NOT NULL,
  CONSTRAINT pk_sector PRIMARY KEY (id_sector),
  CONSTRAINT uq_sector_nombre_sector UNIQUE (nombre_sector),
  CONSTRAINT fk_sector_id_tipo_sector FOREIGN KEY (id_tipo_sector) REFERENCES tipo_sector (id_tipo_sector)
);

CREATE TABLE objeto_perdido (
  id_objeto INT IDENTITY(1,1) NOT NULL,
  titulo NVARCHAR(80) NOT NULL,
  descripcion NVARCHAR(200) NULL,
  ruta_foto NVARCHAR(150) NULL,
  fecha_registro DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_categoria_objeto INT NOT NULL,
  id_estado_objeto INT NOT NULL,
  id_sector INT NOT NULL,
  CONSTRAINT pk_objeto_perdido PRIMARY KEY (id_objeto),
  CONSTRAINT fk_objeto_perdido_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_objeto_perdido_id_categoria_objeto FOREIGN KEY (id_categoria_objeto) REFERENCES categoria_objeto (id_categoria_objeto),
  CONSTRAINT fk_objeto_perdido_id_estado_objeto FOREIGN KEY (id_estado_objeto) REFERENCES estado_objeto (id_estado_objeto),
  CONSTRAINT fk_objeto_perdido_id_sector FOREIGN KEY (id_sector) REFERENCES sector (id_sector)
);

CREATE TABLE reclamo_objeto (
  id_reclamo INT IDENTITY(1,1) NOT NULL,
  prueba_pertenencia NVARCHAR(200) NOT NULL,
  fecha_reclamo DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_objeto INT NOT NULL,
  id_estado_reclamo INT NOT NULL,
  CONSTRAINT pk_reclamo_objeto PRIMARY KEY (id_reclamo),
  CONSTRAINT fk_reclamo_objeto_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_reclamo_objeto_id_objeto FOREIGN KEY (id_objeto) REFERENCES objeto_perdido (id_objeto),
  CONSTRAINT fk_reclamo_objeto_id_estado_reclamo FOREIGN KEY (id_estado_reclamo) REFERENCES estado_reclamo (id_estado_reclamo)
);

CREATE TABLE consulta_objeto (
  id_consulta INT IDENTITY(1,1) NOT NULL,
  fecha_publicacion DATETIME NOT NULL,
  descripcion_busqueda NVARCHAR(200) NOT NULL,
  id_usuario INT NOT NULL,
  CONSTRAINT pk_consulta_objeto PRIMARY KEY (id_consulta),
  CONSTRAINT fk_consulta_objeto_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

CREATE TABLE reporte_higiene (
  id_reporte INT IDENTITY(1,1) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  observaciones NVARCHAR(200) NOT NULL,
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
);

CREATE TABLE grupo_buffet (
  id_grupo INT IDENTITY(1,1) NOT NULL,
  nombre_grupo NVARCHAR(50) NOT NULL,
  pin_acceso NVARCHAR(20) NOT NULL,
  meta_monto INT NOT NULL,
  CONSTRAINT pk_grupo_buffet PRIMARY KEY (id_grupo),
  CONSTRAINT uq_grupo_buffet_nombre_grupo UNIQUE (nombre_grupo),
  CONSTRAINT ck_grupo_meta CHECK (meta_monto > 0)
);

CREATE TABLE integrante_grupo (
  id_usuario INT NOT NULL,
  id_grupo INT NOT NULL,
  CONSTRAINT pk_integrante_grupo PRIMARY KEY (id_usuario, id_grupo),
  CONSTRAINT fk_integrante_grupo_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_integrante_grupo_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo)
);

CREATE TABLE producto_buffet (
  id_producto INT IDENTITY(1,1) NOT NULL,
  nombre_producto NVARCHAR(80) NOT NULL,
  precio INT NOT NULL,
  stock INT NOT NULL,
  id_usuario INT NOT NULL,
  id_grupo INT NULL,
  CONSTRAINT pk_producto_buffet PRIMARY KEY (id_producto),
  CONSTRAINT fk_producto_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_producto_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo),
  CONSTRAINT ck_producto_precio CHECK (precio > 0),
  CONSTRAINT ck_producto_stock CHECK (stock >= 0)
);

CREATE TABLE venta_buffet (
  id_venta INT IDENTITY(1,1) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_estado_venta INT NOT NULL,
  CONSTRAINT pk_venta_buffet PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_venta_buffet_id_estado_venta FOREIGN KEY (id_estado_venta) REFERENCES estado_venta (id_estado_venta)
);

CREATE TABLE detalle_venta (
  id_venta INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario INT NOT NULL,
  CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
  CONSTRAINT fk_detalle_venta_id_venta FOREIGN KEY (id_venta) REFERENCES venta_buffet (id_venta),
  CONSTRAINT fk_detalle_venta_id_producto FOREIGN KEY (id_producto) REFERENCES producto_buffet (id_producto),
  CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0)
);

CREATE TABLE donacion_buffet (
  id_donacion INT IDENTITY(1,1) NOT NULL,
  monto INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_grupo INT NOT NULL,
  CONSTRAINT pk_donacion_buffet PRIMARY KEY (id_donacion),
  CONSTRAINT fk_donacion_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_donacion_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_buffet (id_grupo),
  CONSTRAINT ck_donacion_monto CHECK (monto > 0)
);

CREATE TABLE recursos_ct (
  id_recurso INT IDENTITY(1,1) NOT NULL,
  id_carro INT NULL,
  numero_equipo INT NOT NULL,
  id_tipo_recurso INT NOT NULL,
  id_estado_recurso INT NOT NULL,
  CONSTRAINT pk_recursos_ct PRIMARY KEY (id_recurso),
  CONSTRAINT fk_recursos_ct_id_carro FOREIGN KEY (id_carro) REFERENCES carro (id_carro),
  CONSTRAINT fk_recursos_ct_id_tipo_recurso FOREIGN KEY (id_tipo_recurso) REFERENCES tipo_recurso (id_tipo_recurso),
  CONSTRAINT fk_recursos_ct_id_estado_recurso FOREIGN KEY (id_estado_recurso) REFERENCES estado_recurso (id_estado_recurso),
  CONSTRAINT uq_recursos_ct_id_tipo_recurso_id_carro_numero_equipo UNIQUE (id_tipo_recurso, id_carro, numero_equipo)
);

CREATE TABLE prestamo_ct (
  id_prestamo INT IDENTITY(1,1) NOT NULL,
  fecha_prestamo DATETIME NOT NULL,
  hora_prestamo NVARCHAR(5) NOT NULL,
  hora_devolucion NVARCHAR(5) NULL,
  observaciones NVARCHAR(200) NULL,
  id_usuario_solicitante INT NOT NULL,
  id_usuario_autorizador INT NOT NULL,
  id_recurso INT NOT NULL,
  CONSTRAINT pk_prestamo_ct PRIMARY KEY (id_prestamo),
  CONSTRAINT fk_prestamo_ct_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_prestamo_ct_id_usuario_autorizador FOREIGN KEY (id_usuario_autorizador) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_prestamo_ct_id_recurso FOREIGN KEY (id_recurso) REFERENCES recursos_ct (id_recurso)
);

CREATE TABLE reserva_sector (
  id_reserva INT IDENTITY(1,1) NOT NULL,
  fecha_reserva DATETIME NOT NULL,
  hora_inicio NVARCHAR(5) NOT NULL,
  hora_fin NVARCHAR(5) NOT NULL,
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
);

CREATE TABLE oferta_deporte (
  id_oferta INT IDENTITY(1,1) NOT NULL,
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
);

CREATE TABLE inscripcion_ed_fisica (
  id_inscripcion INT IDENTITY(1,1) NOT NULL,
  fecha_inscripcion DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_oferta INT NOT NULL,
  CONSTRAINT pk_inscripcion_ed_fisica PRIMARY KEY (id_inscripcion),
  CONSTRAINT uq_inscripcion_ed_fisica_id_usuario UNIQUE (id_usuario),
  CONSTRAINT fk_inscripcion_ed_fisica_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_inscripcion_ed_fisica_id_oferta FOREIGN KEY (id_oferta) REFERENCES oferta_deporte (id_oferta)
);

CREATE TABLE log_auditoria (
  id_log INT IDENTITY(1,1) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  direccion_ip NVARCHAR(80) NOT NULL,
  descripcion_evento NVARCHAR(200) NOT NULL,
  id_entidad INT NOT NULL,
  id_usuario INT NULL,
  id_tipo_log INT NOT NULL,
  id_resultado INT NOT NULL,
  CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log),
  CONSTRAINT fk_log_auditoria_id_entidad FOREIGN KEY (id_entidad) REFERENCES entidad_log (id_entidad),
  CONSTRAINT fk_log_auditoria_id_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
  CONSTRAINT fk_log_auditoria_id_tipo_log FOREIGN KEY (id_tipo_log) REFERENCES tipo_log (id_tipo_log),
  CONSTRAINT fk_log_auditoria_id_resultado FOREIGN KEY (id_resultado) REFERENCES resultado_log (id_resultado)
);

GO
INSERT INTO rol (nombre_rol) VALUES (N'Alumno');
INSERT INTO rol (nombre_rol) VALUES (N'Profesor');
INSERT INTO rol (nombre_rol) VALUES (N'Preceptor');
INSERT INTO rol (nombre_rol) VALUES (N'Maestranza');
INSERT INTO especialidad (nombre_especialidad) VALUES (N'Computación');
INSERT INTO especialidad (nombre_especialidad) VALUES (N'Electrónica');
INSERT INTO especialidad (nombre_especialidad) VALUES (N'Mecánica');
INSERT INTO turno (nombre_turno) VALUES (N'Mañana');
INSERT INTO turno (nombre_turno) VALUES (N'Tarde');
INSERT INTO dia_semana (nombre_dia) VALUES (N'Lunes');
INSERT INTO dia_semana (nombre_dia) VALUES (N'Martes');
INSERT INTO dia_semana (nombre_dia) VALUES (N'Miércoles');
INSERT INTO dia_semana (nombre_dia) VALUES (N'Jueves');
INSERT INTO dia_semana (nombre_dia) VALUES (N'Viernes');
INSERT INTO categoria_objeto (nombre_categoria) VALUES (N'Útiles');
INSERT INTO categoria_objeto (nombre_categoria) VALUES (N'Ropa');
INSERT INTO categoria_objeto (nombre_categoria) VALUES (N'Llaves');
INSERT INTO categoria_objeto (nombre_categoria) VALUES (N'Electrónica');
INSERT INTO categoria_objeto (nombre_categoria) VALUES (N'Documentación');
INSERT INTO categoria_objeto (nombre_categoria) VALUES (N'Otros');
INSERT INTO estado_objeto (nombre_estado) VALUES (N'Disponible');
INSERT INTO estado_objeto (nombre_estado) VALUES (N'En reclamo');
INSERT INTO estado_objeto (nombre_estado) VALUES (N'Devuelto');
INSERT INTO estado_objeto (nombre_estado) VALUES (N'Archivado');
INSERT INTO estado_reclamo (nombre_estado) VALUES (N'Pendiente');
INSERT INTO estado_reclamo (nombre_estado) VALUES (N'Aprobado');
INSERT INTO estado_reclamo (nombre_estado) VALUES (N'Rechazado');
INSERT INTO tipo_reporte (nombre_tipo) VALUES (N'Rotura');
INSERT INTO tipo_reporte (nombre_tipo) VALUES (N'Limpieza');
INSERT INTO estado_reporte (nombre_estado) VALUES (N'Pendiente');
INSERT INTO estado_reporte (nombre_estado) VALUES (N'Resuelto');
INSERT INTO estado_reserva (nombre_estado) VALUES (N'Pendiente');
INSERT INTO estado_reserva (nombre_estado) VALUES (N'Aprobada');
INSERT INTO estado_reserva (nombre_estado) VALUES (N'Rechazada');
INSERT INTO estado_reserva (nombre_estado) VALUES (N'Cancelada');
INSERT INTO estado_venta (nombre_estado) VALUES (N'Reservada');
INSERT INTO estado_venta (nombre_estado) VALUES (N'Entregada');
INSERT INTO estado_venta (nombre_estado) VALUES (N'Cancelada');
INSERT INTO tipo_recurso (nombre_tipo) VALUES (N'Computadora');
INSERT INTO tipo_recurso (nombre_tipo) VALUES (N'Tablero de dibujo');
INSERT INTO estado_recurso (nombre_estado) VALUES (N'Disponible');
INSERT INTO estado_recurso (nombre_estado) VALUES (N'Prestado');
INSERT INTO estado_recurso (nombre_estado) VALUES (N'Fuera de servicio');
INSERT INTO carro (nombre_carro) VALUES (N'C1');
INSERT INTO carro (nombre_carro) VALUES (N'C2');
INSERT INTO carro (nombre_carro) VALUES (N'C3');
INSERT INTO carro (nombre_carro) VALUES (N'C4');
INSERT INTO carro (nombre_carro) VALUES (N'C5');
INSERT INTO deporte (nombre_deporte) VALUES (N'Fútbol');
INSERT INTO deporte (nombre_deporte) VALUES (N'Vóley');
INSERT INTO deporte (nombre_deporte) VALUES (N'Básquet');
INSERT INTO deporte (nombre_deporte) VALUES (N'Handball');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Inicio de sesión');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Cierre de sesión');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Registro de usuario');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Publicación de objeto');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Reclamo de objeto');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Resolución de reclamo');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Reporte de higiene');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Resolución de reporte');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Reserva de producto');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Donación');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Préstamo de recurso');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Devolución de recurso');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Reserva de sector');
INSERT INTO tipo_log (nombre_evento) VALUES (N'Inscripción a Ed. Física');
INSERT INTO resultado_log (nombre_resultado) VALUES (N'Exitoso');
INSERT INTO resultado_log (nombre_resultado) VALUES (N'Fallido');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'usuario');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'objeto_perdido');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'reclamo_objeto');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'consulta_objeto');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'reporte_higiene');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'grupo_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'producto_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'venta_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'donacion_buffet');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'prestamo_ct');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'reserva_sector');
INSERT INTO entidad_log (nombre_entidad) VALUES (N'inscripcion_ed_fisica');
INSERT INTO tipo_sector (nombre_tipo) VALUES (N'Reservable');
INSERT INTO tipo_sector (nombre_tipo) VALUES (N'Uso común');
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
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES (N'08:00', N'10:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES (N'10:00', N'12:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES (N'12:00', N'14:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES (N'14:00', N'16:00');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES (N'16:00', N'18:00');
INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES ((SELECT id_anio FROM anio WHERE numero_anio = 4), (SELECT id_division FROM division WHERE numero_division = 1), (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación'));
INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES ((SELECT id_anio FROM anio WHERE numero_anio = 4), (SELECT id_division FROM division WHERE numero_division = 2), (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación'));
INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES ((SELECT id_anio FROM anio WHERE numero_anio = 5), (SELECT id_division FROM division WHERE numero_division = 2), (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Electrónica'));
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (40000001, N'Alumno Uno', N'alumno1', N'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', N'alumno1@iqual.demo', N'1155550001', (SELECT id_rol FROM rol WHERE nombre_rol = N'Alumno'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')));
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (40000002, N'Alumno Dos', N'alumno2', N'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', N'alumno2@iqual.demo', N'1155550002', (SELECT id_rol FROM rol WHERE nombre_rol = N'Alumno'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 5) AND id_division = (SELECT id_division FROM division WHERE numero_division = 2) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Electrónica')));
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (30000003, N'Profesor Uno', N'profe1', N'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', N'profe1@iqual.demo', N'1155550003', (SELECT id_rol FROM rol WHERE nombre_rol = N'Profesor'), NULL);
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (30000004, N'Preceptor Uno', N'preceptor1', N'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', N'preceptor1@iqual.demo', N'1155550004', (SELECT id_rol FROM rol WHERE nombre_rol = N'Preceptor'), NULL);
INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES (30000005, N'Maestranza Uno', N'maestranza1', N'03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', N'maestranza1@iqual.demo', N'1155550005', (SELECT id_rol FROM rol WHERE nombre_rol = N'Maestranza'), NULL);
INSERT INTO materia (nombre_materia, codigo_materia) VALUES (N'Programación', N'PRG-401');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES (N'Bases de Datos', N'BDD-402');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES (N'Matemática', N'MAT-403');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES (N'Lengua y Literatura', N'LEN-404');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES (N'Proyecto Informático I', N'PRY-405');
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES (N'13:00', N'14:40', (SELECT id_materia FROM materia WHERE nombre_materia = N'Programación'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = N'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES (N'14:50', N'16:30', (SELECT id_materia FROM materia WHERE nombre_materia = N'Bases de Datos'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = N'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES (N'13:00', N'14:40', (SELECT id_materia FROM materia WHERE nombre_materia = N'Matemática'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = N'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES (N'14:50', N'16:30', (SELECT id_materia FROM materia WHERE nombre_materia = N'Lengua y Literatura'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = N'Tarde'));
INSERT INTO horario_escolar (hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno) VALUES (N'14:50', N'16:30', (SELECT id_materia FROM materia WHERE nombre_materia = N'Proyecto Informático I'), (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_turno FROM turno WHERE nombre_turno = N'Tarde'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Programación') AND hora_inicio = N'13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Programación') AND hora_inicio = N'13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Miércoles'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Bases de Datos') AND hora_inicio = N'14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Martes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Bases de Datos') AND hora_inicio = N'14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Jueves'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Matemática') AND hora_inicio = N'13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Martes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Matemática') AND hora_inicio = N'13:00'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Viernes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Lengua y Literatura') AND hora_inicio = N'14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Miércoles'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Lengua y Literatura') AND hora_inicio = N'14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Viernes'));
INSERT INTO horario_dia (id_bloque, id_dia) VALUES ((SELECT id_bloque FROM horario_escolar WHERE id_curso = (SELECT id_curso FROM curso WHERE id_anio = (SELECT id_anio FROM anio WHERE numero_anio = 4) AND id_division = (SELECT id_division FROM division WHERE numero_division = 1) AND id_especialidad = (SELECT id_especialidad FROM especialidad WHERE nombre_especialidad = N'Computación')) AND id_materia = (SELECT id_materia FROM materia WHERE nombre_materia = N'Proyecto Informático I') AND hora_inicio = N'14:50'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Laboratorio de química', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Reservable'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Biblioteca', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Reservable'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'SUM', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Reservable'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Baño planta baja', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Baño planta alta', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Aula', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Patio', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Preceptoría', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Uso común'));
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES (N'Taller de computación', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = N'Uso común'));
INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES (N'Campera azul', N'Campera azul de abrigo con capucha, talle M', NULL, '20261019 00:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_categoria_objeto FROM categoria_objeto WHERE nombre_categoria = N'Ropa'), (SELECT id_estado_objeto FROM estado_objeto WHERE nombre_estado = N'Disponible'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Patio'));
INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES (N'Llaves con llavero rojo', N'Dos llaves con un llavero rojo de goma', NULL, '20261020 00:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_categoria_objeto FROM categoria_objeto WHERE nombre_categoria = N'Llaves'), (SELECT id_estado_objeto FROM estado_objeto WHERE nombre_estado = N'En reclamo'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Aula'));
INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES (N'Calculadora científica', N'Calculadora científica negra con funda', NULL, '20261015 00:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_categoria_objeto FROM categoria_objeto WHERE nombre_categoria = N'Electrónica'), (SELECT id_estado_objeto FROM estado_objeto WHERE nombre_estado = N'Devuelto'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Biblioteca'));
INSERT INTO reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) VALUES (N'El llavero tiene mi nombre grabado en la parte de atrás', '20261021 00:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_objeto FROM objeto_perdido WHERE titulo = N'Llaves con llavero rojo'), (SELECT id_estado_reclamo FROM estado_reclamo WHERE nombre_estado = N'Pendiente'));
INSERT INTO reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) VALUES (N'Tiene mis iniciales escritas en la funda de la calculadora', '20261016 00:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), (SELECT id_objeto FROM objeto_perdido WHERE titulo = N'Calculadora científica'), (SELECT id_estado_reclamo FROM estado_reclamo WHERE nombre_estado = N'Aprobado'));
INSERT INTO consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES ('20261022 00:00:00', N'Perdí un buzo gris en el patio, alguien lo vio?', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'));
INSERT INTO consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES ('20261023 00:00:00', N'Busco una botella térmica verde que dejé en el aula', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'));
INSERT INTO reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte, fecha_hora_resolucion, id_usuario_resolutor) VALUES ('20261021 09:15:00', N'Falta papel y hay que limpiar el piso', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Baño planta baja'), (SELECT id_tipo_reporte FROM tipo_reporte WHERE nombre_tipo = N'Limpieza'), (SELECT id_estado_reporte FROM estado_reporte WHERE nombre_estado = N'Pendiente'), NULL, NULL);
INSERT INTO reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte, fecha_hora_resolucion, id_usuario_resolutor) VALUES ('20261019 10:30:00', N'Hay una silla rota en el fondo del aula', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Aula'), (SELECT id_tipo_reporte FROM tipo_reporte WHERE nombre_tipo = N'Rotura'), (SELECT id_estado_reporte FROM estado_reporte WHERE nombre_estado = N'Resuelto'), '20261020 08:45:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'maestranza1'));
INSERT INTO grupo_buffet (nombre_grupo, pin_acceso, meta_monto) VALUES (N'Viaje de Estudios 4to 1ra', N'2468', 50000);
INSERT INTO integrante_grupo (id_usuario, id_grupo) VALUES ((SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = N'Viaje de Estudios 4to 1ra'));
INSERT INTO integrante_grupo (id_usuario, id_grupo) VALUES ((SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = N'Viaje de Estudios 4to 1ra'));
INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES (N'Alfajor de dulce de leche', 800, 18, (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = N'Viaje de Estudios 4to 1ra'));
INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES (N'Sándwich de miga', 1500, 9, (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = N'Viaje de Estudios 4to 1ra'));
INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES (N'Jugo en caja', 700, 15, (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), NULL);
INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES ('20261022 10:20:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = N'Reservada'));
INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES ('20261022 11:05:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = N'Entregada'));
INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES ('20261023 09:40:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = N'Cancelada'));
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES ((SELECT id_venta FROM venta_buffet WHERE fecha_hora = '20261022 10:20:00' AND id_usuario = (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1')), (SELECT id_producto FROM producto_buffet WHERE nombre_producto = N'Alfajor de dulce de leche'), 2, 800);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES ((SELECT id_venta FROM venta_buffet WHERE fecha_hora = '20261022 11:05:00' AND id_usuario = (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1')), (SELECT id_producto FROM producto_buffet WHERE nombre_producto = N'Sándwich de miga'), 1, 1500);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES ((SELECT id_venta FROM venta_buffet WHERE fecha_hora = '20261023 09:40:00' AND id_usuario = (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2')), (SELECT id_producto FROM producto_buffet WHERE nombre_producto = N'Alfajor de dulce de leche'), 1, 800);
INSERT INTO donacion_buffet (monto, fecha_hora, id_usuario, id_grupo) VALUES (2000, '20261022 12:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_grupo FROM grupo_buffet WHERE nombre_grupo = N'Viaje de Estudios 4to 1ra'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 2, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 3, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 4, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 5, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Prestado'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 6, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 7, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 8, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 9, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C4'), 10, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 2, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 3, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 4, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 5, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 6, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 7, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 8, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 9, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = N'C5'), 10, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 2, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 3, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 4, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 5, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 6, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 7, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Fuera de servicio'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 8, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 9, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES (NULL, 10, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Tablero de dibujo'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = N'Disponible'));
INSERT INTO prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) VALUES ('20261023 00:00:00', N'14:10', NULL, NULL, (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_recurso FROM recursos_ct WHERE id_tipo_recurso = (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora') AND id_carro = (SELECT id_carro FROM carro WHERE nombre_carro = N'C4') AND numero_equipo = 5));
INSERT INTO prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) VALUES ('20261022 00:00:00', N'13:30', N'15:10', N'Funciona', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_recurso FROM recursos_ct WHERE id_tipo_recurso = (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = N'Computadora') AND id_carro = (SELECT id_carro FROM carro WHERE nombre_carro = N'C5') AND numero_equipo = 2));
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('20261105 00:00:00', N'10:00', N'11:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Biblioteca'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = N'Pendiente'), NULL);
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('20261105 00:00:00', N'09:00', N'11:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_sector FROM sector WHERE nombre_sector = N'SUM'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = N'Aprobada'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'));
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('20261105 00:00:00', N'11:30', N'12:30', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Biblioteca'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = N'Cancelada'), NULL);
INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ('20261106 00:00:00', N'08:00', N'10:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_sector FROM sector WHERE nombre_sector = N'Laboratorio de química'), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = N'Aprobada'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'));
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'10:00' AND hora_fin = N'12:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'08:00' AND hora_fin = N'10:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'16:00' AND hora_fin = N'18:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'12:00' AND hora_fin = N'14:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'14:00' AND hora_fin = N'16:00'), 20);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'14:00' AND hora_fin = N'16:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'14:00' AND hora_fin = N'16:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'10:00' AND hora_fin = N'12:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'16:00' AND hora_fin = N'18:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Vóley'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'08:00' AND hora_fin = N'10:00'), 12);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'16:00' AND hora_fin = N'18:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'10:00' AND hora_fin = N'12:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'12:00' AND hora_fin = N'14:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'14:00' AND hora_fin = N'16:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Básquet'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'10:00' AND hora_fin = N'12:00'), 10);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'08:00' AND hora_fin = N'10:00'), 1);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Martes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'16:00' AND hora_fin = N'18:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Miércoles'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'14:00' AND hora_fin = N'16:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Jueves'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'08:00' AND hora_fin = N'10:00'), 15);
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Handball'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Viernes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'12:00' AND hora_fin = N'14:00'), 15);
INSERT INTO inscripcion_ed_fisica (fecha_inscripcion, id_usuario, id_oferta) VALUES ('20261022 00:00:00', (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), (SELECT id_oferta FROM oferta_deporte WHERE id_deporte = (SELECT id_deporte FROM deporte WHERE nombre_deporte = N'Handball') AND id_dia = (SELECT id_dia FROM dia_semana WHERE nombre_dia = N'Lunes') AND id_franja = (SELECT id_franja FROM franja_horaria WHERE hora_inicio = N'08:00' AND hora_fin = N'10:00')));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261021 08:00:05', N'PC-PRECEPTORIA', N'Inicio de sesión exitoso de preceptor1', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'usuario'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Inicio de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261021 08:05:40', N'PC-PRECEPTORIA', N'Publicación del objeto Llaves con llavero rojo', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'objeto_perdido'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Publicación de objeto'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261021 09:14:50', N'PC-LAB-01', N'Inicio de sesión exitoso de alumno1', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'usuario'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Inicio de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261021 09:15:10', N'PC-LAB-01', N'Reporte de higiene en Baño planta baja', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'reporte_higiene'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Reporte de higiene'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261021 09:30:00', N'PC-LAB-01', N'Reclamo del objeto Llaves con llavero rojo', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'reclamo_objeto'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Reclamo de objeto'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261021 10:02:11', N'PC-LAB-02', N'Intento de inicio de sesión con usuario inexistente', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'usuario'), NULL, (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Inicio de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Fallido'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261022 10:20:00', N'PC-PRECEPTORIA', N'Reserva de Alfajor de dulce de leche', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'venta_buffet'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Reserva de producto'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261022 12:00:00', N'PC-SALA-PROF', N'Donación de 2000 al grupo Viaje de Estudios 4to 1ra', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'donacion_buffet'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Donación'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261022 13:30:00', N'PC-PRECEPTORIA', N'Préstamo del recurso C5-02', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'prestamo_ct'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Préstamo de recurso'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261022 15:10:00', N'PC-PRECEPTORIA', N'Devolución del recurso C5-02', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'prestamo_ct'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'preceptor1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Devolución de recurso'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261022 16:00:00', N'PC-LAB-01', N'Inscripción a Ed. Física Handball lunes', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'inscripcion_ed_fisica'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno2'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Inscripción a Ed. Física'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261023 08:10:00', N'PC-LAB-01', N'Inscripción rechazada por superposición con Bases de Datos', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'inscripcion_ed_fisica'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Inscripción a Ed. Física'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Fallido'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261023 08:20:00', N'PC-LAB-01', N'Inscripción rechazada por cupo lleno', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'inscripcion_ed_fisica'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Inscripción a Ed. Física'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Fallido'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261023 09:00:00', N'PC-SALA-PROF', N'Reserva del sector Biblioteca', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'reserva_sector'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'profe1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Reserva de sector'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ('20261023 09:45:00', N'PC-LAB-01', N'Cierre de sesión de alumno1', (SELECT id_entidad FROM entidad_log WHERE nombre_entidad = N'usuario'), (SELECT id_usuario FROM usuario WHERE usuario_nick = N'alumno1'), (SELECT id_tipo_log FROM tipo_log WHERE nombre_evento = N'Cierre de sesión'), (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = N'Exitoso'));
GO
