# Cambios a hacer en la Presentación (Defensa Oral)
**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  

La presentación está hecha en Canva y no se puede editar desde acá, así que este documento lista, **lámina por lámina**, qué corregir para que coincida con la documentación actualizada. La revisión se hizo sobre el PDF exportado de 15 láminas y contra el repositorio (`docs/bitacora.md`, README y Excel).

* Prioridad **Alta**: la lámina contradice la aplicación o la documentación. **Media**: está incompleta o desactualizada. **Baja**: detalle de prolijidad.
* Los cambios de fondo y sus motivos están en [`cambios-respecto-al-diseno-inicial.md`](./cambios-respecto-al-diseno-inicial.md).

---

## 1. Inconsistencias transversales (corregir primero)

| # | Inconsistencia | Dónde | Qué hacer | Prioridad |
| :-: | :--- | :--- | :--- | :-: |
| 1 | **Pies de página con total distinto**: las láminas 5 y 12 dicen "05 / 14" y "12 / 14"; las otras 13 dicen "/ 15". La presentación tiene 15 láminas | Láminas 5 y 12 | Cambiar a "05 / 15" y "12 / 15". Además, el pie de la lámina 5 está corrido a la derecha y su texto "PROYECTO IQUAL" arranca más adentro que en las demás: alinearlo con el resto | Alta |
| 2 | **Nombre del archivo de la bitácora**: la lámina 14 muestra `bitacoras.md`; el archivo real del repositorio es `docs/bitacora.md` (así lo enlaza el README) | Lámina 14 | Escribir `bitacora.md` | Alta |
| 3 | **Cantidad de semanas**: la lámina 14 dice "Bitácora semanal (Sem. 1 a 8)" y muestra 8 cuadros; la bitácora del repositorio y el README tienen **semanas 1 a 7**. La "S8: Maquetado y Usabilidad, y Defensa Oral" no figura en la bitácora (el maquetado está en la Semana 6 y la Semana 7 cierra la Carpeta V1) | Lámina 14 | Dejar "Sem. 1 a 7" y quitar el cuadro S8, o agregar la Semana 8 a la bitácora (decisión del equipo; la bitácora no se toca desde esta documentación) | Alta |
| 4 | **Usuario de ejemplo "liomessi"**: es el nombre de una persona real conocida | Lámina 6 | Reemplazar por un usuario ficticio genérico, por ej. `alumno1` | Alta |
| 5 | **Íconos del Excel contra los de las maquetas**: el Excel describía íconos como un silbato (Educación Física) y un carro tecnológico (computadoras); las maquetas de la lámina 7 muestran un signo de pregunta, lavatorio/inodoro, cubiertos, engranaje con hoja, silla y mancuerna | Lámina 7 (y Excel) | La aplicación usa sus propios 6 PNG (`ico_objetos`, `ico_higiene`, `ico_buffet`, `ico_planillas`, `ico_sectores`, `ico_edfisica`). Reemplazar los íconos de la maqueta por los reales (capturas de la app final) | Alta |
| 6 | **Plataforma**: se habla de "plataforma web/móvil" y las maquetas tienen marco de celular; la app es de escritorio | Láminas 3, 4, 6 a 13 | Cambiar los textos a "aplicación de escritorio" y, para las pantallas, usar capturas de la app (o aclarar en voz alta que son las maquetas del diseño inicial) | Alta |
| 7 | **Nombres de módulo distintos**: "Higiene y baños" (láminas 7 y 9) contra "Higiene e Infraestructura" (lámina 3 y README); "Planillas computadoras" (lámina 11) contra "Planillas de taller" (láminas 3 y 7) | Láminas 7, 9 y 11 | Unificar con los nombres de la lámina 3: Objetos Perdidos, Higiene e Infraestructura, Buffet Paralelo, Planillas de Taller, Reserva de Sectores, Educación Física | Media |
| 8 | **Colores**: las láminas usan un color por módulo, semáforo verde/rojo, avisos naranja y rojo; la app usa solo 4 colores (`#102542`, `#1E3A8A`, `#F8FAFC` / `#FFFFFF`, `#1E293B`) y no usa naranja | Láminas 3, 8 a 13 | No hace falta recolorear la presentación, pero las capturas de la app tienen que mostrar la paleta real; no afirmar que "la app usa un color por módulo" | Baja |
| 9 | **Apellido del integrante**: "Gonzalez" (lámina 1), "González Manuel" (README), "MANUEL GONZALEZ" (bitácora) | Lámina 1 | Elegir una forma única (con tilde: "González") para presentación y README | Baja |

---

## 2. Lámina por lámina

### Lámina 1 · Portada
* Pie "01 / 15": correcto.
* Apellido "Gonzalez": ver inconsistencia 9.
* El marco de teléfono con el logo es la identidad de la presentación; si se reemplazan las capturas por las de la app de escritorio, considerar un marco de ventana.

### Lámina 2 · Diagnóstico de la Problemática Escolar
* Sin contradicciones con la documentación actual. El árbol de problemas no cambia.
* **Baja:** la nota del pivot dice que la temática se definió "por sorteo"; la bitácora (Semana 1) dice que fue por piedra, papel o tijera. Si se quiere, escribir "por piedra, papel o tijera" para que coincidan.

### Lámina 3 · Solución Propuesta y Visión del Sistema (Árbol de Objetivos)
* **Alta:** el objetivo general dice "plataforma web/móvil autogestionable" → "**aplicación de escritorio** autogestionable que unifique la administración de recursos y mejore la convivencia escolar".
* **Media:** si se muestra el árbol de objetivos, usar el nuevo ([`arbol-de-objetivos.drawio.xml`](./arbol-de-objetivos.drawio.xml)): el objetivo central ahora es "Organización operativa escolar eficiente".
* Los 6 módulos están bien; ver inconsistencias 7 y 8. Sumar una nota breve: "más Acceso con roles y Mi Cuenta".

### Lámina 4 · Metodología del Marco Lógico (MML)
* **Alta:** Propósito dice "Aplicación web/móvil autogestionable" → "aplicación de escritorio autogestionable".
* **Alta:** "Fuentes de verificación" dice "logs y reportes de uso del sistema" → "registros de la propia base de datos, incluido el log de auditoría" (no hay reportes automáticos).
* **Alta:** "Supuestos críticos" dice "estabilidad del servidor y la red escolar" → "disponibilidad de la PC donde se instala la app (base local, una sola PC)".
* **Media:** Actividades dice "diseño de base de datos local": correcto; agregar "SQLite en la app; modelo también en SQL Server y MySQL (motor final a confirmar)".
* Los indicadores (-40%, 85-90%, < 2 s) **no cambian**; en la defensa se puede aclarar la línea base de medición (está en el Excel del MML).

### Lámina 5 · Requerimientos e Historias de Usuario
* **Alta:** pie "05 / 14" → "05 / 15" (inconsistencia 1).
* **Alta:** "12 Requerimientos Funcionales (RF01-RF12)" → "**18** (RF01-RF18)".
* **Alta:** "6 Historias de Usuario (US01-US06)" → "**11** (US01-US11)".
* **Media:** "Seguridad (SQL / cifrado)" → "Seguridad (SHA-256 / consultas preparadas)"; "Rendimiento < 2s" puede quedar, aclarando "medido en una PC con la base de demostración".
* **Baja:** el ejemplo dice "reclamar mis pertenencias con prueba de titularidad": usar el mismo término que los documentos, "prueba de pertenencia".

### Lámina 6 · Pantalla 02 · Registro y Acceso
* **Alta:** usuario "liomessi" (inconsistencia 4).
* **Alta:** la maqueta muestra solo usuario, contraseña y un selector "Curso y división". Ahora hay: nombre y apellido, usuario, contraseña, DNI, correo, teléfono, rol, **PIN para Profesor, Preceptor y Maestranza**, y para Alumno **tres listas** (año, división y especialidad). Cambiar maqueta y texto ("más un selector obligatorio de curso y división" → "más tres selectores de curso: año, división y especialidad").
* **Media:** agregar que el acceso es con usuario y contraseña, que la contraseña se guarda con hash SHA-256 y que Enter confirma.
* "Crear Cuenta queda gris e inactivo hasta elegir curso": sigue valiendo, pero el texto debe decir "hasta completar los tres selectores de curso" (y solo para Alumno).

### Lámina 7 · Pantalla 03 · Dashboard Principal (Menú)
* **Alta:** íconos (inconsistencia 5).
* **Media:** "barra superior fija" → "encabezado con el menú hamburguesa (☰): Menú Principal, Mi Cuenta / Perfil y Cerrar Sesión". "Higiene y baños" y "Planillas de taller": ver inconsistencia 7.
* El texto "Cada módulo usa un ícono representativo" está bien; agregar "y la app funciona aunque falte alguna imagen (queda el texto)".

### Lámina 8 · Pantalla 04 · Objetos Perdidos
* **Alta:** "si toca un objeto por error, 'Cancelar Solicitud' lo devuelve atrás": **ya no existe esa función**. Reemplazar por el flujo real: el alumno reclama con una prueba de pertenencia (al menos 10 caracteres) → el reclamo queda "Pendiente" → el **Preceptor aprueba** (objeto "Devuelto") **o rechaza** (el objeto vuelve a "Disponible").
* **Media:** la maqueta muestra una grilla de fotos con botón "Reclamar" y un modal "Confirmar pertenencia" con Cancelar / Enviar. La app tiene tres pestañas: Objetos, Consultas y Publicar (solo Preceptor). Reemplazar por captura de la app.
* **Media:** el texto dice que el alumno reconoce sus pertenencias "por foto": la foto es opcional.

### Lámina 9 · Pantalla 05 · Higiene y Baños
* **Alta:** "tipo de falla: Sin jabón" → los tipos son **Rotura** y **Limpieza**; el detalle va en observaciones.
* **Alta:** la trazabilidad muestra "Última limpieza: hace 2 h / Encargado: P. Gomez" → la app muestra "**Último mantenimiento: dd/MM HH:mm — nombre**" (fecha y hora, no "hace cuánto"), y el dato aparece cuando alguien marca el reporte como resuelto.
* **Media:** "Baño PB" → "Baño planta baja". Agregar que reportan todos los roles y que marcan "Resuelto" Profesor, Preceptor y Maestranza (rol nuevo).
* Título: "Higiene e Infraestructura" (inconsistencia 7).

### Lámina 10 · Pantalla 06 · Buffet Paralelo
* **Alta:** la maqueta muestra fotos de las tortas y alfajores: la aplicación **no guarda fotos de productos**. Reemplazar por captura de la lista de productos con precio y stock.
* **Media:** la barra de progreso "71%" → meta, recaudado y porcentaje (verificar con la app final si se ve como texto o barra). Recaudado se calcula (donaciones + ventas no canceladas).
* **Media:** agregar los grupos con PIN, "Mis reservas" y donaciones (sin pagos reales). Publican productos los **alumnos** (ya no solo "último año").
* Texto: "La interfaz muestra únicamente producto, precio, stock disponible y el objetivo grupal" sigue valiendo.

### Lámina 11 · Pantalla 07 · Planillas computadoras
* **Alta:** "Máquina ya asignada en este bloque" y "Confirmar préstamo se bloquea… en ese bloque horario": el criterio ahora es el **estado del recurso**: si está "Prestado" no se ofrece ni puede volver a prestarse hasta devolverlo. Ya no hay "bloque horario".
* **Alta:** el texto dice "nombre, curso/división y profesor de taller" escritos a mano → se elige el **recurso** (carro + número, ej. "C4-05") y el **alumno** de una lista; curso y división salen del alumno; el autorizador es el usuario con sesión iniciada (Profesor o Preceptor).
* **Media:** el título "Planillas computadoras" omite los **tableros de dibujo** → "Planillas de Taller (computadoras y tableros)". Agregar la devolución con "Funciona / No funciona" y el filtro por código.
* **Media:** la maqueta solo muestra Carro C4 y C5; el catálogo de la app admite C1 a C5 (confirmar con la escuela qué carros hay).

### Lámina 12 · Pantalla 08 · Reserva de Sectores
* **Alta:** pie "12 / 14" → "12 / 15" (inconsistencia 1).
* **Alta:** "Calendario mensual con celdas verdes (libre) y rojas (ocupado)" → "**selector de fecha con calendario desplegable** y **lista de la ocupación del día** para el sector", sin colores de semáforo. Reemplazar la maqueta por captura de la app.
* **Alta:** agregar la aprobación: la reserva de un Profesor queda "Pendiente" y la **aprueba o rechaza el Preceptor**; la de un Preceptor queda "Aprobada".
* **Media:** el mensaje de ejemplo "Ocupado: Prof. Díaz, 14 a 16 h" va en la línea correcta (nombra quién y el horario); usar el texto exacto de la app final. El aviso está en color naranja y la paleta de la app no lo incluye.
* **Media:** "modal para solicitar" → pantalla con hora de inicio y fin. Solo reservan Profesor y Preceptor.

### Lámina 13 · Pantalla 09 · Educación Física
* **Alta:** la maqueta muestra botones "Deporte (Vóley / Fútbol / Básquet)" y "Día y turno (Miércoles / Tarde)" + "Confirmar horario". La app muestra una **lista de ofertas** (deporte + día + franja horaria, con cupos usados/máximos); hay 4 deportes (Fútbol, Vóley, Básquet y Handball). La acción es "Inscribirse".
* **Alta:** "bloquea de entrada las opciones que se superpongan": ahora se muestran con la leyenda "se superpone con <materia>" y no se pueden elegir. Agregar cupos, una inscripción por alumno y que el cruce solo funciona para cursos con horario cargado.
* Texto "Selector interactivo de deportes, días y turnos" → "lista de ofertas con cupos".

### Lámina 14 · Repositorio GitHub y Bitácora de Trabajo
* **Alta:** `bitacoras.md` → `bitacora.md` (inconsistencia 2).
* **Alta:** "Bitácora semanal (Sem. 1 a 8)" y cuadro S8 (inconsistencia 3).
* **Alta:** la lista de archivos de `/docs` está desactualizada: `arbol-de-objetivos.png` pasa a **`arbol-de-objetivos.drawio.xml`**; agregar `cambios-respecto-al-diseno-inicial.md`, `matriz-trazabilidad.md` y `cambios-presentacion.md`, y la carpeta `/db`.
* **Media:** la lista no incluye `README.md` junto a `/docs`: sí figura, pero sin la carpeta `/db`. Estructura actual: `README.md`, `/docs`, `/db` y el código de la app.
* **Baja:** los títulos de las semanas de la lámina (S3 "Árbol Problemas en Miro", S4 "Árbol Objetivos e inicio MML") resumen la bitácora; si se quiere fidelidad, usar los títulos de `docs/bitacora.md`.

### Lámina 15 · Cierre (logo)
* Pie "15 / 15": correcto. Sin cambios.
