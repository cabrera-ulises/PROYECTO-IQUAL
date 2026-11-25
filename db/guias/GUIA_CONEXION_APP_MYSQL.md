# GUIA_CONEXION_APP_MYSQL.md — Usar la app IQUAL con MySQL (DBeaver)

La app usa solo MySQL. Si no puede conectar, avisa el motivo y deja la pantalla deshabilitada: no tiene base de respaldo. El título de la ventana termina en **· MySQL** (o **· MySQL (ODBC)**) cuando está conectada.

## Qué se probó y qué no
- **Probado (Linux, Qt 6.4, MariaDB 10.11):** los scripts `03_ModeloSQL_Grupo06.sql` (47 tablas), `04_DatosSQL_Grupo06.sql` (62 usuarios) y `05_Backend_Grupo06.sql` (27 procedimientos) se cargan sin errores, en ese orden (CONTEXTO §22; dato que me pasaron); las consultas de la defensa y las de verificación corrieron sin errores en MariaDB en la ronda anterior (con los datos de entonces; con los 62 usuarios, ver `LEEME_BASE_DE_DATOS.md`); las 131 consultas que tiene el código de la app se validaron con la regla `ONLY_FULL_GROUP_BY` de MySQL 8; los tests automáticos que existían en la ronda anterior (Objetos, Tienda, Ed. Física, Higiene, Sectores, Préstamo, Mi cuenta, login) dieron 0 fallas con el driver `QMYSQL`; esos tests ya no se mantienen (CONTEXTO §23): hoy las pruebas de la app son los casos por pantalla.
- **No probado:** MySQL 8 de Oracle, SQL Server, Windows, ni el camino ODBC con *MySQL Connector/ODBC* (con el conector ODBC de MariaDB la app detecta un problema de textos y avisa, sin abrir). 🔶

## 1. Cargar la base (DBeaver)
Seguí `GUIA_INSTALACION_MYSQL.md`, paso 3: ejecutar `03_ModeloSQL_Grupo06.sql` y después `04_DatosSQL_Grupo06.sql`, cada uno con **Alt+X** (el 03 ya crea la base `iqual`). El `05_Backend_Grupo06.sql` **no hace falta para la app**: es de la defensa de Bases de Datos. Comprobá que da **47** tablas.

## 2. Archivo `iqual.ini`
Se crea solo, junto al programa, la primera vez que se abre la app:

```
[base]
driver=auto
host=localhost
puerto=3306
usuario=root
clave=12341234
nombre=iqual
```
- `driver=auto` usa `QMYSQL` si Qt lo tiene y, si no, ODBC. También se puede poner `qmysql` o `odbc`.
- `odbc_driver=` (opcional) es el nombre del driver ODBC instalado, por ejemplo `MySQL ODBC 8.0 Unicode Driver`. Si no lo ponés, en Windows la app busca solo entre los drivers instalados uno de MySQL.

## 3. El driver en Windows (la parte difícil) 🔶
Qt para Windows (MinGW) **no trae `QMYSQL`**, pero **sí trae `QODBC`**. Hay dos caminos:

**Camino A — ODBC (no hay que compilar nada, probar primero).**
1. Instalá **MySQL Connector/ODBC** (de dev.mysql.com/downloads/connector/odbc, versión de 64 bits, la que se llama *Unicode*).
2. Dejá `driver=auto` en `iqual.ini`. Abrí la app: el título tiene que decir **· MySQL (ODBC)**.
3. Si aparece el aviso «El driver ODBC no compara bien los textos» o «no se pudo usar MySQL», la app no abre la base; probá el camino B o avisá el mensaje completo.

**Camino B — compilar el plugin `QMYSQL`.**
1. Instalá MySQL Server 8 (trae `libmysql.dll` y la carpeta `include`).
2. En el Maintenance Tool de Qt instalá el componente **Sources** de tu versión de Qt.
3. Compilá `Src/qtbase/src/plugins/sqldrivers` con CMake indicando `-DMySQL_INCLUDE_DIR=` y `-DMySQL_LIBRARY=` (y `-DCMAKE_PREFIX_PATH=` con tu Qt). Con MinGW puede hacer falta generar una librería de importación desde `libmysql.dll`.
4. Copiá `qsqlmysql.dll` a `<Qt>\plugins\sqldrivers\` y `libmysql.dll` junto al `.exe`.

**Ubuntu (como en la clase 006), probado:** `sudo apt install libqt6sql6-mysql libmysqlclient-dev`.

## 4. Probar la conexión antes de la demo
La app **no tiene base de respaldo**: si no conecta, no se puede usar. Probala en la compu de la presentación, de preferencia la víspera y otra vez un rato antes:

1. Servidor MySQL encendido y conexión desde DBeaver o Workbench con los datos de `iqual.ini` (por defecto `localhost`, `3306`, `root`, base `iqual`).
2. `SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'iqual';` tiene que dar **47**.
3. `iqual.ini` (junto al `.exe`) con los mismos `host`, `puerto`, `usuario`, `clave` y `nombre`.
4. Abrí la app: el título tiene que terminar en **· MySQL** o **· MySQL (ODBC)**. Entrá con una cuenta de demostración (por ejemplo `alumno1`, clave `1234`).

**Qué muestra la app cuando no conecta.** Dos cuadros «Atención» seguidos y, después, la ventana con todo deshabilitado y el título sin sufijo:
- «No se pudo usar MySQL:» + el error (servidor apagado, clave mal, falta el driver, base vacía, driver ODBC que no compara bien los textos) + «Revisá iqual.ini y que el servidor esté encendido.»
- «No se pudo abrir la base de datos. Revisá iqual.ini y que el servidor MySQL esté encendido.»

Si falla en plena demo no hay otra base a la que cambiar: se puede seguir mostrando la base y los procedimientos desde DBeaver (`consultas_demo.sql`, `05_Backend_Grupo06.sql`). `[COMPLETAR: si el equipo prefiere llevar capturas de la app funcionando como respaldo]`

El título de la ventana dice con qué driver está conectada: «· MySQL» (`QMYSQL`) o «· MySQL (ODBC)». Sin sufijo es que no conectó.

## 5. Qué cambió en el código
- `abrirBase()` lee `iqual.ini` y llama a `abrirMySql()`, que elige `QMYSQL` u ODBC; si falla, avisa y no abre.
- Las fechas se mandan a MySQL como fecha real (`QDate`/`QDateTime`); el id recién insertado se pide con `ultimoId()`.
- `formatoCorto()` entiende las fechas que devuelve MySQL (`2026-10-23T10:00:00`).
- MySQL no distingue mayúsculas ni tildes: el usuario `ALUMNO1` entra igual que `alumno1`.
