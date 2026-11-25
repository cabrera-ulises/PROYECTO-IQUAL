# SCHEMAS.md — división del modelo en schemas

La consigna pide un modelo dividido en schemas. Las 47 tablas se reparten en 7 (mapa del CONTEXTO_IQUAL §21).

| Schema | Tablas |
|---|---|
| `seguridad` (6) | rol, usuario, log_auditoria, tipo_log, resultado_log, entidad_log |
| `academico` (10) | especialidad, turno, dia_semana, anio, division, franja_horaria, curso, materia, horario_escolar, horario_dia |
| `objetos` (6) | categoria_objeto, estado_objeto, estado_reclamo, objeto_perdido, reclamo_objeto, consulta_objeto |
| `instalaciones` (7) | tipo_reporte, estado_reporte, estado_reserva, tipo_sector, sector, reporte_higiene, reserva_sector |
| `tienda` (8) | estado_venta, categoria_producto, grupo_buffet, integrante_grupo, producto_buffet, venta_buffet, detalle_venta, donacion_buffet |
| `equipos` (7) | tipo_recurso, estado_recurso, carro, software, recursos_ct, recurso_software, prestamo_ct |
| `deportes` (3) | deporte, oferta_deporte, inscripcion_ed_fisica |

Total: 6 + 10 + 6 + 7 + 8 + 7 + 3 = 47.

## Cómo queda en cada motor

- **MySQL 8 / MariaDB 10.11:** schemas reales. En MySQL un schema es una base, así que `03_ModeloSQL_Grupo06.sql` crea 8 bases con `CREATE DATABASE`: las 7 de la tabla y `iqual`. Cada tabla vive en su schema (`seguridad.usuario`, `tienda.venta_buffet`) y las claves foráneas entre schemas llevan el nombre completo (`REFERENCES seguridad.usuario (id_usuario)`). La base `iqual` no tiene tablas: guarda los 27 procedimientos de `05_Backend_Grupo06.sql` y es la base a la que se conecta la app (`iqual.ini`).
- **SQL Server 2005:** `03_ModeloSQL_Grupo06_sqlserver.sql` crea los 7 con `CREATE SCHEMA` dentro de la base `iqual`. Mismos nombres.

## Qué hubo que cambiar

- Scripts 03, 04, 05, consultas de demo y de verificación, pruebas (06) y la app: todas las tablas se escriben `schema.tabla`.
- `03` empieza con `DROP DATABASE IF EXISTS` de las 8 bases, así que se puede correr de nuevo y borra la carga vieja (la que tenía todo en `iqual`).
- Los nombres de tablas y columnas no cambiaron.

## Verificación (25/11/2026, MariaDB 10.11)

- 03 → 04 → 05 cargados dos veces seguidas sin errores.
- 47 tablas repartidas 6/10/6/7/8/7/3; `iqual` con 0 tablas y 27 procedimientos; 57 claves foráneas.
- Los 104 casos de `06_PruebasSQL.xlsx` dan PASS.
- La app abrió con los 5 roles y se recorrieron todos los módulos; de 2022 sentencias registradas por el servidor, ninguna usó una tabla sin schema.

## Cómo defenderlo

1. «Dividimos en 7 schemas por área funcional: seguridad, académico, objetos, instalaciones, tienda, equipos y deportes.»
2. «En MySQL un schema es una base de datos; por eso el 03 hace `CREATE DATABASE` de cada uno y las tablas se nombran `schema.tabla`.»
3. «Las claves foráneas cruzan schemas sin problema: por ejemplo `tienda.venta_buffet` apunta a `seguridad.usuario`.»
4. «Los procedimientos están en `iqual`, que es la base de conexión de la app.»
5. La normalización (3FN) no cambia: los schemas agrupan tablas, no modifican columnas ni claves.
