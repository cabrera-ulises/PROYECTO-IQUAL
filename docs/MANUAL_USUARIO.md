# Manual de usuario — PROYECTO IQUAL® (Sistema de Gestión Escolar)

**Versión final (Demo Day, 24/11/2026).** Reúne en un solo manual todas las pantallas de la aplicación y reemplaza a los manuales separados por módulo.

## Cómo leer este manual

Cada tarea dice **quién puede hacerla**. IQUAL tiene cuatro roles:

| Rol | Quién es |
|---|---|
| **Alumno** | Estudiantes del colegio |
| **Profesor** | Docentes |
| **Preceptor** | Preceptoría |
| **Maestranza** | Personal de maestranza |

Lo que tu rol no puede usar **no aparece** en pantalla. Si buscás un botón y no está, es porque no corresponde a tu rol.

**Índice**

1. Primeros pasos
2. Inicio (panel principal)
3. Objetos perdidos
4. Higiene y mantenimiento
5. Tienda de alumnos
6. Préstamo de equipos
7. Reserva de sectores
8. Educación Física
9. Mi cuenta
10. Para todas las pantallas
11. Si algo no funciona
12. Quién te ayuda en el colegio

Los marcadores `[CAPTURA: …]` indican dónde va una imagen. Los que llevan carpeta (`capturas/nombre.png`) ya existen; los que no la llevan hay que sacarlos con la aplicación abierta.

---

## 1. Primeros pasos

### 1.1 Abrir la aplicación
1. Abrí IQUAL. Vas a ver la pantalla de inicio con dos botones: **Iniciar sesión** y **Crear cuenta**.
2. Cuando la aplicación se conecta a la base de datos, la barra del título de la ventana termina en "· MySQL". Si al abrir aparece un aviso que dice **"No se pudo usar MySQL"** (y después otro, "No se pudo abrir la base de datos"), la aplicación no se puede usar: los botones de la pantalla de inicio no responden. Cerrala y avisá al responsable del sistema (ver sección 12), que tiene que revisar que el servidor de la base de datos esté encendido.

`[CAPTURA: inicio_portada]`

### 1.2 Crear tu cuenta
*Podés hacerlo si todavía no tenés una.*

1. En la pantalla de inicio, tocá **Crear cuenta**.
2. Completá los datos:
   - **Nombre y apellido** (por ejemplo, Juan Pérez), separados por un espacio.
   - **Usuario**: con 3 caracteres o más. Con este usuario vas a ingresar.
   - **Contraseña**: con 4 caracteres o más.
   - **DNI**: 7 u 8 números, sin puntos.
   - **Correo electrónico**: con el formato nombre@dominio.com, sin espacios.
   - **Teléfono**: solo números, entre 8 y 15.
3. Elegí tu **rol**.
   - **Si sos alumno**, elegí tu **año**, tu **división** y tu **especialidad**. El botón "Crear cuenta" se habilita recién cuando elegiste los tres.
   - **Si sos profesor, preceptor o personal de maestranza**, escribí el **PIN de personal** (ver sección 12).
4. Tocá **Crear cuenta** (o apretá Enter en el campo del teléfono).
5. Si todo está bien, ves el mensaje "Cuenta creada. Ya podés iniciar sesión." y la pantalla pasa a **Iniciar sesión**.

`[CAPTURA: registro_alumno]`

**Si algo sale mal**, la aplicación te avisa y te dice qué corregir. Los mensajes más comunes:

| Mensaje | Qué hacer |
|---|---|
| "Escribí tu nombre y apellido separados por un espacio." | Escribí nombre y apellido con un espacio en el medio |
| "El DNI tiene que tener 7 u 8 números, sin puntos." | Quitá puntos y letras |
| "El correo no es válido. Tiene que ser algo como nombre@dominio.com." | Revisá que tenga una @, un dominio y un punto, sin espacios |
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
- **La aplicación no tiene recuperación de contraseña.** Si la olvidaste, no la podés recuperar desde la pantalla: pedí que te la restablezcan (ver sección 12).

### 1.4 Moverte por la aplicación
Una vez adentro, tenés dos barras:

- **Barra lateral (izquierda):** Inicio, Objetos perdidos, Higiene, Tienda de alumnos, Préstamo de equipos, Reserva de sectores, Educación Física (solo si sos Alumno), **Mi cuenta** y **Cerrar sesión**.
- **Barra superior:** el título de la pantalla, tu nombre con tu rol y el botón para cambiar de tema.

`[CAPTURA: capturas/alumno_c_p2_inicio.png]` · `[CAPTURA: menu_lateral_y_barra_superior]`

### 1.5 Cambiar entre tema claro y oscuro
1. En la barra superior, tocá **Tema oscuro** (o **Tema claro**).
2. La aplicación recuerda tu elección la próxima vez que la abras.

`[CAPTURA: capturas/preceptor_o_p7.png]` (tema oscuro)

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
| Profesor | Tus reservas de sectores (las pendientes y aprobadas desde hoy) · Reportes de higiene pendientes · Préstamos activos en el colegio |
| Preceptor | Reclamos de objetos pendientes · Reservas de sectores pendientes (de hoy en adelante) · Reportes de higiene pendientes |
| Maestranza | Reportes de higiene pendientes · Equipos fuera de servicio · Préstamos activos en el colegio |

Los números se actualizan **cada vez que volvés al Inicio**, sin cerrar sesión.

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

Es bueno saber que:
- **Cada objeto se reclama una sola vez por persona.** Si lo intentás de nuevo, ves "Ya reclamaste este objeto. Solo se puede reclamar una vez."
- **No podés cancelar** un reclamo una vez enviado: lo resuelve el preceptor.
- Los objetos "Ya devuelto" no se pueden reclamar.
- Si el preceptor rechaza tu reclamo, no podés volver a reclamar ese objeto: hablá con preceptoría.
- Solo ves **cuántos** reclamos tiene un objeto, no quiénes los hicieron ni qué dijeron.

| Mensaje | Qué hacer |
|---|---|
| "Elegí un objeto de la lista." | Tocá primero la tarjeta del objeto |
| "Contanos un poco más: el detalle necesita 10 caracteres o más." | Escribí un detalle más largo |
| "Este objeto ya no se puede reclamar: se devolvió o se archivó." | Elegí otro objeto |

### 3.3 Consultas: avisar que perdiste algo (todos los roles)
1. Abrí la pestaña **Consultas**. Ves lo que buscan otras personas, con su nombre, su teléfono y el día y mes en que lo publicaron (por ejemplo, 23/10).
2. Para publicar la tuya, escribí qué perdiste en el campo de abajo (10 caracteres o más) y tocá **Publicar consulta** (o Enter). Si alguien lo encontró, te va a contactar por teléfono.
3. Para borrar una consulta tuya, tocá la consulta, tocá **Borrar consulta** y confirmá con **Sí**. Solo podés borrar las tuyas (el preceptor puede borrar cualquiera).

Tu teléfono sale de **Mi cuenta**; si lo cambiás ahí, tus consultas muestran el teléfono nuevo.

`[CAPTURA: capturas/alumno_c_p3_t2.png]`

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

## 4. Higiene y mantenimiento

Sirve para **avisar que algo está roto o sucio** en el colegio (un baño sin papel, una silla rota) y para que el personal marque cuándo lo resolvió.

`[CAPTURA: capturas/preceptor_c_p4.png]` (vista de Preceptor) · `[CAPTURA: capturas/alumno_c_p4.png]` (vista de Alumno: sin el botón Marcar resuelto)

### 4.1 Qué ves en la pantalla
- **A la izquierda:** la lista de **Reportes**, con el filtro **Ver:** (Todos, Pendientes, Resueltos) y una franja que dice cuántos reportes están pendientes.
- **A la derecha:** el formulario **Reportar un problema** (¿Dónde?, ¿Qué tipo de problema?, ¿Qué pasó?) y, justo debajo del selector de sector, el **Último mantenimiento** de ese lugar.
- Cada reporte muestra tres líneas: primero su estado, el sector y el tipo; después la fecha, la hora y quién lo reportó; y al final lo que escribieron.
- **Colores:** los reportes **Pendientes** aparecen en **rojo** y los **Resueltos** en **verde**. Además siempre dice la palabra "Pendiente" o "Resuelto", así que se entiende aunque no distingas los colores. Los pendientes van siempre primero.

### 4.2 Cómo reportar un problema (todos los roles)
1. Entrá a **Higiene** desde el menú.
2. En **¿Dónde?** elegí el lugar (por ejemplo, "Baño 1").
3. En **¿Qué tipo de problema?** elegí **Rotura** o **Limpieza**.
4. En **¿Qué pasó?** escribí en pocas palabras qué pasa (por ejemplo, "Falta papel").
5. Hacé clic en **Reportar** (o apretá **Enter**).
6. Aparece el aviso **"Reporte enviado. Gracias por avisar."** Tu reporte queda arriba de la lista, en rojo, como **Pendiente**.

`[CAPTURA: higiene_reportar_formulario_completo]` · `[CAPTURA: higiene_reporte_enviado]`

> **Importante:** el campo **¿Qué pasó?** es obligatorio. Si lo dejás vacío aparece **"Contanos qué pasa para poder resolverlo."** y no se envía nada. Podés escribir hasta **200 caracteres**: el campo no deja escribir más, así que si tu mensaje es largo, resumilo.

### 4.3 Ver cuándo se arregló algo por última vez
1. En **¿Dónde?** elegí el sector.
2. Mirá el recuadro **Último mantenimiento**: dice la fecha, la hora y el nombre de quien lo resolvió (por ejemplo, "20/10 08:45 — Maestranza Uno"). Si todavía nadie resolvió un reporte de ese sector, dice **"Todavía no hay ninguno"**.

### 4.4 Filtrar la lista
Arriba de la lista, en **Ver:**, elegí:
- **Todos:** los pendientes y los resueltos más recientes.
- **Pendientes:** solo lo que falta resolver.
- **Resueltos:** solo lo ya resuelto.

La lista muestra como máximo los **20 reportes resueltos más recientes**; los pendientes se muestran siempre todos.

### 4.5 Marcar un reporte como resuelto (Profesor, Preceptor y Maestranza)
1. Entrá a **Higiene**.
2. En la lista, hacé clic en el reporte que ya se solucionó (tiene que estar **Pendiente**).
3. Hacé clic en **Marcar resuelto**.
4. El reporte pasa a verde como **Resuelto** y queda guardado quién lo resolvió y cuándo. La franja de pendientes baja en uno.
5. El recuadro **Último mantenimiento** pasa a mostrar el **sector del reporte que acabás de resolver**, con tu nombre y la hora.

`[CAPTURA: higiene_marcar_resuelto_seleccion]`

Avisos que podés ver:
- **"Elegí un reporte de la lista."** → te faltó hacer clic en un reporte.
- **"Ese reporte ya está resuelto."** → elegiste uno que ya estaba resuelto.

> Los Alumnos no ven el botón **Marcar resuelto**: solo pueden reportar y mirar.

### 4.6 Cuando la lista está vacía
- Sin pendientes: **"No hay reportes pendientes."**
- Sin resueltos: **"Todavía no hay reportes resueltos."**
- Sin ningún reporte: **"Todavía no hay reportes. Si ves algo roto o sucio, avisanos desde el formulario."**

---

## 5. Tienda de alumnos

Es el espacio donde los alumnos venden productos (por ejemplo, una remera de egresados) y juntan fondos en grupos de recaudación. **No se paga dentro de la aplicación**: la entrega y el cobro se coordinan en persona con el vendedor.

La pantalla tiene pestañas; cuáles ves depende de tu rol:

| Pestaña | Alumno | Profesor / Preceptor / Maestranza |
|---|---|---|
| Productos | Sí | Sí |
| Publicar | Sí | No |
| Grupos y donaciones | Sí | Sí (pueden ver los grupos y donar) |
| Mis reservas | Sí | Sí |
| Mis ventas | Sí | No |
| Mis productos | Sí | No |

### 5.1 Ver y buscar productos (todos los roles)
1. Abrí **Tienda de alumnos** desde la barra lateral. Se abre en la pestaña **Productos**.
2. Arriba elegís qué ver:
   - **TODOS** (viene elegido de entrada): los productos sueltos y los de todos los grupos.
   - **Productos sueltos de alumnos:** solo las ventas individuales.
   - El nombre de un grupo: solo los productos de ese grupo.
3. Podés filtrar también por **categoría** y por **vendedor**, o escribir en el cuadro **Buscar**.
4. Cada producto muestra su nombre, precio, stock, el vendedor y su categoría. Los que no tienen stock aparecen en **rojo** con "SIN STOCK".
5. Para ver la foto en grande, hacé **doble clic** en el producto.

`[CAPTURA: tienda_productos_todos]`

### 5.2 Reservar un producto (todos los roles)
1. Tocá el producto. La franja de abajo te dice si lo podés reservar.
2. Elegí la **cantidad** (el selector no deja pasar del stock disponible).
3. Tocá **Reservar**. Ves **"Reserva hecha. Coordiná la entrega en persona con el vendedor."** El stock del producto baja en lo que reservaste y la reserva aparece en **Mis reservas**.

| Mensaje | Qué significa |
|---|---|
| "Elegí un producto de la lista." | Tocá primero un producto |
| "No podés reservar tus propios productos." | Elegiste un producto que publicaste vos |
| "No hay stock suficiente: quedan …" | Pedí menos unidades o elegí otro producto |
| "Ese producto ya no existe." | El vendedor lo eliminó: actualizá la lista |

### 5.3 Mis reservas (todos los roles)
1. Abrí **Mis reservas**. Cada reserva muestra su estado, el producto, la cantidad, el precio y el vendedor con su teléfono ("vende … (tel. …)"), para coordinar la entrega. Arriba figura cuántas reservas activas tenés.
2. Para cancelar una reserva activa, tocala y elegí **Cancelar reserva**. Confirmá con **Sí**. Ves "Reserva cancelada. El stock volvió al producto."
3. Si todavía no reservaste nada, ves "Todavía no reservaste ningún producto. Elegí uno en la pestaña Productos."

Solo se pueden cancelar las reservas **tuyas** y **activas** ("Esa reserva no es tuya." / "Esa reserva ya no está activa.").

### 5.4 Publicar un producto (Alumno)
1. Abrí la pestaña **Publicar**.
2. Completá:
   - **Nombre** del producto.
   - **Categoría**.
   - **Precio** y **stock**: números enteros mayores a 0, sin centavos.
   - **Venta individual** o un grupo: en la lista de grupos solo aparecen aquellos de los que sos integrante.
3. Si querés, elegí una **foto** (opcional, pero ayuda a vender). Con **Quitar foto** la sacás antes de publicar.
4. Tocá **Publicar**. Ves "Producto publicado." y los campos se limpian.

La foto se elige al publicar y después no se puede cambiar. Si querés otra, eliminá el producto y publicalo de nuevo.

| Mensaje | Qué hacer |
|---|---|
| "Escribí el nombre del producto." | Completá el nombre |
| "Precio y stock: escribí números enteros mayores a 0." | Revisá que no haya letras, centavos ni ceros |
| "Elegí la categoría del producto." | Elegí una categoría |
| "Para vender en un grupo tenés que ser integrante." | Unite al grupo primero (sección 5.6) |

### 5.5 Mis productos (Alumno)
En **Mis productos** ves solo lo que publicaste vos. Elegí un producto y usá:
- **Reponer:** suma unidades al stock ("Sumaste … Ahora hay …").
- **Quitar:** resta unidades. No podés quitar más de lo que hay.
- **Eliminar:** borra el producto (confirmá con **Sí**; no se puede deshacer). No se puede eliminar si tiene **reservas activas** (entregalas o cancelalas antes) ni si **ya tuvo ventas** (se conserva el historial).

### 5.6 Grupos y donaciones
Un **grupo de recaudación** junta fondos para una meta (por ejemplo, el viaje de egresados). El avance se ve en una barra: "Se recaudaron $X de $Y (Z%)". Lo recaudado suma las **donaciones** y las **ventas entregadas** de los productos del grupo.

**Ver los grupos y donar (todos los roles)**
1. Abrí **Grupos y donaciones** y elegí el grupo.
2. Escribí el monto en pesos (entero, mayor a 0, sin centavos) y tocá **Donar**. Ves "¡Gracias por tu donación!" y el recaudado sube.
3. Si todavía no hay grupos: "Todavía no hay grupos para donar."

**Crear un grupo (Alumno)**
1. Escribí el **nombre del grupo**, la **meta** en pesos y un **PIN** de 4 caracteres o más.
2. Tocá **Crear grupo**. Ves "Grupo creado. Ya sos integrante."
3. Pasales el PIN a tus compañeros: lo necesitan para unirse.

**Unirte a un grupo (Alumno)**
1. Elegí el grupo y escribí el **PIN** que te dio quien lo creó.
2. Tocá **Unirse**. Ves "Ya sos parte del grupo." Desde ese momento podés publicar productos para ese grupo.

| Mensaje | Qué hacer |
|---|---|
| "Escribí el nombre del grupo." | Completá el nombre |
| "La meta es un monto en pesos, mayor a 0 y sin centavos." | Corregí la meta |
| "El PIN necesita 4 caracteres o más." | Elegí un PIN más largo |
| "Ya existe un grupo con ese nombre." | Elegí otro nombre |
| "El PIN no coincide. Pedíselo a quien creó el grupo." | Pedí de nuevo el PIN |
| "Ya sos integrante de ese grupo." | No hace falta unirse de nuevo |

`[CAPTURA: tienda_grupos_y_donaciones]`

### 5.7 Mis ventas (Alumno)
1. Abrí **Mis ventas**. Ves las reservas que otros hicieron sobre tus productos: estado, producto, cantidad, precio, y quién reservó con su teléfono ("reservó … (tel. …)").
2. Cuando entregues el producto en persona, tocá la reserva y **Entregar**. Ves "Entrega confirmada. La venta quedó como Entregada."
3. Si el comprador no viene o se arrepiente, tocá la reserva y **Cancelar** (confirmá con **Sí**). El stock vuelve a tu producto.

Solo podés resolver reservas **activas** y de productos **tuyos**. Si todavía nadie reservó, dice "Todavía nadie reservó tus productos."

> Una reserva puede incluir productos de dos vendedores. En ese caso, entregarla o cancelarla cambia el estado de **toda** la reserva, no de un solo producto. Coordinen entre vendedores antes de marcarla.

---

## 6. Préstamo de equipos

Acá se registra el préstamo y la devolución de computadoras (de los carros C1 a C5) y tableros de dibujo.

`[CAPTURA: capturas/preceptor_c_p6.png]`

### 6.1 Mirar qué hay
- Arriba ves un resumen de todo el colegio: cuántos equipos hay **disponibles**, **prestados** y **fuera de servicio**.
- **Equipos disponibles** lista los que se pueden pedir, por ejemplo "C4-01 · Computadora" o "Tablero 03 · Tablero de dibujo".
- **Para buscar un equipo**, escribí parte de su código en el cuadro de búsqueda (por ejemplo "C4-05"); la lista se filtra mientras escribís.
- **Para buscar por programa**, elegí uno en el desplegable "Todos los programas" (solo se muestran las computadoras que lo tienen). Podés combinarlo con la búsqueda por código.
- **Para ver qué programas tiene un equipo**, tocá el equipo: debajo de la lista aparece "Programas instalados: …". Los tableros de dibujo no tienen programas.
- **Préstamos** muestra los préstamos con los activos primero (en verde, "En préstamo") y los devueltos en gris.
  - **Si sos alumno**, ves **solo los tuyos**. Si todavía no tenés ninguno, dice "Todavía no tenés préstamos registrados."
  - Profesores, preceptores y personal de maestranza ven los de todos.

`[CAPTURA: prestamo_programas]`

### 6.2 Pedir un equipo (Alumno)
1. En **Equipos disponibles**, tocá el equipo que necesitás.
2. En **Pedir un equipo**, el desplegable ya muestra tu nombre.
3. Si querés, escribí una observación (por ejemplo, "le falta una tecla").
4. Tocá **Registrar préstamo**. Ves "Préstamo registrado."

`[CAPTURA: capturas/alumno_c_p6.png]`

- **Podés tener un solo equipo prestado a la vez.** Si ya tenés uno, ves "Ya tenés un equipo prestado. Devolvelo antes de retirar otro."
- Solo podés pedir equipos a tu nombre.

### 6.3 Prestarle un equipo a un alumno (Profesor y Preceptor)
1. Tocá el equipo en **Equipos disponibles**.
2. En **Pedir un equipo**, elegí el **alumno** que se lo lleva (el desplegable los lista por orden alfabético de nombre).
3. Tocá **Registrar préstamo**. En la lista queda anotado que lo autorizaste vos.
4. Si el alumno ya tiene un equipo, ves "Ese alumno ya tiene un equipo prestado. Tiene que devolverlo antes de retirar otro."

### 6.4 Devolver un equipo (Alumno, Profesor y Preceptor)
1. En **Préstamos**, tocá el préstamo que querés cerrar (los activos están en verde). Un alumno solo ve y puede devolver los suyos.
2. En **¿Cómo vuelve el equipo?**, elegí **Funciona** o **No funciona**. **Ojo: el desplegable arranca en "Funciona"**, así que fijate de cambiarlo si el equipo tiene un problema.
3. Si querés, escribí una observación en el campo de **Observaciones** (el mismo que se usa al pedir): se guarda con la devolución.
4. Tocá **Devolver equipo**. Ves "Devolución registrada."
   - Con **Funciona**, el equipo vuelve a quedar disponible.
   - Con **No funciona**, la aplicación te pide confirmar (el equipo queda fuera de servicio hasta que lo repare el preceptor o maestranza). Confirmá con **Sí**.

| Mensaje | Qué hacer |
|---|---|
| "Elegí un equipo de la lista de disponibles." | Tocá primero un equipo |
| "Elegí quién se lleva el equipo." | Elegí el alumno (profesor y preceptor) |
| "Elegí un préstamo de la lista." | Tocá primero un préstamo |
| "Ese préstamo ya fue devuelto." | Elegí un préstamo activo |
| "Solo podés devolver tus propios préstamos." | Pedile a quien lo retiró que lo devuelva |

### 6.5 Equipos fuera de servicio (Preceptor y Maestranza)
1. En **Fuera de servicio** ves los equipos rotos, en rojo.
2. Cuando uno esté arreglado, tocalo y tocá **Marcar reparado**. Ves "Equipo reparado. Ya se puede prestar." y vuelve a la lista de disponibles. Si tocás el botón sin elegir un equipo, ves "Elegí un equipo de la lista de fuera de servicio."
3. Maestranza ve los préstamos y los equipos fuera de servicio, pero no puede pedir ni devolver equipos.

---

## 7. Reserva de sectores

Sirve para **reservar** un lugar del colegio (por ejemplo, la Biblioteca, el Laboratorio 1 o el SUM; la lista **Lugar** muestra todos los que se pueden reservar) en un día y horario, sin chocar con otras reservas. Solo los **Profesores y Preceptores** pueden reservar; el resto puede consultar cuándo está ocupado.

`[CAPTURA: capturas/preceptor_c_p7.png]`

### 7.1 Reglas que tenés que conocer
- Solo se reservan los sectores que figuran en la lista **Lugar** (los demás, como el Patio, el Buffet o los baños, no se reservan).
- El horario va de **07:00 a 19:00**. Los selectores de hora no te dejan salir de ese rango.
- No se puede reservar un día que ya pasó, ni un horario de hoy que ya empezó.
- La hora de **fin** tiene que ser **posterior** a la de inicio.
- Dos reservas **no pueden superponerse** en el mismo sector y día. Una reserva **pendiente** también ocupa el horario. Si una termina a las 11:00, otra puede empezar a las 11:00.

### 7.2 Qué ves en la pantalla
- **Lugar y día** (arriba a la izquierda): elegís el lugar y el día en un calendario, y los horarios **Desde** y **Hasta**.
- **Ocupación** (abajo a la izquierda): quién ocupa ese lugar ese día y en qué horario. Los horarios ocupados salen en **rojo**; si el día está libre, dice **"Sin reservas ese día: el sector está libre."** en verde. Si hay reservas esperando aprobación, arriba aparece **"Atención: …reservas pendientes de aprobación ese día."**
- **Reservas próximas** (a la derecha): tus reservas (el Preceptor ve las de todos, con las pendientes primero; las canceladas no figuran). El estado puede ser **Pendiente de aprobación** (gris), **Aprobada** (verde) o **Rechazada** (rojo).

### 7.3 Reservar un sector (Profesor)
1. Entrá a **Reserva de sectores**.
2. En **Lugar** elegí el sector que querés reservar (por ejemplo, Biblioteca). La lista está en orden alfabético.
3. En **Día** hacé clic y elegí la fecha en el calendario.
4. Mirá la **Ocupación**: así sabés si el horario que querés está libre.
5. Elegí **Desde** y **Hasta**.
6. Hacé clic en **Reservar**.
7. Aparece **"Reserva enviada. Queda pendiente hasta que un preceptor la apruebe."** Tu reserva figura en **Reservas próximas** como **Pendiente de aprobación**, y el número de **Tus reservas de sectores** del Inicio sube en uno.
8. Más tarde, volvé a entrar a la pantalla: si el Preceptor la aprobó, pasa a **Aprobada**; si no, a **Rechazada**. La aplicación **no te avisa** sola: tenés que mirar la lista.

`[CAPTURA: sectores_reservar_profesor]` · `[CAPTURA: sectores_reserva_pendiente_en_lista]`

Si el horario ya está ocupado, el aviso te dice quién lo tiene: **"Ese horario está ocupado: <nombre> tiene el sector de 10:00 a 11:00. Probá con otro."**

### 7.4 Reservar un sector (Preceptor)
Es igual que para el Profesor, con una diferencia: tu reserva queda **Aprobada** de inmediato (aparece **"Reserva aprobada."**), porque vos sos quien aprueba.

### 7.5 Aprobar o rechazar reservas (Preceptor)
1. En **Reservas próximas** las **pendientes** aparecen primero, en gris.
2. Hacé clic en la reserva que querés resolver.
3. Para aceptarla, **Aprobar**. Pasa a **Aprobada** (verde).
4. Para no aceptarla, **Rechazar**. La aplicación pregunta **"¿Querés rechazar la reserva de …? El horario queda libre."** Elegí **Sí** o **No**. Con **Sí** pasa a **Rechazada** (rojo) y el horario queda libre.

`[CAPTURA: sectores_aprobar_rechazar_preceptor]`

Avisos posibles:
- **"Elegí una reserva de la lista."** → no seleccionaste ninguna.
- **"Solo se pueden aprobar o rechazar reservas pendientes."** → esa reserva ya estaba resuelta.

### 7.6 Cancelar una reserva (Profesor y Preceptor)
1. En **Reservas próximas**, hacé clic en la reserva.
2. Hacé clic en **Cancelar reserva**.
3. La aplicación pregunta: **"¿Querés cancelar la reserva de …? El horario queda libre para otros."** Elegí **Sí** para cancelar o **No** para dejarla como está.
4. Si elegiste **Sí**, la reserva desaparece de la lista y el horario queda libre.

El Profesor solo puede cancelar **sus** reservas; el Preceptor puede cancelar cualquiera. Si la reserva ya estaba rechazada o cancelada, ves **"Esa reserva ya está rechazada o cancelada."**

`[CAPTURA: sectores_confirmar_cancelacion]`

### 7.7 Consultar la ocupación (Alumno y Maestranza)
Tu pantalla muestra una franja que dice **"Solo profesores y preceptores pueden reservar. Acá podés ver cuándo está ocupado cada sector."**
1. Elegí el **Lugar**.
2. Elegí el **Día**.
3. Mirá la **Ocupación**: los horarios en rojo están ocupados.

`[CAPTURA: capturas/alumno_c_p7.png]`

### 7.8 Otros avisos de la reserva

| Aviso | Qué significa |
|---|---|
| "La hora de fin tiene que ser después de la de inicio." | Corregí la hora **Hasta**. |
| "Ese horario de inicio ya pasó. Elegí uno más tarde." | Estás reservando para hoy una hora que ya pasó. |
| "No se puede reservar en una fecha que ya pasó." | Elegí un día de hoy en adelante. |
| "Ese sector no se puede reservar." | Elegí un sector de la lista **Lugar**. |
| "Elegí un sector para reservar." | Falta elegir el lugar. |

---

## 8. Educación Física (solo Alumno)

Acá te inscribís a una actividad deportiva (deporte + día + horario). La aplicación usa tu **curso** para que la actividad **no choque con tus clases** de teoría y taller, y controla que haya **cupo**.

### 8.1 Inscribirte
1. Abrí **Educación Física** desde el menú o desde el Inicio.
2. Elegí el **Deporte**, el **Día** y la **Hora**. La primera opción posible ya viene elegida.
   - Los días y horarios que **chocan con tu horario** aparecen en gris, con el aviso "(choca con tu horario)", y no se pueden elegir.
   - Si no hay clase de ese deporte en ese día, aparece "(sin clase)". Si no hay clase en esa combinación, ves "No hay clase de ese deporte en ese día y horario. Probá con otra combinación."
3. Mirá el estado que muestra la pantalla:
   - **"Hay lugar. Cupos libres: X de Y."** → podés inscribirte.
   - **"No hay lugar: todos los cupos están ocupados."** → el botón **Inscribirme** se deshabilita. Elegí otra opción.
4. Tocá **Inscribirme**. Ves **"¡Listo! Quedaste inscripto."**
5. La tarjeta **Tu inscripción** muestra el deporte, el día y el horario (por ejemplo, "Vóley de martes de 14:00 a 15:30 hs"). Antes de inscribirte dice "Todavía no te inscribiste."

`[CAPTURA: edfisica_inscripcion]`

Solo podés tener **una inscripción a la vez**. Si querés otra, cancelá primero la actual.

### 8.2 Cancelar tu inscripción
1. Tocá **Cancelar inscripción**.
2. La aplicación pregunta **"¿Querés cancelar tu inscripción a …? Después vas a poder elegir otra opción."** Elegí **Sí**.
3. Ves "Inscripción cancelada." y podés elegir otra actividad.

### 8.3 Avisos posibles

| Aviso | Qué hacer |
|---|---|
| "Ya estás inscripto. Cancelá tu inscripción antes de elegir otra." | Cancelá la actual primero |
| "Esa opción ya no tiene cupo." | Elegí otro día u horario |
| "Esa opción se superpone con … en tu horario." | Elegí otro día u horario |
| "No tenés ninguna inscripción para cancelar." | No hace falta hacer nada |

> La comparación de horarios solo funciona para los cursos que tienen el horario cargado en la aplicación. Si tu curso no lo tiene, no se detectan choques.

---

## 9. Mi cuenta

Acá ves tus datos y podés cambiar tu curso (si sos Alumno), tu contraseña y tu teléfono.

`[CAPTURA: capturas/alumno_c_p9.png]` (vista de Alumno) · `[CAPTURA: capturas/preceptor_c_p9.png]` (Profesor, Preceptor o Maestranza: sin curso)

### 9.1 Qué ves en la pantalla
- **Mis datos:** tu nombre completo, usuario, DNI, correo, teléfono y rol. Si sos Alumno, también tu **curso** (por ejemplo, "4° 1° Computación"). No se pueden editar desde ahí.
- **Cambiar mi curso** (solo Alumnos).
- **Cambiar contraseña** y **Cambiar teléfono** (todos los roles).

### 9.2 Cambiar tu contraseña (todos los roles)
1. Entrá a **Mi cuenta**.
2. En **Contraseña actual** escribí la que usás hoy.
3. En **Contraseña nueva** escribí la nueva (**4 caracteres o más**, y distinta de la actual).
4. En **Repetí la contraseña nueva** escribila otra vez igual.
5. Hacé clic en **Cambiar contraseña** (o apretá **Enter** en el último campo).
6. Aparece **"Contraseña cambiada. Usala la próxima vez que ingreses."** Los campos quedan vacíos.

`[CAPTURA: cuenta_cambiar_contrasena]`

| Aviso | Qué hacer |
|---|---|
| "Escribí tu contraseña actual." | Completá el primer campo. |
| "La contraseña actual no es correcta." | Revisá cómo la escribiste. |
| "La contraseña nueva necesita 4 caracteres o más." | Elegí una más larga. |
| "Las contraseñas nuevas no son iguales." | Escribí la misma en los dos campos. |
| "Elegí una contraseña distinta de la actual." | La nueva no puede ser igual a la de hoy. |

### 9.3 Cambiar tu teléfono (todos los roles)
1. En **Cambiar teléfono**, escribí el número nuevo **solo con números** (de **8 a 15**, sin espacios ni guiones).
2. Hacé clic en **Guardar teléfono** (o apretá **Enter**).
3. Aparece **"Teléfono actualizado."** y tu teléfono nuevo se ve en **Mis datos**. Es el que ven los demás en tus consultas y productos.

`[CAPTURA: cuenta_cambiar_telefono]`

Avisos: **"Escribí el teléfono nuevo."** (campo vacío) y **"Escribí el teléfono solo con números (entre 8 y 15), sin espacios ni guiones."** (formato incorrecto).

### 9.4 Cambiar tu curso (Alumno)
Tu curso se usa para ver si una actividad de **Educación Física** choca con tus clases, así que conviene mantenerlo al día.
1. En **Cambiar mi curso**, elegí el **año**, la **división** y la **especialidad**.
2. Hacé clic en **Guardar curso**.
3. Aparece **"Cambiaste tu curso."** y **Mis datos** muestra el curso nuevo.
4. Si elegís el curso que **ya tenés**, aparece **"Ese ya es tu curso."** y no se cambia nada.
5. Si dejás algún campo sin elegir, aparece **"Elegí el año, la división y la especialidad."**

`[CAPTURA: cuenta_cambiar_curso]`

**Si ya estás inscripto en Educación Física** y tu inscripción **choca** con el horario del curso nuevo, la aplicación te pregunta antes de cambiar: **"Con ese curso, tu inscripción a Educación Física choca con <materia> y se va a cancelar. ¿Querés cambiar de curso igual?"**
- **Sí:** se cambia el curso, **se cancela** tu inscripción y aparece **"Cambiaste tu curso. Se canceló tu inscripción a Educación Física porque choca con <materia> en tu nuevo horario."** Después podés inscribirte a otra oferta desde **Educación Física**.
- **No:** no cambia nada, tu inscripción sigue y los tres selectores **vuelven a mostrar tu curso de siempre**.

`[CAPTURA: cuenta_confirmar_cambio_curso_con_choque]`

---

## 10. Para todas las pantallas

- **Avisos:** cuando algo no se puede hacer, la aplicación abre una ventana **"Atención"** que dice qué falta o qué corregir. Cuando algo sale bien, la ventana se llama **"Listo"**.
- **Confirmaciones:** cuando una acción no se puede deshacer, la aplicación te hace una **pregunta** con los botones **Sí** y **No**. El que está marcado de entrada es **No**, para que no confirmes sin querer.
- **Cambiar de tema:** con el botón de arriba a la derecha ("Tema oscuro" / "Tema claro"). La aplicación recuerda tu elección.
- **Moverte con el teclado:** con **Tab** pasás de un campo al siguiente, en el orden en que los ves en pantalla. En los formularios de una sola línea, **Enter** envía.
- **Ayuda en pantalla:** pasar el mouse sobre un botón, un campo o un reporte muestra una ayuda corta.
- **Cerrar sesión:** botón del final del menú de la izquierda. Al cerrar sesión se borra lo que habías escrito sin guardar (observaciones, contraseñas, teléfono) y las pantallas vuelven a sus valores de inicio. Cerrá sesión siempre que uses una computadora compartida.

### Qué no hace la aplicación (para no confundirte)
- **No manda notificaciones:** para saber si tu reserva fue aprobada o si un reporte se resolvió, tenés que entrar a la pantalla y mirar.
- **No recupera contraseñas** dentro de la aplicación.
- **No procesa pagos:** en la Tienda, el cobro y la entrega se coordinan en persona.

---

## 11. Si algo no funciona

| Qué pasa | Qué hacer |
|---|---|
| No encuentro un botón | Es posible que tu rol no pueda usarlo |
| Aparece un aviso | Leelo: dice qué corregir |
| Un botón no hace nada | Fijate si tenés que elegir antes un elemento de la lista; si no, la aplicación te lo avisa al apretarlo |
| Aparece "No se pudo usar MySQL" al abrir | La aplicación no se puede usar hasta que se arregle la conexión con la base de datos: cerrala y avisá al responsable del sistema |
| Bloqueo por intentos de contraseña | Cerrá y abrí la aplicación |
| Olvidé mi contraseña | No se recupera desde la aplicación (ver 1.3 y la sección 12) |
| Un producto, objeto o reporte que veía ya no está | Otra persona lo eliminó, archivó o resolvió: volvé a abrir la pantalla para actualizar la lista |

---

## 12. Quién te ayuda en el colegio

| Necesito… | Pedíselo a… |
|---|---|
| El PIN de personal (profesores, preceptores y maestranza, para crear la cuenta) | Preceptoría o dirección, en persona |
| Que me restablezcan la contraseña | El responsable del sistema, con tu DNI como verificación |
| Ayuda si la aplicación no abre o no conecta con la base de datos | El responsable del sistema (soporte técnico de IQUAL) |
