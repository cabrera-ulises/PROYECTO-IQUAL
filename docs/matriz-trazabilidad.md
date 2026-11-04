# Matriz de Trazabilidad
**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  

Relaciona cada requerimiento funcional con la historia de usuario que lo cubre, el módulo, las tablas de la base de datos que usa y la pantalla donde se ve. Sirve para responder en la defensa "¿dónde está implementado el RF0X?".

* Requerimientos: [`requerimientos.md`](./requerimientos.md) · Historias: [`historias-de-usuario.md`](./historias-de-usuario.md).
* Tablas: son las del modelo de **44 tablas** (22 catálogos + 22 entidades). Si el profesor de BBDD pide conservar `curso_materia`, `notificacion` o `metodo_pago`, el total cambia (pendiente de confirmar; los scripts y diagramas definitivos ya traen las 44 tablas sin ellas).
* Pantalla: número de página del `QStackedWidget` de la aplicación (0 Landing, 1 Acceso, 2 Dashboard, 3 Objetos, 4 Higiene, 5 Buffet, 6 Planillas, 7 Sectores, 8 Ed. Física, 9 Mi Cuenta).

---

## 1. Requerimientos funcionales → historia → módulo → tablas → pantalla

| RF | Historia | Módulo | Tablas | Pantalla |
| :--- | :--- | :--- | :--- | :--- |
| **RF01** Publicación de Objetos Perdidos | US01 | Objetos Perdidos | `objeto_perdido`, `categoria_objeto`, `estado_objeto`, `sector`, `tipo_sector`, `usuario` | Página 3 · pestaña Publicar (solo Preceptor) |
| **RF02** Reclamo con Prueba de Pertenencia y Aprobación del Preceptor | US01 | Objetos Perdidos | `reclamo_objeto`, `estado_reclamo`, `objeto_perdido`, `estado_objeto`, `usuario` | Página 3 · pestaña Objetos |
| **RF03** Reporte de Incidentes de Higiene/Infraestructura | US02 | Higiene e Infraestructura | `reporte_higiene`, `tipo_reporte`, `estado_reporte`, `sector`, `tipo_sector`, `usuario` | Página 4 |
| **RF04** Trazabilidad de Limpieza Sanitaria | US02 | Higiene e Infraestructura | `reporte_higiene`, `estado_reporte`, `sector`, `tipo_sector`, `usuario` | Página 4 |
| **RF05** Catálogo de Buffet Paralelo | US03 | Buffet Paralelo | `producto_buffet`, `venta_buffet`, `detalle_venta`, `estado_venta`, `grupo_buffet`, `usuario` | Página 5 |
| **RF06** Registro de Donaciones Directas | US03 | Buffet Paralelo | `donacion_buffet`, `grupo_buffet`, `usuario` | Página 5 |
| **RF07** Control Digital de Carros de Computación | US04 | Planillas de Taller | `recursos_ct`, `prestamo_ct`, `carro`, `tipo_recurso`, `estado_recurso`, `usuario`, `curso`, `anio`, `division` | Página 6 |
| **RF08** Control Digital de Tableros de Dibujo | US04 | Planillas de Taller | `recursos_ct`, `prestamo_ct`, `tipo_recurso`, `estado_recurso`, `usuario` | Página 6 |
| **RF09** Reserva Interactiva de Sectores | US05 | Reserva de Sectores | `reserva_sector`, `sector`, `tipo_sector`, `estado_reserva`, `usuario`, `rol` | Página 7 |
| **RF10** Bloqueo de Superposición de Sectores | US05 | Reserva de Sectores | `reserva_sector`, `estado_reserva`, `sector`, `tipo_sector`, `usuario` | Página 7 |
| **RF11** Inscripción a Educación Física | US06 | Educación Física | `oferta_deporte`, `inscripcion_ed_fisica`, `deporte`, `dia_semana`, `franja_horaria`, `usuario` | Página 8 |
| **RF12** Validación Cruzada de Horarios Escolares | US06 | Educación Física | `horario_escolar`, `horario_dia`, `materia`, `curso`, `turno`, `dia_semana`, `franja_horaria`, `oferta_deporte`, `usuario` | Página 8 |
| **RF13** Autenticación, Registro y Roles con PIN | US07 | Acceso y roles | `usuario`, `rol`, `curso`, `anio`, `division`, `especialidad` | Página 1 (pestañas de inicio de sesión y registro) |
| **RF14** Consultas de Objetos Perdidos | US08 | Objetos Perdidos | `consulta_objeto`, `usuario` | Página 3 · pestaña Consultas |
| **RF15** Grupos de Recaudación con PIN | US09 | Buffet Paralelo | `grupo_buffet`, `integrante_grupo`, `donacion_buffet`, `producto_buffet`, `venta_buffet`, `detalle_venta`, `usuario` | Página 5 |
| **RF16** Aprobación de Reservas de Sectores | US05 | Reserva de Sectores | `reserva_sector`, `estado_reserva`, `usuario` | Página 7 (solo Preceptor) |
| **RF17** Mi Cuenta | US10 | Mi Cuenta | `usuario`, `curso`, `anio`, `division`, `especialidad` | Página 9 |
| **RF18** Registro de Auditoría | US11 | Transversal | `log_auditoria`, `tipo_log`, `resultado_log`, `entidad_log`, `usuario` | Sin pantalla: se consulta solo desde la base de datos |

`sector.id_tipo_sector` es clave foránea a `tipo_sector` (Reservable, Uso común) y reemplaza a la marca `reservable`: solo los sectores de tipo Reservable se pueden reservar.

En RF05 el total de la venta **no se guarda**: se calcula desde `detalle_venta` (cantidad × precio unitario).

La página 0 (Landing) y la 2 (Dashboard) no implementan un RF propio: son la portada y el menú de navegación hacia los módulos.

---

## 2. Historia → requerimientos que cubre

| Historia | Requerimientos |
| :--- | :--- |
| US01 Objetos Perdidos | RF01, RF02 |
| US02 Reporte de Higiene/Mantenimiento | RF03, RF04 |
| US03 Buffet Paralelo y Recaudación | RF05, RF06 |
| US04 Planillas Digitales de Taller | RF07, RF08 |
| US05 Reserva de Sectores | RF09, RF10, RF16 |
| US06 Educación Física | RF11, RF12 |
| US07 Acceso y Roles | RF13 |
| US08 Consultas de Objetos Perdidos | RF14 |
| US09 Grupos de Recaudación | RF15 |
| US10 Mi Cuenta | RF17 |
| US11 Registro de Auditoría | RF18 |

---

## 3. Requerimientos no funcionales → dónde se cumplen

| RNF | Dónde se cumple | Cómo se verifica |
| :--- | :--- | :--- |
| **RNF01** Usabilidad | Todas las pantallas · [`maquetado-y-usabilidad.xlsx`](./maquetado-y-usabilidad.xlsx) | Cobertura de las 10 heurísticas (sección 4) |
| **RNF02** Seguridad | Página 1 (Acceso) · columna `usuario.password_hash` · todas las consultas | Contraseña guardada con hash SHA-256 de 64 caracteres; consultas con `prepare()` y `bindValue()` |
| **RNF03** Rendimiento | Consultas de las páginas 3 a 8 | Tabla de medición de [`requerimientos.md`](./requerimientos.md) (pendiente de medir) |
| **RNF04** Modularidad | `QStackedWidget` de 10 páginas, una por módulo | Un módulo nuevo = una página nueva + tablas nuevas |

---

## 4. Heurísticas de Nielsen → pantallas del Excel de usabilidad

Las filas se refieren a [`maquetado-y-usabilidad.xlsx`](./maquetado-y-usabilidad.xlsx) (cada celda de la columna "Heurística" lleva la etiqueta H1 a H10).

| Heurística | Filas del Excel donde se aplica |
| :--- | :--- |
| H1 Visibilidad del estado del sistema | 03 Objetos, 04 Higiene, 05 Buffet, 07 Sectores, 08 Ed. Física |
| H2 Coincidencia entre el sistema y el mundo real | 02 Dashboard, 04 Higiene |
| H3 Control y libertad del usuario | 02 Dashboard (menú ☰), 03 Objetos |
| H4 Consistencia y estándares | 02 Dashboard |
| H5 Prevención de errores | 01 Acceso, 06 Planillas, 08 Ed. Física |
| H6 Reconocimiento antes que recuerdo | 03 Objetos |
| H7 Flexibilidad y eficiencia de uso | 01 Acceso (Enter), 06 Planillas (filtro con Enter) |
| H8 Diseño estético y minimalista | 05 Buffet |
| H9 Ayudar a reconocer, diagnosticar y recuperarse de errores | 07 Sectores |
| H10 Ayuda y documentación | 01 Acceso (tooltips y placeholders), 06 Planillas |

---

## 5. Tablas nuevas del contexto v2 y medios de verificación

| Tabla | Tipo | Para qué sirve | Requerimiento |
| :--- | :--- | :--- | :--- |
| `log_auditoria` | Entidad | Registro de auditoría (14 tipos de evento, resultado Exitoso o Fallido) | RF18 |
| `tipo_log` | Catálogo | Tipo de acción registrada | RF18 |
| `resultado_log` | Catálogo | Resultado de la acción registrada | RF18 |
| `entidad_log` | Catálogo | Tabla afectada por la acción (12 entidades; regla de datos categorizables) | RF18 |
| `tipo_sector` | Catálogo | Tipo de sector (Reservable, Uso común); reemplaza a la marca `reservable` | RF01, RF03, RF04, RF09, RF10 |

| Medio de verificación del MML | Dónde se obtiene |
| :--- | :--- |
| Uso del sistema (Propósito) | Registros de las tablas de cada módulo (con su fecha) y `log_auditoria`, consultados con SQL directamente en la base (sin pantalla). Reemplaza a "logs de uso" y "reportes automáticos" |
| Tiempo de resolución (Fin) | `reporte_higiene`: fecha y hora de resolución menos fecha y hora del reporte |
| Tiempo de respuesta (Componentes) | Tabla de medición de RNF03 en [`requerimientos.md`](./requerimientos.md) |
