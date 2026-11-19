# COMO_COMPLETAR_DATOS_REALES.md — reemplazar los datos de ejemplo por los reales del colegio (Windows)

Para PROYECTO IQUAL (SGE). Revisada el 19/11/2026 con el flujo actual: `03_ModeloSQL_Grupo00.sql` → `04_DatosSQL_Grupo00.sql` → `05_Backend_Grupo00.sql`.

> **Qué cambió respecto de la versión anterior (12/11/2026).** La versión anterior describía un flujo con `plantilla_datos_reales`, 11 planillas CSV, `generar_sql.py` y un script armado `iqual_mysql_armado.sql`. **Nada de eso está en el paquete actual** (ni la carpeta `plantilla_datos_reales`, ni `generar_sql.py`, ni los CSV, ni `iqual_mysql.sql`). Ese flujo queda **obsoleto** y lo saqué de la guía. Lo que sigue es un procedimiento que se hace solo con los archivos que sí existen. La lista de «qué pedir en el colegio» (sección 1) se mantiene porque sigue valiendo.

**Qué se probó y qué no.** El punto de corte de la sección 2 (línea 148 de `04_DatosSQL_Grupo00.sql`) lo verifiqué por texto: antes de esa línea están solo los 19 catálogos fijos (rol, turno, dia_semana, categoria_objeto, estado_objeto, estado_reclamo, tipo_reporte, estado_reporte, estado_reserva, estado_venta, tipo_recurso, estado_recurso, tipo_log, resultado_log, entidad_log, tipo_sector, categoria_producto, anio, division); desde ahí, todo lo que depende del colegio. **No ejecuté nada en MySQL** (no hay MySQL en el entorno donde se revisó). Los pasos de DBeaver están escritos de lo que sé del programa, no de verlo: 🔶.

## 0. Qué necesitás

- La carpeta `BASE DE DATOS & MODELOS RELACIONALES` del paquete (con `03_…`, `04_…` y `05_…`).
- MySQL 8 y DBeaver (o Workbench) ya instalados y conectados como en `GUIA_INSTALACION_MYSQL.md` (usuario `root`, base `iqual`).
- Un editor de texto (Bloc de notas, VS Code o el propio editor de DBeaver).
- Opcional: Excel o LibreOffice para juntar los datos antes de pasarlos a SQL.

## 1. Qué pedir en el colegio

Nada de esto se inventa: lo que trae `04_DatosSQL_Grupo00.sql` son **ejemplos** (salvo los nombres de las tres especialidades, que son los del proyecto). Si no te lo pueden dar todavía, dejalo como está y anotalo como pendiente.

| Tabla | Qué hay que conseguir | A quién | Reglas |
|---|---|---|---|
| `especialidad` | Nombre oficial de cada especialidad | Secretaría o Dirección | Sin repetidos |
| `curso` | Cada curso que existe: año (1 a 7), división (1 a 9) y especialidad | Secretaría o preceptoría | La especialidad tiene que existir en `especialidad`; no se repite la combinación año+división+especialidad |
| `carro` y `recursos_ct` | Cada carro de computadoras (nombre, cuántas compus tiene, cuáles están fuera de servicio) y los tableros de dibujo (cantidad y cuáles están rotos) | Encargado del laboratorio o jefe de taller | Las computadoras llevan carro; los tableros llevan `id_carro` en `NULL`; el par (carro, número de equipo) no se repite |
| `software` y `recurso_software` | Programas instalados y en qué carro está cada uno | Encargado del laboratorio | Sin repetidos |
| `deporte` | Deportes que se ofrecen en Educación Física | Profe de Ed. Física | Sin repetidos |
| `franja_horaria` | Franjas horarias de Ed. Física (inicio y fin) | Profe de Ed. Física | Fin posterior al inicio; no hay dos franjas iguales |
| `oferta_deporte` | Cada oferta: deporte, día, franja y cupo | Profe de Ed. Física | El deporte, el día y la franja tienen que existir; cupo entero |
| `sector` | Sectores del colegio y cuáles se pueden reservar | Dirección o preceptoría | El tipo es `Reservable` o `Uso común` |
| `materia` | Materias y su código | Secretaría | Sin repetidos |
| `horario_escolar` y `horario_dia` | Grilla de clases: curso, materia, días, hora de inicio y fin, turno | Preceptoría | Curso y materia tienen que existir; turno `Mañana` o `Tarde`; fin posterior al inicio |

Reglas generales:
- Los nombres tienen que coincidir **letra por letra** entre una tabla y otra, tildes incluidas (`Optica` ≠ `Óptica`), porque los INSERT buscan por nombre.
- Los datos de personas (usuarios, alumnos, docentes) **no se inventan**: los reales los carga cada persona registrándose en la app, o los pasa el colegio. Este paquete solo trae usuarios ficticios.

## 2. Armar el script con los datos reales

1. Hacé una **copia** de `04_DatosSQL_Grupo00.sql` y llamala `04_DatosReales.sql`. No toques el original.
2. Abrila en el editor y buscá la primera línea que empieza con `INSERT INTO especialidad` (es la **línea 148**). Todo lo anterior son el `USE iqual`, los `TRUNCATE` y los 19 catálogos fijos: **se queda**.
3. **Borrá desde esa línea 148 hasta el final del archivo.** Con eso se van los datos de ejemplo (especialidades, cursos, usuarios, objetos, ventas, etc.).
4. Al final del archivo escribí tus INSERT, **en este orden** (cada tabla depende de las anteriores): `especialidad`, `carro`, `deporte`, `franja_horaria`, `curso`, `materia`, `software`, `recursos_ct`, `recurso_software`, `oferta_deporte`, `sector`, `horario_escolar`, `horario_dia`. Los usuarios y lo demás (objetos, reservas, ventas, préstamos…) no hacen falta: se cargan desde la app.
5. Usá los mismos patrones del 04 original (todos buscan por nombre, no por número de id):

```sql
INSERT INTO especialidad (nombre_especialidad) VALUES ('Computación');
INSERT INTO carro (nombre_carro) VALUES ('C1');
INSERT INTO deporte (nombre_deporte) VALUES ('Fútbol');
INSERT INTO franja_horaria (hora_inicio, hora_fin) VALUES ('08:00', '10:00');
INSERT INTO materia (nombre_materia, codigo_materia) VALUES ('Programación', 'PRG-401');
INSERT INTO software (nombre_software) VALUES ('Qt Creator');
INSERT INTO sector (nombre_sector, id_tipo_sector) VALUES ('Laboratorio de química', (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Reservable'));
INSERT INTO recursos_ct (id_carro, numero_equipo, id_tipo_recurso, id_estado_recurso) VALUES ((SELECT id_carro FROM carro WHERE nombre_carro = 'C4'), 1, (SELECT id_tipo_recurso FROM tipo_recurso WHERE nombre_tipo = 'Computadora'), (SELECT id_estado_recurso FROM estado_recurso WHERE nombre_estado = 'Disponible'));
INSERT INTO oferta_deporte (id_deporte, id_dia, id_franja, cupo_maximo) VALUES ((SELECT id_deporte FROM deporte WHERE nombre_deporte = 'Fútbol'), (SELECT id_dia FROM dia_semana WHERE nombre_dia = 'Lunes'), (SELECT id_franja FROM franja_horaria WHERE hora_inicio = '10:00' AND hora_fin = '12:00'), 20);
```

Para `curso`, `horario_escolar`, `horario_dia` y `recurso_software` copiá la forma exacta de las líneas que ya están en el 04 original (son más largas, con subconsultas anidadas) y cambiá solo los textos entre comillas y los números. Ejemplo de `recurso_software` (todos los programas de un carro, en una sola sentencia):

```sql
INSERT INTO recurso_software (id_recurso, id_software)
SELECT r.id_recurso, s.id_software
FROM recursos_ct r JOIN carro c ON c.id_carro = r.id_carro
JOIN software s ON s.nombre_software IN ('Qt Creator', 'Visual Studio Code')
WHERE c.nombre_carro = 'C4';
```

6. Dos detalles del 04 original que conviene saber: las dos sentencias `UPDATE producto_buffet` (líneas 217–218) ajustan categorías de productos de ejemplo; si borrás los productos, también se van esas dos líneas. Y `log_auditoria` queda vacía a propósito.

## 3. Cargar en MySQL con DBeaver

1. Conectate a MySQL (root) y seleccioná la base `iqual` (clic derecho → «Set as default»). Si no existe todavía, corré primero `03_ModeloSQL_Grupo00.sql` con **Alt+X** (el 03 la crea).
2. Abrí `04_DatosReales.sql` (Archivo → Abrir archivo) y ejecutalo entero con **Alt+X**. 🔶
3. El script primero **vacía las 47 tablas** y después carga: se puede repetir las veces que haga falta, pero cada corrida borra lo que haya en la base.
4. Después corré `05_Backend_Grupo00.sql` (también con Alt+X) para crear los procedimientos, igual que en `GUIA_INSTALACION_MYSQL.md`. Es independiente de los datos.
5. Si da error, copiá el **número y el texto completo**. Los más probables: `1062 Duplicate entry` (algo repetido en tus INSERT, o corriste el script sin el TRUNCATE del principio); `1452` (una subconsulta no encontró el nombre y devolvió `NULL` → un nombre mal escrito o una tabla cargada fuera de orden); `1048 Column cannot be null` (lo mismo, visto desde la columna).

## 4. Verificar con 4 consultas

Se corren en una pestaña nueva de SQL (**Ctrl+]**) con la base `iqual` seleccionada.

**Consulta 1 — cantidad de filas por tabla:**

```sql
SELECT 'especialidad' AS tabla, COUNT(*) AS filas FROM especialidad
UNION ALL SELECT 'curso', COUNT(*) FROM curso
UNION ALL SELECT 'materia', COUNT(*) FROM materia
UNION ALL SELECT 'horario_escolar', COUNT(*) FROM horario_escolar
UNION ALL SELECT 'recursos_ct', COUNT(*) FROM recursos_ct
UNION ALL SELECT 'oferta_deporte', COUNT(*) FROM oferta_deporte
UNION ALL SELECT 'sector', COUNT(*) FROM sector;
```

Tiene que dar **la cantidad de filas que escribiste** en cada tabla (los equipos: computadoras + tableros).

**Consulta 2 — cursos y cuántas clases tiene cada uno:**

```sql
SELECT a.numero_anio AS anio, d.numero_division AS division, e.nombre_especialidad AS especialidad,
       COUNT(h.id_bloque) AS bloques
FROM curso c
JOIN anio a ON a.id_anio = c.id_anio
JOIN division d ON d.id_division = c.id_division
JOIN especialidad e ON e.id_especialidad = c.id_especialidad
LEFT JOIN horario_escolar h ON h.id_curso = c.id_curso
GROUP BY a.numero_anio, d.numero_division, e.nombre_especialidad
ORDER BY 1, 2;
```

Un curso con 0 bloques no es un error: solo no tiene horario cargado.

**Consulta 3 — equipos por carro y estado:**

```sql
SELECT COALESCE(c.nombre_carro, 'sin carro') AS carro, tr.nombre_tipo, er.nombre_estado, COUNT(*) AS equipos
FROM recursos_ct r
JOIN tipo_recurso tr ON tr.id_tipo_recurso = r.id_tipo_recurso
JOIN estado_recurso er ON er.id_estado_recurso = r.id_estado_recurso
LEFT JOIN carro c ON c.id_carro = r.id_carro
GROUP BY c.nombre_carro, tr.nombre_tipo, er.nombre_estado
ORDER BY 1, 3;
```

**Consulta 4 — ofertas de Ed. Física:**

```sql
SELECT dep.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin, o.cupo_maximo
FROM oferta_deporte o
JOIN deporte dep ON dep.id_deporte = o.id_deporte
JOIN dia_semana ds ON ds.id_dia = o.id_dia
JOIN franja_horaria f ON f.id_franja = o.id_franja
ORDER BY dep.nombre_deporte, ds.id_dia, f.hora_inicio
LIMIT 5;
```

Las consultas usan solo sintaxis común a SQLite y MySQL, pero **no se corrieron en MySQL**: si en tu servidor dan otra cosa, avisá. Además, `consultas_verificacion_mysql.sql` tiene los controles de integridad completos (son 21).

## 5. Y la app

La app elige el motor con `iqual.ini` (ver `GUIA_DRIVER_WINDOWS.md` y `GUIA_CONEXION_APP_MYSQL.md`). Si cargaste en la base `iqual`, no cambia nada. Si usaste otro nombre de base, `nombre` en `iqual.ini` tiene que ser ese. Si la app no puede conectar, cae a SQLite con un aviso, y ese SQLite es otro archivo con sus propios datos. Con estos pasos **no queda ninguna cuenta de usuario**: la primera se registra desde la app con el PIN de personal.

## Desvíos

- El flujo anterior (plantilla + CSV + `generar_sql.py`) lo di por obsoleto porque esos archivos no están en el paquete; no lo reconstruí. El reemplazo es manual (copiar el 04, cortar en la línea 148 y escribir los INSERT), más trabajoso que con CSV pero sin dependencias.
- `herramientas/generar_datos.py` **no sirve para esto**: genera los datos de ejemplo y sus fuentes (`iqual_mysql.sql`, `iqual_sqlserver.sql`) no están en el paquete, así que ni siquiera se puede volver a correr. No lo toqué.
- Para SQL Server el procedimiento es el mismo sobre `04_DatosSQL_Grupo00_sqlserver.sql` (cortar en la primera línea `INSERT INTO academico.especialidad`, que es la **línea 193** de ese archivo, y respetar los `GO`; los catálogos fijos quedan arriba); no lo probé ni lo detallé porque nada se corrió en SQL Server.
- La carga en MySQL y en DBeaver sobre Windows **no se probó**; los pasos de DBeaver son 🔶.
- No escribí datos reales: los de ejemplo siguen siendo de ejemplo.

## Datos que faltan

- [COMPLETAR: datos reales del colegio para las tablas de la sección 1 y a quién pedirlos]
- [COMPLETAR: resultado de correr `04_DatosReales.sql` en tu MySQL (versión y mensaje de error si hay)]
- [COMPLETAR: nombre de la base y puerto con los que la app tiene que conectarse (`iqual.ini`)]
