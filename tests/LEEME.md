# Prueba automática de las funciones agregadas después del Demo Day

`test_funciones_nuevas.cpp` abre la ventana principal de IQUAL, escribe en los campos, aprieta los botones y mira la pantalla y la base, igual que lo haría una persona. Cubre RF24 (recuperar contraseña), RF25 (aprobación de productos) y RF26 (ID de usuario en los préstamos): 36 comprobaciones. Los resultados están en `docs/pruebas/CASOS_PRUEBA_NUEVAS_FUNCIONES.md`.

## Cómo correrla
1. Cargar la base **desde cero** con `db/03_ModeloSQL_Grupo00.sql`, `db/04_DatosSQL_Grupo00.sql` y `db/05_Backend_Grupo00.sql`. En la consola de MySQL o MariaDB hay que usar `--default-character-set=utf8mb4`; si no, los textos con tildes se guardan mal y la auditoría falla. DBeaver ya usa UTF-8.
2. Dejar `iqual.ini` con los datos de la base (la app lo crea sola la primera vez; clave por defecto del proyecto: `12341234`).
3. Compilar y correr (en Linux, o en Windows con Qt 6 y el driver `QMYSQL`):
   ```
   cmake -S tests -B build_pruebas
   cmake --build build_pruebas
   QT_QPA_PLATFORM=offscreen ./build_pruebas/PRUEBAS_IQUAL
   ```
   En Windows no hace falta `QT_QPA_PLATFORM`.
4. La salida muestra `PASS` o `FALLA` por cada comprobación y, al final, `RESULTADO: n de n pruebas OK`.

## Importante
- **La prueba modifica la base**: cambia la contraseña de `alumno1` a `nueva123`, publica dos productos y registra un préstamo. Después de correrla hay que volver a cargar `03`, `04` y `05` para dejarla como estaba.
- Solo se puede correr una vez por carga de la base (algunas comprobaciones suponen que `alumno1` todavía tiene la contraseña `1234`).
- No reemplaza las pruebas a mano en Windows con ODBC, que son las que valen para la entrega.
