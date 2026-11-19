# Manual de usuario — Acceso, Inicio, Objetos perdidos y Préstamo de equipos

**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar)
**Versión:** ronda final, actualizada a la **app v3** (CONTEXTO v3.0, §20) y revisada en la ronda de cierre (19/11/2026) contra los datos nuevos de MySQL. Reemplaza a la anterior.

Los marcadores `[CAPTURA: capturas/nombre.png]` son imágenes que ya existen en la carpeta `capturas`. Los marcadores `[CAPTURA: nombre]` (sin carpeta) son imágenes que todavía hay que sacar a mano.

## Cómo leer este manual

Cada tarea dice **quién puede hacerla**. IQUAL tiene cuatro roles:

| Rol | Quién es |
|---|---|
| **Alumno** | Estudiantes del colegio |
| **Profesor** | Docentes |
| **Preceptor** | Preceptoría |
| **Maestranza** | Personal de maestranza |

Lo que tu rol no puede usar **no aparece** en pantalla. Si buscás un botón y no está, es porque no corresponde a tu rol.

---

## 1. Primeros pasos

### 1.1 Abrir la aplicación
1. Abrí IQUAL. Vas a ver la pantalla de inicio con dos botones: **Iniciar sesión** y **Crear cuenta**.
2. En la barra del título de la ventana podés ver con qué base de datos trabaja la aplicación (termina en "· MySQL" si usa MySQL). Si al abrir aparece un aviso que dice **"No se pudo usar MySQL"**, la aplicación sigue funcionando con una base local; avisá al responsable del sistema `[COMPLETAR: quién es el responsable del sistema en el colegio]`.

`[CAPTURA: inicio_portada]`

### 1.2 Crear tu cuenta
*Podés hacerlo si todavía no tenés una.*

1. En la pantalla de inicio, tocá **Crear cuenta**.
2. Completá los datos:
   - **Nombre y apellido** (por ejemplo, Juan Pérez).
   - **Usuario**: con 3 caracteres o más. Con este usuario vas a ingresar.
   - **Contraseña**: con 4 caracteres o más.
   - **DNI**: 7 u 8 números, sin puntos.
   - **Correo electrónico**: tiene que llevar una @ y un punto.
   - **Teléfono**: solo números, entre 8 y 15.
3. Elegí tu **rol**.
   - **Si sos alumno**, elegí tu **año**, tu **división** y tu **especialidad**. El botón "Crear cuenta" se habilita recién cuando elegiste los tres.
   - **Si sos profesor, preceptor o personal de maestranza**, escribí el **PIN de personal**. `[COMPLETAR: quién entrega el PIN y cómo se pide]`
4. Tocá **Crear cuenta** (o apretá Enter en el campo del teléfono).
5. Si todo está bien, ves el mensaje "Cuenta creada. Ya podés iniciar sesión." y la pantalla pasa a **Iniciar sesión**.

`[CAPTURA: registro_alumno]`

**Si algo sale mal**, la aplicación te avisa y te dice qué corregir. Los mensajes más comunes:

| Mensaje | Qué hacer |
|---|---|
| "Escribí tu nombre y apellido separados por un espacio." | Escribí nombre y apellido con un espacio en el medio |
| "El DNI tiene que tener 7 u 8 números, sin puntos." | Quitá puntos y letras |
| "El correo tiene que llevar un @ y un punto." | Revisá que sea algo como nombre@correo.com |
| "Ese usuario ya existe, probá con otro." | Elegí otro usuario |
| "Ya hay una cuenta con ese DNI." / "…con ese correo." | Ya tenés cuenta: iniciá sesión |
| "El PIN de personal es incorrecto." | Pedí de nuevo el PIN en el colegio |

### 1.3 Iniciar sesión
1. En la pantalla de inicio, tocá **Iniciar sesión**.
2. Escribí tu **usuario** y apretá Enter.
3. Escribí tu **contraseña** y apretá Enter (o tocá **Ingresar**).
4. Entrás al **Inicio** de IQUAL.

`[CAPTURA: login]`

- En el usuario no importan las mayúsculas ni los espacios al principio o al final. **La contraseña sí distingue mayúsculas**.
- Si te equivocás, ves "Usuario o contraseña incorrectos" y cuántos intentos te quedan. El mensaje es el mismo si el usuario no existe.
- **Si se falla 5 veces seguidas** (en cualquier cuenta), la aplicación pide cerrarla y volver a abrirla para intentar de nuevo. Mientras tanto nadie puede ingresar.
- **La aplicación no tiene recuperación de contraseña.** Si la olvidaste, no la podés recuperar desde la pantalla; consultá quién la restablece en el colegio `[COMPLETAR: quién restablece las contraseñas en el colegio]`.

### 1.4 Moverte por la aplicación
Una vez adentro, tenés dos barras:

- **Barra lateral (izquierda):** Inicio, los módulos que podés usar, **Mi cuenta** y **Cerrar sesión**.
- **Barra superior:** el título de la pantalla, tu nombre con tu rol y el botón para cambiar de tema.

`[CAPTURA: capturas/alumno_c_p2_inicio.png]`

### 1.5 Cambiar entre tema claro y oscuro
1. En la barra superior, tocá **Tema oscuro** (o **Tema claro**).
2. La aplicación recuerda tu elección la próxima vez que la abras.

### 1.6 Cerrar sesión
1. En la barra lateral, tocá **Cerrar sesión**. Volvés a la pantalla de inicio y se borran los textos que habías escrito en las pantallas.
2. Hacelo siempre al terminar, sobre todo si la computadora es compartida.

---

## 2. Inicio (panel principal)

Al ingresar ves un saludo, **Tu resumen** y los **Módulos**.

`[CAPTURA: capturas/alumno_c_p2_inicio.png]` · `[CAPTURA: capturas/preceptor_c_p2_inicio.png]`

**Tu resumen** muestra tres números según tu rol:

| Rol | Los tres números |
|---|---|
| Alumno | Tus reclamos de objetos · Tus reservas en la tienda · Préstamos activos a tu nombre |
| Preceptor | Reclamos de objetos pendientes · Reservas de sectores pendientes (de hoy en adelante) · Reportes de higiene pendientes |
| Profesor | Tus reservas de sectores (las pendientes y aprobadas desde hoy) · Reportes de higiene pendientes · Préstamos activos en el colegio |
| Maestranza | Reportes de higiene pendientes · Equipos fuera de servicio · Préstamos activos en el colegio |

Los números se actualizan **cada vez que volvés al Inicio**.

**Módulos:** tocá una tarjeta para abrirla. "Educación Física" aparece solo para alumnos.

---

## 3. Objetos perdidos

Acá se publican los objetos que se encuentran en el colegio y los alumnos pueden reclamar lo suyo. La pantalla tiene pestañas; cuáles ves depende de tu rol:

| Pestaña | Alumno | Profesor | Preceptor | Maestranza |
|---|---|---|---|---|
| Objetos | Sí | Sí | Sí | Sí |
| Reclamos | No | No | Sí | No |
| Consultas | Sí | Sí | Sí | Sí |
| Publicar | No | No | Sí | No |
| Auditoría | No | No | Sí | No |

### 3.1 Ver los objetos y buscar (todos los roles)
1. Abrí **Objetos perdidos** desde la barra lateral.
2. En la pestaña **Objetos** ves una tarjeta por objeto con su nombre, su categoría y el sector donde se encontró, su estado y cuántos reclamos tiene, por ejemplo "Disponible · (2 reclamos)".
   - En **verde** están los que se pueden reclamar.
   - En **gris** y con "Ya devuelto" están los que ya volvieron a su dueño.
   - En **gris** y con "En reclamo" están los que ya tienen reclamos en revisión; igual se pueden reclamar.
   - El resumen de arriba ("Objetos para reclamar") cuenta solo los que están en verde.
3. Para buscar, escribí en el cuadro de búsqueda (busca por nombre, descripción, categoría y sector) o elegí una **categoría**.
4. Para ver un objeto con más detalle, hacé **doble clic** en su tarjeta: se abre una ventana con la descripción y la foto. Tocá **Cerrar** (o apretá Enter o Esc) para volver.

`[CAPTURA: capturas/alumno_c_p3_t0.png]` · `[CAPTURA: objetos_detalle]`

### 3.2 Cómo reclamar un objeto (Alumno)
1. En la pestaña **Objetos**, tocá la tarjeta del objeto que creés tuyo.
2. En **Reclamar el objeto elegido**, escribí **un detalle que no se vea en la foto ni en la descripción**: algo que solo su dueño sabría (por ejemplo, "tiene una cinta celeste en la cabeza"). Necesitás 10 caracteres o más.
3. Tocá **Reclamar objeto** (o apretá Enter).
4. Ves "Reclamo enviado. El preceptor lo va a revisar." El objeto **sigue en la lista**: ahora muestra un reclamo más.

`[CAPTURA: capturas/alumno_c_p3_t0.png]`

Es bueno saber que:
- **Cada objeto se reclama una sola vez por persona.** Si lo intentás de nuevo, ves "Ya reclamaste este objeto. Solo se puede reclamar una vez."
- **No podés cancelar** un reclamo una vez enviado: lo resuelve el preceptor.
- Los objetos "Ya devuelto" no se pueden reclamar.
- Si el preceptor rechaza tu reclamo, no podés volver a reclamar ese objeto: hablá con preceptoría.
- Solo ves **cuántos** reclamos tiene un objeto, no quiénes los hicieron ni qué dijeron.

Los mensajes más comunes:

| Mensaje | Qué hacer |
|---|---|
| "Elegí un objeto de la lista." | Tocá primero la tarjeta del objeto |
| "Contanos un poco más: el detalle necesita 10 caracteres o más." | Escribí un detalle más largo |
| "Este objeto ya no se puede reclamar: se devolvió o se archivó." | Elegí otro objeto |

### 3.3 Consultas: avisar que perdiste algo (todos los roles)
1. Abrí la pestaña **Consultas**. Ves lo que buscan otras personas, con su nombre, su teléfono y el día y mes en que lo publicaron (por ejemplo, 23/10).
2. Para publicar la tuya, escribí qué perdiste en el campo de abajo (10 caracteres o más) y tocá **Publicar consulta** (o Enter). Si alguien lo encontró, te va a contactar por teléfono.
3. Para borrar una consulta tuya, tocá la consulta, tocá **Borrar consulta** y confirmá con **Sí**. Solo podés borrar las tuyas (el preceptor puede borrar cualquiera).

`[CAPTURA: capturas/alumno_c_p3_t2.png]`

Tu teléfono sale de **Mi cuenta**; si lo cambiás ahí, tus consultas muestran el teléfono nuevo.

### 3.4 Publicar un objeto encontrado (Preceptor)
1. Abrí la pestaña **Publicar**.
2. Completá:
   - **Título** (obligatorio), por ejemplo "Buzo azul".
   - **Descripción** (opcional): lo que se ve del objeto.
   - **Categoría** y **sector donde se encontró** (obligatorios): elegí una opción de cada lista; si no, la aplicación te avisa "Elegí la categoría del objeto." o "Elegí el sector donde lo encontraron."
   - **Dato reservado** (opcional): algo que **no se ve en la foto ni en la descripción** y que solo vas a ver vos. Te sirve para comparar con lo que cuenten quienes lo reclamen. Admite hasta 200 caracteres.
3. Si querés, tocá **Elegir foto (opcional)** y elegí una imagen PNG o JPG. Ves una vista previa.
4. Tocá **Publicar objeto**. Ves "Objeto publicado." y el objeto aparece primero en la lista.
5. Después de publicar, la categoría y el sector vuelven a "Elegí una categoría" / "Elegí un sector": para el siguiente objeto tenés que elegirlos otra vez.

`[CAPTURA: capturas/preceptor_c_p3_t3.png]`

- Alumnos y profesores **nunca** ven el dato reservado.
- Si la foto no se puede abrir, ves "No se pudo abrir esa imagen. Probá con otra foto PNG o JPG."

### 3.5 Revisar los reclamos (Preceptor)
1. Abrí la pestaña **Reclamos**. El número entre paréntesis es la cantidad de reclamos pendientes.
2. Cada reclamo muestra **qué objeto es**, **quién lo reclama**, **su detalle** y el **dato reservado** del objeto, uno debajo del otro, para que los compares. Los reclamos del mismo objeto están juntos.
3. Elegí el reclamo y decidí:
   - **Aprobar reclamo:** confirmá con **Sí**. El objeto pasa a "Ya devuelto" y los demás reclamos de ese objeto quedan rechazados.
   - **Rechazar reclamo:** confirmá con **Sí**. Solo se rechaza ese reclamo; el objeto sigue disponible para otros.
4. Si tocás **No** en la confirmación, no cambia nada.
5. Si tocás un botón sin haber elegido un reclamo, ves "Elegí un reclamo de la lista."

`[CAPTURA: capturas/preceptor_c_p3_t1.png]`

### 3.6 Archivar un objeto (Preceptor)
1. En la pestaña **Objetos**, tocá la tarjeta del objeto.
2. Tocá **Archivar objeto** y confirmá con **Sí**. El objeto sale de la lista.
3. Si el objeto tiene reclamos pendientes, primero tenés que aprobarlos o rechazarlos.

### 3.7 Ver la auditoría (Preceptor)
En la pestaña **Auditoría** ves los últimos 50 registros de lo que pasó en el sistema: fecha, quién, qué evento y si salió bien (**Exitoso**) o no (**Fallido**, en rojo). Podés filtrar por resultado. Si la base es nueva, la lista empieza vacía y se va llenando a medida que se usa la aplicación.

`[CAPTURA: capturas/preceptor_c_p3_t4.png]`

---

## 4. Préstamo de equipos

Acá se registra el préstamo y la devolución de computadoras (de los carros C1 a C5) y tableros de dibujo.

`[CAPTURA: capturas/preceptor_c_p6.png]`

### 4.1 Mirar qué hay
- Arriba ves un resumen de todo el colegio: cuántos equipos hay **disponibles**, **prestados** y **fuera de servicio**.
- **Equipos disponibles** lista los que se pueden pedir, por ejemplo "C4-01 · Computadora" o "Tablero 03 · Tablero de dibujo".
- **Para buscar un equipo**, escribí parte de su código en el cuadro de búsqueda (por ejemplo "C4-05"); la lista se filtra mientras escribís.
- **Para buscar por programa**, elegí uno en el desplegable "Todos los programas" (solo se muestran las computadoras que lo tienen). Podés combinarlo con la búsqueda por código.
- **Para ver qué programas tiene un equipo**, tocá el equipo: debajo de la lista aparece "Programas instalados: …".
- **Préstamos** muestra los préstamos con los activos primero (en verde, "En préstamo") y los devueltos en gris.
  - **Si sos alumno**, ves **solo los tuyos**. Si todavía no tenés ninguno, dice "Todavía no tenés préstamos registrados."
  - Profesores, preceptores y personal de maestranza ven los de todos.

`[CAPTURA: prestamo_programas]`

### 4.2 Cómo pedir un equipo (Alumno)
1. En **Equipos disponibles**, tocá el equipo que necesitás.
2. En **Pedir un equipo**, el desplegable ya muestra tu nombre.
3. Si querés, escribí una observación (por ejemplo, "le falta una tecla").
4. Tocá **Registrar préstamo**. Ves "Préstamo registrado."

`[CAPTURA: capturas/alumno_c_p6.png]`

- **Podés tener un solo equipo prestado a la vez.** Si ya tenés uno, ves "Ya tenés un equipo prestado. Devolvelo antes de retirar otro."
- Solo podés pedir equipos a tu nombre.

### 4.3 Cómo pedirle un equipo a un alumno (Profesor y Preceptor)
1. Tocá el equipo en **Equipos disponibles**.
2. En **Pedir un equipo**, elegí el **alumno** que se lo lleva (el desplegable los lista por orden alfabético de nombre).
3. Tocá **Registrar préstamo**. En la lista queda anotado que lo autorizaste vos.
4. Si el alumno ya tiene un equipo, ves "Ese alumno ya tiene un equipo prestado. Tiene que devolverlo antes de retirar otro."

### 4.4 Cómo devolver un equipo (Alumno, Profesor y Preceptor)
1. En **Préstamos**, tocá el préstamo que querés cerrar (los activos están en verde). Un alumno solo ve y puede devolver los suyos.
2. En **¿Cómo vuelve el equipo?**, elegí **Funciona** o **No funciona**. **Ojo: el desplegable arranca en "Funciona"**, así que fijate de cambiarlo si el equipo tiene un problema.
3. Si querés, escribí una observación en el campo de **Observaciones** (el mismo que se usa al pedir): se guarda con la devolución.
4. Tocá **Devolver equipo**. Ves "Devolución registrada."
   - Con **Funciona**, el equipo vuelve a quedar disponible.
   - Con **No funciona**, la aplicación te pide confirmar (el equipo queda fuera de servicio hasta que lo repare el preceptor o maestranza). Confirmá con **Sí**.

`[CAPTURA: capturas/alumno_c_p6.png]`

Mensajes comunes:

| Mensaje | Qué hacer |
|---|---|
| "Elegí un equipo de la lista de disponibles." | Tocá primero un equipo |
| "Elegí quién se lleva el equipo." | Elegí el alumno (profesor y preceptor) |
| "Elegí un préstamo de la lista." | Tocá primero un préstamo |
| "Ese préstamo ya fue devuelto." | Elegí un préstamo activo |
| "Solo podés devolver tus propios préstamos." | Pedile a quien lo retiró que lo devuelva |

### 4.5 Equipos fuera de servicio (Preceptor y Maestranza)
1. En **Fuera de servicio** ves los equipos rotos, en rojo.
2. Cuando uno esté arreglado, tocalo y tocá **Marcar reparado**. Ves "Equipo reparado. Ya se puede prestar." y vuelve a la lista de disponibles. Si tocás el botón sin elegir un equipo, ves "Elegí un equipo de la lista de fuera de servicio."
3. Maestranza ve los préstamos y los equipos fuera de servicio, pero no puede pedir ni devolver equipos.

`[CAPTURA: capturas/preceptor_c_p6.png]`

---

## 5. Si algo no funciona

| Qué pasa | Qué hacer |
|---|---|
| No encuentro un botón | Es posible que tu rol no pueda usarlo |
| Aparece un aviso | Leelo: dice qué corregir |
| Un botón no hace nada | Fijate si tenés que elegir antes un elemento de la lista; si no, la aplicación te lo avisa al apretarlo |
| Aparece "No se pudo usar MySQL" al abrir | La aplicación sigue con una base local; avisá al responsable del sistema `[COMPLETAR: quién es el responsable del sistema]` |
| Bloqueo por intentos de contraseña | Cerrá y abrí la aplicación |
| Olvidé mi contraseña | No se recupera desde la aplicación (ver 1.3) |

---

## Desvíos

- El manual describe la app v3 (CONTEXTO v3.0, §19 y §20). Donde una decisión por defecto puede cambiar (bloqueo por intentos, un solo campo de observaciones, "Funciona" elegido al devolver, pantalla de inicio), hay que revisar los pasos 1.1, 1.3, 4.2 y 4.4.
- Ronda de cierre: con los datos de MySQL el manual cambió en 5 puntos (carros C1 a C5, objetos "En reclamo", qué cuenta el resumen de Objetos, auditoría que arranca vacía y lista de alumnos ordenada). Los ejemplos del manual ("Disponible · (2 reclamos)", "23/10", "C4-01", "C4-05", "Tablero 03") existen en los datos de MySQL. El manual no repite cantidades, así que no depende de cuántos registros haya.
- Cambios de la v3 reflejados: la fecha de las consultas se ve día/mes, categoría y sector vuelven a "Elegí…" después de publicar, y el Alumno ve solo sus préstamos.
- Usé las capturas de `capturas/` solo donde coinciden con lo que se explica (son las de la etapa de cierre; esta ronda no trajo capturas nuevas). Las de la portada, el login, el registro, el detalle del objeto y los programas instalados todavía no existen.
- No incluí el PIN de personal: es un dato interno que entrega el colegio.

## Datos que faltan

- `[COMPLETAR: quién entrega el PIN y cómo se pide]` (sección 1.2).
- `[COMPLETAR: quién restablece las contraseñas en el colegio]` (sección 1.3).
- `[COMPLETAR: quién es el responsable del sistema en el colegio]` (secciones 1.1 y 5).
- Capturas a sacar a mano: `inicio_portada`, `registro_alumno`, `login`, `objetos_detalle`, `prestamo_programas`.
- Capturas nuevas con la v3 para reemplazar las de la etapa de cierre.
