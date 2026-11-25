-- 03_ModeloSQL_Grupo00_sqlserver.sql - PROYECTO IQUAL (SGE) - modelo de datos para SQL Server 2005 (47 tablas en 3FN, 7 schemas)
-- Se ejecuta con SSMS (los GO los entiende el cliente). Se puede repetir: borra las tablas y las vuelve a crear, vacias.
-- MAPA DE SCHEMAS (47 tablas, CONTEXTO_IQUAL 21):
--   seguridad      (6) rol, usuario, log_auditoria, tipo_log, resultado_log, entidad_log
--   academico      (10) especialidad, turno, dia_semana, anio, division, franja_horaria, curso, materia, horario_escolar, horario_dia
--   objetos        (6) categoria_objeto, estado_objeto, estado_reclamo, objeto_perdido, reclamo_objeto, consulta_objeto
--   instalaciones  (7) tipo_reporte, estado_reporte, estado_reserva, tipo_sector, sector, reporte_higiene, reserva_sector
--   tienda         (8) estado_venta, categoria_producto, grupo_buffet, integrante_grupo, producto_buffet, venta_buffet, detalle_venta, donacion_buffet
--   equipos        (7) tipo_recurso, estado_recurso, carro, software, recursos_ct, recurso_software, prestamo_ct
--   deportes       (3) deporte, oferta_deporte, inscripcion_ed_fisica
-- Cada tabla vive en su schema (por ejemplo seguridad.usuario). Las claves foraneas entre schemas llevan el nombre completo.
IF DB_ID('iqual') IS NULL CREATE DATABASE iqual;
GO
USE iqual;
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'seguridad') EXEC ('CREATE SCHEMA seguridad');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'academico') EXEC ('CREATE SCHEMA academico');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'objetos') EXEC ('CREATE SCHEMA objetos');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'instalaciones') EXEC ('CREATE SCHEMA instalaciones');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'tienda') EXEC ('CREATE SCHEMA tienda');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'equipos') EXEC ('CREATE SCHEMA equipos');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'deportes') EXEC ('CREATE SCHEMA deportes');
GO
-- limpieza de una carga vieja sin schemas (iqual_sqlserver.sql): si no existe, no hace nada
IF OBJECT_ID('dbo.log_auditoria', 'U') IS NOT NULL DROP TABLE dbo.log_auditoria;
IF OBJECT_ID('dbo.inscripcion_ed_fisica', 'U') IS NOT NULL DROP TABLE dbo.inscripcion_ed_fisica;
IF OBJECT_ID('dbo.oferta_deporte', 'U') IS NOT NULL DROP TABLE dbo.oferta_deporte;
IF OBJECT_ID('dbo.reserva_sector', 'U') IS NOT NULL DROP TABLE dbo.reserva_sector;
IF OBJECT_ID('dbo.prestamo_ct', 'U') IS NOT NULL DROP TABLE dbo.prestamo_ct;
IF OBJECT_ID('dbo.recurso_software', 'U') IS NOT NULL DROP TABLE dbo.recurso_software;
IF OBJECT_ID('dbo.recursos_ct', 'U') IS NOT NULL DROP TABLE dbo.recursos_ct;
IF OBJECT_ID('dbo.donacion_buffet', 'U') IS NOT NULL DROP TABLE dbo.donacion_buffet;
IF OBJECT_ID('dbo.detalle_venta', 'U') IS NOT NULL DROP TABLE dbo.detalle_venta;
IF OBJECT_ID('dbo.venta_buffet', 'U') IS NOT NULL DROP TABLE dbo.venta_buffet;
IF OBJECT_ID('dbo.producto_buffet', 'U') IS NOT NULL DROP TABLE dbo.producto_buffet;
IF OBJECT_ID('dbo.integrante_grupo', 'U') IS NOT NULL DROP TABLE dbo.integrante_grupo;
IF OBJECT_ID('dbo.grupo_buffet', 'U') IS NOT NULL DROP TABLE dbo.grupo_buffet;
IF OBJECT_ID('dbo.reporte_higiene', 'U') IS NOT NULL DROP TABLE dbo.reporte_higiene;
IF OBJECT_ID('dbo.consulta_objeto', 'U') IS NOT NULL DROP TABLE dbo.consulta_objeto;
IF OBJECT_ID('dbo.reclamo_objeto', 'U') IS NOT NULL DROP TABLE dbo.reclamo_objeto;
IF OBJECT_ID('dbo.objeto_perdido', 'U') IS NOT NULL DROP TABLE dbo.objeto_perdido;
IF OBJECT_ID('dbo.sector', 'U') IS NOT NULL DROP TABLE dbo.sector;
IF OBJECT_ID('dbo.horario_dia', 'U') IS NOT NULL DROP TABLE dbo.horario_dia;
IF OBJECT_ID('dbo.horario_escolar', 'U') IS NOT NULL DROP TABLE dbo.horario_escolar;
IF OBJECT_ID('dbo.materia', 'U') IS NOT NULL DROP TABLE dbo.materia;
IF OBJECT_ID('dbo.usuario', 'U') IS NOT NULL DROP TABLE dbo.usuario;
IF OBJECT_ID('dbo.curso', 'U') IS NOT NULL DROP TABLE dbo.curso;
IF OBJECT_ID('dbo.franja_horaria', 'U') IS NOT NULL DROP TABLE dbo.franja_horaria;
IF OBJECT_ID('dbo.division', 'U') IS NOT NULL DROP TABLE dbo.division;
IF OBJECT_ID('dbo.anio', 'U') IS NOT NULL DROP TABLE dbo.anio;
IF OBJECT_ID('dbo.software', 'U') IS NOT NULL DROP TABLE dbo.software;
IF OBJECT_ID('dbo.categoria_producto', 'U') IS NOT NULL DROP TABLE dbo.categoria_producto;
IF OBJECT_ID('dbo.tipo_sector', 'U') IS NOT NULL DROP TABLE dbo.tipo_sector;
IF OBJECT_ID('dbo.entidad_log', 'U') IS NOT NULL DROP TABLE dbo.entidad_log;
IF OBJECT_ID('dbo.resultado_log', 'U') IS NOT NULL DROP TABLE dbo.resultado_log;
IF OBJECT_ID('dbo.tipo_log', 'U') IS NOT NULL DROP TABLE dbo.tipo_log;
IF OBJECT_ID('dbo.deporte', 'U') IS NOT NULL DROP TABLE dbo.deporte;
IF OBJECT_ID('dbo.carro', 'U') IS NOT NULL DROP TABLE dbo.carro;
IF OBJECT_ID('dbo.estado_recurso', 'U') IS NOT NULL DROP TABLE dbo.estado_recurso;
IF OBJECT_ID('dbo.tipo_recurso', 'U') IS NOT NULL DROP TABLE dbo.tipo_recurso;
IF OBJECT_ID('dbo.estado_venta', 'U') IS NOT NULL DROP TABLE dbo.estado_venta;
IF OBJECT_ID('dbo.estado_reserva', 'U') IS NOT NULL DROP TABLE dbo.estado_reserva;
IF OBJECT_ID('dbo.estado_reporte', 'U') IS NOT NULL DROP TABLE dbo.estado_reporte;
IF OBJECT_ID('dbo.tipo_reporte', 'U') IS NOT NULL DROP TABLE dbo.tipo_reporte;
IF OBJECT_ID('dbo.estado_reclamo', 'U') IS NOT NULL DROP TABLE dbo.estado_reclamo;
IF OBJECT_ID('dbo.estado_objeto', 'U') IS NOT NULL DROP TABLE dbo.estado_objeto;
IF OBJECT_ID('dbo.categoria_objeto', 'U') IS NOT NULL DROP TABLE dbo.categoria_objeto;
IF OBJECT_ID('dbo.dia_semana', 'U') IS NOT NULL DROP TABLE dbo.dia_semana;
IF OBJECT_ID('dbo.turno', 'U') IS NOT NULL DROP TABLE dbo.turno;
IF OBJECT_ID('dbo.especialidad', 'U') IS NOT NULL DROP TABLE dbo.especialidad;
IF OBJECT_ID('dbo.rol', 'U') IS NOT NULL DROP TABLE dbo.rol;
GO
IF OBJECT_ID('seguridad.log_auditoria', 'U') IS NOT NULL DROP TABLE seguridad.log_auditoria;
IF OBJECT_ID('deportes.inscripcion_ed_fisica', 'U') IS NOT NULL DROP TABLE deportes.inscripcion_ed_fisica;
IF OBJECT_ID('deportes.oferta_deporte', 'U') IS NOT NULL DROP TABLE deportes.oferta_deporte;
IF OBJECT_ID('instalaciones.reserva_sector', 'U') IS NOT NULL DROP TABLE instalaciones.reserva_sector;
IF OBJECT_ID('equipos.prestamo_ct', 'U') IS NOT NULL DROP TABLE equipos.prestamo_ct;
IF OBJECT_ID('equipos.recurso_software', 'U') IS NOT NULL DROP TABLE equipos.recurso_software;
IF OBJECT_ID('equipos.recursos_ct', 'U') IS NOT NULL DROP TABLE equipos.recursos_ct;
IF OBJECT_ID('tienda.donacion_buffet', 'U') IS NOT NULL DROP TABLE tienda.donacion_buffet;
IF OBJECT_ID('tienda.detalle_venta', 'U') IS NOT NULL DROP TABLE tienda.detalle_venta;
IF OBJECT_ID('tienda.venta_buffet', 'U') IS NOT NULL DROP TABLE tienda.venta_buffet;
IF OBJECT_ID('tienda.producto_buffet', 'U') IS NOT NULL DROP TABLE tienda.producto_buffet;
IF OBJECT_ID('tienda.integrante_grupo', 'U') IS NOT NULL DROP TABLE tienda.integrante_grupo;
IF OBJECT_ID('tienda.grupo_buffet', 'U') IS NOT NULL DROP TABLE tienda.grupo_buffet;
IF OBJECT_ID('instalaciones.reporte_higiene', 'U') IS NOT NULL DROP TABLE instalaciones.reporte_higiene;
IF OBJECT_ID('objetos.consulta_objeto', 'U') IS NOT NULL DROP TABLE objetos.consulta_objeto;
IF OBJECT_ID('objetos.reclamo_objeto', 'U') IS NOT NULL DROP TABLE objetos.reclamo_objeto;
IF OBJECT_ID('objetos.objeto_perdido', 'U') IS NOT NULL DROP TABLE objetos.objeto_perdido;
IF OBJECT_ID('instalaciones.sector', 'U') IS NOT NULL DROP TABLE instalaciones.sector;
IF OBJECT_ID('academico.horario_dia', 'U') IS NOT NULL DROP TABLE academico.horario_dia;
IF OBJECT_ID('academico.horario_escolar', 'U') IS NOT NULL DROP TABLE academico.horario_escolar;
IF OBJECT_ID('academico.materia', 'U') IS NOT NULL DROP TABLE academico.materia;
IF OBJECT_ID('seguridad.usuario', 'U') IS NOT NULL DROP TABLE seguridad.usuario;
IF OBJECT_ID('academico.curso', 'U') IS NOT NULL DROP TABLE academico.curso;
IF OBJECT_ID('academico.franja_horaria', 'U') IS NOT NULL DROP TABLE academico.franja_horaria;
IF OBJECT_ID('academico.division', 'U') IS NOT NULL DROP TABLE academico.division;
IF OBJECT_ID('academico.anio', 'U') IS NOT NULL DROP TABLE academico.anio;
IF OBJECT_ID('equipos.software', 'U') IS NOT NULL DROP TABLE equipos.software;
IF OBJECT_ID('tienda.categoria_producto', 'U') IS NOT NULL DROP TABLE tienda.categoria_producto;
IF OBJECT_ID('instalaciones.tipo_sector', 'U') IS NOT NULL DROP TABLE instalaciones.tipo_sector;
IF OBJECT_ID('seguridad.entidad_log', 'U') IS NOT NULL DROP TABLE seguridad.entidad_log;
IF OBJECT_ID('seguridad.resultado_log', 'U') IS NOT NULL DROP TABLE seguridad.resultado_log;
IF OBJECT_ID('seguridad.tipo_log', 'U') IS NOT NULL DROP TABLE seguridad.tipo_log;
IF OBJECT_ID('deportes.deporte', 'U') IS NOT NULL DROP TABLE deportes.deporte;
IF OBJECT_ID('equipos.carro', 'U') IS NOT NULL DROP TABLE equipos.carro;
IF OBJECT_ID('equipos.estado_recurso', 'U') IS NOT NULL DROP TABLE equipos.estado_recurso;
IF OBJECT_ID('equipos.tipo_recurso', 'U') IS NOT NULL DROP TABLE equipos.tipo_recurso;
IF OBJECT_ID('tienda.estado_venta', 'U') IS NOT NULL DROP TABLE tienda.estado_venta;
IF OBJECT_ID('instalaciones.estado_reserva', 'U') IS NOT NULL DROP TABLE instalaciones.estado_reserva;
IF OBJECT_ID('instalaciones.estado_reporte', 'U') IS NOT NULL DROP TABLE instalaciones.estado_reporte;
IF OBJECT_ID('instalaciones.tipo_reporte', 'U') IS NOT NULL DROP TABLE instalaciones.tipo_reporte;
IF OBJECT_ID('objetos.estado_reclamo', 'U') IS NOT NULL DROP TABLE objetos.estado_reclamo;
IF OBJECT_ID('objetos.estado_objeto', 'U') IS NOT NULL DROP TABLE objetos.estado_objeto;
IF OBJECT_ID('objetos.categoria_objeto', 'U') IS NOT NULL DROP TABLE objetos.categoria_objeto;
IF OBJECT_ID('academico.dia_semana', 'U') IS NOT NULL DROP TABLE academico.dia_semana;
IF OBJECT_ID('academico.turno', 'U') IS NOT NULL DROP TABLE academico.turno;
IF OBJECT_ID('academico.especialidad', 'U') IS NOT NULL DROP TABLE academico.especialidad;
IF OBJECT_ID('seguridad.rol', 'U') IS NOT NULL DROP TABLE seguridad.rol;
GO
CREATE TABLE seguridad.rol (
  id_rol INT IDENTITY(1,1) NOT NULL,
  nombre_rol NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_rol PRIMARY KEY (id_rol),
  CONSTRAINT uq_rol_nombre_rol UNIQUE (nombre_rol)
);

CREATE TABLE academico.especialidad (
  id_especialidad INT IDENTITY(1,1) NOT NULL,
  nombre_especialidad NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_especialidad PRIMARY KEY (id_especialidad),
  CONSTRAINT uq_especialidad_nombre_especialidad UNIQUE (nombre_especialidad)
);

CREATE TABLE academico.turno (
  id_turno INT IDENTITY(1,1) NOT NULL,
  nombre_turno NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_turno PRIMARY KEY (id_turno),
  CONSTRAINT uq_turno_nombre_turno UNIQUE (nombre_turno)
);

CREATE TABLE academico.dia_semana (
  id_dia INT IDENTITY(1,1) NOT NULL,
  nombre_dia NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_dia_semana PRIMARY KEY (id_dia),
  CONSTRAINT uq_dia_semana_nombre_dia UNIQUE (nombre_dia)
);

CREATE TABLE objetos.categoria_objeto (
  id_categoria_objeto INT IDENTITY(1,1) NOT NULL,
  nombre_categoria NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_categoria_objeto PRIMARY KEY (id_categoria_objeto),
  CONSTRAINT uq_categoria_objeto_nombre_categoria UNIQUE (nombre_categoria)
);

CREATE TABLE objetos.estado_objeto (
  id_estado_objeto INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_objeto PRIMARY KEY (id_estado_objeto),
  CONSTRAINT uq_estado_objeto_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE objetos.estado_reclamo (
  id_estado_reclamo INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reclamo PRIMARY KEY (id_estado_reclamo),
  CONSTRAINT uq_estado_reclamo_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE instalaciones.tipo_reporte (
  id_tipo_reporte INT IDENTITY(1,1) NOT NULL,
  nombre_tipo NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_reporte PRIMARY KEY (id_tipo_reporte),
  CONSTRAINT uq_tipo_reporte_nombre_tipo UNIQUE (nombre_tipo)
);

CREATE TABLE instalaciones.estado_reporte (
  id_estado_reporte INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reporte PRIMARY KEY (id_estado_reporte),
  CONSTRAINT uq_estado_reporte_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE instalaciones.estado_reserva (
  id_estado_reserva INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_reserva PRIMARY KEY (id_estado_reserva),
  CONSTRAINT uq_estado_reserva_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE tienda.estado_venta (
  id_estado_venta INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_venta PRIMARY KEY (id_estado_venta),
  CONSTRAINT uq_estado_venta_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE equipos.tipo_recurso (
  id_tipo_recurso INT IDENTITY(1,1) NOT NULL,
  nombre_tipo NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_recurso PRIMARY KEY (id_tipo_recurso),
  CONSTRAINT uq_tipo_recurso_nombre_tipo UNIQUE (nombre_tipo)
);

CREATE TABLE equipos.estado_recurso (
  id_estado_recurso INT IDENTITY(1,1) NOT NULL,
  nombre_estado NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_estado_recurso PRIMARY KEY (id_estado_recurso),
  CONSTRAINT uq_estado_recurso_nombre_estado UNIQUE (nombre_estado)
);

CREATE TABLE equipos.carro (
  id_carro INT IDENTITY(1,1) NOT NULL,
  nombre_carro NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_carro PRIMARY KEY (id_carro),
  CONSTRAINT uq_carro_nombre_carro UNIQUE (nombre_carro)
);

CREATE TABLE deportes.deporte (
  id_deporte INT IDENTITY(1,1) NOT NULL,
  nombre_deporte NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_deporte PRIMARY KEY (id_deporte),
  CONSTRAINT uq_deporte_nombre_deporte UNIQUE (nombre_deporte)
);

CREATE TABLE seguridad.tipo_log (
  id_tipo_log INT IDENTITY(1,1) NOT NULL,
  nombre_evento NVARCHAR(80) NOT NULL,
  CONSTRAINT pk_tipo_log PRIMARY KEY (id_tipo_log),
  CONSTRAINT uq_tipo_log_nombre_evento UNIQUE (nombre_evento)
);

CREATE TABLE seguridad.resultado_log (
  id_resultado INT IDENTITY(1,1) NOT NULL,
  nombre_resultado NVARCHAR(30) NOT NULL,
  CONSTRAINT pk_resultado_log PRIMARY KEY (id_resultado),
  CONSTRAINT uq_resultado_log_nombre_resultado UNIQUE (nombre_resultado)
);

CREATE TABLE seguridad.entidad_log (
  id_entidad INT IDENTITY(1,1) NOT NULL,
  nombre_entidad NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_entidad_log PRIMARY KEY (id_entidad),
  CONSTRAINT uq_entidad_log_nombre_entidad UNIQUE (nombre_entidad)
);

CREATE TABLE instalaciones.tipo_sector (
  id_tipo_sector INT IDENTITY(1,1) NOT NULL,
  nombre_tipo NVARCHAR(50) NOT NULL,
  CONSTRAINT pk_tipo_sector PRIMARY KEY (id_tipo_sector),
  CONSTRAINT uq_tipo_sector_nombre_tipo UNIQUE (nombre_tipo)
);

CREATE TABLE tienda.categoria_producto (
  id_categoria_producto INT IDENTITY(1,1) NOT NULL,
  nombre_categoria NVARCHAR(80) NOT NULL,
  CONSTRAINT pk_categoria_producto PRIMARY KEY (id_categoria_producto),
  CONSTRAINT uq_categoria_producto_nombre_categoria UNIQUE (nombre_categoria)
);

CREATE TABLE equipos.software (
  id_software INT IDENTITY(1,1) NOT NULL,
  nombre_software NVARCHAR(80) NOT NULL,
  CONSTRAINT pk_software PRIMARY KEY (id_software),
  CONSTRAINT uq_software_nombre_software UNIQUE (nombre_software)
);

CREATE TABLE academico.anio (
  id_anio INT IDENTITY(1,1) NOT NULL,
  numero_anio INT NOT NULL,
  CONSTRAINT pk_anio PRIMARY KEY (id_anio),
  CONSTRAINT uq_anio_numero_anio UNIQUE (numero_anio),
  CONSTRAINT ck_anio CHECK (numero_anio BETWEEN 1 AND 7)
);

CREATE TABLE academico.division (
  id_division INT IDENTITY(1,1) NOT NULL,
  numero_division INT NOT NULL,
  CONSTRAINT pk_division PRIMARY KEY (id_division),
  CONSTRAINT uq_division_numero_division UNIQUE (numero_division),
  CONSTRAINT ck_division CHECK (numero_division BETWEEN 1 AND 9)
);

CREATE TABLE academico.franja_horaria (
  id_franja INT IDENTITY(1,1) NOT NULL,
  hora_inicio NVARCHAR(5) NOT NULL,
  hora_fin NVARCHAR(5) NOT NULL,
  CONSTRAINT pk_franja_horaria PRIMARY KEY (id_franja),
  CONSTRAINT ck_franja CHECK (hora_fin > hora_inicio)
);

CREATE TABLE academico.curso (
  id_curso INT IDENTITY(1,1) NOT NULL,
  id_anio INT NOT NULL,
  id_division INT NOT NULL,
  id_especialidad INT NOT NULL,
  CONSTRAINT pk_curso PRIMARY KEY (id_curso),
  CONSTRAINT fk_curso_id_anio FOREIGN KEY (id_anio) REFERENCES academico.anio (id_anio),
  CONSTRAINT fk_curso_id_division FOREIGN KEY (id_division) REFERENCES academico.division (id_division),
  CONSTRAINT fk_curso_id_especialidad FOREIGN KEY (id_especialidad) REFERENCES academico.especialidad (id_especialidad),
  CONSTRAINT uq_curso_id_anio_id_division_id_especialidad UNIQUE (id_anio, id_division, id_especialidad)
);

CREATE TABLE seguridad.usuario (
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
  CONSTRAINT fk_usuario_id_rol FOREIGN KEY (id_rol) REFERENCES seguridad.rol (id_rol),
  CONSTRAINT fk_usuario_id_curso FOREIGN KEY (id_curso) REFERENCES academico.curso (id_curso),
  CONSTRAINT ck_usuario_dni CHECK (dni BETWEEN 1000000 AND 99999999)
);

CREATE TABLE academico.materia (
  id_materia INT IDENTITY(1,1) NOT NULL,
  nombre_materia NVARCHAR(80) NOT NULL,
  codigo_materia NVARCHAR(20) NOT NULL,
  CONSTRAINT pk_materia PRIMARY KEY (id_materia),
  CONSTRAINT uq_materia_codigo_materia UNIQUE (codigo_materia)
);

CREATE TABLE academico.horario_escolar (
  id_bloque INT IDENTITY(1,1) NOT NULL,
  hora_inicio NVARCHAR(5) NOT NULL,
  hora_fin NVARCHAR(5) NOT NULL,
  id_materia INT NOT NULL,
  id_curso INT NOT NULL,
  id_usuario INT NULL,
  id_turno INT NOT NULL,
  CONSTRAINT pk_horario_escolar PRIMARY KEY (id_bloque),
  CONSTRAINT fk_horario_escolar_id_materia FOREIGN KEY (id_materia) REFERENCES academico.materia (id_materia),
  CONSTRAINT fk_horario_escolar_id_curso FOREIGN KEY (id_curso) REFERENCES academico.curso (id_curso),
  CONSTRAINT fk_horario_escolar_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_horario_escolar_id_turno FOREIGN KEY (id_turno) REFERENCES academico.turno (id_turno),
  CONSTRAINT ck_horario_horas CHECK (hora_fin > hora_inicio)
);

CREATE TABLE academico.horario_dia (
  id_bloque INT NOT NULL,
  id_dia INT NOT NULL,
  CONSTRAINT pk_horario_dia PRIMARY KEY (id_bloque, id_dia),
  CONSTRAINT fk_horario_dia_id_bloque FOREIGN KEY (id_bloque) REFERENCES academico.horario_escolar (id_bloque),
  CONSTRAINT fk_horario_dia_id_dia FOREIGN KEY (id_dia) REFERENCES academico.dia_semana (id_dia)
);

CREATE TABLE instalaciones.sector (
  id_sector INT IDENTITY(1,1) NOT NULL,
  nombre_sector NVARCHAR(80) NOT NULL,
  id_tipo_sector INT NOT NULL,
  CONSTRAINT pk_sector PRIMARY KEY (id_sector),
  CONSTRAINT uq_sector_nombre_sector UNIQUE (nombre_sector),
  CONSTRAINT fk_sector_id_tipo_sector FOREIGN KEY (id_tipo_sector) REFERENCES instalaciones.tipo_sector (id_tipo_sector)
);

CREATE TABLE objetos.objeto_perdido (
  id_objeto INT IDENTITY(1,1) NOT NULL,
  titulo NVARCHAR(80) NOT NULL,
  descripcion NVARCHAR(200) NULL,
  ruta_foto NVARCHAR(150) NULL,
  fecha_registro DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_categoria_objeto INT NOT NULL,
  id_estado_objeto INT NOT NULL,
  id_sector INT NOT NULL,
  detalle_reservado NVARCHAR(200) NULL,
  CONSTRAINT pk_objeto_perdido PRIMARY KEY (id_objeto),
  CONSTRAINT fk_objeto_perdido_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_objeto_perdido_id_categoria_objeto FOREIGN KEY (id_categoria_objeto) REFERENCES objetos.categoria_objeto (id_categoria_objeto),
  CONSTRAINT fk_objeto_perdido_id_estado_objeto FOREIGN KEY (id_estado_objeto) REFERENCES objetos.estado_objeto (id_estado_objeto),
  CONSTRAINT fk_objeto_perdido_id_sector FOREIGN KEY (id_sector) REFERENCES instalaciones.sector (id_sector)
);

CREATE TABLE objetos.reclamo_objeto (
  id_reclamo INT IDENTITY(1,1) NOT NULL,
  prueba_pertenencia NVARCHAR(200) NOT NULL,
  fecha_reclamo DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_objeto INT NOT NULL,
  id_estado_reclamo INT NOT NULL,
  CONSTRAINT pk_reclamo_objeto PRIMARY KEY (id_reclamo),
  CONSTRAINT fk_reclamo_objeto_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_reclamo_objeto_id_objeto FOREIGN KEY (id_objeto) REFERENCES objetos.objeto_perdido (id_objeto),
  CONSTRAINT fk_reclamo_objeto_id_estado_reclamo FOREIGN KEY (id_estado_reclamo) REFERENCES objetos.estado_reclamo (id_estado_reclamo)
);

CREATE UNIQUE INDEX ux_reclamo_usuario_objeto ON objetos.reclamo_objeto (id_usuario, id_objeto);

CREATE TABLE objetos.consulta_objeto (
  id_consulta INT IDENTITY(1,1) NOT NULL,
  fecha_publicacion DATETIME NOT NULL,
  descripcion_busqueda NVARCHAR(200) NOT NULL,
  id_usuario INT NOT NULL,
  CONSTRAINT pk_consulta_objeto PRIMARY KEY (id_consulta),
  CONSTRAINT fk_consulta_objeto_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario)
);

CREATE TABLE instalaciones.reporte_higiene (
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
  CONSTRAINT fk_reporte_higiene_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_reporte_higiene_id_sector FOREIGN KEY (id_sector) REFERENCES instalaciones.sector (id_sector),
  CONSTRAINT fk_reporte_higiene_id_tipo_reporte FOREIGN KEY (id_tipo_reporte) REFERENCES instalaciones.tipo_reporte (id_tipo_reporte),
  CONSTRAINT fk_reporte_higiene_id_estado_reporte FOREIGN KEY (id_estado_reporte) REFERENCES instalaciones.estado_reporte (id_estado_reporte),
  CONSTRAINT fk_reporte_higiene_id_usuario_resolutor FOREIGN KEY (id_usuario_resolutor) REFERENCES seguridad.usuario (id_usuario)
);

CREATE TABLE tienda.grupo_buffet (
  id_grupo INT IDENTITY(1,1) NOT NULL,
  nombre_grupo NVARCHAR(50) NOT NULL,
  pin_acceso NVARCHAR(20) NOT NULL,
  meta_monto INT NOT NULL,
  CONSTRAINT pk_grupo_buffet PRIMARY KEY (id_grupo),
  CONSTRAINT uq_grupo_buffet_nombre_grupo UNIQUE (nombre_grupo),
  CONSTRAINT ck_grupo_meta CHECK (meta_monto > 0)
);

CREATE TABLE tienda.integrante_grupo (
  id_usuario INT NOT NULL,
  id_grupo INT NOT NULL,
  CONSTRAINT pk_integrante_grupo PRIMARY KEY (id_usuario, id_grupo),
  CONSTRAINT fk_integrante_grupo_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_integrante_grupo_id_grupo FOREIGN KEY (id_grupo) REFERENCES tienda.grupo_buffet (id_grupo)
);

CREATE TABLE tienda.producto_buffet (
  id_producto INT IDENTITY(1,1) NOT NULL,
  nombre_producto NVARCHAR(80) NOT NULL,
  precio INT NOT NULL,
  stock INT NOT NULL,
  id_usuario INT NOT NULL,
  id_grupo INT NULL,
  id_categoria_producto INT NOT NULL DEFAULT 1,
  ruta_foto NVARCHAR(150) NULL,
  aprobado TINYINT NOT NULL DEFAULT 0,
  id_usuario_revisor INT NULL,
  CONSTRAINT pk_producto_buffet PRIMARY KEY (id_producto),
  CONSTRAINT fk_producto_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_producto_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES tienda.grupo_buffet (id_grupo),
  CONSTRAINT fk_producto_buffet_id_categoria_producto FOREIGN KEY (id_categoria_producto) REFERENCES tienda.categoria_producto (id_categoria_producto),
  CONSTRAINT fk_producto_buffet_id_usuario_revisor FOREIGN KEY (id_usuario_revisor) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT ck_producto_precio CHECK (precio > 0),
  CONSTRAINT ck_producto_stock CHECK (stock >= 0),
  CONSTRAINT ck_producto_aprobado CHECK (aprobado IN (0, 1)),
  CONSTRAINT ck_producto_aprobado_revisor CHECK (aprobado = 0 OR id_usuario_revisor IS NOT NULL)
);

CREATE TABLE tienda.venta_buffet (
  id_venta INT IDENTITY(1,1) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_estado_venta INT NOT NULL,
  CONSTRAINT pk_venta_buffet PRIMARY KEY (id_venta),
  CONSTRAINT fk_venta_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_venta_buffet_id_estado_venta FOREIGN KEY (id_estado_venta) REFERENCES tienda.estado_venta (id_estado_venta)
);

CREATE TABLE tienda.detalle_venta (
  id_venta INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario INT NOT NULL,
  CONSTRAINT pk_detalle_venta PRIMARY KEY (id_venta, id_producto),
  CONSTRAINT fk_detalle_venta_id_venta FOREIGN KEY (id_venta) REFERENCES tienda.venta_buffet (id_venta),
  CONSTRAINT fk_detalle_venta_id_producto FOREIGN KEY (id_producto) REFERENCES tienda.producto_buffet (id_producto),
  CONSTRAINT ck_detalle_cantidad CHECK (cantidad > 0)
);

CREATE TABLE tienda.donacion_buffet (
  id_donacion INT IDENTITY(1,1) NOT NULL,
  monto INT NOT NULL,
  fecha_hora DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_grupo INT NOT NULL,
  CONSTRAINT pk_donacion_buffet PRIMARY KEY (id_donacion),
  CONSTRAINT fk_donacion_buffet_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_donacion_buffet_id_grupo FOREIGN KEY (id_grupo) REFERENCES tienda.grupo_buffet (id_grupo),
  CONSTRAINT ck_donacion_monto CHECK (monto > 0)
);

CREATE TABLE equipos.recursos_ct (
  id_recurso INT IDENTITY(1,1) NOT NULL,
  id_carro INT NULL,
  numero_equipo INT NOT NULL,
  id_tipo_recurso INT NOT NULL,
  id_estado_recurso INT NOT NULL,
  CONSTRAINT pk_recursos_ct PRIMARY KEY (id_recurso),
  CONSTRAINT fk_recursos_ct_id_carro FOREIGN KEY (id_carro) REFERENCES equipos.carro (id_carro),
  CONSTRAINT fk_recursos_ct_id_tipo_recurso FOREIGN KEY (id_tipo_recurso) REFERENCES equipos.tipo_recurso (id_tipo_recurso),
  CONSTRAINT fk_recursos_ct_id_estado_recurso FOREIGN KEY (id_estado_recurso) REFERENCES equipos.estado_recurso (id_estado_recurso),
  CONSTRAINT uq_recursos_ct_id_tipo_recurso_id_carro_numero_equipo UNIQUE (id_tipo_recurso, id_carro, numero_equipo)
);

CREATE TABLE equipos.recurso_software (
  id_recurso_software INT IDENTITY(1,1) NOT NULL,
  id_recurso INT NOT NULL,
  id_software INT NOT NULL,
  CONSTRAINT pk_recurso_software PRIMARY KEY (id_recurso_software),
  CONSTRAINT fk_recurso_software_id_recurso FOREIGN KEY (id_recurso) REFERENCES equipos.recursos_ct (id_recurso),
  CONSTRAINT fk_recurso_software_id_software FOREIGN KEY (id_software) REFERENCES equipos.software (id_software),
  CONSTRAINT uq_recurso_software_id_recurso_id_software UNIQUE (id_recurso, id_software)
);

CREATE TABLE equipos.prestamo_ct (
  id_prestamo INT IDENTITY(1,1) NOT NULL,
  fecha_prestamo DATETIME NOT NULL,
  hora_prestamo NVARCHAR(5) NOT NULL,
  hora_devolucion NVARCHAR(5) NULL,
  observaciones NVARCHAR(200) NULL,
  id_usuario_solicitante INT NOT NULL,
  id_usuario_autorizador INT NOT NULL,
  id_recurso INT NOT NULL,
  CONSTRAINT pk_prestamo_ct PRIMARY KEY (id_prestamo),
  CONSTRAINT fk_prestamo_ct_id_usuario_solicitante FOREIGN KEY (id_usuario_solicitante) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_prestamo_ct_id_usuario_autorizador FOREIGN KEY (id_usuario_autorizador) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_prestamo_ct_id_recurso FOREIGN KEY (id_recurso) REFERENCES equipos.recursos_ct (id_recurso)
);

CREATE TABLE instalaciones.reserva_sector (
  id_reserva INT IDENTITY(1,1) NOT NULL,
  fecha_reserva DATETIME NOT NULL,
  hora_inicio NVARCHAR(5) NOT NULL,
  hora_fin NVARCHAR(5) NOT NULL,
  id_usuario INT NOT NULL,
  id_sector INT NOT NULL,
  id_estado_reserva INT NOT NULL,
  id_usuario_autorizador INT NULL,
  CONSTRAINT pk_reserva_sector PRIMARY KEY (id_reserva),
  CONSTRAINT fk_reserva_sector_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_reserva_sector_id_sector FOREIGN KEY (id_sector) REFERENCES instalaciones.sector (id_sector),
  CONSTRAINT fk_reserva_sector_id_estado_reserva FOREIGN KEY (id_estado_reserva) REFERENCES instalaciones.estado_reserva (id_estado_reserva),
  CONSTRAINT fk_reserva_sector_id_usuario_autorizador FOREIGN KEY (id_usuario_autorizador) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT ck_reserva_horas CHECK (hora_fin > hora_inicio)
);

CREATE TABLE deportes.oferta_deporte (
  id_oferta INT IDENTITY(1,1) NOT NULL,
  id_deporte INT NOT NULL,
  id_dia INT NOT NULL,
  id_franja INT NOT NULL,
  cupo_maximo INT NOT NULL,
  CONSTRAINT pk_oferta_deporte PRIMARY KEY (id_oferta),
  CONSTRAINT fk_oferta_deporte_id_deporte FOREIGN KEY (id_deporte) REFERENCES deportes.deporte (id_deporte),
  CONSTRAINT fk_oferta_deporte_id_dia FOREIGN KEY (id_dia) REFERENCES academico.dia_semana (id_dia),
  CONSTRAINT fk_oferta_deporte_id_franja FOREIGN KEY (id_franja) REFERENCES academico.franja_horaria (id_franja),
  CONSTRAINT uq_oferta_deporte_id_deporte_id_dia_id_franja UNIQUE (id_deporte, id_dia, id_franja),
  CONSTRAINT ck_oferta_cupo CHECK (cupo_maximo > 0)
);

CREATE TABLE deportes.inscripcion_ed_fisica (
  id_inscripcion INT IDENTITY(1,1) NOT NULL,
  fecha_inscripcion DATETIME NOT NULL,
  id_usuario INT NOT NULL,
  id_oferta INT NOT NULL,
  CONSTRAINT pk_inscripcion_ed_fisica PRIMARY KEY (id_inscripcion),
  CONSTRAINT uq_inscripcion_ed_fisica_id_usuario UNIQUE (id_usuario),
  CONSTRAINT fk_inscripcion_ed_fisica_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_inscripcion_ed_fisica_id_oferta FOREIGN KEY (id_oferta) REFERENCES deportes.oferta_deporte (id_oferta)
);

CREATE TABLE seguridad.log_auditoria (
  id_log INT IDENTITY(1,1) NOT NULL,
  fecha_hora DATETIME NOT NULL,
  direccion_ip NVARCHAR(80) NOT NULL,
  descripcion_evento NVARCHAR(200) NOT NULL,
  id_entidad INT NOT NULL,
  id_usuario INT NULL,
  id_tipo_log INT NOT NULL,
  id_resultado INT NOT NULL,
  CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log),
  CONSTRAINT fk_log_auditoria_id_entidad FOREIGN KEY (id_entidad) REFERENCES seguridad.entidad_log (id_entidad),
  CONSTRAINT fk_log_auditoria_id_usuario FOREIGN KEY (id_usuario) REFERENCES seguridad.usuario (id_usuario),
  CONSTRAINT fk_log_auditoria_id_tipo_log FOREIGN KEY (id_tipo_log) REFERENCES seguridad.tipo_log (id_tipo_log),
  CONSTRAINT fk_log_auditoria_id_resultado FOREIGN KEY (id_resultado) REFERENCES seguridad.resultado_log (id_resultado)
);
GO
