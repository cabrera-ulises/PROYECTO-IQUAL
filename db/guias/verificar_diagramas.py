#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
verificar_diagramas.py - PROYECTO IQUAL (SGE)

Compara 03_ModeloSQL_Grupo06.sql (la fuente de verdad: tablas, columnas, claves foraneas)
contra los dos diagramas de draw.io. Usa solo la biblioteca estandar de Python 3.8+
(no hay que instalar nada). No modifica ningun archivo.

Uso (Windows, en la carpeta donde estan los archivos):
    python verificar_diagramas.py
    python verificar_diagramas.py --sql 03_ModeloSQL_Grupo06.sql --codd Proyecto_IQUAL_Edgar_Codd.xml --chen Proyecto_IQUAL_Peter_Chen.xml
    python verificar_diagramas.py --md informe_generado.md     (ademas guarda la salida en un archivo)

Que comprueba
  CODD (Edgar Codd): una tabla por cada CREATE TABLE (47); cada tabla con TODAS sus columnas,
      con la marca PK en la clave primaria y FK en las claves foraneas; un conector por cada
      clave foranea (57) uniendo la fila FK de la tabla hija con la tabla padre (o su fila PK);
      estilo de pata de gallo ERmandOne / ERmany (sin ERzeroToOne / ERzeroToMany).
  CHEN (Peter Chen): una entidad (rectangulo) por tabla, salvo las que el modelo no dibuja como
      entidad (ver REGLAS CHEN abajo); cada entidad con sus atributos propios (elipses, sin las
      claves foraneas, que se expresan con la relacion); la clave primaria subrayada; un rombo
      por cada clave foranea entre entidades; atributos multivalorados con elipse doble.

REGLAS CHEN aplicadas (regla 7 del contrato y seccion 12):
  - Catalogo con valores fijos y chicos que solo se usa para elegir (anio, division) = atributo
    MULTIVALORADO de CURSO (elipse doble): no es entidad.
  - Los demas catalogos (rol, estado_*, tipo_*, etc.) SI son entidades: tienen filas propias con
    nombre y se relacionan con otras entidades.
  - Tabla que solo resuelve una relacion N:M (horario_dia, integrante_grupo, detalle_venta,
    recurso_software) = un ROMBO con sus atributos propios, no un rectangulo.
  Si cambia la regla, se cambian los conjuntos MULTIVALORADAS y TABLAS_RELACION de aca abajo.

Codigo de salida: 0 si no hay diferencias, 1 si hay diferencias, 2 si no se pudo leer algun archivo.
"""
import argparse
import os
import re
import sys
import xml.etree.ElementTree as ET
import zlib
import base64
import urllib.parse

MULTIVALORADAS = {"anio", "division"}
TABLAS_RELACION = {"horario_dia", "integrante_grupo", "detalle_venta", "recurso_software"}

SALIDA = []


def p(texto=""):
    print(texto)
    SALIDA.append(texto)


# --------------------------------------------------------------------------- SQL

def partir_nivel0(cuerpo):
    """Parte el cuerpo de un CREATE TABLE por comas que no estan entre parentesis."""
    partes, nivel, actual = [], 0, []
    for ch in cuerpo:
        if ch == "(":
            nivel += 1
        elif ch == ")":
            nivel -= 1
        if ch == "," and nivel == 0:
            partes.append("".join(actual).strip())
            actual = []
        else:
            actual.append(ch)
    if "".join(actual).strip():
        partes.append("".join(actual).strip())
    return partes


def leer_sql(ruta):
    with open(ruta, encoding="utf-8") as f:
        texto = f.read()
    texto = re.sub(r"--[^\n]*", "", texto)
    tablas = {}
    for m in re.finditer(r"CREATE\s+TABLE\s+(?:`?\w+`?\.)?`?(\w+)`?\s*\(", texto, re.I):
        nombre = m.group(1)
        i, nivel = m.end(), 1
        while nivel > 0 and i < len(texto):
            if texto[i] == "(":
                nivel += 1
            elif texto[i] == ")":
                nivel -= 1
            i += 1
        cuerpo = texto[m.end():i - 1]
        cols, pk, fks, unicas = [], [], [], []
        for item in partir_nivel0(cuerpo):
            up = item.upper()
            if up.startswith("CONSTRAINT") or up.startswith("PRIMARY") or up.startswith("FOREIGN") \
                    or up.startswith("UNIQUE") or up.startswith("CHECK"):
                mp = re.search(r"PRIMARY\s+KEY\s*\(([^)]*)\)", item, re.I)
                if mp:
                    pk = [c.strip().strip("`") for c in mp.group(1).split(",")]
                mu = re.search(r"UNIQUE\s*\(([^)]*)\)", item, re.I)
                if mu and not up.startswith("CHECK"):
                    unicas.append([c.strip().strip("`") for c in mu.group(1).split(",")])
                mf = re.search(r"FOREIGN\s+KEY\s*\(([^)]*)\)\s*REFERENCES\s+(?:`?\w+`?\.)?`?(\w+)`?\s*\(([^)]*)\)", item, re.I)
                if mf:
                    fks.append((mf.group(1).strip().strip("`"), mf.group(2), mf.group(3).strip().strip("`")))
            else:
                cols.append(item.split()[0].strip("`"))
        tablas[nombre] = {"cols": cols, "pk": pk, "fks": fks, "unicas": unicas}
    return tablas


# --------------------------------------------------------------------------- XML

def leer_xml(ruta):
    """Devuelve el elemento <root> del diagrama (acepta XML sin comprimir o comprimido de draw.io)."""
    arbol = ET.parse(ruta)
    raiz = arbol.getroot()
    r = raiz.find(".//root")
    if r is not None:
        return r
    d = raiz.find(".//diagram")
    if d is not None and d.text and d.text.strip():
        datos = base64.b64decode(d.text.strip())
        xml = urllib.parse.unquote(zlib.decompress(datos, -15).decode("utf-8"))
        return ET.fromstring(xml).find(".//root") if ET.fromstring(xml).tag != "root" else ET.fromstring(xml)
    raise ValueError("no se encontro <root> en " + ruta)


def estilo(celda):
    d = {}
    for kv in (celda.get("style") or "").split(";"):
        if "=" in kv:
            k, v = kv.split("=", 1)
            d[k] = v
        elif kv:
            d[kv] = ""
    return d


# --------------------------------------------------------------------------- CODD

def verificar_codd(sql, ruta):
    p("=" * 78)
    p("CODD: " + os.path.basename(ruta))
    p("=" * 78)
    diffs = 0
    raiz = leer_xml(ruta)
    celdas = {c.get("id"): c for c in raiz.iter("mxCell")}
    hijos = {}
    for c in celdas.values():
        hijos.setdefault(c.get("parent"), []).append(c)

    tablas_xml = {}
    fila_de = {}  # id de fila -> (tabla, columna)
    for c in celdas.values():
        if c.get("vertex") == "1" and "shape=table" in (c.get("style") or "") and "shape=tableRow" not in (c.get("style") or ""):
            nombre = (c.get("value") or "").strip()
            cols = []
            for fila in hijos.get(c.get("id"), []):
                if "tableRow" not in (fila.get("style") or ""):
                    continue
                celdas_fila = hijos.get(fila.get("id"), [])
                valores = [(x.get("value") or "").strip() for x in celdas_fila]
                marca = valores[0] if len(valores) > 1 else ""
                col = valores[-1] if valores else ""
                cols.append((col, marca))
                fila_de[fila.get("id")] = (nombre, col)
                for x in celdas_fila:
                    fila_de[x.get("id")] = (nombre, col)
            tablas_xml[nombre] = cols
            fila_de[c.get("id")] = (nombre, None)

    esperadas, halladas = set(sql), set(tablas_xml)
    p("Tablas en el SQL: %d | tablas en el diagrama: %d" % (len(esperadas), len(halladas)))
    for t in sorted(esperadas - halladas):
        p("  FALTA tabla en el diagrama: " + t)
        diffs += 1
    for t in sorted(halladas - esperadas):
        p("  SOBRA tabla en el diagrama (no esta en el SQL): " + t)
        diffs += 1

    cols_ok = 0
    for t in sorted(esperadas & halladas):
        info = sql[t]
        xml_cols = [c for c, _ in tablas_xml[t]]
        marcas = dict(tablas_xml[t])
        problemas = []
        for c in info["cols"]:
            if c not in xml_cols:
                problemas.append("falta la columna " + c)
        for c in xml_cols:
            if c not in info["cols"]:
                problemas.append("sobra la columna " + c + " (no esta en el SQL)")
        if len(xml_cols) != len(set(xml_cols)):
            problemas.append("hay columnas repetidas")
        fkcols = {f[0] for f in info["fks"]}
        for c in info["cols"]:
            if c not in marcas:
                continue
            m = marcas[c]
            if c in info["pk"] and "PK" not in m:
                problemas.append("%s deberia decir PK y dice '%s'" % (c, m))
            if c in fkcols and c not in info["pk"] and "FK" not in m:
                problemas.append("%s deberia decir FK y dice '%s'" % (c, m))
            if c not in info["pk"] and c not in fkcols and m:
                problemas.append("%s no es clave y dice '%s'" % (c, m))
        if problemas:
            diffs += len(problemas)
            p("  %s:" % t)
            for x in problemas:
                p("    - " + x)
        else:
            cols_ok += 1
    p("Tablas con todas las columnas y marcas PK/FK correctas: %d de %d" % (cols_ok, len(esperadas & halladas)))

    # conectores
    def resolver(id_):
        actual = id_
        while actual is not None and actual not in fila_de:
            c = celdas.get(actual)
            actual = c.get("parent") if c is not None else None
        return fila_de.get(actual)

    conectores = []
    for c in celdas.values():
        if c.get("edge") == "1":
            a, b = resolver(c.get("source")), resolver(c.get("target"))
            conectores.append((a, b, c))
    fks_sql = [(t, f[0], f[1], f[2]) for t, i in sql.items() for f in i["fks"]]
    p("Claves foraneas en el SQL: %d | conectores en el diagrama: %d" % (len(fks_sql), len(conectores)))
    usados = set()
    for (t, col, pt, pcol) in fks_sql:
        hallado = None
        for k, (a, b, c) in enumerate(conectores):
            if k in usados or a is None or b is None:
                continue
            # el padre puede estar dibujado como la fila PK o como la tabla entera (es lo que hace el diagrama)
            padre_ok = lambda x: x is not None and x[0] == pt and x[1] in (None, pcol)
            if (a == (t, col) and padre_ok(b)) or (b == (t, col) and padre_ok(a)):
                hallado = k
                break
        if hallado is None:
            p("  FALTA conector: %s.%s -> %s.%s" % (t, col, pt, pcol))
            diffs += 1
        else:
            usados.add(hallado)
    for k, (a, b, c) in enumerate(conectores):
        if k not in usados:
            p("  SOBRA conector (id %s): %s -> %s" % (c.get("id"), a, b))
            diffs += 1
    malos = 0
    for a, b, c in conectores:
        st = c.get("style") or ""
        hijo = a if (a and a[1] is not None) else b
        uno_a_uno = False
        if hijo and hijo[0] in sql:
            uno_a_uno = any(u == [hijo[1]] for u in sql[hijo[0]]["unicas"])
        esperado = "endArrow=ERmandOne" if uno_a_uno else "endArrow=ERmany"
        if "ERzeroToOne" in st or "ERzeroToMany" in st:
            malos += 1
            p("  ESTILO no permitido (seccion 12) en el conector %s: usa pata de gallo con 'cero'" % c.get("id"))
        elif "startArrow=ERmandOne" not in st or esperado not in st:
            malos += 1
            p("  ESTILO distinto del esperado en el conector %s (se esperaba startArrow=ERmandOne y %s)" % (c.get("id"), esperado))
        elif uno_a_uno:
            p("  (informativo) %s.%s es UNIQUE: el conector es 1 a 1 (ERmandOne en los dos extremos)" % hijo)
    diffs += malos
    p("Resultado CODD: " + ("SIN diferencias" if diffs == 0 else "%d diferencia(s)" % diffs))
    p()
    return diffs


# --------------------------------------------------------------------------- CHEN

def verificar_chen(sql, ruta):
    p("=" * 78)
    p("CHEN: " + os.path.basename(ruta))
    p("=" * 78)
    diffs = 0
    raiz = leer_xml(ruta)
    celdas = {c.get("id"): c for c in raiz.iter("mxCell")}
    entidades, rombos, elipses, dobles, vecinos = {}, {}, {}, {}, {}
    for c in celdas.values():
        if c.get("vertex") != "1":
            continue
        st = c.get("style") or ""
        v = (c.get("value") or "").strip()
        if "rhombus" in st:
            rombos[c.get("id")] = v
        elif "doubleEllipse" in st:
            dobles[c.get("id")] = v
        elif st.startswith("ellipse") or "ellipse;" in st:
            elipses[c.get("id")] = (v, "fontStyle=4" in st, "dashed=1" in st)
        elif st.startswith("whiteSpace=wrap") and v:
            entidades[c.get("id")] = v
    for c in celdas.values():
        if c.get("edge") == "1":
            a, b = c.get("source"), c.get("target")
            if a and b:
                vecinos.setdefault(a, set()).add(b)
                vecinos.setdefault(b, set()).add(a)

    esperadas = {t for t in sql if t not in MULTIVALORADAS and t not in TABLAS_RELACION}
    nombre_de = {v.lower(): k for k, v in entidades.items()}
    p("Entidades esperadas (47 tablas - %d multivaloradas - %d relaciones N:M): %d | entidades en el diagrama: %d"
      % (len(MULTIVALORADAS), len(TABLAS_RELACION), len(esperadas), len(entidades)))
    for t in sorted(esperadas):
        if t.lower() not in nombre_de:
            p("  FALTA entidad: " + t.upper())
            diffs += 1
    for k, v in sorted(entidades.items(), key=lambda x: x[1]):
        if v.lower() not in esperadas:
            p("  SOBRA entidad (no corresponde a una tabla del SQL): " + v)
            diffs += 1

    # atributos propios de cada entidad
    def attrs_de(id_):
        return [(elipses[n][0], elipses[n][1], elipses[n][2]) for n in vecinos.get(id_, ()) if n in elipses]

    for t in sorted(esperadas):
        if t.lower() not in nombre_de:
            continue
        info = sql[t]
        fkcols = {f[0] for f in info["fks"]}
        propios = [c for c in info["cols"] if c not in fkcols]
        id_e = nombre_de[t.lower()]
        presentes = attrs_de(id_e)
        nombres = [a[0] for a in presentes]
        problemas = []
        for c in propios:
            if c not in nombres:
                problemas.append("falta el atributo " + c)
        derivados = [a[0] for a in presentes if a[2]]
        for d in derivados:
            p("  (informativo) %s: '%s' es un atributo derivado (elipse punteada), no es columna y no pasa al Codd" % (t.upper(), d))
        for a in nombres:
            if a not in propios and a not in derivados:
                problemas.append("sobra el atributo %s (no es columna propia del SQL: o es una FK o no existe)" % a)
        for nombre, subr, punt in presentes:
            if nombre in info["pk"] and not subr:
                problemas.append("la clave primaria %s deberia ir subrayada" % nombre)
            if nombre not in info["pk"] and subr:
                problemas.append("%s esta subrayado y no es clave primaria" % nombre)
        if len(nombres) != len(set(nombres)):
            problemas.append("hay atributos repetidos")
        if problemas:
            p("  %s:" % t.upper())
            for x in problemas:
                p("    - " + x)
            diffs += len(problemas)

    # multivalorados
    for t in sorted(MULTIVALORADAS):
        enlazado = any(dobles[n].lower() == t for n in dobles)
        if not enlazado:
            p("  FALTA el atributo multivalorado (elipse doble): " + t)
            diffs += 1
    for n, v in dobles.items():
        padres = [entidades[m] for m in vecinos.get(n, ()) if m in entidades]
        if "CURSO" not in padres:
            p("  El multivalorado '%s' no esta unido a CURSO" % v)
            diffs += 1

    # relaciones: una por cada clave foranea entre entidades
    def entidad_de(tabla):
        return nombre_de.get(tabla.lower())

    fks_ent = []
    for t, i in sql.items():
        if t in MULTIVALORADAS or t in TABLAS_RELACION:
            continue
        for (col, pt, pcol) in i["fks"]:
            if pt in MULTIVALORADAS:
                continue
            fks_ent.append((t, col, pt))
    # tablas N:M: un rombo unido a las entidades que referencian
    for t in sorted(TABLAS_RELACION):
        padres = sorted({f[1] for f in sql[t]["fks"]})
        p("  [N:M] %s: rombo entre %s" % (t, " y ".join(x.upper() for x in padres)))
    pares_necesarios = {}
    for (t, col, pt) in fks_ent:
        k = frozenset([t, pt]) if t != pt else frozenset([t])
        pares_necesarios[k] = pares_necesarios.get(k, 0) + 1
    for t in TABLAS_RELACION:
        for (col, pt, pcol) in sql[t]["fks"]:
            pass
    pares_rombos = {}
    for r in rombos:
        ents = {entidades[n].lower() for n in vecinos.get(r, ()) if n in entidades}
        k = frozenset(ents)
        pares_rombos[k] = pares_rombos.get(k, 0) + 1
    for k, necesarios in sorted(pares_necesarios.items(), key=lambda x: sorted(x[0])):
        hay = pares_rombos.get(frozenset(x.lower() for x in k), 0)
        if hay < necesarios:
            p("  FALTA(N) relacion entre %s: hacen falta %d rombo(s) y hay %d"
              % (" y ".join(sorted(k)).upper(), necesarios, hay))
            diffs += necesarios - hay
    for t in sorted(TABLAS_RELACION):
        padres = frozenset(f[1].lower() for f in sql[t]["fks"])
        propios = [c for c in sql[t]["cols"] if c not in sql[t]["pk"] and c not in {f[0] for f in sql[t]["fks"]}]
        hallados = set()
        for r in rombos:
            ents = {entidades[n].lower() for n in vecinos.get(r, ()) if n in entidades}
            if ents == set(padres):
                hallados |= {elipses[n][0] for n in vecinos.get(r, ()) if n in elipses}
        for c in propios:
            if c not in hallados:
                p("  FALTA el atributo %s en el rombo de la relacion N:M %s" % (c, t))
                diffs += 1
    for t in TABLAS_RELACION:
        padres = frozenset(f[1].lower() for f in sql[t]["fks"])
        if not any(frozenset(x.lower() for x in padres) == k for k in pares_rombos):
            p("  FALTA el rombo de la relacion N:M de %s entre %s" % (t, " y ".join(sorted(padres)).upper()))
            diffs += 1
    p("Claves foraneas entre entidades: %d | rombos en el diagrama: %d (incluye los %d de relaciones N:M)"
      % (len(fks_ent), len(rombos), len(TABLAS_RELACION)))
    p("Elipses (atributos): %d | elipses dobles: %d" % (len(elipses), len(dobles)))
    p("Resultado CHEN: " + ("SIN diferencias" if diffs == 0 else "%d diferencia(s)" % diffs))
    p()
    return diffs


# --------------------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description="Compara 03_ModeloSQL_Grupo06.sql con los diagramas Codd y Chen.")
    ap.add_argument("--sql", default="03_ModeloSQL_Grupo06.sql")
    ap.add_argument("--codd", default="Proyecto_IQUAL_Edgar_Codd.xml")
    ap.add_argument("--chen", default="Proyecto_IQUAL_Peter_Chen.xml")
    ap.add_argument("--md", default=None, help="guardar la salida tambien en este archivo")
    a = ap.parse_args()
    try:
        sql = leer_sql(a.sql)
    except OSError as e:
        print("No se pudo leer el SQL: %s" % e)
        return 2
    p("SQL: %s -> %d tablas, %d claves foraneas" % (a.sql, len(sql), sum(len(i["fks"]) for i in sql.values())))
    p()
    total = 0
    try:
        total += verificar_codd(sql, a.codd)
        total += verificar_chen(sql, a.chen)
    except (OSError, ET.ParseError, ValueError) as e:
        print("No se pudo leer un diagrama: %s" % e)
        return 2
    p("TOTAL: " + ("sin diferencias" if total == 0 else "%d diferencia(s)" % total))
    if a.md:
        with open(a.md, "w", encoding="utf-8") as f:
            f.write("\n".join(SALIDA) + "\n")
    return 0 if total == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
