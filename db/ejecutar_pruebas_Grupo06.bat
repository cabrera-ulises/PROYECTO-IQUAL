@echo off
cd /d "%~dp0"
set MYSQL=
for /d %%D in ("C:\Program Files\MySQL\MySQL Server *") do if exist "%%D\bin\mysql.exe" set MYSQL=%%D\bin\mysql.exe
if "%MYSQL%"=="" (
    echo No encontre mysql.exe en "C:\Program Files\MySQL\MySQL Server ...\bin".
    echo Abri este archivo con el Bloc de notas y escribi la ruta a mano en la linea "set MYSQL=".
    pause
    exit /b
)
echo Usando: %MYSQL%
set /p CLAVE=Clave del usuario root de MySQL: 
echo.
echo 1. Cargando 03, 04 y 05...
"%MYSQL%" -u root -p%CLAVE% --default-character-set=utf8mb4 < 03_ModeloSQL_Grupo06.sql > carga_scripts.txt 2>&1
"%MYSQL%" -u root -p%CLAVE% --default-character-set=utf8mb4 < 04_DatosSQL_Grupo06.sql >> carga_scripts.txt 2>&1
"%MYSQL%" -u root -p%CLAVE% --default-character-set=utf8mb4 < 05_Backend_Grupo06.sql >> carga_scripts.txt 2>&1
echo 2. Ejecutando los 104 casos de prueba...
"%MYSQL%" -u root -p%CLAVE% --default-character-set=utf8mb4 -n -t -v --force iqual < 06_Ejecutar_Todas_Las_Pruebas_Grupo06.sql > resultados_pruebas.txt 2>&1
echo.
echo Listo. Los resultados estan en resultados_pruebas.txt (y la carga de los scripts en carga_scripts.txt).
pause
