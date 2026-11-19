# Presupuesto y modelo de negocio — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I
**Autores:** Arce Thiago · Cabrera Ulises
**Plan de Aprendizaje:** 4° bimestre, semana 5 (presupuesto: horas hombre, licencias, infraestructura, mantenimiento; monetización: licencias, SaaS, llave en mano, soporte)

> **Cómo usar este documento.** No hay ninguna cifra inventada: **todo número que no sale de un archivo del proyecto o de una fuente citada es un `[COMPLETAR]`**. Las tablas están armadas con **fórmulas explicadas** para que, cuando el equipo cargue las horas y los valores, el total se calcule solo (en la sección 8 hay un ejemplo de cómo pasarlo a una planilla). Las letras entre corchetes (por ejemplo `[H]`) son las celdas que hay que completar.

---

## 1. Qué se presupuesta
Dos presupuestos distintos, que conviene no mezclar en la defensa:
1. **Costo de desarrollo (ya hecho):** lo que costó construir IQUAL (horas de trabajo, herramientas).
2. **Costo de tenerlo funcionando en una escuela (por año):** infraestructura, mantenimiento y soporte.

Y un modelo de negocio: cómo se cobraría y cuándo se recupera lo invertido (secciones 6 y 7).

## 2. Horas hombre por rol
**Fórmula:** `Costo del rol = [H] horas × [V] valor de la hora`. **Costo total de desarrollo = suma de los costos de todos los roles.**

| Rol | Qué hizo en IQUAL | Integrante | Horas `[H]` | Valor hora `[V]` | Costo `= H × V` |
|---|---|---|---|---|---|
| Analista / relevamiento | Árbol de problemas, requerimientos, historias de usuario, matriz de trazabilidad | `[COMPLETAR: quién]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| Diseñador de base de datos | Modelo de 47 tablas en 3FN, diagramas, scripts MySQL, SQLite y SQL Server, procedimientos | `[COMPLETAR]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| Programador C++/Qt | Aplicación de escritorio: 10 pantallas, conexión a la base, roles y permisos, auditoría | `[COMPLETAR]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| Diseñador de interfaz | Maquetado, temas claro y oscuro, íconos, splash | `[COMPLETAR]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| QA / pruebas | 337 casos de prueba escritos, informe de errores, revisión de código | `[COMPLETAR]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| Documentación | Manuales de usuario y técnico, guías de MySQL, bitácora | `[COMPLETAR]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| Gestión del proyecto | Coordinación, entregas, presentación y pitch | `[COMPLETAR]` | `[COMPLETAR]` | `[COMPLETAR]` | `= H × V` |
| **Total** | | | **`= suma de H`** | | **`= suma de costos`** |

**Qué se puede usar para estimar las horas** (datos reales del proyecto, no horas): `mainwindow.cpp` 3269 líneas, `mainwindow.ui` 2244 líneas, 186 funciones de `MainWindow`, 95 slots de eventos (app v3), 47 tablas, 5 procedimientos, 337 casos de prueba, 49 errores registrados (ver `MANUAL_TECNICO.md` e `INFORME_PRUEBAS.md`). La bitácora del equipo (`bitacora.md`) es la fuente natural de las horas reales: `[COMPLETAR: sumar las horas de la bitácora por rol]`.

**¿De dónde sale el valor de la hora `[V]`?** No lo pongo yo. Opciones para definirlo: el valor que fije el docente para el ejercicio, o una referencia salarial de un desarrollador junior con fuente y fecha. `[COMPLETAR: criterio y fuente del valor hora]`

**Costo de las horas de aprendizaje:** al ser un proyecto escolar, parte de las horas son de aprendizaje. Conviene decidir si se cuentan completas o con un factor de eficiencia: `Horas facturables = Horas reales × [F]`, con `[F]` entre 0 y 1. `[COMPLETAR: criterio]`

## 3. Licencias
**Fórmula:** `Costo de licencias = suma de (cantidad × precio × meses)` de lo que sea de pago. Lo que es libre cuesta cero.

| Componente | Licencia | Costo | Fuente |
|---|---|---|---|
| MySQL Community Edition (base de datos) | GPL; descarga gratuita | **0** por licencia | [1] |
| Qt (framework de la interfaz) | Community (LGPL/GPL, sin compra) o comercial (precio en qt.io/pricing, no leí los montos). Acceso educativo gratuito con fines de aprendizaje | **0** para el uso educativo y open source; comercial: `[COMPLETAR: precio en qt.io/pricing]` | [2] |
| Qt Creator, CMake, compilador MinGW | `[COMPLETAR: confirmar licencia de cada herramienta]` | `[COMPLETAR]` | — |
| DBeaver o MySQL Workbench (para cargar los scripts) | `[COMPLETAR: confirmar licencia de la edición usada]` | `[COMPLETAR]` | — |
| Sistema operativo de la PC de desarrollo y del servidor | `[COMPLETAR: Windows / Linux, y si tiene costo]` | `[COMPLETAR]` | — |
| Driver ODBC de MySQL (si se usa el camino ODBC) | `[COMPLETAR: confirmar licencia de MySQL Connector/ODBC]` | `[COMPLETAR]` | — |

**Dos advertencias de licencia que sí están en las fuentes y afectan al negocio:**
- **MySQL:** según una consultora de licencias, el uso interno de Community es gratis; **se paga** si se usan funciones exclusivas de Enterprise, si se **distribuye MySQL dentro de un producto** sin publicar bajo licencia compatible con GPL, o si se contrata soporte de Oracle. La lista de Oracle del 11/09/2025 para MySQL Standard es **2.140 USD por servidor por año** (1 a 4 sockets). No es asesoramiento legal [3]. Para IQUAL: que **la escuela instale su MySQL** (como hoy) y IQUAL no lo incluya en el instalador.
- **Qt:** con la licencia Community «tu software debe poder copiarse, modificarse y distribuirse»; no se puede mezclar con la licencia comercial en el mismo proyecto [2]. Si IQUAL se vendiera como producto cerrado, hay que comprar la licencia comercial de Qt. `[COMPLETAR: costo de la licencia comercial]`

## 4. Infraestructura
Lo que necesita una escuela para usar IQUAL (hoy funciona con un servidor MySQL en la red local y la aplicación en cada PC).

| Ítem | Para qué | Cantidad `[N]` | Precio unitario `[P]` | Costo `= N × P` |
|---|---|---|---|---|
| Servidor (o una PC dedicada) con MySQL | Guardar la base de datos de la escuela | `[COMPLETAR]` | `[COMPLETAR]` | `= N × P` |
| PC de los usuarios con la aplicación instalada | Preceptoría, secretaría, preceptores, etc. | `[COMPLETAR]` (se puede usar lo que ya tiene la escuela: costo adicional posible cero) | `[COMPLETAR]` | `= N × P` |
| Red local | Que las PC lleguen al servidor | `[COMPLETAR]` | `[COMPLETAR]` | `= N × P` |
| Resguardo (copias de seguridad de la base) | Que no se pierda la información | `[COMPLETAR]` | `[COMPLETAR]` | `= N × P` |
| Energía / UPS | Que un corte no rompa la base | `[COMPLETAR]` | `[COMPLETAR]` | `= N × P` |
| **Total infraestructura (inicial)** | | | | **`= suma`** |

Notas verificadas en el proyecto: la app funciona en una sola PC con SQLite si no hay servidor (`motor=sqlite`), así que **el costo mínimo de infraestructura es cero si se usa lo que la escuela ya tiene** (con la limitación de que cada PC tendría sus propios datos). Qué nivel de servidor hace falta para el tamaño de la escuela **no se midió** (RNF03): `[COMPLETAR: cantidad de usuarios simultáneos y de alumnos de E.T. N°3]`.

## 5. Mantenimiento
**Fórmula:** `Costo anual de mantenimiento = (horas por mes × 12 × valor hora) + costos fijos anuales`. Una referencia habitual es expresarlo como porcentaje del costo de desarrollo: `% anual = mantenimiento anual ÷ costo de desarrollo`. `[COMPLETAR: el porcentaje no lo invento]`

| Tarea | Frecuencia | Horas por vez `[H]` | Veces por año `[Q]` | Costo `= H × Q × V` |
|---|---|---|---|---|
| Corregir errores (hay 24 abiertos, casi todos de gravedad baja; ver `INFORME_PRUEBAS.md`) | Según aparezcan | `[COMPLETAR]` | `[COMPLETAR]` | `= H × Q × V` |
| Cambios por nuevos pedidos del colegio (ejemplo: notas o asistencia) | Anual | `[COMPLETAR]` | `[COMPLETAR]` | `= H × Q × V` |
| Actualizar Qt / MySQL / drivers | Cuando salga una versión importante | `[COMPLETAR]` | `[COMPLETAR]` | `= H × Q × V` |
| Copias de seguridad y control de la base | Mensual | `[COMPLETAR]` | `[COMPLETAR]` | `= H × Q × V` |
| Alta de usuarios, restablecer contraseñas y soporte al personal | Continuo | `[COMPLETAR]` | `[COMPLETAR]` | `= H × Q × V` |
| Capacitación del personal nuevo | Por ingreso | `[COMPLETAR]` | `[COMPLETAR]` | `= H × Q × V` |
| **Total mantenimiento anual** | | | | **`= suma`** |

Hechos reales que impactan: MySQL 8.0 dejó de recibir actualizaciones normales el 21/04/2026 (solo «Sustaining Support», según [3]); si el servidor de una escuela usa 8.0, habrá que planificar la actualización. Hoy la app **no tiene recuperación de contraseña** (decisión por defecto U04; `[COMPLETAR: quién restablece la contraseña en el colegio]`), por lo que esa tarea cae en soporte.

## 6. Modelos de monetización posibles
Los cuatro modelos que pide el plan, aplicados a IQUAL **tal como es hoy** (aplicación de escritorio con base propia en la escuela):

| Modelo | Cómo funcionaría | Ingreso | Lo bueno | Lo difícil o a resolver |
|---|---|---|---|---|
| **Venta de licencia** (pago único o anual por escuela) | La escuela paga por usar IQUAL | `Ingreso = [Pl] precio de licencia × [E] escuelas` | Simple de explicar; ingreso previsible | Revisar la licencia de Qt (sección 3). Como el proyecto es escolar, `[COMPLETAR: ¿se puede vender?, consultar al docente y a la escuela]` |
| **SaaS** (suscripción mensual) | IQUAL alojado por nosotros y accedido por internet | `Ingreso = [S] cuota mensual × [E] escuelas × 12` | Ingreso recurrente | **IQUAL hoy es una aplicación de escritorio conectada a la base de la escuela; no es web.** Para SaaS habría que alojar la base y exponerla de forma segura, o rehacer la app para web: es un trabajo grande no presupuestado. Además, el hosting es un costo nuevo `[COMPLETAR]` |
| **Llave en mano** (proyecto cerrado por escuela) | Se instala, se configura y se capacita; la escuela recibe el sistema funcionando | `Ingreso = [Ll] precio del proyecto × [E]` | Encaja con lo que ya existe: scripts, guías y manuales | Cada escuela puede pedir adaptaciones (carros, sectores, deportes distintos): cada una agrega horas |
| **Soporte y mantenimiento** | La escuela usa IQUAL y paga por ayuda y cambios | `Ingreso anual = [M] cuota mensual de soporte × 12 × [E]` | Se apoya en la sección 5 y mantiene el sistema vivo | Hay que definir qué incluye (tiempo de respuesta, cantidad de horas) |

**Combinación posible:** llave en mano (instalación y capacitación) + soporte mensual. Es la que mejor se corresponde con el estado actual del producto; el SaaS queda como una etapa futura.

**Qué precio fijar:** no lo invento. Criterios: (1) cubrir el costo de las secciones 2 y 5, (2) quedar por debajo de lo que la escuela pagaría por una plataforma comercial. Como referencia, `ANALISIS_COMPETENCIA.md` **no pudo sostener ningún precio comercial con fecha** (las fuentes dan «bajo cotización» o «consultar precios», o no tienen fecha de publicación); lo que sí figura es que Google Workspace for Education Fundamentals se ofrece sin cargo a instituciones elegibles (vigencia a confirmar). `[COMPLETAR: precio de IQUAL, y precios comerciales vigentes con fecha pedidos a los proveedores]`

## 7. Retorno de la inversión
Hay dos retornos, y el segundo suele ser el más fuerte en una escuela.

### 7.1 Retorno económico (si se vende)
- **Inversión inicial** `[I]` = costo de desarrollo (sección 2) + costos de licencias (sección 3) + infraestructura propia.
- **Margen anual** `[Mg]` = ingresos anuales (sección 6) − costos anuales (mantenimiento y soporte, sección 5, más hosting si hay SaaS).
- **Punto de equilibrio (años)** `= [I] ÷ [Mg]`. Solo tiene sentido si `[Mg]` es mayor que cero.
- **ROI a N años** `= (Mg × N − I) ÷ I`.
- Cantidad de escuelas necesarias para cubrir la inversión en un año `= I ÷ (ingreso por escuela − costo por escuela)`.

### 7.2 Retorno para la escuela (si se usa dentro del colegio)
No es dinero, sino tiempo y orden. Qué medir (hoy **no hay mediciones**): 

| Indicador | Cómo se mediría | Valor |
|---|---|---|
| Tiempo para devolver un objeto perdido a su dueño | Antes / después de usar el módulo | `[COMPLETAR]` |
| Tiempo para saber qué equipos están prestados | Antes (planilla en papel) / después | `[COMPLETAR]` |
| Reservas de sectores superpuestas o perdidas | Cantidad por mes antes / después | `[COMPLETAR]` |
| Reportes de higiene resueltos y tiempo de resolución | Cantidad y demora promedio | `[COMPLETAR]` |
| Horas del personal ahorradas por mes | `= (minutos ahorrados por tarea × tareas por mes) ÷ 60` | `[COMPLETAR]` |
| Valor de esas horas | `= horas ahorradas × valor hora del personal` | `[COMPLETAR]` |

Nada de esto fue medido porque la app todavía no se probó en uso real (`INFORME_PRUEBAS.md`). En la defensa conviene presentarlo como **hipótesis a medir**, no como resultado.

## 8. Cómo pasarlo a una planilla
Cuando el equipo cargue los datos, en una hoja de cálculo alcanza con: una columna de horas `[H]`, una de valor `[V]` y una de costo con la fórmula `=H*V` por fila; el total con `=SUMA(...)`. Punto de equilibrio: `=I/Mg`. ROI: `=(Mg*N-I)/I`. (Si el equipo quiere, se puede armar como planilla; lo pide al usuario.)

## 9. Resumen para la defensa (a completar)
| Concepto | Valor |
|---|---|
| Costo de desarrollo (horas hombre) | `[COMPLETAR]` |
| Licencias | **0** con MySQL Community y Qt Community en uso educativo; otros ítems `[COMPLETAR]` |
| Infraestructura inicial | `[COMPLETAR]` |
| Mantenimiento anual | `[COMPLETAR]` |
| Modelo de ingreso elegido | `[COMPLETAR]` (sugerencia: llave en mano + soporte) |
| Precio por escuela | `[COMPLETAR]` |
| Punto de equilibrio | `[COMPLETAR]` |

## Fuentes (consultadas el 12/11/2026)
1. [MySQL Community Edition — mysql.com](https://www.mysql.com/de/products/community/) (consultada 12/11/2026; fecha de la fuente `[COMPLETAR]`)
2. [Qt licensing — qt.io](https://www.qt.io/development/qt-framework/qt-licensing) (consultada 12/11/2026; fecha de la fuente `[COMPLETAR]`, pie «© 2026»)
3. [MySQL Community (GPL) vs Enterprise: cuándo hay que pagar — Redress Compliance](https://redresscompliance.com/mysql-community-gpl-vs-enterprise-when-you-must-pay) (17/08/2026, actualizado 25/09/2026; consultora, no es una fuente oficial de Oracle)
4. Precios de plataformas escolares y Google Workspace for Education: ver las fuentes de `ANALISIS_COMPETENCIA.md`.

## Desvíos
- **Ronda final (13/11/2026):** revisé cada cifra. Las cifras del proyecto (líneas, funciones, casos, errores) las actualicé a la app v3 y a los recuentos de `INFORME_PRUEBAS.md` (337 casos, 24 errores abiertos). Saqué el rango de precios «25 a 49,90 €/mes» porque venía de un directorio sin fecha de publicación. Cifras que quedan con fuente y fecha: MySQL Standard 2.140 USD por servidor por año (lista de Oracle del 11/09/2025, según artículo del 17/08/2026, actualizado el 25/09/2026) y la fecha del 21/04/2026 de MySQL 8.0. Todo lo demás son fórmulas o `[COMPLETAR]`.
- **No puse ninguna cifra de horas, sueldos ni precios**: no están en ningún archivo del proyecto. Las tablas quedan con fórmulas y `[COMPLETAR]`.
- El valor de MySQL (2.140 USD) es precio de lista de Oracle según una consultora, y no se usa en el presupuesto de IQUAL porque se asume MySQL Community; está para mostrar qué pasaría si se necesitara la edición comercial.
- No verifiqué la licencia de Qt Creator, CMake, MinGW, DBeaver, Workbench ni MySQL Connector/ODBC: están marcadas `[COMPLETAR]`.
- Dije que el SaaS exigiría rehacer o exponer la app porque hoy es de escritorio (es lo que se ve en el código y en `MANUAL_TECNICO.md`); no es una estimación de esfuerzo.

## Datos que faltan
- Horas reales por rol e integrante (bitácora) y criterio del valor hora. — **usuario**
- Costo de infraestructura que tiene o necesitaría E.T. N°3. — **usuario / Linares**
- Cantidad de alumnos y usuarios simultáneos de la escuela. — **usuario / Linares**
- Precio de IQUAL y modelo elegido. — **usuario**
- Licencias de las herramientas listadas y precio de Qt comercial (qt.io/pricing). — **usuario**
- Si el proyecto puede comercializarse (propiedad intelectual del trabajo escolar). — **Linares**
