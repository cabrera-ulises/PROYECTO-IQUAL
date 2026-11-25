# Stored Procedures de funcionalidades 1 a 8 — fichas para la defensa técnica

PROYECTO IQUAL® (SGE) · MySQL 8 / MariaDB 10.11 · archivo `05a_Backend_funcionalidades_1_a_8.sql` · pruebas en `06_PruebasSQL_claude2.xlsx`.

## Cómo están armados (vale para los 8)

- **Estilo de la clase 006:** `DELIMITER //`, `DROP PROCEDURE IF EXISTS` (se pueden volver a ejecutar), parámetros `p_...` y un `DECLARE EXIT HANDLER FOR SQLEXCEPTION` con `GET DIAGNOSTICS CONDITION 1` que captura `MYSQL_ERRNO` y `MESSAGE_TEXT`.
- **Reglas de negocio con `SIGNAL SQLSTATE '45000'`:** es el equivalente del `RAISERROR` de la clase 003. El handler atrapa ese error y devuelve una fila `estado = 'ERROR'`, `codigo_sql = 1644`, `descripcion_error = <el mensaje>`. Los mensajes son los mismos de la app (`mainwindow.cpp`).
- **Si todo sale bien:** devuelven una fila `estado = 'OK'`, el id creado y un `mensaje`.
- **Transacción:** `START TRANSACTION` antes de escribir y `COMMIT` al final. Si algo falla, el handler hace `ROLLBACK`: nunca queda un préstamo sin cambiar el estado del equipo, ni una reserva sin su log.
- **Auditoría:** todos llaman a `sp_registrar_log`, con resultado `Exitoso` al terminar bien y `Fallido` en el handler. Así `log_auditoria` se llena sola al ejecutar los SP.
- **Quién actúa:** se identifica por `usuario_nick` y los catálogos por nombre, como hace la app. El rol se controla dentro del SP con el mensaje `Esta acción es solo para estos roles: ...`.
- **Qué se usa de SQL:** `JOIN`, `WHERE`, `COUNT`, `IN`, `LIMIT`, `COALESCE`/`NULLIF`, `TRIM`, `CURDATE`/`NOW`/`CURTIME`, `IF/ELSEIF`, variables `DECLARE`. No hay cursores, triggers, SQL dinámico ni expresiones regulares.
- **Silenciar el log:** cada SP pone `@iqual_log_silencioso = 1` antes de llamar a `sp_registrar_log` para que el log no agregue una segunda fila de resultado. Es una variable de sesión; vale 0 si nadie la tocó.

---

## 1. `sp_registrar_log`

**Para qué sirve:** guarda un evento en `log_auditoria` con la fecha y hora actuales. Es la base: los otros 7 la llaman.

**Parámetros:** `p_evento` (nombre en `tipo_log`), `p_descripcion`, `p_entidad` (nombre en `entidad_log`), `p_nick`, `p_resultado` (`Exitoso` o `Fallido`), `p_ip`.

**Reglas:**
- La descripción es obligatoria (se recorta a 200 caracteres).
- Evento, entidad y resultado tienen que existir en sus catálogos.
- Si `p_nick` es NULL o no existe, `id_usuario` queda en NULL (la columna lo admite).
- Si `p_ip` viene vacía se guarda el host del cliente: `SUBSTRING_INDEX(USER(), '@', -1)`.
- Si falla estando en modo silencioso, no tumba la operación que la llamó.

**Devuelve:** `OK` + `id_log` + `mensaje`, o la fila `ERROR` (salvo en modo silencioso).

```sql
CALL sp_registrar_log('Inicio de sesión', 'Inicio de sesión exitoso de alumno1', 'usuario', 'alumno1', 'Exitoso', 'PC-LAB-01');
```

## 2. `sp_registrar_usuario`

**Para qué sirve:** alta de cuenta con las mismas validaciones del formulario de registro.

**Parámetros:** `p_dni, p_nombre, p_nick, p_hash, p_email, p_telefono, p_rol, p_anio, p_division, p_especialidad`.

**Reglas (en este orden):**
- Nombre con al menos un espacio (máximo 80).
- Usuario de 3 a 50 caracteres; se guarda en minúsculas y sin espacios de los costados.
- `p_hash` tiene que ser el SHA-256 en hexadecimal (64 caracteres): el SP no ve la clave, solo el hash.
- DNI de 7 u 8 dígitos y mayor o igual a 1.000.000; teléfono de 8 a 15 dígitos (los controla el auxiliar `sp_aux_solo_digitos`, que va quitando dígitos con `REPLACE`).
- Correo con `@` y `.` (máximo 80).
- Rol existente. Después se controla que usuario, DNI y correo no estén usados.
- Si el rol es Alumno hacen falta año, división y especialidad existentes; se busca el curso y, si no existe, se crea. Para los demás roles `id_curso` queda NULL.

**Devuelve:** `OK` + `id_usuario` + `Cuenta creada. Ya podés iniciar sesión.`. En el log el usuario del evento exitoso es la cuenta nueva; en el fallido es NULL (todavía no hay sesión).

```sql
CALL sp_registrar_usuario('45123456', 'Prueba Alumno', 'prueba.alumno',
  '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4',
  'prueba.alumno@iqual.demo', '1155559999', 'Alumno', 4, 1, 'Computación');
```

## 3. `sp_publicar_objeto`

**Para qué sirve:** da de alta un objeto perdido. Solo lo hace el Preceptor.

**Parámetros:** `p_nick, p_titulo, p_descripcion, p_categoria, p_sector, p_detalle_reservado, p_ruta_foto`.

**Reglas:**
- Usuario existente con rol Preceptor.
- Título obligatorio (máximo 80); categoría y sector tienen que existir (se buscan por nombre).
- Descripción y dato reservado hasta 200 caracteres, foto hasta 150. Los opcionales vacíos o con solo espacios se guardan como NULL.
- Estado inicial `Disponible`; `fecha_registro` es hoy.

**Devuelve:** `OK` + `id_objeto` + `Objeto publicado.`.

```sql
CALL sp_publicar_objeto('preceptor1', 'Mochila negra', 'Mochila negra con un llavero de Qt', 'Otros', 'Patio', 'Tiene un cuaderno de Bases de Datos adentro', 'mochila_negra.png');
```

## 4. `sp_reclamar_objeto`

**Para qué sirve:** un Alumno reclama un objeto; crea el reclamo en estado `Pendiente`.

**Parámetros:** `p_nick, p_id_objeto, p_prueba`.

**Reglas:**
- Usuario con rol Alumno; objeto elegido y existente.
- No se reclama un objeto `Devuelto` o `Archivado`.
- El detalle necesita 10 caracteres o más (máximo 200).
- Un solo reclamo por alumno y objeto (hay un índice único `ux_reclamo_usuario_objeto`).
- Igual que la app, el objeto **no** cambia de estado al reclamarse: cambia cuando el Preceptor resuelve.

**Devuelve:** `OK` + `id_reclamo` + `Reclamo enviado. El preceptor lo va a revisar.`.

```sql
CALL sp_reclamar_objeto('alumno1', 1, 'Es mi campera, tiene un parche en la manga izquierda');
```

## 5. `sp_resolver_reclamo`

**Para qué sirve:** el Preceptor aprueba o rechaza un reclamo Pendiente.

**Parámetros:** `p_nick_preceptor, p_id_reclamo, p_aprobar` (1 aprueba, 0 rechaza).

**Reglas:**
- Usuario con rol Preceptor; reclamo elegido y existente; `p_aprobar` tiene que ser 0 o 1; el reclamo tiene que estar Pendiente (`Ese reclamo ya fue resuelto.`).
- **Aprobar:** el reclamo pasa a Aprobado, los otros reclamos Pendientes del mismo objeto pasan a Rechazado y el objeto queda `Devuelto`.
- **Rechazar:** el reclamo pasa a Rechazado. El objeto solo vuelve a `Disponible` si estaba `En reclamo` y no le quedan reclamos Pendientes (con la app actual el objeto nunca llega a `En reclamo`, así que en la práctica no cambia).
- Lee el reclamo con `FOR UPDATE` para que dos preceptores no lo resuelvan a la vez.

**Devuelve:** `OK` + `id_reclamo` + `resultado` (`Aprobado` o `Rechazado`) + `mensaje`.

```sql
CALL sp_resolver_reclamo('preceptor1', 1, 1);
```

## 6. `sp_prestar_equipo`

**Para qué sirve:** registra el préstamo de una computadora o un tablero y pasa el equipo a `Prestado`.

**Parámetros:** `p_nick_solicitante, p_nick_autorizador, p_id_recurso, p_observaciones`.

**Reglas:**
- Autoriza un Alumno, un Profesor o un Preceptor. Un Alumno solo puede retirar a su propio nombre.
- El solicitante tiene que ser Alumno y no puede tener otro equipo sin devolver (los mensajes cambian si se retira uno mismo o lo hace otro).
- El equipo tiene que existir y estar `Disponible` (se lee con `FOR UPDATE`).
- Observaciones opcionales, hasta 200 caracteres. Guarda fecha de hoy y hora actual `HH:MM`.

**Devuelve:** `OK` + `id_prestamo` + `equipo` (por ejemplo `C4-01` o `Tablero 03`) + `Préstamo registrado.`.

```sql
CALL sp_prestar_equipo('alumno2', 'profe1', 1, 'Para la clase de Bases de Datos');
```

## 7. `sp_devolver_equipo`

**Para qué sirve:** cierra un préstamo con la hora actual y deja el equipo `Disponible` o `Fuera de servicio`.

**Parámetros:** `p_id_prestamo, p_nick_autorizador, p_funciona` (1 funciona, 0 no funciona), `p_observaciones`.

**Reglas:**
- Alumno, Profesor o Preceptor. Un Alumno solo devuelve sus propios préstamos.
- Préstamo elegido, existente y sin devolver (`Ese préstamo ya fue devuelto.`); `p_funciona` obligatorio (0 o 1).
- Si hay observaciones nuevas se agregan a las anteriores con ` / Devolución: `; el total no puede pasar de 200 caracteres.
- La confirmación «vas a devolverlo como que NO funciona» es de la pantalla: el SP no pregunta.

**Devuelve:** `OK` + `id_prestamo` + `estado_recurso` + `Devolución registrada.`.

```sql
CALL sp_devolver_equipo(1, 'alumno1', 1, 'Todo bien');
```

## 8. `sp_reservar_sector`

**Para qué sirve:** reserva un sector reservable en una fecha y un horario.

**Parámetros:** `p_nick, p_sector, p_fecha, p_hora_inicio, p_hora_fin` (horas como texto `HH:MM`; `9:00` se normaliza a `09:00`).

**Reglas (en este orden):**
- Rol Profesor o Preceptor; sector elegido y existente; el sector tiene que ser de tipo `Reservable`.
- Fecha elegida y no pasada; horas válidas; fin posterior al inicio; horario entre 07:00 y 19:00 (las constantes de la app).
- Si la fecha es hoy, el inicio no puede ser anterior a la hora actual.
- Superposición: mismo sector y fecha, reserva `Pendiente` o `Aprobada`, con `hora_inicio < nuevo_fin AND hora_fin > nuevo_inicio`. El mensaje nombra quién lo tiene y en qué horario.
- El Preceptor deja la reserva `Aprobada` y queda como autorizador; el Profesor la deja `Pendiente`.

**Devuelve:** `OK` + `id_reserva` + `estado_reserva` + `mensaje`.

```sql
CALL sp_reservar_sector('profe1', 'Biblioteca', DATE_ADD(CURDATE(), INTERVAL 30 DAY), '16:00', '17:00');
```

---

## Qué decir en la defensa

- **Por qué un SP y no SQL suelto en la app:** las reglas y el registro de auditoría viven en un solo lugar y se prueban sin abrir la interfaz.
- **Por qué `ROLLBACK`:** cada funcionalidad toca varias tablas; o se guarda todo o no se guarda nada.
- **Por qué los fallos también se auditan:** un intento rechazado (cupo, superposición, permiso) es información de seguridad.
- **Límite conocido:** el control de superposición lee y después inserta; con dos usuarios reservando el mismo instante exacto podría colarse un choque. En un colegio con pocas reservas se acepta y se declara.

## Casos extra que conviene probar a mano (no están entre los 32 de la planilla)

- `sp_reservar_sector` con un horario superpuesto a la reserva demo de la Biblioteca de mañana (10:00–11:00): debe dar `Ese horario está ocupado: Profesor Uno tiene el sector de 10:00 a 11:00. Probá con otro.`.
- `sp_reservar_sector` con un sector de uso común (por ejemplo `Patio`): `Ese sector no se puede reservar.`.
- `sp_prestar_equipo` con `alumno1` (ya tiene la C4-05): `Ya tenés un equipo prestado...` o `Ese alumno ya tiene un equipo prestado...`.
- `sp_prestar_equipo` con el Tablero 07 (Fuera de servicio): `Ese equipo no está disponible.`.
- `sp_reclamar_objeto` repetido por el mismo alumno: `Ya reclamaste este objeto. Solo se puede reclamar una vez.`.
- `sp_reclamar_objeto` sobre la `Calculadora científica` (Devuelto): `Este objeto ya no se puede reclamar...`.
- `sp_registrar_usuario` con un nick, DNI o correo repetido.

## Desvíos

1. **`sp_aux_solo_digitos` (SP extra).** El contrato pide 8 SP; agregué este auxiliar porque sin expresiones regulares había que repetir diez `REPLACE` en dos lugares. Arce Thiago y Cabrera Ulises lo tiene que incluir en `05_Backend` (va en el mismo archivo, antes de `sp_registrar_usuario`).
2. **Variable de sesión `@iqual_log_silencioso`.** El contrato dice que cada SP llama a `sp_registrar_log` y a la vez que cada SP devuelve una fila `estado`. Con las dos cosas a la vez el cliente recibiría dos resultados y la app leería primero el del log. Mi solución es esa variable; no está en el contrato. **Los SP 9 a 15 de Arce Thiago y Cabrera Ulises y los de Arce Thiago y Cabrera Ulises tienen que hacer lo mismo** (`SET @iqual_log_silencioso = 1;` antes de cada `CALL sp_registrar_log` y `= 0` después), o Arce Thiago y Cabrera Ulises lo corrige al unir. Si un SP no la pone, el log devuelve su fila `OK` y la app (o el cliente) verá ese resultado primero.
3. **El PIN de personal no se controla en el SP.** La app valida `IQUAL2026` antes de registrar a un Profesor, Preceptor o Maestranza (`PIN_PERSONAL` en `mainwindow.cpp`); la firma del contrato no tiene parámetro para eso. Hoy cualquiera que haga `CALL sp_registrar_usuario(..., 'Preceptor', ...)` crea un Preceptor. Opciones para Arce Thiago y Cabrera Ulises: seguir controlando el PIN en la app antes del `CALL` (lo más simple) o agregar un parámetro `p_pin`.
4. **La longitud mínima de la contraseña (4) no se puede controlar:** el SP recibe el hash. Solo valida que sea de 64 caracteres. Sigue en la app.
5. **`sp_reclamar_objeto`: se sigue la app, no el §6.** El §6 y el contrato dicen «exige objeto Disponible» y «pasa el objeto a En reclamo»; la app v3 permite reclamar un objeto ya reclamado por otro (solo bloquea `Devuelto` y `Archivado`), no cambia el estado del objeto y cuenta como «para reclamar» los que están `Disponible`. Si Arce Thiago y Cabrera Ulises prefiere el §6, hay que cambiar el SP **y** la app a la vez. También por eso en `sp_resolver_reclamo` rechazar no cambia el objeto, salvo que estuviera `En reclamo` sin otros reclamos pendientes.
6. **§8 del contexto desactualizado:** dice que «Llaves con llavero rojo» está `En reclamo`; el script `03_ModeloSQL_Grupo06.sql y 04_DatosSQL_Grupo06.sql` la carga `Disponible`. Las pruebas usan lo que dice el script.
7. **Horario de reservas 07:00 a 19:00:** es lo que valida la app hoy (`HORA_APERTURA`/`HORA_CIERRE`). Hay una nota vieja del proyecto con el horario de alumnos de 7:35 a 10:45; si ese es el que vale, hay que cambiar las dos constantes del SP 8 y de la app.
8. **`sp_prestar_equipo` y `sp_devolver_equipo` rechazan lo que la app resolvía en silencio.** Un Alumno que autoriza para otro alumno: la app lo pisaba con su propio id; el SP da error `Un alumno solo puede retirar un equipo a su propio nombre.`. Además el solicitante tiene que ser Alumno. Los mensajes de estos dos casos son nuevos (la app no los tiene).
9. **Mensajes nuevos para casos que la app resolvía con un combo** (no pueden existir en pantalla, sí en un `CALL`): `No se encontró el usuario indicado.`, `No se encontró el objeto/reclamo/equipo/préstamo/sector indicado.`, `Elegí un rol válido...`, `El año/la división/la especialidad elegida no existe.`, `Indicá si aprobás (1) o rechazás (0)...`, `Indicá si el equipo funciona (1) o no funciona (0).`, `La hora de inicio/fin no es válida. Usá el formato HH:MM.`.
10. **Límites de largo explícitos** (80 en título, nombre y correo; 200 en descripciones, detalle y observaciones; 150 en la foto): la app los resuelve con el campo de texto; en el SP evitan un error 1406 poco claro.
11. **Hora del log de usuario inexistente en el login:** no aplica a estos 8 SP (el login es del SP de Arce Thiago y Cabrera Ulises/0).
12. **Fecha de creación de la planilla:** puse 17-Nov-26 (fecha de hoy). La fecha de revisión quedó como `[COMPLETAR]`.
13. **`USE iqual;` y `SET NAMES utf8mb4;`** están al principio del archivo; Arce Thiago y Cabrera Ulises los puede sacar si los pone en el script unido.

## Datos que faltan

- **Ejecución real:** no pude ejecutar MySQL ni MariaDB en este entorno. El SQL está revisado a mano contra `03_ModeloSQL_Grupo06.sql y 04_DatosSQL_Grupo06.sql` (tablas, columnas, `DELIMITER`, orden de `DECLARE`, balance de `IF`/`END IF`), pero **nunca corrió**. Los errores de sintaxis que aparezcan los corrige Arce Thiago y Cabrera Ulises a partir de lo que devuelva MariaDB.
- **ACTUAL RESULT y STATUS** de los 32 casos: vacíos, a completar al ejecutar.
- **Datos de `04_DatosSQL` de Arce Thiago y Cabrera Ulises:** los casos asumen que se conservan los usuarios, objetos, reclamos, préstamos y reservas de demostración con los mismos nombres. Si Arce Thiago y Cabrera Ulises cambió algo (por ejemplo cargó otro préstamo abierto de `alumno2` o una reserva en la Biblioteca para hoy + 30 días), hay que ajustar la precondición del caso.
- **DNI ficticios 45123456 a 45123458:** confirmar que no choquen con los de `04_DatosSQL`.
- **Fecha de revisión** de la planilla y **confirmación de Linares** sobre el nombre del grupo (`Grupo06` provisional).
