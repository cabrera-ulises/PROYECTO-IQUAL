# Manual técnico — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · Sistema de Gestión Escolar · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Versión de la app descripta:** v3 (24/11/2026): la app usa solo MySQL.
**Qué es este documento:** explica cómo está armada la aplicación, cómo se conecta a la base de datos, cómo compilarla y ejecutarla, qué se probó y qué no, y qué limitaciones tiene hoy. Describe lo que la app hace **hoy**, no lo que se pensó en el diseño inicial.
**Cómo se obtuvo:** a partir del código fuente (`main.cpp`, `mainwindow.*`, `ventana*.*`, `CMakeLists.txt`, `recursos.qrc`, los dos `.qss`) y de las guías y scripts del proyecto. Las cantidades de líneas, funciones y consultas se contaron con comandos sobre el código.

---

## 1. Resumen técnico

| Dato | Valor |
|---|---|
| Lenguaje | C++17 |
| Framework | Qt 6 (Widgets + Sql). Kit usado en el proyecto: Desktop Qt 6.12.0 MinGW 64-bit |
| Sistema de construcción | CMake (objetivo `PROYECTO_IQUAL`) |
| Tipo de app | Escritorio, una sola ventana principal |
| Base de datos | MySQL (47 tablas); es la única que usa la app |
| Drivers | `QMYSQL` (plugin de Qt) o, en Windows, ODBC (`QODBC`) con MySQL Connector/ODBC |
| Tamaño del código principal (v3) | `mainwindow.cpp` 3257 líneas; `mainwindow.ui` 2244; `mainwindow.h` 246; 185 funciones de `MainWindow` (contadas con una búsqueda por texto, sin contar constructor y destructor) |
| Consultas | 99 llamadas a `prepare(` y 224 a `bindValue`; solo dos `exec("...")` directos sin parámetros: `SELECT LAST_INSERT_ID()` y `SET NAMES utf8mb4` |
| Nivel de código | Sin comentarios, sin ternarios, sin `continue`, sin `findData`, `.arg` encadenados de a un parámetro (verificado con búsquedas por texto sobre toda la app v3; ver `REVISION_CODIGO_*`) |

---

## 2. Arquitectura de la aplicación

### 2.1 Clases
| Clase | Archivos | Para qué sirve |
|---|---|---|
| `MainWindow` | `mainwindow.cpp/.h/.ui` | Ventana principal: acceso, menú lateral, barra superior, los módulos y toda la lógica de negocio y de acceso a datos |
| `VentanaDetalle` | `ventanadetalle.*` | Ventana de detalle (se abre desde las listas) |
| `VentanaProducto` | `ventanaproducto.*` | Ventana de producto de la Tienda |
| `VentanaInicio` | `ventanainicio.*` | Pantalla de presentación (splash). Se retiró del arranque: el código sigue en el proyecto pero la aplicación ya no la muestra |

### 2.2 Arranque (`main.cpp`)
1. Se crea la `QApplication`.
2. Se construye `MainWindow` (ahí se abre la base de datos, ver sección 4). Si no se puede abrir MySQL, la app muestra el motivo y la ventana queda deshabilitada (ver 4.5).
3. `w.show()` muestra la ventana principal.

### 2.3 Una sola ventana, varias páginas (`QStackedWidget`)
La interfaz se diseñó en Qt Designer (`mainwindow.ui`). El contenido cambia con un `QStackedWidget` de **10 páginas**, que el código nombra con el enum `Pagina`:

| Índice | Constante | Pantalla |
|---|---|---|
| 0 | `PAG_LANDING` | Pantalla de bienvenida |
| 1 | `PAG_ACCESO` | Acceso (inicio de sesión / registro) |
| 2 | `PAG_DASHBOARD` | Inicio (resumen) |
| 3 | `PAG_OBJETOS` | Objetos perdidos |
| 4 | `PAG_HIGIENE` | Higiene y mantenimiento |
| 5 | `PAG_BUFFET` | Tienda de alumnos |
| 6 | `PAG_PLANILLAS` | Préstamo de equipos |
| 7 | `PAG_SECTORES` | Reserva de sectores |
| 8 | `PAG_EDFISICA` | Educación Física |
| 9 | `PAG_CUENTA` | Mi cuenta |

- La **barra lateral** (menú) y la **barra superior** (título de la página) solo se muestran desde `PAG_DASHBOARD` en adelante (`on_stackedWidget_currentChanged`). En esa función también se marca el botón del menú que corresponde y se pone el título de la página.
- Cada botón del menú hace `ui->stackedWidget->setCurrentIndex(...)`; «Mi cuenta» pasa por `irACuenta()` y «Salir» por `cerrarSesion()`.
- Lo que ve cada rol se resuelve al iniciar sesión (`aplicarPermisos`): se ocultan botones y pestañas que ese rol no usa. Los roles son Alumno, Profesor, Preceptor y Maestranza (ver `matriz-trazabilidad.md` y `requerimientos.md` para el detalle por rol).

### 2.4 Slots automáticos
Los eventos de la interfaz usan la convención de Qt `on_<objeto>_<señal>`: Qt los conecta solo si el objeto se llama igual en el `.ui`. Hay **95 slots** de este tipo. Ejemplos: `on_btnNavObjetos_clicked`, `on_btnBuffetReservar_clicked`, `on_stackedWidget_currentChanged`. Ventaja: no hay `connect()` escritos a mano para esos botones. Desventaja: si se renombra un objeto en el `.ui`, el slot deja de conectarse sin avisar al compilar (Qt solo lo informa por consola al ejecutar).

### 2.5 Funciones de apoyo compartidas
Estas funciones se usan en todos los módulos; conviene conocerlas antes de tocar el código:

| Función | Qué hace |
|---|---|
| `exigir(roles, evento, entidad)` | Verifica que el usuario tenga uno de los roles permitidos; si no, avisa y registra el intento |
| `aviso`, `info` | Cuadros de mensaje (advertencia / información) |
| `fallar(evento, entidad, mensaje)` | Muestra un aviso y deja un registro «Fallido» en la auditoría |
| `registrarLog` | **Único método** que escribe en la auditoría |
| `confirmar(titulo, pregunta)` | Cuadro Sí/No; el botón por defecto es **No** |
| `hashClave` | SHA-256 de la clave con `QCryptographicHash` |
| `valorAhora()`, `valorFecha(QDate)` | Fecha y hora para guardar en la base, calculadas en C++ (no en el SQL): devuelven siempre un `QDateTime` o un `QDate` |
| `ultimoId(QSqlQuery&)` | Devuelve el id recién insertado; con driver ODBC pide `SELECT LAST_INSERT_ID()` |
| `formatoCorto()`, `plural` | Formato de fechas y plurales en los textos |
| `ponerIcono`, `colorToken` | Íconos y colores de estado |
| `elegirPorId`, `cargarCombo` | Cargar y posicionar combos por id |

Todas las consultas se escriben con `prepare()` y `bindValue()` (no se arman concatenando texto del usuario).

### 2.6 Temas y estilos (`.qss`)
- Hay dos hojas de estilo en los recursos: `claro.qss` y `oscuro.qss`.
- `aplicarTema(bool)` carga la hoja elegida y la aplica con `qApp->setStyleSheet`. La elección se guarda con `QSettings("IQUAL", "SGE")` bajo la clave `tema` y se recuerda en el próximo arranque.
- Después de cambiar de tema, la app vuelve a cargar las listas (así los colores de estado se recalculan).
- Algunos widgets se estilizan con **propiedades dinámicas** (`estilo`, `variante`) que el `.qss` usa como selector (por ejemplo, botones primarios o de peligro).

### 2.7 Auditoría
Toda acción relevante (alta, baja, cambio de estado, intento fallido) termina en `registrarLog`. Hay una pantalla para consultar la auditoría con los roles que corresponden (ver `requerimientos.md`).

---

## 3. Base de datos

### 3.1 Modelo
- **47 tablas**: 24 de catálogos y 23 de entidades y relaciones, según `justificacion_3FN.md`. Son las 44 del diseño original más `categoria_producto`, `software` y `recurso_software`.
- Está normalizado hasta **Tercera Forma Normal (3FN)**; la justificación está en `justificacion_3FN.md`.
- Diagramas: `Proyecto_IQUAL_Edgar_Codd.xml` y `Proyecto_IQUAL_Peter_Chen.xml` (modelo relacional y entidad-relación).
- La matriz de trazabilidad (`matriz-trazabilidad.md`, sección 6) vincula cada una de las 47 tablas con los requerimientos que la usan.

### 3.2 Scripts
| Script | Para qué sirve | Quién lo usa |
|---|---|---|
| `03_ModeloSQL_Grupo00.sql` | Crea la base `iqual` y las 47 tablas | Se carga a mano en DBeaver o Workbench |
| `04_DatosSQL_Grupo00.sql` | Carga los datos de demostración (62 usuarios) | Se carga a mano, después del 03 |
| `05_Backend_Grupo00.sql` | Crea los 27 procedimientos almacenados (usa `DELIMITER`, se carga aparte) | Se carga a mano, después del 04 |
| `03_ModeloSQL_Grupo00_sqlserver.sql` y `04_DatosSQL_Grupo00_sqlserver.sql` | Versión para SQL Server 2005 | Entrega del proyecto; **no se probó** |
| `consultas_demo.sql` | Consultas para la demostración | A mano |
| `consultas_verificacion_mysql.sql` | Consultas para verificar la carga | A mano |

La app no trae ningún script embebido: no crea tablas ni datos.

**Importante:** la app **no crea las tablas en MySQL**. Si la base `iqual` existe pero está vacía, la app avisa que hay que cargar `03_ModeloSQL_Grupo00.sql` y `04_DatosSQL_Grupo00.sql` desde DBeaver.

### 3.3 Procedimientos almacenados
`db/05_Backend_Grupo00.sql` crea **27 rutinas**: 15 procedimientos de funcionalidades (registrar log y usuario, objetos y reclamos, préstamo y devolución de equipos, reservas de sectores, higiene, compras y donaciones, inscripciones de Educación Física), 9 de reportes y auditoría, 2 versiones tuneadas de reportes y el auxiliar `sp_aux_solo_digitos`. (El script también crea y borra al final `sp_aux_crear_indices`, que solo sirve para crear índices al cargarlo.) Cada procedimiento devuelve un único resultado: `estado = 'OK'` con los ids, o `estado = 'ERROR'` con `codigo_sql` y `descripcion_error`.

**La app llama solo a `sp_registrar_log`** (`CALL sp_registrar_log(...)` desde `registrarLog`, para el log de auditoría). Si ese `CALL` falla, hace el `INSERT` en `log_auditoria` directamente. Las demás consultas de la app están escritas en `mainwindow.cpp`; los otros 26 procedimientos se usan desde la base (DBeaver o Workbench).

Fichas en `db/SP_*.md`, pruebas en `db/06_PruebasSQL.xlsx` (104 casos) y tuning medido en `db/TUNING_REPORTES.md`.

### 3.4 Cómo usa la app los tipos y el motor
| Tema | Cómo es en MySQL |
|---|---|
| Fechas | tipos `DATE` / `DATETIME`; la app pasa un `QDate` o un `QDateTime` con `bindValue` |
| Mayúsculas y tildes en comparaciones y `LIKE` | el collation por defecto (`utf8mb4_0900_ai_ci`) no las distingue: `ALUMNO1` = `alumno1` |
| Restricciones `CHECK` | se aplican desde MySQL 8.0.16 |
| Claves foráneas | siempre (InnoDB) |
| Id nuevo | `LAST_INSERT_ID()` con ODBC, `lastInsertId()` con `QMYSQL` (función `ultimoId`) |

El código no usa funciones de fecha del SQL (`NOW()`, `CURDATE()`): las fechas se calculan en C++ y el id nuevo pasa por `ultimoId`.

---

## 4. Cómo se conecta la app a la base (`abrirBase`)

### 4.1 Flujo
1. Al construir `MainWindow` se llama a `abrirBase()`.
2. `abrirBase()` lee `iqual.ini`, que está **al lado del .exe**. Si no existe, la app lo crea con valores por defecto.
3. Llama a `abrirMySql()`. Si conecta, el título de la ventana termina en «· MySQL» o «· MySQL (ODBC)» según el driver.
4. Si no conecta, `abrirBase()` muestra «No se pudo usar MySQL: …» con el motivo y devuelve `false` (ver 4.5).

### 4.2 `iqual.ini`
| Clave | Valor por defecto | Descripción |
|---|---|---|
| `host` | `localhost` | Servidor |
| `puerto` | `3306` | Puerto |
| `usuario` | (por defecto de la app) | Usuario de MySQL |
| `clave` | (por defecto de la app) | Clave de MySQL |
| `nombre` | `iqual` | Nombre de la base |
| `driver` (opcional) | `auto` | `auto`, `qmysql` u `odbc` |
| `odbc_driver` (opcional) | (se busca solo) | Nombre exacto del driver ODBC instalado |

Todas van en la sección `[base]`. Los valores de usuario y clave **no se escriben en este manual**: están en `GUIA_CONEXION_APP_MYSQL.md` y en el script de datos.

### 4.3 `abrirMySql` y elección del driver
- `driver=auto`: usa `QMYSQL` si Qt lo tiene disponible; si no, usa `QODBC`. Si no hay ninguno de los dos, devuelve el error «Qt no tiene ni el driver QMYSQL ni el QODBC».
- Con ODBC arma la cadena de conexión `DRIVER={...};SERVER=...;PORT=...;DATABASE=...`.
- `nombreDriverOdbc` busca en el registro de Windows (`HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers`) un driver de MySQL y prefiere el que dice «Unicode». Se puede forzar con `odbc_driver`.
- Después de conectar ejecuta `SET NAMES utf8mb4` para que las tildes y la ñ viajen bien.
- Si la base existe pero no tiene la tabla `usuario`, devuelve el error «La base … existe pero está vacía. Cargá 03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql desde DBeaver.»

### 4.4 Autochequeo con ODBC
Con ODBC, la app hace una consulta de prueba (`SELECT COUNT(*) FROM rol WHERE nombre_rol = :nombre` buscando «Alumno»). Si devuelve menos de 1, entiende que el driver no está pasando bien los parámetros, cierra la conexión y devuelve un error que sugiere instalar MySQL Connector/ODBC o usar el driver `QMYSQL`. No hay otra base a la que pasar.

### 4.5 Qué pasa si no se puede conectar
Si `abrirMySql` falla (servidor apagado, clave mal, base vacía, falta el driver o el autochequeo ODBC falla):
1. `abrirBase()` muestra el aviso «No se pudo usar MySQL:» + el motivo + «Revisá iqual.ini y que el servidor esté encendido.».
2. El constructor de `MainWindow` muestra un segundo aviso («No se pudo abrir la base de datos. Revisá iqual.ini y que el servidor MySQL esté encendido.»), deshabilita el `QStackedWidget` y sale sin llamar a `cargarCatalogos`.
3. La ventana queda abierta pero **sin usarse**: no hay login ni módulos hasta corregir el problema y volver a abrir la app. No hay base de respaldo.

### 4.6 Pasos para instalar el driver
**No se repiten acá.** Están en `GUIA_CONEXION_APP_MYSQL.md`: Camino A (MySQL Connector/ODBC Unicode de 64 bits), Camino B (compilar el plugin `QMYSQL`) e instalación en Ubuntu. La instalación del servidor y la carga del script están en `GUIA_INSTALACION_MYSQL.md`.

---

## 5. Cómo compilar y ejecutar

### 5.1 Requisitos
- Qt 6 con los módulos **Widgets** y **Sql** (el proyecto usa Desktop Qt 6.12.0 MinGW 64-bit).
- CMake y un compilador con C++17.
- Para usar MySQL: un driver (ver sección 4.6).

### 5.2 Pasos con Qt Creator
1. Abrir `CMakeLists.txt`.
2. Elegir el kit Desktop Qt 6.12.0 MinGW 64-bit.
3. Compilar y ejecutar el objetivo **`PROYECTO_IQUAL`**.
4. En la primera ejecución se crea `iqual.ini` **junto al .exe**, no junto al código.
5. Antes de abrir la app: levantar el servidor MySQL, cargar `03_ModeloSQL_Grupo00.sql`, `04_DatosSQL_Grupo00.sql` y `05_Backend_Grupo00.sql` y revisar `iqual.ini` (`GUIA_INSTALACION_MYSQL.md` y `GUIA_CONEXION_APP_MYSQL.md`).

### 5.3 Observaciones sobre el proyecto CMake
- `CMakeLists.txt` compila solo `main.cpp`, `mainwindow.*`, `ventanadetalle.*`, `ventanaproducto.*`, `ventanainicio.*` y `recursos.qrc`, y enlaza `Qt6::Widgets` y `Qt6::Sql`. Ya no hay ejecutables de prueba aparte (`harness*`): las pruebas de la app son los casos por pantalla de `docs/pruebas` y los 104 casos de los procedimientos (`db/06_PruebasSQL.xlsx`).
- `recursos.qrc` embebe el logo, el GIF del splash (sin uso), los dos `.qss` y los íconos; ya no embebe ningún script SQL.
- La carpeta `recursos/` (imágenes, temas e íconos) está en el repositorio, junto a `recursos.qrc`.

---

## 6. Estructura de carpetas

El repositorio se organiza así:

```
README.md
docs/        documentación (requerimientos, historias, matriz, manuales, informes)
db/          scripts SQL, diagramas y guías de MySQL
(raíz)       código: CMakeLists.txt, main.cpp, mainwindow.*, ventana*.*, recursos.qrc
recursos/    tema/ (claro.qss, oscuro.qss), imagenes/, iconos/
```


Recursos embebidos (`recursos.qrc`): `/imagenes` (logo y GIF del splash, sin uso), `/tema` (los dos `.qss`) e `/iconos` (`nav_*`, `tarj_*`, `barra_*`).

---

## 7. Qué se probó y qué no

**Probado (Linux, Qt 6.4, MariaDB 10.11):**
- 131 consultas de la app validadas con el modo `ONLY_FULL_GROUP_BY`.
- Los scripts `03`, `04` y `05` (47 tablas, 62 usuarios, 27 procedimientos), `consultas_demo.sql` y `consultas_verificacion_mysql.sql` corren sin errores.
- 104 casos de prueba de los procedimientos (`db/06_PruebasSQL.xlsx`) planificados; 80 se ejecutaron a mano en la aplicación.
- La app compila con Qt 6.12 MinGW 64-bit (Windows).

**No probado:**
- MySQL 8 de Oracle (la base usada fue MariaDB 10.11) y SQL Server 2005 (`03_ModeloSQL_Grupo00_sqlserver.sql`, solo revisado por lectura).
- Rendimiento con muchos usuarios simultáneos (RNF03).
- De los 337 casos de prueba por pantalla se probaron 306 (285 OK y 21 con observación); 31 quedaron sin probar. De los 104 casos planificados de la base, 80 se ejecutaron a mano. El resultado de cada caso está en `docs/CASOS_PRUEBA_CONSOLIDADO.md` (columna «Resultado»).

`REVISION_ESTATICA_MYSQL.md` es una revisión por lectura, anterior a las corridas con MariaDB.

---

## 8. Limitaciones y decisiones tomadas

### 8.1 Limitaciones conocidas
- **MySQL como único motor, sin confirmación final:** fue decisión del usuario; la confirmación del profesor de Bases de Datos está pendiente.
- La app **no crea las tablas** en MySQL: hay que cargar el script a mano.
- Si MySQL falla, la app avisa el motivo y no se puede usar (no hay base de respaldo): hay que dejar el servidor andando antes de la defensa.
- El PIN de un grupo de recaudación se guarda en texto plano (`grupo_buffet.pin_acceso`); la clave de usuario se guarda con hash SHA-256 (sin sal). Para el alcance escolar se declara como limitación (RNF02).
- Las comparaciones no distinguen mayúsculas ni tildes (`utf8mb4_0900_ai_ci`).
- Hay errores abiertos de baja gravedad documentados por módulo (ver `ERRORES_ACCESO_OBJETOS_PRESTAMO/3/4.md`).
- Rendimiento con muchos datos: no se midió (RNF03).
- Sin pagos reales: las reservas de la Tienda se coordinan y se pagan en persona .
- El cruce de horarios de Educación Física solo funciona para los cursos con horario cargado .
- Sin notificaciones en pantalla . La auditoría **sí tiene pantalla** (pestaña «Auditoría» de Objetos perdidos, solo para el Preceptor); la documentación del proyecto todavía dice que no (ver los documentos de `docs/pruebas`).
- Es una aplicación de escritorio: no hay versión web ni para celular.

### 8.2 Decisiones por defecto 
| Tema | Decisión |
|---|---|
| Login (U04) | 5 intentos fallidos → hay que cerrar y volver a abrir la app. No hay recuperación de clave. El restablecimiento lo hace el responsable del sistema (soporte técnico de IQUAL), verificando el DNI. |
| Objetos devueltos (U18) | Se ven en gris con «Ya devuelto» y no se pueden reclamar |
| Observaciones (U11) | Un solo campo de observaciones |
| Devolver un equipo (ERR-08) | Arranca en «Funciona»; solo «No funciona» pide confirmación |
| Curso inexistente (E4-05) | El Alumno puede crearlo desde Mi cuenta |
| Botones sin selección | Quedan habilitados y avisan al tocarlos |
| Educación Física | Inscribirme se deshabilita cuando la opción no se puede elegir; no se genera «Fallido» desde la pantalla |

### 8.3 Errores corregidos 
ERR-01, 02, 03, 05, 06, 07 ; E4-01, 02, 03, 11 ; E-01, 02, 03 . En la app v3  se suman: E4-04 y E4-06 (Mi cuenta), E-15 (estilo de código en `cargarDiasEdFisica`) y la revisión de código de toda la app (sin comentarios, ternarios, `continue` ni `findData`). Además, se retiró la pantalla de presentación (splash) del arranque (ERR-23).

---

## 9. Datos de demostración

Los usuarios, claves y PIN de demostración **no se escriben acá**: están en el script de datos (`03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`) y en `GUIA_CONEXION_APP_MYSQL.md`. Resumen de lo que hay cargado : usuarios `alumno1`, `alumno2`, `profe1`, `preceptor1` y `maestranza1`; objetos perdidos de ejemplo; el grupo «Viaje de Estudios 4to 1ra» con tres productos; un equipo prestado; un tablero fuera de servicio; 20 ofertas de Educación Física.

**Reservas de sectores:** el script de datos las carga con fechas relativas a hoy (`DATE_ADD(CURDATE(), INTERVAL 1 DAY)` y `INTERVAL 2 DAY`), así que siempre aparecen como futuras.


---
