# Bitácora — Entradas en BORRADOR
*Versión de la ronda final: se conservan las dos entradas anteriores tal como estaban (describen cómo era el proyecto en esa etapa), las entradas por hito de las versiones 2.3 a 2.9 del archivo de contexto interno del equipo y se suma la entrada de la ronda final (12 al 13/11/2026, app v3).*
> ⚠️ **BORRADOR para revisar.** Estas entradas NO forman parte de `bitacora.md` y no se modificó ese archivo. Solo describen cambios de documentación que figuran en este repositorio; **fechas, horas, participantes y resultados están sin completar a propósito**: los tiene que llenar el equipo con lo que realmente pasó.

---

## Semana [completar] — Actualización de la documentación a la aplicación real (BORRADOR)
* **Fecha / participantes / horas dedicadas:** [completar]
* **Actividades:**
  * Actualización de `requerimientos.md` (RF01-RF18 y RNF01-RNF04), `historias-de-usuario.md` (US01-US11), `marco-logico.xlsx`, `maquetado-y-usabilidad.xlsx` y `README.md` para que describan la aplicación de escritorio que se construye.
  * Reconstrucción del Árbol de Objetivos como archivo editable de draw.io, con el objetivo central "Organización operativa escolar eficiente".
  * Nuevos documentos: `cambios-respecto-al-diseno-inicial.md`, `matriz-trazabilidad.md` y `cambios-presentacion.md`.
* **Entregables / Artefactos:** documentos actualizados en `/docs` y `README.md`. [completar si se publicaron en GitHub y cuándo]
* **Dificultades / observaciones:** [completar]

---

## Semana [completar] — Decisiones de diseño y modelo de datos (BORRADOR)
* **Fecha / participantes / horas dedicadas:** [completar]
* **Actividades:**
  * Definición de la base local SQLite en la app, con el modelo de 44 tablas entregado también en SQL Server y MySQL. [completar quién y cuándo]
  * Motor final de base de datos: **a confirmar con el profesor de BBDD.** [completar resultado de la consulta]
  * Hito 1 de Bases de Datos: diagramas de Peter Chen (conceptual) y Edgar Codd (lógico) en PNG. [completar cuándo se exportaron y dónde están]
* **Entregables / Artefactos:** [completar]
* **Dificultades / observaciones:** [completar]

---

# Entradas por hito (v2.3 a v3) — BORRADOR
> Las **fechas** salen del encabezado de cada versión del archivo de contexto interno (`CONTEXTO_IQUAL.md`); la v2.3 no tiene fecha escrita. **Quién hizo cada cosa, las horas y las dificultades** no están en ningún documento: quedan como `[COMPLETAR]` para que las llene el equipo con lo que realmente pasó. No se tocó `bitacora.md`.

## Hito v2.3 — Estilo de los diagramas de Bases de Datos
* **Fecha / participantes / horas dedicadas:** [COMPLETAR: fecha] · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * Se definió el estilo de los diagramas (Peter Chen y Edgar Codd) usando solo lo visto en clase.
* **Entregables / Artefactos:** sección 12 del archivo de contexto. [COMPLETAR: dónde quedó el material]
* **Dificultades / observaciones:** [COMPLETAR]

## Hito v2.4 — App, base de datos y documentación terminadas (3/11/2026)
* **Fecha / participantes / horas dedicadas:** 03/11/2026 · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * Foto del estado real: la app, la base de datos y la documentación quedaron terminadas y el Pull Request se mergeó a `main`.
  * Planillas: los Alumnos también registran y devuelven préstamos, pero solo a su propio nombre y solo los suyos.
  * Educación Física: si un alumno cambia de curso y su inscripción pasa a superponerse con el horario nuevo, la inscripción se cancela automáticamente, se avisa y queda en la auditoría.
  * Motor de bases de datos: el equipo decidió usar **SQL Server 2005** para la materia de Bases de Datos (no se consultó al profesor); la app seguía con SQLite.
  * Se describieron los datos de demostración reales del script definitivo.
* **Entregables / Artefactos:** app en `main`, tres scripts SQL. [COMPLETAR: enlace del Pull Request]
* **Dificultades / observaciones:** [COMPLETAR]

## Hito v2.5 — Lote 2 de mejoras y planificación de la etapa 3 (4/11/2026)
* **Fecha / participantes / horas dedicadas:** 04/11/2026 · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * Lote 2 implementado y probado: tienda (Mis ventas, Reponer stock, Eliminar), Planillas (equipos fuera de servicio, Marcar reparado, un solo préstamo activo por alumno), Objetos (ventana de detalle) y Sectores (no se reserva en un horario de inicio que ya pasó).
  * El **recaudado** de los grupos pasó a contar solo ventas Entregadas más donaciones.
  * **Mi Cuenta** dejó de ser solo lectura: se puede cambiar la contraseña y el teléfono.
  * La **auditoría** tuvo pantalla para el Preceptor (últimos 50 registros).
  * Se definió la etapa 3 con el contrato de la base de datos y el reparto del trabajo.
* **Entregables / Artefactos:** [COMPLETAR]
* **Dificultades / observaciones:** [COMPLETAR]

## Hito v2.6 — Etapa 3 integrada y rediseño libre de la interfaz (5/11/2026)
* **Fecha / participantes / horas dedicadas:** 05/11/2026 · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * La etapa 3 (tienda, programas, reclamos, ocultar por rol, Higiene, Sectores, login) quedó fusionada y probada en la app. La base pasó a **47 tablas**.
  * Se dejó claro que la interfaz no tiene reglas de la profesora: paleta, estilos y posiciones son libres. Quedan solo las reglas de código.
  * El rediseño empezó a usar el logo y el splash propios.
* **Entregables / Artefactos:** [COMPLETAR]
* **Dificultades / observaciones:** [COMPLETAR]

## Hito v2.7 — Rediseño integrado y cambio de motor a MySQL (9/11/2026)
* **Fecha / participantes / horas dedicadas:** 09/11/2026 · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * El rediseño de la interfaz quedó integrado y compilado: barra lateral y superior, dos temas (claro y oscuro) y splash con GIF.
  * **Decisión de motor:** la app pasa de SQLite a **MySQL**, como en la clase de Bases de Datos. El profesor Linares todavía no lo confirmó. [COMPLETAR: respuesta del profesor]
  * Especialidades reales del colegio: Computación, Óptica y Geografía-Matemática.
  * Tienda: el vendedor puede quitar stock además de reponerlo.
  * Se definió la fase final y el reparto del trabajo.
* **Entregables / Artefactos:** [COMPLETAR]
* **Dificultades / observaciones:** [COMPLETAR]

## Hito v2.8 — Ajuste final de la interfaz y scripts de 47 tablas (9/11/2026)
* **Fecha / participantes / horas dedicadas:** 09/11/2026 · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * El ajuste final de las seis pantallas quedó integrado: textos revisados en segunda persona, confirmaciones con botones Sí y No, orden de tabulación, quitar stock y Educación Física con días y horas en gris.
  * Se escribieron los scripts de 47 tablas para MySQL, SQL Server 2005 y SQLite, los procedimientos almacenados de ejemplo y la plantilla para cargar los datos reales del colegio.
  * Se definió la etapa siguiente: documentación, casos de prueba, cierre de la base y migración.
* **Entregables / Artefactos:** `03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`, `03_ModeloSQL_Grupo00_sqlserver.sql`, `iqual_sqlite.sql`, `05_Backend_Grupo00.sql`, plantilla de datos reales. [COMPLETAR: dónde están publicados]
* **Dificultades / observaciones:** MySQL y SQL Server no se pudieron ejecutar en ese momento. [COMPLETAR]

## Hito v2.9 — La app se conecta a MySQL (10/11/2026)
* **Fecha / participantes / horas dedicadas:** 10/11/2026 · [COMPLETAR: quién] · [COMPLETAR: horas]
* **Actividades:**
  * La app se conecta a MySQL (driver `QMYSQL` u ODBC) con los datos en `iqual.ini`, y vuelve sola a SQLite si algo falla.
  * Se corrigieron en el código los errores medios que salieron de las revisiones: contadores del Inicio, fecha de las consultas, el alumno solo ve sus préstamos, límite de 200 caracteres en las observaciones de Higiene, cerrar sesión que limpia los campos, Educación Física con días y horas en gris.
  * La base se ejecutó en MariaDB 10.11: el script de 47 tablas, los 5 procedimientos y las consultas corren sin errores. Quedan sin probar MySQL 8 de Oracle, SQL Server 2005 y Windows.
  * Se redactaron los casos de prueba, las listas de errores, los manuales de usuario y las guías de MySQL y del driver.
* **Entregables / Artefactos:** carpeta `APP IQUAL V5`, documentación y scripts. [COMPLETAR: enlace del Pull Request o del commit]
* **Dificultades / observaciones:** [COMPLETAR]

## Ronda final (12 al 13/11/2026) — App v3, MySQL y revisión de código
* **Fecha / participantes / horas dedicadas:** 12/11/2026 al 13/11/2026 (el contexto interno fecha esta ronda el 13/11) · [COMPLETAR: quién] · [COMPLETAR: horas]. `[COMPLETAR: qué se hizo el 12/11 y qué el 13/11, porque el contexto no lo separa]`
* **Actividades:**
  * **MySQL (vigente desde el 10/11):** la app se conecta a MySQL con `iqual.ini` y vuelve sola a SQLite si algo falla; la base de 47 tablas se ejecutó en MariaDB 10.11. Siguen sin probar MySQL 8 de Oracle, SQL Server 2005 y Windows.
  * **Revisión de código aplicada:** se sacaron los comentarios, los ternarios, el `continue` y el `findData`, los `.arg` quedaron encadenados de a uno, y la fecha de "hoy" del Inicio pasa como parámetro de la consulta.
  * **App v3 (`iqual_integrado_v3`):** las pruebas automáticas internas (harness3 y harness4) pasan con 0 fallas con MariaDB 10.11 (`QMYSQL`) y con SQLite.
  * **Cambios de comportamiento de la v3:** al publicar un objeto, Categoría y Sector vuelven a "Elegí una categoría" y "Elegí un sector"; las Consultas muestran la fecha como `dd/MM`; en Mi cuenta, elegir el curso que ya tenés muestra "Ese ya es tu curso." y, si se responde "No" al aviso de choque con Educación Física, el selector vuelve al curso anterior; el texto de ayuda de las observaciones de Higiene es "Contá qué pasa (ej: falta papel)"; el Alumno ve solo sus préstamos; en Educación Física un día queda en gris como "(choca con tu horario)" o "(sin clase)".
  * **Decisión:** la pantalla de inicio (splash) no se toca.
  * **Documentación:** se actualizaron los casos de prueba, los errores con su estado, los manuales de usuario y el README a la v3.
* **Entregables / Artefactos:** carpeta `iqual_integrado_v3`. [COMPLETAR: enlace del Pull Request o del commit]
* **Pendientes (no dependen de ningún asistente):** probar el script en MySQL 8 y en SQL Server, instalar el driver en Windows, exportar los PNG de los diagramas de Codd y Chen desde draw.io, completar los `[COMPLETAR]` con datos reales, correr los casos de prueba, sacar capturas reales y confirmar el motor con el profesor Linares.
* **Dificultades / observaciones:** [COMPLETAR]

---

## Datos que faltan
* Participantes, horas dedicadas, dificultades y enlaces de cada hito (todos los `[COMPLETAR]`).
* Número de semana de cada hito en el calendario del bimestre.
* Qué se hizo el 12/11 y qué el 13/11.
* Respuesta del profesor Linares sobre el motor de base de datos.
