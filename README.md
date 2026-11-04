# PROYECTO IQUAL®
## SGE: Sistema de Gestión Escolar Integrado
*Proyecto Informático I - 4° Año Computación*  
**Especialidad:** Computación  
**Establecimiento:** Escuela Técnica N°3 D.E.9 Reg 8ª "María Sánchez de Thompson"  
**Marco Pedagógico:** Buenos Aires Aprende  
**Plataforma:** Aplicación de escritorio (C++17 · Qt 6 Widgets · CMake)  

---

## 1. Descripción del Proyecto
Este sistema integrado surge para dar solución a la desorganización operativa en las áreas y recursos comunes de nuestro establecimiento escolar. El SGE unifica seis módulos críticos de gestión diaria en una sola aplicación de escritorio autogestionable por alumnos, profesores, personal de preceptoría y maestranza, con acceso por roles y una pantalla de Mi Cuenta.

---

## 2. Desarrollo del 4° Bimestre (Implementación y Código)
En esta etapa correspondiente al **4° Bimestre**, el proyecto avanza en la programación e implementación técnica del software en dupla de desarrollo:
* **Modelo Relacional:** esquema de base de datos relacional en 3FN con integridad referencial, de **44 tablas** (22 catálogos y 22 entidades). **SQLite en la app; modelo entregado también en SQL Server (scripts para SQL Server 2005) y MySQL.** El motor final está **a confirmar con el profesor de BBDD.**
* **Interfaz y Lógica de Negocio:** desarrollo de la aplicación de **escritorio** basada en las especificaciones y maquetados de la Carpeta V1, ajustados en el 4° Bimestre (ver [cambios respecto al diseño inicial](./docs/cambios-respecto-al-diseno-inicial.md)).

### 🧰 Tecnología
| Aspecto | Detalle |
| :--- | :--- |
| Lenguaje y framework | C++17 · Qt 6 (Qt Widgets) · Qt Creator · CMake |
| Kit de compilación | Desktop Qt 6.12.0 MinGW 64-bit (Windows) |
| Target CMake | `PROYECTO_IQUAL` |
| Base de datos en la app | SQLite local (`iqual.db`, junto al ejecutable; se crea sola la primera vez con un script embebido en el `.qrc`) |
| Seguridad y auditoría | Contraseñas con hash SHA-256, consultas SQL preparadas (`bindValue`) y registro de auditoría en la base (`log_auditoria`, sin pantalla) |
| Estructura de la interfaz | Una ventana con un `QStackedWidget` de 10 páginas (una por módulo) |

### 👥 Integrantes del Repositorio (4° Bimestre)
* **Arce Thiago**
* **Cabrera Ulises**

---

## 3. Módulos del Sistema
1. **Objetos Perdidos:** catálogo de pertenencias acumuladas en preceptoría; el alumno reclama con una prueba de pertenencia y el Preceptor aprueba o rechaza el reclamo. Incluye consultas "¿Vieron tal cosa?".
2. **Higiene e Infraestructura:** canal interactivo de reportes de roturas y limpieza, con trazabilidad del último mantenimiento de cada sector (fecha, hora y responsable).
3. **Buffet Paralelo:** venta estudiantil de productos con reservas, grupos de recaudación con PIN y registro de donaciones para metas grupales (sin pagos reales).
4. **Planillas de Taller:** registro y devolución digital de préstamos de los carros de computadoras (catálogo C1-C5) y de los tableros de dibujo técnico.
5. **Reserva de Sectores:** reserva de laboratorio de química, biblioteca y otros sectores de tipo Reservable con selector de fecha, lista de ocupación del día y aprobación del Preceptor.
6. **Inscripción a Educación Física:** inscripción a ofertas deportivas (deporte + día + franja + cupo), con validación contra superposición con el horario de teoría y taller del curso.

Además: **Acceso** (inicio de sesión y registro, con roles Alumno, Profesor, Preceptor y Maestranza), **Mi Cuenta** y un **registro de auditoría** en la base de datos (sin pantalla).

---

## 4. Estructura del Repositorio
```
/
├── README.md        Este archivo
├── docs/            Documentación del proyecto (diseño inicial y su actualización)
├── db/              Scripts SQL, consultas de verificación, justificación de 3FN y diagramas (XML y PNG)
└── (raíz)           Código de la aplicación Qt: CMakeLists.txt, main.cpp, mainwindow.*, …
```
Contenido de `/db`: `iqual_sqlite.sql` (el que usa la app), `iqual_sqlserver.sql` (SQL Server 2005), `iqual_mysql.sql`, `consultas_verificacion.sql`, `justificacion_3FN.md` y los diagramas del Hito 1. Los tres scripts crean las mismas 44 tablas con los mismos nombres. Usuarios de demostración que carga el script de datos: `alumno1`, `alumno2`, `profe1`, `preceptor1` y `maestranza1`.

*Verificar la estructura real del repositorio antes de publicar.*

---

## 5. HITO 1 — Diagramas (XML y PNG)
Diagramas del Hito 1 de Bases de Datos. Se entregan como **XML editable de draw.io** y como **PNG con fondo blanco**; los PNG se exportan desde diagrams.net. Ambos formatos van en `/db`.

| Diagrama | Archivo XML editable | Archivo PNG (ruta propuesta) |
| :--- | :--- | :--- |
| **Peter Chen** (modelo conceptual) | `/db/Proyecto_IQUAL_Peter_Chen.xml` | `/db/peter-chen-modelo-conceptual.png` |
| **Edgar Codd** (modelo lógico, 3FN) | `/db/Proyecto_IQUAL_Edgar_Codd.xml` | `/db/edgar-codd-modelo-logico.png` |

> Pendiente: guardar los dos XML y exportar los dos PNG con esos nombres en `/db` (o ajustar las rutas de esta tabla si se guardan en otro lado).

---

## 6. Documentación y Antecedentes (Carpeta V1 - `/docs`)
Toda la documentación técnica de análisis, diagnóstico y maquetado desarrollada durante el **3er Bimestre**, actualizada en el 4° Bimestre, se encuentra organizada en [`/docs`](./docs):

* 📀 **[Defensa Oral](https://canva.link/ecw1bmcqn1ekxgu):** Diapositivas visuales para la defensa oral del tema (diseño inicial; lo que quedó desactualizado está en [`cambios-presentacion.md`](./docs/cambios-presentacion.md)).
* 📊 **[Matriz de Marco Lógico (MML)](./docs/marco-logico.xlsx):** Planificación sintética de jerarquía de objetivos, indicadores, medios de verificación y supuestos.
* 🛠️ **Maquetado Funcional y Usabilidad:**
  * 📐 **[Maquetado Funcional y Usabilidad](./docs/maquetado-y-usabilidad.xlsx):** Especificación de pantallas y aplicación de las 10 Heurísticas de Jakob Nielsen (cobertura completa de H1 a H10).
  * 🎨 **[Maquetado de Pantallas en Canva](https://canva.link/o7k6tqoyn125gn7):** Prototipo visual del diseño inicial de las pantallas (maquetas de celular).
* 📋 **[Especificación de Requerimientos](./docs/requerimientos.md):** Requerimientos Funcionales (RF01-RF18) y No Funcionales (RNF01-RNF04).
* 🟡 **[Historias de Usuario (Backlog)](./docs/historias-de-usuario.md):** US01 a US11 con sus respectivos Criterios de Aceptación (3 C de Agile).
* 🔗 **[Matriz de Trazabilidad](./docs/matriz-trazabilidad.md):** RF → historia → módulo → tablas → pantalla.
* 🔄 **[Cambios respecto al Diseño Inicial](./docs/cambios-respecto-al-diseno-inicial.md):** cada cambio, su motivo y el documento que afecta.
* 🧾 **[Cambios a hacer en la Presentación](./docs/cambios-presentacion.md):** corrección lámina por lámina.
* 🗓️ **[Bitácora de Trabajo](./docs/bitacora.md):** Registro de avances y decisiones semanales del equipo (Semanas 1 a 7).
* 🌳 **Diagnósticos Visuales:**
  * [Árbol de Problemas](./docs/arbol-de-problemas.png)
  * [Árbol de Objetivos](./docs/arbol-de-objetivos.drawio.xml) (editable en draw.io)

---

## 7. Limitaciones Conocidas
* La base de datos de la app es un archivo local: funciona en una sola PC (no hay multiusuario en red). Camino de evolución: un motor de servidor con el mismo modelo (motor a confirmar con el profesor de BBDD).
* Sin pagos reales: las reservas y donaciones del buffet se coordinan en persona.
* El cruce de horarios de Educación Física solo funciona para los cursos con horario cargado.
* Sin notificaciones en pantalla.
* El registro de auditoría se consulta solo desde la base de datos (sin pantalla).
* Para correr la app contra MySQL habría que compilar el driver `QMYSQL` o usar ODBC (el Qt 6 de Windows con MinGW no lo trae); se usa SQLite por defecto.

---

> **Nota de Créditos (3er Bimestre):** La fase de diagnóstico, investigación, MML, requerimientos y maquetados de la Carpeta V1 fue realizada durante el 3er Bimestre por el equipo original: Arce Thiago, Cabrera Ulises, Denuble Franco y González Manuel.
