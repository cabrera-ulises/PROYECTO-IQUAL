cmake_minimum_required(VERSION 3.5)
project(PROYECTO_IQUAL VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets Sql)

add_executable(PROYECTO_IQUAL
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    recursos.qrc
)

target_link_libraries(PROYECTO_IQUAL PRIVATE Qt6::Widgets Qt6::Sql)