# Historias de Usuario (Backlog Ágil)
**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  
**Marco:** Buenos Aires Aprende (CABA)  

> **Versión del 4° Bimestre.** Las historias y sus criterios de aceptación se ajustaron a la aplicación que se construye (ver [`cambios-respecto-al-diseno-inicial.md`](./cambios-respecto-al-diseno-inicial.md)). Los requerimientos que cubre cada historia están en [`matriz-trazabilidad.md`](./matriz-trazabilidad.md).

---

## Historias de Usuario 🟡

*Desarrollo formal bajo la fórmula:**Como [perfil], quiero [funcionalidad], para [beneficio]**,acompañado de las 3 C (Tarjeta,Conversación y Confirmación).*

### 🟡 US01:Módulo Objetos Perdidos
* **Historia de Usuario:** Como **Preceptor**, quiero **publicar las pertenencias extraviadas que se encuentran en la escuela y aprobar o rechazar los reclamos de los alumnos**,para que **los alumnos puedan identificarlas y solicitar su devolución reduciendo la acumulación en preceptoría**.
* **Criterios de Aceptación (Confirmación):**
  * `1.1` La carga requiere de forma obligatoria un título descriptivo, la categoría del objeto y el sector donde se encontró; la descripción y la foto son opcionales.
  * `1.2` Un alumno solo puede reclamar objetos en estado "Disponible" y debe completar un campo de texto con la prueba de pertenencia (al menos 10 caracteres) antes de confirmar; el reclamo queda "Pendiente" y el objeto pasa a "En reclamo".
  * `1.3` Preceptoría ve los reclamos pendientes y puede **aprobarlos** (el reclamo queda "Aprobado" y el objeto "Devuelto") o **rechazarlos** (el reclamo queda "Rechazado" y el objeto vuelve a "Disponible").
  * `1.4` Preceptoría puede archivar un objeto (estado "Archivado").
  * `1.5` Reclamar no borra el objeto: cada reclamo queda guardado con su fecha y su estado.
  * `1.6` Solo el Alumno puede reclamar (ni el Profesor ni la Maestranza) y no puede cancelar su reclamo una vez enviado; lo resuelve el Preceptor.

### 🟡 US02:Módulo Reporte de Higiene/Mantenimiento
* **Historia de Usuario:** Como **Alumno**,quiero **reportar una avería o falta de higiene en un sector de la escuela**,para que **las autoridades y personal de maestranza conozcan el problema y ordenen su reparación**.
* **Criterios de Aceptación (Confirmación):**
  * `2.1` El formulario ofrece desplegables para seleccionar el sector (ej."Baño planta baja") y el tipo de reporte ("Limpieza","Rotura").
  * `2.2` Permite adjuntar un comentario descriptivo del desperfecto (observaciones).
  * `2.3` Al elegir un sector, la pantalla muestra "Último mantenimiento: dd/MM HH:mm — nombre del responsable" o "ninguno registrado".
  * `2.4` Todo reporte nuevo queda en estado "Pendiente"; Profesor, Preceptor y Maestranza pueden marcarlo como "Resuelto" y el sistema guarda la fecha, la hora y quién lo resolvió.

### 🟡 US03:Módulo Buffet Paralelo y Recaudación
* **Historia de Usuario:** Como **Alumno**,quiero **publicar productos a la venta en el buffet de la aplicación**,para **recaudar fondos destinados a financiar nuestro viaje de egresados**.
* **Criterios de Aceptación (Confirmación):**
  * `3.1` Permite ingresar nombre del producto, precio y stock (ambos mayores a cero) y el grupo de recaudación asociado, que es opcional; si el producto es de un grupo, el alumno debe ser integrante.
  * `3.2` Cada reserva de compra desde la app (cantidad de 1 o más, de un producto con stock y que no sea propio) crea una venta "Reservada" y descuenta automáticamente el stock disponible; si se cancela desde "Mis reservas", el stock se devuelve. El total de la venta se calcula a partir del detalle; no se guarda.
  * `3.3` Incluye una opción clara para registrar donaciones directas (monto entero mayor a cero) destinadas al objetivo del grupo.
  * `3.4` La aplicación no procesa pagos: la entrega y el cobro de lo reservado se coordinan en persona.

### 🟡 US04:Módulo Planillas Digitales de Taller
* **Historia de Usuario:** Como **Profesor o Preceptor**,quiero **registrar en forma digital el préstamo y la devolución de computadoras y tableros**,para **eliminar el uso de planillas de papel manuales y evitar pérdidas de equipamiento**.
* **Criterios de Aceptación (Confirmación):**
  * `4.1` El registro requiere elegir un recurso disponible (carro + número de equipo, ej. "C4-05", o tablero, ej. "Tablero 03") y el alumno solicitante; el curso y la división salen del alumno y el autorizador queda registrado como el usuario con sesión iniciada.
  * `4.2` Un recurso en estado "Prestado" no puede volver a prestarse hasta su devolución.
  * `4.3` Al devolver, el usuario informa si el recurso "Funciona" o "No funciona"; se guarda la hora de devolución y el recurso queda "Disponible" o "Fuera de servicio".
  * `4.4` Provee un buscador rápido por código de recurso, que filtra mientras se escribe, para auditar los préstamos.
  * `4.5` El Alumno solo puede ver las planillas: no registra ni devuelve préstamos.

### 🟡 US05:Módulo Reserva de Sectores
* **Historia de Usuario:** Como **Profesor**,quiero **reservar el laboratorio o la biblioteca eligiendo fecha y horario en un calendario**,para **asegurar la disponibilidad del espacio sin entorpecer a otros profesores, con la aprobación del Preceptor**.
* **Criterios de Aceptación (Confirmación):**
  * `5.1` Solo se pueden reservar los sectores de tipo "Reservable". Ofrece un selector de fecha con calendario desplegable y, para el sector y la fecha elegidos, una lista con la ocupación del día (quién reservó, horario y estado).
  * `5.2` Valida que la hora de fin sea posterior a la de inicio y que la fecha no sea anterior a hoy, e invalida solicitudes superpuestas (mismo sector y fecha, con reservas "Pendiente" o "Aprobada") notificando quién ocupa el sector y en qué horario.
  * `5.3` La reserva de un Profesor queda "Pendiente" hasta que un Preceptor la **apruebe o rechace**; la reserva de un Preceptor queda "Aprobada".
  * `5.4` Una reserva puede cancelarla quien la creó o un Preceptor.

### 🟡 US06:Módulo Educación Física
* **Historia de Usuario:** Como **Alumno**,quiero **inscribirme a una oferta de Educación Física (deporte, día y franja horaria)**,para **cumplir con la materia registrando un horario compatible con mis clases de teoría y taller**.
* **Criterios de Aceptación (Confirmación):**
  * `6.1` Al registrarse,el alumno elige obligatoriamente su curso (año, división y especialidad), que determina el horario de teoría/taller contra el que se cruza su inscripción.
  * `6.2` El sistema cruza los horarios y no permite elegir las ofertas que causen superposiciones: se muestran con la leyenda "se superpone con <materia>".
  * `6.3` Cada oferta tiene un cupo máximo: se muestran los cupos usados y máximos y no se puede inscribir en una oferta completa.
  * `6.4` Cada alumno tiene una única inscripción y puede cancelarla.
  * `6.5` El cruce de horarios funciona solo para los cursos que tienen horario cargado en la base.

### 🟡 US07:Módulo Acceso y Roles
* **Historia de Usuario:** Como **persona de la comunidad escolar (Alumno, Profesor, Preceptor o Maestranza)**,quiero **crear mi cuenta e iniciar sesión con usuario y contraseña**,para **usar solo las funciones que corresponden a mi rol**.
* **Criterios de Aceptación (Confirmación):**
  * `7.1` El registro pide nombre y apellido, usuario, contraseña, DNI, correo, teléfono y rol, y valida: nombre con al menos un espacio; usuario de 3 o más caracteres; contraseña de 4 o más; DNI de 7 u 8 dígitos; correo con "@" y "."; teléfono de 8 a 15 dígitos.
  * `7.2` Usuario, DNI y correo no pueden repetirse: se controla antes de guardar el registro.
  * `7.3` Si el rol es Alumno, elige su curso con tres listas (año, división y especialidad) y "Crear cuenta" permanece deshabilitado hasta completarlo; si la combinación no existe, se crea.
  * `7.4` Los roles Profesor, Preceptor y Maestranza requieren el PIN institucional; con un PIN incorrecto la cuenta no se crea.
  * `7.5` La contraseña se guarda con hash SHA-256 y el inicio de sesión usa usuario y contraseña; Enter confirma el formulario.
  * `7.6` Cada módulo habilita solo las acciones permitidas al rol (tabla de permisos de [`requerimientos.md`](./requerimientos.md)).

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
  * `9.3` La vista del grupo muestra la meta, lo recaudado, el porcentaje y las donaciones recientes (nombre y monto); lo recaudado se calcula como donaciones más ventas no canceladas del grupo.

### 🟡 US10:Módulo Mi Cuenta
* **Historia de Usuario:** Como **usuario del sistema**,quiero **ver mis datos y, si soy Alumno, cambiar mi curso**,para **mantener actualizado el horario contra el que se valida mi inscripción a Educación Física**.
* **Criterios de Aceptación (Confirmación):**
  * `10.1` La pantalla muestra los datos de la cuenta en solo lectura.
  * `10.2` El Alumno puede cambiar su curso con las tres listas (año, división y especialidad).

### 🟡 US11:Módulo Registro de Auditoría
* **Historia de Usuario:** Como **responsable de la escuela (por ejemplo, el Preceptor)**,quiero **que el sistema registre en la base de datos los eventos importantes con su resultado**,para **poder revisar después quién hizo qué y cuándo, sin depender de la memoria de nadie**.
* **Criterios de Aceptación (Confirmación):**
  * `11.1` El sistema registra los 14 tipos de evento (inicio y cierre de sesión, registro de usuario, publicación de objeto, reclamo de objeto, resolución de reclamo, reporte de higiene, resolución de reporte, reserva de producto, donación, préstamo de recurso, devolución de recurso, reserva de sector e inscripción a Educación Física).
  * `11.2` Cada registro guarda fecha y hora, descripción, tipo de evento, entidad afectada, resultado ("Exitoso" o "Fallido"), el nombre del equipo y el usuario implicado, que puede quedar vacío (por ejemplo, un inicio de sesión fallido con un usuario inexistente).
  * `11.3` Cuando una validación de negocio rechaza una acción (por ejemplo, cupo lleno o superposición de horarios), el intento se registra con resultado "Fallido".
  * `11.4` El registro no tiene pantalla en la aplicación: se consulta directamente en la base de datos.
