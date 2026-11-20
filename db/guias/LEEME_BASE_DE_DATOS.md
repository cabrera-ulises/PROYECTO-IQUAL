# LEEME_BASE_DE_DATOS.md — cargar y verificar la base de IQUAL (ronda de cierre, CONTEXTO v3.2)

**Orden de ejecución:** `03_ModeloSQL` → `04_DatosSQL` → `05_Backend` (27 procedimientos almacenados, solo para MySQL) → `06_PruebasSQL.xlsx` (planilla de pruebas, no es un script). Los scripts 03, 04 y 05 se pueden repetir las veces que haga falta. SQL Server tiene solo 03 y 04.

| Archivo | Para qué |
|---|---|
| `03_ModeloSQL_Grupo00.sql` / `_sqlserver.sql` | Borra y crea las 47 tablas vacías (MySQL: una base `iqual`; SQL Server: 7 schemas) |
| `04_DatosSQL_Grupo00.sql` / `_sqlserver.sql` | Vacía las 47 tablas y carga catálogos y datos (62 usuarios) |
| `05_Backend_Grupo00.sql` | 27 procedimientos: 15 de funcionalidades (el 1 es `sp_registrar_log`), 9 de reportes y auditoría, 2 `_tuneado` y el auxiliar `sp_aux_solo_digitos`. Solo MySQL; usa `DELIMITER` |
| `06_PruebasSQL.xlsx` | Planilla de pruebas (107 casos de los procedimientos), no es un script |
| `generar_datos.py`, `generar_modelo.py` | Generaron los cuatro archivos 03 y 04. Para volver a correrlos hacen falta `iqual_mysql.sql` e `iqual_sqlserver.sql` (las fuentes de la ronda anterior), que **ya no viajan en el repositorio**; sin ellos no se pueden regenerar |
| `renombrar_grupo.sh` | Reemplaza `Grupo00` por el número de grupo en nombres de archivo y textos (ver la sección 4) |
| `consultas_verificacion_mysql.sql` / `_sqlserver.sql` | Controles con el valor esperado en cada consulta |
| `consultas_demo.sql` / `consultas_demo_sqlserver.sql` | Las 10 consultas para la defensa |

**Qué se probó de verdad:** en **MariaDB 10.11** se integraron y probaron 03, 04 y 05 (62 usuarios, 27 procedimientos) y los 107 casos de `06_PruebasSQL.xlsx` dieron PASS (CONTEXTO §22; dato que me pasaron, no lo corrí yo). Los valores esperados de los comentarios de `consultas_demo.sql` y `consultas_verificacion_*.sql` (con los 62 usuarios) se calcularon con una carga de prueba fuera de MySQL el 19/11/2026: **no están confirmados en MariaDB ni en MySQL 8**. `[COMPLETAR: correr las consultas en MariaDB o MySQL y anotar si las cantidades coinciden]` **Nunca se ejecutó:** MySQL 8 de Oracle, SQL Server 2005 y Windows. De SQL Server solo hay revisión estática (`REVISION_ESTATICA_SQLSERVER.md`).

## 1. MySQL 8 / MariaDB (DBeaver)

1. Conectate a `localhost:3306`.
2. Abrí `03_ModeloSQL_Grupo00.sql` y ejecutalo **entero con Alt+X** (crea la base `iqual` si no existe, y hace `USE iqual`).
3. Abrí `04_DatosSQL_Grupo00.sql` y ejecutalo con **Alt+X**.
4. Abrí `05_Backend_Grupo00.sql` y ejecutalo **entero con Alt+X** (usa `DELIMITER`; si lo corrés sentencia por sentencia se corta a la mitad).
5. Verificá con `consultas_verificacion_mysql.sql`.

Consola (cmd, no PowerShell):
```
mysql -u root -p --default-character-set=utf8mb4 < 03_ModeloSQL_Grupo00.sql
mysql -u root -p --default-character-set=utf8mb4 < 04_DatosSQL_Grupo00.sql
mysql -u root -p --default-character-set=utf8mb4 < 05_Backend_Grupo00.sql
```
Para repetir: volvé a correr 03, después 04 y después 05 (03 borra las tablas pero no los procedimientos). No hace falta borrar la base. Los pasos de DBeaver y de consola están escritos de lo que se sabe del programa, sin probarlos en Windows. 🔶

## 2. SQL Server 2005 / Express (SSMS)

1. Abrí SSMS, conectate (por ejemplo `.\SQLEXPRESS`).
2. Abrí `03_ModeloSQL_Grupo00_sqlserver.sql` y apretá **F5**. Crea la base, los 7 schemas y las tablas. Si había una carga vieja sin schemas (`dbo.*`), la borra.
3. Abrí `04_DatosSQL_Grupo00_sqlserver.sql` y **F5**.
4. Verificá con `consultas_verificacion_sqlserver.sql` (ya trae los nombres con schema).
5. Para repetir: volvé a correr 03 y después 04. No hay `05` para SQL Server: los procedimientos son solo de MySQL.

Consola: `sqlcmd -S .\SQLEXPRESS -i 03_ModeloSQL_Grupo00_sqlserver.sql` y lo mismo con el 04 (los `GO` los entiende `sqlcmd`). Si las tildes salen mal, abrí el archivo en SSMS y guardalo como Unicode. 🔶

## 3. Qué esperar

| Qué | Consulta | Esperado |
|---|---|---|
| Tablas (MySQL) | `SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'iqual';` | **47** |
| Tablas (SQL Server) | `SELECT COUNT(*) FROM sys.tables;` | **47** (48 si SSMS creó `sysdiagrams`) |
| Usuarios | `SELECT COUNT(*) FROM usuario;` | **62** (46 alumnos, 9 profesores, 4 preceptores, 3 maestranza; mínimo pedido: 50) |
| Filas por tabla | consulta 17 de verificación | 47 filas de resultado; las cantidades están en el comentario (por ejemplo equipos 60, ventas 28) |
| Catálogos | consulta 14 | rol 4, especialidad 3, … anio 7, division 9 |
| Integridad | consulta 15 | los **21** controles dan **0** (6 de siempre y 15 nuevos) |
| Procedimientos (MySQL) | `SHOW PROCEDURE STATUS WHERE Db = 'iqual';` | **27** (después de correr 05) |
| Recaudado «Viaje de Estudios 4to 1ra» | consulta 2B (o la 9 de la demo) | **3500** (los otros 20 grupos tienen otros valores) |
| Solape de reservas | 1A y 1B | 1A: **1 fila**; 1B: **0 filas** (cargar y consultar el mismo día) |
| Auditoría | 8A–8E y 9 | **0 filas** hasta correr los procedimientos de 05 o usar la app: `log_auditoria` queda vacía a propósito |

Los valores esperados de los comentarios se calcularon con una carga de prueba fuera de MySQL (19/11/2026); en MariaDB 10.11 se probaron 03, 04 y 05; en MySQL 8 de Oracle y en SQL Server son los que **deberían** dar.

**Usuarios y claves:** las cuentas de demostración originales (`alumno1`, `alumno2`, `profe1`, `preceptor1`, `maestranza1`) conservan sus datos. Los 57 usuarios nuevos tienen nombres, DNI, correos y teléfonos ficticios y la misma clave de demostración.

Si algo falla: copiá el mensaje completo (número y texto) y la línea que marca el programa.

## 4. Cambiar `Grupo00` por el número de grupo

El número de grupo ya se le consultó a Linares; mientras no lo informe, los archivos siguen con `Grupo00`. Cuando lo sepas, en Git Bash y parado en la carpeta del paquete (donde está `renombrar_grupo.sh`):

```
bash renombrar_grupo.sh --simular 7
bash renombrar_grupo.sh 7
```

La primera línea solo muestra qué cambiaría; la segunda lo hace y deja `Grupo07`. Renombra los archivos `*_Grupo00*` y cambia el texto `Grupo00` en `.md`, `.sql`, `.xlsx`, `.sh`, `.py` y `.txt`. No toca `mainwindow.cpp`: ese archivo tiene el mensaje «Cargá 03_ModeloSQL_Grupo00.sql…», y si lo querés cambiar corré el script con `--incluir-app` (y recompilá). Hacelo antes de subir al repositorio. [COMPLETAR: número de grupo]

## Desvíos

- Pedido: «una página». Son más por los dos motores.
- Los pasos de DBeaver y SSMS y el borrado de tablas viejas `dbo.*` en SQL Server están escritos de lo que sé, sin ejecutarlos. 🔶
- `04` depende de que `producto_buffet.id_categoria_producto DEFAULT 1` encuentre la categoría 1: por eso MySQL usa `TRUNCATE` y SQL Server reinicia el contador con `DBCC CHECKIDENT` (con una guarda para tablas nunca usadas). Esa guarda no está probada en un servidor real. 🔶
- 23 de los 24 cursos tienen horario: 5° 2° Óptica quedó sin horario (si lo tuviera, la inscripción de Ed. Física de `alumno2` chocaría). 4° 1° Computación conserva el horario de antes. No afecta los controles.
- La *collation* del servidor puede cambiar comparaciones de texto en SQL Server (ver `REVISION_ESTATICA_SQLSERVER.md`).
- Las consultas de verificación decían «22 controles» en la consulta 15; hay 21 (6 de siempre y 15 nuevos). Se corrigieron los comentarios de los dos archivos y este documento.

## Datos que faltan

- [COMPLETAR: versión de MySQL 8 y de SQL Server con los que se prueba]
- [COMPLETAR: resultado de correr 03 y 04 en cada motor (ok o mensaje de error)]
- [COMPLETAR: número de grupo que informe Linares (sección 4)]
