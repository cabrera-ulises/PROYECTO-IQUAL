# Historias de Usuario (Backlog Ágil)
> Actualizada a la app v3 (`iqual_integrado_v3`, CONTEXTO §20, 13/11/2026). Los números de criterio no cambian.

**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  
**Marco:** Buenos Aires Aprende (CABA)  

> **Versión de la fase final del 4° Bimestre (lote 2, etapa 3 y rediseño).** Las historias y sus criterios de aceptación se ajustaron a la aplicación que se construye (ver [`cambios-respecto-al-diseno-inicial.md`](./cambios-respecto-al-diseno-inicial.md)). Los requerimientos que cubre cada historia están en [`matriz-trazabilidad.md`](./matriz-trazabilidad.md).

---

## Historias de Usuario 🟡

*Desarrollo formal bajo la fórmula:**Como [perfil], quiero [funcionalidad], para [beneficio]**,acompañado de las 3 C (Tarjeta,Conversación y Confirmación).*

### 🟡 US01:Módulo Objetos Perdidos
* **Historia de Usuario:** Como **Preceptor**, quiero **publicar las pertenencias extraviadas que se encuentran en la escuela y aprobar o rechazar los reclamos de los alumnos**,para que **los alumnos puedan identificarlas y solicitar su devolución reduciendo la acumulación en preceptoría**.
* **Criterios de Aceptación (Confirmación):**
  * `1.1` La carga requiere de forma obligatoria un título descriptivo, la categoría del objeto y el sector donde se encontró; la descripción, la foto y el dato reservado (hasta 200 caracteres, que solo ve el Preceptor) son opcionales.
  * `1.2` Un alumno puede reclamar cualquier objeto que no esté "Devuelto" ni "Archivado", una sola vez por objeto, y debe escribir un detalle de al menos 10 caracteres; el reclamo queda "Pendiente" y el objeto **sigue en la lista**. Los alumnos ven solo la cantidad de reclamos ("N reclamos").
  * `1.3` En la pestaña "Reclamos", Preceptoría ve cada reclamo pendiente con el detalle del alumno y el dato reservado, y puede **aprobarlo** (reclamo "Aprobado", objeto "Devuelto" y los otros reclamos del objeto pasan a "Rechazado") o **rechazarlo** (reclamo "Rechazado", el objeto sigue en la lista). Ambas acciones piden confirmación Sí/No.
  * `1.4` Preceptoría puede archivar un objeto (estado "Archivado") después de confirmar.
  * `1.5` Reclamar no borra el objeto: cada reclamo queda guardado con su fecha y su estado.
  * `1.6` Solo el Alumno puede reclamar (ni el Profesor ni la Maestranza) y no puede cancelar su reclamo una vez enviado; lo resuelve el Preceptor.
  * `1.7` Con doble clic en un objeto se abre su detalle (título, descripción y foto; el Preceptor ve además el dato reservado). Los objetos devueltos se ven en gris como "Ya devuelto".

### 🟡 US02:Módulo Reporte de Higiene/Mantenimiento
* **Historia de Usuario:** Como **Alumno**,quiero **reportar una avería o falta de higiene en un sector de la escuela**,para que **las autoridades y personal de maestranza conozcan el problema y ordenen su reparación**.
* **Criterios de Aceptación (Confirmación):**
  * `2.1` El formulario ofrece desplegables para seleccionar el sector (ej."Baño planta baja") y el tipo de reporte ("Limpieza","Rotura").
  * `2.2` Permite adjuntar un comentario descriptivo del desperfecto (observaciones).
  * `2.3` Al elegir un sector, la pantalla muestra el último mantenimiento (fecha, hora y nombre del responsable) o "Todavía no hay ninguno".
  * `2.4` Todo reporte nuevo queda en estado "Pendiente"; Profesor, Preceptor y Maestranza pueden marcarlo como "Resuelto" y el sistema guarda la fecha, la hora y quién lo resolvió.
  * `2.5` La lista de reportes se puede filtrar por Todos, Pendientes o Resueltos y muestra primero los pendientes; el estado se ve en texto y con color (pendiente en rojo, resuelto en verde).

### 🟡 US03:Módulo Tienda de Alumnos y Recaudación
* **Historia de Usuario:** Como **Alumno**,quiero **publicar productos a la venta en la tienda de la aplicación**,para **recaudar fondos destinados a financiar nuestro viaje de egresados o vender cosas entre compañeros**.
* **Criterios de Aceptación (Confirmación):**
  * `3.1` Permite ingresar nombre, categoría (Comida, Bebida, Accesorios, Ropa u Otros), precio y stock (enteros mayores a cero), una foto opcional (.png o .jpg) y el grupo de recaudación asociado, que es opcional; si el producto es de un grupo, el alumno debe ser integrante.
  * `3.2` Cada reserva de compra desde la app (cantidad de 1 o más, de un producto con stock y que no sea propio) crea una venta "Reservada" y descuenta automáticamente el stock disponible; si se cancela desde "Mis reservas" (con confirmación), el stock se devuelve. El total de la venta se calcula a partir del detalle; no se guarda.
  * `3.3` Incluye una opción clara para registrar donaciones directas (monto entero mayor a cero) destinadas al objetivo del grupo.
  * `3.4` La aplicación no procesa pagos: la entrega y el cobro de lo reservado se coordinan en persona.
  * `3.5` La lista de productos se filtra por categoría, por vendedor ("Productos sueltos de alumnos" o un grupo) y por texto; los productos sin stock aparecen como "SIN STOCK".

### 🟡 US04:Módulo Préstamo de Equipos
* **Historia de Usuario:** Como **Profesor o Preceptor** (y, a su propio nombre, como **Alumno**),quiero **registrar en forma digital el préstamo y la devolución de computadoras y tableros**,para **eliminar el uso de planillas de papel manuales y evitar pérdidas de equipamiento**.
* **Criterios de Aceptación (Confirmación):**
  * `4.1` El registro requiere elegir un recurso disponible (carro + número de equipo, ej. "C4-05", o tablero, ej. "Tablero 03") y el alumno solicitante; el curso y la división salen del alumno y el autorizador queda registrado como el usuario con sesión iniciada. Cuando el que registra es un Alumno, el préstamo queda siempre a su nombre.
  * `4.2` Un recurso en estado "Prestado" no puede volver a prestarse hasta su devolución, y un alumno no puede tener más de un préstamo activo.
  * `4.3` Al devolver, el usuario informa si el recurso "Funciona" o "No funciona" (en este caso confirma con Sí/No); se guarda la hora de devolución y el recurso queda "Disponible" o "Fuera de servicio". Un Alumno solo puede devolver sus propios préstamos.
  * `4.4` Provee un buscador rápido por código de recurso, que filtra mientras se escribe, para auditar los préstamos.
  * `4.5` El Alumno solo registra préstamos a su nombre, solo devuelve los suyos y **solo ve sus propios préstamos** (sin préstamos, la pantalla dice «Todavía no tenés préstamos registrados.»); Profesor, Preceptor y Maestranza ven todos.
  * `4.6` La Maestranza no registra préstamos; puede ver la pantalla y reparar equipos (ver US13).

### 🟡 US05:Módulo Reserva de Sectores
* **Historia de Usuario:** Como **Profesor**,quiero **reservar el laboratorio o la biblioteca eligiendo fecha y horario en un calendario**,para **asegurar la disponibilidad del espacio sin entorpecer a otros profesores, con la aprobación del Preceptor**.
* **Criterios de Aceptación (Confirmación):**
  * `5.1` Solo se pueden reservar los sectores de tipo "Reservable". Ofrece un selector de fecha con calendario desplegable y, para el sector y la fecha elegidos, una lista con la ocupación del día (quién reservó, horario y estado).
  * `5.2` Valida que la hora de fin sea posterior a la de inicio, que la fecha no sea anterior a hoy, que el horario esté entre las 07:00 y las 19:00 y que, si la reserva es para hoy, la hora de inicio no haya pasado, e invalida solicitudes superpuestas (mismo sector y fecha, con reservas "Pendiente" o "Aprobada") notificando quién ocupa el sector y en qué horario.
  * `5.3` La reserva de un Profesor queda "Pendiente" hasta que un Preceptor la **apruebe o rechace**; la reserva de un Preceptor queda "Aprobada".
  * `5.4` Una reserva puede cancelarla quien la creó o un Preceptor, con confirmación Sí/No; el Preceptor confirma también el rechazo de una reserva pendiente.
  * `5.5` El estado de cada reserva se ve en texto y con color (por ejemplo, Aprobada en verde); el Alumno y la Maestranza solo consultan la ocupación.

### 🟡 US06:Módulo Educación Física
* **Historia de Usuario:** Como **Alumno**,quiero **inscribirme a una opción de Educación Física eligiendo deporte, día y hora en listas desplegables**,para **cumplir con la materia registrando un horario compatible con mis clases de teoría y taller**.
* **Criterios de Aceptación (Confirmación):**
  * `6.1` Al registrarse,el alumno elige obligatoriamente su curso (año, división y especialidad), que determina el horario de teoría/taller contra el que se cruza su inscripción.
  * `6.2` El sistema cruza los horarios: los días y horas que no tienen clase o que se superponen con una materia del curso **se ven en gris y no se pueden elegir** ("(sin clase)" o "(choca con <materia>)").
  * `6.3` Cada opción tiene un cupo máximo: la franja de estado muestra los cupos libres y no se puede inscribir en una opción completa.
  * `6.4` Cada alumno tiene una única inscripción y puede cancelarla (con confirmación Sí/No) para elegir otra.
  * `6.5` El cruce de horarios funciona solo para los cursos que tienen horario cargado en la base.
  * `6.6` "Inscribirme" está habilitado solo si hay oferta, cupo, no hay choque y el alumno no tiene otra inscripción; la franja de estado explica el motivo en cada caso.
  * `6.7` Si el alumno cambia de curso y su inscripción choca con el horario nuevo, se le avisa y, si acepta, la inscripción se cancela (RF23).

### 🟡 US07:Módulo Acceso y Roles
* **Historia de Usuario:** Como **persona de la comunidad escolar (Alumno, Profesor, Preceptor o Maestranza)**,quiero **crear mi cuenta e iniciar sesión con usuario y contraseña**,para **usar solo las funciones que corresponden a mi rol**.
* **Criterios de Aceptación (Confirmación):**
  * `7.1` El registro pide nombre y apellido, usuario, contraseña, DNI, correo, teléfono y rol, y valida: nombre con al menos un espacio; usuario de 3 o más caracteres; contraseña de 4 o más; DNI de 7 u 8 dígitos; correo con "@" y "."; teléfono de 8 a 15 dígitos.
  * `7.2` Usuario, DNI y correo no pueden repetirse: se controla antes de guardar el registro.
  * `7.3` Si el rol es Alumno, elige su curso con tres listas (año, división y especialidad) y "Crear cuenta" permanece deshabilitado hasta completarlo; si la combinación no existe, se crea.
  * `7.4` Los roles Profesor, Preceptor y Maestranza requieren el PIN institucional; con un PIN incorrecto la cuenta no se crea.
  * `7.5` La contraseña se guarda con hash SHA-256 y el inicio de sesión usa usuario y contraseña; Enter confirma el formulario. Después de 5 intentos fallidos seguidos hay que cerrar y volver a abrir la aplicación.
  * `7.6` Cada módulo muestra solo las pestañas, botones y módulos permitidos al rol: lo que el rol no puede usar se oculta (tabla de permisos de [`requerimientos.md`](./requerimientos.md)).
  * `7.7` El Dashboard muestra tres indicadores según el rol (por ejemplo, el Preceptor ve reclamos, reservas y reportes pendientes; el Alumno ve sus reclamos, reservas y préstamos).

### 🟡 US08:Módulo Consultas de Objetos Perdidos
* **Historia de Usuario:** Como **Alumno**,quiero **publicar una consulta del tipo "¿Vieron tal cosa?" sobre algo que perdí**,para **que otras personas de la escuela me ayuden a encontrarlo**.
* **Criterios de Aceptación (Confirmación):**
  * `8.1` Cualquier usuario puede publicar una consulta, que debe tener al menos 10 caracteres.
  * `8.2` Cada consulta muestra la descripción, la fecha y el nombre y teléfono de su autor.
  * `8.3` Cada usuario puede borrar sus propias consultas; el Preceptor puede borrar cualquiera.

### 🟡 US09:Módulo Grupos de Recaudación
* **Historia de Usuario:** Como **Alumno**,quiero **crear un grupo de recaudación con una meta y un PIN, y que mis compañeros se unan con ese PIN**,para **juntar fondos entre todos (ej. el viaje de egresados) y ver cuánto falta**.
* **Criterios de Aceptación (Confirmación):**
  * `9.1` Para crear un grupo se ingresa nombre (no repetido), meta mayor a cero y PIN de al menos 4 caracteres; el creador queda como integrante.
  * `9.2` Un alumno se une solo si ingresa el PIN correcto y no es ya integrante.
  * `9.3` La vista del grupo muestra la meta, lo recaudado, el porcentaje y las donaciones recientes (nombre y monto); lo recaudado se calcula como donaciones más ventas "Entregadas" del grupo.

### 🟡 US10:Módulo Mi Cuenta
* **Historia de Usuario:** Como **usuario del sistema**,quiero **ver mis datos, cambiar mi contraseña y mi teléfono y, si soy Alumno, cambiar mi curso**,para **mantener mis datos al día y el horario contra el que se valida mi inscripción a Educación Física**.
* **Criterios de Aceptación (Confirmación):**
  * `10.1` La pantalla muestra los datos de la cuenta.
  * `10.2` El Alumno puede cambiar su curso con las tres listas (año, división y especialidad). Si la combinación no existe, la app la crea (limitación declarada). Si elige el curso que ya tiene, la app dice «Ese ya es tu curso.» y no cambia nada; si responde «No» al aviso de choque con Educación Física, las listas vuelven al curso anterior.
  * `10.3` Cualquier usuario puede cambiar su contraseña indicando la actual, una nueva de 4 o más caracteres y repitiéndola.
  * `10.4` Cualquier usuario puede cambiar su teléfono (8 a 15 dígitos).

### 🟡 US11:Módulo Registro de Auditoría
* **Historia de Usuario:** Como **responsable de la escuela (por ejemplo, el Preceptor)**,quiero **que el sistema registre en la base de datos los eventos importantes con su resultado**,para **poder revisar después quién hizo qué y cuándo, sin depender de la memoria de nadie**.
* **Criterios de Aceptación (Confirmación):**
  * `11.1` El sistema registra los 14 tipos de evento (inicio y cierre de sesión, registro de usuario, publicación de objeto, reclamo de objeto, resolución de reclamo, reporte de higiene, resolución de reporte, reserva de producto, donación, préstamo de recurso, devolución de recurso, reserva de sector e inscripción a Educación Física).
  * `11.2` Cada registro guarda fecha y hora, descripción, tipo de evento, entidad afectada, resultado ("Exitoso" o "Fallido"), el nombre del equipo y el usuario implicado, que puede quedar vacío (por ejemplo, un inicio de sesión fallido con un usuario inexistente).
  * `11.3` Cuando una validación de negocio rechaza una acción (por ejemplo, cupo lleno o superposición de horarios), el intento se registra con resultado "Fallido".
  * `11.4` El Preceptor ve los últimos 50 registros en la pestaña "Auditoría" de Objetos Perdidos, con filtro Todos / Exitoso / Fallido; el resto se consulta directamente en la base de datos.
  * `11.5` Cambiar la contraseña o el teléfono y marcar un equipo como reparado no generan registro.

### 🟡 US12:Módulo Mis Productos y Mis Ventas
* **Historia de Usuario:** Como **Alumno vendedor**,quiero **ver quién reservó mis productos, marcar las entregas y administrar mi stock**,para **llevar el control de lo que vendo sin errores**.
* **Criterios de Aceptación (Confirmación):**
  * `12.1` En "Mis ventas" veo las reservas de mis productos y puedo marcar una como "Entregada" o cancelarla con confirmación; al cancelar, el stock vuelve a mi producto.
  * `12.2` En "Mis productos" puedo reponer stock y quitar stock; no puedo quitar más unidades de las que hay.
  * `12.3` Puedo eliminar un producto con confirmación; no se puede si tiene reservas activas o si ya tuvo ventas; al eliminarlo se borra su foto.
  * `12.4` Solo el Alumno ve estas pestañas.

### 🟡 US13:Módulo Programas y Reparación de Equipos
* **Historia de Usuario:** Como **Profesor, Preceptor o Maestranza**,quiero **saber qué programas tiene cada computadora y marcar como reparados los equipos que estaban fuera de servicio**,para **elegir el equipo adecuado para cada clase y mantener el inventario al día**.
* **Criterios de Aceptación (Confirmación):**
  * `13.1` Al elegir un equipo se muestran los programas instalados, y la lista de equipos se puede filtrar por programa.
  * `13.2` Hay una lista de equipos "Fuera de servicio" y solo el Preceptor y la Maestranza pueden marcarlos como reparados; el equipo vuelve a "Disponible" y se puede prestar.
