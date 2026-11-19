# Errores y pendientes — PROYECTO IQUAL® (SGE)

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9 · Proyecto Informático I · Arce Thiago y Cabrera Ulises
**Fecha:** 19/11/2026 · **Estado:** app v3 con registro de log por `sp_registrar_log`; base de datos v7 (`03` a `06`, 47 tablas, 62 usuarios)

## 1. Ya resuelto
- La app compila (Qt 6, CMake) y cumple las reglas de código del profesor (sin comentarios, ternarios, `continue`, `findData`, `auto`, `std::` ni lambdas).
- Base de datos: 47 tablas, 62 usuarios, 27 rutinas almacenadas (15 funcionalidades, 8 reportes, 1 auditoría, 2 tuneados y 1 auxiliar), 107 casos de prueba de SP ejecutados en MariaDB 10.11, todos PASS. Tuning medido en `db/TUNING_REPORTES.md`.
- Diagramas Codd y Chen exportados (XML de draw.io y PNG con fondo blanco) y verificados contra el script, sin diferencias.
- Los casos de prueba y manuales de la app se revisaron contra los datos de MySQL.

## 2. Pendiente: lo hace el equipo
| # | Qué hacer | Para qué |
|---|---|---|
| E-01 | Cargar `03`, `04` y `05` en **MySQL 8** y anotar `SELECT VERSION();`. Correr `consultas_demo.sql` y `consultas_verificacion_mysql.sql` | Hoy solo se probó en MariaDB 10.11 |
| E-02 | Probar **SQL Server** con `03_..._sqlserver.sql` y `04_..._sqlserver.sql` (`db/guias/CHECKLIST_USUARIO_BBDD.md`) | Los scripts solo se revisaron leyéndolos |
| E-03 | Compilar y abrir la app en **Windows** (Qt 6.12 MinGW). Mirar el título de la ventana («· MySQL» o «· MySQL (ODBC)») y hacer una acción para ver el evento en `log_auditoria` | Driver y conexión sin probar en Windows |
| E-04 | Ejecutar los casos de `docs/pruebas/CASOS_PRUEBA_*.md` y completar la columna Resultado, empezando por login, registro, objetos, préstamo, sectores, Tienda y Educación Física | Hoy no hay resultados cargados |
| E-05 | Completar en `db/06_PruebasSQL.xlsx` la fecha de revisión del encabezado | Se corrió en MariaDB; falta repetir en MySQL 8 |
| E-06 | Reemplazar `Grupo00` por el número de grupo con `renombrar_grupo.sh` | Los archivos de la consigna llevan el número |
| E-07 | Sacar capturas reales de la app para los manuales | Las capturas actuales son de la etapa anterior |
| E-08 | Decidir y escribir quién restablece contraseñas y quién entrega el PIN institucional | La app no tiene recuperación de clave |
| E-09 | Buscar `COMPLETAR` en todo el repo y, en cada caso, completar el dato o borrar la línea (sobre todo presupuesto, análisis de competencia y guion del pitch) | No deben quedar marcas en la entrega |

## 3. Preguntas para Linares
Detalle en `db/guias/PREGUNTAS_LINARES_BBDD.md`.
1. Número de grupo.
2. Si acepta **una sola base en MySQL** con los 7 schemas solo en el script de SQL Server (mapa en `db/SCHEMAS.md`).
3. Si acepta los **catálogos con menos de 20 filas** (`db/DATOS_EXCEPCIONES.md`).
4. Si está bien usar **`CREATE TEMPORARY TABLE`** en `sp_rep_ventas_por_producto_tuneado`.
5. Si pide **SQL Server además de MySQL**.
6. Si la app debe **llamar a los procedimientos** de funcionalidades o alcanza con que existan y estén probados en la base.

## 4. Errores abiertos de la app
Todos de gravedad baja; ninguno de gravedad alta. El detalle y el estado de cada uno están en `docs/pruebas/ERRORES_*.md`. Los dos más recientes (ERR-24 y ERR-25, de Objetos perdidos): un objeto «En reclamo» no vuelve a Disponible al rechazar su único reclamo desde la app (el SP sí lo hace), y «Objetos para reclamar» no cuenta los «En reclamo».

## 5. Límites conocidos
- No probado: MySQL 8, SQL Server, Windows, rendimiento con muchos datos (RNF03) y redimensionado de la ventana.
- Los datos de SQLite (respaldo de la app) son un juego chico de 5 usuarios; MySQL trae 62.
- El tuneado de ventas no es más rápido con los datos actuales (28 ventas); está documentado en `db/TUNING_REPORTES.md`.
