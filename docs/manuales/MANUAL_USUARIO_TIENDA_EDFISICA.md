# Manual de usuario — Tienda de alumnos y Educación Física

**Proyecto:** PROYECTO IQUAL® · SGE · E.T. N°3 D.E.9
Este manual explica, paso a paso, cómo usar la **Tienda de alumnos** y **Educación Física**. Donde dice `[CAPTURA: capturas/…png]` va la imagen que ya existe en la carpeta de capturas; donde dice `[CAPTURA: nombre]` todavía no hay imagen y hay que sacarla. En las capturas, `_c_` es tema claro, `_o_` tema oscuro, `p5` es la Tienda y `p8` Educación Física.
Para iniciar sesión usá el usuario que te dio la escuela. Los usuarios de demostración están en el script de datos (`03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql`).

## ¿Qué ve cada rol?
| Parte | Alumno | Profesor, Preceptor y Maestranza |
|---|---|---|
| Tienda → Productos | Sí | Sí |
| Tienda → Publicar | Sí | No (no aparece) |
| Tienda → Grupos y donaciones | Sí: crea grupos, se une y dona | Ve los grupos y dona; no ve «crear grupo» ni «unirse» |
| Tienda → Mis reservas | Sí | Sí (todos pueden reservar) |
| Tienda → Mis ventas | Sí | No (no aparece) |
| Tienda → Mis productos | Sí | No (no aparece) |
| Educación Física | Sí | No (no aparece en el menú) |

---

## Parte 1 — Alumno

### 1. Entrar a la Tienda
1. Iniciá sesión con tu usuario.
2. En el menú lateral elegí **Tienda de alumnos**.
3. Arriba vas a ver seis pestañas: **Productos, Publicar, Grupos y donaciones, Mis reservas, Mis ventas** y **Mis productos**.

`[CAPTURA: capturas/alumno_c_p5_t0.png]`

### 2. Buscar y reservar un producto
1. En **Productos** podés:
   - escribir en **Buscar** parte del nombre del producto o del vendedor;
   - elegir una **Categoría** (Comida, Bebida, Accesorios, Ropa u Otros);
   - elegir en **Ver** «Productos sueltos de alumnos» o el grupo de recaudación del que querés ver los productos;
   - elegir un **Vendedor**.
2. Arriba de la lista dice cuántos productos hay (por ejemplo, «14 productos» en la vista de productos sueltos). Si no aparece ninguno, te avisa «No hay productos con esos filtros» y te sugiere probar con otra categoría o borrar la búsqueda.
3. Cada producto muestra su foto (si no tiene, un ícono de bolsa), el nombre, el precio, la categoría y el stock. Si no queda stock dice **SIN STOCK**.
4. Tocá un producto: abajo ves el precio, el vendedor y su teléfono. Con **doble clic** se abre la foto en grande.
5. Elegí la **Cantidad** (no puede pasar del stock) y tocá **Reservar**.
6. Si sale bien aparece «Reserva hecha. Coordiná la entrega en persona con el vendedor.» **La compra no se paga en la app:** la entrega y el pago se arreglan en persona con el vendedor.

Avisos que podés ver:
- «No podés reservar tus propios productos.»
- «No hay stock suficiente: quedan N unidades.»

Mientras no elijas un producto, Reservar y Cantidad están apagados.

### 3. Ver o cancelar tus reservas
1. Entrá a **Mis reservas**: ves cada reserva con su estado, el producto, la cantidad, el precio y el vendedor con su teléfono.
2. Elegí la reserva y tocá **Cancelar**.
3. La app pregunta «¿Querés cancelar tu reserva de “producto”? El stock vuelve al producto.» Tocá **Sí** para cancelar o **No** para dejarla como está.

`[CAPTURA: capturas/alumno_c_p5_t3.png]`

### 4. Publicar un producto para vender
1. Entrá a **Publicar**. A la derecha ves una vista previa.
2. Escribí el **nombre**, el **precio** y el **stock** como números enteros mayores a 0 (sin comas ni centavos).
3. Elegí la **categoría** y, en el segundo combo, «Venta individual» o un grupo del que seas integrante.
4. Si querés, tocá **Elegir foto** y elegí un archivo .png o .jpg (con **Quitar foto** la sacás).
5. Tocá **Publicar producto**. Aparece «Producto publicado.» Los compradores ven tu teléfono («Tu contacto» es el de tu cuenta).

`[CAPTURA: capturas/alumno_c_p5_t1.png]`

### 5. Entregar o cancelar lo que te reservaron
1. Entrá a **Mis ventas**: ahí ves quién reservó tus productos.
2. Cuando entregás el producto en persona, elegí la reserva y tocá **Entregar**. La venta queda como Entregada.
3. Si la reserva no va a ser, tocá **Cancelar** y confirmá con **Sí**: el stock vuelve a tu producto.

`[CAPTURA: capturas/alumno_c_p5_t4.png]`

### 6. Administrar tus productos
En **Mis productos** elegí un producto, poné las **Unidades** y tocá:
- **Reponer stock**: suma unidades.
- **Quitar stock**: resta unidades (no podés quitar más de las que hay). Sirve si algo se perdió o se rompió.
- **Eliminar producto**: lo borra, después de confirmar. No se puede si tiene reservas activas (entregalas o cancelalas antes) ni si ya tuvo ventas, porque se conserva el historial.

La foto se elige al publicar; después no se puede cambiar.

`[CAPTURA: capturas/alumno_c_p5_t5.png]`

### 7. Grupos de recaudación y donaciones
En **Grupos y donaciones**:
- **Ver un grupo:** elegilo en «Metas de los grupos». Ves la barra de avance, cuánto se recaudó de la meta y las últimas donaciones. Lo recaudado es **donaciones + ventas ya entregadas**; una reserva sin entregar todavía no suma.
- **Donar:** abajo escribí un **Monto** en pesos (entero mayor a 0) y tocá **Donar**. Aparece «¡Gracias por tu donación!»
- **Crear un grupo** («Creá una venta grupal»): nombre, **meta** en pesos y un **PIN de 4 caracteres o más**; después tocá **Crear grupo**. Pasás a ser integrante. Compartí el PIN solo con quienes quieras que se unan.
- **Unirte a un grupo:** en «Unite a un grupo con su PIN» elegí el grupo, escribí el PIN que te dio quien lo creó y tocá **Unirme**.

`[CAPTURA: capturas/alumno_c_p5_t2.png]`

### 8. Inscribirte a Educación Física
1. Entrá a **Educación Física** en el menú. Arriba ves tu estado; si todavía no te inscribiste dice «Todavía no te inscribiste.»
2. Elegí **Deporte**, **Día** y **Hora**.
   - Lo que aparece en gris no se puede elegir: «(sin clase)» es que ese deporte no tiene clase ese día u hora; «(choca con tu horario)» o «(choca con <materia>)» es que se superpone con tus clases.
   - La app te deja preseleccionada la primera opción posible. Si ninguna alcanza, las listas quedan sin elegir y te avisa que no hay clase.
3. Mirá la franja de estado: «Hay lugar. Cupos libres: X de Y.» te dice que podés inscribirte.
4. Tocá **Inscribirme**. Aparece «¡Listo! Quedaste inscripto.» y tu inscripción queda a la vista.
5. Solo podés estar inscripto a **una** opción. Si elegís otra, la franja te avisa «Ya tenés otra inscripción: cancelala para elegir esta.»
6. Para cancelar tocá **Cancelar inscripción** y confirmá con **Sí**.

`[CAPTURA: capturas/alumno_c_p8.png]`

Importante: si cambiás de curso en **Mi cuenta** y tu inscripción choca con el horario del curso nuevo, la app te avisa («…se va a cancelar. ¿Querés cambiar de curso igual?»). Con **Sí** cambia el curso y cancela la inscripción; con **No** no cambia nada y las listas de curso vuelven al curso que tenías. Si elegís el curso que ya tenés, la app dice «Ese ya es tu curso.» y no cambia nada.

`[CAPTURA: cuenta_cambio_curso_aviso]`

---

## Parte 2 — Profesor, Preceptor y Maestranza
1. **Tienda → Productos:** buscás y **reservás** igual que un alumno (sección 2 de la Parte 1).
2. **Tienda → Mis reservas:** ves y cancelás tus reservas (sección 3).
3. **Tienda → Grupos y donaciones:** ves los grupos y **donás**. No aparecen crear grupo ni unirse.
4. No ves Publicar, Mis ventas ni Mis productos, ni el módulo de Educación Física.

`[CAPTURA: capturas/preceptor_c_p5_t0.png]` · `[CAPTURA: capturas/preceptor_c_p5_t2.png]` · `[CAPTURA: capturas/preceptor_c_p5_t3.png]`

---

## Si algo no sale
| Mensaje | Qué hacer |
|---|---|
| «Elegí una reserva de la lista.» / «Elegí un producto de tu lista.» | Seleccioná una fila antes de tocar el botón. |
| «Esa reserva ya no está activa.» | Ya fue entregada o cancelada: volvé a entrar a la pestaña. |
| «El PIN no coincide. Pedíselo a quien creó el grupo.» | Pedile el PIN a quien creó el grupo. |
| «No se pudo abrir esa imagen. Probá con otro archivo .png o .jpg.» | Usá un archivo .png o .jpg. |
| «Ya tenés otra inscripción: cancelala para elegir esta.» | Cancelá la inscripción actual primero. |
| «Tiene reservas activas. Entregalas o cancelalas antes de eliminar el producto.» | Andá a Mis ventas y entregá o cancelá esas reservas. |

## Desvíos
- No incluí claves ni PIN: están en el script de datos y en `GUIA_CONEXION_APP_MYSQL.md`.
- Hay capturas para todas las pestañas de la Tienda y para Educación Física (`capturas/`); faltan las de Mi cuenta (`cuenta_cambio_curso_aviso`), la de la franja gris de Educación Física con un día «(choca con tu horario)» y la de la ventana de foto con doble clic.
- Actualizado a la app v3 (CONTEXTO §20): lo único que cambió para este manual es el cambio de curso en Mi cuenta («Ese ya es tu curso.» y el combo que vuelve al curso anterior con «No»). Las capturas que tengo son anteriores a la v3; no muestran ese cambio, y `cuenta_cambio_curso_aviso` sigue sin existir.
- Las capturas son del tema claro; en `capturas/` están también las del tema oscuro (`_o_`).

- Actualizado el 19/11/2026 a los datos de MySQL (CONTEXTO §22): el ejemplo de la sección 2 pasó de «3 productos» (juego chico de SQLite) a «14 productos»; y la sección 8 aclara que el estado de Educación Física depende de si ya te inscribiste (en MySQL, 37 de los 46 alumnos ya tienen inscripción). El resto del manual no depende de cantidades ni de nombres de ejemplo.
- Las capturas de `capturas/` se sacaron antes de ampliar los datos: las listas de Productos, Grupos y Educación Física ahora son más largas (21 grupos, 22 vendedores). Falta confirmarlo y, si hace falta, volver a sacarlas en la compu.

## Datos que faltan
- Las tres capturas que no existen (ver arriba): las saca el usuario con la app corriendo.
- Revisar si conviene repetir las capturas de Productos (`alumno_c_p5_t0.png`) y Grupos (`alumno_c_p5_t2.png`) con los datos de MySQL.
