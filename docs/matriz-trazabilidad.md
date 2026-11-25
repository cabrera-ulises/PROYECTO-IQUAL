# Matriz de Trazabilidad
> Revisada contra la app v7 (`iqual_integrado_v7`, CONTEXTO §20, 13/11/2026): no cambian las relaciones entre requerimientos, historias, pantallas y tablas (los cambios de la ronda final son de comportamiento dentro de RF01, RF03, RF14 y RF17).

**Sistema:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  

Relaciona cada requerimiento funcional con la historia de usuario que lo cubre, el módulo, las tablas de la base de datos que usa y la pantalla donde se ve. Sirve para responder en la defensa "¿dónde está implementado el RF0X?".

* Requerimientos: [`requerimientos.md`](./requerimientos.md) · Historias: [`historias-de-usuario.md`](./historias-de-usuario.md).
* Tablas: son las del modelo de **47 tablas** (las 44 anteriores más `software`, `recurso_software` y `categoria_producto`). Si el profesor de BBDD pide conservar `curso_materia`, `notificacion` o `metodo_pago`, el total cambia (pendiente de confirmar). El motor de la app es MySQL (sin base de respaldo); falta que el profesor Linares confirme la elección. La sección 6 lista las 47 tablas del script `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` y los RF que las usan.
* Pantalla: número de página del `QStackedWidget` de la aplicación (0 Landing, 1 Acceso, 2 Dashboard, 3 Objetos, 4 Higiene, 5 Tienda de alumnos, 6 Préstamo de equipos, 7 Sectores, 8 Ed. Física, 9 Mi Cuenta). Las pestañas de cada página se indican con su nombre.

---

## 1. Requerimientos funcionales → historia → módulo → tablas → pantalla

| RF | Historia | Módulo | Tablas | Pantalla |
| :--- | :--- | :--- | :--- | :--- |
| **RF01** Publicación de Objetos Perdidos | US01 | Objetos Perdidos | `objeto_perdido` (incluye `detalle_reservado`), `categoria_objeto`, `estado_objeto`, `sector`, `tipo_sector`, `usuario` | Página 3 · pestaña Publicar (solo Preceptor); detalle con doble clic en la pestaña Objetos |
| **RF02** Reclamo con Detalle y Aprobación del Preceptor | US01 | Objetos Perdidos | `reclamo_objeto` (índice único `ux_reclamo_usuario_objeto`; la columna `prueba_pertenencia` guarda el detalle del reclamo), `estado_reclamo`, `objeto_perdido`, `estado_objeto`, `usuario` | Página 3 · pestañas Objetos (alumno reclama) y Reclamos (solo Preceptor) |
| **RF03** Reporte de Incidentes de Higiene/Infraestructura | US02 | Higiene e Infraestructura | `reporte_higiene`, `tipo_reporte`, `estado_reporte`, `sector`, `tipo_sector`, `usuario` | Página 4 |
| **RF04** Trazabilidad de Limpieza Sanitaria | US02 | Higiene e Infraestructura | `reporte_higiene`, `estado_reporte`, `sector`, `tipo_sector`, `usuario` | Página 4 |
| **RF05** Tienda de Alumnos | US03 | Tienda de alumnos | `producto_buffet`, `categoria_producto`, `venta_buffet`, `detalle_venta`, `estado_venta`, `grupo_buffet`, `usuario` | Página 5 · pestañas Productos, Publicar y Mis reservas |
| **RF06** Registro de Donaciones Directas | US03 | Tienda de alumnos | `donacion_buffet`, `grupo_buffet`, `usuario` | Página 5 · pestaña Grupos y donaciones |
| **RF07** Control Digital de Carros de Computación | US04 | Préstamo de equipos | `recursos_ct`, `prestamo_ct`, `carro`, `tipo_recurso`, `estado_recurso`, `usuario`, `curso`, `anio`, `division` | Página 6 |
| **RF08** Control Digital de Tableros de Dibujo | US04 | Préstamo de equipos | `recursos_ct`, `prestamo_ct`, `tipo_recurso`, `estado_recurso`, `usuario` | Página 6 |
| **RF09** Reserva Interactiva de Sectores | US05 | Reserva de Sectores | `reserva_sector`, `sector`, `tipo_sector`, `estado_reserva`, `usuario`, `rol` | Página 7 |
| **RF10** Bloqueo de Superposición de Sectores | US05 | Reserva de Sectores | `reserva_sector`, `estado_reserva`, `sector`, `tipo_sector`, `usuario` | Página 7 |
| **RF11** Inscripción a Educación Física | US06 | Educación Física | `oferta_deporte`, `inscripcion_ed_fisica`, `deporte`, `dia_semana`, `franja_horaria`, `usuario` | Página 8 (listas de deporte, día y hora) |
| **RF12** Validación Cruzada de Horarios Escolares | US06 | Educación Física | `horario_escolar`, `horario_dia`, `materia`, `curso`, `turno`, `dia_semana`, `franja_horaria`, `oferta_deporte`, `usuario` | Página 8 |
| **RF13** Autenticación, Registro y Roles con PIN | US07 | Acceso y roles | `usuario`, `rol`, `curso`, `anio`, `division`, `especialidad` | Página 1 (pestañas de inicio de sesión y registro) |
| **RF14** Consultas de Objetos Perdidos | US08 | Objetos Perdidos | `consulta_objeto`, `usuario` | Página 3 · pestaña Consultas |
| **RF15** Grupos de Recaudación con PIN | US09 | Tienda de alumnos | `grupo_buffet`, `integrante_grupo`, `donacion_buffet`, `producto_buffet`, `venta_buffet`, `detalle_venta`, `usuario` | Página 5 · pestaña Grupos y donaciones |
| **RF16** Aprobación de Reservas de Sectores | US05 | Reserva de Sectores | `reserva_sector`, `estado_reserva`, `usuario` | Página 7 (solo Preceptor) |
| **RF17** Mi Cuenta | US10 | Mi Cuenta | `usuario` (contraseña y teléfono), `curso`, `anio`, `division`, `especialidad` | Página 9 |
| **RF18** Registro de Auditoría | US11 | Transversal | `log_auditoria`, `tipo_log`, `resultado_log`, `entidad_log`, `usuario` | Página 3 · pestaña Auditoría (solo Preceptor, últimos 50); el resto, desde la base de datos |
| **RF19** Gestión de Productos Propios y Ventas | US12 | Tienda de alumnos | `producto_buffet`, `venta_buffet`, `detalle_venta`, `estado_venta`, `usuario` | Página 5 · pestañas Mis ventas y Mis productos (solo Alumno) |
| **RF20** Programas Instalados por Equipo | US13 | Préstamo de equipos | `software`, `recurso_software`, `recursos_ct` | Página 6 |
| **RF21** Visibilidad de Funciones por Rol | US07 | Transversal | `usuario`, `rol` | Todas las páginas (pestañas, botones y módulos ocultos según el rol) y el Dashboard |
| **RF22** Reparación de Equipos | US13 | Préstamo de equipos | `recursos_ct`, `estado_recurso` | Página 6 · lista de fuera de servicio |
| **RF23** Cancelación Automática de Inscripción por Cambio de Curso | US06 | Mi Cuenta / Educación Física | `usuario`, `curso`, `inscripcion_ed_fisica`, `horario_escolar`, `log_auditoria` | Página 9 (aviso Sí/No al guardar el curso) y página 8 |

`sector.id_tipo_sector` es clave foránea a `tipo_sector` (Reservable, Uso común) y reemplaza a la marca `reservable`: solo los sectores de tipo Reservable se pueden reservar.

En RF05 el total de la venta **no se guarda**: se calcula desde `detalle_venta` (cantidad × precio unitario). Lo recaudado de un grupo (RF15) tampoco se guarda: son las donaciones más las ventas "Entregadas".

`categoria_producto` (RF05), `software` y `recurso_software` (RF20) son las tres tablas que llevan el modelo de 44 a 47; además `producto_buffet` agrega `id_categoria_producto` y `ruta_foto`, y `objeto_perdido` agrega `detalle_reservado`.

La página 0 (Landing) y la 2 (Dashboard) no implementan un RF propio: son la portada y el menú de navegación hacia los módulos.

---

## 2. Historia → requerimientos que cubre

| Historia | Requerimientos |
| :--- | :--- |
| US01 Objetos Perdidos | RF01, RF02 |
| US02 Reporte de Higiene/Mantenimiento | RF03, RF04 |
| US03 Tienda de Alumnos y Recaudación | RF05, RF06 |
| US04 Préstamo de Equipos | RF07, RF08 |
| US05 Reserva de Sectores | RF09, RF10, RF16 |
| US06 Educación Física | RF11, RF12, RF23 |
| US07 Acceso y Roles | RF13, RF21 |
| US08 Consultas de Objetos Perdidos | RF14 |
| US09 Grupos de Recaudación | RF15 |
| US10 Mi Cuenta | RF17 |
| US11 Registro de Auditoría | RF18 |
| US12 Mis Productos y Mis Ventas | RF19 |
| US13 Programas y Reparación de Equipos | RF20, RF22 |

---

## 3. Requerimientos no funcionales → dónde se cumplen

| RNF | Dónde se cumple | Cómo se verifica |
| :--- | :--- | :--- |
| **RNF01** Usabilidad | Todas las pantallas · [`maquetado-y-usabilidad.xlsx`](./maquetado-y-usabilidad.xlsx) | Cobertura de las 10 heurísticas (sección 4); confirmaciones Sí/No en acciones destructivas; temas claro y oscuro |
| **RNF02** Seguridad | Página 1 (Acceso) · columna `usuario.password_hash` · todas las consultas | Contraseña guardada con hash SHA-256 de 64 caracteres; consultas con `prepare()` y `bindValue()` |
| **RNF03** Rendimiento | Consultas de las páginas 3 a 8 (la lista de productos con búsqueda tiene una sospecha de lentitud sin medir: `ERRORES_TIENDA_EDFISICA.md`, E-04) | Tabla de medición de [`requerimientos.md`](./requerimientos.md) (pendiente de medir) |
| **RNF04** Modularidad | `QStackedWidget` de 10 páginas, una por módulo, con `abrirBase()` como único punto de conexión | Un módulo nuevo = una página nueva + tablas nuevas |

---

## 4. Heurísticas de Nielsen → pantallas del Excel de usabilidad

> El Excel describe las maquetas del diseño inicial (paleta de 4 colores, módulos con los nombres anteriores). Con el rediseño, sus filas se refieren a las mismas pantallas, pero **el Excel hay que actualizarlo** (por ejemplo, la fila 05 "Buffet" es hoy la Tienda de alumnos y la 06 "Planillas" es Préstamo de equipos).

Las filas se refieren a [`maquetado-y-usabilidad.xlsx`](./maquetado-y-usabilidad.xlsx) (cada celda de la columna "Heurística" lleva la etiqueta H1 a H10).

| Heurística | Filas del Excel donde se aplica |
| :--- | :--- |
| H1 Visibilidad del estado del sistema | 03 Objetos, 04 Higiene, 05 Tienda, 07 Sectores, 08 Ed. Física |
| H2 Coincidencia entre el sistema y el mundo real | 02 Dashboard, 04 Higiene |
| H3 Control y libertad del usuario | 02 Dashboard (menú ☰), 03 Objetos |
| H4 Consistencia y estándares | 02 Dashboard |
| H5 Prevención de errores | 01 Acceso, 06 Préstamo, 08 Ed. Física (opciones en gris y botón deshabilitado), confirmaciones Sí/No |
| H6 Reconocimiento antes que recuerdo | 03 Objetos |
| H7 Flexibilidad y eficiencia de uso | 01 Acceso (Enter), 06 Planillas (filtro con Enter) |
| H8 Diseño estético y minimalista | 05 Tienda |
| H9 Ayudar a reconocer, diagnosticar y recuperarse de errores | 07 Sectores |
| H10 Ayuda y documentación | 01 Acceso (tooltips y placeholders), 06 Planillas |

---

## 5. Tablas nuevas y medios de verificación

| Tabla | Tipo | Para qué sirve | Requerimiento |
| :--- | :--- | :--- | :--- |
| `log_auditoria` | Entidad | Registro de auditoría (14 tipos de evento, resultado Exitoso o Fallido) | RF18 |
| `tipo_log` | Catálogo | Tipo de acción registrada | RF18 |
| `resultado_log` | Catálogo | Resultado de la acción registrada | RF18 |
| `entidad_log` | Catálogo | Tabla afectada por la acción (12 entidades; regla de datos categorizables) | RF18 |
| `tipo_sector` | Catálogo | Tipo de sector (Reservable, Uso común); reemplaza a la marca `reservable` | RF01, RF03, RF04, RF09, RF10 |
| `categoria_producto` | Catálogo | Categoría de producto de la tienda (Comida, Bebida, Accesorios, Ropa, Otros) | RF05 |
| `software` | Catálogo | Programas que pueden estar instalados en un equipo | RF20 |
| `recurso_software` | Entidad (relación) | Qué programas tiene cada equipo | RF20 |

| Medio de verificación del MML | Dónde se obtiene |
| :--- | :--- |
| Uso del sistema (Propósito) | Registros de las tablas de cada módulo (con su fecha) y `log_auditoria`, consultados con SQL en la base o, los últimos 50, en la pestaña Auditoría del Preceptor. Reemplaza a "logs de uso" y "reportes automáticos" |
| Tiempo de resolución (Fin) | `reporte_higiene`: fecha y hora de resolución menos fecha y hora del reporte |
| Tiempo de respuesta (Componentes) | Tabla de medición de RNF03 en [`requerimientos.md`](./requerimientos.md) |

---

## 6. Las 47 tablas del script → requerimientos

Salen de `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` (47 sentencias `CREATE TABLE`) cruzadas con la sección 1. Se verificó con un script que cada tabla aparece al menos en un RF; ninguna quedó sin mapear.

| Tabla | Requerimientos que la usan |
| :--- | :--- |
| `rol` | RF09, RF13, RF21 |
| `especialidad` | RF13, RF17 |
| `turno` | RF12 |
| `dia_semana` | RF11, RF12 |
| `categoria_objeto` | RF01 |
| `estado_objeto` | RF01, RF02 |
| `estado_reclamo` | RF02 |
| `tipo_reporte` | RF03 |
| `estado_reporte` | RF03, RF04 |
| `estado_reserva` | RF09, RF10, RF16 |
| `estado_venta` | RF05, RF19 |
| `tipo_recurso` | RF07, RF08 |
| `estado_recurso` | RF07, RF08, RF22 |
| `carro` | RF07 |
| `deporte` | RF11 |
| `tipo_log` | RF18 |
| `resultado_log` | RF18 |
| `entidad_log` | RF18 |
| `tipo_sector` | RF01, RF03, RF04, RF09, RF10 |
| `categoria_producto` | RF05 |
| `software` | RF20 |
| `anio` | RF07, RF13, RF17 |
| `division` | RF07, RF13, RF17 |
| `franja_horaria` | RF11, RF12 |
| `curso` | RF07, RF12, RF13, RF17, RF23 |
| `usuario` | RF01, RF02, RF03, RF04, RF05, RF06, RF07, RF08, RF09, RF10, RF11, RF12, RF13, RF14, RF15, RF16, RF17, RF18, RF19, RF21, RF23 |
| `materia` | RF12 |
| `horario_escolar` | RF12, RF23 |
| `horario_dia` | RF12 |
| `sector` | RF01, RF03, RF04, RF09, RF10 |
| `objeto_perdido` | RF01, RF02 |
| `reclamo_objeto` | RF02 |
| `consulta_objeto` | RF14 |
| `reporte_higiene` | RF03, RF04 |
| `grupo_buffet` | RF05, RF06, RF15 |
| `integrante_grupo` | RF15 |
| `producto_buffet` | RF05, RF15, RF19 |
| `venta_buffet` | RF05, RF15, RF19 |
| `detalle_venta` | RF05, RF15, RF19 |
| `donacion_buffet` | RF06, RF15 |
| `recursos_ct` | RF07, RF08, RF20, RF22 |
| `recurso_software` | RF20 |
| `prestamo_ct` | RF07, RF08 |
| `reserva_sector` | RF09, RF10, RF16 |
| `oferta_deporte` | RF11, RF12 |
| `inscripcion_ed_fisica` | RF11, RF23 |
| `log_auditoria` | RF18, RF23 |

Hay RF que no tienen tablas propias porque son transversales o de interfaz (RF21) y las páginas 0 (Landing) y 2 (Dashboard).
