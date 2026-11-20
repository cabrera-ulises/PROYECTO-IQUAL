# Manual de usuario — Higiene, Reserva de sectores y Mi cuenta

**PROYECTO IQUAL® (Sistema de Gestión Escolar)**

*Versión de la ronda final: reemplaza a `MANUAL_USUARIO_HIGIENE_SECTORES_CUENTA.md` anterior y describe la aplicación v3 (`iqual_integrado_v3`).*

*Ronda de cierre (19/11/2026): revisado contra los datos nuevos de MySQL. Las instrucciones no cambian; se ajustaron las listas de ejemplo para que valgan con cualquier cantidad de lugares y de reservas.*

*Ronda sin SQLite (19/11/2026): la aplicación usa solo MySQL. Este manual no mencionaba SQLite y las instrucciones no cambian; solo se ajustó la nota sobre las capturas (sección «Datos que faltan»).*

> Esta sección explica tres pantallas de la aplicación. Cada punto dice quién puede hacerlo y cómo, paso a paso. Donde ves **[CAPTURA: capturas/nombre.png]** ya existe la imagen en la carpeta `capturas/` del proyecto; donde ves **[CAPTURA: nombre]** (sin carpeta) hay que sacarla a mano con la aplicación abierta y guardarla con ese nombre.

## Antes de empezar
- Entrás con tu **usuario y contraseña**. Con tu rol (Alumno, Profesor, Preceptor o Maestranza) la aplicación te muestra solo lo que podés hacer.
- A la izquierda tenés el **menú**: Inicio, Objetos perdidos, **Higiene**, Tienda de alumnos, Préstamo de equipos, **Reserva de sectores**, Educación Física (solo si sos Alumno), **Mi cuenta** y Cerrar sesión. Arriba a la derecha ves tu nombre y tu rol, y el botón para cambiar entre **tema claro y tema oscuro**.
- Cuando algo no se puede hacer, la aplicación abre una ventana **"Atención"** que dice qué falta o qué corregir. Leela: casi siempre te dice cómo seguir. Cuando algo sale bien, la ventana se llama **"Listo"**.
- Cuando una acción no se puede deshacer, la aplicación te hace una **pregunta** con los botones **Sí** y **No** (el que está marcado de entrada es **No**, para que no confirmes sin querer).
- Si escribís mal tu contraseña **5 veces** al ingresar, la aplicación se bloquea hasta que la cierres y la vuelvas a abrir.

**[CAPTURA: menu_lateral_y_barra_superior]**

## Las tarjetas de resumen del Inicio
Al entrar a **Inicio** ves tres tarjetas con números que dependen de tu rol. **Se actualizan cada vez que volvés al Inicio**, sin tener que cerrar sesión.
| Rol | Tarjetas que tienen que ver con estas pantallas |
|---|---|
| Alumno | No tiene tarjetas de Higiene ni de Sectores |
| Profesor | **Tus reservas de sectores** (las tuyas que están pendientes o aprobadas, de hoy en adelante) y **Reportes de higiene pendientes** |
| Preceptor | **Reservas de sectores pendientes** (de hoy en adelante, de todos los que reservaron) y **Reportes de higiene pendientes** |
| Maestranza | **Reportes de higiene pendientes** |

---

# 1. Higiene y mantenimiento
Sirve para **avisar que algo está roto o sucio** en el colegio (un baño sin papel, una silla rota) y para que el personal marque cuándo lo resolvió.

**[CAPTURA: capturas/preceptor_c_p4.png]** (vista de Preceptor, tema claro)
**[CAPTURA: capturas/alumno_c_p4.png]** (vista de Alumno: sin el botón Marcar resuelto)

## Qué ves en la pantalla
- **A la izquierda:** la lista de **Reportes**, con el filtro **Ver:** (Todos, Pendientes, Resueltos) y una franja que dice cuántos reportes están pendientes.
- **A la derecha:** el formulario **Reportar un problema** (¿Dónde?, ¿Qué tipo de problema?, ¿Qué pasó?) y, justo debajo del selector de sector, el **Último mantenimiento** de ese lugar.
- Cada reporte muestra tres líneas: primero su estado, el sector y el tipo; después la fecha, la hora y quién lo reportó; y al final lo que escribieron.
- **Colores:** los reportes **Pendientes** aparecen en **rojo** y los **Resueltos** en **verde**. Además siempre dice la palabra "Pendiente" o "Resuelto", así que se entiende aunque no distingas los colores. Los pendientes van siempre primero.

## Si sos Alumno, Profesor, Preceptor o Maestranza: cómo reportar un problema
1. Entrá a **Higiene** desde el menú.
2. En **¿Dónde?** elegí el lugar (por ejemplo, "Baño planta baja").
3. En **¿Qué tipo de problema?** elegí **Rotura** o **Limpieza**.
4. En **¿Qué pasó?** escribí en pocas palabras qué pasa (por ejemplo, "Falta papel").
5. Hacé clic en **Reportar** (o apretá **Enter**).
6. Aparece el aviso **"Reporte enviado. Gracias por avisar."** Tu reporte queda arriba de la lista, en rojo, como **Pendiente**.

**[CAPTURA: higiene_reportar_formulario_completo]**
**[CAPTURA: higiene_reporte_enviado]**

> **Importante:** el campo **¿Qué pasó?** es obligatorio. Si lo dejás vacío aparece **"Contanos qué pasa para poder resolverlo."** y no se envía nada. Podés escribir hasta **200 caracteres**: el campo no deja escribir más, así que si tu mensaje es largo, resumilo.

## Cómo ver cuándo se arregló algo por última vez
1. En **¿Dónde?** elegí el sector.
2. Mirá el recuadro **Último mantenimiento**: dice la fecha, la hora y el nombre de quien lo resolvió (por ejemplo, "20/10 08:45 — Maestranza Uno"). Si todavía nadie resolvió un reporte de ese sector, dice **"Todavía no hay ninguno"**.

## Cómo filtrar la lista
Arriba de la lista, en **Ver:**, elegí:
- **Todos:** los pendientes y los resueltos más recientes.
- **Pendientes:** solo lo que falta resolver.
- **Resueltos:** solo lo ya resuelto.

La lista muestra como máximo los **20 reportes resueltos más recientes**; los pendientes se muestran siempre todos.

## Si sos Profesor, Preceptor o Maestranza: cómo marcar un reporte como resuelto
1. Entrá a **Higiene**.
2. En la lista, hacé clic en el reporte que ya se solucionó (tiene que estar **Pendiente**).
3. Hacé clic en **Marcar resuelto**.
4. El reporte pasa a verde como **Resuelto** y queda guardado quién lo resolvió y cuándo. La franja de pendientes baja en uno.

**[CAPTURA: higiene_marcar_resuelto_seleccion]**

Avisos que podés ver:
- **"Elegí un reporte de la lista."** → te faltó hacer clic en un reporte.
- **"Ese reporte ya está resuelto."** → elegiste uno que ya estaba resuelto.

> Los Alumnos no ven el botón **Marcar resuelto**: solo pueden reportar y mirar.

## Cuando la lista está vacía
- Sin pendientes: **"No hay reportes pendientes."**
- Sin resueltos: **"Todavía no hay reportes resueltos."**
- Sin ningún reporte: **"Todavía no hay reportes. Si ves algo roto o sucio, avisanos desde el formulario."**

---

# 2. Reserva de sectores
Sirve para **reservar** un lugar del colegio (por ejemplo, la Biblioteca, el Laboratorio de química o el SUM; la lista **Lugar** muestra todos los que se pueden reservar) en un día y horario, sin chocar con otras reservas. Solo los **Profesores y Preceptores** pueden reservar; el resto puede consultar cuándo está ocupado.

**[CAPTURA: capturas/preceptor_c_p7.png]** (vista de Preceptor, tema claro)

## Reglas que tenés que conocer
- Solo se reservan los sectores que figuran en la lista **Lugar** (los demás, como el Patio o los baños, no se reservan).
- El horario va de **07:00 a 19:00**. Los selectores de hora no te dejan salir de ese rango.
- No se puede reservar un día que ya pasó, ni un horario de hoy que ya empezó.
- La hora de **fin** tiene que ser **posterior** a la de inicio.
- Dos reservas **no pueden superponerse** en el mismo sector y día. Una reserva **pendiente** también ocupa el horario. Si una termina a las 11:00, otra puede empezar a las 11:00.

## Qué ves en la pantalla
- **Lugar y día** (arriba a la izquierda): elegís el lugar y el día en un calendario, y los horarios **Desde** y **Hasta**.
- **Ocupación** (abajo a la izquierda): quién ocupa ese lugar ese día y en qué horario. Los horarios ocupados salen en **rojo**; si el día está libre, dice **"Sin reservas ese día: el sector está libre."** en verde. Si hay reservas esperando aprobación, arriba aparece **"Atención: …reservas pendientes de aprobación ese día."**
- **Reservas próximas** (a la derecha): tus reservas (el Preceptor ve las de todos, con las pendientes primero; las canceladas no figuran). El estado puede ser **Pendiente de aprobación** (gris), **Aprobada** (verde) o **Rechazada** (rojo).

## Si sos Profesor: cómo reservar un sector
1. Entrá a **Reserva de sectores**.
2. En **Lugar** elegí el sector que querés reservar (por ejemplo, Biblioteca). La lista está en orden alfabético.
3. En **Día** hacé clic y elegí la fecha en el calendario.
4. Mirá la **Ocupación**: así sabés si el horario que querés está libre.
5. Elegí **Desde** y **Hasta**.
6. Hacé clic en **Reservar**.
7. Aparece **"Reserva enviada. Queda pendiente hasta que un preceptor la apruebe."** Tu reserva figura en **Reservas próximas** como **Pendiente de aprobación**, y el número de **Tus reservas de sectores** del Inicio sube en uno.
8. Más tarde, volvé a entrar a la pantalla: si el Preceptor la aprobó, pasa a **Aprobada**; si no, a **Rechazada**. La aplicación **no te avisa** sola: tenés que mirar la lista.

**[CAPTURA: sectores_reservar_profesor]**
**[CAPTURA: sectores_reserva_pendiente_en_lista]**

Si el horario ya está ocupado, el aviso te dice quién lo tiene: **"Ese horario está ocupado: <nombre> tiene el sector de 10:00 a 11:00. Probá con otro."**

## Si sos Profesor o Preceptor: cómo cancelar una reserva
1. En **Reservas próximas**, hacé clic en la reserva.
2. Hacé clic en **Cancelar reserva**.
3. La aplicación pregunta: **"¿Querés cancelar la reserva de …? El horario queda libre para otros."** Elegí **Sí** para cancelar o **No** para dejarla como está.
4. Si elegiste **Sí**, la reserva desaparece de la lista y el horario queda libre.

El Profesor solo puede cancelar **sus** reservas; el Preceptor puede cancelar cualquiera.

**[CAPTURA: sectores_confirmar_cancelacion]**

## Si sos Preceptor: cómo reservar
Es igual que para el Profesor, con una diferencia: tu reserva queda **Aprobada** de inmediato (aparece **"Reserva aprobada."**), porque vos sos quien aprueba.

## Si sos Preceptor: cómo aprobar o rechazar reservas
1. En **Reservas próximas** las **pendientes** aparecen primero, en gris.
2. Hacé clic en la reserva que querés resolver.
3. Para aceptarla, **Aprobar**. Pasa a **Aprobada** (verde).
4. Para no aceptarla, **Rechazar**. La aplicación pregunta **"¿Querés rechazar la reserva de …? El horario queda libre."** Elegí **Sí** o **No**. Con **Sí** pasa a **Rechazada** (rojo) y el horario queda libre.

**[CAPTURA: sectores_aprobar_rechazar_preceptor]**

Avisos posibles:
- **"Elegí una reserva de la lista."** → no seleccionaste ninguna.
- **"Solo se pueden aprobar o rechazar reservas pendientes."** → esa reserva ya estaba resuelta.
- **"Esa reserva ya está rechazada o cancelada."** → no se puede cancelar de nuevo.

## Si sos Alumno o Maestranza: cómo consultar la ocupación
Tu pantalla muestra una franja que dice **"Solo profesores y preceptores pueden reservar. Acá podés ver cuándo está ocupado cada sector."**
1. Elegí el **Lugar**.
2. Elegí el **Día**.
3. Mirá la **Ocupación**: los horarios en rojo están ocupados.

**[CAPTURA: capturas/alumno_c_p7.png]** (vista de Alumno)

## Otros avisos de la reserva
| Aviso | Qué significa |
|---|---|
| "La hora de fin tiene que ser después de la de inicio." | Corregí la hora **Hasta**. |
| "Ese horario de inicio ya pasó. Elegí uno más tarde." | Estás reservando para hoy una hora que ya pasó. |
| "No se puede reservar en una fecha que ya pasó." | Elegí un día de hoy en adelante. |
| "Ese sector no se puede reservar." | Elegí un sector de la lista **Lugar**. |
| "Elegí un sector para reservar." | Falta elegir el lugar. |

---

# 3. Mi cuenta
Acá ves tus datos y podés cambiar tu curso (si sos Alumno), tu contraseña y tu teléfono.

**[CAPTURA: capturas/alumno_c_p9.png]** (vista de Alumno)
**[CAPTURA: capturas/preceptor_c_p9.png]** (vista de Preceptor, Profesor o Maestranza: sin curso)

## Qué ves en la pantalla
- **Mis datos:** tu nombre completo, usuario, DNI, correo, teléfono y rol. Si sos Alumno, también tu **curso** (por ejemplo, "4° 1° Computación"). No se pueden editar desde ahí.
- **Cambiar mi curso** (solo Alumnos).
- **Cambiar contraseña** y **Cambiar teléfono** (todos los roles).

## Cómo cambiar tu contraseña (todos los roles)
1. Entrá a **Mi cuenta**.
2. En **Contraseña actual** escribí la que usás hoy.
3. En **Contraseña nueva** escribí la nueva (**4 caracteres o más**, y distinta de la actual).
4. En **Repetí la contraseña nueva** escribila otra vez igual.
5. Hacé clic en **Cambiar contraseña** (o apretá **Enter** en el último campo).
6. Aparece **"Contraseña cambiada. Usala la próxima vez que ingreses."** Los campos quedan vacíos.

**[CAPTURA: cuenta_cambiar_contrasena]**

Si algo falla, la aplicación te dice qué y te deja el cursor en el campo para corregir:
| Aviso | Qué hacer |
|---|---|
| "Escribí tu contraseña actual." | Completá el primer campo. |
| "La contraseña actual no es correcta." | Revisá cómo la escribiste. |
| "La contraseña nueva necesita 4 caracteres o más." | Elegí una más larga. |
| "Las contraseñas nuevas no son iguales." | Escribí la misma en los dos campos. |
| "Elegí una contraseña distinta de la actual." | La nueva no puede ser igual a la de hoy. |

## Cómo cambiar tu teléfono (todos los roles)
1. En **Cambiar teléfono**, escribí el número nuevo **solo con números** (de **8 a 15**, sin espacios ni guiones).
2. Hacé clic en **Guardar teléfono** (o apretá **Enter**).
3. Aparece **"Teléfono actualizado."** y tu teléfono nuevo se ve en **Mis datos**. Es el que ven los demás en tus consultas y productos.

**[CAPTURA: cuenta_cambiar_telefono]**

Avisos: **"Escribí el teléfono nuevo."** (campo vacío) y **"Escribí el teléfono solo con números (entre 8 y 15), sin espacios ni guiones."** (formato incorrecto).

## Si sos Alumno: cómo cambiar tu curso
Tu curso se usa para ver si una actividad de **Educación Física** choca con tus clases, así que conviene mantenerlo al día.
1. En **Cambiar mi curso**, elegí el **año**, la **división** y la **especialidad**.
2. Hacé clic en **Guardar curso**.
3. Aparece **"Cambiaste tu curso."** y **Mis datos** muestra el curso nuevo.
4. Si elegís el curso que **ya tenés**, aparece **"Ese ya es tu curso."** y no se cambia nada.

**[CAPTURA: cuenta_cambiar_curso]**

> Si dejás algún campo sin elegir, aparece **"Elegí el año, la división y la especialidad."**

### Si ya estás inscripto en Educación Física
Si tu inscripción **choca** con el horario del curso nuevo, la aplicación te pregunta antes de cambiar: **"Con ese curso, tu inscripción a Educación Física choca con <materia> y se va a cancelar. ¿Querés cambiar de curso igual?"**
- **Sí:** se cambia el curso, **se cancela** tu inscripción y aparece **"Cambiaste tu curso. Se canceló tu inscripción a Educación Física porque choca con <materia> en tu nuevo horario."** Después podés inscribirte a otra oferta desde **Educación Física**.
- **No:** no cambia nada, tu inscripción sigue y los tres selectores **vuelven a mostrar tu curso de siempre**.

**[CAPTURA: cuenta_confirmar_cambio_curso_con_choque]**

> La comparación de horarios solo funciona para los cursos que tienen el horario cargado en la aplicación. Si tu curso no lo tiene, no se detectan choques.

---

# 4. Para todas las pantallas
- **Cambiar de tema:** con el botón de arriba a la derecha ("Tema oscuro" / "Tema claro"). La aplicación recuerda tu elección.
- **Moverte con el teclado:** con **Tab** pasás de un campo al siguiente, en el orden en que los ves en pantalla. En los formularios de una sola línea (¿Qué pasó?, Repetí la contraseña nueva, Nuevo teléfono), **Enter** envía.
- **Pasar el mouse** sobre un botón, un campo o un reporte muestra una ayuda corta.
- **Cerrar sesión:** botón del final del menú de la izquierda. Al cerrar sesión se borra lo que habías escrito sin guardar (observaciones, contraseñas, teléfono) y las pantallas vuelven a sus valores de inicio (por ejemplo, Reserva de sectores vuelve a hoy, 08:00 a 09:00). Cerrá sesión siempre que uses una computadora compartida.

**[CAPTURA: capturas/preceptor_o_p7.png]** (tema oscuro)

## Qué no hace la aplicación (para no confundirte)
- **No manda notificaciones:** para saber si tu reserva fue aprobada o si un reporte se resolvió, tenés que entrar a la pantalla y mirar.
- **No hay recuperación de contraseña dentro de la aplicación:** si te olvidás de la contraseña, hay que pedir que te la restablezcan. `[COMPLETAR: quién restablece las contraseñas en el colegio]`
- **No procesa pagos** ni nada relacionado con dinero en estas pantallas.

---

## Datos que faltan
- Capturas con los datos de MySQL: las capturas de la etapa anterior son de una base de demostración más chica (5 usuarios, 2 reportes, 3 sectores reservables); con los datos de `04_DatosSQL_Grupo00.sql` las listas se ven más largas (por ejemplo, 22 reportes en Higiene y hasta 24 reservas para el Preceptor).
- `[COMPLETAR: quién restablece las contraseñas en el colegio]` (CONTEXTO §19.3, decisión pendiente del usuario).
- Capturas de la v3 de Higiene, Sectores y Mi cuenta, para reemplazar las de la etapa anterior.
- Las capturas **sin carpeta** (`higiene_reportar_formulario_completo`, `higiene_reporte_enviado`, `higiene_marcar_resuelto_seleccion`, `sectores_reservar_profesor`, `sectores_reserva_pendiente_en_lista`, `sectores_confirmar_cancelacion`, `sectores_aprobar_rechazar_preceptor`, `cuenta_cambiar_contrasena`, `cuenta_cambiar_telefono`, `cuenta_cambiar_curso`, `cuenta_confirmar_cambio_curso_con_choque`, `menu_lateral_y_barra_superior`) las saca el usuario con la aplicación abierta.

## Desvíos
- Ronda de cierre: revisé el manual contra `04_DatosSQL_Grupo00.sql` (62 usuarios, 22 sectores, 22 reportes, 28 reservas) y `mainwindow.cpp`. Solo cambiaron las frases que nombraban tres sectores como si fueran los únicos y la del Preceptor ("de todos los profesores"); el resto (ejemplos como "20/10 08:45 — Maestranza Uno" o "4° 1° Computación") sigue valiendo con MySQL.
- Ronda sin SQLite: revisé el manual completo buscando «SQLite» y el motor de la base: no había menciones, así que no cambié ninguna instrucción. El manual tampoco explica qué hacer si la aplicación no consigue conectarse a MySQL (se ven los avisos «No se pudo usar MySQL…» y las pantallas quedan deshabilitadas); eso es del arranque de la aplicación y no de estas tres pantallas, por eso no lo agregué.
- No ejecuté la aplicación: los textos de cada aviso y cada pregunta están copiados del código de la app v3.
- Esta ronda no trae capturas nuevas. Los marcadores `[CAPTURA: capturas/<nombre>.png]` apuntan a las capturas de la etapa anterior (vistas generales de las tres pantallas, Preceptor y Alumno, tema claro y oscuro); la de Higiene fue tomada antes del cambio del texto de ayuda de "¿Qué pasó?" (ahora "Contá qué pasa (ej: falta papel)"). No hay capturas de los avisos ni de las preguntas de confirmación.
