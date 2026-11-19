# GUIA_CONEXION_APP_MYSQL.md — Usar la app IQUAL con MySQL (DBeaver)

La app se conecta a MySQL. Si no puede, avisa el motivo y sigue con la base local `iqual.db` (SQLite), así que nunca queda sin funcionar. El título de la ventana termina en **· MySQL** (o **· MySQL (ODBC)**) cuando está usando MySQL.

## Qué se probó y qué no
- **Probado (Linux, Qt 6.4, MariaDB 10.11):** los scripts `03_ModeloSQL_Grupo00.sql` (47 tablas), `04_DatosSQL_Grupo00.sql` (62 usuarios) y `05_Backend_Grupo00.sql` (27 procedimientos) se cargan sin errores, en ese orden (CONTEXTO §22; dato que me pasaron); las consultas de la defensa y las de verificación corrieron sin errores en la ronda anterior y el 19/11/2026 se comprobaron sus resultados esperados sobre una copia SQLite con los datos nuevos; las 131 consultas que tiene el código de la app se validaron con la regla `ONLY_FULL_GROUP_BY` de MySQL 8; los tests automáticos de la app (Objetos, Tienda, Ed. Física, Higiene, Sectores, Préstamo, Mi cuenta, login) dan 0 fallas con el driver `QMYSQL`.
- **No probado:** MySQL 8 de Oracle, SQL Server, Windows, ni el camino ODBC con *MySQL Connector/ODBC* (con el conector ODBC de MariaDB la app detecta un problema de textos y vuelve sola a SQLite). 🔶

## 1. Cargar la base (DBeaver)
Seguí `GUIA_INSTALACION_MYSQL.md`, paso 3: ejecutar `03_ModeloSQL_Grupo00.sql` y después `04_DatosSQL_Grupo00.sql`, cada uno con **Alt+X** (el 03 ya crea la base `iqual`). El `05_Backend_Grupo00.sql` **no hace falta para la app**: es de la defensa de Bases de Datos. Comprobá que da **47** tablas.

## 2. Archivo `iqual.ini`
Se crea solo, junto al programa, la primera vez que se abre la app:

```
[base]
motor=mysql
driver=auto
host=localhost
puerto=3306
usuario=root
clave=12341234
nombre=iqual
```
- `motor=sqlite` fuerza la base local.
- `driver=auto` usa `QMYSQL` si Qt lo tiene y, si no, ODBC. También se puede poner `qmysql` o `odbc`.
- `odbc_driver=` (opcional) es el nombre del driver ODBC instalado, por ejemplo `MySQL ODBC 8.0 Unicode Driver`. Si no lo ponés, en Windows la app busca solo entre los drivers instalados uno de MySQL.

## 3. El driver en Windows (la parte difícil) 🔶
Qt para Windows (MinGW) **no trae `QMYSQL`**, pero **sí trae `QODBC`**. Hay dos caminos:

**Camino A — ODBC (no hay que compilar nada, probar primero).**
1. Instalá **MySQL Connector/ODBC** (de dev.mysql.com/downloads/connector/odbc, versión de 64 bits, la que se llama *Unicode*).
2. Dejá `driver=auto` en `iqual.ini`. Abrí la app: el título tiene que decir **· MySQL (ODBC)**.
3. Si aparece el aviso «El driver ODBC no compara bien los textos» o «no se pudo usar MySQL», la app sigue con SQLite; probá el camino B o avisá el mensaje completo.

**Camino B — compilar el plugin `QMYSQL`.**
1. Instalá MySQL Server 8 (trae `libmysql.dll` y la carpeta `include`).
2. En el Maintenance Tool de Qt instalá el componente **Sources** de tu versión de Qt.
3. Compilá `Src/qtbase/src/plugins/sqldrivers` con CMake indicando `-DMySQL_INCLUDE_DIR=` y `-DMySQL_LIBRARY=` (y `-DCMAKE_PREFIX_PATH=` con tu Qt). Con MinGW puede hacer falta generar una librería de importación desde `libmysql.dll`.
4. Copiá `qsqlmysql.dll` a `<Qt>\plugins\sqldrivers\` y `libmysql.dll` junto al `.exe`.

**Ubuntu (como en la clase 006), probado:** `sudo apt install libqt6sql6-mysql libmysqlclient-dev`.

**Plan de emergencia para la defensa:** poné `motor=sqlite` y mostrá MySQL aparte desde DBeaver (las dos bases tienen los mismos datos y las mismas 47 tablas).

## 4. Cómo saber qué motor está usando
El título de la ventana: «· MySQL», «· MySQL (ODBC)», o sin sufijo si está en SQLite. Si volvió a SQLite sin que lo pidas, apareció antes un aviso con el motivo (servidor apagado, clave mal, base vacía, falta driver).

## 5. Qué cambió en el código
- `abrirBase()` lee `iqual.ini`; `abrirMySql()` elige `QMYSQL` u ODBC; `abrirSqlite()` es la de antes.
- Las fechas se mandan a MySQL como fecha real (`QDate`/`QDateTime`) y a SQLite como texto; el id recién insertado se pide con `ultimoId()`.
- `formatoCorto()` acepta las fechas de MySQL (`2026-10-23T10:00:00`) y las de SQLite.
- MySQL no distingue mayúsculas ni tildes: el usuario `ALUMNO1` entra igual que `alumno1`.
