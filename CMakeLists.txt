cmake_minimum_required(VERSION 3.5)
project(PROYECTO_IQUAL VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

add_executable(PROYECTO_IQUAL
    main.cpp
    mainwindow.cpp
    ventanadetalle.cpp
    ventanaproducto.cpp
    ventanainicio.cpp
    mainwindow.h
    ventanadetalle.h
    ventanaproducto.h
    ventanainicio.h
    mainwindow.ui
    ventanadetalle.ui
    ventanaproducto.ui
    recursos.qrc
)

target_link_libraries(PROYECTO_IQUAL PRIVATE Qt6::Widgets)

# Conexion con MySQL por la libreria de C (mysql.h), como en la clase 006 de BBDD.
# Linux: sudo apt install libmysqlclient-dev
# Windows: usa la carpeta include y lib del MySQL Server instalado (o la que se indique en MYSQL_DIR).
if(WIN32)
    if(NOT MYSQL_DIR)
        file(GLOB CARPETAS_MYSQL "C:/Program Files/MySQL/MySQL Server *")
        list(SORT CARPETAS_MYSQL)
        list(REVERSE CARPETAS_MYSQL)
        list(GET CARPETAS_MYSQL 0 MYSQL_DIR)
    endif()
    message(STATUS "MySQL para mysql.h: ${MYSQL_DIR}")
    target_include_directories(PROYECTO_IQUAL PRIVATE "${MYSQL_DIR}/include")
    target_link_libraries(PROYECTO_IQUAL PRIVATE "${MYSQL_DIR}/lib/libmysql.lib")
    file(GLOB DLLS_MYSQL "${MYSQL_DIR}/lib/libmysql.dll" "${MYSQL_DIR}/bin/libcrypto*.dll" "${MYSQL_DIR}/bin/libssl*.dll")
    foreach(DLL ${DLLS_MYSQL})
        add_custom_command(TARGET PROYECTO_IQUAL POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different "${DLL}" "$<TARGET_FILE_DIR:PROYECTO_IQUAL>")
    endforeach()
else()
    target_include_directories(PROYECTO_IQUAL PRIVATE /usr/include/mysql)
    target_link_libraries(PROYECTO_IQUAL PRIVATE mysqlclient)
endif()
