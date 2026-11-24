# Cambios a hacer en la Presentación (Defensa Oral)
**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  

La presentación está hecha en Canva y no se puede editar desde acá, así que este documento lista, **lámina por lámina**, qué corregir para que coincida con la documentación y con la aplicación actual (**app v3**, `iqual_integrado_v3`: rediseño con barra lateral y dos temas, MySQL, 47 tablas). La revisión se hizo sobre el PDF exportado de 15 láminas. **Reemplaza** a la versión anterior de este archivo: sigue valiendo lo que no cambió y se actualizó lo que la app modificó desde entonces (motor de base de datos, nombres de módulos, colores, fotos de productos, Higiene, Sectores y Educación Física) más lo de la semana del 12 al 13/11 (ver la sección 4).

* Prioridad **Alta**: la lámina contradice la aplicación o la documentación. **Media**: está incompleta o desactualizada. **Baja**: detalle de prolijidad.
* Los cambios de fondo y sus motivos están en [`cambios-respecto-al-diseno-inicial.md`](./cambios-respecto-al-diseno-inicial.md).
* **Capturas:** las que se pongan en la presentación tienen que salir de la app final (`capturas/` del proyecto tiene las de Higiene, Sectores y Mi cuenta, en claro y oscuro; las demás hay que sacarlas). `[COMPLETAR: capturas de Objetos, Tienda, Préstamo de equipos, Educación Física, Acceso e Inicio]`

---

## 1. Inconsistencias transversales (corregir primero)

| # | Inconsistencia | Dónde | Qué hacer | Prioridad |
| :-: | :--- | :--- | :--- | :-: |
| 1 | **Pies de página con total distinto**: las láminas 5 y 12 dicen "05 / 14" y "12 / 14"; las otras 13 dicen "/ 15" | Láminas 5 y 12 | Cambiar a "05 / 15" y "12 / 15". El pie de la lámina 5 además está corrido a la derecha: alinearlo con el resto | Alta |
| 2 | **Nombre del archivo de la bitácora**: la lámina 14 muestra `bitacoras.md`; el archivo real es `docs/bitacora.md` | Lámina 14 | Escribir `bitacora.md` | Alta |
| 3 | **Cantidad de semanas**: la lámina 14 dice "Bitácora semanal (Sem. 1 a 8)" y muestra 8 cuadros; el repositorio tiene las semanas 1 a 7 y el borrador de la bitácora agrega entradas por hito | Lámina 14 | Dejar el número de semanas que tenga la bitácora publicada. `[COMPLETAR: decisión del equipo: sumar la semana 8 a la bitácora o quitar el cuadro S8]` | Alta |
| 4 | **Usuario de ejemplo "liomessi"**: es el nombre de una persona real conocida | Lámina 6 | Usar un usuario ficticio, como `alumno1` | Alta |
| 5 | **Íconos**: la maqueta muestra íconos que no son los de la app. La app usa íconos propios (dibujados en SVG y exportados a PNG para el tema claro y el oscuro) | Lámina 7 | Reemplazar por capturas del Inicio de la app | Alta |
| 6 | **Plataforma**: se habla de "plataforma web/móvil" y las maquetas tienen marco de celular; la app es de **escritorio** | Láminas 3, 4, 6 a 13 | Cambiar los textos a "aplicación de escritorio" y usar capturas de la app (o aclarar que son las maquetas del diseño inicial) | Alta |
| 7 | **Motor de base de datos**: las láminas hablan de una base local; la app **se conecta a MySQL** (sin base de respaldo) y el modelo tiene **47 tablas** | Láminas 4 y 5 (y donde se mencione la base) | Escribir "MySQL (47 tablas; también el modelo para SQL Server 2005)". Si dice "44 tablas", cambiar a 47. `[COMPLETAR: confirmación del profesor sobre el motor]` | Alta |
| 8 | **Nombres de módulo distintos** entre láminas y app. Los nombres actuales de la app son: **Objetos Perdidos, Higiene y Mantenimiento, Tienda de alumnos, Préstamo de equipos, Reserva de Sectores, Educación Física** | Láminas 3, 7, 9, 10 y 11 | Unificar con esos nombres (se puede aclarar "Tienda de alumnos (antes Buffet Paralelo)" y "Préstamo de equipos (antes Planillas de Taller)") | Media |
| 9 | **Colores y temas**: las láminas dicen que la app usa una paleta de 4 colores. Esa regla no existe: la app tiene **dos temas (claro y oscuro)** con el azul marino del splash y el celeste del logo, y usa verde y rojo en las listas para marcar estados (siempre con el estado escrito) | Láminas 3, 8 a 13 | Mostrar capturas de los dos temas y no afirmar que "la app usa solo 4 colores" | Media |
| 10 | **Navegación**: se menciona un menú hamburguesa (☰) y un botón "Volver" en cada módulo. La app tiene una **barra lateral** con un ítem por módulo, una barra superior con el título, el usuario y el botón de tema | Láminas 3, 7 a 13 | Reemplazar por capturas y decir "barra lateral de navegación" | Media |
| 11 | **Apellido del integrante**: "Gonzalez" (lámina 1), "González Manuel" (README), "MANUEL GONZALEZ" (bitácora) | Lámina 1 | Elegir una forma única (con tilde: "González") | Baja |

---

## 2. Lámina por lámina

### Lámina 1 · Portada
* Pie "01 / 15": correcto.
* Apellido: ver inconsistencia 11.
* El marco de teléfono con el logo es la identidad de la presentación; si se reemplazan las capturas por las de la app de escritorio, considerar un marco de ventana.

### Lámina 2 · Diagnóstico de la Problemática Escolar
* Sin contradicciones. El árbol de problemas no cambia.
* **Baja:** la nota del pivot dice que la temática se definió "por sorteo"; la bitácora (Semana 1) dice que fue por piedra, papel o tijera. Escribir "por piedra, papel o tijera" para que coincidan.

### Lámina 3 · Solución Propuesta y Visión del Sistema (Árbol de Objetivos)
* **Alta:** el objetivo general dice "plataforma web/móvil autogestionable" → "**aplicación de escritorio** autogestionable que unifique la administración de recursos y mejore la convivencia escolar".
* **Media:** si se muestra el árbol de objetivos, usar el nuevo ([`arbol-de-objetivos.drawio.xml`](./arbol-de-objetivos.drawio.xml)): el objetivo central ahora es "Organización operativa escolar eficiente".
* Los 6 módulos están bien; ver inconsistencias 8 y 9. Sumar una nota breve: "más Acceso con roles, Inicio con resumen y Mi Cuenta".

### Lámina 4 · Metodología del Marco Lógico (MML)
* **Alta:** Propósito dice "Aplicación web/móvil autogestionable" → "aplicación de escritorio autogestionable".
* **Alta:** "Fuentes de verificación" dice "logs y reportes de uso del sistema" → "registros de la propia base de datos, incluido el log de auditoría (14 tipos de evento)". No hay reportes automáticos.
* **Alta:** "Supuestos críticos" dice "estabilidad del servidor y la red escolar" → "disponibilidad de la PC donde corre la base MySQL; si no está disponible, la app trabaja con una base local (un solo puesto)".
* **Media:** Actividades: "diseño de base de datos" → "base de datos de 47 tablas en 3FN, en MySQL (con el modelo también para SQL Server 2005)".
* Los indicadores (-40%, 85-90%, < 2 s) **no cambian**; en la defensa se puede aclarar la línea base de medición (está en el Excel del MML).

### Lámina 5 · Requerimientos e Historias de Usuario
* **Alta:** pie "05 / 14" → "05 / 15".
* **Alta:** "12 Requerimientos Funcionales (RF01-RF12)" → "**23** (RF01-RF23)" y "4 no funcionales (RNF01-RNF04)".
* **Alta:** "6 Historias de Usuario (US01-US06)" → "**13** (US01-US13)". `[COMPLETAR: confirmar estas cantidades cuando se actualicen requerimientos.md e historias-de-usuario.md al motor MySQL]`
* **Media:** "Seguridad (SQL / cifrado)" → "Seguridad (SHA-256 / consultas preparadas)"; "Rendimiento < 2s" puede quedar, aclarando "medido en una PC con la base de demostración".
* **Baja:** usar el mismo término que los documentos, "prueba de pertenencia".

### Lámina 6 · Pantalla 02 · Registro y Acceso
* **Alta:** usuario "liomessi" (inconsistencia 4).
* **Alta:** la maqueta muestra solo usuario, contraseña y "Curso y división". Ahora hay: nombre y apellido, usuario, contraseña, DNI, correo, teléfono, rol, **PIN institucional para Profesor, Preceptor y Maestranza**, y para Alumno **tres listas** (año, división y especialidad). El registro y el inicio de sesión están en **una tarjeta con dos pestañas**.
* **Media:** agregar que el acceso es con usuario y contraseña, que la contraseña se guarda con hash SHA-256, que Enter confirma y que **5 intentos fallidos bloquean** el acceso hasta reabrir la app.
* "Crear cuenta queda gris hasta elegir curso": sigue valiendo, pero el texto debe decir "hasta completar los tres selectores de curso" (solo para Alumno).

### Lámina 7 · Pantalla 03 · Dashboard Principal (Menú)
* **Alta:** íconos y navegación (inconsistencias 5 y 10).
* **Media:** el Inicio ahora tiene **"Tu resumen"** (tarjetas con números que dependen del rol y se actualizan cada vez que se vuelve al Inicio) y **"Módulos"** (seis tarjetas con ícono). Cambiar "barra superior fija" y "menú hamburguesa" por la barra lateral.
* **Media:** nombres de módulo (inconsistencia 8).

### Lámina 8 · Pantalla 04 · Objetos Perdidos
* **Alta:** "si toca un objeto por error, 'Cancelar Solicitud' lo devuelve atrás": **ya no existe esa función**. Flujo real: el alumno reclama con una prueba de pertenencia (al menos 10 caracteres) → el reclamo queda "Pendiente" → el **Preceptor compara con el dato reservado del objeto y aprueba** (objeto "Devuelto") **o rechaza** (el objeto vuelve a "Disponible").
* **Media:** la app tiene cinco pestañas: Objetos, Reclamos (solo Preceptor), Consultas, Publicar (solo Preceptor) y Auditoría (solo Preceptor). Los objetos devueltos se ven en gris con "Ya devuelto". Reemplazar la maqueta por una captura.
* **Media:** la foto es opcional (si no hay, se muestra una miniatura sin foto). Doble clic en un objeto abre su detalle.

### Lámina 9 · Pantalla 05 · Higiene
* **Alta:** "tipo de falla: Sin jabón" → los tipos son **Rotura** y **Limpieza**; el detalle va en "¿Qué pasó?" (hasta 200 caracteres).
* **Alta:** la trazabilidad dice "Última limpieza: hace 2 h / Encargado: P. Gomez" → la app muestra "**Último mantenimiento: dd/MM HH:mm — nombre**" (fecha y hora, no "hace cuánto"), o "Todavía no hay ninguno". El dato aparece cuando alguien marca un reporte como resuelto.
* **Media:** "Baño PB" → "Baño planta baja". Reportan todos los roles; marcan "Resuelto" Profesor, Preceptor y Maestranza. Los pendientes salen primero y en rojo, los resueltos en verde (el texto siempre dice el estado), y hay un contador de pendientes y un filtro Todos / Pendientes / Resueltos.
* Título: "Higiene y Mantenimiento" (inconsistencia 8). Captura disponible: `capturas/preceptor_c_p4.png`.

### Lámina 10 · Pantalla 06 · Tienda de alumnos
* **Media:** la maqueta con fotos de tortas y alfajores **ahora se parece a la app**: los productos pueden tener **foto opcional** (con miniatura y vista en grande al hacer doble clic). Actualizar la afirmación anterior de que "la app no guarda fotos de productos": sí las guarda.
* **Alta:** "Recaudado" = donaciones + ventas **Entregadas** (las reservas todavía no entregadas no cuentan). Corregir si la lámina dice "ventas no canceladas".
* **Media:** agregar las pestañas actuales: Productos, Publicar, Grupos y donaciones (con PIN), Mis reservas, Mis ventas y Mis productos (reponer y quitar stock). Publican productos los **alumnos**. Sin pagos reales.

### Lámina 11 · Pantalla 07 · Préstamo de equipos
* **Alta:** "Máquina ya asignada en este bloque": el criterio es el **estado del equipo**: uno "Prestado" no se ofrece ni puede volver a prestarse hasta devolverlo. Ya no hay "bloque horario".
* **Alta:** el texto dice "nombre, curso/división y profesor de taller" escritos a mano → se elige el **equipo** (por ejemplo "C4-05") y el **alumno**; el autorizador es el usuario con sesión iniciada. Un alumno puede tener un solo préstamo activo y solo ve los suyos.
* **Media:** el título "Planillas computadoras" omite los **tableros de dibujo** → "Préstamo de equipos (computadoras y tableros)". Agregar: programas instalados en cada equipo, devolución con "Funciona / No funciona", lista de equipos fuera de servicio y "Marcar reparado" (Preceptor y Maestranza).
* **Media:** la maqueta solo muestra los carros C4 y C5; el catálogo de la app admite C1 a C5 (confirmar con la escuela qué carros hay). `[COMPLETAR: carros reales del colegio]`

### Lámina 12 · Pantalla 08 · Reserva de Sectores
* **Alta:** pie "12 / 14" → "12 / 15".
* **Alta:** "Calendario mensual con celdas verdes (libre) y rojas (ocupado)" → "**selector de fecha con calendario desplegable** y **lista de la ocupación del día** para el sector". La lista marca los horarios ocupados en rojo y el día libre en verde (con texto), pero no hay calendario mensual con celdas de colores. Captura disponible: `capturas/preceptor_c_p7.png`.
* **Alta:** agregar la aprobación: la reserva de un Profesor queda "Pendiente de aprobación" y la **aprueba o rechaza el Preceptor**; la de un Preceptor queda "Aprobada". Cancelar y rechazar piden confirmación (Sí / No).
* **Media:** el mensaje de ejemplo "Ocupado: Prof. Díaz, 14 a 16 h" va en la línea correcta; usar el texto exacto de la app: "Ese horario está ocupado: <nombre> tiene el sector de 10:00 a 11:00. Probá con otro."
* **Media:** "modal para solicitar" → una tarjeta con lugar, día, hora de inicio y fin (los selectores de hora van de 07:00 a 19:00). Solo reservan Profesor y Preceptor; el Alumno y la Maestranza solo consultan la ocupación.

### Lámina 13 · Pantalla 09 · Educación Física
* **Alta:** la maqueta muestra botones "Deporte" y "Día y turno" + "Confirmar horario". La app pide **deporte, día y hora** y tiene "Inscribirme" y "Cancelar inscripción"; hay 4 deportes (Fútbol, Vóley, Básquet y Handball).
* **Alta:** "bloquea de entrada las opciones que se superpongan": los días sin clase o que chocan se muestran en gris con una leyenda ("sin clase", "choca con <materia>") y no se pueden elegir; "Inscribirme" solo se habilita si hay cupo y no hay choque, y una franja de estado explica el motivo. Una inscripción por alumno. El cruce solo funciona para los cursos con horario cargado.
* Si un alumno cambia de curso desde Mi cuenta y su inscripción choca con el horario nuevo, la app pregunta y, si confirma, la cancela; si responde "No", el selector de curso vuelve al curso anterior.
* **Actualización v3:** un día sin clase o que choca con todas las horas se muestra en gris como "(sin clase)" o "(choca con tu horario)"; las horas, como "(sin clase)" o "(choca con <materia>)". Cambiar el texto de la lámina si dice solo "choca con <materia>" para los días.

### Lámina 14 · Repositorio GitHub y Bitácora de Trabajo
* **Alta:** `bitacoras.md` → `bitacora.md` (inconsistencia 2) y el número de semanas (inconsistencia 3).
* **Alta:** la lista de archivos de `/docs` está desactualizada: `arbol-de-objetivos.png` pasa a **`arbol-de-objetivos.drawio.xml`**; agregar `cambios-respecto-al-diseno-inicial.md`, `matriz-trazabilidad.md`, `cambios-presentacion.md` y las carpetas `casos_de_prueba/`, `errores/` y `manuales/`; y la carpeta `/db` (scripts de MySQL y SQL Server, 3FN, consultas, guías y diagramas).
* **Media:** estructura actual: `README.md`, `/docs`, `/db` y el código de la app en la raíz.
* **Baja:** los títulos de las semanas de la lámina resumen la bitácora; si se quiere fidelidad, usar los de `docs/bitacora.md`.

### Lámina 15 · Cierre (logo)
* Pie "15 / 15": correcto. Sin cambios.

---

## 3. Qué cambió en la semana del 12 al 13/11 y cómo afecta a la presentación
Solo hechos del archivo de contexto interno (§19 y §20); las fechas y horas reales que no figuran quedan como `[COMPLETAR]`.
| # | Qué cambió | Láminas afectadas | Qué hacer |
| :-: | :--- | :--- | :--- |
| 1 | **MySQL como motor** (la app se conecta a MySQL con `iqual.ini` y, si falla, avisa el motivo y no abre; base ejecutada en MariaDB 10.11; falta MySQL 8 de Oracle, SQL Server 2005 y Windows) | 4, 5 y donde se mencione la base | Escribir "MySQL" y no afirmar que está probado en Windows. `[COMPLETAR: confirmación del profesor Linares sobre el motor]` |
| 2 | **Revisión de código** aplicada: sin comentarios, ternarios, `continue` ni `findData`; `.arg` encadenados | Lámina de calidad (opcional, sección 4) | Si se muestra, decir "cumple las reglas de la profesora" solo para estas reglas |
| 3 | **App v3**: las pruebas automáticas internas con el motor de respaldo ya no existen; hoy hay casos por pantalla (337) y 106 casos de procedimientos almacenados con resultado PASS en MariaDB 10.11 | Lámina de calidad (opcional) | No presentar los casos por pantalla como "ejecutados": todavía no se corrieron. Sí se pueden mencionar los 106 casos de la base |
| 4 | **Objetos:** al publicar, Categoría y Sector vuelven a "Elegí una categoría / un sector"; las Consultas muestran la fecha como `dd/MM` | 8 | Usar una captura de la v3 |
| 5 | **Mi cuenta:** "Ese ya es tu curso." si se elige el mismo curso; el selector vuelve atrás si se dice "No" al choque | (sin lámina propia) | Mencionarlo solo si se explica Mi Cuenta |
| 6 | **Higiene:** el texto de ayuda de las observaciones es "Contá qué pasa (ej: falta papel)" | 9 | Usar una captura de la v3 |
| 7 | **Préstamo de equipos:** el Alumno ve solo sus préstamos | 11 | Ya figura en esta lista (lámina 11) |
| 8 | **Educación Física:** días en gris "(choca con tu horario)" / "(sin clase)" | 13 | Ver la actualización de la lámina 13 |
| 9 | El **splash** no se toca (decisión) | — | Sin cambios |

## 4. Qué se podría agregar (opcional)
* **Una lámina de base de datos:** 47 tablas en 3FN, diagramas de Chen y Codd, y MySQL con las consultas de la defensa (`db/consultas_demo.sql`).
* **Una lámina de calidad:** casos de prueba por pantalla (escritos, sin ejecutar), errores encontrados con su estado (Corregido / Abierto / Decisión), la revisión de código contra las reglas de la profesora y el manual de usuario por rol. `[COMPLETAR: cantidad de casos ejecutados y resultados, cuando el equipo los ejecute]`

## Desvíos
* No vi el PDF ni el Canva de la presentación: la lista parte de la versión anterior de este documento (hecha sobre el PDF de 15 láminas) y la actualiza contra la app v3 y los documentos actuales. Las láminas con algún cambio son 4, 5, 7, 8, 9, 10, 11, 12, 13 y 14.
* Las fechas y horas reales del trabajo del 12 y 13/11 no están en el contexto: quedan `[COMPLETAR]`.
* No hay en los archivos recibidos un texto de la presentación nuevo: este archivo no decide cuántas láminas lleva la versión final.
* Las cantidades de la lámina 5 (23 RF, 13 historias) las tomé de los documentos de `docs/`, que todavía se están poniendo al día.

## Datos que faltan
* Capturas de la app final de las pantallas que no tienen (ver el recuadro de capturas de arriba).
* Respuesta del profesor sobre el motor de base de datos y carros reales del colegio.
* Decisión del equipo sobre la semana 8 de la bitácora.
