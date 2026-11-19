# INFORME_DIAGRAMAS.md — 03_ModeloSQL_Grupo00.sql contra los diagramas Codd y Chen

Corrida del 19/11/2026 de `verificar_diagramas.py` (Python estándar, sin instalar nada) sobre los archivos de `paquete_v7.zip`: `03_ModeloSQL_Grupo00.sql` (el único script que importa: el 04 son datos), `Proyecto_IQUAL_Edgar_Codd.xml`, `Proyecto_IQUAL_Peter_Chen.xml`. Dio las mismas cifras que la corrida del 12/11 (47 tablas, 57 claves foráneas, 41 entidades, 51 rombos, 113 elipses) y código de salida 0. Cómo correrlo en Windows, parado en la carpeta con los tres archivos: `python verificar_diagramas.py` (o `py verificar_diagramas.py`). Devuelve código 0 si no hay diferencias.

**Resultado: sin diferencias reales. No hace falta entregar XML corregidos.**

## 1. Codd (Edgar Codd)

| Chequeo | SQL | Diagrama | Resultado |
|---|---|---|---|
| Tablas | 47 | 47 | Coinciden por nombre |
| Columnas de cada tabla (nombre, sin faltantes ni sobrantes) | — | — | 47 de 47 tablas completas |
| Marca `PK` en la clave primaria y `FK` en las foráneas, sin marcas de más | — | — | 47 de 47 correctas |
| Claves foráneas / conectores | 57 | 57 | Cada FK tiene su conector, sin conectores de más |
| Estilo de los conectores | — | 56 con `ERmandOne`→`ERmany`; 1 con `ERmandOne`→`ERmandOne` | Ninguno usa `ERzeroToOne` / `ERzeroToMany` (sección 12) |

Notas:
- El conector `usuario → inscripcion_ed_fisica.id_usuario` termina en `ERmandOne` porque esa FK es `UNIQUE` (un alumno, una inscripción: relación 1 a 1). No es un error; el script lo reconoce y lo informa.
- Los conectores salen de la **tabla padre entera** y llegan a la **fila FK** de la hija (no a la fila PK). El script lo acepta porque es lo que dibuja el diagrama.

## 2. Chen (Peter Chen) y la regla aplicada

El Chen no dibuja las 47 tablas como rectángulos. La regla aplicada (regla 7 del contrato y sección 12):

| Qué | Cuántas | Cómo se dibuja |
|---|---|---|
| Tablas que son entidades (incluye 22 catálogos con filas propias: `rol`, `estado_*`, `tipo_*`, etc.) | 41 | Rectángulo con sus atributos propios |
| Catálogos fijos y chicos que solo sirven para elegir: `anio`, `division` | 2 | Atributo **multivalorado** de CURSO (elipse doble) |
| Tablas que solo resuelven una N:M: `horario_dia`, `integrante_grupo`, `detalle_venta`, `recurso_software` | 4 | **Rombo** con sus atributos propios (por ejemplo `cantidad` y `precio_unitario` en la de ventas) |
| Total | 47 | |

Los atributos de una entidad son sus columnas **sin las claves foráneas** (la FK se expresa con el rombo). La clave primaria va subrayada. Los datos derivados van en elipse punteada.

| Chequeo | Esperado | Diagrama | Resultado |
|---|---|---|---|
| Entidades | 41 | 41 | Coinciden por nombre |
| Atributos propios de cada entidad, con PK subrayada | — | — | Todos presentes, sin sobrantes |
| Elipses dobles unidas a CURSO | `anio`, `division` | 2 | Correcto |
| Rombos | 47 FK entre entidades + 4 N:M = 51 | 51 | Cada par de entidades relacionado por una FK tiene al menos un rombo (los pares con dos FK, como USUARIO–PRESTAMO_CT, tienen dos) |
| Atributos de los rombos N:M | los de cada tabla | presentes | Correcto |
| Elipses totales | — | 113 (+ 2 dobles) | Informativo |

Nota: `recaudado` en GRUPO_BUFFET es una elipse punteada (dato derivado, duda D4): no es columna y no pasa al Codd; el script lo informa y no lo cuenta como error.

## 3. Qué prueba el script y qué no

- Probé que **detecta errores**: con copias donde cambié el nombre de una columna del Codd, el nombre de una entidad y de un atributo del Chen, el script marcó 23 diferencias y devolvió código 1.
- **No** verifica lo visual: que no haya cruces ni superposiciones, que no haya leyenda, que los estilos sean los vistos en clase (más allá de las patas de gallo), ni que el archivo abra bien en draw.io. En esta tanda no abrí los XML en draw.io; lo último que se miró en pantalla fue en la entrega anterior.
- El Chen se compara por **nombres** (las entidades en mayúsculas, los atributos igual que la columna). Si se renombra un atributo a mano en draw.io, el script lo marca.

## Desvíos

- El pedido describía el Chen como un diagrama que no dibuja las 24 tablas de catálogo como entidades. El diagrama vigente (y la regla 7 de `justificacion_3FN.md`) hace otra cosa: solo `anio` y `division` pasan a multivalorados y los otros 22 catálogos son entidades. Verifiqué el diagrama contra esa regla y no lo cambié. Si el profesor pide sacar todos los catálogos, hay que decidirlo y se rehace el Chen (y el script cambia el conjunto `MULTIVALORADAS`).
- El script lee el SQL de MySQL (`03_ModeloSQL_Grupo00.sql`), no el de SQL Server ni el de SQLite; el 19/11/2026 se comparó además el 03 de SQL Server contra el de MySQL y tienen las mismas 47 tablas, columnas y 57 claves foráneas (ver `REVISION_ESTATICA_SQLSERVER.md`).
- No entregué XML corregidos porque no hubo diferencias.

## Datos que faltan

- [COMPLETAR: confirmar abriendo los dos XML en draw.io que se ven bien y sin superposiciones]
- [COMPLETAR: decisión del profesor sobre los catálogos en el Chen, si la pide]
