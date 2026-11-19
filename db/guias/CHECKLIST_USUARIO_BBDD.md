# CHECKLIST_USUARIO_BBDD.md — lo que tenés que hacer vos (Bases de Datos)

Nadie más puede hacer estos pasos: necesitan tu compu y tus programas. Tildá cada uno. Los detalles de carga están en `LEEME_BASE_DE_DATOS.md`.

## A. Diagramas (draw.io)

1. [ ] Abrí `Proyecto_IQUAL_Edgar_Codd.xml` en draw.io (Archivo → Abrir). Mirá que se vean las 47 tablas, los conectores y que no haya cosas encimadas.
2. [ ] Exportalo: Archivo → Exportar como → PNG. Dejá el fondo blanco (sin transparencia) y una resolución que se lea al hacer zoom (200 % o más). Guardalo con el nombre exacto **`edgar-codd-modelo-logico.png`**. 🔶 (los nombres de los menús son los del draw.io de escritorio)
3. [ ] Repetí con `Proyecto_IQUAL_Peter_Chen.xml` → **`peter-chen-modelo-conceptual.png`**.
4. [ ] Abrí los dos PNG y fijate que se lea el texto de las elipses y de las tablas. Si algo se corta o se pisa, avisá con una captura.

## B. MySQL 8

5. [ ] Anotá la versión: `SELECT VERSION();` → [COMPLETAR: versión].
6. [ ] Corré `03_ModeloSQL_Grupo00.sql` y **después** `04_DatosSQL_Grupo00.sql`, cada uno con Alt+X en DBeaver (o por consola). El 03 ya crea la base `iqual`.
7. [ ] Corré `05_Backend_Grupo00.sql` con Alt+X (después del 04) y comprobá `SHOW PROCEDURE STATUS WHERE Db = 'iqual';` → 27 filas.
8. [ ] Corré `consultas_verificacion_mysql.sql` y comprobá: 47 tablas, 1A = 1 fila, 1B = 0 filas, recaudado 3500, los 21 controles de la consulta 15 todos en 0 (1A y 1B dan eso solo si se consulta el mismo día de la carga).
9. [ ] Corré `consultas_demo.sql` (las 10 consultas de la defensa).
10. [ ] Probá algunos `CALL` (el archivo 05 ya no trae llamadas de ejemplo): por ejemplo `CALL sp_rep_recaudado_por_grupo('2026-01-01', '2026-12-31');` y `CALL sp_rep_prestamos_por_carro('2026-01-01', '2026-12-31');`. Los casos con resultado esperado están en `06_PruebasSQL.xlsx`.

## C. SQL Server 2005 / Express

11. [ ] Anotá la versión: `SELECT @@VERSION;` → [COMPLETAR: versión].
12. [ ] Abrí `03_ModeloSQL_Grupo00_sqlserver.sql` en SSMS y ejecutalo con F5; después abrí `04_DatosSQL_Grupo00_sqlserver.sql` y ejecutalo también (sin el 04 las tablas quedan vacías). No hay `05` para SQL Server.
13. [ ] Abrí `consultas_verificacion_sqlserver.sql` (con `USE iqual; GO` antes) y comprobá los mismos valores que en MySQL (en vez de `information_schema`, la consulta 16 usa `sys.tables`).
14. [ ] Corré la versión de SQL Server de la consulta 8 de `consultas_demo.sql` (es la única que cambia entre motores).
15. [ ] Si el script da error, copiá el **número y el texto completo** del mensaje y la línea.

## D. SQLite (opcional)

16. [ ] Cargá `iqual_sqlite.sql` en DB Browser for SQLite y corré `SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';` → 47.

## E. Capturas de evidencia (guardalas con nombre claro, por ejemplo `bbdd-01-mysql-47-tablas.png`)

17. [ ] DBeaver con el árbol de la base `iqual` (las tablas) y el resultado de `COUNT(*) = 47`.
18. [ ] Resultado de 1A (1 fila) y de 1B (0 filas) en MySQL.
19. [ ] Resultado del recaudado = 3500 (consulta 2B).
20. [ ] Resultado de un `CALL` de procedimiento y de uno que dispare el manejador de errores (por ejemplo `CALL sp_rep_prestamos_por_carro('2026-12-31', '2026-01-01');`, rango invertido: tiene que devolver una fila con `estado = ERROR`).
21. [ ] SSMS con el Object Explorer mostrando las tablas de `iqual` y el resultado de `SELECT COUNT(*) FROM sys.tables` = 47.
22. [ ] Resultado de 1A y 1B en SQL Server.
23. [ ] Los dos diagramas abiertos en draw.io (además de los PNG exportados).
24. [ ] Cada captura tiene que mostrar la hora del sistema o la versión del motor, para que se vea con qué se probó.

## F. Después

25. [ ] Pasale a Arce Thiago y Cabrera Ulises (o al chat que corresponda) los resultados: ok o mensaje de error, con las versiones anotadas en los pasos 5 y 11.
26. [ ] Si el profesor ya confirmó el motor, avisá cuál (MySQL o SQL Server) para ajustar los documentos.
27. [ ] Para cargar datos reales del colegio, seguí `COMO_COMPLETAR_DATOS_REALES.md`.

## Desvíos

- Los nombres de menú de draw.io y las capturas sugeridas son una propuesta mía; no hay un listado de capturas obligatorias en el contrato. [COMPLETAR: si Linares pide otras capturas]

## Datos que faltan

- [COMPLETAR: versiones de MySQL y SQL Server usadas]
- [COMPLETAR: resultados de las pruebas de los pasos 8 a 14]
