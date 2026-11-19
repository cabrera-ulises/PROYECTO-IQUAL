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

- **SQL Server 2005:** schemas reales. `03_ModeloSQL_Grupo00_sqlserver.sql` crea los 7 con `CREATE SCHEMA` y cada tabla vive en el suyo (`seguridad.usuario`). Las claves foráneas entre schemas llevan el nombre completo. Las consultas `_sqlserver` ya traen los nombres calificados.
- **MySQL 8 / MariaDB 10.11:** una sola base, `iqual`, con las 47 tablas sin prefijo. El mapa está como comentario al principio de `03_ModeloSQL_Grupo00.sql`.
- **SQLite:** igual que MySQL (no tiene schemas).

## Por qué MySQL queda con una sola base

En MySQL «schema» y «base de datos» son lo mismo. Dividir en 7 bases obligaría a escribir `schema.tabla` en cada consulta de la app (C++), los 15 procedimientos de funcionalidades, los reportes, las pruebas y los documentos, y cualquier error de nombre rompería todo. Como la consigna pide no cambiar el contrato de nombres de tablas y columnas, la división se muestra en el motor que la soporta de verdad (SQL Server), en el diagrama y en la documentación.

## Cómo defenderlo ante Linares

1. «Dividimos en 7 schemas por área funcional; el mapa está en el script, en el diagrama y en este documento.»
2. «En SQL Server están creados de verdad. En MySQL un schema es una base: partir `iqual` en 7 bases obliga a calificar todo y no aporta seguridad extra en un proyecto con un solo usuario de conexión.»
3. Si pide MySQL dividido igual: se puede generar con el mismo script (`generar_modelo.py`), pero hay que cambiar la app y los procedimientos; es una decisión a tomar con Arce Thiago y Cabrera Ulises.
4. La normalización (3FN) no cambia: los schemas agrupan tablas, no modifican columnas ni claves.

## Desvíos

- Los schemas reales solo existen en la versión SQL Server, que no se ejecutó en un servidor (`CREATE SCHEMA` dentro de `EXEC` y el borrado de tablas viejas en `dbo` están sin probar). 🔶
- No cambié el nombre de ninguna tabla ni columna.

## Datos que faltan

- [COMPLETAR: respuesta de Linares sobre si acepta una sola base en MySQL con el mapa documentado]
- [COMPLETAR: confirmar los nombres de schema con el equipo si quieren otros]
