# REVISION_ESTATICA_SQLSERVER.md — revisión de los scripts de SQL Server (`03`, `04` y las consultas) contra SQL Server 2005

**Aclaración principal:** ninguno de los dos archivos se ejecutó en SQL Server (no hay servidor en mi entorno). Esto es lectura del texto más chequeos automáticos con scripts. «Sin hallazgos» quiere decir que no vi nada leyendo; **no** quiere decir que corra. Lo único que lo confirma es ejecutarlo en una instancia 2005 (o 2005 Express) y mirar que no dé errores.

## 0. Revisión de la ronda de cierre (19/11/2026)

Alcance: `03_ModeloSQL_Grupo00_sqlserver.sql`, `04_DatosSQL_Grupo00_sqlserver.sql`, `consultas_demo_sqlserver.sql` y `consultas_verificacion_sqlserver.sql`, contra sus versiones de MySQL (`03_ModeloSQL_Grupo00.sql`, `04_DatosSQL_Grupo00.sql`, `consultas_demo.sql`, `consultas_verificacion_mysql.sql`). **Sigue siendo revisión estática: nada se ejecutó en SQL Server.** Las comparaciones las hizo un script que lee los dos archivos; los `INSERT` de datos se compararon fila por fila con los de MySQL, que sí cargan en MariaDB; eso no prueba la sintaxis de T-SQL.

| Qué se comparó | Resultado |
|---|---|
| Tablas | 47 en las dos versiones, mismos nombres; en SQL Server repartidas en 7 schemas (seguridad 6, academico 10, objetos 6, instalaciones 7, tienda 8, equipos 7, deportes 3) |
| Columnas, nulabilidad, `PRIMARY KEY`, `UNIQUE`, `FOREIGN KEY` (57 en las dos), `CHECK` | Idénticas línea por línea. Las únicas diferencias son las esperadas: `AUTO_INCREMENT` → `IDENTITY(1,1)`, `VARCHAR` → `NVARCHAR`, `DATE` → `DATETIME` (11 columnas de fecha) |
| Orden de `CREATE`, de `DROP` y de `DELETE` | Cada tabla hija va antes que sus padres al borrar y después al crear; sin hallazgos |
| Orden de los `INSERT` | Misma secuencia de tablas que en MySQL; los `INSERT` se resuelven con subconsultas por nombre y en la simulación todos encontraron su fila padre |
| Nombres de constraints | Sin duplicados dentro de un schema (SQL Server los exige únicos por schema) |
| Palabras reservadas | Ningún nombre de tabla ni de columna está en la lista de T-SQL (revisado contra una lista escrita de memoria 🔶) |
| Sintaxis no válida en 2005 | No hay `DATE`/`TIME`/`DATETIME2`, `LIMIT`, `CONCAT`, `IIF`, `FORMAT`, `THROW`, `DROP TABLE IF EXISTS`, `AUTO_INCREMENT`, comillas invertidas, `INSERT` de varias filas ni `DECLARE @x = valor`. `IF NOT EXISTS (SELECT …)` aparece solo como condición de T-SQL (válido) |
| Textos | Todo literal con tilde o ñ lleva prefijo `N''` |
| Fechas | Literales `'yyyymmdd'` / `'yyyymmdd hh:mm:ss'` (no dependen del idioma de la sesión); «hoy + n» con `DATEADD(day, n, DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0))` |
| Datos | 1083 sentencias en cada versión. Listas de columnas iguales; ningún `INSERT` pasa un id de `IDENTITY`; ningún texto supera el largo de su columna; ningún `NULL` en columna `NOT NULL`. Comparados fila por fila: sin diferencias, salvo la expresión de fecha de las 28 reservas de sectores |
| Reinicio de `IDENTITY` | 44 `DBCC CHECKIDENT` (una por cada tabla con `IDENTITY`; las otras 3 tienen clave compuesta) |
| `consultas_demo` y `consultas_verificacion` | Comparadas sentencia por sentencia con MySQL: solo cambian el schema, `TOP`, las fechas (`DATEADD`/`DATEDIFF`) y `sys.tables`. Los valores esperados que dicen los comentarios (62, 24, 10, 5, 5, 28, 5, 28, 21 y 9 filas en las 10 de demo) se calcularon con una carga de prueba fuera de MySQL y no están confirmados en SQL Server |

### Filas por tabla en cada script de datos

`recurso_software` se carga con `INSERT … SELECT`: las 7 sentencias son idénticas en las dos versiones salvo el schema y dan 160 filas (contadas en la simulación). `log_auditoria` queda vacía a propósito.

| Schema (SQL Server) | Tabla | Filas MySQL | Filas SQL Server |
|---|---|---:|---:|
| seguridad | `entidad_log` | 12 | 12 |
| seguridad | `log_auditoria` | 0 | 0 |
| seguridad | `resultado_log` | 2 | 2 |
| seguridad | `rol` | 4 | 4 |
| seguridad | `tipo_log` | 16 | 16 |
| seguridad | `usuario` | 62 | 62 |
| academico | `anio` | 7 | 7 |
| academico | `curso` | 24 | 24 |
| academico | `dia_semana` | 5 | 5 |
| academico | `division` | 9 | 9 |
| academico | `especialidad` | 3 | 3 |
| academico | `franja_horaria` | 5 | 5 |
| academico | `horario_dia` | 229 | 229 |
| academico | `horario_escolar` | 137 | 137 |
| academico | `materia` | 21 | 21 |
| academico | `turno` | 2 | 2 |
| objetos | `categoria_objeto` | 6 | 6 |
| objetos | `consulta_objeto` | 22 | 22 |
| objetos | `estado_objeto` | 4 | 4 |
| objetos | `estado_reclamo` | 3 | 3 |
| objetos | `objeto_perdido` | 23 | 23 |
| objetos | `reclamo_objeto` | 25 | 25 |
| instalaciones | `estado_reporte` | 2 | 2 |
| instalaciones | `estado_reserva` | 4 | 4 |
| instalaciones | `reporte_higiene` | 22 | 22 |
| instalaciones | `reserva_sector` | 28 | 28 |
| instalaciones | `sector` | 22 | 22 |
| instalaciones | `tipo_reporte` | 2 | 2 |
| instalaciones | `tipo_sector` | 2 | 2 |
| tienda | `categoria_producto` | 5 | 5 |
| tienda | `detalle_venta` | 37 | 37 |
| tienda | `donacion_buffet` | 26 | 26 |
| tienda | `estado_venta` | 3 | 3 |
| tienda | `grupo_buffet` | 21 | 21 |
| tienda | `integrante_grupo` | 62 | 62 |
| tienda | `producto_buffet` | 30 | 30 |
| tienda | `venta_buffet` | 28 | 28 |
| equipos | `carro` | 5 | 5 |
| equipos | `estado_recurso` | 3 | 3 |
| equipos | `prestamo_ct` | 24 | 24 |
| equipos | `recurso_software` | 160 | 160 |
| equipos | `recursos_ct` | 60 | 60 |
| equipos | `software` | 6 | 6 |
| equipos | `tipo_recurso` | 2 | 2 |
| deportes | `deporte` | 4 | 4 |
| deportes | `inscripcion_ed_fisica` | 37 | 37 |
| deportes | `oferta_deporte` | 20 | 20 |
| | **Total (47 tablas)** | **1234** | **1234** |

### Hallazgos de esta revisión

| # | Archivo | Qué pasa | Gravedad | Qué se hizo |
|---|---|---|---|---|
| N1 | `consultas_verificacion_sqlserver.sql` y `consultas_verificacion_mysql.sql`, comentario de la consulta 15 | Decía «Son 22: los 6 de siempre y 16 nuevos», pero hay **21** controles (6 y 15) en los dos archivos. | Informativa | Corregido el comentario en los dos archivos y en `LEEME_BASE_DE_DATOS.md`. |
| N2 | `consultas_demo*.sql`, comentario de la cabecera | Decía que las 10 «no se ejecutaron en MySQL»; en MariaDB sí corrieron (CONTEXTO §19.1). | Informativa | Cabecera reescrita en los dos archivos. |
| N3 | `consultas_verificacion*.sql`, cabecera | Decía CONTEXTO v3.1. | Informativa | Pasó a v3.2. |
| N4 | `consultas_demo.sql` | Sin sufijo `_mysql`, a diferencia de `consultas_verificacion_mysql.sql` y de `consultas_demo_sqlserver.sql`. | Informativa | **No** se renombró: lo citan varios documentos. Queda para decidir. |
| N5 | `03_…_sqlserver.sql` | El `UNIQUE` de `recursos_ct` con `id_carro` NULL se comporta distinto en SQL Server (ver hallazgo 2 de abajo). Se verificó que con los datos actuales los 10 tableros (`id_carro` NULL) tienen números distintos. | Baja | Sin cambios. Decirlo en la defensa. |

**No se tocó ningún `03` ni `04` de SQL Server: no se encontró ningún error.** Eso no confirma que corran: lo único que lo confirma es ejecutarlos en una instancia de SQL Server.

### Lo que sigue sin poder confirmarse

- Que el lote de `INSERT` (más de mil sentencias entre dos `GO`) compile y corra sin error en 2005.
- La *collation* del servidor y su efecto en comparaciones con `N'…'`.
- Que `DBCC CHECKIDENT … RESEED` dentro de `IF EXISTS (SELECT … sys.identity_columns … last_value …)` se comporte igual en 2005 Express (la vista existe desde 2005; lo demás es lectura).

## Revisión anterior (12/11/2026, se conserva como estaba)

Archivos revisados: `03_ModeloSQL_Grupo00_sqlserver.sql` (776 líneas) y `consultas_verificacion_sqlserver.sql` (296 líneas), los de `scripts_y_diagramas.zip`.

## 1. Chequeos hechos y resultado

| Tema | Qué se buscó | Resultado |
|---|---|---|
| Tipos de fecha | `DATE`, `TIME`, `DATETIME2`, `DATETIMEOFFSET` (no existen en 2005, llegan en 2008) | No se usan. Las fechas son `DATETIME` (líneas 302, 318, 332, 341, 347, 394, 416, 450, 465, 496, 507) y las horas son `NVARCHAR(5)` |
| Literales de fecha | Formatos ambiguos (`'2026-10-23'` depende del idioma de la sesión) | Todos son `'yyyymmdd'` o `'yyyymmdd hh:mm:ss'`, que son independientes del idioma. Sin hallazgos |
| `IDENTITY` | Sintaxis y que no se inserte id a mano | `IDENTITY(1,1) NOT NULL`; ningún `INSERT` pasa el id |
| `INSERT` de varias filas | `VALUES (...),(...)` (constructor de filas, llega en 2008) | No hay; cada fila tiene su `INSERT`. Sin hallazgos |
| `DECLARE @x = valor` | Inicializar al declarar (llega en 2008) | No se usa ninguna variable |
| `CHECK` | Sintaxis `CONSTRAINT ck_x CHECK (...)` | 12 `CHECK`, todos con `BETWEEN` o comparación de columnas; válidos en 2005 |
| Palabras reservadas | Nombres de tabla y columna contra la lista de T-SQL | Ninguna usada |
| Prefijo `N''` | Textos con tildes o ñ sin `N` (se perderían en una columna `NVARCHAR`) | Todos los textos de los `INSERT` llevan `N`. Sin hallazgos |
| Concatenación | `\|\|`, `CONCAT()` (no existen en 2005) | No se usan |
| `COALESCE` | Disponible desde 2000 | Línea 172 de las consultas; válido |
| `TOP` | `LIMIT` no existe | Se usa `TOP 3` (consultas, línea 183); válido |
| `sys.tables` | Vista de catálogo de 2005 | Línea 296 de las consultas; válida (en 2000 era `sysobjects`) |
| `GO` | Separador de lotes (comando del cliente, no de T-SQL) | 5 `GO` en el script de la base (líneas 3, 5, 53, 521, 776); sirven en SSMS, Management Studio Express y `sqlcmd`. **No** los acepta una conexión directa por ODBC/Qt (ver hallazgo 3) |
| Orden de borrado y creación | Cada `FOREIGN KEY` apunta a una tabla ya creada; los `DROP` van de las hijas a las padres | Sin hallazgos (47 tablas) |
| Largo de nombres | Identificadores ≤ 128 caracteres | El más largo (`uq_recursos_ct_id_tipo_recurso_id_carro_numero_equipo`, 52) está bien |
| Largo de fila | Máximo 8060 bytes por fila | Por la cantidad y el largo de las columnas, ninguna tabla se acerca (cálculo a ojo, no medido) |
| Subconsulta escalar en `VALUES` | `VALUES ((SELECT ...))` | Válido en 2005 |
| `INSERT ... SELECT` | Para `horario_dia` y `recurso_software` | Válido en 2005 (líneas 649 y 730–733) |
| Tabla derivada con alias | `FROM (SELECT ...) x` | Las dos consultas de integridad (líneas 286 y 289) llevan alias `x`; válido |

## 2. Hallazgos

| # | Archivo y línea | Qué pasa | Gravedad | Qué cambiar |
|---|---|---|---|---|
| 1 | `03_ModeloSQL_Grupo00_sqlserver.sql`, línea 1 | (12/11) El comentario de cabecera decía «CONTEXTO_IQUAL v2.7». Hoy el 03 dice «CONTEXTO_IQUAL 21» (número de sección). | Informativa | Sin acción. |
| 2 | `03_ModeloSQL_Grupo00_sqlserver.sql`, línea 425–436 (`recursos_ct`) | El `UNIQUE (id_tipo_recurso, id_carro, numero_equipo)` con `id_carro` NULL se comporta distinto: **SQL Server trata los NULL como iguales** y sí frena dos tableros con el mismo número; MySQL no (duda D3). Con los datos de ejemplo no hay choque: los tableros 1 a 10 tienen `id_carro` NULL pero números distintos (líneas 714–723). | Baja | Nada que cambiar en el script. Hay que **decirlo en la defensa**: en SQL Server la restricción hace más de lo que hace en MySQL. |
| 3 | `03_ModeloSQL_Grupo00_sqlserver.sql`, líneas 3, 5, 53, 521, 776 (`GO`) | `GO` no es T-SQL: lo interpreta el cliente. Si el script se manda entero por ODBC o desde código (como hace la app con `QSqlQuery`), SQL Server da «Incorrect syntax near 'GO'». | Media si se carga desde la app; ninguna en SSMS | Cargarlo desde SSMS o `sqlcmd -i`. La app **hoy** no tiene driver ni camino para SQL Server (§19.1–19.3): usa MySQL por `iqual.ini` y, si no conecta, avisa y no abre. No hay nada que corregir en el script. |
| 4 | `03_ModeloSQL_Grupo00_sqlserver.sql`, línea 2 | `IF DB_ID('iqual') IS NULL CREATE DATABASE iqual;` funciona, pero la base queda con los archivos y la *collation* por defecto del servidor. Si el servidor es *case sensitive* (`..._CS_AS`), `usuario_nick = N'alumno1'` ya no encuentra `Alumno1`, y también cambian los `UNIQUE`. | Baja (depende del servidor) | Mirar la collation con `SELECT SERVERPROPERTY('Collation');`. Lo más común en instalaciones en español es `Modern_Spanish_CI_AS` / `SQL_Latin1_General_CP1_CI_AS` (no distingue mayúsculas; sí tildes). [COMPLETAR: collation del servidor de la escuela] |
| 5 | `03_ModeloSQL_Grupo00_sqlserver.sql`, línea 382 y líneas ~683–684 | `producto_buffet.id_categoria_producto INT NOT NULL DEFAULT 1` apunta a la categoría con id 1. En SQL Server el `IDENTITY` arranca en 1 en una tabla nueva, así que anda; si se recarga solo ese catálogo con `DELETE`, el próximo id no vuelve a 1 (hay que usar `TRUNCATE` o `DBCC CHECKIDENT`). Los dos `UPDATE` posteriores corrigen la categoría de los productos de ejemplo. | Baja | Nada que cambiar en una carga desde cero. No recargar el catálogo suelto. |
| 6 | `consultas_verificacion_sqlserver.sql`, líneas 15 y 28 | `fecha_reserva = DATEADD(day, 1, DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0))` es el truco para «mañana a medianoche» en 2005 (no hay `CAST(... AS DATE)`). Es correcto, pero el script de datos usa la misma expresión (líneas 736–739), así que coinciden si se corre el mismo día de la carga. | Informativa | Nada. Si se carga un día y se consulta otro, las consultas 1A y 1B dan 0 filas / 0 filas en vez de 1 / 0. Es igual que en MySQL. |
| 7 | `consultas_verificacion_sqlserver.sql`, líneas 17–18, 30–31 | Se comparan horas guardadas como texto (`'11:30'`). Funciona porque son siempre `HH:MM` con cero a la izquierda. | Informativa | Nada. Si algún día se guarda `9:00` sin cero, la comparación falla (igual en los tres motores). |
| 8 | `consultas_verificacion_sqlserver.sql`, línea 3 | El comentario dice que se revisó «contra lo visto en la clase 003». Lo único que verifiqué yo es la lectura contra la lista de arriba; no ejecuté nada. | Informativa | Dejar el comentario o reescribirlo como «No se ejecutó en SQL Server». |
| 9 | `consultas_verificacion_sqlserver.sql`, línea 296 | `SELECT COUNT(*) FROM sys.tables` da 47 solo si la base `iqual` tiene únicamente estas tablas. Si se crearon otras (por ejemplo `sysdiagrams`, que SSMS crea al hacer un diagrama), da más. | Baja | Avisar en la defensa. Para contar solo las del proyecto: `WHERE name <> 'sysdiagrams'`. |

No encontré ningún error de sintaxis. Los hallazgos 2 a 5 son **diferencias de comportamiento**, no fallas; el 1 y el 8 son comentarios.

## 3. Lo que no se puede confirmar sin un servidor

- Que los 776 renglones corran de punta a punta sin error (lo más probable es que sí, pero no lo vi correr).
- Que la collation del servidor de la escuela no cambie los resultados de las consultas con `nombre = N'...'`.
- Que las 16 consultas devuelvan los números que dicen los comentarios (por ejemplo 1A = 1 fila, 1B = 0, 16 = 47). En MySQL (MariaDB 10.11) sí corrieron y dieron eso; en SQL Server no.
- Que SSMS Express o `sqlcmd` de 2005 acepten el archivo en UTF-8 con tildes (conviene abrirlo y guardarlo como Unicode si muestra caracteres raros). 🔶

## Desvíos

- No se ejecutó nada en SQL Server 2005 (ni en ninguna otra versión): es revisión de lectura.
- La lista de reglas de 2005 (sin `DATE`, sin `VALUES` múltiple, sin inicialización en `DECLARE`) está escrita de mi conocimiento de la documentación de Microsoft; no la contrasté en esta sesión contra la página oficial. 🔶
- No toqué los scripts: no encontré errores reales, solo los comentarios de los hallazgos 1 y 8, que dejé como están para no entregar archivos nuevos sin necesidad.

## Datos que faltan

- [COMPLETAR: versión y *collation* exacta del SQL Server de la escuela (`SELECT @@VERSION;` y `SELECT SERVERPROPERTY('Collation');`)]
- [COMPLETAR: resultado de correr `03_ModeloSQL_Grupo00_sqlserver.sql` y `consultas_verificacion_sqlserver.sql` en SSMS; si da error, el número y el texto completo]
- [COMPLETAR: confirmación de que el motor de la defensa es MySQL o SQL Server (queda pendiente de hablar con el profesor)]
