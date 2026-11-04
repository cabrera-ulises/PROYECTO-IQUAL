# Cambios respecto al Diseño Inicial
**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  

Durante el 4° Bimestre la aplicación se desvió del diseño inicial del 3er Bimestre (árboles, Marco Lógico, 12 RF + 4 RNF, 6 historias y maquetado). Este documento lista **cada cambio, por qué se hizo y qué documento afecta**, para que la documentación describa lo que realmente se construye.

* **Ref.:** número de decisión del archivo de contexto interno del equipo (`CONTEXTO_IQUAL.md`, que no está en el repositorio). Los motivos que dicen "regla de la profesora" o "regla de BD" vienen de las consignas de la cátedra.
* Documentos: `REQ` = [requerimientos](./requerimientos.md) · `US` = [historias de usuario](./historias-de-usuario.md) · `MML` = [marco-logico.xlsx](./marco-logico.xlsx) · `MAQ` = [maquetado-y-usabilidad.xlsx](./maquetado-y-usabilidad.xlsx) · `README` · `ARB` = [árbol de objetivos](./arbol-de-objetivos.drawio.xml) · `PRES` = presentación (ver [`cambios-presentacion.md`](./cambios-presentacion.md)) · `MAT` = [matriz de trazabilidad](./matriz-trazabilidad.md).

---

## 1. Cambios de diseño

### Plataforma y datos

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 1 | Plataforma | "Aplicación web/móvil" (presentación) y "escritorio/móvil" (README) | Aplicación de **escritorio** en C++17 / Qt 6 (Qt Widgets, CMake), para Windows | Es lo que se construye en el 4° Bimestre (D1, §1 del contexto) | README, MML, PRES |
| 2 | Persistencia | README: "SQL Server (3FN)"; MML, RNF02 y presentación: "base de datos local" | **SQLite en la app** (`iqual.db`, junto al ejecutable; se crea sola la primera vez con un script embebido en el `.qrc`). El **modelo se entrega también en SQL Server (scripts para SQL Server 2005) y MySQL** como entregable de Bases de Datos. **El motor final está a confirmar con el profesor de BBDD**; pasar la app a un motor de servidor queda como evolución futura | Respeta el RNF02 y la actividad del MML, que ya decían "base de datos local" (D1) | README, REQ (RNF02, RNF04), MML, MAT |
| 3 | Acceso a datos | La versión 1 de la app usaba listas paralelas y `struct` y no tenía base de datos | Todo se lee y se escribe con consultas SQL preparadas (`prepare` + `bindValue`) | D2 y regla de la profesora (sin `struct` propias) | REQ (RNF02) |
| 4 | Modelo relacional | Sin definir en el diseño inicial | **44 tablas** (22 catálogos + 22 entidades) en 3FN (contexto v2). Todo lo categorizable (estados, tipos, categorías, años, divisiones, días, etc.) es tabla o atributo multivaluado | Regla del profesor de Bases de Datos | README, MAT |
| 5 | Tablas descartadas | Modelo anterior con `curso_materia`, `notificacion` y `metodo_pago` | Se eliminan **por defecto — pendiente de confirmar con el profesor de BBDD** (sección 10 del contexto: todavía no se confirmó si los pidió). Los scripts y diagramas definitivos ya traen **44 tablas sin ellas**. Si se conservan, vuelven al modelo y el total de tablas cambia; la app no los usa. **El log de auditoría ya no se descarta** (ver cambio 54) | Notificaciones en pantalla y pagos quedan fuera de alcance (D13, D7) | MML, MAT |
| 6 | Formatos | Sin definir | Fechas `yyyy-MM-dd`, fecha y hora `yyyy-MM-dd HH:mm:ss`, horas `HH:mm`; los ids de catálogos se buscan por nombre y nunca se escriben a mano | Que la app (SQLite) y SQL Server sean compatibles (D14) | README |

### Acceso, roles y navegación

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 7 | Registro | Usuario, contraseña y un selector "Curso y división" | Nombre y apellido, usuario, contraseña, DNI, correo, teléfono y rol. Validaciones sin expresiones regulares (largo, dígitos, "@" y ".") y unicidad de usuario, DNI y correo | D3 y §6 del contexto | REQ (RF13), US07, MAQ 01, PRES |
| 8 | Curso | Un solo desplegable "Curso y división" | **Tres listas**: año, división y especialidad; si la combinación no existe, se crea. "Crear cuenta" sigue deshabilitado hasta completar el curso | D3 y modelo de datos (`curso` con claves a tres catálogos) | REQ (RF13, RF17), US06, US07, MAQ 01, PRES |
| 9 | Contraseña | "Cifradas en la base de datos local" | Hash **SHA-256** (`QCryptographicHash`) y consultas preparadas con `bindValue` | D3; RNF02 más preciso | REQ (RNF02), MAT |
| 10 | Roles | Se hablaba de alumnos, docentes, preceptores, "autoridades" y "personal de maestranza" sin definirlos | Cuatro roles: **Alumno, Profesor, Preceptor y Maestranza** (nuevo). Los roles distintos de Alumno piden un PIN institucional al registrarse | D3 y D4 (Maestranza se agrega por la trazabilidad de higiene) | REQ (RF13, permisos), US07 |
| 11 | Pantallas nuevas | 8 pantallas (acceso, dashboard y 6 módulos) | **10 páginas**: se suman Landing (0) y Mi Cuenta (9), y un menú hamburguesa (☰) con Menú Principal, Mi Cuenta / Perfil y Cerrar Sesión en las páginas 2 a 9; botón "Volver" en cada módulo | Regla de la profesora (una página por módulo en un `QStackedWidget`) y D3 | REQ (RF17, RNF04), US10, MAQ 02, MAT |

### Objetos Perdidos

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 12 | Quién y qué publica | "Autoridades (preceptores)" cargan fotografías, títulos y descripciones | El **Preceptor** publica título, descripción (opcional), categoría, sector y foto (opcional, copiada a `imagenes_objetos` junto al ejecutable; se guarda solo el nombre del archivo) | D5 | REQ (RF01), US01, MAQ 03 |
| 13 | Reclamo | El alumno redacta una prueba antes del retiro; el maquetado preveía "Cancelar Solicitud" | Prueba de **al menos 10 caracteres** → reclamo "Pendiente" y objeto "En reclamo". El **Preceptor aprueba** (objeto "Devuelto") **o rechaza** (objeto vuelve a "Disponible"). El objeto ya no se borra al reclamarlo. No hay botón "Cancelar Solicitud" para el alumno | D5 y §6 del contexto | REQ (RF02), US01, MAQ 03, PRES |
| 14 | Estados | Preceptoría marcaba el objeto "devuelto" o "archivado" a mano | Catálogo de estados: Disponible, En reclamo, Devuelto y Archivado. "Devuelto" ahora se alcanza solo al aprobar un reclamo; "Archivado" con el botón Archivar | Regla de BD (estados en tabla) y D5 | US01 (1.3, 1.4), MAQ 03 |
| 15 | Consultas | No existían | Pestaña "Consultas": cualquier usuario publica "¿Vieron tal cosa?" (10 o más caracteres); se ve nombre y teléfono del autor; se borra la propia (el Preceptor borra cualquiera) | §6 del contexto (tabla `consulta_objeto`) | REQ (RF14), US08, MAQ 03 |

### Higiene e Infraestructura

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 16 | Trazabilidad | "Cronograma de higiene" actualizado por maestranza (A2.2) y "último horario de limpieza" | Al **marcar resuelto** un reporte se guardan fecha, hora y quién lo resolvió; al elegir un sector se muestra "Último mantenimiento: dd/MM HH:mm — nombre" o "ninguno registrado" | D6 (cumple RF04 y el criterio 2.3 de US02) | REQ (RF04), US02, MML (A2.2), MAQ 04 |
| 17 | Tipos de reporte | Categorías "Higiene" / "Rotura" y fallas libres (ej. "Sin jabón" en la maqueta) | Catálogo `tipo_reporte`: **Rotura** y **Limpieza**; el detalle va en observaciones | Regla de BD | REQ (RF03), US02 (2.1), MAQ 04, PRES |
| 18 | Quién resuelve | No se definía | Profesor, Preceptor y Maestranza pueden marcar "Resuelto"; todos los roles pueden reportar | D4 y §7 del contexto | REQ (RF03, RF04, permisos), US02 (2.4) |

### Buffet Paralelo

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 19 | Quién publica | Alumnos **de último año** | Cualquier **Alumno** publica productos, crea grupos y se une con PIN | Para poder demostrar con alumnos de 4° (D7). Es una decisión reversible | REQ (RF05), US03 |
| 20 | Reserva de productos | "Reserva de compra" sin detalle | Una reserva es una **venta "Reservada"** que descuenta stock; "Mis reservas" permite cancelar y devuelve el stock. Reservan todos los roles, salvo productos propios | D7 | REQ (RF05), US03 (3.2), MAQ 05 |
| 21 | Grupos con PIN | La meta grupal era un dato del producto | Entidad **grupo** con meta y PIN; los alumnos se unen con el PIN. Lo **recaudado no se guarda: se calcula** (donaciones + ventas no canceladas del grupo) | D7 | REQ (RF15), US09, MAQ 05, MAT |
| 22 | Donaciones | "Pasarela de registro de donaciones" (A3.2), con método de pago y comprobante en el modelo anterior | **Registro** de donaciones (monto entero mayor a cero, a un grupo). Se eliminan método de pago y comprobante; **no hay pagos reales** | D7 y D13 | REQ (RF06), US03 (3.3, 3.4), MML (A3.2) |
| 23 | Contacto del vendedor | Dato cargado en cada producto | Sale del usuario que publica el producto | D7 | REQ (RF05) |
| 24 | Presentación visual | Galería con fotos de productos y barra de progreso hacia la meta | Lista de productos con precio y stock; meta, recaudado y porcentaje como datos. El modelo no guarda fotos de productos | Modelo de datos y widgets permitidos. Si el avance se ve como texto o como barra: **verificar con la app final** | MAQ 05, PRES |

### Planillas de Taller

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 25 | Quién registra | "Profesores" | **Profesor y Preceptor** registran y devuelven; el Alumno solo ve. El autorizador es el usuario con sesión iniciada | D8 | REQ (RF07, RF08, permisos), US04 |
| 26 | Datos del préstamo | Carro (C4/C5), máquina, nombre del alumno, curso, división y profesor, escritos a mano | Se elige de una lista el **recurso** (carro + número, mostrado "C4-05"; tablero solo por número, "Tablero 03") y el **alumno**; curso y división salen del alumno | D8 | REQ (RF07, RF08), US04 (4.1), MAQ 06 |
| 27 | Disponibilidad | Un recurso no puede estar asignado a dos alumnos "en el mismo bloque horario" | El recurso queda **"Prestado"** y no se puede volver a prestar hasta devolverlo. Desaparece el concepto de bloque horario | D8 | REQ (RF07), US04 (4.2), MAQ 06, PRES |
| 28 | Devolución | No estaba prevista | Se indica **Funciona / No funciona** al devolver: el recurso queda "Disponible" o "Fuera de servicio" y se guarda la hora | D8 | REQ (RF07), US04 (4.3), MAQ 06 |
| 29 | Búsqueda | Buscador por número de recurso | Filtro por **código** mientras se escribe (también atajo con Enter) | §6 y D11 | US04 (4.4), MAQ 06 |
| 30 | Catálogo de carros | "Carros C4/C5" | El catálogo contiene **C1 a C5** (los datos de demostración cargan C4 y C5). **A confirmar con la escuela** qué carros tiene realmente | Modelo de datos (`carro`: C1 a C5) | REQ (RF07), README |

### Reserva de Sectores

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 31 | Quién reserva | "Docentes" | **Profesor y Preceptor** | D9 | REQ (RF09), US05 |
| 32 | Calendario | Calendario mensual interactivo con celdas verde (libre) y rojo (ocupado) | **Selector de fecha con calendario desplegable** más una **lista de la ocupación del día** para el sector elegido, con hora de inicio y fin | Regla de la profesora (paleta de 4 colores, sin otros colores) y herramientas permitidas (D9, §10 del contexto) | REQ (RF09), US05 (5.1), MAQ 07, PRES |
| 33 | Aprobación | "Las autoridades escolares autorizan o cancelan" | Reserva de un **Profesor = "Pendiente"** hasta que un **Preceptor la aprueba o rechaza**; la de un Preceptor queda "Aprobada". Ocupado = Pendiente o Aprobada. Cancela el dueño o un Preceptor | D9 | REQ (RF09, RF10, RF16), US05 (5.3, 5.4), MML (supuestos) |
| 34 | Superposición | Mismo sector y mismo "módulo horario" | Mismo sector y fecha con horario solapado (`inicio < nuevo fin` y `fin > nuevo inicio`); el mensaje nombra **quién ocupa y en qué horario**. También se valida fin > inicio y fecha ≥ hoy | D9 y §6 | REQ (RF10), US05 (5.2), MAQ 07 |

### Educación Física

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 35 | Opciones de inscripción | Selector de deportes, días y turnos | Tabla de **ofertas** (deporte + día + franja horaria + cupo máximo); la lista muestra cupos usados/máximos | D10 | REQ (RF11), US06, MAQ 08, PRES |
| 36 | Validación cruzada | Bloqueo si coincide con las clases del curso del alumno | Cruce con el **horario cargado del curso** (tablas de horario) y con los cupos; las ofertas en conflicto se muestran como "se superpone con <materia>" y no se pueden elegir | D10 | REQ (RF12), US06 (6.2, 6.3), MAQ 08 |
| 37 | Una inscripción por alumno | No estaba definido | Una sola inscripción por alumno, con opción de cancelarla | D10 | REQ (RF11), US06 (6.4) |
| 38 | Limitación | No declarada | El cruce solo funciona para los cursos con horario cargado | §9 del contexto | REQ (sección 4), US06 (6.5), MML (supuestos) |

### Usabilidad e interfaz

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 39 | Heurísticas 7 y 10 | El Excel cubría 8 de las 10 heurísticas de Nielsen; el README decía "las 10" | Se agrega **H7** (flexibilidad y eficiencia: atajos con Enter en login, registro y filtros) y **H10** (ayuda: `setToolTip` y `placeholderText`). Las filas del Excel llevan las etiquetas H1 a H10 | D11; vuelve verdadera la afirmación del README | MAQ, REQ (RNF01), README, MAT |
| 40 | Logo e íconos | Íconos descriptos en el Excel (silbato, carro tecnológico) distintos de los de las maquetas (mancuerna, engranaje, etc.) | `logo.png` y 6 íconos PNG en `:/imagenes/` (`ico_objetos`, `ico_higiene`, `ico_buffet`, `ico_planillas`, `ico_sectores`, `ico_edfisica`); la app **funciona aunque falten los archivos** (queda el texto) | D12 | MAQ 02, PRES |
| 41 | Paleta | Maquetas con colores por módulo, semáforo verde/rojo y alertas naranja | **4 colores** (`#102542`, `#1E3A8A`, `#F8FAFC` / `#FFFFFF`, `#1E293B`), sin naranja; los stylesheets solo usan `color`, `background-color` y `font` | Regla de la profesora | MAQ, REQ (RNF01), PRES |
| 42 | Tamaño de ventana | RNF01 pedía una interfaz "adaptable" | Widgets en **posiciones fijas** (sin diseño adaptable) | Regla de la profesora (widgets con posiciones fijas) | REQ (RNF01) |
| 43 | Maquetas | Maquetas de celular (marco de teléfono) | Aplicación de escritorio; las maquetas de Canva quedan como diseño inicial | Cambio de plataforma (cambio 1) | README, PRES |

### Alcance y métricas

| # | Cambio | Antes (diseño inicial) | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 44 | Fuera de alcance | No declarado | Notificaciones, pagos reales y multiusuario en red (el registro de auditoría **sí** se incluye) | D13, ajustada en el contexto v2 | REQ (sección 4), README, MML |
| 45 | Cantidades | 12 RF, 4 RNF, 6 historias | **18 RF** (se suman RF13 a RF18), 4 RNF (los cuatro ajustados a la app real), **11 historias** (se suman US07 a US11) | Funciones que existen en la app y no estaban documentadas | REQ, US, MAT, README, PRES |
| 46 | RNF03 | "Búsquedas < 2 segundos" sin criterio de medición | **Propuesta** de cómo se mide: de clic o Enter hasta que se muestra el resultado, con la base de demostración, en una PC, 10 repeticiones por consulta, peor caso < 2 s. **Todavía sin medir** | Que el requisito sea verificable | REQ (RNF03), MML |
| 47 | RNF04 | "Código modular" genérico | Se describe la modularidad real: una página por módulo en un `QStackedWidget` de 10 páginas, con `enum` de índices y tablas propias por módulo | Cambio de plataforma y regla de la profesora | REQ (RNF04) |
| 48 | MML: línea base | Indicadores sin línea base | **Propuesta** de cómo se mide cada uno; los valores (-40%, 85–90%, < 2 s) **no cambian** | Que los indicadores sean medibles | MML |
| 49 | MML: medios de verificación | "Logs de transacciones y reportes automáticos" | "Registros de la propia base de datos", incluido el **log de auditoría** (`log_auditoria`), consultados con SQL | El log de auditoría se mantiene en el contexto v2 y reemplaza a los "logs de uso"; no hay reportes automáticos | MML (C3) |
| 50 | MML: presupuesto | Servidores y base de datos: USD 50 anuales a cargo de la Cooperadora | Base local sin servidor: **$0**. Un motor de servidor (SQL Server, USD 50 anuales por la Cooperadora; motor a confirmar con el profesor de BBDD) se menciona **solo como evolución futura** | D1 | MML (B5, C5) |
| 51 | MML: supuestos | "Servidores y red de la escuela estables" | Una sola PC disponible, horarios cargados por curso, reservas y donaciones coordinadas en persona, sin notificaciones | §9 del contexto | MML (D4) |
| 52 | MML: actividades | A1.1 "pruebas físicas"; A2.2 "cronograma de higiene"; A3.2 "pasarela" | A1.1 prueba escrita y aprobación del preceptor; A2.2 registro de resolución y último mantenimiento; A3.2 "registro de donaciones" | Coherencia con los cambios 13, 16 y 22 | MML (A5) |
| 53 | MML: componente C4 | "Desplegados en el servidor escolar"; "consultas concurrentes de alumnos" | "Instalados como aplicación de escritorio en la PC de la escuela"; consultas de la aplicación en una sola PC (el 2 s no cambia) | No hay servidor ni acceso concurrente en red | MML (B4) |

### Cambios del contexto v2.1 (modelo de 44 tablas y auditoría)

| # | Cambio | Antes (contexto v1) | Ahora (contexto v2.1) | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 54 | Log de auditoría | `log_auditoria`, `tipo_log` y `resultado_log` se eliminaban y la auditoría estaba fuera de alcance | Se **mantienen**. Nuevo RF18 y nueva historia US11: se registran 14 tipos de evento con resultado "Exitoso" o "Fallido", con un único método `registrarLog`; **sin pantalla** (se consulta solo desde la base). Reemplaza al medio de verificación "logs de uso" del MML | Requisito del profesor de BBDD (D15) | REQ (RF18, sección 4), US11, MML (C3, D4), MAT, README |
| 55 | `entidad_log` | `log_auditoria.entidad_afectada` era un texto | `log_auditoria.id_entidad` es clave foránea al catálogo nuevo `entidad_log` (12 entidades: las tablas sobre las que se registra) | Regla de datos categorizables | REQ (RF18), MAT |
| 56 | `tipo_sector` | `sector.reservable` (0/1) | `sector.id_tipo_sector` → catálogo `tipo_sector` (Reservable, Uso común); solo se reservan los de tipo Reservable | Regla de datos categorizables | REQ (RF09), US05 (5.1), MAQ 07, MAT |
| 57 | Total de venta | `venta_buffet.monto_total` se guardaba | **No se guarda**: se calcula con `SUM(cantidad*precio_unitario)` sobre `detalle_venta` | Los datos derivados se calculan, no se guardan (criterio de 3FN del profesor; igual que "recaudado") | REQ (RF05), US03 (3.2), MAT |
| 58 | Cantidad de tablas | 39 (18 catálogos + 21 entidades) | **44** (22 catálogos + 22 entidades), sujeto a la confirmación del cambio 5 | Suma de los cambios 54 a 56 | README, MAT, cambios 4 y 5 |
| 59 | Motor de base de datos | SQLite en la app y SQL Server como entregable | **SQLite en la app; modelo entregado también en SQL Server y MySQL.** El motor final **no está definido**: a confirmar con el profesor de BBDD. La app abre la base en un único método (`abrirBase()`) para poder cambiar de motor | Decisión pendiente de la cátedra; el Qt 6 de Windows (MinGW) no trae el driver de MySQL precompilado | README, REQ, MML, cambios 2, 50 y F |
| 60 | Hito 1 | No figuraba en el README | Sección "Hito 1" en el README con los diagramas de Peter Chen (conceptual) y Edgar Codd (lógico), exportados en PNG por el usuario desde el XML de draw.io | Requisito del profesor de BBDD | README |
| 61 | Nuevo requerimiento e historia | 17 RF y 10 historias | RF18 y US11 (auditoría) | Cambio 54 | REQ, US, MAT, README, PRES |
| 62 | Aclaración del reclamo | No estaba explícito | Solo el Alumno reclama (ni Profesor ni Maestranza) y no puede cancelar su reclamo | Confirmado por el usuario | REQ (RF02), US01 (1.6) |

### Cambios del contexto v2.3 (entregables de Bases de Datos)

| # | Cambio | Antes | Ahora | Motivo | Documentos |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 63 | Scripts de la base | Sin scripts en el repositorio | `iqual_sqlite.sql` (el que usa la app), `iqual_sqlserver.sql` (SQL Server 2005) e `iqual_mysql.sql`, con las mismas 44 tablas y los mismos nombres, más `consultas_verificacion.sql` y `justificacion_3FN.md` | Entregables de Bases de Datos | README |
| 64 | Diagramas del Hito 1 | Solo PNG | XML editable de draw.io (Peter Chen: 39 entidades; Edgar Codd: las 44 tablas) más los PNG que exporta el usuario; todo en `/db` | Requisito del profesor de BBDD | README |
| 65 | Datos de demostración | No documentados | Usuarios `alumno1`, `alumno2`, `profe1`, `preceptor1` y `maestranza1` (los carga el script de datos); el PIN institucional no se escribe en la documentación | Coherencia con el script | README |

---

## 2. Inconsistencias internas del diseño inicial que se corrigieron

| # | Inconsistencia | Dónde estaba | Corrección |
| :-: | :--- | :--- | :--- |
| A | El **objetivo central** era idéntico al primer efecto del árbol ("Incrementar la confianza, pertenencia y satisfacción de la comunidad estudiantil") | Árbol de objetivos | El central pasa a ser el inverso positivo del problema central: **"Organización operativa escolar eficiente"**. El árbol de problemas queda igual |
| B | "Educacion Física" sin tilde y un catálogo "online" en una app local | Árbol de objetivos | Se corrige la tilde y "online" pasa a "digital" |
| C | Plataforma: "web/móvil" (presentación), "escritorio/móvil" (README) | README, presentación | Escritorio |
| D | Base de datos: SQL Server (README) contra base local (MML, RNF02) | README, MML | SQLite en la app más modelo también en SQL Server y MySQL; motor final a confirmar (cambio 2) |
| E | "10 heurísticas" en el README mientras el Excel cubría 8 | README, MAQ | Cobertura de las 10 (cambio 39) |
| F | Presupuesto con servidor y hosting (USD 50) contra base local sin servidor | MML | $0 y un motor de servidor como evolución (cambio 50) |
| G | "Pasarela" de pagos en una función que solo registra donaciones | MML (A3.2) | "Registro de donaciones" |
| H | Un recurso "asignado en el mismo bloque horario" sin que existieran bloques horarios de préstamo | US04, MAQ 06 | Estado "Prestado" (cambio 27) |
| I | US03 para alumnos "de último año" mientras el equipo demuestra con 4° año | US03 | Cualquier alumno (cambio 19) |
| J | Mismo actor con tres nombres: "Docente" (US05), "Profesor de Taller" (US04) y "docentes" (RF09) | REQ, US | Profesor y Preceptor, definidos por rol |
| K | Nombres de módulo distintos según el documento: "Higiene y Baños" / "Higiene e Infraestructura" y "Planillas computadoras" / "Planillas de Taller" | MAQ, PRES, README | Se usan los nombres de módulo del README: Higiene e Infraestructura y Planillas de Taller |
| L | Íconos del Excel distintos de los de las maquetas | MAQ, PRES | Se usan los íconos reales de la app (cambio 40); la presentación debe actualizarse |
| M | Presupuesto y MoV hablaban de "hosting" y "reportes automáticos" que no existen | MML | Eliminados (cambios 49 y 50) |
| N | Carros "C4/C5" (RF07, MML) contra "C1-C5" (README) | REQ, MML, README | El catálogo admite C1 a C5; los datos de demostración usan C4 y C5. **Pendiente de confirmar con la escuela** |

---

## 3. Qué no se modificó

* `docs/bitacora.md`: es el registro histórico del equipo (semanas 1 a 7). Cuando haga falta registrar estos cambios hay entradas en borrador aparte: [`bitacora-borrador.md`](./bitacora-borrador.md).
* El **árbol de problemas** (`arbol-de-problemas.png`).
* El PNG viejo del árbol de objetivos (`docs/arbol-de-objetivos.png`) sigue en el repositorio con el objetivo central anterior: **pendiente de reemplazo** (exportar un PNG nuevo desde el XML de draw.io o borrar el viejo).
* La presentación de Canva y las maquetas de Canva: no se pueden editar desde acá. Qué corregir en cada lámina está en [`cambios-presentacion.md`](./cambios-presentacion.md).
* Los indicadores numéricos del MML: -40%, 85% / 90% y menos de 2 segundos.
