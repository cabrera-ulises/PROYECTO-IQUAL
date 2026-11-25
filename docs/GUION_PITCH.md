# Guion de la presentación (Demo Day, 24/11/2026)

Versión final, 11 diapositivas. Las notas salen de la presentación en `docs/presentacion/`.

## Diapositiva 1: IQUAL®

ULISES (10 s): «Buenas tardes. Somos Ulises Cabrera y Thiago Arce, de cuarto año de Computación. Les presentamos IQUAL, un sistema de gestión para nuestra escuela.»

## Diapositiva 2: Gran parte de la gestión diaria de la escuela no queda registrada

ULISES (35 s): «Hoy, buena parte de lo que pasa a diario en la escuela no queda registrado. No hay un inventario de objetos perdidos. Las computadoras y los tableros se prestan con planillas en papel. Y los problemas de higiene se avisan de palabra, sin seguimiento. En el árbol de problemas lo definimos como desorganización operativa escolar. Sus consecuencias son pertenencias perdidas, clases interrumpidas y tiempo desperdiciado.»

## Diapositiva 3: Un único sistema para la gestión cotidiana

ULISES (30 s): «Nuestra propuesta es IQUAL: un único sistema, desarrollado a medida de esta escuela. Lo usan cuatro tipos de usuario: alumno, profesor, preceptor y maestranza, y cada uno accede solo a lo que le corresponde. Reemplaza seis procesos que hoy se hacen con papeles o mensajes, y deja un registro de auditoría de quién hizo cada acción y cuándo.»

## Diapositiva 4: Lo que pasa entre una clase y la otra

ULISES (20 s): «Incluye seis módulos: objetos perdidos, higiene y mantenimiento, tienda de alumnos, préstamo de equipos, reserva de sectores e inscripción a Educación Física. Están diseñados con los recursos reales de la escuela: los carros, los tableros, los talleres. A continuación lo vemos funcionando.»
[APP] Al terminar la frase, pasar a la diapositiva de la demo y abrir la aplicación.

## Diapositiva 5: Uso real del sistema, con datos de nuestra escuela

ULISES maneja la app y habla (2:30). Thiago espera sin hablar.
[APP 0:00] La app ya está abierta en el login. «Ingreso como alumno» → alumno1.
[APP 0:20] Objetos perdidos → «Campera azul» → Reclamar. «No alcanza con decir que es mía: tengo que dar un detalle que solo sabe el dueño.»
[APP 0:50] Cerrar sesión → preceptor1. Aprobar el reclamo y abrir Auditoría. «Acá queda quién lo hizo y cuándo.»
[APP 1:20] Tienda → grupo «Viaje de Estudios 4to 1ra» → entregar una reserva. «Ahora lo recaudado sube solo.»
[APP 1:50] Educación Física → el martes de Vóley aparece en gris porque choca con Bases de Datos. «Y en Handball el cupo está lleno.»
[APP 2:15] Si hay tiempo: maestranza1 → Higiene → resolver un reporte → se actualiza el «Último mantenimiento». Si no, cerrar.
[APP 2:30] Volver a la presentación (diapositiva de tecnología).
Plan B: si falla la conexión, pasar el video grabado y seguir.

## Diapositiva 6: Funciona en la red de la escuela, sin internet y sin licencias

THIAGO (40 s): «Veamos cómo está construido. La aplicación es de escritorio, desarrollada en C++ con Qt, y los datos se guardan en una base MySQL dentro de la red de la escuela. Por eso no depende de internet ni requiere licencias. La base tiene 47 tablas y 27 rutinas almacenadas. Planificamos 104 pruebas y, hasta ahora, realizamos 80 de forma manual en la aplicación. Las contraseñas se guardan encriptadas y las acciones importantes quedan registradas en la auditoría.»

## Diapositiva 7: No venimos a reemplazar lo que ya existe, sino a complementarlo

THIAGO (30 s): «Hoy ya existen plataformas como Classroom, Clickedu, Alexia, miEscuela o AprendeBA, que se ocupan de cosas más generales: el aprendizaje, las tareas, los boletines, el seguimiento académico. IQUAL es distinto: se encarga de lo cotidiano de la escuela, como los objetos perdidos, los préstamos, las reservas de sectores o los reportes de higiene. No las reemplaza: las complementa. Y funciona en la red de la escuela, sin necesidad de internet.»

## Diapositiva 8: Qué costaría llevarlo a una escuela

THIAGO (40 s): «Veamos qué costaría llevarlo a una escuela. Es un modelo de negocio, hecho con estimaciones nuestras: no es una cotización real. La instalación, configuración y capacitación del personal, 4 millones y medio de pesos, y un soporte mensual de 80 mil. No hay costo de licencias. Si la escuela no tiene un equipo para instalarlo, hay que sumar servidor, UPS y disco de copias, unos 870 mil pesos. Estimamos nuestro trabajo en 320 horas a 10 mil pesos la hora. Además, usamos una licencia de Claude Pro, una herramienta de IA que cuesta unos 35 a 40 mil pesos por mes y nos ayuda con el desarrollo y el mantenimiento. El beneficio para la escuela sería tiempo y orden, pero eso habría que medirlo antes de prometer nada.»

## Diapositiva 9: Qué le falta a IQUAL

THIAGO (30 s): «Para ser sinceros, todavía es un prototipo y le faltan bastantes cosas. Por ejemplo, un sistema para recuperar la contraseña, porque hoy la restablece el responsable del sistema. Que el preceptor pueda aprobar los productos antes de que se publiquen en la tienda. Un ID personal de usuario, para registrar un préstamo en persona con solo decirlo. Notificaciones, porque hoy hay que entrar a mirar. Y terminar de probar, además de medir qué pasa con muchos usuarios a la vez.»

## Diapositiva 10: IQUAL ordena la gestión cotidiana de la escuela

THIAGO (25 s): «Para concluir: IQUAL sirve para reunir en una sola aplicación lo que hoy se resuelve con papeles, planillas y mensajes. Sus beneficios son que cada dato queda registrado, que cada usuario ve solo lo que le corresponde, que hay una auditoría de quién hizo qué y cuándo, y que funciona en la red de la escuela, sin internet ni licencias. Hoy funciona con los datos de nuestra escuela, y nos falta terminar de probarlo antes de pensar en instalarlo. En definitiva, menos tiempo perdido y más orden.»

## Diapositiva 11: Gracias

THIAGO Y ULISES (10 s): «Muchas gracias por su atención. Quedamos a disposición para las preguntas.»
