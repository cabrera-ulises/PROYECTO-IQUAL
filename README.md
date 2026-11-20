# PROYECTO IQUAL®
## SGE: Sistema de Gestión Escolar Integrado
*Proyecto Informático I - 4° Año Computación*  
**Especialidad:** Computación  
**Establecimiento:** Escuela Técnica N°3 D.E.9 Reg 8ª "María Sánchez de Thompson"  
**Marco Pedagógico:** Buenos Aires Aprende  
**Plataforma:** Aplicación de escritorio (C++17 · Qt 6 Widgets · CMake)  
**Versión de la aplicación:** v3 (`iqual_integrado_v3`)  

---

## 1. Descripción del Proyecto
Este sistema integrado surge para dar solución a la desorganización operativa en las áreas y recursos comunes de nuestro establecimiento escolar. El SGE unifica seis módulos de gestión diaria en una sola aplicación de escritorio, usada por alumnos, profesores, personal de preceptoría y maestranza, con acceso por roles y una pantalla de Mi Cuenta.

---

## 2. Desarrollo del 4° Bimestre (Implementación y Código)
En esta etapa, el proyecto avanza en la programación e implementación técnica del software en dupla de desarrollo:
* **Modelo relacional:** esquema de base de datos en 3FN con integridad referencial, de **47 tablas**. La aplicación **se conecta a MySQL** (base `iqual`); si el servidor, el driver o la base fallan, avisa el motivo y no abre. El modelo también se entrega como script para **SQL Server 2005**, y hay 27 procedimientos almacenados para MySQL (`db/05_Backend_Grupo00.sql`).
* **Interfaz y lógica de negocio:** aplicación de **escritorio** con una barra lateral de navegación, una barra superior (título de la página, usuario con su rol y botón de tema) y **dos temas**, claro y oscuro, que se recuerdan entre sesiones. Parte de las especificaciones y maquetados de la Carpeta V1 y los ajusta en el 4° Bimestre (ver [cambios respecto al diseño inicial](./docs/cambios-respecto-al-diseno-inicial.md)).

### 🧰 Tecnología
| Aspecto | Detalle |
| :--- | :--- |
| Lenguaje y framework | C++17 · Qt 6 (Qt Widgets y Qt Sql) · Qt Creator · CMake |
| Kit de compilación | Desktop Qt 6.12.0 MinGW 64-bit (Windows) |
| Target CMake | `PROYECTO_IQUAL` |
| Base de datos | MySQL (por defecto `localhost:3306`, base `iqual`). Los datos de conexión viven en `iqual.ini`, que la app crea sola junto al ejecutable. Driver `QMYSQL` o, si Qt no lo tiene, ODBC.|
| Seguridad y auditoría | Contraseñas con hash SHA-256, consultas SQL preparadas (`bindValue`) y registro de auditoría en la base (`log_auditoria`, 14 tipos de evento, con resultado Exitoso o Fallido) |
| Estructura de la interfaz | Una ventana con un `QStackedWidget` de 10 páginas: Landing, Acceso, Dashboard y una por módulo, más Mi Cuenta |

### 👥 Integrantes del Repositorio (4° Bimestre)
* **Arce Thiago**
* **Cabrera Ulises**

---

## 3. Módulos del Sistema
Los nombres son los que muestra hoy la aplicación; entre paréntesis, cómo se llamaban en el diseño inicial.
1. **Objetos Perdidos:** catálogo de pertenencias acumuladas en preceptoría, con foto opcional. El alumno reclama con una prueba de pertenencia (un dato que no se vea en la foto) y el Preceptor la compara con el dato reservado del objeto para aprobar o rechazar el reclamo. Incluye consultas "¿Vieron tal cosa?". El Preceptor, además, publica y archiva objetos y ve la auditoría (últimos 50 registros).
2. **Higiene y Mantenimiento (Higiene e Infraestructura):** reportes de roturas y limpieza que puede hacer cualquier rol (hasta 200 caracteres de observaciones), con el **último mantenimiento** de cada sector (fecha, hora y responsable). Profesores, Preceptores y Maestranza marcan los reportes como resueltos.
3. **Tienda de alumnos (Buffet Paralelo):** venta estudiantil de productos con foto opcional, categorías, stock y reservas; grupos de recaudación con PIN, metas y donaciones; pestañas "Mis reservas", "Mis ventas" y "Mis productos" (reponer y quitar stock). Sin pagos reales: las entregas se coordinan en persona.
4. **Préstamo de equipos (Planillas de Taller):** registro y devolución de las computadoras de los carros (C1 a C5 en el catálogo) y de los tableros de dibujo técnico, con los programas instalados en cada equipo, lista de equipos fuera de servicio y "Marcar reparado" (Preceptor y Maestranza).
5. **Reserva de Sectores:** reserva de sectores de tipo Reservable (hoy Laboratorio de química, Biblioteca y SUM) con selector de fecha, horas de 07:00 a 19:00, lista de ocupación del día y aprobación del Preceptor. Solo reservan Profesores y Preceptores.
6. **Educación Física:** inscripción a ofertas deportivas (deporte + día + franja + cupo). Los días y las horas que chocan con el horario de teoría y taller del curso se marcan en gris y no se pueden elegir.

Además: **Acceso** (inicio de sesión y registro con roles Alumno, Profesor, Preceptor y Maestranza; 5 intentos fallidos bloquean el acceso hasta reabrir la app), **Inicio** con un resumen según el rol y **Mi Cuenta** (datos, cambio de curso para alumnos, cambio de contraseña y de teléfono).

### Usuarios de demostración
Los carga el script de la base. **Contraseña de todos: `1234`**.
| Usuario | Rol | Notas |
| :--- | :--- | :--- |
| `alumno1` | Alumno | 4° 1° Computación, con horario cargado |
| `alumno2` | Alumno | 5° 2° Óptica, sin horario cargado, inscripto en Handball lunes 08:00 a 10:00 |
| `profe1` | Profesor | |
| `preceptor1` | Preceptor | |
| `maestranza1` | Maestranza | |

Para registrar cuentas de Profesor, Preceptor o Maestranza la app pide un PIN institucional. `[COMPLETAR: quién guarda y entrega el PIN en el colegio]`

---

## 4. Cómo compilar y ejecutar

### 4.1 Compilar en Windows (Qt 6 con MinGW)
1. **Instalar Qt** con Qt Creator y el kit **Desktop Qt 6.x MinGW 64-bit** (en el instalador, marcar los componentes *Qt 6 → MinGW 64-bit* y *Qt Creator*; se usó la versión 6.12.0). La app necesita los módulos **Widgets** y **Sql**.
2. **Abrir el proyecto:** en Qt Creator, *Archivo → Abrir archivo o proyecto* y elegir el `CMakeLists.txt` de la raíz del repositorio. Elegir el kit MinGW y *Configurar proyecto*.
3. **Compilar y ejecutar** el target `PROYECTO_IQUAL` (botón verde de Qt Creator). Las imágenes, los íconos, los dos temas van **dentro del ejecutable** (`recursos.qrc`): no hay que copiar nada al lado del `.exe`.
4. Si CMake falla, revisá que abriste el `CMakeLists.txt` de la raíz y que el kit sea MinGW 64-bit con Widgets y Sql instalados.

### 4.2 Base de datos (MySQL)
1. Instalar MySQL, crear la base `iqual` y ejecutar en este orden, con Alt+X en DBeaver o MySQL Workbench: `db/03_ModeloSQL_Grupo00.sql` (47 tablas), `db/04_DatosSQL_Grupo00.sql` (datos, 62 usuarios) y `db/05_Backend_Grupo00.sql` (procedimientos almacenados). Pasos detallados en [`db/guias/GUIA_INSTALACION_MYSQL.md`](./db/guias/GUIA_INSTALACION_MYSQL.md). La app **no crea** las tablas en MySQL; si la base existe pero está vacía, lo avisa.
2. **Conexión (`iqual.ini`).** La primera vez que se abre, la app crea `iqual.ini` junto al ejecutable, con una sección `[base]`:
   | Clave | Valor por defecto | Para qué |
   | :--- | :--- | :--- |
   | `driver` | `auto` | `auto` (usa `QMYSQL` si Qt lo tiene; si no, ODBC), `qmysql` u `odbc` |
   | `odbc_driver` | (vacío) | Nombre del driver ODBC de MySQL, si hay más de uno |
   | `host` | `localhost` | Servidor |
   | `puerto` | `3306` | Puerto |
   | `usuario` | `root` | Usuario |
   | `clave` | `12341234` | Contraseña (la de la clase de Bases de Datos) |
   | `nombre` | `iqual` | Nombre de la base |
3. **Driver en Windows.** El Qt de MinGW no trae `QMYSQL` pero sí `QODBC`: el camino recomendado es instalar *MySQL Connector/ODBC* (no hay que compilar nada); el alternativo es compilar el plugin `QMYSQL`. Detalles en [`db/guias/GUIA_CONEXION_APP_MYSQL.md`](./db/guias/GUIA_CONEXION_APP_MYSQL.md).
4. **Si MySQL falla** (servidor apagado, clave incorrecta, base vacía o sin driver), la app **avisa el motivo** y no abre: hay que revisar `iqual.ini`, que el servidor esté encendido y que `03`, `04` y `05` estén cargados. Si el conector ODBC no compara bien los textos, también avisa.
5. **Qué motor está usando:** lo dice el título de la ventana ("· MySQL", "· MySQL (ODBC)").
6. **Plan de emergencia para una demostración:** tener la base cargada y probada en la PC de la demo con anticipación; como alternativa, mostrar los scripts y las consultas desde DBeaver.

### 4.3 Qué se probó y qué no
* **Probado** (Linux, Qt 6.4, MariaDB 10.11): las pruebas automáticas internas de la v3 pasan con **0 fallas** con `QMYSQL`; las 131 consultas del código se validaron con `ONLY_FULL_GROUP_BY`; el script de 47 tablas, los 27 procedimientos (107 casos de prueba de SP en `db/06_PruebasSQL.xlsx`, todos PASS), las 10 consultas de la defensa y las 28 de verificación corren sin errores.
* **No probado:** MySQL 8 de Oracle, SQL Server 2005 y Windows (compilación y los dos caminos de driver). `[COMPLETAR: resultado de probarlo en la PC del equipo]`
* Los casos de prueba por pantalla están escritos pero **sin ejecutar**: la columna Resultado la completa el equipo. `[COMPLETAR: resultados de los casos de prueba]`

---

## 5. Estructura del Repositorio
```
/
├── README.md        Este archivo
├── CMakeLists.txt   Proyecto CMake (target PROYECTO_IQUAL)
├── *.cpp, *.h, *.ui Código de la aplicación Qt: main, mainwindow, ventanainicio, ventanadetalle, ventanaproducto
├── recursos.qrc     Imágenes, íconos, temas (claro.qss y oscuro.qss)
├── recursos/        Los archivos que referencia recursos.qrc (imagenes/, iconos/, tema/)
├── docs/            Documentación del proyecto
│   ├── pruebas/           Casos de prueba, errores y revisión de código por módulo
│   └── manuales/          Manual de usuario por módulo y por rol
└── db/              Scripts SQL, consultas, justificación de 3FN, diagramas y guías (db/guias/)
```
Contenido de `/db`:
* **Scripts (orden de carga 03, 04, 05):** `03_ModeloSQL_Grupo00.sql` (47 tablas), `04_DatosSQL_Grupo00.sql` (datos), `05_Backend_Grupo00.sql` (procedimientos almacenados: 15 funcionalidades, 8 reportes, 1 auditoría y 2 tuneados) y `06_PruebasSQL.xlsx` (107 casos de prueba). Versión SQL Server 2005 con schemas: `*_sqlserver.sql`.
* **Consultas:** `consultas_verificacion_mysql.sql` (y su versión para SQL Server) y `consultas_demo.sql` (consultas para mostrar en la defensa).
* **Documentos:** `justificacion_3FN.md` y las guías en `db/guias/` (`GUIA_INSTALACION_MYSQL.md`, `GUIA_CONEXION_APP_MYSQL.md`, `REVISION_ESTATICA_MYSQL.md`).
* **Diagramas:** los dos XML de draw.io y sus PNG (sección 6).


---

## 6. HITO 1 — Diagramas (XML y PNG)
Diagramas del Hito 1 de Bases de Datos, actualizados al modelo de 47 tablas. Se entregan como **XML editable de draw.io** y como **PNG con fondo blanco**; los PNG se exportan desde diagrams.net.

| Diagrama | Archivo XML editable | Archivo PNG |
| :--- | :--- | :--- |
| **Peter Chen** (modelo conceptual) | `/db/Proyecto_IQUAL_PeterChen.drawio.xml` | `/db/Proyecto_IQUAL_PeterChen.png` |
| **Edgar Codd** (modelo lógico, 3FN) | `/db/Proyecto_IQUAL_EdgarCodd.drawio.xml` | `/db/Proyecto_IQUAL_EdgarCodd.png` |


---

## 7. Documentación y Antecedentes (Carpeta V1 - `/docs`)
La documentación técnica de análisis, diagnóstico y maquetado del **3er Bimestre**, actualizada en el 4° Bimestre, está en [`/docs`](./docs):

* 📀 **[Defensa Oral](https://canva.link/ecw1bmcqn1ekxgu):** Diapositivas visuales para la defensa oral del tema (diseño inicial; lo que quedó desactualizado está en [`cambios-presentacion.md`](./docs/cambios-presentacion.md)).
* 📊 **[Matriz de Marco Lógico (MML)](./docs/marco-logico.xlsx):** Planificación sintética de jerarquía de objetivos, indicadores, medios de verificación y supuestos, con el estado de cada actividad.
* 🛠️ **Maquetado Funcional y Usabilidad:**
  * 📐 **[Maquetado Funcional y Usabilidad](./docs/maquetado-y-usabilidad.xlsx):** Especificación de pantallas y aplicación de las 10 Heurísticas de Jakob Nielsen (H1 a H10), con el estado de cada pantalla.
  * 🎨 **[Maquetado de Pantallas en Canva](https://canva.link/o7k6tqoyn125gn7):** Prototipo visual del diseño inicial (maquetas de celular).
* 📋 **[Especificación de Requerimientos](./docs/requerimientos.md):** Requerimientos Funcionales (RF01-RF23) y No Funcionales (RNF01-RNF04).
* 🟡 **[Historias de Usuario (Backlog)](./docs/historias-de-usuario.md):** US01 a US13 con sus Criterios de Aceptación (3 C de Agile).
* 🔗 **[Matriz de Trazabilidad](./docs/matriz-trazabilidad.md):** RF → historia → módulo → tablas → pantalla.
* 🔄 **[Cambios respecto al Diseño Inicial](./docs/cambios-respecto-al-diseno-inicial.md):** cada cambio, su motivo y el documento que afecta.
* 🧾 **[Cambios a hacer en la Presentación](./docs/cambios-presentacion.md):** corrección lámina por lámina.
* 🗓️ **[Bitácora de Trabajo](./docs/bitacora.md):** Registro de avances y decisiones del equipo.
* 🌳 **Diagnósticos Visuales:** [Árbol de Problemas](./docs/arbol-de-problemas.png) y [Árbol de Objetivos](./docs/arbol-de-objetivos.drawio.xml) (editable en draw.io).
* 🧪📖 **Pruebas, errores y manuales** (carpetas [`docs/pruebas`](./docs/pruebas) y [`docs/manuales`](./docs/manuales)):

| Módulos | Casos de prueba | Errores | Manual de usuario |
| :--- | :--- | :--- | :--- |
| Inicio, Acceso, Dashboard, Objetos perdidos y Préstamo de equipos | [`casos`](./docs/pruebas/CASOS_PRUEBA_ACCESO_OBJETOS_PRESTAMO.md) | [`errores`](./docs/pruebas/ERRORES_ACCESO_OBJETOS_PRESTAMO.md) | [`manual`](./docs/manuales/MANUAL_USUARIO_ACCESO_OBJETOS_PRESTAMO.md) |
| Higiene, Reserva de sectores y Mi cuenta | [`casos`](./docs/pruebas/CASOS_PRUEBA_HIGIENE_SECTORES_CUENTA.md) | [`errores`](./docs/pruebas/ERRORES_HIGIENE_SECTORES_CUENTA.md) | [`manual`](./docs/manuales/MANUAL_USUARIO_HIGIENE_SECTORES_CUENTA.md) |
| Tienda de alumnos y Educación Física | [`casos`](./docs/pruebas/CASOS_PRUEBA_TIENDA_EDFISICA.md) | [`errores`](./docs/pruebas/ERRORES_TIENDA_EDFISICA.md) | [`manual`](./docs/manuales/MANUAL_USUARIO_TIENDA_EDFISICA.md) |

Informe general: [`INFORME_PRUEBAS.md`](./docs/INFORME_PRUEBAS.md) y [`CASOS_PRUEBA_CONSOLIDADO.md`](./docs/CASOS_PRUEBA_CONSOLIDADO.md). Revisión de código: archivos `REVISION_CODIGO_*` en `docs/pruebas`. Manual técnico: [`MANUAL_TECNICO.md`](./docs/MANUAL_TECNICO.md).


---

## 8. Limitaciones Conocidas
* **Motor:** MySQL está probado en MariaDB 10.11 sobre Linux; falta probar MySQL 8 de Oracle y SQL Server 2005, y el camino de Windows (driver ODBC o `QMYSQL`). Si la conexión falla, la app avisa y no abre. El motor final está a confirmar con el profesor de Bases de Datos.
* Sin pagos reales: las reservas y donaciones de la tienda se coordinan en persona.
* El cruce de horarios de Educación Física solo funciona para los cursos con horario cargado.
* Sin notificaciones: para saber si una reserva fue aprobada o si un reporte se resolvió hay que entrar a la pantalla.
* **Acceso:** 5 intentos fallidos bloquean hasta cerrar y volver a abrir la app; no hay recuperación de contraseña dentro de la app. `[COMPLETAR: quién restablece las contraseñas en el colegio]`
* Un Alumno puede crear desde Mi Cuenta un curso que todavía no existe en la base (decisión por defecto).
* Los botones de acción (Aprobar, Rechazar, Cancelar, Marcar resuelto, etc.) están activos aunque no haya nada elegido: avisan al apretarlos (decisión por defecto).
* El registro de auditoría se ve en la pestaña Auditoría de Objetos (solo Preceptor, últimos 50 registros) o consultando la base.
* MySQL no distingue mayúsculas ni tildes: `ALUMNO1` entra igual que `alumno1`.

---

> **Nota de Créditos (3er Bimestre):** La fase de diagnóstico, investigación, MML, requerimientos y maquetados de la Carpeta V1 fue realizada durante el 3er Bimestre por el equipo original: Arce Thiago, Cabrera Ulises, Denuble Franco y González Manuel.

## Actualización v7: base de datos de la consigna de BBDD
Los scripts están en `db/`: `03_ModeloSQL_Grupo00.sql` (47 tablas), `04_DatosSQL_Grupo00.sql` (62 usuarios y datos de las demás tablas), `05_Backend_Grupo00.sql` (procedimientos almacenados) y `06_PruebasSQL.xlsx` (107 casos con resultado real). Orden de carga: 03, 04, 05, con Alt+X en DBeaver. Hay versión para SQL Server (`*_sqlserver.sql`, con schemas). El número de grupo `Grupo00` es provisorio hasta confirmarlo con el profesor. Si en algún documento aparece "5 usuarios", es el dato de ejemplo anterior: ahora son 62.
