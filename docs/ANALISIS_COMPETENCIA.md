# Análisis de la competencia — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Plan de Aprendizaje:** 4° bimestre, semana 4 (matriz comparativa de funcionalidades y costos, y propuesta única de valor)
**Fecha de la consulta:** 12/11/2026 (revisión final de fuentes: 13/11/2026). Cada dato de otros productos sale de una página web leída ese día y lleva su fuente (sección 7). Cuando la página no informa fecha de publicación, se indica.

> **Cómo leer este documento:** «No figura en la fuente» significa que **la página que leí no lo menciona**, no que el producto no lo tenga. Para afirmar que alguien «no lo ofrece» habría que mirar el producto o pedir una demo (ver sección 8).

---

## 1. Qué es IQUAL hoy (lo que se compara)
IQUAL es una aplicación de escritorio (C++17 con Qt) para una escuela técnica, con base de datos MySQL y cuatro roles: Alumno, Profesor, Preceptor y Maestranza. Hoy resuelve estos módulos:

| Módulo de IQUAL | Qué hace |
|---|---|
| Objetos perdidos | Publicar objetos encontrados, reclamarlos con una prueba de pertenencia, aprobar o rechazar el reclamo, consultas y auditoría |
| Higiene y mantenimiento | Reportar problemas de baños y espacios, con seguimiento de pendientes y resueltos |
| Tienda de alumnos | Publicar y reservar productos, grupos de recaudación con meta, PIN y donaciones, entrega y stock |
| Préstamo de equipos | Préstamo y devolución de computadoras y tableros de los carros, con estado «funciona / no funciona» |
| Reserva de sectores | Reservar un lugar de la escuela en un día y horario, con aprobación del preceptor |
| Educación Física | Inscribirse a un deporte, día y hora, con cupos y control de choque con el horario de cursada |
| Mi cuenta y Auditoría | Cambio de curso, clave y teléfono; registro de lo que hace cada usuario |

**Lo que IQUAL no tiene hoy:** notas y boletines, asistencia, cobro de cuotas, comunicación masiva con familias ni aulas virtuales. No hay pantalla para eso (ver `requerimientos.md` y `MANUAL_TECNICO.md`, limitaciones). Lo digo porque es lo primero que cualquier jurado va a preguntar.

## 2. A quién se compara
Se eligieron alternativas reales que una escuela podría usar en lugar de IQUAL, de cuatro tipos:

| Tipo | Alternativas |
|---|---|
| Plataforma estatal | miEscuela (Ministerio de Educación de la Ciudad de Buenos Aires) |
| Herramienta gratuita general | Google Workspace for Education (Fundamentals y Classroom) |
| Software de gestión escolar comercial | Clickedu, Alexia (Educaria), Esemtia, Cifra Educación, e-Schooling |
| Sistema para ministerios (Argentina) | Tramix Gestión Educativa (Unitech) |

No se pudo averiguar con fuentes públicas qué sistema usa hoy E.T. N°3 para notas y legajos; por eso no figura en la comparación.

**Límite de esta búsqueda:** casi todos los productos comerciales que figuran en las fuentes son de España o de plataformas de comparación; **no pude confirmar que se vendan o se usen en Argentina** (salvo miEscuela y Tramix, que sí son argentinos). No uso ningún precio en euros ni en pesos: los pocos montos que había eran de páginas sin fecha y quedaron en sin dato (sección 4).

## 3. Matriz comparativa de funcionalidades
**✔** = la fuente lo menciona · **—** = no figura en la fuente · **No** = IQUAL no lo tiene hoy.

| Funcionalidad | IQUAL | miEscuela [1] | Google Workspace for Education / Classroom [2] | Clickedu [3][4a] | Alexia [4a][4b] | Esemtia [4a] | Cifra Educación [4a] | e-Schooling [6] | Tramix [7] |
|---|---|---|---|---|---|---|---|---|---|
| Matrícula / legajo del alumno | Parcial (alta de cuenta y curso) | ✔ | — | ✔ | ✔ | ✔ | — | ✔ (admisiones) | ✔ |
| Notas / calificaciones | No | ✔ | — | ✔ (evaluación) | ✔ | ✔ | — | — | ✔ |
| Asistencia / inasistencias | No | ✔ | — | — | ✔ | — | — | — | ✔ |
| Aulas virtuales / e-learning | No | ✔ (con Google Classroom) | ✔ (Classroom) | ✔ | — | — | — | ✔ | — |
| Comunicación con familias | No | — | — | ✔ | ✔ | ✔ | ✔ | ✔ (portal de padres) | — |
| Cobros y pagos | No (la compra se arregla en persona) | — | — | ✔ | ✔ (gestión económica) | ✔ (pagos online) | ✔ (pago electrónico) | ✔ (finanzas) | — |
| Tienda / venta entre usuarios | **✔** (alumnos publican y reservan) | — | — | — | — | ✔ (tienda del colegio) | ✔ (tienda con pago electrónico) | — | — |
| Recaudación grupal con meta | **✔** | — | — | — | — | — | — | — | — |
| Objetos perdidos | **✔** | — | — | — | — | — | — | — | — |
| Préstamo de equipos | **✔** | — | — | — | — | — | — | — (biblioteca) | — |
| Reserva de sectores | **✔** | — | — | — | — | — | — | — | — |
| Reportes de higiene y mantenimiento | **✔** | — | — | — | — | — | — | — | — |
| Inscripción a Educación Física con cupos | **✔** | — | — | — | — | ✔ (extraescolares, comedor, transporte) | ✔ (extraescolares) | — | — |
| Auditoría de acciones de usuarios | **✔** | — | — | — | — | — | — | — | — (la nota solo menciona administración de accesos y seguridad) |
| Funciona sin conexión a internet (red de la escuela) | **✔** (MySQL local) | — | — | — | — | — | — | Nube / SaaS / web (la fuente lo lista como plataforma) | — |

Notas de la matriz:
- Esemtia y Cifra son las únicas que mencionan tienda, extraescolares o comedor; son pagos y servicios **del colegio hacia las familias**, no entre alumnos.
- En e-Schooling aparece «gestión de bibliotecas»; es préstamo de libros, no de equipos, y no lo cuento como equivalente.
- Las celdas «—» no prueban que el producto no lo ofrezca: las fuentes son resúmenes de directorios o notas de prensa.

## 4. Matriz comparativa de costos
| Alternativa | Dato de costo publicado | Fuente y fecha |
|---|---|---|
| IQUAL | Sin precio definido todavía. Los costos de armar y sostener el proyecto están en `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`. Propuesta del equipo: llave en mano $4.500.000 + soporte $80.000 por mes (estimación; ver `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`) | Este proyecto |
| miEscuela | La página **no indica** si tiene costo | [1] (consultada 12/11/2026; sin fecha de publicación) |
| Google Workspace for Education Fundamentals (incluye Classroom) | Sin monto verificable. La página lo describía como «disponible sin cargo para las instituciones que cumplan los requisitos» | [2] (consultada 12/11/2026; la página no informa fecha) |
| Google Workspace for Education Plus | Sin monto verificable (la página dice «Consultar precios»: suscripción anual, sin monto) | [2] (ídem) |
| Clickedu | Sin monto verificable (la página muestra tres modelos posibles —pago único, sin licencia, mensual— sin decir cuál aplica) | [3] (consultada 12/11/2026; sin fecha) |
| Alexia (Educaria) | Sin monto verificable. El directorio leído da una referencia «orientativa» en euros, pero **sin fecha de publicación**, por eso no la uso como dato | [4b] (consultada 12/11/2026; sin fecha) |
| Esemtia, Cifra Educación | No publican monto en las fuentes consultadas | [4a] (12/01/2014, actualizado 03/07/2026) |
| e-Schooling | «Bajo cotización» (precio personalizado) | [6] (consultada 12/11/2026; solo informa el año 2026) sin dato |
| Tramix | La nota **no indica** precios | [7] 29/11/2012 (nota antigua) |
| Otros directorios (Atenea, Schooltivity, Playoff, Dinantia, Brainbond) | Sin monto verificable. El directorio [4b] los da como «orientativos», sin fecha de publicación | [4b] (sin fecha) |

Lo que se ve en las fuentes: las plataformas comerciales de gestión escolar **se ofrecen por suscripción o por cotización** (e-Schooling: «bajo cotización»; Google Workspace Plus: «consultar precios»); **no pude sostener ningún monto con fecha**, por eso las celdas quedan en sin dato. Lo estatal y lo de Google es gratis, pero **no resuelve** objetos perdidos, préstamos ni reservas de sectores (según las fuentes). Conversión a pesos: No se convirtieron montos a pesos porque no se usó ningún precio en euros..

## 5. Costos de lo que usa IQUAL (para compararlo contra estos precios)
| Componente | Dato verificado | Fuente |
|---|---|---|
| MySQL Community Edition | Se distribuye bajo licencia GPL y se descarga gratis | [9] (consultada 12/11/2026; fecha de la fuente sin dato) |
| MySQL: cuándo se paga | Según un artículo de asesoría de licencias (publicado 17/08/2026, actualizado 25/09/2026): el uso interno en producción de la edición Community no requiere pagar; se paga si se usan funciones exclusivas de Enterprise, si se **distribuye MySQL dentro de un producto** sin publicar bajo licencia compatible con GPL, o si se contrata soporte de Oracle. Lista de Oracle del 11/09/2025: Standard 2.140 USD por servidor por año (1 a 4 sockets). No es asesoramiento legal | [10] |
| Qt | Doble licencia: Community (LGPL o GPL, sin compra, pero «tu software debe poder copiarse, modificarse y distribuirse») o comercial (precio en qt.io/pricing, no pude leer los montos). Acceso gratuito educativo con fines de aprendizaje | [11] (consultada 12/11/2026; fecha de la fuente sin dato) |

Consecuencia para IQUAL: usar Qt Community y MySQL Community no tiene costo de licencia para un proyecto escolar, pero **si IQUAL se vendiera como producto cerrado habría que revisar la licencia de Qt** (o comprar la comercial) y **no instalar MySQL dentro del paquete de IQUAL** (que lo instale la escuela, como hoy). Si el proyecto se comercializara, conviene consultar la licencia con un profesional..

## 6. Propuesta única de valor (PUV)
**Qué nos diferencia:** las plataformas que encontré se concentran en lo **académico y administrativo** (matrícula, notas, asistencia, cobros, comunicación). IQUAL resuelve la **vida cotidiana de una escuela técnica**: lo que pasa entre el timbre y el timbre y casi nunca está en un sistema.

**Frase para el pitch (borrador):**
> «Las plataformas de gestión escolar saben quién es cada alumno y qué nota tiene. IQUAL sabe dónde quedó la campera, qué computadora del carro está prestada, quién reservó la biblioteca y cuánto falta para el viaje de egresados.»

**Cinco puntos que sostienen la PUV:**
1. **Cubre cosas que las fuentes no listan:** objetos perdidos, préstamo de equipos, reserva de sectores, reportes de higiene e inscripción a Educación Física con control de choque de horarios (matriz, sección 3).
2. **Hecho a la medida de esta escuela:** los carros C4 y C5, los tableros y las especialidades son los reales de E.T. N°3 (CONTEXTO §8).
3. **Funciona en la red de la escuela:** con MySQL local, sin depender de un servicio en la nube; si el servidor no está encendido, la app avisa y no abre.
4. **Trazabilidad:** toda acción importante queda en la auditoría.
5. **Sin costo de licencia de base y framework** (secciones 5 y 7) para el alcance escolar; el costo real es el de horas de desarrollo y soporte (ver presupuesto).

**Lo que NO podemos decir (y conviene reconocer en la defensa):**
- IQUAL **no reemplaza** a un sistema de notas y asistencia; **lo complementa**. Si la escuela ya usa uno, IQUAL no compite con eso.
- Es una aplicación de escritorio: no hay versión web ni app para celular; las familias no acceden.
- No fue probado en Windows ni con muchos usuarios a la vez (`MANUAL_TECNICO.md`, sección 7).
- La competencia con presupuesto y años de desarrollo (Clickedu, Alexia) tiene soporte, apps y miles de centros; nosotros tenemos un prototipo funcional.

## 7. Fuentes
Todas se consultaron el **12/11/2026**. La columna «Fecha de la fuente» es la que informa la página; si no la informa, queda sin dato.

| N° | Fuente | Fecha de la fuente | Qué se tomó |
|---|---|---|---|
| 1 | [Conocé miEscuela — Ministerio de Educación de la Ciudad de Buenos Aires](https://buenosaires.gob.ar/gcaba_historico/educacion/conoce-miescuela) | sin dato | Funciones de miEscuela; no informa costo |
| 2 | [Google Workspace for Education — ediciones](https://edu.google.com.co/products/workspace-for-education/editions) | sin dato | Fundamentals sin cargo para instituciones elegibles; Plus «Consultar precios»; Classroom incluido en todas las ediciones |
| 3 | [Clickedu — SoftwareDoit](https://www.softwaredoit.es/clickedu/clickedu.html) | sin dato | Funciones de Clickedu; modelos de precio posibles |
| 4a | [Plataformas de gestión escolar — Educación 3.0](https://www.educaciontrespuntocero.com/noticias/plataformas-gestion-escolar/12663.html) | Publicado 12/01/2014; actualizado 03/07/2026 | Funciones de Alexia, Cifra Educación, Clickedu, Educamos, Esemtia y Globaleduca; no da precios |
| 4b | [Los mejores software educativos de 2026 — SoftwareDoit](https://www.softwaredoit.es/erp-educativo/erp-educativo.html) | sin dato | Funciones de Alexia, Atenea, Playoff, Schooltivity, Dinantia, Brainbond; precios «orientativos» (**no usados**) |
| 6 | [e-Schooling — ComparaSoftware](https://www.comparasoftware.com/e-schooling) | sin dato | Funciones; precio «bajo cotización» |
| 7 | [Unitech presenta Tramix Gestión Educativa — Mercado](https://mercado.com.ar/varios/unitech-presenta-tramix-gestion-educativa) | 29/11/2012 (**nota antigua**: el producto pudo cambiar) | Funciones de Tramix |
| 9 | [MySQL Community Edition — mysql.com](https://www.mysql.com/de/products/community/) | sin dato | Licencia GPL y descarga gratuita |
| 10 | [MySQL Community (GPL) vs Enterprise: cuándo hay que pagar — Redress Compliance](https://redresscompliance.com/mysql-community-gpl-vs-enterprise-when-you-must-pay) | Publicado 17/08/2026; actualizado 25/09/2026 (consultora, no es fuente oficial de Oracle) | Cuándo se paga MySQL; lista de Oracle del 11/09/2025 |
| 11 | [Qt licensing — qt.io](https://www.qt.io/development/qt-framework/qt-licensing) | sin dato | Licencias de Qt |

(Los números 5 y 8 de la versión anterior eran referencias a [4a] y [4b]: Alexia está en 4a y 4b; Esemtia y Cifra, en 4a.)

## 8. Qué no se pudo verificar
- Las celdas «—» de las matrices significan que la página leída no lo menciona; confirmarlas exigiría una demo o consulta al proveedor.
- Ningún precio comercial tiene fuente fechada, por eso la matriz de costos no trae montos de la competencia.
- No se sabe si los productos españoles se venden en Argentina.
- Colegium, Phidias y WebColegios no pudieron leerse (sitio no accesible desde la herramienta de lectura), por eso no integran la matriz.

## 9. Actualización respecto del informe entregado en la semana 4
Este documento reemplaza al informe entregado en su momento. Cambios y motivos:

| Tema | Informe entregado | Versión final | Motivo |
|---|---|---|---|
| Base de datos | SQLite | **MySQL** (47 tablas en 3FN, 27 procedimientos) | Se eliminó SQLite: la clase de Bases de Datos trabaja con MySQL |
| Costo de IQUAL | «$0 en desarrollo y servidor», USD 20 de folletería, ~USD 50/año de red | Desarrollo valuado en 320 h × $10.000 = $3.200.000; precio propuesto $4.500.000 + $80.000/mes (ver `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`) | El plan de la semana 5 pide costos de desarrollo y precio de venta. El costo de licencias sigue siendo $0 |
| Competidores | AprendeBA, Colegium, Phidias, Alexia, papel/Excel | miEscuela, Google Workspace for Education/Classroom, Clickedu, Alexia, Esemtia, Cifra, e-Schooling, Tramix | Se releyeron fuentes con fecha; Colegium y Phidias no pudieron leerse de nuevo |
| Línea base de tiempos | Se cronometraría una muestra real antes del Demo Day | No se midió; se presenta como hipótesis a medir | No hubo mediciones en la preceptoría |

Lo que se mantiene: IQUAL complementa a los sistemas académicos y no los reemplaza; sus reglas propias son el bloqueo de reservas superpuestas, el cruce de horarios en Educación Física y la prueba de pertenencia para objetos perdidos.
