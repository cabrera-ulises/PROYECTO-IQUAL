# GUIA_DRIVER_WINDOWS.md — Que la app de IQUAL hable con MySQL en Windows

Para PROYECTO IQUAL. Complementa a `GUIA_CONEXION_APP_MYSQL.md` §3 (los dos caminos) y a `GUIA_INSTALACION_MYSQL.md` (instalar el servidor y cargar la base).

**Cómo leer esta guía.** Cada paso dice de dónde sale. Lo marcado con 🔶 **no se pudo comprobar** (no hay Windows acá, y la documentación oficial no lo dice): son pasos generales o del uso habitual; si algo no coincide con tu pantalla, avisá el mensaje exacto. **Ninguno de los dos caminos fue probado en Windows.** Sí se probó en Linux con MariaDB y el driver `QMYSQL` (ver `CONTEXTO` §19.1).

Fuentes (consultadas el 11/11/2026):
- Qt, «SQL Database Drivers»: <https://doc.qt.io/qt-6/sql-driver.html>
- MySQL, «Installing Connector/ODBC from a Zipped DLL Package» (Windows): <https://dev.mysql.com/doc/connectors/en/connector-odbc-installation-binary-windows-dll.html>
- MySQL, «Connector/ODBC DSN on Windows»: <https://dev.mysql.com/doc/connectors/en/connector-odbc-configuration-dsn-windows.html>

---

## 0. Qué hace la app (leído de `mainwindow.cpp`, funciones `abrirBase`, `abrirMySql`, `nombreDriverOdbc`)

1. Lee `iqual.ini` junto al `.exe` (si no existe, lo crea con `host=localhost`, `puerto=3306`, `usuario=root`, `clave=12341234`, `nombre=iqual`).
2. Con `driver=auto` (el valor por defecto): si Qt tiene el driver `QMYSQL`, lo usa; si no, usa `QODBC`. Con `driver=qmysql` o `driver=odbc` fuerza uno.
3. Si el driver elegido no existe, muestra un aviso. La app **no tiene otra base de respaldo**: si no conecta, deja la pantalla deshabilitada (ver «Probar la conexión antes de la demo», al final).
4. Con ODBC arma la conexión como `DRIVER={<nombre del driver>};SERVER=…;PORT=…;DATABASE=…`. El nombre sale de `odbc_driver=` en `iqual.ini`; si está vacío, en Windows lo busca en el registro (`HKLM\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers`), prefiriendo uno que diga «MySQL» y «Unicode»; si no encuentra ninguno usa `MySQL ODBC 8.0 Unicode Driver`.
5. Después de conectar hace `SET NAMES utf8mb4`, comprueba que exista la tabla `usuario` y, solo con ODBC, hace una consulta de prueba (`rol` con `nombre_rol = 'Alumno'`): si da 0 filas, cierra la conexión y muestra el aviso del driver ODBC.
6. El título de la ventana lo dice: **· MySQL** = `QMYSQL`, **· MySQL (ODBC)** = ODBC. Sin sufijo significa que no conectó.

Qué dice Qt (fuente 1): en Windows ya hay un *driver manager* ODBC instalado; el plugin `QODBC` usa la API Unicode por defecto en Windows; el driver y la base también tienen que soportar Unicode.

---

## Camino A — ODBC (probar primero; no se compila nada)

### A1. Instalar *MySQL Connector/ODBC*
1. Entrá a la página de descargas de Connector/ODBC en `dev.mysql.com/downloads/connector/odbc` 🔶 (la página de descargas no se consultó; las versiones cambian).
2. Bajá la versión de **64 bits**, porque tu Qt es **MinGW 64-bit**. Un programa de 64 bits solo ve drivers ODBC de 64 bits 🔶 (regla general de Windows; no está en la fuente).
3. Dos formas de instalarlo:
   - **Instalador MSI** (el habitual). Los pasos del MSI no están en las fuentes consultadas 🔶: es el asistente «Siguiente… Instalar».
   - **Paquete ZIP** (documentado por MySQL, fuente 2): descomprimí en una carpeta (el ejemplo oficial usa `C:\Program Files\MySQL\Connector ODBC <versión>\`), abrí una consola **como administrador**, andá a esa carpeta y ejecutá `Install.bat`. Según la documentación, registra el driver ODBC en versión ANSI y Unicode.
4. Si al abrir la app aparece un error de bibliotecas faltantes, puede faltar el *Visual C++ Redistributable* 🔶 (la fuente 2 no habla de eso; Qt sí lo menciona para `libmysql.dll`, ver Camino B).

### A2. Verificar el nombre exacto del driver instalado
El nombre incluye la versión (por ejemplo `MySQL ODBC <versión> Unicode Driver`), así que **no lo adivines**:

- **Con `odbcad32.exe`:** `Win + R` → `odbcad32` → pestaña **Controladores** (*Drivers*). Tiene que aparecer un driver «MySQL ODBC … Unicode Driver». Ese es el nombre. 🔶 (Que la pestaña lista los drivers instalados es conocimiento general de Windows; la página de MySQL consultada solo nombra la herramienta.) Si no aparece, está instalado en la otra arquitectura (32 bits) o no se instaló.
- **Con la consola** (documentado por MySQL, fuente 2): `cd "<carpeta de instalación>\bin"` y `myodbc-installer -d -l`. Tiene que listar el driver «MySQL ODBC … Unicode Driver» (y el ANSI).

### A3. Qué poner en `iqual.ini`
Normalmente **nada**: con `driver=auto` y sin `QMYSQL`, la app usa ODBC y busca sola el driver. Si no lo encuentra o hay más de uno, escribí el nombre exacto de A2:

```
[base]
driver=odbc
odbc_driver=MySQL ODBC 8.0 Unicode Driver
host=localhost
puerto=3306
usuario=root
clave=12341234
nombre=iqual
```
(Reemplazá el valor de `odbc_driver` por el que viste en A2; el de arriba es solo el ejemplo que la app usa por defecto.)

### A4. Qué avisos puede mostrar la app y qué significan

| Aviso (empieza con «No se pudo usar MySQL:») | Qué significa | Qué hacer |
|---|---|---|
| Qt no tiene ni el driver QMYSQL ni el QODBC | El Qt del kit no trae los plugins de SQL | Reinstalar o revisar el kit; es raro con el Qt oficial, que trae `QODBC` |
| Falta el driver QMYSQL de Qt | Pusiste `driver=qmysql` y ese plugin no está | Usar `driver=auto` u `odbc`, o hacer el Camino B |
| Texto del driver con «Data source name not found and no default driver specified» (o parecido) | El nombre en `DRIVER={…}` no coincide con ningún driver instalado | Repetir A2 y copiar el nombre exacto en `odbc_driver=` |
| «Can't connect to MySQL server» / «Access denied for user» | Servidor apagado, puerto distinto o clave mal | Ver `GUIA_INSTALACION_MYSQL.md` §6 (errores 2003 y 1045) |
| «La base iqual existe pero está vacía. Cargá 03_ModeloSQL_Grupo06.sql y 04_DatosSQL_Grupo06.sql desde DBeaver.» | Se conectó, pero no hay tablas | Cargar `03_ModeloSQL_Grupo06.sql` y después `04_DatosSQL_Grupo06.sql` (`GUIA_INSTALACION_MYSQL.md` §3) |
| «El driver ODBC no compara bien los textos (le pasa al MariaDB Connector/ODBC)…» | El autochequeo falló: las búsquedas por nombre devuelven 0 filas | Instalar **MySQL Connector/ODBC** (no el de MariaDB) o usar `QMYSQL`. La app no abre la base: corregí el driver y volvé a abrirla |

Hallazgo previo (CONTEXTO §19 y prompt): con el conector ODBC **de MariaDB**, Qt manda los textos con un carácter nulo de más y por eso las comparaciones por nombre dan 0 filas. Con MySQL Connector/ODBC **no está probado**: el autochequeo existe justamente para detectarlo.

Después de A1 a A3 abrí la app: el título tiene que decir **· MySQL (ODBC)**. Si dice solo «PROYECTO IQUAL» sin sufijo, no conectó y hubo avisos al arrancar: leelos (ver abajo qué dice cada uno).

---

## Camino B — compilar el plugin `QMYSQL` para Qt MinGW

Solo si el A falla. Es lo más delicado. Los pasos y comandos vienen de la documentación de Qt (fuente 1); lo que cambia por usar **MinGW** no está documentado y va marcado 🔶.

### B1. Conseguir `libmysql` y `mysql.h`
Qt pide, en Windows, los archivos `libmysql.lib`, `libmysql.dll` y `include/mysql.h` (o los de MariaDB: `libmariadb.lib`, `libmariadb.dll`, `include/mysql.h`), **de la misma arquitectura que tu Qt (x64)**. Desde MySQL 8.0.19 el *C Connector* ya no se ofrece como componente suelto: hay que sacarlos del **MySQL Server completo** (solo x64) o usar el *MariaDB C Connector* (fuente 1). Si instalaste MySQL Server 8 con el instalador, buscalos en la carpeta de instalación (por ejemplo `C:\Program Files\MySQL\MySQL Server 8.0\`, carpetas `lib` e `include`) 🔶 (la ruta exacta depende de tu instalación).

### B2. Tener las fuentes de Qt
En el *Maintenance Tool* de Qt marcá el componente **Sources** de tu misma versión de Qt. Quedan en `<carpeta de Qt>\Src\` (fuente 1 usa `<qt_installation_path>\Src\qtbase\src\plugins\sqldrivers`). 🔶 El nombre del componente en el Maintenance Tool puede variar.

### B3. Compilar el plugin
Desde una consola donde estén `qt-cmake`, `cmake`, el compilador MinGW y Ninja 🔶 (la «Qt 6.x for MinGW» del menú Inicio, o las `Tools` de Qt, suelen tenerlos). El comando de la documentación (fuente 1), adaptado:

```
mkdir build-sqldrivers
cd build-sqldrivers
qt-cmake -G Ninja <qt>\Src\qtbase\src\plugins\sqldrivers -DCMAKE_INSTALL_PREFIX=<qt>\<kit> -DMySQL_INCLUDE_DIR="<mysql>\include" -DMySQL_LIBRARY="<mysql>\lib\libmysql.lib"
cmake --build .
cmake --install .
```
- `<qt>` es tu carpeta de Qt (por ejemplo la que tiene `6.12.0`) y `<kit>` el kit MinGW (por ejemplo `6.12.0\mingw_64`) 🔶.
- La documentación de Qt también acepta `-DMySQL_ROOT="<carpeta de MySQL>"` en lugar de las dos opciones explícitas.
- `-DCMAKE_INSTALL_PREFIX` hay que ponerlo para que `cmake --install .` copie el plugin; la documentación no dice la subcarpeta, pero el plugin tiene que terminar en `<kit>\plugins\sqldrivers\` 🔶.
- 🔶 **Problema probable con MinGW:** la documentación de Qt habla de `libmysql.lib`, que es una biblioteca de importación de Visual C++. MinGW suele necesitar una librería de importación propia (`.a`) generada desde `libmysql.dll`, con `gendef` y `dlltool`. **Eso no está en la documentación de Qt ni se probó acá**: si CMake o el enlazador protestan por `libmysql.lib`, ese es el primer sospechoso.

### B4. Copiar los `.dll`
- El plugin compilado (`qsqlmysql.dll`) tiene que quedar en `<kit>\plugins\sqldrivers\` 🔶 (si `cmake --install` no lo copió ahí, copialo a mano).
- `libmysql.dll` (o `libmariadb.dll`) **en la misma carpeta que el `.exe`** de la app (lo dice la fuente 1). La fuente 1 agrega que `libmysql.dll` necesita las bibliotecas de ejecución de MSVC, que se instalan con `vcredist.exe`.
- Para verificar: cerrá y abrí Qt Creator, y poné `driver=qmysql` en `iqual.ini`. El título tiene que decir **· MySQL**.

### B5. Si no anda
- Aviso «Falta el driver QMYSQL de Qt»: el plugin no está en `plugins\sqldrivers` o no coincide la versión de Qt con la que se compiló.
- La app abre pero el plugin no carga: falta `libmysql.dll` junto al `.exe` o faltan las bibliotecas de MSVC.
- Lo más sano si se complica: volver al Camino A.

---

## Probar la conexión antes de la demo
La app **no tiene base de respaldo**: si no conecta a MySQL, no se puede usar. Por eso hay que probarla en la compu donde se va a presentar, de preferencia la víspera y otra vez un rato antes.

1. **Servidor encendido.** Conectate con DBeaver o Workbench con los mismos datos que `iqual.ini` (por defecto `localhost`, puerto `3306`, usuario `root`, base `iqual`).
2. **Base cargada.** Corré `SELECT COUNT(*) FROM information_schema.tables WHERE table_schema IN ('seguridad','academico','objetos','instalaciones','tienda','equipos','deportes');` y comprobá que dé **47** (si da 0, falta cargar `03_ModeloSQL_Grupo06.sql` y `04_DatosSQL_Grupo06.sql`).
3. **`iqual.ini`.** Está junto al `.exe`; `host`, `puerto`, `usuario`, `clave` y `nombre` tienen que ser los del paso 1.
4. **Abrir la app.** El título de la ventana tiene que terminar en **· MySQL** o **· MySQL (ODBC)**. Entrá con una cuenta de demostración (por ejemplo `alumno1`, clave `1234`, CONTEXTO §8).
5. **Si no conecta, qué muestra la app.** Dos cuadros «Atención», uno atrás del otro, y después la ventana con todo deshabilitado y el título sin sufijo:
   - El primero: «No se pudo usar MySQL:» + el texto del error + «Revisá iqual.ini y que el servidor esté encendido.»
   - El segundo: «No se pudo abrir la base de datos. Revisá iqual.ini y que el servidor MySQL esté encendido.»
   - El texto del medio es el que dice qué pasó: ver la tabla de la sección A4 (driver que falta, servidor apagado o clave mal, base vacía, driver ODBC que no compara bien los textos).
6. **Si falla en plena demo.** No hay otra base a la que cambiar. Lo que sí se puede seguir mostrando es la base y los procedimientos desde DBeaver o Workbench (`consultas_demo.sql` y `05_Backend_Grupo06.sql`). `[COMPLETAR: si el equipo prefiere llevar capturas de la app funcionando como respaldo]`

## Desvíos
- No se probó ningún paso en Windows. Todo lo marcado 🔶 es general o está sin confirmar.
- La página de descargas de Connector/ODBC y la página del instalador MSI no se pudieron consultar (la segunda quedó fuera de las páginas permitidas); por eso no se indican versiones concretas ni los pasos del asistente MSI.
- Los nombres de driver y de carpeta de este documento son **ejemplos**; el nombre real de tu driver se ve en A2.

## Datos que faltan
- `[COMPLETAR: nombre exacto del driver ODBC que aparece en tu odbcad32 (A2)]`
- `[COMPLETAR: si el Camino A anduvo o con qué aviso falló]`
