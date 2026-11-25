# PREGUNTAS_LINARES_BBDD.md — las 10 preguntas más probables sobre el modelo (y qué hay que preguntarle a Linares)

Respuestas cortas para decir en voz alta. Los números son los de los scripts: **47 tablas = 24 catálogos + 23 entidades/relaciones**, 57 claves foráneas. Las preguntas son una estimación mía de lo que puede preguntar Linares; no sé qué va a preguntar de verdad.

**1. ¿Qué es la tercera forma normal y cómo la cumple tu modelo?**
Es 1FN (valores atómicos, sin grupos repetidos), 2FN (cada atributo depende de toda la clave) y 3FN (ningún atributo depende de otro que no sea clave). Lo cumplimos separando en tablas los datos repetidos: roles, estados y tipos están en catálogos y las demás tablas guardan solo su id. En `justificacion_3FN.md` está tabla por tabla.

**2. ¿Por qué tantas tablas (47)? ¿No se puede con menos?**
Hay 24 catálogos (rol, turno, estado_reserva, tipo_sector, etc.) y 23 entidades y relaciones. Si guardáramos «Pendiente» como texto en cada reserva repetiríamos datos y un error de tipeo crearía un estado nuevo. Con catálogo se cambia el nombre en un solo lugar.

**3. ¿Qué claves usaron?**
Cada tabla tiene clave primaria `id_...` entera autoincremental (clave sustituta). Las relaciones entre tablas son claves foráneas con nombre (`fk_tabla_columna`). Además hay `UNIQUE` en lo que no se puede repetir: DNI, usuario, email, nombre del sector. Los 57 conectores del diagrama de Codd son esas 57 foráneas.

**4. ¿Dónde hay relaciones muchos a muchos y cómo se resuelven?**
Cuatro: horario y día (`horario_dia`), usuario y grupo del buffet (`integrante_grupo`), venta y producto (`detalle_venta`) y equipo y programa (`recurso_software`). Cada una es una tabla intermedia con dos claves foráneas. En el Chen se dibujan como rombo; en el Codd, como tabla.

**5. `detalle_venta.precio_unitario` repite el precio del producto: ¿no rompe la 3FN?**
No. Depende de la clave completa (venta y producto) y no se puede calcular desde `producto_buffet.precio`, porque el precio del producto puede cambiar después de la venta. Guarda el precio histórico de esa línea (duda D2 de la justificación).

**6. ¿Por qué no guardaron el total de la venta, el recaudado ni los cupos usados?**
Son datos derivados: se calculan con `SUM` y `COUNT` desde otras tablas. Si los guardáramos habría que actualizarlos a mano y podrían quedar mal. Por eso el `recaudado` es una elipse punteada en el Chen y no existe en el Codd. Regla vigente: donaciones más ventas **entregadas** del grupo (3500 con los datos de ejemplo).

**7. ¿Qué es un procedimiento almacenado y cuáles hicieron?**
Es código SQL guardado en la base que se ejecuta con `CALL`. Hicimos 27 en MySQL (`05_Backend_Grupo06.sql`): 15 funcionalidades (por ejemplo `sp_registrar_usuario`, `sp_prestar_equipo`, `sp_comprar_producto`, `sp_reservar_sector`), 9 reportes y auditoría (`sp_rep_…`), 2 versiones tuneadas de reportes pesados y 1 auxiliar. Las funcionalidades usan `DECLARE EXIT HANDLER FOR SQLEXCEPTION` y `GET DIAGNOSTICS` (como en la clase 006) y las reglas de negocio se rechazan con `SIGNAL SQLSTATE '45000'`. La app no los usa: se cargan a mano con Alt+X después de 03 y 04, y se pueden volver a correr.

**8. ¿Por qué `usuario.id_curso` admite NULL, y `horario_escolar` guarda el turno?**
Solo los alumnos tienen curso; para los otros roles queda NULL (D5: la alternativa sería una tabla `alumno`, que no está en el contrato). El turno (Mañana/Tarde) se guarda en el horario como dato propio; si dependiera solo de la hora sería una dependencia transitiva, y por eso está anotado como duda D1 en la justificación.

**9. ¿Qué diferencias hay entre MySQL y SQL Server 2005 en su base?**
Los ids: `AUTO_INCREMENT` e `IDENTITY(1,1)`. Las fechas: `DATE`/`DATETIME` en MySQL y solo `DATETIME` en SQL Server 2005 (no tiene `DATE`). Los textos con tildes: `utf8mb4` y `NVARCHAR`. La consulta «mañana» cambia (`DATE_ADD` / `DATEADD`) y `LIMIT` pasa a `TOP`. Probado de verdad: MariaDB 10.11; MySQL 8 y SQL Server están revisados por lectura (los scripts de SQL Server se compararon línea por línea con los de MySQL el 19/11/2026) pero **no ejecutados** (decirlo así). SQL Server solo tiene los scripts 03 y 04; los procedimientos (05) son solo MySQL.

**10. ¿Qué reglas no controla la base y las controla la app? ¿Cómo detectan que dos reservas se pisan?**
La base no impide que un préstamo lo pida alguien que no es alumno (D8) ni dos tableros con el mismo número, porque `UNIQUE` con `id_carro` NULL no los frena en MySQL (D3; SQL Server sí). Eso lo valida la app. Las reservas que se pisan se detectan con una consulta de solape: hay conflicto si `hora_inicio < fin_nuevo AND hora_fin > inicio_nuevo` para ese sector y día, entre reservas Pendientes o Aprobadas (consultas 1A y 1B: 1 fila y 0 filas).

## Para preguntarle a Linares (abiertas, 19/11/2026)

1. **Número de grupo:** respondido: somos el **Grupo 6** (Arce Thiago y Cabrera Ulises). Los archivos ya dicen `Grupo06`.
2. **Esquemas en MySQL:** en SQL Server hay 7 esquemas (`seguridad`, `academico`, `objetos`, `instalaciones`, `tienda`, `equipos`, `deportes`). En MySQL un esquema es una base, y nosotros tenemos una sola (`iqual`) con las 47 tablas. ¿Alcanza con eso o quiere 7 bases en MySQL? [COMPLETAR: respuesta]
3. **Catálogos con menos de 20 filas:** casi todos los catálogos tienen entre 2 y 14 filas (rol 4, turno 2, estado_venta 3, etc.). Si la consigna pide mínimo 20 filas por tabla, ¿vale para los catálogos o solo para las entidades? [COMPLETAR: respuesta]
4. **Tablas temporales en el procedimiento tuneado:** `sp_rep_ventas_por_producto_tuneado` usa `CREATE TEMPORARY TABLE` (técnica de la clase 004). ¿Está bien usar tabla temporal, o prefiere que el tuning sea solo con índices y pre-agregado? [COMPLETAR: respuesta]
5. **¿Pide SQL Server además de MySQL?** Entregamos los dos scripts (03 y 04) en SQL Server 2005 por las dudas, pero **no se ejecutaron** en SQL Server. Si solo pide MySQL, no hace falta presentarlos. [COMPLETAR: respuesta]
6. **¿La app debe ejecutar los SP de funcionalidades con `CALL`, como en la clase 006?** Hoy la app usa `CALL` solo para `sp_registrar_log` (auditoría; si el procedimiento falla, hace el `INSERT` directo). El resto de las funcionalidades (reclamar, prestar, reservar, comprar, inscribir, etc.) las hace con consultas preparadas (`prepare` / `bindValue`), y los SP 2 a 15 se ejecutan desde DBeaver o Workbench y en los casos de `06_PruebasSQL.xlsx`. En la clase 006 se conecta y se ejecuta `CALL` de un SP con parámetros (en Qt, el equivalente de `mysql_query("CALL ...")` es `prepare("CALL sp(?, ?)")` y `exec()`). Si Linares espera que la app llame a los SP, hay que cambiar el código de esas pantallas (lo hace quien mantiene la app). [COMPLETAR: respuesta]

## Desvíos

- Las diez preguntas son predicción: no vienen de Linares ni del contrato. Elegí las que salen directo de `justificacion_3FN.md` y de los procedimientos.
- Dejé fuera preguntas sobre la collation (mayúsculas y tildes) porque están en `REVISION_ESTATICA_MYSQL.md`; si preguntan, la respuesta corta es: «MySQL no distingue mayúsculas ni tildes por defecto y la app guarda el usuario en minúsculas».

## Datos que faltan

- [COMPLETAR: preguntas reales que haga Linares, si te cuenta cuáles fueron]
- [COMPLETAR: respuestas de Linares a las 6 preguntas abiertas de arriba (número de grupo incluido)]
