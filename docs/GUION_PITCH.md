# IQUAL · Demo Day 24/11 · Guion por diapositiva

Duración total: unos 6 min 20 s (el rango pedido es 5 a 7). En cada diapositiva figura quién habla. Ulises abre y hace la demo (diapositivas 1 a 5); Thiago sigue desde la 6 hasta el final.

## Diapositiva 1 · Portada · Ulises · 0:10
«Buenas tardes. Somos Ulises Cabrera y Thiago Arce, de cuarto año de Computación. Les presentamos IQUAL, un sistema de gestión para nuestra escuela.»

## Diapositiva 2 · El problema · Ulises · 0:35
«Hoy, buena parte de lo que pasa a diario en la escuela no queda registrado. No hay un inventario de objetos perdidos. Las computadoras y los tableros se prestan con planillas en papel. Y los problemas de higiene se avisan de palabra, sin seguimiento. En el árbol de problemas lo definimos como desorganización operativa escolar. Sus consecuencias son pertenencias perdidas, clases interrumpidas y tiempo desperdiciado.»

## Diapositiva 3 · La propuesta · Ulises · 0:30
«Nuestra propuesta es IQUAL: un único sistema, desarrollado a medida de esta escuela. Lo usan cuatro tipos de usuario: alumno, profesor, preceptor y maestranza, y cada uno accede solo a lo que le corresponde. Reemplaza seis procesos que hoy se hacen con papeles o mensajes, y deja un registro de auditoría de quién hizo cada acción y cuándo.»

## Diapositiva 4 · Los seis módulos · Ulises · 0:20
«Incluye seis módulos: objetos perdidos, higiene y mantenimiento, tienda de alumnos, préstamo de equipos, reserva de sectores e inscripción a Educación Física. Están diseñados con los recursos reales de la escuela: los carros, los tableros, los talleres. A continuación lo vemos funcionando.»
**[APP]** Al terminar, pasar a la diapositiva 5 y abrir la aplicación (ya abierta en el login).

## Diapositiva 5 · Demostración en vivo · Ulises · 2:30
Thiago no habla: controla el tiempo.

| Min | Acción en la app | Qué se dice |
|---|---|---|
| 0:00 | Login como `alumno1` | «Ingreso como alumno. Veo un resumen y el menú de lo que puedo hacer.» |
| 0:20 | Objetos perdidos → «Campera azul» → Reclamar | «Reclamo un objeto perdido. Tengo que dar un detalle que solo conoce el dueño.» |
| 0:50 | Cerrar sesión → `preceptor1` → aprobar el reclamo → pestaña Auditoría | «El preceptor aprueba el reclamo, y la auditoría registra quién lo hizo y cuándo.» |
| 1:20 | Tienda → grupo «Viaje de Estudios 4to 1ra» → entregar una reserva | «En la tienda, al entregar una reserva, lo recaudado por el grupo se actualiza.» |
| 1:50 | Educación Física → martes de Vóley (en gris) y Handball | «La inscripción respeta el horario de cursada: el martes de vóley no se puede elegir porque coincide con Bases de Datos. En handball el cupo está completo.» |
| 2:15 | Solo si hay tiempo: `maestranza1` → Higiene → resolver un reporte → «Último mantenimiento» | «La maestranza resuelve un reporte de higiene y el último mantenimiento del sector se actualiza.» |
| 2:30 | Volver a la presentación (diapositiva 6) | «Hasta acá, el sistema en uso. Thiago explica cómo está construido.» |

Si la app no conecta o algo falla: no improvisar, pasar al video de respaldo.

## Diapositiva 6 · Tecnología · Thiago · 0:40
«Veamos cómo está construido. La aplicación es de escritorio, desarrollada en C++ con Qt, y los datos se guardan en una base MySQL dentro de la red de la escuela. Por eso no depende de internet ni requiere licencias. La base tiene 47 tablas y 27 rutinas almacenadas. Planificamos 104 pruebas y, hasta ahora, realizamos 80 de forma manual en la aplicación. Las contraseñas se guardan encriptadas y las acciones importantes quedan registradas en la auditoría.»

## Diapositiva 7 · Competencia · Thiago · 0:40
«Analizamos las alternativas actuales: miEscuela, Google Classroom, Clickedu y Alexia. Resuelven bien la parte académica: matrícula, notas y asistencia. Según lo que pudimos leer en sus sitios, ninguna contempla objetos perdidos, préstamo de equipos, reserva de sectores ni reportes de higiene. Por eso IQUAL no las reemplaza: las complementa. Además funciona en la red local de la escuela, sin necesidad de internet.»

## Diapositiva 8 · La inversión · Thiago · 0:40
«Veamos qué costaría llevarlo a una escuela. Es un modelo de negocio, hecho con estimaciones nuestras: no es una cotización real. La instalación, configuración y capacitación del personal, 4 millones y medio de pesos, y un soporte mensual de 80 mil. No hay costo de licencias. Si la escuela no tiene un equipo para instalarlo, hay que sumar servidor, UPS y disco de copias, unos 870 mil pesos. Estimamos nuestro trabajo en 320 horas a 10 mil pesos la hora. El beneficio para la escuela sería tiempo y orden, pero eso habría que medirlo antes de prometer nada.»

## Diapositiva 9 · Conclusión · Thiago · 0:25
«Para concluir: IQUAL sirve para reunir en una sola aplicación lo que hoy se resuelve con papeles, planillas y mensajes. Sus beneficios son que cada dato queda registrado, que cada usuario ve solo lo que le corresponde, que hay una auditoría de quién hizo qué y cuándo, y que funciona en la red de la escuela, sin internet ni licencias. Hoy funciona con los datos de nuestra escuela, y nos falta terminar de probarlo antes de pensar en instalarlo. En definitiva, menos tiempo perdido y más orden.»

## Diapositiva 10 · Gracias · Thiago y Ulises · 0:10
«Muchas gracias por su atención. Quedamos a disposición para las preguntas.»

---

## Preguntas probables

- **¿Cuántas pruebas hicieron?** Planificamos 104 pruebas y realizamos 80 de forma manual en la aplicación. Las que fallaron las corregimos o las anotamos.
- **¿De dónde salen los precios?** Son estimaciones nuestras: 320 horas a $10.000 la hora, más infraestructura y soporte. Se ajustan con datos reales.
- **¿Cuánto ahorra la escuela?** Todavía no lo medimos; por eso proponemos un piloto de un mes.
- **¿Por qué no usar Classroom o miEscuela?** Resuelven lo académico. IQUAL cubre objetos perdidos, préstamos, reserva de sectores e higiene. Se complementan.
- **¿Y si falla el servidor?** La aplicación avisa el motivo y no abre hasta que se restablezca; hay copias de seguridad.

## Antes de salir

1. En DBeaver, correr 03, 04 y 05 (en ese orden) y verificar 47 tablas, 62 usuarios y 27 rutinas. Recargar la base después de cada ensayo.
2. Abrir la app en el login; probar `alumno1`, `preceptor1`, `maestranza1`.
3. Ensayar la demo dos veces con cronómetro y una vez sin wifi.
4. Llevar cargador, adaptador HDMI y pendrive con la presentación, el video de la demo y capturas de respaldo.
5. Notificaciones apagadas y notebook en «no suspender».
