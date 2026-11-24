# Guion del pitch — PROYECTO IQUAL® (SGE) · Demo Day

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Plan de Aprendizaje:** 4° bimestre, semana 6 (Demo Day, 5 a 7 minutos, demo en vivo, preguntas sobre viabilidad, competencia y arquitectura)
**App descripta:** v3 (`iqual_integrado_v3`, CONTEXTO §20, 13/11/2026).
**Duración prevista:** 6 minutos (entra en el rango de 5 a 7). Si se pasan, se recorta la demo (sección 3), no el problema ni los costos.

> Los textos entre comillas están escritos **para decirse en voz alta**, en lenguaje de todos los días. Cada uno puede cambiar las palabras, pero no los datos. Todo lo que está entre `[COMPLETAR: …]` es un dato que falta y **no se puede decir en el pitch hasta cargarlo**.

---

## 1. Estructura y tiempos (Pitch Deck)
| # | Diapositiva | Quién (a definir) | Tiempo | Acumulado |
|---|---|---|---|---|
| 1 | Problema (Árbol de Problemas) | Ulises | 0:45 | 0:45 |
| 2 | Solución: qué es IQUAL | Thiago | 0:30 | 1:15 |
| 3 | **Demo en vivo** | Ulises maneja la app, Thiago narra | 2:45 | 4:00 |
| 4 | Competencia y diferencial | Thiago | 0:50 | 4:50 |
| 5 | Costos, precio y retorno | Ulises | 0:55 | 5:45 |
| 6 | Cierre | Thiago y Ulises | 0:15 | 6:00 |

Orden pedido por el plan: Problema → Solución y Demo → Competencia y Diferencial → Costos, Precio y ROI.

## 2. Texto para decir

### Diapositiva 1 — Problema (0:00 a 0:45)
*En pantalla: el Árbol de Problemas (`arbol-de-problemas.png`).*

> «En la E.T. N°3 pasan muchas cosas todos los días que no están en ningún sistema. Alguien deja una campera en el patio y nadie sabe dónde quedó. Un profesor necesita una computadora del carro y hay que acordarse quién la tiene. Una canilla pierde agua y el aviso se pierde en un pasillo. Reservar la biblioteca depende de preguntarle a la persona correcta.
> Eso es lo que muestra nuestro Árbol de Problemas: **la escuela se organiza con papeles, mensajes y memoria**, y de ahí salen los efectos: cosas perdidas, tiempo desperdiciado y menos confianza de la comunidad.»

*(Árbol real: problema central «Desorganización operativa escolar»; 6 causas, p. ej. gestión ineficiente de objetos perdidos y control en papel de computadoras y tabletas; efectos: pérdida de pertenencias, deterioro edilicio, dificultad para cumplir metas, pérdida de clase, conflictos en biblioteca y laboratorio, inasistencias en Ed. Física.)*
*(No hay mediciones en el proyecto: no decir números del problema.)*

### Diapositiva 2 — Solución (0:45 a 1:15)
*En pantalla: captura del Inicio con la barra lateral.*

> «Nuestra solución es **IQUAL**, un sistema de gestión escolar que hicimos nosotros: una aplicación de escritorio en C++ con Qt y una base de datos MySQL de 47 tablas. Tiene cuatro roles —alumno, profesor, preceptor y maestranza— y cada uno ve solo lo que le corresponde.
> Resuelve seis cosas de la vida diaria: objetos perdidos, higiene y mantenimiento, tienda de alumnos con grupos de recaudación, préstamo de equipos, reserva de sectores e inscripción a Educación Física. Y todo lo que importa queda en una auditoría. Se los mostramos funcionando.»

### Diapositiva 3 — Demo en vivo (1:15 a 4:00)
Se hace con la app abierta, **no con capturas** (las capturas son el plan B, ver 4.3). Pasos en la sección 3.

### Diapositiva 4 — Competencia y diferencial (4:00 a 4:50)
*En pantalla: matriz resumida de `ANALISIS_COMPETENCIA.md` (solo 4 filas: Notas y asistencia / Objetos perdidos / Préstamo de equipos / Reserva de sectores).*

> «Miramos qué hay hoy. Plataformas como miEscuela, que es del Gobierno de la Ciudad, Google Classroom, o productos comerciales como Clickedu y Alexia, resuelven muy bien lo académico: matrícula, notas, asistencia, comunicación con las familias. Según lo que pudimos leer de cada una, **ninguna menciona objetos perdidos, préstamo de equipos, reserva de sectores ni reportes de higiene**.
> No venimos a reemplazar el sistema de notas: **lo complementamos**. IQUAL cubre lo que pasa entre una clase y la otra, hecho a la medida de nuestra escuela: los carros C4 y C5, los tableros, los sectores y los deportes reales. Y funciona en la red de la escuela, con MySQL local, sin depender de internet.»

(Esto se apoya en que las páginas consultadas no lo mencionan: si preguntan, la respuesta es la 9 de la sección 5.)

### Diapositiva 5 — Costos, precio y retorno (4:50 a 5:45)
*En pantalla: la tabla resumen de `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`, sección 9.*

> «Armamos el presupuesto con las horas de cada rol del equipo: unas 320 horas a $10.000 la hora, $3.200.000 de desarrollo. En licencias el costo es cero: MySQL Community y Qt se usan gratis para un proyecto educativo. Mantenerlo en una escuela cuesta unos $720.000 por año.
> Pensamos cobrarlo como **proyecto llave en mano más soporte mensual**: instalamos, configuramos y capacitamos, y después acompañamos. El precio sería $4.500.000 de instalación más $80.000 por mes de soporte y recuperaríamos la inversión con la primera escuela. La versión como servicio por suscripción es una etapa futura, porque hoy IQUAL es de escritorio.
> Y para la escuela el retorno es tiempo y orden; todavía lo tenemos como hipótesis a medir, no como resultado.»

### Diapositiva 6 — Cierre (5:45 a 6:00)
> «IQUAL junta en un solo lugar lo cotidiano de la escuela, y ya funciona. Nos queda probarlo con usuarios reales y sumar más módulos. Gracias; les mostramos lo que quieran ver y respondemos preguntas.»

## 3. Demo en vivo (2:45)
**Datos de demostración** (CONTEXTO §8; las claves y PIN están en el script de datos y en `GUIA_CONEXION_APP_MYSQL.md`, **no se escriben acá**): usuarios `alumno1` (4° 1° Computación, con horario cargado), `alumno2`, `profe1`, `preceptor1` y `maestranza1`.

### 3.1 Antes de subir (checklist, 10 minutos antes)
1. MySQL funcionando y la base **recién cargada** con `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` (GUIA_INSTALACION_MYSQL.md). Varios pasos de la demo cambian datos: después de ensayar hay que **volver a cargar la base**.
2. Abrir la app y mirar el **título de la ventana: tiene que decir «· MySQL»** (o «· MySQL (ODBC)»). Si la app no conectó, avisa «No se pudo usar MySQL: …» y no abre: levantar el servidor MySQL, revisar `iqual.ini` y volver a abrirla antes de subir.
3. Tener las sesiones listas **en este orden**: `alumno1`, luego `preceptor1`. Tener a mano la ventana de login para no perder tiempo.
4. **Reservas de sectores:** el `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` que recibí las carga con fechas relativas (hoy+1 y hoy+2), así que aparecen siempre. Si igual no se vieran, la demo de sectores se hace creando una reserva en vivo.
5. Tener las capturas (`capturas/`) en una carpeta abierta por si la app falla.

### 3.2 Pasos y texto de cada uno
| Tiempo | Quién/Rol | Pasos en la app | Qué se dice |
|---|---|---|---|
| 1:15–1:30 | `alumno1` | 1. Iniciar sesión con `alumno1`. 2. Se ve el **Inicio** con el resumen. | «Entro como alumno. Esto es lo que ve un alumno: un resumen y el menú de lo que puede hacer.» |
| 1:30–2:05 | `alumno1` → `preceptor1` | 1. Menú **Objetos perdidos**. 2. Elegir «Campera azul» (Disponible). 3. **Reclamar** y escribir el detalle (por ejemplo, de qué color es el forro). 4. Cerrar sesión. 5. Entrar como `preceptor1`, pestaña **Reclamos**, **aprobar** el reclamo. 6. Mostrar la pestaña **Auditoría**. | «El alumno reclama la campera y tiene que explicar cómo sabe que es suya. El preceptor lo ve, lo aprueba, y todo queda registrado en la auditoría: quién, qué y cuándo.» |
| 2:05–2:35 | `alumno1` y el usuario vendedor | 1. Iniciar sesión con `alumno1`. 2. Menú **Tienda de alumnos**, pestaña **Grupos y donaciones**: mostrar «Viaje de Estudios 4to 1ra» (meta $50.000, recaudado $3.500 = 7%; CONTEXTO §8). 3. Con la misma sesión de `alumno1` (es el vendedor del Alfajor de dulce de leche que reservó `preceptor1`; el script la carga en estado «Reservada»), entrar a la pestaña **Mis ventas** y marcar **Entregar** esa reserva. 4. Volver al grupo: pasa a $5.100 = 10%. | «Un grupo de 4° junta plata para el viaje vendiendo alfajores y sándwiches. Cuando el vendedor entrega una reserva, lo recaudado sube solo: de 3.500 a 5.100 pesos.» |
| 2:35–3:05 | `alumno1` | 1. Menú **Educación Física**. 2. Deporte **Vóley**, día **martes**: queda en gris «(choca con tu horario)» (choca con Bases de Datos). 3. Deporte **Handball**, lunes 08:00–10:00: franja «No hay lugar: todos los cupos están ocupados» (el cupo 1/1 lo tiene `alumno2`). | «Educación Física se fija en el horario de cursada: el martes del vóley choca con Bases de Datos, así que ni te deja elegirlo. Y Handball tiene un cupo y ya está ocupado.» |
| 3:05–3:40 | `alumno1` → `preceptor1` (opcional) | 1. Menú **Reserva de sectores**: mirar la ocupación. 2. (Si se usa un `profe1`) crear una reserva de Biblioteca; queda «Pendiente de aprobación» en gris; el preceptor la aprueba y pasa a verde. | «Reservar la biblioteca ya no depende de preguntar: se pide en la app y el preceptor la aprueba.» |
| 3:40–4:00 | cualquiera | Alternar el **tema oscuro** con el botón correspondiente y volver al claro. | «Y tiene tema claro y oscuro, que se recuerda para la próxima vez.» |

El tramo de 3:05 en adelante es el que se **recorta primero** si se pasan de tiempo.

### 3.3 Si algo falla (plan B)
| Falla | Qué hacer |
|---|---|
| La app no conecta con MySQL | Decir «el sistema avisa el motivo («No se pudo usar MySQL: …») y no abre hasta que se levante el servidor» (es verdad: no hay base de respaldo). Mostrar el aviso, levantar el servidor MySQL, revisar `iqual.ini` y volver a abrir la app. Si no se logra, mostrar la base y las consultas desde DBeaver. |
| Un paso no da el resultado esperado | No improvisar: pasar a la captura de ese módulo y seguir con el siguiente. |
| Se cuelga la app | Volver a abrirla (tarda segundos) o pasar a las capturas. |
| Se pasan de tiempo | Saltear sectores y tema oscuro (3:05 a 4:00). |

## 4. Materiales para llevar
1. Pitch Deck con las 5 diapositivas (Problema, Solución, Competencia, Costos y Cierre; la demo no lleva diapositiva): hecho (10 diapositivas, con notas del orador); los números de presupuesto son estimaciones del equipo.
2. Computadora con la app compilada, MySQL y la base cargada (probar **en esa misma computadora** antes: el camino de Windows no se probó, ver `MANUAL_TECNICO.md`, sección 7).
3. Capturas (`capturas/`) y los manuales de usuario y técnico (entregables del plan).
4. Este guion impreso.

## 5. Diez preguntas probables y respuestas cortas
**1. ¿Por qué MySQL y no otra base?**
«Porque es la que vimos en Bases de Datos, es gratuita en su edición Community y se instala en el servidor de la escuela. Nuestro modelo es portable: tenemos los scripts también para SQL Server 2005, y la app usa solo MySQL.» *(Nota: la confirmación del profesor Linares sobre MySQL todavía está pendiente; si lo preguntan, decir que fue decisión del equipo.)*

**2. ¿Cómo se conecta la aplicación a la base?**
«Lee un archivo `iqual.ini` que está junto al ejecutable, con el servidor, el puerto, el usuario y el nombre de la base. Usa el driver de MySQL de Qt o, si no lo tiene, ODBC. Si falla, avisa el motivo y no abre. Todas las consultas se hacen con parámetros.»

**3. ¿Está normalizada? ¿Hasta qué forma?**
«Sí, hasta Tercera Forma Normal. Son 47 tablas: 24 catálogos y 23 entidades y relaciones. La justificación está en un documento (`justificacion_3FN.md`).»

**4. ¿Qué pasa si el servidor MySQL se cae?**
«La aplicación avisa el motivo y no abre: no hay base de respaldo. Limitación declarada; la solución es levantar el servidor y, de fondo, tener una copia de seguridad de la base.»

**5. ¿Por qué es de escritorio y no web o celular?**
«Fue una decisión de alcance: se usa en la red de la escuela y el plan pedía una aplicación en C++ con Qt. Una versión web o móvil sería otra etapa, y es lo que haría falta para ofrecerlo como servicio por suscripción.»

**6. ¿Qué tan segura es?**
«Hay roles y permisos por pantalla, las contraseñas se guardan con hash SHA-256, las consultas usan parámetros (no se arman con texto del usuario) y toda acción importante queda en una auditoría. Limitaciones que conocemos y declaramos: el hash no lleva sal y el PIN de los grupos de recaudación se guarda sin cifrar.»

**7. ¿Cómo la probaron?**
«Hay 337 casos de prueba escritos para todas las pantallas y 53 errores detectados leyendo el código, 20 ya corregidos y ninguno grave. Además se corrieron pruebas automáticas y los scripts de la base sin fallas en Linux con MariaDB. **Lo que todavía no hicimos** es ejecutar los casos a mano y probar en Windows: está declarado.» *(Ser honestos: no decir «probado» si no se corrieron los casos.)*

**8. ¿Por qué no usan Google Classroom o miEscuela?**
«Son buenas y gratuitas para lo académico, pero según lo que leímos no resuelven objetos perdidos, préstamo de equipos, reserva de sectores ni higiene. No competimos con ellas: IQUAL las complementa.»

**9. ¿Hay algo parecido en el mercado que haga lo mismo?**
«Revisamos ocho alternativas (estatales, gratuitas y comerciales) y en las páginas que pudimos leer no aparecen esos módulos. Eso no prueba que nadie los tenga; es lo que encontramos. Si alguien conoce uno, nos interesa compararlo.»

**10. ¿Cuánto cuesta y cómo ganan plata? ¿Escala a más usuarios?**
«Licencias de software, cero. El costo real es el trabajo: unos 3,2 millones de pesos de desarrollo y 720 mil por año de mantenimiento (estimaciones del equipo). Lo cobraríamos como llave en mano más soporte. Sobre cuántos usuarios aguanta: todavía no lo medimos (RNF03); es lo próximo que probaríamos.»

*Preguntas de reserva (si hay tiempo para prepararlas):* ¿por qué C++ y Qt (lo pedía el plan: «C/Qt»; Qt permite interfaces de escritorio con un solo código)? · ¿quién restablece una contraseña olvidada (hoy no hay recuperación; preguntar en la escuela quién lo haría)? · ¿qué pasa con los datos de los alumnos y la privacidad? no tenemos una política definida; los datos quedan en el servidor de la escuela.

## Desvíos
- **Ronda final:** actualicé las cifras a la v3 (337 casos, 20 errores corregidos de 53) y resolví con el script lo que antes estaba como `[COMPLETAR]`: el vendedor de la reserva demo es `alumno1` y las reservas de sectores son relativas en MySQL.
- No escribí claves ni PIN: la demo usa los usuarios por nombre y las claves están en el script de datos.
- **Datos de demo:** CONTEXTO §8 está desactualizado frente al `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql` (fechas de las reservas de sectores, especialidad de `alumno2` y estado de las «Llaves con llavero rojo»). Para el guion valen el script (que verifiqué) y la v3.
- El guion usa datos que vienen de la documentación; **yo no ejecuté la app**, así que los pasos de la demo (en especial los textos exactos de pantalla y que la reserva de demostración de la Tienda se pueda entregar con `alumno1`) hay que ensayarlos.
- No tengo el texto del Árbol de Problemas, solo lo que citan los documentos; dejé marcado dónde pegar las palabras reales.
- El tiempo por parte es una propuesta; hay que cronometrarlo ensayando.

## Datos que faltan
- Texto del Árbol de Problemas y, si existe, un dato real del problema. — **usuario**
- Reparto de quién habla en cada diapositiva. — **usuario**
- Totales de presupuesto: horas, costo, mantenimiento, precio, equilibrio (`PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`). — **usuario**
- Prueba de la demo completa en la computadora del Demo Day (Windows). — **usuario**
- Pitch Deck armado. — **usuario**
