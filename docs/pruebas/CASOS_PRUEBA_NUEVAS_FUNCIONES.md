# Casos de prueba de las funciones agregadas después del Demo Day (RF24, RF25 y RF26)

**Cómo se probó:** con la prueba automática `tests/test_funciones_nuevas.cpp`, que abre la ventana principal, escribe en los campos, aprieta los botones y comprueba lo que se ve en pantalla y lo que queda en la base y en la auditoría. Entorno: Linux, Qt 6.4, MariaDB 10.11, base cargada desde cero con `03`, `04` y `05`. **No se probó a mano en Windows con ODBC**: esas pruebas siguen pendientes y son las que valen para la entrega.

**Resultado: 36 de 36 comprobaciones OK.** Los casos por pantalla de `CASOS_PRUEBA_CONSOLIDADO.md` (337) no incluyen estas funciones.


## Recuperar contraseña

| N° | Comprobación | Resultado |
|---|---|---|
| 1 | el botón lleva a la pestaña Recuperar | OK |
| 2 | DNI incorrecto: avisa y descuenta un intento | OK |
| 3 | DNI incorrecto: no cambia la contraseña | OK |
| 4 | DNI incorrecto: queda en la auditoría como Fallido | OK |
| 5 | contraseñas distintas: avisa | OK |
| 6 | contraseña corta: avisa | OK |
| 7 | datos correctos: confirma el cambio | OK |
| 8 | datos correctos: queda en la auditoría como Exitoso con el usuario | OK |
| 9 | la contraseña vieja ya no sirve | OK |
| 10 | la contraseña nueva sirve y Mi cuenta muestra el ID 1 | OK |

## Aprobación de productos

| N° | Comprobación | Resultado |
|---|---|---|
| 11 | el alumno no ve la pestaña Por aprobar | OK |
| 12 | al publicar avisa que falta la aprobación | OK |
| 13 | Mis productos lo muestra como pendiente | OK |
| 14 | todavía no aparece en la tienda | OK |
| 15 | sp_comprar_producto rechaza un producto sin aprobar | OK |
| 16 | otro alumno no lo ve en la tienda | OK |
| 17 | el preceptor ve la pestaña Por aprobar | OK |
| 18 | la pestaña indica 2 pendientes | OK |
| 19 | la lista tiene los 2 productos pendientes | OK |
| 20 | aprobar sin elegir avisa | OK |
| 21 | aprobar saca el producto de la cola | OK |
| 22 | el aprobado aparece en la tienda | OK |
| 23 | rechazar pide confirmación y saca el producto de la cola | OK |
| 24 | el rechazado no aparece en la tienda | OK |
| 25 | las dos revisiones quedaron en la auditoría | OK |
| 26 | el rechazado guarda aprobado 0 y el revisor | OK |
| 27 | el alumno ve su producto como RECHAZADO | OK |
| 28 | sp_comprar_producto acepta el producto ya aprobado | OK |

## Id de usuario en préstamos

| N° | Comprobación | Resultado |
|---|---|---|
| 29 | el preceptor ve el campo ID del alumno | OK |
| 30 | escribir 2 elige al alumno con ID 2 (Alumno Dos) | OK |
| 31 | un ID que no existe vuelve a 'Elegí el alumno' | OK |
| 32 | un texto no numérico no elige a nadie | OK |
| 33 | Enter en el ID registra el préstamo | OK |
| 34 | el préstamo quedó a nombre del usuario con ID 2 | OK |
| 35 | Enter con un ID inexistente avisa | OK |
| 36 | el alumno no ve el campo ID del alumno | OK |

## Qué quedó sin probar
- Los mismos casos a mano en Windows, con la base por ODBC.
- Qué pasa con muchos usuarios a la vez.
- La versión SQL Server de las tablas (`03_ModeloSQL_Grupo00_sqlserver.sql`): se cambió `producto_buffet` igual que en MySQL, pero solo se revisó por lectura.
