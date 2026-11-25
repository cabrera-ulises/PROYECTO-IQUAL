# REVISION_ESTATICA_MYSQL.md — revisión de `03_ModeloSQL_Grupo00.sql`, `04_DatosSQL_Grupo00.sql` y `05_Backend_Grupo00.sql`

## 0. Qué se ejecutó y qué no (estado al 19/11/2026)

**Ejecutado de verdad (CONTEXTO §22; dato que me pasaron, no lo corrí yo en esta sesión):** en un **MariaDB 10.11** (compatible con MySQL 8, pero **no es** MySQL 8) con `ONLY_FULL_GROUP_BY` activada:

- `03_ModeloSQL_Grupo00.sql` y `04_DatosSQL_Grupo00.sql` cargan sin errores: 47 tablas, 62 usuarios.
- `05_Backend_Grupo00.sql` carga y crea los 27 procedimientos; hay 104 casos planificados en `06_PruebasSQL.xlsx`.
- `consultas_demo.sql` (10 consultas) y `consultas_verificacion_mysql.sql` (28 sentencias) corrieron con 0 errores en la ronda anterior (recaudado 3500; 47 tablas).

**Valores esperados (19/11/2026):** los comentarios de `consultas_demo.sql` y `consultas_verificacion_mysql.sql` traen la cantidad de filas esperada con los 62 usuarios (y los 21 controles de integridad en 0). Esos valores se calcularon con una carga de prueba fuera de MySQL y **no están confirmados con los datos ampliados en MariaDB ni en MySQL 8**. `[COMPLETAR: correr las consultas en MariaDB o MySQL y anotar si coinciden]`

**Todavía NO ejecutado:**

- MySQL 8 de Oracle (el motor de la clase 006). MariaDB 10.11 es parecido pero no idéntico: collation por defecto, mensajes de error y algunas funciones cambian.
- SQL Server 2005 (ver `REVISION_ESTATICA_SQLSERVER.md`).
- Windows: la carga desde DBeaver o Workbench en una PC con Windows, y la conexión de la app (ver `GUIA_DRIVER_WINDOWS.md`).
- La app contra MySQL: no se probó que las pantallas funcionen sobre MySQL real.

Lo que sigue en las secciones 1 a 3 es **lectura del texto** (antes de que se ejecutara en MariaDB) y sigue valiendo para MySQL 8, que no se corrió. «Sin hallazgos» no es «corrió en MySQL 8».

## 1. Qué se revisó y qué dio

| Chequeo | Cómo | Resultado |
|---|---|---|
| Cantidad de tablas | Se contaron los `CREATE TABLE` | 47. En MariaDB 10.11 se confirmó con la consulta 16 |
| Columnas, nulabilidad, PK, UQ, FK, CHECK | Se comparó automáticamente con el script que había antes (ya no existe); hoy la referencia es `03_ModeloSQL_Grupo00.sql`, que además se contrastó con los diagramas (`INFORME_DIAGRAMAS.md`) | Sin diferencias en esa comparación |
| Datos de ejemplo | Comparación fila por fila de los `INSERT` de MySQL contra los de SQL Server (19/11/2026) | Sin diferencias (62 usuarios; salvo la expresión de fecha de las 28 reservas de sectores, que es la misma en cada motor) |
| Orden de creación | Cada `REFERENCES` apunta a una tabla creada antes | Sin hallazgos (confirmado al cargar en MariaDB) |
| Palabras reservadas de MySQL 8 | Se cruzaron nombres de tabla y columna contra la lista | Ninguna usada |
| `INSERT` con subconsulta sobre la misma tabla (error 1093) | Se buscó `FROM <tabla>` dentro de un `INSERT INTO <esa tabla>` | Sin hallazgos |
| Largo de claves únicas (utf8mb4: hasta 4 bytes por letra) | Se sumaron los largos de las `UNIQUE` | Muy por debajo del máximo de InnoDB |
| Comentarios y `;` | Ningún comentario ni texto tiene `;`; todos los `--` van seguidos de espacio | Sin hallazgos |
| `DELIMITER` dentro del script de la app | Se buscó | No hay (están en el otro archivo) |
| Índice `ux_reclamo_usuario_objeto` | Presente | Sin hallazgos |
| Orden de `DECLARE` en los procedimientos | Lectura | Variables antes del handler (si no, error 1337). Cargó en MariaDB |
| `GROUP BY` con `ONLY_FULL_GROUP_BY` | Lectura | Todas las columnas no agregadas están en el `GROUP BY`. Corrió en MariaDB con la regla activa |

## 2. Collation: qué pasa con mayúsculas y tildes

### 2.1 Qué hay hoy

Las tablas se crean con `DEFAULT CHARSET=utf8mb4` y **sin `COLLATE`**, así que cada una toma la collation por defecto del servidor para `utf8mb4`:

- **MySQL 8:** `utf8mb4_0900_ai_ci` → no distingue mayúsculas (`ci`) ni tildes (`ai`).
- **MariaDB 10.11:** 🔶 por lo que sé es `utf8mb4_general_ci` → tampoco distingue mayúsculas, y distingue poco las tildes (`general_ci` las trata como la letra sin tilde). Se ve en cualquier instalación con `SHOW VARIABLES LIKE 'collation_database';` y `SHOW TABLE STATUS;`. [COMPLETAR: collation que dio tu servidor]

### 2.2 Efecto en cada lugar

| Lugar | Con collation `ci`/`ai` (hoy en MySQL) | Con `utf8mb4_bin` |
|---|---|---|
| **Login** (`mainwindow.cpp`, `LOWER(usuario_nick) = :nick`) | La app ya pasa el nick a minúsculas al registrar y al entrar, y compara con `LOWER(...)`. Hoy los nicks quedan siempre en minúscula, así que la collation casi no cambia nada. Lo que sí cambia: en MySQL `jose` coincide con `josé`. | Distingue tildes: `jose` ≠ `josé`. Las mayúsculas dan lo mismo porque la app ya normaliza |
| **Contraseña** (`password_hash = :hash`) | El hash es SHA-256 en hexadecimal minúscula, sin tildes; la collation no puede producir un acceso falso. Sin riesgo real | Sin cambio práctico |
| **`UNIQUE` de nombres de catálogo** (`rol`, `estado_*`, `sector`, `software`…) | `Optica` y `Óptica` son el mismo valor: el segundo `INSERT` falla (error 1062). Es un efecto deseable en un catálogo | `Optica` y `Óptica` conviven: dos filas casi iguales |
| **`UNIQUE` de `usuario_nick`** | El nick ya llega en minúscula; el único choque nuevo es por tildes (`jose` / `josé`) | Permite los dos |
| **`UNIQUE` de `email`** | `Ana@mail.com` y `ana@mail.com` chocan: bien, el correo no distingue mayúsculas | Los toma por distintos: se podrían crear dos cuentas con «el mismo» mail |
| **`UNIQUE` de `dni`, `codigo_materia`** | `codigo_materia`: si lleva letras, `mat1` y `MAT1` chocan | Distintos |
| **Consultas de la app** con `= 'Texto'` sobre catálogos (por ejemplo `nombre_estado = 'Pendiente'`) | Encuentra aunque el texto cambie de mayúsculas | Hay que escribirlo exacto |
| **Defensa oral** | «MySQL por defecto no distingue mayúsculas ni tildes; es lo habitual y lo que conviene para nombres» | Hay que explicar por qué se eligió `_bin` |

### 2.3 Opciones

| Opción | Qué implica | A favor | En contra |
|---|---|---|---|
| **A. Dejarlo como está** (recomendada) | Collation por defecto del servidor | No se cambia ningún script ya probado en MariaDB. Es el comportamiento habitual de MySQL. El login ya está protegido por el `LOWER()` de la app | No distingue tildes (`jose` = `josé`): con los datos de ejemplo no se nota |
| B. `utf8mb4_bin` solo en `usuario.usuario_nick` | Una columna con `COLLATE utf8mb4_bin` | El login y el `UNIQUE` del nick distinguen tildes | Hay que modificar `03_ModeloSQL_Grupo00.sql` y volver a probarlo; solo cubre un campo; el resto sigue sin distinguir tildes |
| C. `utf8mb4_bin` en todas las columnas de texto | Collation binaria en todo | Todo el texto se compara exacto (mayúsculas y tildes) | Se pierde el beneficio en emails y catálogos; cambia muchas líneas; más riesgo |
| D. Collation explícita `utf8mb4_unicode_ci` en las tablas | Misma sensibilidad en todo el servidor, MySQL y MariaDB | Mismo comportamiento en MySQL 8 y MariaDB (la collation `0900` no existe en MariaDB y falla si se la pide: error 1273) | Hay que modificar el script; hoy no hace falta |

Ojo con una trampa: **si algún día se pone `COLLATE utf8mb4_0900_ai_ci` a mano en el script, deja de cargar en MariaDB** (error 1273 «Unknown collation»). Por eso el script no la nombra.

### 2.4 Recomendación

**Opción A: no tocar los scripts.** La app ya normaliza el nick a minúsculas (altas y login), así que el único efecto visible es el de las tildes, que con los datos reales de una escuela casi no aparece en nicks. Para la defensa conviene explicar la diferencia con una frase: «en MySQL las comparaciones de texto no distinguen mayúsculas ni tildes, por la collation; la app guarda el usuario en minúsculas». Si el profesor pide que el nick distinga tildes, la opción B es la mínima. No cambié ningún script en esta entrega.

## 3. Otras particularidades de MySQL (no son errores de sintaxis)

1. **Fechas con tipo propio.** En MySQL `fecha_reserva`, `fecha_registro`, `fecha_prestamo`, etc. son `DATE`, y `fecha_hora`, `fecha_hora_resolucion` son `DATETIME`. Con el driver `QMYSQL`, Qt devuelve un `QDate` o `QDateTime` y no un texto: si el código de la app hace `value(...).toString()` obtiene el formato ISO (`2026-11-10T10:00:00`, con una `T`) y no `yyyy-MM-dd HH:mm:ss`. **Para Arce Thiago y Cabrera Ulises al migrar:** revisar los lugares donde la app lee fechas y las compara o muestra como texto. Las horas (`hora_inicio`, `hora_fin`, `hora_prestamo`, `hora_devolucion`) son `VARCHAR(5)` a propósito (texto `HH:mm`), así que ahí no hay conversión de fecha. No se probó con la app.
2. **Los `CHECK` se aplican en MySQL 8.0.16 o más nuevo y en MariaDB desde la 10.2.1.** En versiones anteriores se aceptan pero se ignoran (año 1–7, precio > 0, etc.). Los mensajes cambian: MySQL da el error 3819, MariaDB el 4025. La app valida igual. (La versión anterior de este archivo decía que MariaDB los ignoraba: era un error mío, corregido.)
3. **UNIQUE con NULL (duda D3).** En `recursos_ct`, `UNIQUE(id_tipo_recurso, id_carro, numero_equipo)` no frena dos tableros con el mismo número, porque `id_carro` es NULL. SQL Server sí lo frena. Lo controla la app.
4. **`DEFAULT 1` en `producto_buffet.id_categoria_producto`.** Apunta a la categoría con id 1 (Comida). Funciona porque `categoria_producto` se carga antes que los productos y el primer id es 1 en una base nueva. Si se borra y recarga solo ese catálogo, el id 1 puede no existir.
5. **Reservas con fecha relativa.** Usan `DATE_ADD(CURDATE(), INTERVAL n DAY)`. Funciona en MySQL y MariaDB; el resultado depende del día en que se cargue el script.

## 4. Hallazgos menores en los archivos

| # | Archivo | Qué | Gravedad | Qué hacer |
|---|---|---|---|---|
| 1 | `05_Backend_Grupo00.sql` | **Obsoleto:** este hallazgo hablaba de `sp_recaudado_grupo`, que ya no existe (el 05 actual tiene 27 procedimientos). | — | Sin acción. |
| 2 | `05_Backend_Grupo00.sql` | Las validaciones de negocio (por ejemplo rango de fechas invertido) salen con `SIGNAL SQLSTATE '45000'`, que el mismo `EXIT HANDLER FOR SQLEXCEPTION` devuelve como fila `ERROR`. | Informativa | Se explica en la defensa como «validación de negocio». Leído en el código, no ejecutado por mí. |
| 3 | `05_Backend_Grupo00.sql` | El archivo usa `DELIMITER //`: solo funciona en clientes (Workbench, DBeaver con Alt+X), no se puede mandar con `mysql_query()` ni con Qt. | Informativa | Está documentado en la cabecera del archivo y en `GUIA_INSTALACION_MYSQL.md`. |
| 4 | `03_ModeloSQL_Grupo00.sql` | **Cambió:** ahora trae `CREATE DATABASE IF NOT EXISTS iqual` y `USE iqual;` sin comentar, y borra las tablas antes de crearlas (se puede repetir). | Informativa | Las guías ya lo dicen. El `DELIMITER` solo está en el 05. |
| 5 | `04_DatosSQL_Grupo00.sql` | **Obsoleto:** el marcador `-- DATOS DE EJEMPLO, REEMPLAZAR AL FINAL` ya no existe. | — | Para datos reales ver `COMO_COMPLETAR_DATOS_REALES.md`. |

No se encontraron errores de sintaxis y la carga en MariaDB 10.11 no dio errores. **Falta lo que esta revisión no puede dar: correrlos en MySQL 8.** Si al ejecutarlos aparece un error, copiá el mensaje completo (número y texto) y la línea que marca Workbench o DBeaver.

## Desvíos

- Ronda de cierre (19/11/2026): actualicé la sección 0 y los hallazgos 1, 2, 4 y 5, que hablaban de scripts y procedimientos de versiones anteriores; corregí los nombres de archivo. Las secciones 1 a 3 se dejaron como estaban (siguen valiendo).
- No cambié ningún script `03`, `04` ni `05`: no apareció ningún error real.
- Ronda del 19/11/2026: se sacó el motor local que la app usaba como respaldo (ya no existe en el proyecto). Las comparaciones contra su script y la carga de prueba que lo usaba no se repiten, y los valores esperados de las consultas siguen sin confirmar con los datos ampliados en MariaDB o MySQL (ver la sección 0).
- La ejecución en MariaDB 10.11 es un dato que me pasaron (CONTEXTO §22); no la repetí. En mi entorno no hay MySQL ni MariaDB.
- Los datos de collation de MariaDB (`utf8mb4_general_ci` por defecto) y de que `0900` no existe ahí son de mi conocimiento de la documentación, marcados 🔶; no los contrasté en esta sesión.
- La lista de palabras reservadas usada para el chequeo está escrita de memoria de la documentación de MySQL 8; se verifica con `SELECT * FROM information_schema.keywords WHERE reserved = 1;` (MySQL 8.0.13 o más nuevo).

## Datos que faltan

- [COMPLETAR: collation real del servidor que se use (`SHOW VARIABLES LIKE 'collation_database';`)]
- [COMPLETAR: resultado de cargar `03_ModeloSQL_Grupo00.sql`, `04_DatosSQL_Grupo00.sql` y `05_Backend_Grupo00.sql` en MySQL 8 de Oracle, si es el motor de la defensa]
- [COMPLETAR: si el profesor quiere que el login distinga tildes (en ese caso, opción B)]
