# Bitácora de Trabajo del Equipo
**Proyecto:** PROYECTO IQUAL® (Sistema de Gestión Escolar-SGE)  
**Materia:** Proyecto Informático I-4° Año Computación  
**Establecimiento:** Escuela Técnica N°3 D.E.9 Reg 8ª "María Sánchez de Thompson"  
**Equipo 3er bimestre:** Arce Thiago, Cabrera Ulises, Denuble Franco, González Manuel  
**Equipo 4° bimestre:** Arce Thiago, Cabrera Ulises (dupla de desarrollo)  

---

## Semana 1-Definición del Problema Inicial y Pivot
* **Actividades:**
  * Lluvia de ideas inicial sobre problemáticas escolares.Se propuso en primera instancia la problemática del buffet escolar,sin embargo,al existir una coincidencia con otro equipo de trabajo,la elección de la temática se definió mediante piedra papel o tijera.
  * Tras el resultado,el equipo pivotó rápidamente hacia una nueva temática integral:la **desorganización operativa en las áreas generales y recursos comunes del colegio**.
* **Entregables/Artefactos:** Definición del concepto general del PROYECTO IQUAL.

---

## Semana 2-Organización del Entorno e Inicio del Árbol de Problemas
* **Actividades:**
  * Profundización en las causas y consecuencias de la desorganización escolar.
  * Configuración del entorno de trabajo colaborativo: creación del Google Classroom interno del equipo,carpeta compartida en Google Drive,espacio de trabajo en Miro y repositorio oficial en GitHub.
  * Elaboración del primer borrador en papel/boceto del **Árbol de Problemas**.
* **Entregables / Artefactos:** Entorno colaborativo activo y primer borrador del Árbol de Problemas.

---

## Semana 3-Digitalización de Problemas e Inicio del Árbol de Objetivos
* **Actividades:**
  * Finalización del boceto del Árbol de Problemas y su trasplante/digitalización al tablero de Miro.
  * Análisis metodológico para la conversión de estados negativos a medios y fines positivos.
  * Inicio de la elaboración del borrador del **Árbol de Objetivos**.
* **Entregables / Artefactos:** Árbol de Problemas digitalizado en Miro y borrador del Árbol de Objetivos.

---

## Semana 4-Consolidación de Árboles e Inicio del Marco Lógico
* **Actividades:**
  * Traslado y estructuración definitiva del Árbol de Objetivos en el tablero de Miro.
  * Análisis de la Metodología del Marco Lógico (MML) e inicio del planteo de la jerarquía de objetivos (Fin,Propósito,Componentes y Actividades).
* **Entregables / Artefactos:** Árbol de Objetivos completo en Miro e inicio del borrador de la MML.

---

## Semana 5-Redacción de la MML y Creación del Repositorio GitHub
* **Actividades:**
  * Redacción en texto plano del contenido completo de la Matriz de Marco Lógico (MML) para su posterior maquetación en tabla.
  * Creación e inicialización del archivo `README.md` en el repositorio oficial de GitHub con la información institucional del proyecto.
* **Entregables / Artefactos:** Borrador de MML y primer `README.md` publicado en GitHub.

---

## Semana 6-Requerimientos,Historias de Usuario y Maquetado UX/UI en Miro
* **Actividades:**
  * Consolidación de la MML en formato tabla dentro de Miro.
  * Redacción de los Requerimientos Funcionales (RF01-RF12) y No Funcionales (RNF01-RNF04) mediante notas adhesivas de colores.
  * Elaboración del backlog de Historias de Usuario (US01-US06) con sus Criterios de Aceptación (las 3 C de Agile).
  * Diseño del maquetado funcional (wireframes/user flow) y análisis de aplicación de las 10 Heurísticas de Usabilidad de Jakob Nielsen.
* **Entregables / Artefactos:** Tablero de Miro completo con Árboles,MML,Requerimientos,Historias de Usuario y Maquetado.

---

## Semana 7-Migración a Repositorio y Cierre de la Carpeta de Proyecto V1
* **Actividades:**
  * Rediseño y exportación de los Árboles de Problemas y Objetivos a **Draw.io** (`.png`).
  * Migración de los Requerimientos e Historias de Usuario a archivos formateados en Markdown (`docs/requerimientos.md` y `docs/historias-de-usuario.md`).
  * Conversión de la MML y la tabla de Maquetado/Usabilidad a hojas de cálculo formateadas en Excel (`docs/marco-logico.xlsx` y `docs/maquetado-y-usabilidad.xlsx`).
  * Estructuración final de la carpeta `/docs` en GitHub y actualización del `README.md` principal con enlaces navegables a toda la documentación.
* **Entregables / Artefactos:** Carpeta `/docs` y `README.md` actualizados en GitHub, completando los requisitos de la Carpeta  PROYECTO V1.

---
---

# 4° BIMESTRE: Desarrollo del software, mercado y Demo Day
**Equipo:** Arce Thiago, Cabrera Ulises (dupla de desarrollo). **Producto final:** aplicación de escritorio C++17 / Qt 6 conectada a MySQL, presentada en formato pitch.
**Herramientas de trabajo:** Qt Creator y CMake, GitHub, DBeaver / MySQL Workbench, draw.io, Claude Slides para el deck y un asistente de IA (Claude) como apoyo para analizar el código, generar scripts y redactar documentación, con revisión del equipo.

## Semana 1-Arquitectura del sistema y prototipo de la interfaz en Qt
* **Actividades:**
  * Configuración del entorno de trabajo (Qt Creator, kit Desktop Qt 6.12.0 MinGW 64-bit) y vinculación con el repositorio de GitHub.
  * Maquetado de la interfaz en Qt Designer (`mainwindow.ui`): una sola ventana con un `QStackedWidget` de 10 páginas (inicio, acceso, resumen y un módulo por página), barra lateral, barra superior y dos temas (claro y oscuro).
  * Implementación de eventos con señales y slots (más de 90 slots `on_..._clicked`).
  * Estudio de lo visto en clase (guías de Qt 1 a 8) comparado con el código de la app, para saber qué conceptos explicar en la defensa: structs, referencias, expresiones regulares, listas de widgets.
  * Comparación entre el diseño del 3er bimestre (árboles, MML, requerimientos, maquetado) y la app: se documentó cada diferencia y su motivo en `docs/cambios-respecto-al-diseno-inicial.md`.
* **Entregables / Artefactos:** prototipo navegable en C++/Qt sin persistencia, sincronizado en el repositorio.

## Semana 2-Persistencia e integración con la base de datos
* **Actividades:**
  * Revisión de los diagramas Peter Chen y Edgar Codd: se corrigieron inconsistencias entre ambos (atributos multivaluados convertidos en tablas, cardinalidades, catálogos para los datos categorizables) y el modelo pasó de 35 a 47 tablas en tercera forma normal.
  * Decisión de usar MySQL como único motor y retirar SQLite: la clase de Bases de Datos trabaja con MySQL. La app se conecta con `QSqlDatabase` (driver `QMYSQL` o ODBC), lee los datos de conexión de `iqual.ini` y, si no puede conectar, avisa el motivo.
  * Scripts de la base: `03_ModeloSQL` (tablas), `04_DatosSQL` (62 usuarios y datos de demostración) y `05_Backend` (procedimientos almacenados); versión para SQL Server 2005 como respaldo.
  * Pasaje de los formularios a consultas con `QSqlQuery` y parámetros (`bindValue`): altas, bajas y modificaciones en los seis módulos.
  * Auditoría: toda acción importante se registra en `log_auditoria` mediante el procedimiento `sp_registrar_log`.
* **Entregables / Artefactos:** módulo ABM funcional integrado a MySQL; diagramas Chen y Codd (XML de draw.io y PNG); scripts 03, 04 y 05.

## Semana 3-Lógica de negocio, validaciones y calidad
* **Actividades:**
  * Validaciones de entrada: DNI de 7 u 8 dígitos, correo con expresión regular, largos mínimos, contraseña con hash SHA-256 y bloqueo tras 5 intentos fallidos de acceso.
  * Reglas del dominio: prueba de pertenencia para reclamar objetos perdidos, bloqueo de reservas de sectores superpuestas, cruce del horario de cursada con Educación Física, stock y metas de recaudación en la tienda.
  * 27 procedimientos almacenados (15 de funcionalidades, reportes, auditoría y dos versiones tuneadas) y 104 casos de prueba de la base planificados en `db/06_PruebasSQL.xlsx`, de los cuales 80 se ejecutaron a mano en la aplicación. Se midió el tuning de los reportes (`db/TUNING_REPORTES.md`).
  * Diseño de 337 casos de prueba por pantalla y registro de errores por módulo (`docs/pruebas/`); revisión del código contra las reglas de la profesora (sin comentarios, ternarios, `continue`, `auto`, `std::` ni lambdas).
* **Entregables / Artefactos:** versión candidata de la app, casos de prueba, informe de errores e `INFORME_PRUEBAS.md`.

## Semana 4-Análisis de mercado y competencia
* **Actividades:**
  * Relevamiento de alternativas (miEscuela, Google Workspace for Education, Clickedu, Alexia, Esemtia, Cifra, e-Schooling, Tramix) y armado de la matriz comparativa de funcionalidades y de costos.
  * Propuesta única de valor: IQUAL resuelve la vida cotidiana de la escuela técnica y complementa a los sistemas de notas y asistencia, sin reemplazarlos.
  * Entrega del informe de competencia de la semana; después se actualizó a una versión final porque la app pasó de SQLite a MySQL y el plan pidió costos y precio.
* **Entregables / Artefactos:** informe analítico de competencia (versión entregada y versión final).

## Semana 5-Presupuesto, modelo de negocio y pitch
* **Actividades:**
  * Presupuesto: 320 horas a $10.000 (desarrollo $3.200.000), licencias $0, infraestructura $870.000 y mantenimiento $720.000 por año.
  * Modelo de negocio: llave en mano más soporte mensual; precio propuesto $4.500.000 + $80.000 por mes; estimación a validar con datos reales. El SaaS queda como etapa futura.
  * Armado del Pitch Deck de 10 diapositivas y del guion para dos voces, con tiempos para entrar en 5 a 7 minutos.
* **Entregables / Artefactos:** Pitch Deck, `PRESUPUESTO_Y_MODELO_DE_NEGOCIO.md` y `GUION_PITCH.md`.

## Semana 6-Demo Day
* **Actividades:**
  * Ronda de datos reales del colegio: cursos de 1° a 6° con divisiones 1 a 5, 36 sectores, programas instalados en las computadoras y tableros sin programas.
  * Corrección de dos detalles de la app: el «Último mantenimiento» ahora salta al sector del reporte resuelto y la tienda arranca en la vista «TODOS». Se retiró la pantalla de presentación (splash).
  * Manual de usuario unificado y manual técnico finales; revisión de que las cifras de los documentos coincidan con el código y con la base (47 tablas, 62 usuarios, 27 procedimientos, 104 casos de la base).
  * Corrección de dos errores hallados en las pruebas: el registro ahora rechaza usuarios con espacios y contraseñas en blanco, y la cancelación de una reserva de sector queda en la auditoría.
  * Ejecución de pruebas: 80 de los 104 casos planificados de la base y 306 de los 337 casos por pantalla (285 OK, 21 con observación, 31 sin probar).
  * Preparación del pitch: ensayos con cronómetro, capturas y video de respaldo de la demo.
  * Demo Day: martes 24/11/2026.
* **Entregables / Artefactos:** software final, defensa en formato pitch, manual técnico y manual de usuario.
