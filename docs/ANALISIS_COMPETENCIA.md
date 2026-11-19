# Análisis de la competencia — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Plan de Aprendizaje:** 4° bimestre, semana 4 (matriz comparativa de funcionalidades y costos, y propuesta única de valor)
**Fecha de la consulta:** 12/11/2026. **Revisión de fuentes (ronda final, 13/11/2026):** cada dato de costo tiene fuente y fecha; los que salen de una página **sin fecha de publicación** pasaron a `[COMPLETAR]` (ver sección 4). Todos los datos de otros productos salen de páginas web leídas ese día; cada dato lleva su fuente (numerada en la sección 7) y la fecha que la página informa. **Cuando la página no trae fecha lo digo.** Lo que no pude confirmar queda como `[COMPLETAR]`.

> **Cómo leer este documento:** «No figura en la fuente» significa que **la página que leí no lo menciona**, no que el producto no lo tenga. Para afirmar que alguien «no lo ofrece» habría que mirar el producto o pedir una demo (ver «Datos que faltan»).

---

## 1. Qué es IQUAL hoy (lo que se compara)
IQUAL es una aplicación de escritorio (C++17 con Qt) para una escuela técnica, con base de datos MySQL (respaldo SQLite) y cuatro roles: Alumno, Profesor, Preceptor y Maestranza. Hoy resuelve estos módulos:

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

`[COMPLETAR: otras alternativas que use realmente E.T. N°3 o el D.E.9 (por ejemplo, el sistema que usa la escuela para notas y legajos). No pude averiguarlo con fuentes públicas y no lo invento.]`

**Límite de esta búsqueda:** casi todos los productos comerciales que figuran en las fuentes son de España o de plataformas de comparación; **no pude confirmar que se vendan o se usen en Argentina** (salvo miEscuela y Tramix, que sí son argentinos). No uso ningún precio en euros ni en pesos: los pocos montos que había eran de páginas sin fecha y quedaron en `[COMPLETAR]` (sección 4).

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
| Funciona sin conexión a internet (red de la escuela) | **✔** (MySQL local o SQLite) | — | — | — | — | — | — | Nube / SaaS / web (la fuente lo lista como plataforma) | — |

Notas de la matriz:
- Esemtia y Cifra son las únicas que mencionan tienda, extraescolares o comedor; son pagos y servicios **del colegio hacia las familias**, no entre alumnos.
- En e-Schooling aparece «gestión de bibliotecas»; es préstamo de libros, no de equipos, y no lo cuento como equivalente.
- Las celdas «—» no prueban que el producto no lo ofrezca: las fuentes son resúmenes de directorios o notas de prensa.

## 4. Matriz comparativa de costos
| Alternativa | Dato de costo publicado | Fuente y fecha |
|---|---|---|
| IQUAL | Sin precio definido todavía. Los costos de armar y sostener el proyecto están en `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md`. `[COMPLETAR: precio]` | Este proyecto |
| miEscuela | La página **no indica** si tiene costo | [1] (consultada 12/11/2026; fecha de publicación `[COMPLETAR]`) |
| Google Workspace for Education Fundamentals (incluye Classroom) | `[COMPLETAR: confirmar vigencia]`. La página lo describía como «disponible sin cargo para las instituciones que cumplan los requisitos» | [2] (consultada 12/11/2026; la página no informa fecha) |
| Google Workspace for Education Plus | `[COMPLETAR: precio]` (la página dice «Consultar precios»: suscripción anual, sin monto) | [2] (ídem) |
| Clickedu | `[COMPLETAR: modelo y precio]` (la página muestra tres modelos posibles —pago único, sin licencia, mensual— sin decir cuál aplica) | [3] (consultada 12/11/2026; sin fecha) |
| Alexia (Educaria) | `[COMPLETAR: precio vigente]`. El directorio leído da una referencia «orientativa» en euros, pero **sin fecha de publicación**, por eso no la uso como dato | [4b] (consultada 12/11/2026; sin fecha) |
| Esemtia, Cifra Educación | No publican monto en las fuentes consultadas | [4a] (12/01/2014, actualizado 03/07/2026) |
| e-Schooling | «Bajo cotización» (precio personalizado) | [6] (consultada 12/11/2026; solo informa el año 2026) `[COMPLETAR: fecha]` |
| Tramix | La nota **no indica** precios | [7] 29/11/2012 (nota antigua) |
| Otros directorios (Atenea, Schooltivity, Playoff, Dinantia, Brainbond) | `[COMPLETAR: precios vigentes]`. El directorio [4b] los da como «orientativos», sin fecha de publicación | [4b] (sin fecha) |

Lo que se ve en las fuentes: las plataformas comerciales de gestión escolar **se ofrecen por suscripción o por cotización** (e-Schooling: «bajo cotización»; Google Workspace Plus: «consultar precios»); **no pude sostener ningún monto con fecha**, por eso las celdas quedan en `[COMPLETAR]`. Lo estatal y lo de Google es gratis, pero **no resuelve** objetos perdidos, préstamos ni reservas de sectores (según las fuentes). Conversión a pesos: `[COMPLETAR: cotización del euro en la fecha en que se presente; no la puse para no inventarla]`.

## 5. Costos de lo que usa IQUAL (para compararlo contra estos precios)
| Componente | Dato verificado | Fuente |
|---|---|---|
| MySQL Community Edition | Se distribuye bajo licencia GPL y se descarga gratis | [9] (consultada 12/11/2026; fecha de la fuente `[COMPLETAR]`) |
| MySQL: cuándo se paga | Según un artículo de asesoría de licencias (publicado 17/08/2026, actualizado 25/09/2026): el uso interno en producción de la edición Community no requiere pagar; se paga si se usan funciones exclusivas de Enterprise, si se **distribuye MySQL dentro de un producto** sin publicar bajo licencia compatible con GPL, o si se contrata soporte de Oracle. Lista de Oracle del 11/09/2025: Standard 2.140 USD por servidor por año (1 a 4 sockets). No es asesoramiento legal | [10] |
| Qt | Doble licencia: Community (LGPL o GPL, sin compra, pero «tu software debe poder copiarse, modificarse y distribuirse») o comercial (precio en qt.io/pricing, no pude leer los montos). Acceso gratuito educativo con fines de aprendizaje | [11] (consultada 12/11/2026; fecha de la fuente `[COMPLETAR]`) |

Consecuencia para IQUAL: usar Qt Community y MySQL Community no tiene costo de licencia para un proyecto escolar, pero **si IQUAL se vendiera como producto cerrado habría que revisar la licencia de Qt** (o comprar la comercial) y **no instalar MySQL dentro del paquete de IQUAL** (que lo instale la escuela, como hoy). `[COMPLETAR: consultar con el profesor y, si el proyecto se comercializara, con alguien que entienda de licencias]`.

## 6. Propuesta única de valor (PUV)
**Qué nos diferencia:** las plataformas que encontré se concentran en lo **académico y administrativo** (matrícula, notas, asistencia, cobros, comunicación). IQUAL resuelve la **vida cotidiana de una escuela técnica**: lo que pasa entre el timbre y el timbre y casi nunca está en un sistema.

**Frase para el pitch (borrador):**
> «Las plataformas de gestión escolar saben quién es cada alumno y qué nota tiene. IQUAL sabe dónde quedó la campera, qué computadora del carro está prestada, quién reservó la biblioteca y cuánto falta para el viaje de egresados.»

**Cinco puntos que sostienen la PUV:**
1. **Cubre cosas que las fuentes no listan:** objetos perdidos, préstamo de equipos, reserva de sectores, reportes de higiene e inscripción a Educación Física con control de choque de horarios (matriz, sección 3).
2. **Hecho a la medida de esta escuela:** los carros C4 y C5, los tableros y las especialidades son los reales de E.T. N°3 (CONTEXTO §8).
3. **Funciona en la red de la escuela:** con MySQL local, sin depender de un servicio en la nube; con respaldo SQLite si el servidor falla.
4. **Trazabilidad:** toda acción importante queda en la auditoría.
5. **Sin costo de licencia de base y framework** (secciones 5 y 7) para el alcance escolar; el costo real es el de horas de desarrollo y soporte (ver presupuesto).

**Lo que NO podemos decir (y conviene reconocer en la defensa):**
- IQUAL **no reemplaza** a un sistema de notas y asistencia; **lo complementa**. Si la escuela ya usa uno, IQUAL no compite con eso.
- Es una aplicación de escritorio: no hay versión web ni app para celular; las familias no acceden.
- No fue probado en Windows ni con muchos usuarios a la vez (`MANUAL_TECNICO.md`, sección 7).
- La competencia con presupuesto y años de desarrollo (Clickedu, Alexia) tiene soporte, apps y miles de centros; nosotros tenemos un prototipo funcional.

## 7. Fuentes
Todas se consultaron el **12/11/2026**. La columna «Fecha de la fuente» es la que informa la página; si no la informa, queda `[COMPLETAR]`.

| N° | Fuente | Fecha de la fuente | Qué se tomó |
|---|---|---|---|
| 1 | [Conocé miEscuela — Ministerio de Educación de la Ciudad de Buenos Aires](https://buenosaires.gob.ar/gcaba_historico/educacion/conoce-miescuela) | `[COMPLETAR: la página no la informa]` | Funciones de miEscuela; no informa costo |
| 2 | [Google Workspace for Education — ediciones](https://edu.google.com.co/products/workspace-for-education/editions) | `[COMPLETAR: la página no la informa]` | Fundamentals sin cargo para instituciones elegibles; Plus «Consultar precios»; Classroom incluido en todas las ediciones |
| 3 | [Clickedu — SoftwareDoit](https://www.softwaredoit.es/clickedu/clickedu.html) | `[COMPLETAR: la página no la informa]` | Funciones de Clickedu; modelos de precio posibles |
| 4a | [Plataformas de gestión escolar — Educación 3.0](https://www.educaciontrespuntocero.com/noticias/plataformas-gestion-escolar/12663.html) | Publicado 12/01/2014; actualizado 03/07/2026 | Funciones de Alexia, Cifra Educación, Clickedu, Educamos, Esemtia y Globaleduca; no da precios |
| 4b | [Los mejores software educativos de 2026 — SoftwareDoit](https://www.softwaredoit.es/erp-educativo/erp-educativo.html) | `[COMPLETAR: la página no la informa; el título dice «2026»]` | Funciones de Alexia, Atenea, Playoff, Schooltivity, Dinantia, Brainbond; precios «orientativos» (**no usados**) |
| 6 | [e-Schooling — ComparaSoftware](https://www.comparasoftware.com/e-schooling) | `[COMPLETAR: solo informa el año 2026]` | Funciones; precio «bajo cotización» |
| 7 | [Unitech presenta Tramix Gestión Educativa — Mercado](https://mercado.com.ar/varios/unitech-presenta-tramix-gestion-educativa) | 29/11/2012 (**nota antigua**: el producto pudo cambiar) | Funciones de Tramix |
| 9 | [MySQL Community Edition — mysql.com](https://www.mysql.com/de/products/community/) | `[COMPLETAR: la página no la informa]` | Licencia GPL y descarga gratuita |
| 10 | [MySQL Community (GPL) vs Enterprise: cuándo hay que pagar — Redress Compliance](https://redresscompliance.com/mysql-community-gpl-vs-enterprise-when-you-must-pay) | Publicado 17/08/2026; actualizado 25/09/2026 (consultora, no es fuente oficial de Oracle) | Cuándo se paga MySQL; lista de Oracle del 11/09/2025 |
| 11 | [Qt licensing — qt.io](https://www.qt.io/development/qt-framework/qt-licensing) | `[COMPLETAR: la página no la informa; pie «© 2026»]` | Licencias de Qt |

(Los números 5 y 8 de la versión anterior eran referencias a [4a] y [4b]: Alexia está en 4a y 4b; Esemtia y Cifra, en 4a.)

## Desvíos
- **Ronda final (13/11/2026):** revisé fuente y fecha de cada dato externo. Ningún monto de las fuentes sin fecha de publicación quedó como dato (Alexia, Atenea, Schooltivity, Playoff, Dinantia); la fecha de consulta (12/11/2026) la tienen todos. Las funciones que salen de páginas sin fecha se mantienen, con la fecha de la fuente marcada `[COMPLETAR]` en la sección 7. Saqué una referencia a una nota de Interempresas (700 colegios) que solo había visto como título en la búsqueda y nunca leí.
- No pude abrir las páginas oficiales de Colegium ni de WebColegios (la primera no está permitida en mi herramienta de lectura y la segunda solo mostró una pantalla de verificación), por lo que **no están en la matriz**. Aparecieron en la búsqueda pero no tengo un dato leído de ellas.
- Casi todos los precios salen de directorios españoles y son «orientativos»; ninguno es un precio oficial en pesos. No los convertí.
- Dos fuentes tienen más años (Tramix 2012) o no traen fecha; lo aclaré en cada caso.
- No encontré una fuente que diga qué sistema usa hoy E.T. N°3.
- El plan dice «C/Qt»; el proyecto es C++17 con Qt, lo describí así.

## Datos que faltan
- `[COMPLETAR: sistema que usa hoy la escuela para notas y asistencia, si lo hay]` — lo informa el usuario o Linares.
- `[COMPLETAR: confirmar con demo o con el proveedor las celdas «—» de las matrices (Clickedu, Alexia, Esemtia, e-Schooling)]`
- `[COMPLETAR: precio de IQUAL]` — sale de `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md` cuando el usuario cargue las horas.
- `[COMPLETAR: precios vigentes con fecha de Alexia, Clickedu, Google Workspace Plus y e-Schooling (pedir cotización o leer la página oficial del proveedor)]` — usuario.
- `[COMPLETAR: precios comerciales de Qt (qt.io/pricing)]` — usuario, si se quiere el costo de una licencia comercial.
- `[COMPLETAR: disponibilidad en Argentina de los productos españoles]`
