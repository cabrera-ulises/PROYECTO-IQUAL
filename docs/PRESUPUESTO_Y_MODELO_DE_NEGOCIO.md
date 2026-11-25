# Presupuesto y modelo de negocio — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Plan de Aprendizaje:** 4° bimestre, semana 5 (presupuesto: horas hombre, licencias, infraestructura, mantenimiento; monetización)

> Las horas, el valor de la hora ($10.000, valor de referencia de un desarrollador junior), la infraestructura y los precios son **estimaciones del equipo**, no mediciones ni datos de fuentes externas. Si el docente fija otro valor de hora, se reemplaza y los totales se recalculan con las mismas fórmulas.

---

## 1. Qué se presupuesta
Dos presupuestos distintos, que conviene no mezclar en la defensa:
1. **Costo de desarrollo (ya hecho):** lo que costó construir IQUAL (horas de trabajo, herramientas).
2. **Costo de tenerlo funcionando en una escuela (por año):** infraestructura, mantenimiento y soporte.

Y un modelo de negocio: cómo se cobraría (secciones 6 y 7). Es un ejercicio con estimaciones, no una venta real.

## 2. Horas hombre por rol
**Fórmula:** `Costo del rol = [H] horas × [V] valor de la hora`. **Costo total de desarrollo = suma de los costos de todos los roles.**

| Rol | Qué hizo en IQUAL | Integrante | Horas `[H]` | Valor hora `[V]` | Costo `= H × V` |
|---|---|---|---|---|---|
| Analista / relevamiento | Árbol de problemas, requerimientos, historias de usuario, matriz de trazabilidad | Thiago y Ulises | 30 | $10.000 | $300.000 |
| Diseñador de base de datos | Modelo de 47 tablas en 3FN, diagramas, scripts MySQL y SQL Server, procedimientos | Ulises | 60 | $10.000 | $600.000 |
| Programador C++/Qt | Aplicación de escritorio: 10 pantallas, conexión a la base, roles y permisos, auditoría | Ulises y Thiago | 120 | $10.000 | $1.200.000 |
| Diseñador de interfaz | Maquetado, temas claro y oscuro, íconos | Thiago y Ulises | 25 | $10.000 | $250.000 |
| QA / pruebas | 337 casos de prueba por pantalla, 104 casos de procedimientos almacenados (80 ejecutados), informe de errores y revisión de código | Thiago y Ulises | 35 | $10.000 | $350.000 |
| Documentación | Manuales de usuario y técnico, guías de MySQL, bitácora | Thiago y Ulises | 30 | $10.000 | $300.000 |
| Gestión del proyecto | Coordinación, entregas, presentación y pitch | Ulises | 20 | $10.000 | $200.000 |
| **Total** | | | **320** | | **$3.200.000** |

**Datos reales del proyecto** (referencia, no horas): `mainwindow.cpp` 3257 líneas, `mainwindow.ui` 2244 líneas, 47 tablas, 27 procedimientos almacenados, 337 casos de prueba por pantalla, 104 casos de procedimientos, 55 errores registrados (ver `MANUAL_TECNICO.md` e `INFORME_PRUEBAS.md`). La bitácora no registra horas.

**¿De dónde sale el valor de la hora `[V]`?** No lo pongo yo. Opciones para definirlo: el valor que fije el docente para el ejercicio, o una referencia salarial de un desarrollador junior con fuente y fecha. **Criterio del equipo:** $10.000 por hora, un valor de ejemplo de un desarrollador junior en pesos. Es una estimación nuestra, sin fuente salarial; si el docente fija otro valor, se reemplaza y se recalculan los totales.

**Costo de las horas de aprendizaje:** al ser un proyecto escolar, parte de las horas son de aprendizaje. Conviene decidir si se cuentan completas o con un factor de eficiencia: `Horas facturables = Horas reales × [F]`, con `[F]` entre 0 y 1. **Criterio del equipo:** se cuentan las horas completas (`F` = 1).

## 3. Licencias
**Fórmula:** `Costo de licencias = suma de (cantidad × precio × meses)` de lo que sea de pago. Lo que es libre cuesta cero.

| Componente | Licencia | Costo | Fuente |
|---|---|---|---|
| MySQL Community Edition (base de datos) | GPL; descarga gratuita | **0** por licencia | [1] |
| Qt (framework de la interfaz) | Community (LGPL/GPL, sin compra) o comercial (montos en qt.io/pricing, no verificados). Acceso educativo gratuito | **0** para uso educativo y open source; la licencia comercial no se presupuesta | [2] |
| Qt Creator, CMake, compilador MinGW | Qt Creator: GPL/comercial junto con Qt; CMake: BSD de 3 cláusulas; MinGW: GPL | **0** |
| DBeaver Community / MySQL Workbench | Apache 2.0 / GPL | **0** |
| Sistema operativo | Windows de las PC que la escuela ya tiene, o Linux (gratuito) | **0** adicional |
| MySQL Connector/ODBC (camino ODBC) | GPL | **0** |
| Claude Pro (asistente de IA para desarrollo y mantenimiento del código) | Suscripción mensual | Unos **$35.000 a $40.000 por mes** (≈ $450.000 por año); dato del equipo, sin fuente verificada | — |

**Dos advertencias de licencia que sí están en las fuentes y afectan al negocio:**
- **MySQL:** según una consultora de licencias, el uso interno de Community es gratis; **se paga** si se usan funciones exclusivas de Enterprise, si se **distribuye MySQL dentro de un producto** sin publicar bajo licencia compatible con GPL, o si se contrata soporte de Oracle. La lista de Oracle del 11/09/2025 para MySQL Standard es **2.140 USD por servidor por año** (1 a 4 sockets). No es asesoramiento legal [3]. Para IQUAL: que **la escuela instale su MySQL** (como hoy) y IQUAL no lo incluya en el instalador.
- **Qt:** con la licencia Community «tu software debe poder copiarse, modificarse y distribuirse»; no se puede mezclar con la licencia comercial en el mismo proyecto [2]. Si IQUAL se vendiera como producto cerrado, habría que comprar la licencia comercial de Qt (monto no incluido en este presupuesto).

## 4. Infraestructura
Lo que necesita una escuela para usar IQUAL (hoy funciona con un servidor MySQL en la red local y la aplicación en cada PC).

| Ítem | Para qué | Cantidad `[N]` | Precio unitario `[P]` | Costo `= N × P` |
|---|---|---|---|---|
| Servidor (o una PC dedicada) con MySQL | Guardar la base de datos de la escuela | 1 | $600.000 | $600.000 |
| PC de los usuarios con la aplicación instalada | Preceptoría, secretaría, preceptores, etc. | las que ya tiene la escuela | $0 | $0 |
| Red local | Que las PC lleguen al servidor | la que ya tiene la escuela | $0 | $0 |
| Resguardo (copias de seguridad de la base) | Que no se pierda la información | 1 disco externo | $120.000 | $120.000 |
| Energía / UPS | Que un corte no rompa la base | 1 | $150.000 | $150.000 |
| **Total infraestructura (inicial)** | | | | **$870.000** |

Notas verificadas en el proyecto: la app necesita un servidor MySQL (la edición Community no tiene costo de licencia) y no tiene base de respaldo, así que **el costo mínimo de infraestructura es cero si el servidor se instala en una PC que la escuela ya tiene** (con la limitación de que, si esa PC está apagada, la app no abre). Qué nivel de servidor hace falta para el tamaño de la escuela **no se midió** (RNF03): Cuántos usuarios simultáneos soporta no se midió; es una de las próximas pruebas..

## 5. Mantenimiento
**Fórmula:** `Costo anual de mantenimiento = (horas por mes × 12 × valor hora) + costos fijos anuales`. Una referencia habitual es expresarlo como porcentaje del costo de desarrollo: `% anual = mantenimiento anual ÷ costo de desarrollo`. Con estos números: $720.000 ÷ $3.200.000 = **22,5 % anual**.

| Tarea | Frecuencia | Horas por vez `[H]` | Veces por año `[Q]` | Costo `= H × Q × V` |
|---|---|---|---|---|
| Corregir errores (hay 26 abiertos, casi todos de gravedad baja; ver `INFORME_PRUEBAS.md`) | Según aparezcan | 2 | 6 | $120.000 |
| Cambios por nuevos pedidos del colegio (ejemplo: notas o asistencia) | Anual | 20 | 1 | $200.000 |
| Actualizar Qt / MySQL / drivers | Cuando salga una versión importante | 8 | 1 | $80.000 |
| Copias de seguridad y control de la base | Mensual | 1 | 12 | $120.000 |
| Alta de usuarios, restablecer contraseñas y soporte al personal | Continuo | 1 | 12 | $120.000 |
| Capacitación del personal nuevo | Por ingreso | 4 | 2 | $80.000 |
| **Total mantenimiento anual** | | | | **$720.000** (72 horas = 6 por mes) |

Hechos reales que impactan: MySQL 8.0 dejó de recibir actualizaciones normales el 21/04/2026 (solo «Sustaining Support», según [3]); si el servidor de una escuela usa 8.0, habrá que planificar la actualización. Hoy la app **no tiene recuperación de contraseña** (decisión por defecto U04; hay que definir con la escuela quién lo hace), por lo que esa tarea cae en soporte.

## 6. Modelos de monetización posibles
Los cuatro modelos que pide el plan, aplicados a IQUAL **tal como es hoy** (aplicación de escritorio con base propia en la escuela):

| Modelo | Cómo funcionaría | Ingreso | Lo bueno | Lo difícil o a resolver |
|---|---|---|---|---|
| **Venta de licencia** (pago único o anual por escuela) | La escuela paga por usar IQUAL | `Ingreso = [Pl] precio de licencia × [E] escuelas` | Simple de explicar; ingreso previsible | Revisar la licencia de Qt (sección 3). Como el proyecto es escolar, Por ser un trabajo escolar, la venta real requeriría el acuerdo del docente y de la escuela. |
| **SaaS** (suscripción mensual) | IQUAL alojado por nosotros y accedido por internet | `Ingreso = [S] cuota mensual × [E] escuelas × 12` | Ingreso recurrente | **IQUAL hoy es una aplicación de escritorio conectada a la base de la escuela; no es web.** Para SaaS habría que alojar la base y exponerla de forma segura, o rehacer la app para web: es un trabajo grande no presupuestado. Además, el hosting es un costo nuevo no presupuestado |
| **Llave en mano** (proyecto cerrado por escuela) | Se instala, se configura y se capacita; la escuela recibe el sistema funcionando | `Ingreso = [Ll] precio del proyecto × [E]` | Encaja con lo que ya existe: scripts, guías y manuales | Cada escuela puede pedir adaptaciones (carros, sectores, deportes distintos): cada una agrega horas |
| **Soporte y mantenimiento** | La escuela usa IQUAL y paga por ayuda y cambios | `Ingreso anual = [M] cuota mensual de soporte × 12 × [E]` | Se apoya en la sección 5 y mantiene el sistema vivo | Hay que definir qué incluye (tiempo de respuesta, cantidad de horas) |

**Combinación posible:** llave en mano (instalación y capacitación) + soporte mensual. Es la que mejor se corresponde con el estado actual del producto; el SaaS queda como una etapa futura.

**Qué precio fijar:** propuesta del equipo: llave en mano $4.500.000 + soporte $80.000 por mes (el soporte anual, $960.000, contra un mantenimiento estimado de $720.000; si además se suma la herramienta de IA, unos $450.000 por año, el soporte no alcanza a cubrir ambos y habría que ajustar el precio). Criterios para decidirlo: Criterios: (1) cubrir el costo de las secciones 2 y 5, (2) quedar por debajo de lo que la escuela pagaría por una plataforma comercial. Como referencia, `ANALISIS_COMPETENCIA.md` **no pudo sostener ningún precio comercial con fecha** (las fuentes dan «bajo cotización» o «consultar precios», o no tienen fecha de publicación); lo que sí figura es que Google Workspace for Education Fundamentals se ofrece sin cargo a instituciones elegibles (vigencia a confirmar). El precio es una propuesta del equipo; no se pudieron sostener precios comerciales con fecha.

## 7. Retorno de la inversión
Hay dos retornos, y el segundo suele ser el más fuerte en una escuela.

### 7.1 Margen estimado (si se vendiera), con las cifras del equipo
| Concepto | Cálculo | Valor |
|---|---|---|
| Inversión inicial (desarrollo) | 320 h × $10.000 | $3.200.000 |
| Ingreso del año 1 con 1 escuela (hipotética) | $4.500.000 + 12 × $80.000 | $5.460.000 |
| Costo de mantenimiento anual | 72 h × $10.000 | $720.000 |
| Margen del año 1 | $5.460.000 − $3.200.000 − $720.000 | $1.540.000 |
| Margen anual desde el año 2 (por escuela) | $960.000 de soporte − $720.000 de mantenimiento | $240.000 |

La infraestructura ($870.000) se considera a cargo de la escuela. Estas cifras son un modelo con estimaciones del equipo: dependen de que una escuela pague ese precio, que es una hipótesis y no un resultado. Ninguna escuela aceptó comprarlo.

### 7.2 Retorno para la escuela (si se usa dentro del colegio)
No es dinero, sino tiempo y orden. Qué medir (hoy **no hay mediciones**): 

| Indicador | Cómo se mediría | Valor |
|---|---|---|
| Tiempo para devolver un objeto perdido a su dueño | Antes / después de usar el módulo | Sin medir |
| Tiempo para saber qué equipos están prestados | Antes (planilla en papel) / después | Sin medir |
| Reservas de sectores superpuestas o perdidas | Cantidad por mes antes / después | Sin medir |
| Reportes de higiene resueltos y tiempo de resolución | Cantidad y demora promedio | Sin medir |
| Horas del personal ahorradas por mes | `= (minutos ahorrados por tarea × tareas por mes) ÷ 60` | Sin medir |
| Valor de esas horas | `= horas ahorradas × valor hora del personal` | Sin medir |

Nada de esto fue medido porque la app todavía no se probó en uso real (`INFORME_PRUEBAS.md`). En la defensa conviene presentarlo como **hipótesis a medir**, no como resultado.

## 8. Fórmulas para una planilla
Cuando el equipo cargue los datos, en una hoja de cálculo alcanza con: una columna de horas `[H]`, una de valor `[V]` y una de costo con la fórmula `=H*V` por fila; el total con `=SUMA(...)`. 

## 9. Resumen para la defensa
**Valores estimados por el equipo para el ejercicio (en pesos); se ajustan con el valor de hora que fije el docente y con datos reales de la escuela.**

| Concepto | Valor |
|---|---|
| Costo de desarrollo (horas hombre) | 320 horas × $10.000 = $3.200.000 |
| Licencias | **0** con MySQL Community y Qt Community en uso educativo |
| Herramienta de IA | Claude Pro: unos $35.000 a $40.000 por mes (≈ $450.000 por año), dato del equipo |
| Infraestructura inicial | $870.000 (servidor $600.000, UPS $150.000, disco de copias $120.000) |
| Mantenimiento anual | 6 horas por mes × 12 × $10.000 = $720.000 |
| Modelo de ingreso elegido | Llave en mano + soporte mensual |
| Precio por escuela | $4.500.000 de instalación + $80.000 por mes de soporte |
| Retorno | Hipótesis a medir; no se calcula un ROI porque no hay un cliente real ni mediciones |

## Fuentes (consultadas el 12/11/2026)
1. [MySQL Community Edition — mysql.com](https://www.mysql.com/de/products/community/) (consultada 12/11/2026; la página no informa fecha)
2. [Qt licensing — qt.io](https://www.qt.io/development/qt-framework/qt-licensing) (consultada 12/11/2026; pie «© 2026»)
3. [MySQL Community (GPL) vs Enterprise: cuándo hay que pagar — Redress Compliance](https://redresscompliance.com/mysql-community-gpl-vs-enterprise-when-you-must-pay) (17/08/2026, actualizado 25/09/2026; consultora, no es una fuente oficial de Oracle)
4. Precios de plataformas escolares y Google Workspace for Education: ver las fuentes de `ANALISIS_COMPETENCIA.md`.
