# Especificación de Requerimientos
**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  
**Marco:** Buenos Aires Aprende (CABA)  
**Plataforma:** Aplicación de escritorio (C++17 · Qt 6)  
**Base de datos:** SQLite en la app; modelo entregado también en SQL Server (scripts para SQL Server 2005) y MySQL. Motor final: a confirmar con el profesor de BBDD  

> **Versión del 4° Bimestre.** Esta especificación se actualizó para describir lo que realmente se construye. Cada cambio respecto del diseño inicial (3er Bimestre) está justificado en [`cambios-respecto-al-diseno-inicial.md`](./cambios-respecto-al-diseno-inicial.md); la relación entre requerimientos, historias, pantallas y tablas está en [`matriz-trazabilidad.md`](./matriz-trazabilidad.md).

---

## 1.Requerimientos Funcionales (RF) 🔵

*Procesos, tareas y funciones operativas obligatorias del software (RF01-RF18).*

| ID | Nombre | Descripción |
| :--- | :--- | :--- |
| **RF01** | Publicación de Objetos Perdidos | El sistema debe permitir al Preceptor publicar las pertenencias extraviadas encontradas en la escuela, cargando título, categoría y sector (obligatorios), y descripción y foto (opcionales). La foto se copia a la carpeta `imagenes_objetos` junto al ejecutable y en la base se guarda solo el nombre del archivo. El objeto se publica en estado "Disponible" y el Preceptor puede archivarlo (estado "Archivado"). |
| **RF02** | Reclamo con Prueba de Pertenencia y Aprobación del Preceptor | El sistema debe permitir al Alumno reclamar un objeto en estado "Disponible" escribiendo una prueba de pertenencia de al menos 10 caracteres. Al confirmar, el reclamo queda "Pendiente" y el objeto pasa a "En reclamo". El Preceptor ve los reclamos pendientes y los **aprueba** (reclamo "Aprobado", objeto "Devuelto"; recién ahí corresponde el retiro físico en preceptoría) o los **rechaza** (reclamo "Rechazado", objeto vuelve a "Disponible"). El objeto no se borra al reclamarlo. **Solo el Alumno puede reclamar** (ni el Profesor ni la Maestranza) y **no puede cancelar su reclamo** una vez enviado: lo resuelve el Preceptor. |
| **RF03** | Reporte de Incidentes de Higiene/Infraestructura | El sistema debe permitir a cualquier usuario con sesión iniciada (Alumno, Profesor, Preceptor o Maestranza) reportar una avería o falta de higiene, seleccionando el sector escolar y el tipo de reporte (Rotura o Limpieza) mediante listas desplegables e ingresando observaciones. El reporte se crea en estado "Pendiente". |
| **RF04** | Trazabilidad de Limpieza Sanitaria | El sistema debe permitir a Profesor, Preceptor y Maestranza marcar un reporte como "Resuelto"; al hacerlo guarda la fecha y hora y el usuario que lo resolvió. Al elegir un sector, se muestra "Último mantenimiento: dd/MM HH:mm — nombre del responsable" o "ninguno registrado". |
| **RF05** | Catálogo de Buffet Paralelo | El sistema debe permitir a los Alumnos publicar productos (tortas, alfajores) especificando nombre, precio y stock (mayores a cero) y, si corresponde, el grupo de recaudación al que pertenece el producto (el alumno debe ser integrante). Cualquier usuario puede reservar un producto con stock que no sea propio, indicando una cantidad de 1 o más: se crea una venta en estado "Reservada" y se descuenta el stock. Desde "Mis reservas" puede cancelarla, y el stock se devuelve. El contacto del vendedor sale de su usuario. El total de cada venta se calcula a partir del detalle (cantidad × precio unitario): no se guarda. |
| **RF06** | Registro de Donaciones Directas | El sistema debe ofrecer a cualquier usuario una opción digital para registrar aportes monetarios voluntarios (monto entero mayor a cero) destinados a un grupo de recaudación (ej. viaje de egresados). Cada donación se guarda con fecha, hora y usuario. No hay método de pago ni comprobante: no se procesan pagos reales. |
| **RF07** | Control Digital de Carros de Computación | El sistema debe permitir a Profesor y Preceptor registrar el préstamo de computadoras eligiendo de una lista el recurso disponible (carro + número de equipo, mostrado como "C4-05") y el alumno solicitante; el curso y la división salen del alumno y el autorizador queda registrado automáticamente (usuario con sesión iniciada), con fecha y hora. El recurso pasa a "Prestado" y no puede volver a prestarse hasta su devolución. Al devolver se informa si "Funciona" o "No funciona": se guarda la hora de devolución y el recurso queda "Disponible" o "Fuera de servicio". La lista de préstamos se puede filtrar por código mientras se escribe. El Alumno solo consulta. El catálogo de carros contiene C1 a C5 (el diseño inicial mencionaba C4/C5; **a confirmar con la escuela** qué carros existen). |
| **RF08** | Control Digital de Tableros de Dibujo | El sistema debe proveer un registro digital idéntico al RF07 (mismos actores, estados, devolución y filtro) para el préstamo e inventario de los tableros de dibujo técnico del taller. El tablero se identifica solo por su número, sin carro (mostrado como "Tablero 03"). |
| **RF09** | Reserva Interactiva de Sectores | El sistema debe permitir a Profesor y Preceptor solicitar el uso de los sectores de tipo "Reservable" (biblioteca, laboratorio de química y los demás sectores con ese tipo en la base; los de tipo "Uso común" no se reservan), eligiendo sector, fecha en un selector con calendario desplegable, hora de inicio y hora de fin. Valida que la hora de fin sea posterior a la de inicio y que la fecha no sea anterior a hoy. Para el sector y la fecha elegidos se muestra una lista con la ocupación del día (quién reservó, horario y estado). La reserva de un Profesor queda "Pendiente"; la de un Preceptor queda "Aprobada". Puede cancelarla quien la creó o un Preceptor. La ocupación se informa con texto y sin código de colores (la aplicación usa una paleta fija de 4 colores). |
| **RF10** | Bloqueo de Superposición de Sectores | El sistema debe rechazar de forma automática las solicitudes que coincidan con otra reserva del mismo sector y la misma fecha en estado "Pendiente" o "Aprobada" (ambos estados cuentan como ocupado), es decir, cuando la hora de inicio existente es menor que la hora de fin nueva y la hora de fin existente es mayor que la hora de inicio nueva. El mensaje de rechazo nombra quién ocupa el sector y en qué horario. |
| **RF11** | Inscripción a Educación Física | El sistema debe permitir al Alumno inscribirse a una oferta de Educación Física (combinación de deporte + día + franja horaria con un cupo máximo), elegida de una lista que muestra los cupos usados y máximos. Cada alumno tiene una única inscripción, puede cancelarla y no puede inscribirse a una oferta sin cupo disponible. |
| **RF12** | Validación Cruzada de Horarios Escolares | El sistema debe bloquear la inscripción a Educación Física si la franja de la oferta se superpone, ese mismo día, con las clases teóricas o de taller del curso del alumno. Las ofertas en conflicto se muestran con la leyenda "se superpone con <materia>" y no se pueden elegir. El cruce usa el horario cargado del curso del alumno: para los cursos sin horario cargado no hay cruce. |
| **RF13** | Autenticación, Registro y Roles con PIN | El sistema debe permitir crear una cuenta con nombre y apellido, usuario, contraseña, DNI, correo, teléfono y rol (Alumno, Profesor, Preceptor o Maestranza), e iniciar sesión con usuario y contraseña. Los roles distintos de Alumno requieren ingresar un PIN institucional. El Alumno elige su curso con tres listas (año, división y especialidad); "Crear cuenta" permanece deshabilitado hasta completarlo y, si esa combinación de curso no existe, se crea. Validaciones: nombre con al menos un espacio; usuario de 3 o más caracteres; contraseña de 4 o más; DNI de 7 u 8 dígitos; correo con "@" y "."; teléfono de 8 a 15 dígitos. Usuario, DNI y correo no pueden repetirse (se controla antes de guardar). Las acciones de cada módulo se habilitan según el rol (sección 3). |
| **RF14** | Consultas de Objetos Perdidos | El sistema debe permitir a cualquier usuario publicar una consulta del tipo "¿Vieron tal cosa?" de al menos 10 caracteres. La consulta muestra la descripción, la fecha y el nombre y teléfono de su autor. Cada usuario puede borrar sus propias consultas y el Preceptor puede borrar cualquiera. |
| **RF15** | Grupos de Recaudación con PIN | El sistema debe permitir al Alumno crear un grupo de recaudación (nombre, meta mayor a cero y PIN de al menos 4 caracteres; el creador queda como integrante) y a los demás alumnos unirse ingresando el PIN correcto, siempre que no sean ya integrantes. La vista de un grupo muestra la meta, lo recaudado, el porcentaje y las donaciones recientes (nombre y monto). Lo recaudado no se guarda: se calcula como donaciones más ventas no canceladas del grupo. |
| **RF16** | Aprobación de Reservas de Sectores | El sistema debe permitir al Preceptor ver las reservas de sectores en estado "Pendiente" y aprobarlas o rechazarlas, quedando registrado quién resolvió. Las reservas "Rechazada" y "Cancelada" dejan de contar como ocupación. |
| **RF17** | Mi Cuenta | El sistema debe mostrar al usuario sus datos en solo lectura y permitir al Alumno cambiar su curso con las tres listas (año, división y especialidad), que es el que se usa para el cruce de horarios de Educación Física. |
| **RF18** | Registro de Auditoría | El sistema debe registrar en `log_auditoria` los eventos importantes, con un único método de registro y con resultado "Exitoso" o "Fallido": inicio de sesión, cierre de sesión, registro de usuario, publicación de objeto, reclamo de objeto, resolución de reclamo (aprobación o rechazo), reporte de higiene, resolución de reporte, reserva de producto, donación, préstamo de recurso, devolución de recurso, reserva de sector (incluida su aprobación o rechazo) e inscripción a Educación Física. Cada registro guarda fecha y hora, descripción del evento, el tipo de evento (`tipo_log`), la entidad afectada (`entidad_log`), el resultado (`resultado_log`) y el usuario implicado, que puede quedar vacío (por ejemplo, un inicio de sesión fallido con un usuario inexistente). En el campo `direccion_ip` se guarda el nombre del equipo, porque una aplicación de escritorio no tiene una IP propia relevante. Los eventos fallidos se registran cuando una validación de negocio rechaza la acción (por ejemplo, cupo lleno o superposición de horarios). **No tiene pantalla:** el registro se consulta solo desde la base de datos. Es el medio de verificación del Marco Lógico que reemplaza a los "logs de uso". |

---

## 2.Requerimientos No Funcionales (RNF) 🟢

*Atributos de calidad,restricciones técnicas e infraestructura del sistema.*

* **RNF01 (Usabilidad):** La interfaz debe ser intuitiva y amigable, siguiendo los principios de consistencia y diseño minimalista para usuarios con distinto nivel técnico, y aplicar las 10 heurísticas de Nielsen ([`maquetado-y-usabilidad.xlsx`](./maquetado-y-usabilidad.xlsx)). Usa una paleta fija de 4 colores, widgets en posiciones fijas (no se adapta a otros tamaños de ventana), atajos con Enter en el inicio de sesión, el registro y los filtros, y ayudas con *tooltips* y textos de ejemplo (*placeholders*) en los campos y botones principales.
* **RNF02 (Seguridad):** Las contraseñas de los usuarios se guardan con hash SHA-256 (nunca en texto plano) en la base de datos local, y todas las consultas SQL son preparadas (`prepare()` + `bindValue()`), sin armar sentencias con texto escrito por el usuario, para prevenir inyecciones de código (SQL Injection). Los formularios, además, validan el formato de los datos antes de guardarlos (ver RF13).
* **RNF03 (Eficiencia/Rendimiento):** *(criterio de medición: propuesta del equipo)* Las consultas a la base de datos (listados de objetos y reclamos, último mantenimiento por sector, vista de grupo del buffet, recursos disponibles de taller, ocupación y solapamiento de sectores, ofertas y cupos de Educación Física) deben mostrar su resultado en menos de 2 segundos.
  * **Cómo se mide (propuesta):** el tiempo corre desde que el usuario dispara la acción (clic en el botón o Enter) hasta que la pantalla muestra el resultado. Se mide con la base local (`iqual.db`) cargada con los datos de demostración, en la PC donde se instala la aplicación y con un único usuario (no hay acceso concurrente en red). Se cronometran 10 repeticiones de cada consulta de la tabla siguiente y el requisito se cumple si ninguna supera los 2 segundos.
  * **Estado:** sin medir en esta versión del documento. Completar la columna "Resultado" cuando se ejecute la prueba.

  | Consulta | Pantalla | Resultado (peor de 10) |
  | :--- | :--- | :--- |
  | Listado de objetos y reclamos pendientes | Objetos Perdidos | pendiente |
  | Último mantenimiento de un sector | Higiene e Infraestructura | pendiente |
  | Vista de grupo (meta, recaudado y %) | Buffet Paralelo | pendiente |
  | Recursos disponibles y filtro por código | Planillas de Taller | pendiente |
  | Ocupación del día y control de solapamiento | Reserva de Sectores | pendiente |
  | Ofertas con cupos y cruce de horarios | Educación Física | pendiente |

* **RNF04 (Escalabilidad y Modularidad):** La aplicación es una sola ventana con un `QStackedWidget` de 10 páginas (0 Landing, 1 Acceso, 2 Dashboard, 3 Objetos, 4 Higiene, 5 Buffet, 6 Planillas, 7 Sectores, 8 Educación Física, 9 Mi Cuenta), con los índices de página definidos en un `enum`: una página por módulo. Cada módulo tiene sus propias tablas y se relaciona con el resto solo a través de las entidades compartidas (`usuario`, `curso`, `sector` y los catálogos), de modo que sumar un módulo nuevo implica agregar una página y sus tablas sin modificar las existentes. La escalabilidad es funcional (más módulos); en usuarios simultáneos está limitada por la base de datos local (ver sección 4), y pasar a un motor de base de datos de servidor con el mismo modelo (SQL Server o MySQL, a confirmar con el profesor de BBDD) queda como evolución futura. La app abre la base en un único método (`abrirBase()`) y registra la auditoría en un único método (`registrarLog`), de modo que cambiar de motor o de criterio de auditoría implica tocar un solo lugar.

---

## 3.Permisos por rol 🔐

*Qué puede hacer cada rol en cada módulo.*

| Acción | Alumno | Profesor | Preceptor | Maestranza |
| :--- | :---: | :---: | :---: | :---: |
| Publicar/gestionar objetos y reclamos | no (reclama) | no | sí | no |
| Reportar higiene | sí | sí | sí | sí |
| Marcar higiene resuelto | no | sí | sí | sí |
| Publicar producto, crear grupo, unirse | sí | no | no | no |
| Reservar producto, donar | sí | sí | sí | sí |
| Registrar/devolver planillas | no (solo ve) | sí | sí | no |
| Reservar sector | no | sí | sí | no |
| Aprobar/rechazar reservas | no | no | sí | no |
| Inscribirse a Educación Física | sí | no | no | no |

---

## 4.Fuera de alcance y limitaciones conocidas ⚠️

* **Fuera de alcance de esta versión:** notificaciones, pagos reales y uso multiusuario en red. El registro de auditoría **sí** está incluido (RF18), pero sin pantalla.
* **Base local:** la base es un archivo local, por lo que funciona en una sola PC (no hay multiusuario en red). Camino de evolución: un motor de servidor (SQL Server o MySQL, a confirmar con el profesor de BBDD) con el mismo modelo.
* **Sin pagos reales:** las reservas del buffet y las donaciones se coordinan en persona.
* **Cruce de horarios de Educación Física:** solo funciona para los cursos que tienen horario cargado en la base.
* **Sin notificaciones en pantalla:** el sistema no avisa a los usuarios de lo que ocurre (por ejemplo, el resultado de un reclamo se ve al entrar a la pantalla).
* **Motor de base de datos:** en la app es SQLite; el Qt 6 para Windows (MinGW) no trae el driver de MySQL precompilado, por lo que usar MySQL desde la app implicaría compilarlo o usar ODBC. Si el proyecto debe correr contra MySQL o SQL Server es una decisión **a confirmar con el profesor de BBDD**.
* **Auditoría sin pantalla:** el registro de auditoría se consulta solo desde la base de datos.
