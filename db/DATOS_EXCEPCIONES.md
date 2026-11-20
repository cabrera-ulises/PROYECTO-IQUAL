# DATOS_EXCEPCIONES.md — tablas con menos de 20 filas en `04_DatosSQL`

Regla de la consigna (CONTEXTO_IQUAL §21): toda tabla que admita 20 o más filas plausibles las tiene. Las 47 tablas quedan así: **22 tablas con 20 filas o más**, **24 catálogos cerrados con menos de 20** y **`log_auditoria` vacía a propósito**. Las cantidades salen de la consulta 17 de `consultas_verificacion_*.sql` (se midieron con una carga de prueba de los mismos datos fuera de MySQL y SQL Server; en MySQL y SQL Server hay que confirmarlas).

## 1. Catálogos cerrados (24 tablas)

| Tabla | Filas | Motivo | Se podría llegar a 20 sin inventar? |
|---|---|---|---|
| `rol` | 4 | Alumno, Profesor, Preceptor, Maestranza: los 4 roles del sistema (§6) | No: un rol más cambiaría los permisos de la app |
| `especialidad` | 3 | Computación, Geografía-Matemática, Óptica: las que tiene el 4° año de la escuela | No |
| `turno` | 2 | Mañana y Tarde | No: la escuela no tiene otro turno |
| `dia_semana` | 5 | Lunes a viernes | No: no se cursa fines de semana |
| `categoria_objeto` | 6 | Categorías de objetos perdidos definidas en el diseño | Solo agregando categorías de relleno |
| `estado_objeto` | 4 | Estados del flujo (Disponible, En reclamo, Devuelto, …) | No: cada estado es una regla de negocio |
| `estado_reclamo` | 3 | Pendiente, Aprobado, Rechazado | No |
| `tipo_reporte` | 2 | Tipos de reporte de higiene | No |
| `estado_reporte` | 2 | Pendiente y Resuelto | No |
| `estado_reserva` | 4 | Pendiente, Aprobada, Rechazada, Cancelada | No |
| `estado_venta` | 3 | Reservada, Entregada, Cancelada | No |
| `tipo_recurso` | 2 | Computadora y Tablero de dibujo | No |
| `estado_recurso` | 3 | Disponible, Prestado, Fuera de servicio | No |
| `carro` | 5 | C1 a C5: los carros de computadoras de la escuela (dato a confirmar con la escuela) | No |
| `deporte` | 4 | Los deportes de Educación Física que ofrece la escuela | No |
| `tipo_log` | 14 | Un tipo por cada evento que registran los procedimientos | No: cada uno corresponde a un procedimiento |
| `resultado_log` | 2 | Exitoso y Fallido | No |
| `entidad_log` | 12 | Una por cada entidad auditada | No |
| `tipo_sector` | 2 | Reservable y Uso común | No |
| `categoria_producto` | 5 | Comida, Bebida, Accesorios, Ropa, Otros | Solo con categorías de relleno |
| `software` | 6 | Programas instalados en los carros | Se podrían sumar programas ficticios, pero no corresponden a la escuela |
| `anio` | 7 | Años 1 a 7 (escuela técnica) | No |
| `division` | 9 | Divisiones 1 a 9 | No |
| `franja_horaria` | 5 | Franjas de Educación Física | No |

## 2. `log_auditoria`: 0 filas

La consigna pide que los logs los generen los procedimientos almacenados, no una carga manual. `04_DatosSQL` la deja vacía y se puebla al ejecutar `05_Backend` (o al usar la app). Hasta entonces las consultas 8A–8E y 9 de la verificación devuelven 0 filas, y eso es lo esperado.

## 3. Tablas que SÍ pasan de 20

usuario 62, curso 24, materia 21, horario_escolar 137, horario_dia 229, sector 22, objeto_perdido 23, reclamo_objeto 25, consulta_objeto 22, reporte_higiene 22, grupo_buffet 21, integrante_grupo 62, producto_buffet 30, venta_buffet 28, detalle_venta 37, donacion_buffet 26, recursos_ct 60, recurso_software 160, prestamo_ct 24, reserva_sector 28, oferta_deporte 20, inscripcion_ed_fisica 37.

## Para preguntarle a Linares

1. ¿Los catálogos cerrados (rol, estado_*, turno, tipo_*, día, año, división…) pueden quedar con pocas filas, o prefiere que lleguen a 20? Si pide 20, habría que agregar filas inventadas que la aplicación no usa.
2. ¿`log_auditoria` vacía en `04` es correcto, o quiere algunas filas cargadas? (Nuestra lectura de la consigna: vacía, y poblada por los procedimientos.)
3. ¿Cuenta como «tabla» cada una de las 47 para el mínimo de 20, o solo las entidades?

## Desvíos

- Pedido: tabla con motivo por cada tabla de menos de 20 filas. Agregué la columna «Se podría llegar a 20» para que se vea qué se descartó y por qué; si no hace falta, se borra.
- Los motivos de `carro` y `software` suponen datos de la escuela que no pude verificar.
- Los conteos no se vieron en MySQL ni en SQL Server: salen de la carga de prueba del 19/11/2026.

## Datos que faltan

- [COMPLETAR: respuesta de Linares sobre el mínimo de 20 en catálogos y sobre `log_auditoria`]
- [COMPLETAR: confirmar con la escuela los 5 carros, los deportes y los programas instalados]
