# Guía: la app conectada con `mysql.h` (como en la clase 006)

Rama de GitHub: **`app-mysql-h-clase-006`**. La rama `main` queda como estaba (Qt Sql con `QMYSQL` u ODBC). Con esta guía se decide con cuál quedarse.

## 1. Qué cambió

La app ya no usa `QSqlDatabase` ni `QSqlQuery`, ni el plugin `QMYSQL`, ni ODBC. Habla con MySQL usando la librería de C que se vio en la clase 006 (`mysql.h`):

| Clase 006 (ejemplos `ejemplobd01` a `04`) | App IQUAL en esta rama |
|---|---|
| `MYSQL *conn = mysql_init(NULL);` | `abrirMySql()`: `conn = mysql_init(NULL);` |
| `mysql_real_connect(conn, "127.0.0.1", "root", "12341234", "CuartoAnio_2026", 3306, NULL, 0)` | Lo mismo, con los datos de `iqual.ini` (host, usuario, clave, base `iqual`, puerto) |
| `hacer_select(conn)`: `mysql_query` + `mysql_store_result` | `hacerSelect(sql)`: `mysql_query` + `mysql_store_result` |
| `while ((fila = mysql_fetch_row(result)))` y `fila[0]`, `fila[1]` | Igual en cada listado: `while ((fila = mysql_fetch_row(result)) != NULL)` |
| `mysql_free_result(result)` | Igual, después de cada listado |
| `insertar_alumno`: `if (mysql_query(conn, sql.c_str()) == 0)` | `ejecutar(sql)`: devuelve `true` si `mysql_query` dio 0 |
| `mysql_insert_id(conn)` | `ultimoId()`: `mysql_insert_id(conn)` |
| `CALL sp_obtener_alumnos_Fecha('1973-01-01', '1980-01-01')` | `CALL sp_registrar_log('Inicio de sesión', ..., 'Exitoso', ...)` |
| `mysql_error(conn)` | Se muestra si no se puede conectar |
| `mysql_close(conn)` | En el destructor de `MainWindow` |

Hay dos cosas que la clase no muestra y que hacen falta en una app real:

1. **Las comillas.** La diapositiva del INSERT avisa: «Hay que tener en cuenta las comillas». Si alguien escribe `O'Brien` y el texto se pega tal cual en el SQL, la consulta se rompe, y alguien podría meter SQL propio (inyección). Por eso cada texto pasa por `texto(valor)`, que usa `mysql_real_escape_string` (función de la misma librería) y le agrega las comillas simples. Los números se pegan con `QString::number`.
2. **Resultados de un `CALL`.** Un `CALL` deja más de un resultado en la conexión. Si no se leen todos, la consulta siguiente falla con «Commands out of sync». `hacerSelect` y `ejecutar` los recorren con `mysql_next_result` y los liberan. En los ejemplos de la clase no pasa porque el programa termina después del `CALL`.

Archivos que cambiaron: `mainwindow.cpp`, `mainwindow.h` y `CMakeLists.txt`. Los scripts SQL, los schemas y los procedimientos son los mismos que en `main`.

## 2. Qué se probó y qué no

Probado el 25/11/2026 en Linux (Ubuntu 24.04, `libmysqlclient` 8.0.46, servidor MariaDB 10.11):

- **Misma prueba en las dos versiones.** Se corrió una prueba automática que recorre la app con los 5 roles (registro, login, objetos, reclamos, consultas, higiene, sectores, préstamos, tienda, grupos, donaciones, Educación Física, cuenta y auditoría: 40 pasos), primero con `main` y después con esta rama. Se compararon todos los mensajes, todas las listas, etiquetas y combos de cada pantalla (14.027 líneas) y la base completa al final.
  - Mensajes y base de datos: **idénticos**.
  - Única diferencia en pantalla: tres reservas con el mismo día y la misma hora salen en otro orden. Las dos versiones las ordenan por fecha y hora, y entre empates MySQL no garantiza un orden, así que las dos son correctas.
- **Comillas y barras:** un nombre `O'Brien` y una consulta con `'`, `"` y `\` se guardan y se muestran bien.
- **Inyección SQL:** entrar con usuario `' OR '1'='1` o `preceptor1' -- ` da «Usuario o contraseña incorrectos».
- **Errores de conexión:** con clave mal muestra «Access denied…»; con el servidor apagado, «Can't connect to MySQL server…»; sin los schemas, «Los schemas de IQUAL no existen…». En los tres casos la app avisa y no abre.
- **Memoria:** valgrind sobre la prueba completa da 0 errores y 0 bytes perdidos (todos los resultados se liberan con `mysql_free_result`).
- **No probado:** Windows con Qt MinGW, porque desde acá no hay Windows. Es lo primero que hay que probar (sección 4). Si algo falla, `main` sigue funcionando como siempre.

## 3. Cómo bajar la rama

Con GitHub Desktop: **Current branch** → elegir `app-mysql-h-clase-006`.

Con la consola, dentro de la carpeta del proyecto:

```
git fetch
git checkout app-mysql-h-clase-006
```

Para volver a la versión de siempre: `git checkout main`.

## 4. Qué hacer en Windows (Qt Creator, kit MinGW 64-bit)

### 4.1 Lo que tiene que estar instalado

Hace falta **MySQL Server** instalado (el mismo que usan con Workbench). Trae lo que necesita `mysql.h`:

- `C:\Program Files\MySQL\MySQL Server 8.x\include\mysql.h`
- `C:\Program Files\MySQL\MySQL Server 8.x\lib\libmysql.lib`
- `C:\Program Files\MySQL\MySQL Server 8.x\lib\libmysql.dll`

Fijate en el Explorador que estén esos tres archivos (la `x` cambia según la versión: 8.0, 8.4…).

**Si no están** (por ejemplo, porque instalaste solo Workbench o el servidor está en otra PC):

1. Entrá a https://dev.mysql.com/downloads/mysql/ y bajá **Windows (x86, 64-bit), ZIP Archive** (no hace falta registrarse: «No thanks, just start my download»).
2. Descomprimilo, por ejemplo, en `C:\mysql`. Adentro tienen que quedar `include\mysql.h` y `lib\libmysql.lib`.
3. En el paso 4.2 vas a tener que indicar esa carpeta en `MYSQL_DIR`.

**No hace falta** el plugin `QMYSQL` ni MySQL Connector/ODBC.

### 4.2 Compilar

1. Abrí `CMakeLists.txt` en Qt Creator con el kit **Desktop Qt 6.12.0 MinGW 64-bit**.
2. En **General Messages** (o en la salida de CMake) tiene que aparecer `MySQL para mysql.h: C:/Program Files/MySQL/MySQL Server 8.x`. CMake busca la carpeta solo.
3. Si MySQL está en otra carpeta (o usás el ZIP): **Projects** → **Build** → **CMake** → **Add** → **Directory**, nombre `MYSQL_DIR`, valor la carpeta (por ejemplo `C:/mysql`). Apretá **Apply Configuration Changes** (o **Run CMake**).
4. Compilá (martillo). Al terminar, CMake copia `libmysql.dll` (y las `libssl`/`libcrypto` de OpenSSL si están en `bin`) al lado del `.exe`.
5. `iqual.ini` es el mismo de siempre. Las claves `driver` y `odbc_driver` ya no se usan (si están, no molestan).
6. Ejecutá. El título de la ventana termina en «· MySQL».

### 4.3 Si algo falla

| Qué pasa | Qué hacer |
|---|---|
| `mysql.h: No such file or directory` | CMake no encontró la carpeta: cargá `MYSQL_DIR` (paso 4.2.3) y volvé a correr CMake. |
| Error de enlace `undefined reference to mysql_init` (u otra `mysql_…`) | En `CMakeLists.txt` cambiá `"${MYSQL_DIR}/lib/libmysql.lib"` por `"${MYSQL_DIR}/lib/libmysql.dll"` (MinGW puede enlazar directo contra la DLL) y recompilá. |
| Al abrir: «no se encontró libmysql.dll» o el programa se cierra solo | Copiá a mano `libmysql.dll` (de `lib`) y, si están, `libssl-3-x64.dll` y `libcrypto-3-x64.dll` (de `bin`) a la carpeta del `.exe`. |
| «Access denied for user 'root'» | La clave de `iqual.ini` no es la del servidor. |
| «Can't connect to MySQL server» | El servidor está apagado (Servicios de Windows → `MySQL80` → Iniciar) o el puerto no es 3306. |
| «Los schemas de IQUAL no existen» | Cargá `03`, `04` y `05` desde Workbench o DBeaver. |
| Tildes raras (`Ã©`) | No debería pasar: la conexión pide `utf8mb4`. Si pasa, avisá. |

Si no sale andando, `git checkout main` y la app vuelve a ser la de siempre.

## 5. En Linux (igual que en la clase)

```
sudo apt install libmysqlclient-dev
```

Después se abre `CMakeLists.txt` en Qt Creator y se compila. `CMakeLists.txt` ya agrega `-I/usr/include/mysql` y `-lmysqlclient` (lo mismo que `g++ ... -lmysqlclient` de la clase).

## 6. Con cuál quedarse

| | `main` (Qt Sql) | `app-mysql-h-clase-006` |
|---|---|---|
| Parecido al código de la clase 006 | Hace lo mismo con clases de Qt | Mismas funciones que la clase |
| Qué hay que instalar en Windows | MySQL Connector/ODBC (o compilar `QMYSQL`) | Solo MySQL Server (trae `mysql.h` y `libmysql`) |
| Probada en Windows | Sí (casos por pantalla, 337) | No todavía |
| Probada en Linux | Sí | Sí, con resultados iguales a `main` |
| Protección contra comillas e inyección | `prepare` + `bindValue` | `mysql_real_escape_string` en cada texto |

Si en tu PC compila y abre, conviene esta rama para la defensa de BBDD, porque es literalmente lo que se vio en clase. Si no compila, quedate con `main`.
