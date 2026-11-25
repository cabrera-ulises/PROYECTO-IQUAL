# GUIA_INSTALACION_MYSQL.md — Cargar la base de IQUAL en MySQL (paso a paso)

Para PROYECTO IQUAL (SGE). Pensada para que la puedas seguir sin ayuda y explicar qué hiciste en la defensa.

**Qué dice y qué no dice la clase 006.** La guía 006 de Linares (Ubuntu) enseña: instalar `libmysqlclient-dev`, verificar que el servidor MySQL esté corriendo, entrar desde **MySQL Workbench** (instancia local, puerto 3306, contraseña `12341234`), crear una base con `IF NOT EXISTS`, crear y ejecutar un *stored procedure* con `CALL` y `EXIT HANDLER FOR SQLEXCEPTION` + `GET DIAGNOSTICS`, entrar con **DBeaver-ce**, y conectar desde C con `mysql_init` / `mysql_real_connect` / `mysql_query`. **No dice nada de instalar MySQL en Windows** ni de cargar un script grande de 47 tablas: esas partes están armadas con pasos generales y están marcadas con 🔶 («no está en las guías»). Las pantallas pueden verse un poco distintas según la versión.

**Qué ya se ejecutó de verdad (CONTEXTO §22; dato que me pasaron, no lo corrí yo).** En un **MariaDB 10.11** (compatible con MySQL 8, pero no es MySQL 8): `03_ModeloSQL_Grupo00.sql` y `04_DatosSQL_Grupo00.sql` cargan sin errores (47 tablas, 62 usuarios), `05_Backend_Grupo00.sql` crea los 27 procedimientos y hay 104 casos planificados en `06_PruebasSQL.xlsx`. Los valores esperados de las consultas de `consultas_demo.sql` (10) y `consultas_verificacion_mysql.sql` con los 62 usuarios se calcularon con una carga de prueba fuera de MySQL el 19/11/2026: **no están confirmados en MariaDB ni en MySQL 8**, así que si alguna da otra cantidad de filas, avisá. **Sigue sin probarse:** MySQL 8 de Oracle, SQL Server 2005 y Windows. Si algo falla en tu instalación, copiá el mensaje de error completo (número y texto) y avisá.

Archivos que vas a usar, **siempre en este orden**: `03_ModeloSQL_Grupo00.sql` (crea las 47 tablas vacías), `04_DatosSQL_Grupo00.sql` (carga los datos de ejemplo: 62 usuarios y el resto), `05_Backend_Grupo00.sql` (27 procedimientos), `consultas_verificacion_mysql.sql` (para comprobar) y `consultas_demo.sql` (consultas de la defensa).

---

## 1. 🔶 Instalar MySQL Server en Windows

1. Entrá a la página oficial de descargas de MySQL (`dev.mysql.com/downloads/installer`) y bajá **MySQL Installer for Windows** (el instalador *web* alcanza, pide internet).
2. Ejecutalo y elegí el tipo de instalación **Custom** (o *Server only*). Lo único obligatorio es **MySQL Server 8.x**. **MySQL Workbench** conviene instalarlo también (es lo que se usa en clase).
3. En «Type and Networking» dejá lo que viene: puerto **3306**, tipo *Development Computer*.
4. En «Accounts and Roles» poné la contraseña de `root`: **`12341234`** (la misma de la clase 006).
5. En «Windows Service» dejá marcado *Start the MySQL Server at System Startup*. Terminá la instalación.
6. Para comprobar que anda: abrí **Servicios** de Windows (`services.msc`) y buscá `MySQL80` (o similar): tiene que decir *En ejecución*.

> Si ya tenés MariaDB o XAMPP usando el puerto 3306, uno de los dos no va a arrancar. Cerrá el otro o cambiá el puerto.

## 2. Conectarte y crear la base `iqual`

### En MySQL Workbench (clase 006, Paso 02)
1. Abrí Workbench y hacé doble clic en **Local instance 3306**.
2. Cuando pida la clave: `root` / **`12341234`**.
3. Abrí una pestaña de consulta (**File → New Query Tab**) y escribí:

```sql
CREATE DATABASE IF NOT EXISTS iqual CHARACTER SET utf8mb4;
USE iqual;
```

4. Ejecutá con el **rayo** (o `Ctrl+Enter` para una sola línea; `Ctrl+Shift+Enter` ejecuta todo). `IF NOT EXISTS` evita el error si la base ya existe (lo explica la diapositiva 7).
5. En el panel **Schemas** (a la izquierda), apretá el botón de refrescar y vas a ver `iqual`.

### En DBeaver-ce (clase 006, Parte 02 final)
1. **Database → New Database Connection → MySQL**.
2. Servidor `localhost`, puerto `3306`, usuario `root`, contraseña `12341234`. DBeaver puede pedir **descargar el driver de MySQL**: aceptá.
3. Apretá **Test Connection**; si dice *Connected*, terminá.
4. Clic derecho sobre la conexión → **SQL Editor → New SQL script**, y pegá:

```sql
CREATE DATABASE IF NOT EXISTS iqual CHARACTER SET utf8mb4;
USE iqual;
```

Ejecutalo con **Alt+X** (ejecuta todo el script).

## 3. Cargar `03_ModeloSQL_Grupo00.sql` y después `04_DatosSQL_Grupo00.sql`

Son **dos archivos y van uno detrás del otro** (03 y después 04; el 05 es el paso 5). El 03 ya trae `CREATE DATABASE IF NOT EXISTS iqual` y `USE iqual;`, así que el paso 2 es opcional: sirve para comprobar que la conexión anda. El 03 **borra las tablas y las crea de nuevo, vacías**; el 04 vacía las tablas y carga los datos. Los dos se pueden repetir.

### Workbench
1. **File → Open SQL Script…** y elegí `03_ModeloSQL_Grupo00.sql`.
2. Apretá el **rayo** (ejecuta *todo* el script, no una sola sentencia). Abajo, en *Output*, cada sentencia tiene que salir con ✔ verde.
3. Repetí 1 y 2 con `04_DatosSQL_Grupo00.sql` (es grande: tarda unos segundos; si el 04 se queda sin terminar, revisá la sección 6).

### DBeaver-ce
1. **File → Open File…** y elegí `03_ModeloSQL_Grupo00.sql` (o arrastralo).
2. Ejecutá con **Alt+X** (*Execute script*). Con `Ctrl+Enter` solo corre **una** sentencia: no sirve para cargar todo.
3. Repetí con `04_DatosSQL_Grupo00.sql`.

> **Para volver a cargar desde cero:** alcanza con volver a ejecutar el 03 y después el 04 (y el 05 si querés recrear los procedimientos). No hace falta `DROP DATABASE`.

## 4. Verificar que quedó bien

Corré estas consultas (están completas en `consultas_verificacion_mysql.sql`, consultas 14, 15 y 16):

```sql
USE iqual;
SELECT COUNT(*) AS tablas FROM information_schema.tables
WHERE table_schema = 'iqual' AND table_type = 'BASE TABLE';
```

**Tiene que dar 47.** También podés ejecutar `SHOW TABLES;` y contar.

Filas esperadas en los catálogos (con los datos de ejemplo cargados):

| Catálogo | Filas | Catálogo | Filas |
|---|---|---|---|
| `rol` | 4 | `estado_recurso` | 3 |
| `especialidad` | 3 | `carro` | 5 |
| `turno` | 2 | `deporte` | 4 |
| `dia_semana` | 5 | `tipo_log` | 14 |
| `categoria_objeto` | 6 | `resultado_log` | 2 |
| `estado_objeto` | 4 | `entidad_log` | 12 |
| `estado_reclamo` | 3 | `tipo_sector` | 2 |
| `tipo_reporte` | 2 | `anio` | 7 |
| `estado_reporte` | 2 | `division` | 9 |
| `estado_reserva` | 4 | `franja_horaria` | 5 |
| `estado_venta` | 3 | `categoria_producto` | 5 |
| `tipo_recurso` | 2 | `software` | 6 |

Los números de esta tabla coinciden con el script actual (se contaron los `INSERT` de cada catálogo). Si cargás los datos reales del colegio (ver `COMO_COMPLETAR_DATOS_REALES.md`, que explica el procedimiento), algunos cambian: por ejemplo `carro`, `deporte`, `franja_horaria` y `software` dependen de lo que cargues. `especialidad` queda en 3 (Computación, Óptica y Geografía-Matemática).

Dos comprobaciones rápidas más:

```sql
SELECT nombre_especialidad FROM especialidad;
SELECT COUNT(*) AS reservas_de_sectores FROM reserva_sector;
```

Las reservas de ejemplo de sectores se cargan con fechas **relativas al día de la carga** (hoy + 1, hoy + 2…); por eso no hay que correr fechas a mano, pero si cargás un día y consultás otro, las consultas 1A y 1B de verificación cambian de resultado.

## 5. Cargar los procedimientos con `DELIMITER` y llamarlos con `CALL`

`05_Backend_Grupo00.sql` define **27 procedimientos** (primero hay que cargar 03 y 04, porque el 05 empieza con `USE iqual;`). **Usan `DELIMITER //`**: por eso van en un archivo aparte y **no** dentro de 03 ni de 04 (esos se parten por `;`, y el `;` de adentro de un procedimiento los cortaría a la mitad). El archivo se puede ejecutar de nuevo: cada procedimiento se borra y se vuelve a crear.

- **15 de funcionalidades:** `sp_registrar_log`, `sp_registrar_usuario`, `sp_publicar_objeto`, `sp_reclamar_objeto`, `sp_resolver_reclamo`, `sp_prestar_equipo`, `sp_devolver_equipo`, `sp_reservar_sector`, `sp_resolver_reserva_sector`, `sp_reportar_higiene`, `sp_resolver_reporte_higiene`, `sp_comprar_producto`, `sp_donar_grupo`, `sp_inscribir_ed_fisica`, `sp_cancelar_inscripcion_ed_fisica`.
- **9 de reportes y auditoría:** `sp_rep_prestamos_por_carro`, `sp_rep_objetos_por_categoria_estado`, `sp_rep_higiene_por_sector`, `sp_rep_ocupacion_sectores`, `sp_rep_ventas_por_producto`, `sp_rep_recaudado_por_grupo`, `sp_rep_inscriptos_por_deporte`, `sp_rep_actividad_por_usuario` y `sp_rep_auditoria`.
- **2 tuneados:** `sp_rep_ventas_por_producto_tuneado` y `sp_rep_actividad_por_usuario_tuneado`.
- **1 auxiliar:** `sp_aux_solo_digitos`. (El archivo también crea y borra `sp_aux_crear_indices`, que solo sirve durante la carga.)

1. Abrí el archivo `05_Backend_Grupo00.sql` en Workbench (**File → Open SQL Script**) o DBeaver.
2. Ejecutalo **entero**: rayo en Workbench, **Alt+X** en DBeaver. (Si ejecutás una sola sentencia suelta, el `DELIMITER` no se interpreta bien: ver «Script cortado por el DELIMITER» en la sección 6.) También anda desde la consola: `mysql -u root -p --default-character-set=utf8mb4 < 05_Backend_Grupo00.sql`.
3. Comprobá que quedaron **27**: `SHOW PROCEDURE STATUS WHERE Db = 'iqual';`
4. Probá algunos con `CALL` (el archivo ya no trae llamadas de ejemplo al final). Los reportes reciben un rango de fechas:

```sql
CALL sp_rep_recaudado_por_grupo('2026-01-01', '2026-12-31');
CALL sp_rep_prestamos_por_carro('2026-01-01', '2026-12-31');
CALL sp_rep_auditoria('2026-01-01', '2026-12-31', NULL, NULL, NULL);
```

Cada procedimiento valida lo que recibe y devuelve una fila con `estado` (`OK` o `ERROR`) y, si falla, el código y el mensaje, en vez de cortar con un error rojo (el estilo de la clase 006: `EXIT HANDLER FOR SQLEXCEPTION` + `GET DIAGNOSTICS`). Las llamadas a los de funcionalidades (por ejemplo `sp_prestar_equipo`) **cambian datos y escriben en `log_auditoria`**: para volver al estado inicial, corré de nuevo el 04. Los casos de prueba con resultado esperado están en `06_PruebasSQL.xlsx`. [COMPLETAR: que alguien corra los `CALL` de arriba en su instalación y anote lo que devuelven; en esta revisión no se ejecutaron]

`log_auditoria` queda **vacía** después del 04 a propósito: la llenan los procedimientos a medida que se usan.

## 6. Errores comunes y qué significan

| Error | Qué significa | Qué hacer |
|---|---|---|
| **1045 Access denied for user 'root'@'localhost'** | Usuario o contraseña mal. | Usá `root` y la clave que pusiste al instalar (`12341234` en clase). Si no te acordás, hay que reinstalar o resetear la clave del servidor. |
| **2003 Can't connect to MySQL server** | El servidor no está corriendo o el puerto es otro. | Abrí `services.msc`, buscá `MySQL80` y apretá *Iniciar*. Revisá que el puerto sea 3306. |
| **1049 Unknown database 'iqual'** | La base no existe todavía (o está mal escrita). | Ejecutá el paso 2 (`CREATE DATABASE IF NOT EXISTS iqual ...`) y refrescá. |
| **1046 No database selected** | Se ejecutó una sentencia sin elegir base. | Escribí `USE iqual;` antes, o elegí la base como activa en la barra. |
| **1050 Table 'xxx' already exists** | Casi no debería aparecer: el 03 borra las tablas antes de crearlas. Aparece si se ejecutó solo una parte del 03. | Volvé a ejecutar el 03 entero (Alt+X) y después el 04. |
| **1146 Table 'iqual.xxx' doesn't exist** | La tabla no existe en la base activa (script cortado o base equivocada). | Revisá que las 47 tablas estén (paso 4). Si faltan, volvé a cargar desde cero. |
| **1064 You have an error in your SQL syntax** | Error de sintaxis en la sentencia. | Mirá la línea que marca el mensaje. Si ocurre en un procedimiento, casi siempre es que se ejecutó **sin el `DELIMITER`** (ver abajo). |
| **Script cortado por el `DELIMITER`** | Al pegar un `CREATE PROCEDURE` y correrlo con `Ctrl+Enter` (o desde otro cliente que no entiende `DELIMITER`), el `;` de adentro lo corta y da 1064 o *procedure ... incomplete*. | Ejecutá el **script completo** (rayo en Workbench, **Alt+X** en DBeaver). El comando `DELIMITER` es del cliente, no del servidor: sirve en Workbench y DBeaver, pero no en `mysql_query()` de C ni en una consulta de Qt. |
| **1305 PROCEDURE iqual.sp_xxx does not exist** | Se llamó con `CALL` antes de crearlo (o desde otra base). | Cargá el archivo de procedimientos (paso 5) con la base `iqual` activa. |
| **1337 / 1064 al crear un procedimiento** | Los `DECLARE` están en mal orden: en MySQL primero van las variables y *después* los handlers. | Los procedimientos de este proyecto ya están en el orden correcto; si modificás uno, respetalo. |
| **Entra con `ALUMNO1` igual que con `alumno1`** (no es un error) | MySQL no distingue mayúsculas ni tildes con la collation por defecto. | Es esperable. Ver el análisis en `REVISION_ESTATICA_MYSQL.md`. |
| **Caracteres raros (Ã³, �) en tildes y eñes** | La conexión o el archivo no están en `utf8mb4`. | Guardá el `.sql` como **UTF-8**, creá la base con `CHARACTER SET utf8mb4` (paso 2) y, si hace falta, ejecutá `SET NAMES utf8mb4;` al principio de la sesión. Las tablas ya se crean con `utf8mb4`. |
| **1451 / 1452 (clave foránea)** | Se borra o inserta una fila que otra tabla referencia (o que no existe). | Respetá el orden: primero catálogos, después lo que los usa. Si ocurre al cargar el script, lo más probable es que haya quedado cortado: recargá desde cero. |
| **3819 Check constraint is violated** (en MariaDB: 4025) | Un dato rompe un `CHECK` (año 1–7, precio > 0, hora_fin > hora_inicio…). | Corregí el dato. Nota: MySQL aplica los `CHECK` desde la 8.0.16 y MariaDB desde la 10.2.1; en versiones anteriores se aceptan pero se ignoran. |

## 7. Conectar la app

La app **ya se conecta a MySQL** (lee `iqual.ini`, junto al `.exe`; por defecto `localhost:3306`, usuario `root`, clave `12341234`, base `iqual`). **No crea las tablas**: tenés que cargar `03_ModeloSQL_Grupo00.sql` y después `04_DatosSQL_Grupo00.sql` vos, con el paso 3 de esta guía (el 05 no lo necesita la app: es para la defensa de Bases de Datos). Si MySQL falla (servidor apagado, clave mal, base vacía o falta el driver), la app **avisa el motivo y no abre** (no tiene base de respaldo: ver «Probar la conexión antes de la demo» en `GUIA_CONEXION_APP_MYSQL.md`). El título de la ventana dice con qué driver está conectada: **· MySQL** o **· MySQL (ODBC)**; sin sufijo es que no conectó.

- Cómo es `iqual.ini`, cómo saber qué motor se está usando y qué cambió en el código: `GUIA_CONEXION_APP_MYSQL.md`.
- Cómo conseguir el driver en Windows (Qt MinGW no trae `QMYSQL`; el camino recomendado es ODBC): `GUIA_DRIVER_WINDOWS.md`. **Ese paso no está probado en Windows.**

## 8. Lo que NO cubre esta guía

- La clase 006 muestra la conexión desde C/C++ con `mysql.h` en **Ubuntu** (`g++ ... -lmysqlclient`). En Windows eso no se probó. En Ubuntu, para Qt: `sudo apt install libqt6sql6-mysql libmysqlclient-dev` (probado en Linux, ver `GUIA_CONEXION_APP_MYSQL.md`).
- No se explica instalar MySQL en Ubuntu ni en otro sistema: ver las diapositivas 3 a 5 de la clase 006.
- Confirmar con Linares que el motor del proyecto es MySQL está pendiente (decisión tuya).
- MySQL 8 de Oracle y Windows: sin probar. Si algo de esta guía no coincide con tu pantalla, avisá.

## Desvíos
- Ronda de cierre (19/11/2026): se corrigió el nombre de archivo que había quedado pegado («03… y 04…» como si fuera un solo archivo), el orden de carga 03 → 04 → 05, la sección 5 (ahora son 27 procedimientos con sus nombres reales; el archivo ya no trae `sp_prueba_error` ni llamadas de ejemplo al final), las cifras de usuarios (62) y el error 1050.
- Que los `CALL` de la sección 5 devuelvan lo esperado no lo verifiqué: no hay MySQL ni MariaDB en mi entorno.
- Los pasos de DBeaver y Workbench se mantienen como en la clase 006; no se pudieron probar con pantallas reales.
- Las filas esperadas de los catálogos se contaron el 19/11/2026 contra `04_DatosSQL_Grupo00.sql` con una carga de prueba fuera de MySQL y coinciden con el script; en MariaDB o MySQL falta confirmarlas.

## Datos que faltan
- `[COMPLETAR: versión de MySQL Server que instalaste (8.0.x) y si la carga del script dio 47 tablas]`
