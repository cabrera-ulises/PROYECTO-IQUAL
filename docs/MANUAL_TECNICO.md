# Manual técnico — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · Sistema de Gestión Escolar · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Versión de la app descripta:** v3 (`iqual_integrado_v3`, CONTEXTO §20, 13/11/2026).
**Qué es este documento:** explica cómo está armada la aplicación, cómo se conecta a la base de datos, cómo compilarla y ejecutarla, qué se probó y qué no, y qué limitaciones tiene hoy. Describe lo que la app hace **hoy**, no lo que se pensó en el diseño inicial.
**Cómo se obtuvo:** lectura del código fuente integrado (`main.cpp`, `mainwindow.cpp/.h/.ui`, `ventanadetalle.*`, `ventanainicio.*`, `ventanaproducto.*`, `CMakeLists.txt`, `recursos.qrc`, los dos `.qss`) y de las guías y scripts del proyecto. Los números de líneas y de funciones salen de contarlos con comandos sobre los archivos recibidos. **Yo no compilé ni ejecuté la app** (ver sección 9).

---

## 1. Resumen técnico

| Dato | Valor |
|---|---|
| Lenguaje | C++17 |
| Framework | Qt 6 (Widgets + Sql). Kit usado en el proyecto: Desktop Qt 6.12.0 MinGW 64-bit |
| Sistema de construcción | CMake (objetivo `PROYECTO_IQUAL`) |
| Tipo de app | Escritorio, una sola ventana principal |
| Base de datos principal | MySQL (47 tablas) |
| Base de respaldo | SQLite (`iqual.db`, se crea sola en el primer uso) |
| Drivers | `QMYSQL` (plugin de Qt) o ODBC (`QODBC`) con MySQL Connector/ODBC; `QSQLITE` para el respaldo |
| Tamaño del código principal (v3) | `mainwindow.cpp` 3269 líneas; `mainwindow.ui` 2244; `mainwindow.h` 247; 186 funciones de `MainWindow` (contadas con una búsqueda por texto, sin contar constructor y destructor) |
| Consultas | 98 llamadas a `prepare(` y 217 a `bindValue`; solo dos `exec("...")` directos sin parámetros: `SELECT LAST_INSERT_ID()` y `SET NAMES utf8mb4` |
| Nivel de código | Sin comentarios, sin ternarios, sin `continue`, sin `findData`, `.arg` encadenados de a un parámetro (verificado con búsquedas por texto sobre toda la app v3; ver `REVISION_CODIGO_*`) |

---

## 2. Arquitectura de la aplicación

### 2.1 Clases
| Clase | Archivos | Para qué sirve |
|---|---|---|
| `MainWindow` | `mainwindow.cpp/.h/.ui` | Ventana principal: acceso, menú lateral, barra superior, los módulos y toda la lógica de negocio y de acceso a datos |
| `VentanaDetalle` | `ventanadetalle.*` | Ventana de detalle (se abre desde las listas) |
| `VentanaProducto` | `ventanaproducto.*` | Ventana de producto de la Tienda |
| `VentanaInicio` | `ventanainicio.*` | Pantalla de presentación (splash): diálogo sin borde de 960×540 con un GIF animado (`QMovie`); se cierra sola a los 2600 ms o al hacer clic |

### 2.2 Arranque (`main.cpp`)
1. Se crea la `QApplication`.
2. Se muestra `VentanaInicio` (splash).
3. Se construye `MainWindow` (ahí se abre la base de datos, ver sección 4).
4. `inicio.exec()` espera a que se cierre el splash.
5. `w.show()` muestra la ventana principal.

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
| `valorAhora()`, `valorFecha(QDate)` | Fecha y hora para guardar en la base, calculadas en C++ (no en el SQL) |
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
| `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` | Crea las 47 tablas y carga los datos de demostración en MySQL | Se carga a mano en DBeaver o Workbench |
| `05_Backend_Grupo00.sql` | Crea 5 procedimientos almacenados (usa `DELIMITER`, se carga aparte) | Se carga a mano |
| `iqual_sqlite.sql` | Mismo modelo para SQLite | **Está embebido en la app** (`:/imagenes/iqual_sqlite.sql`); la app lo ejecuta para crear `iqual.db` |
| `03_ModeloSQL_Grupo00_sqlserver.sql` | Versión para SQL Server 2005 | Entrega del proyecto; **no se probó** |
| `consultas_demo.sql` | 10 consultas para la demostración | A mano |
| `consultas_verificacion.sql` | 28 consultas para verificar la carga | A mano |

**Importante:** la app **no crea las tablas en MySQL**. Si la base `iqual` existe pero está vacía, la app avisa que hay que cargar `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` desde DBeaver.

### 3.3 Procedimientos almacenados
`05_Backend_Grupo00.sql` crea 27 rutinas: 15 SP de funcionalidades (registrar log y usuario, objetos y reclamos, préstamo y devolución de equipos, reservas de sectores, higiene, compras y donaciones, inscripciones de Educación Física), 8 reportes, 1 de auditoría con rango de fechas y 2 versiones tuneadas, más el auxiliar `sp_aux_solo_digitos`. Cada SP devuelve un único resultado: `estado = 'OK'` con los ids, o `estado = 'ERROR'` con `codigo_sql` y `descripcion_error`. Fichas en `db/SP_*.md`, pruebas en `db/06_PruebasSQL.xlsx` y tuning medido en `db/TUNING_REPORTES.md`. De todos ellos la app Qt solo llama a `sp_registrar_log` (para el log de auditoría en MySQL, con respaldo al INSERT); el resto de las consultas de la app están escritas en `mainwindow.cpp`.

### 3.4 Diferencias entre MySQL y SQLite
| Tema | MySQL | SQLite (respaldo) |
|---|---|---|
| Fechas | tipos `DATE` / `DATETIME` | texto |
| Mayúsculas y tildes en comparaciones y `LIKE` | el collation por defecto (`utf8mb4_0900_ai_ci`) no las distingue: `ALUMNO1` = `alumno1` | solo ignora mayúsculas ASCII |
| Restricciones `CHECK` | se aplican desde MySQL 8.0.16 | se aplican |
| Claves foráneas | siempre | la app ejecuta `PRAGMA foreign_keys = ON` al abrir |
| Id nuevo | `LAST_INSERT_ID()` con ODBC, `lastInsertId()` con QMYSQL | `lastInsertId()` |

El código evita SQL propio de un motor: las fechas se calculan en C++ y el id nuevo pasa por `ultimoId`.

---

## 4. Cómo se conecta la app a la base (`abrirBase`)

### 4.1 Flujo
1. Al construir `MainWindow` se llama a `abrirBase()`.
2. Si existe la variable de entorno `IQUAL_MOTOR=sqlite`, se usa SQLite directamente.
3. Si no, se lee `iqual.ini`, que está **al lado del .exe**. Si no existe, la app lo crea con valores por defecto.
4. Con `motor=mysql` se intenta `abrirMySql`. Si falla, la app muestra un aviso con el motivo y **pasa a SQLite** (`abrirSqlite`).
5. El título de la ventana indica el motor: «· MySQL», «· MySQL (ODBC)» o nada si es SQLite.

### 4.2 `iqual.ini`
| Clave | Valor por defecto | Descripción |
|---|---|---|
| `motor` | `mysql` | `mysql` o `sqlite` |
| `host` | `localhost` | Servidor |
| `puerto` | `3306` | Puerto |
| `usuario` | (por defecto de la app) | Usuario de MySQL |
| `clave` | (por defecto de la app) | Clave de MySQL |
| `nombre` | `iqual` | Nombre de la base |
| `driver` (opcional) | `auto` | `auto`, `qmysql` u `odbc` |
| `odbc_driver` (opcional) | (se busca solo) | Nombre exacto del driver ODBC instalado |

Los valores de usuario y clave **no se escriben en este manual**: están en `GUIA_CONEXION_APP_MYSQL.md` y en el script de datos.

### 4.3 `abrirMySql` y elección del driver
- `driver=auto`: usa `QMYSQL` si Qt lo tiene disponible; si no, usa `QODBC`.
- Con ODBC arma la cadena de conexión `DRIVER={...};SERVER=...;PORT=...;DATABASE=...`.
- `nombreDriverOdbc` busca en el registro de Windows (`HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers`) un driver de MySQL y prefiere el que dice «Unicode». Se puede forzar con `odbc_driver`.
- Después de conectar ejecuta `SET NAMES utf8mb4` para que las tildes y la ñ viajen bien.
- Si la base existe pero no tiene tablas, falla con el mensaje «Cargá 03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql desde DBeaver».

### 4.4 Autochequeo con ODBC
Con ODBC, la app hace una consulta de prueba (`SELECT COUNT(*) FROM rol WHERE nombre_rol = :nombre` buscando «Alumno»). Si devuelve menos de 1, entiende que el driver no está pasando bien los parámetros y cae al respaldo con un mensaje que sugiere instalar MariaDB Connector/ODBC.

### 4.5 `abrirSqlite`
Si no existe `iqual.db` junto al .exe, la crea ejecutando el script embebido `:/imagenes/iqual_sqlite.sql` (lo separa por «;» y lo corre dentro de una transacción), y activa `PRAGMA foreign_keys = ON`.

### 4.6 Pasos para instalar el driver
**No se repiten acá.** Están en `GUIA_CONEXION_APP_MYSQL.md`: Camino A (MySQL Connector/ODBC Unicode de 64 bits), Camino B (compilar el plugin `QMYSQL`), instalación en Ubuntu y el plan de emergencia (`motor=sqlite`). La instalación del servidor y la carga del script están en `GUIA_INSTALACION_MYSQL.md`.

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
4. En la primera ejecución se crea `iqual.ini` (y `iqual.db` si cae en SQLite) **junto al .exe**, no junto al código.
5. Para usar MySQL: levantar el servidor, cargar `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` (y los procedimientos) y revisar `iqual.ini` (`GUIA_INSTALACION_MYSQL.md` y `GUIA_CONEXION_APP_MYSQL.md`).

### 5.3 Observaciones sobre el paquete recibido (`app_codigo.zip` de la v3)
- **Ahora sí trae** la carpeta `recursos/` (íconos, imágenes y las dos hojas `.qss`).
- **Sigue faltando `iqual_sqlite.sql`**: `recursos.qrc` lo incluye (`<file>iqual_sqlite.sql</file>`, junto al `.qrc`) y no está en el zip. Sin ese archivo el proyecto no compila. Es el script que la app ejecuta para crear `iqual.db`.
- **Siguen faltando los `harness*.cpp`**: `CMakeLists.txt` conserva el bucle `foreach(h harness harness2 harness3 harness4 harness6 harness7)` y esos archivos no están en el zip; CMake falla al configurar si no están. CONTEXTO §20 informa que Arce Thiago y Cabrera Ulises corrió `harness3` y `harness4` (0 fallas), así que existen en su repositorio. `[COMPLETAR: Arce Thiago y Cabrera Ulises incluye los harness y `iqual_sqlite.sql` en el repositorio de entrega, o saca el bucle del `CMakeLists.txt`]`
- No pude compilar este paquete (en mi entorno no hay Qt).

---

## 6. Estructura de carpetas

Según `README_proyecto.md` (el repositorio se organiza así):

```
README.md
docs/        documentación (requerimientos, historias, matriz, manuales, informes)
db/          scripts SQL, diagramas y guías de MySQL
(raíz)       código: CMakeLists.txt, main.cpp, mainwindow.*, ventana*.*, recursos.qrc
recursos/    tema/ (claro.qss, oscuro.qss), imagenes/, iconos/
```

`[COMPLETAR: confirmar la estructura final del repositorio; el README_proyecto.md todavía dice 44 tablas, SQLite por defecto, «Buffet Paralelo» y «Planillas de Taller», y lo está actualizando Arce Thiago y Cabrera Ulises]`

Recursos embebidos (`recursos.qrc`): `/imagenes` (logo, GIF del splash, `iqual_sqlite.sql`), `/tema` (los dos `.qss`) e `/iconos` (`nav_*`, `tarj_*`, `barra_*`).

---

## 7. Qué se probó y qué no

Fuente: CONTEXTO §19.1 y §20.

**Probado (Arce Thiago y Cabrera Ulises, en Linux con Qt 6.4 y MariaDB 10.11):**
- Pruebas automáticas: 0 fallas con `QMYSQL` y con SQLite (en la v3, `harness3` y `harness4`, según CONTEXTO §20).
- 131 consultas validadas con el modo `ONLY_FULL_GROUP_BY`.
- `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`, los procedimientos, `consultas_demo.sql` y `consultas_verificacion.sql` corren sin errores.

**No probado:**
- MySQL 8 de Oracle (la base usada fue MariaDB 10.11).
- SQL Server 2005 (`03_ModeloSQL_Grupo00_sqlserver.sql`).
- Windows: ni el camino ODBC ni el plugin `QMYSQL` compilado.
- La compilación de este paquete: la hizo Arce Thiago y Cabrera Ulises en su entorno; **yo no pude compilar ni ejecutar** (en mi entorno no hay Qt instalado y el zip no traía los recursos).
- Los casos de prueba escritos (Arce Thiago y Cabrera Ulises, 3 y 4): están redactados pero **nadie los ejecutó** todavía (ver `INFORME_PRUEBAS.md`).

`REVISION_ESTATICA_MYSQL.md` es una revisión por lectura, anterior a las corridas con MariaDB.

---

## 8. Limitaciones y decisiones tomadas

### 8.1 Limitaciones conocidas
- **MySQL por defecto, sin confirmación final:** fue decisión del usuario; el profesor Linares todavía no lo confirmó. `[COMPLETAR: confirmación de Linares]`
- La app **no crea las tablas** en MySQL: hay que cargar el script a mano.
- Si MySQL falla, la app sigue con SQLite: puede pasar sin que el usuario lo note si no mira el título de la ventana. Los datos de un motor no pasan al otro.
- El PIN de un grupo de recaudación se guarda en texto plano (`grupo_buffet.pin_acceso`); la clave de usuario se guarda con hash SHA-256 (sin sal). Para el alcance escolar se declara como limitación (RNF02).
- Las comparaciones no distinguen mayúsculas ni tildes en MySQL (`utf8mb4_0900_ai_ci`) y sí lo hacen distinto en SQLite.
- Hay errores abiertos de baja gravedad documentados por módulo (ver `ERRORES_ACCESO_OBJETOS_PRESTAMO/3/4.md`).
- Rendimiento con muchos datos: no se midió (RNF03).
- Sin pagos reales: las reservas de la Tienda se coordinan y se pagan en persona (CONTEXTO §9).
- El cruce de horarios de Educación Física solo funciona para los cursos con horario cargado (CONTEXTO §9).
- Sin notificaciones en pantalla (CONTEXTO §9). La auditoría **sí tiene pantalla** (pestaña «Auditoría» de Objetos perdidos, solo para el Preceptor); CONTEXTO §9 todavía dice que no (ver los documentos de `docs/pruebas`).
- Es una aplicación de escritorio: no hay versión web ni para celular.

### 8.2 Decisiones por defecto (CONTEXTO §19.3)
| Tema | Decisión |
|---|---|
| Login (U04) | 5 intentos fallidos → hay que cerrar y volver a abrir la app. No hay recuperación de clave. `[COMPLETAR: quién restablece la contraseña en el colegio]` |
| Objetos devueltos (U18) | Se ven en gris con «Ya devuelto» y no se pueden reclamar |
| Observaciones (U11) | Un solo campo de observaciones |
| Devolver un equipo (ERR-08) | Arranca en «Funciona»; solo «No funciona» pide confirmación |
| Curso inexistente (E4-05) | El Alumno puede crearlo desde Mi cuenta |
| Botones sin selección | Quedan habilitados y avisan al tocarlos |
| Educación Física | Inscribirme se deshabilita cuando la opción no se puede elegir; no se genera «Fallido» desde la pantalla |

### 8.3 Errores corregidos (CONTEXTO §19.2)
ERR-01, 02, 03, 05, 06, 07 (Arce Thiago y Cabrera Ulises); E4-01, 02, 03, 11 (Arce Thiago y Cabrera Ulises); E-01, 02, 03 (Arce Thiago y Cabrera Ulises). En la app v3 (CONTEXTO §20) se suman: E4-04 y E4-06 (Mi cuenta), E-15 (estilo de código en `cargarDiasEdFisica`) y la revisión de código de toda la app (sin comentarios, ternarios, `continue` ni `findData`). Sin cambios: la pantalla de inicio (ERR-23, decisión: no tocar).

---

## 9. Datos de demostración

Los usuarios, claves y PIN de demostración **no se escriben acá**: están en el script de datos (`03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`) y en `GUIA_CONEXION_APP_MYSQL.md`. Resumen de lo que hay cargado (CONTEXTO §8): usuarios `alumno1`, `alumno2`, `profe1`, `preceptor1` y `maestranza1`; objetos perdidos de ejemplo; el grupo «Viaje de Estudios 4to 1ra» con tres productos; un equipo prestado; un tablero fuera de servicio; 20 ofertas de Educación Física.

**Reservas de sectores:** CONTEXTO §8 dice que tienen fechas fijas (05 y 06/11/2026) y que la app deja de mostrarlas después (filtra fecha ≥ hoy). **El `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` que recibí el 11/11 las carga con fechas relativas** (`DATE_ADD(CURDATE(), INTERVAL 1 DAY)` y `INTERVAL 2 DAY`), así que con MySQL siempre aparecen como «mañana» y «pasado». Para el script de SQLite (`iqual_sqlite.sql`, el embebido) no pude verificarlo porque no lo recibí. `[COMPLETAR: Arce Thiago y Cabrera Ulises confirma las fechas del script de SQLite y corrige CONTEXTO §8]`

**Otras diferencias de CONTEXTO §8 con el script de MySQL:** `alumno2` es de **5° 2° Óptica** (no Electrónica); «Llaves con llavero rojo» está **Disponible con dos reclamos pendientes** (de `alumno1` y `alumno2`) y «Calculadora científica» está Devuelta con un reclamo aprobado.

---

## Desvíos
- **No compilé ni ejecuté nada.** Todo lo de este manual sale de leer el código y los documentos; los resultados de pruebas son los que informa CONTEXTO §19.1.
- Dejé las instrucciones del driver en `GUIA_CONEXION_APP_MYSQL.md` (como se pidió) y no inventé pasos.
- No incluí usuarios, claves ni PIN.
- **Ronda final:** actualicé las métricas y el estado del código a la app v3 (los números los recontó con comandos sobre el zip recibido), agregué las limitaciones de CONTEXTO §9 que faltaban y corregí lo que había dicho de las fechas de las reservas de sectores y de `alumno2`, comparando con `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`.
- CONTEXTO §8 y §9 tienen datos viejos frente al script y a la v3 (ver sección 9); en este manual valen el script y el código.
- Los procedimientos almacenados no los llama la app (ver 3.3); lo dejé marcado como duda y no como error.
- El plan de aprendizaje dice «C/Qt»; el proyecto es C++17 con Qt: lo describí como C++17.

## Datos que faltan
- `[COMPLETAR: confirmación de Linares sobre MySQL]`
- `[COMPLETAR: resultado de la prueba en Windows (ODBC y plugin QMYSQL)]` — lo hace el usuario.
- `[COMPLETAR: incluir en el repositorio los `harness*.cpp` y `iqual_sqlite.sql`, o sacar el bucle de harness del CMakeLists.txt]` — Arce Thiago y Cabrera Ulises.
- `[COMPLETAR: fechas de las reservas de sectores del script de SQLite]` — Arce Thiago y Cabrera Ulises.
- `[COMPLETAR: estructura final del repositorio]` — Arce Thiago y Cabrera Ulises está actualizando el README.
- `[COMPLETAR: quién restablece la contraseña en el colegio]`
- `[COMPLETAR: si los procedimientos almacenados se muestran solo como parte de la base o también desde la app]`
