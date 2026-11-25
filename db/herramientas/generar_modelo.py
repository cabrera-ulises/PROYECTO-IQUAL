#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generar_modelo.py - PROYECTO IQUAL (SGE)

Genera 03_ModeloSQL_Grupo06.sql (MySQL) y 03_ModeloSQL_Grupo06_sqlserver.sql (SQL Server 2005) a partir de
iqual_mysql.sql e iqual_sqlserver.sql. NO cambia la estructura: las 47 tablas, claves, FK e indices salen
identicos. Solo agrega el encabezado (con el mapa de schemas), el borrado previo y, en SQL Server, los schemas.
AVISO (25/11/2026): el 03 de MySQL ya no sale de aca. Ahora crea los 7 schemas como bases (schema.tabla) y se
mantiene a mano; NO correr este script para MySQL porque lo pisaria con la version vieja de una sola base.
Usa solo la biblioteca estandar de Python 3.8 o mas nueva.

Uso:
    python generar_modelo.py
    python generar_modelo.py --mysql iqual_mysql.sql --sqlserver iqual_sqlserver.sql --salida .
"""
import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from generar_datos import SCHEMAS, SCHEMA_DE, calificar, orden_de_tablas, leer, escribir  # noqa: E402


def bloque_modelo(texto):
    """Devuelve las sentencias CREATE TABLE / CREATE INDEX tal cual estan en el script (sin comentarios ni datos)."""
    lineas = []
    activo = False
    for linea in texto.split("\n"):
        s = linea.strip()
        if s.startswith("INSERT INTO"):
            break
        if s.startswith("CREATE TABLE"):
            activo = True
        if not activo:
            continue
        if s.startswith("--") or s.upper() == "GO":
            continue
        lineas.append(linea.rstrip())
    while lineas and lineas[-1] == "":
        lineas.pop()
    return lineas


def mapa_comentario(motor):
    L = ["-- MAPA DE SCHEMAS (47 tablas, CONTEXTO_IQUAL 21):"]
    for s, ts in SCHEMAS.items():
        L.append("--   %-14s (%d) %s" % (s, len(ts), ", ".join(ts)))
    if motor == "mysql":
        L.append("-- En MySQL schema y base de datos son lo mismo. Si cada schema fuera una base, la app y las consultas tendrian que")
        L.append("-- escribir base.tabla en todos lados. Por eso aca queda UNA base (iqual), las tablas conservan su nombre y el mapa")
        L.append("-- se documenta en este comentario y en SCHEMAS.md. La version de SQL Server si crea los 7 schemas reales.")
    else:
        L.append("-- Cada tabla vive en su schema (por ejemplo seguridad.usuario). Las claves foraneas entre schemas llevan el nombre completo.")
    return L


def armar_mysql(texto, grupo):
    tablas = orden_de_tablas(texto)
    L = ["-- 03_ModeloSQL_%s.sql - PROYECTO IQUAL (SGE) - modelo de datos para MySQL 8 / MariaDB 10.11 (47 tablas en 3FN)" % grupo,
         "-- Se puede ejecutar muchas veces: borra las tablas y las vuelve a crear, vacias. Los datos van en 04_DatosSQL."] + \
        mapa_comentario("mysql")
    L += ["CREATE DATABASE IF NOT EXISTS iqual CHARACTER SET utf8mb4;", "USE iqual;", "SET FOREIGN_KEY_CHECKS = 0;"]
    for t in reversed(tablas):
        L.append("DROP TABLE IF EXISTS %s;" % t)
    L.append("SET FOREIGN_KEY_CHECKS = 1;")
    L.append("")
    L.extend(bloque_modelo(texto))
    return "\n".join(L) + "\n"


def armar_sqlserver(texto, grupo):
    tablas = orden_de_tablas(texto)
    conjunto = set(tablas)
    L = ["-- 03_ModeloSQL_%s_sqlserver.sql - PROYECTO IQUAL (SGE) - modelo de datos para SQL Server 2005 (47 tablas en 3FN, 7 schemas)" % grupo,
         "-- Se ejecuta con SSMS (los GO los entiende el cliente). Se puede repetir: borra las tablas y las vuelve a crear, vacias."] + \
        mapa_comentario("sqlserver")
    L += ["IF DB_ID('iqual') IS NULL CREATE DATABASE iqual;", "GO", "USE iqual;", "GO"]
    for s in SCHEMAS:
        L.append("IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = '%s') EXEC ('CREATE SCHEMA %s');" % (s, s))
    L.append("GO")
    L.append("-- limpieza de una carga vieja sin schemas (iqual_sqlserver.sql): si no existe, no hace nada")
    for t in reversed(tablas):
        L.append("IF OBJECT_ID('dbo.%s', 'U') IS NOT NULL DROP TABLE dbo.%s;" % (t, t))
    L.append("GO")
    for t in reversed(tablas):
        L.append("IF OBJECT_ID('%s.%s', 'U') IS NOT NULL DROP TABLE %s.%s;" % (SCHEMA_DE[t], t, SCHEMA_DE[t], t))
    L.append("GO")
    for linea in bloque_modelo(texto):
        L.append(calificar(linea, conjunto))
    L.append("GO")
    return "\n".join(L) + "\n"


def main():
    ap = argparse.ArgumentParser(description="Genera los scripts 03_ModeloSQL de IQUAL.")
    ap.add_argument("--mysql", default="iqual_mysql.sql")
    ap.add_argument("--sqlserver", default="iqual_sqlserver.sql")
    ap.add_argument("--salida", default=".")
    ap.add_argument("--grupo", default="Grupo06")
    a = ap.parse_args()
    try:
        t_mysql = leer(a.mysql)
        t_ss = leer(a.sqlserver)
    except OSError as e:
        print("Error: %s" % e)
        return 1
    escribir(os.path.join(a.salida, "03_ModeloSQL_%s.sql" % a.grupo), armar_mysql(t_mysql, a.grupo))
    escribir(os.path.join(a.salida, "03_ModeloSQL_%s_sqlserver.sql" % a.grupo), armar_sqlserver(t_ss, a.grupo))
    return 0


if __name__ == "__main__":
    sys.exit(main())
