cmake_minimum_required(VERSION 3.5)
project(PRUEBAS_IQUAL LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Sql)

set(RAIZ ${CMAKE_CURRENT_SOURCE_DIR}/..)
set(CMAKE_AUTOUIC_SEARCH_PATHS ${RAIZ})
include_directories(${RAIZ})

add_executable(PRUEBAS_IQUAL
    test_funciones_nuevas.cpp
    ${RAIZ}/mainwindow.cpp
    ${RAIZ}/ventanadetalle.cpp
    ${RAIZ}/ventanaproducto.cpp
    ${RAIZ}/ventanainicio.cpp
    ${RAIZ}/mainwindow.ui
    ${RAIZ}/ventanadetalle.ui
    ${RAIZ}/ventanaproducto.ui
    ${RAIZ}/recursos.qrc
)

target_link_libraries(PRUEBAS_IQUAL PRIVATE Qt6::Widgets Qt6::Sql)
