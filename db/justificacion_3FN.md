# justificacion_3FN.md — PROYECTO IQUAL (SGE)

Base: CONTEXTO_IQUAL v3.1 (secciones 5, 15 y 21). **47 tablas = 24 catálogos + 23 entidades/relaciones** (las 44 originales más `categoria_producto`, `software` y `recurso_software`). Criterio de 3FN del profesor Linares (sección 11): 1FN (sin grupos repetitivos ni valores no atómicos), 2FN (cada atributo no clave depende de toda la clave), 3FN (sin dependencias transitivas) y **los datos derivados se calculan con una consulta, no se guardan**.

## 1. Cómo se aplicó la regla 7 (catálogo vs. multivalorado)

Todo dato categorizable (estados, tipos, categorías, años, divisiones, días, turnos, deportes, franjas, carros, eventos de log) tiene un conjunto cerrado de valores. Para no repetir texto en cada fila (1FN y 2FN limpias) y poder cambiar el valor en un solo lugar, se resuelve así:

- **En el Chen (conceptual):** `anio` y `division` son **atributos multivaluados** de CURSO (doble elipse), porque son valores simples (1 a 7 y 1 a 9) sin otros datos. Los otros 22 catálogos (los 20 de antes más `categoria_producto` y `software`) son **entidades independientes / tablas maestras** (rectángulos), como pide el profesor.
- **En el Codd (lógico):** un atributo multivaluado no puede quedar como columna, así que `anio` y `division` pasan a tablas catálogo (`id_anio`, `numero_anio` con CHECK 1–7; `id_division`, `numero_division` con CHECK 1–9) y CURSO guarda solo las claves foráneas. Los demás catálogos pasan igual (1 entidad → 1 tabla).
- **Dato derivado:** `recaudado` (grupo) se dibuja en el Chen como elipse punteada (derivado) y **no existe** como columna; `monto_total` de la venta se eliminó; los cupos usados y el «último mantenimiento» se calculan (ver `consultas_verificacion.sql`).


## 1 bis. Schemas (ronda BBDD)

Las 47 tablas se agrupan en 7 schemas (`seguridad`, `academico`, `objetos`, `instalaciones`, `tienda`, `equipos`, `deportes`; mapa en `SCHEMAS.md`). Agrupar no cambia la normalización: ninguna columna, clave ni dependencia se modificó, así que el análisis de 1FN, 2FN y 3FN de abajo vale igual. En SQL Server los schemas son reales; en MySQL queda una sola base y el mapa está documentado.

## 2. Las 47 tablas: Chen → Codd → SQL

Los nombres de tabla y de columna son idénticos en los 3 scripts (`iqual_sqlite.sql`, `03_ModeloSQL_Grupo00_sqlserver.sql`, `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`) y coinciden con la sección 5 y con el contrato de la sección 15 del CONTEXTO.

| # | Tabla (Codd = SQL) | En el Chen | Tipo |
|---|---|---|---|
| 1 | `rol` | Entidad ROL | Catálogo |
| 2 | `especialidad` | Entidad ESPECIALIDAD | Catálogo |
| 3 | `turno` | Entidad TURNO | Catálogo |
| 4 | `dia_semana` | Entidad DIA_SEMANA | Catálogo |
| 5 | `categoria_objeto` | Entidad CATEGORIA_OBJETO | Catálogo |
| 6 | `estado_objeto` | Entidad ESTADO_OBJETO | Catálogo |
| 7 | `estado_reclamo` | Entidad ESTADO_RECLAMO | Catálogo |
| 8 | `tipo_reporte` | Entidad TIPO_REPORTE | Catálogo |
| 9 | `estado_reporte` | Entidad ESTADO_REPORTE | Catálogo |
| 10 | `estado_reserva` | Entidad ESTADO_RESERVA | Catálogo |
| 11 | `estado_venta` | Entidad ESTADO_VENTA | Catálogo |
| 12 | `tipo_recurso` | Entidad TIPO_RECURSO | Catálogo |
| 13 | `estado_recurso` | Entidad ESTADO_RECURSO | Catálogo |
| 14 | `carro` | Entidad CARRO | Catálogo |
| 15 | `deporte` | Entidad DEPORTE | Catálogo |
| 16 | `tipo_log` | Entidad TIPO_LOG | Catálogo |
| 17 | `resultado_log` | Entidad RESULTADO_LOG | Catálogo |
| 18 | `entidad_log` | Entidad ENTIDAD_LOG | Catálogo |
| 19 | `tipo_sector` | Entidad TIPO_SECTOR | Catálogo |
| 20 | `anio` | Atributo multivaluado `anio` (doble elipse) de CURSO | Catálogo |
| 21 | `division` | Atributo multivaluado `division` (doble elipse) de CURSO | Catálogo |
| 22 | `franja_horaria` | Entidad FRANJA_HORARIA | Catálogo |
| 23 | `categoria_producto` | Entidad CATEGORIA_PRODUCTO (nueva) | Catálogo |
| 24 | `software` | Entidad SOFTWARE (nueva) | Catálogo |
| 25 | `curso` | Entidad CURSO | Entidad / relación |
| 26 | `usuario` | Entidad USUARIO | Entidad / relación |
| 27 | `materia` | Entidad MATERIA | Entidad / relación |
| 28 | `horario_escolar` | Entidad HORARIO_ESCOLAR | Entidad / relación |
| 29 | `horario_dia` | Relación N:M «se dicta los» (HORARIO_ESCOLAR – DIA_SEMANA) | Entidad / relación |
| 30 | `sector` | Entidad SECTOR | Entidad / relación |
| 31 | `objeto_perdido` | Entidad OBJETO_PERDIDO | Entidad / relación |
| 32 | `reclamo_objeto` | Entidad RECLAMO_OBJETO | Entidad / relación |
| 33 | `consulta_objeto` | Entidad CONSULTA_OBJETO | Entidad / relación |
| 34 | `reporte_higiene` | Entidad REPORTE_HIGIENE | Entidad / relación |
| 35 | `grupo_buffet` | Entidad GRUPO_BUFFET | Entidad / relación |
| 36 | `integrante_grupo` | Relación N:M «integra» (USUARIO – GRUPO_BUFFET) | Entidad / relación |
| 37 | `producto_buffet` | Entidad PRODUCTO_BUFFET | Entidad / relación |
| 38 | `venta_buffet` | Entidad VENTA_BUFFET | Entidad / relación |
| 39 | `detalle_venta` | Relación N:M «detalla» (VENTA_BUFFET – PRODUCTO_BUFFET) con atributos cantidad y precio_unitario | Entidad / relación |
| 40 | `donacion_buffet` | Entidad DONACION_BUFFET | Entidad / relación |
| 41 | `recursos_ct` | Entidad RECURSOS_CT | Entidad / relación |
| 42 | `recurso_software` | Relación N:M «tiene instalado» (RECURSOS_CT – SOFTWARE) | Entidad / relación |
| 43 | `prestamo_ct` | Entidad PRESTAMO_CT | Entidad / relación |
| 44 | `reserva_sector` | Entidad RESERVA_SECTOR | Entidad / relación |
| 45 | `oferta_deporte` | Entidad OFERTA_DEPORTE | Entidad / relación |
| 46 | `inscripcion_ed_fisica` | Entidad INSCRIPCION_ED_FISICA | Entidad / relación |
| 47 | `log_auditoria` | Entidad LOG_AUDITORIA | Entidad / relación |

Resumen: **41 entidades** en el Chen (22 catálogos + 19 entidades de negocio). Las otras 6 tablas no son entidad: **2 atributos multivaluados** (`anio`, `division`) y **4 relaciones N:M** (`horario_dia`, `integrante_grupo`, `detalle_venta`, `recurso_software`). 41 + 6 = 47.

## 3. Catálogos (24): PK, dependencias y por qué están en 3FN

Todos tienen la misma forma: clave `id_*` y un único atributo no clave. No hay grupos repetitivos (1FN), la clave es simple (2FN no aplica) y con un solo atributo no clave no puede haber dependencia transitiva (3FN).

| Tabla | PK | Dependencia funcional | Valores |
|---|---|---|---|
| `rol` | `id_rol` | id_rol → nombre_rol (y nombre_rol → id_rol por ser UQ) | ver §5 |
| `especialidad` | `id_especialidad` | id_especialidad → nombre_especialidad (y nombre_especialidad → id_especialidad por ser UQ) | ver §5 |
| `turno` | `id_turno` | id_turno → nombre_turno (y nombre_turno → id_turno por ser UQ) | ver §5 |
| `dia_semana` | `id_dia` | id_dia → nombre_dia (y nombre_dia → id_dia por ser UQ) | ver §5 |
| `categoria_objeto` | `id_categoria_objeto` | id_categoria_objeto → nombre_categoria (y nombre_categoria → id_categoria_objeto por ser UQ) | ver §5 |
| `estado_objeto` | `id_estado_objeto` | id_estado_objeto → nombre_estado (y nombre_estado → id_estado_objeto por ser UQ) | ver §5 |
| `estado_reclamo` | `id_estado_reclamo` | id_estado_reclamo → nombre_estado (y nombre_estado → id_estado_reclamo por ser UQ) | ver §5 |
| `tipo_reporte` | `id_tipo_reporte` | id_tipo_reporte → nombre_tipo (y nombre_tipo → id_tipo_reporte por ser UQ) | ver §5 |
| `estado_reporte` | `id_estado_reporte` | id_estado_reporte → nombre_estado (y nombre_estado → id_estado_reporte por ser UQ) | ver §5 |
| `estado_reserva` | `id_estado_reserva` | id_estado_reserva → nombre_estado (y nombre_estado → id_estado_reserva por ser UQ) | ver §5 |
| `estado_venta` | `id_estado_venta` | id_estado_venta → nombre_estado (y nombre_estado → id_estado_venta por ser UQ) | ver §5 |
| `tipo_recurso` | `id_tipo_recurso` | id_tipo_recurso → nombre_tipo (y nombre_tipo → id_tipo_recurso por ser UQ) | ver §5 |
| `estado_recurso` | `id_estado_recurso` | id_estado_recurso → nombre_estado (y nombre_estado → id_estado_recurso por ser UQ) | ver §5 |
| `carro` | `id_carro` | id_carro → nombre_carro (y nombre_carro → id_carro por ser UQ) | ver §5 |
| `deporte` | `id_deporte` | id_deporte → nombre_deporte (y nombre_deporte → id_deporte por ser UQ) | ver §5 |
| `tipo_log` | `id_tipo_log` | id_tipo_log → nombre_evento (y nombre_evento → id_tipo_log por ser UQ) | ver §5 |
| `resultado_log` | `id_resultado` | id_resultado → nombre_resultado (y nombre_resultado → id_resultado por ser UQ) | ver §5 |
| `entidad_log` | `id_entidad` | id_entidad → nombre_entidad (y nombre_entidad → id_entidad por ser UQ) | ver §5 |
| `tipo_sector` | `id_tipo_sector` | id_tipo_sector → nombre_tipo (y nombre_tipo → id_tipo_sector por ser UQ) | ver §5 |
| `categoria_producto` | `id_categoria_producto` | id_categoria_producto → nombre_categoria (y nombre_categoria → id_categoria_producto por ser UQ) | Comida, Bebida, Accesorios, Ropa, Otros |
| `software` | `id_software` | id_software → nombre_software (y nombre_software → id_software por ser UQ) | lista de programas (datos reales) |
| `anio` | `id_anio` | id_anio → numero_anio (y numero_anio → id_anio por ser UQ) | 1 a 7 |
| `division` | `id_division` | id_division → numero_division (y numero_division → id_division por ser UQ) | 1 a 9 |
| `franja_horaria` | `id_franja` | id_franja → hora_inicio, hora_fin (UQ no se declara: una franja = un par de horas, CHECK fin > inicio) | 5 franjas de 2 h (08:00 a 18:00) |

## 4. Entidades y relaciones (23): PK, dependencias y justificación

| Tabla | PK | Dependencias funcionales | 1FN / 2FN / 3FN |
|---|---|---|---|
| `curso` | `id_curso` | id_curso → id_anio, id_division, id_especialidad. Clave candidata (id_anio, id_division, id_especialidad) → id_curso. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `usuario` | `id_usuario` | id_usuario → todos los demás. Claves candidatas: dni, usuario_nick, email (cada una determina al resto). | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `materia` | `id_materia` | id_materia → nombre_materia, codigo_materia. codigo_materia (UQ) → id_materia. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `horario_escolar` | `id_bloque` | id_bloque → hora_inicio, hora_fin, id_materia, id_curso, id_usuario, id_turno. Ver duda D1 (id_turno). | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `horario_dia` | `id_bloque, id_dia` | Clave compuesta (id_bloque, id_dia) sin atributos no clave: no puede haber dependencia parcial ni transitiva. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `sector` | `id_sector` | id_sector → nombre_sector, id_tipo_sector. nombre_sector (UQ) → id_sector. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `objeto_perdido` | `id_objeto` | id_objeto → titulo, descripcion, ruta_foto, detalle_reservado, fecha_registro, id_usuario (publicó), id_categoria_objeto, id_estado_objeto, id_sector. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `reclamo_objeto` | `id_reclamo` | id_reclamo → prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `consulta_objeto` | `id_consulta` | id_consulta → fecha_publicacion, descripcion_busqueda, id_usuario. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `reporte_higiene` | `id_reporte` | id_reporte → fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte, fecha_hora_resolucion, id_usuario_resolutor. Ver duda D7. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `grupo_buffet` | `id_grupo` | id_grupo → nombre_grupo, pin_acceso, meta_monto. nombre_grupo (UQ) → id_grupo. «recaudado» NO existe: se calcula. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `integrante_grupo` | `id_usuario, id_grupo` | Clave compuesta (id_usuario, id_grupo) sin atributos no clave. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `producto_buffet` | `id_producto` | id_producto → nombre_producto, precio, stock, ruta_foto, id_usuario (vendedor), id_grupo, id_categoria_producto. El contacto del vendedor sale de usuario. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `venta_buffet` | `id_venta` | id_venta → fecha_hora, id_usuario (comprador), id_estado_venta. «monto_total» NO existe: se calcula con SUM(cantidad*precio_unitario). | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `detalle_venta` | `id_venta, id_producto` | (id_venta, id_producto) → cantidad, precio_unitario (dependen de la clave completa). Ver duda D2. | 1FN: valores atómicos. 2FN: cantidad y precio_unitario dependen de (id_venta, id_producto) completa, no de una sola. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. (con la salvedad de la duda D2). |
| `donacion_buffet` | `id_donacion` | id_donacion → monto, fecha_hora, id_usuario, id_grupo. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `recursos_ct` | `id_recurso` | id_recurso → id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso. Clave candidata (id_tipo_recurso, id_carro, numero_equipo). Ver duda D3. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `recurso_software` | `id_recurso_software` | id_recurso_software → id_recurso, id_software. Clave candidata UQ(id_recurso, id_software): un programa se instala una sola vez por equipo. Ver duda D12. | 1FN: valores atómicos (un programa por fila, no una lista dentro de recursos_ct). 2FN: la clave sustituta es simple. 3FN: no hay atributos no clave aparte de las dos FK. |
| `prestamo_ct` | `id_prestamo` | id_prestamo → fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `reserva_sector` | `id_reserva` | id_reserva → fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `oferta_deporte` | `id_oferta` | id_oferta → id_deporte, id_dia, id_franja, cupo_maximo. Clave candidata (id_deporte, id_dia, id_franja). Los cupos usados se cuentan, no se guardan. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `inscripcion_ed_fisica` | `id_inscripcion` | id_inscripcion → fecha_inscripcion, id_usuario, id_oferta. id_usuario (UQ) → id_inscripcion: una inscripción por alumno. Deporte y franja salen de la oferta (no se repiten). | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |
| `log_auditoria` | `id_log` | id_log → fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado. | 1FN: todos los valores son atómicos. 2FN: no hay atributos no clave dependientes de una parte de la clave. 3FN: lo categorizable está en catálogos (FK) y lo derivado no se guarda, así que no hay dependencias entre atributos no clave. |

## 5. Lista de dudas de 3FN (NO se cambió nada en silencio)

Cada punto se dejó **como está en el contrato (sección 5)**. Si el profesor o vos prefieren otra opción, se cambia en las 3 versiones del modelo a la vez.

- **D1 — `horario_escolar.id_turno`.** El turno (Mañana/Tarde) se podría deducir de `hora_inicio` o del curso. Si existiera la regla «hora_inicio → turno» sería una dependencia transitiva (id_bloque → hora_inicio → id_turno) y rompería la 3FN. Como esa regla no está guardada en ninguna tabla (no hay una tabla que diga hasta qué hora es Mañana), se dejó. Opciones: (a) dejarlo; (b) quitarlo y deducirlo por consulta; (c) pasar el turno a `curso` (cada curso cursa en un turno).
- **D2 — `detalle_venta.precio_unitario`.** Depende de la clave completa (id_venta, id_producto) y NO es derivable de `producto_buffet.precio`, porque el precio del producto puede cambiar después de la venta: guarda el precio **histórico** de esa línea. Con eso el total de una venta (que sí es derivado y no se guarda) no cambia si se edita el producto. Un criterio muy estricto de «derivado» podría objetarlo. Opción alternativa: quitarlo y calcular con `producto_buffet.precio` (el total histórico quedaría inestable).
- **D3 — `recursos_ct` y el carro NULL de los tableros.** UQ(id_tipo_recurso, id_carro, numero_equipo): en SQLite y MySQL los NULL no cuentan como iguales, así que dos tableros con el mismo número no serían rechazados por la base; SQL Server sí los rechaza. No es un problema de 3FN; la app lo controla (D8). Si se quisiera forzar en todos los motores habría que sacar el carro de los tableros a otra tabla.
- **D4 — `recaudado` en el Chen.** Aparece como atributo derivado (elipse punteada) en GRUPO_BUFFET y no pasa al Codd. Es lo que pide la sección 12 para derivados; si el profesor prefiere no mostrarlo, se borra la elipse.
- **D5 — `usuario.id_curso` opcional.** Solo los alumnos tienen curso; para los demás roles queda NULL. Una alternativa más «pura» sería una tabla `alumno` (subtipo) pero no está en el contrato (la sección 12 además evita generalizaciones).
- **D6 — `reporte_higiene`: resolución.** `fecha_hora_resolucion` e `id_usuario_resolutor` son NULL juntos mientras el reporte está Pendiente. No es una dependencia entre atributos no clave en sentido estricto, pero podría ir en una tabla aparte 1 a 0..1.
- **D7 — rangos de horas repetidos.** `horario_escolar` y `franja_horaria` (y `reserva_sector`) guardan horas de inicio y fin; son conceptos distintos (clase, franja de Ed. Física, reserva) y no hay dependencia entre ellos.
- **D8 — roles y reglas que la base no fuerza.** Que el solicitante de un préstamo sea alumno, o el autorizador profesor/preceptor, no se puede expresar con 3FN: lo valida la app.
- **D9 — `log_auditoria.direccion_ip`.** Guarda el nombre del equipo (D15), pero el nombre de la columna se mantiene como en el diagrama aprobado.
- **D10 — nulabilidad en el Codd.** Siguiendo la sección 12, el diagrama no usa símbolos de «cero o uno»: las FK opcionales (marcadas con `?` en la sección 5) se dibujan igual que las obligatorias. Qué columnas admiten NULL se ve en los scripts SQL.

- **D11 — `producto_buffet.id_categoria_producto` con DEFAULT 1.** La categoría del producto es una FK a un catálogo (no un texto repetido). El `DEFAULT 1` (Comida) existe solo para que la columna pueda ser NOT NULL aunque un script viejo no la nombre; la app siempre la elige. Si cambia el orden de carga del catálogo, el DEFAULT apunta a otra categoría: por eso `categoria_producto` se carga antes que los productos.
- **D12 — `recurso_software`: N:M con clave sustituta.** Un equipo tiene muchos programas y un programa está en muchos equipos, así que va en una tabla intermedia (si fuera una columna de texto con la lista, rompería la 1FN). Se le dio `id_recurso_software` propio y UQ(id_recurso, id_software) en vez de clave compuesta, igual que el contrato de la sección 15. Es equivalente en 3FN.
- **D13 — `objeto_perdido.detalle_reservado` y quién lo ve.** Es un atributo más del objeto (depende solo de `id_objeto`). Que solo lo vea el Preceptor es una regla de la app, no de la base.
- **D14 — `ux_reclamo_usuario_objeto`.** Índice único (id_usuario, id_objeto) en `reclamo_objeto`: una persona reclama un objeto una sola vez. No es de 3FN sino integridad; en SQL Server 2005 y MySQL se crea con `CREATE UNIQUE INDEX`.
- **D15 — `recaudado` y la regla de «Entregada».** Sigue siendo derivado (no existe como columna). Desde la v2.5 se calcula como donaciones + ventas **Entregadas** (no «no canceladas»); las consultas están actualizadas.
- **D16 — Collation de MySQL.** Los scripts de MySQL no nombran `COLLATE`; se usa la del servidor (MySQL 8: `utf8mb4_0900_ai_ci`, no distingue mayúsculas ni tildes). No es una cuestión de 3FN sino de comparación de textos: `UNIQUE` de nombres de catálogo, de `usuario_nick` y de `email` rechazan valores que solo difieren en mayúsculas o tildes, y el login ya normaliza el nick a minúsculas en la app. Se dejó como está; las opciones y el efecto en cada lugar están en `REVISION_ESTATICA_MYSQL.md` (sección 2).

## 6. Dónde está cada cosa en SQL

- Tipos: ids `INTEGER PRIMARY KEY AUTOINCREMENT` (SQLite), `INT IDENTITY(1,1)` (SQL Server 2005), `INT AUTO_INCREMENT` (MySQL 8). Textos con tildes: `NVARCHAR` en SQL Server; en MySQL `utf8mb4` con motor InnoDB. Fechas: `TEXT` `yyyy-MM-dd` (SQLite), `DATETIME` (SQL Server), `DATE` (MySQL); horas `HH:mm` como texto de largo 5 en los tres.
- Restricciones: PK, UQ, FK con nombre, CHECK (año 1–7, división 1–9, DNI de 7 a 8 dígitos, hora_fin > hora_inicio, precio > 0, stock >= 0, cantidad > 0, monto > 0, meta_monto > 0, cupo_maximo > 0). Nota para MySQL: los CHECK se aplican desde MySQL 8.0.16 y desde MariaDB 10.2.1; en versiones anteriores se aceptan pero se ignoran.
- Datos de ejemplo: todo lo que está debajo de la línea `-- DATOS DE EJEMPLO, REEMPLAZAR AL FINAL`. Las reservas de sectores usan fechas relativas a hoy (`date('now','localtime','+n day')` en SQLite, `DATE_ADD(CURDATE(), INTERVAL n DAY)` en MySQL, `DATEADD(day, n, DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0))` en SQL Server 2005, que deja la fecha a medianoche).
- `iqual_sqlite.sql` y `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`: sin triggers, sin BEGIN...END, sin `DELIMITER` y sin «;» dentro de textos o comentarios (la app los parte por «;»). Los procedimientos almacenados van aparte en `05_Backend_Grupo00.sql`.
- **Qué se ejecutó y qué no.** SQLite: se ejecutó siempre. MySQL: `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` (47 tablas, 5 usuarios), `05_Backend_Grupo00.sql`, `consultas_demo.sql` y `consultas_verificacion_mysql.sql` corrieron **en MariaDB 10.11** con `ONLY_FULL_GROUP_BY`, sin errores y con los valores esperados (dato del 10/11/2026). **No se ejecutó:** MySQL 8 de Oracle, SQL Server 2005 (solo revisión de lectura: `REVISION_ESTATICA_SQLSERVER.md`) ni nada en Windows.

## Desvíos

- Respecto de la versión anterior: cabecera pasada a v2.9; nota de `CHECK` corregida (MariaDB los aplica desde 10.2.1); la expresión de fechas relativas de SQL Server ahora es la que usa el script; se reescribió el punto «qué no se pudo ejecutar» y se agregó D16 (collation). El resto del texto no cambió.
- La ejecución en MariaDB 10.11 es un dato que me pasaron (10/11/2026); no la repetí.
- Esta ronda: cabecera pasada a v3.1 y agregada la sección «1 bis. Schemas». El análisis de normalización no cambió.
- No se tocó ningún script.

## Datos que faltan

- [COMPLETAR: resultado de correr los scripts en MySQL 8 de Oracle y en SQL Server 2005, si alguno es el motor de la defensa]
- [COMPLETAR: qué opción de la duda D16 prefiere el profesor, si pregunta]

