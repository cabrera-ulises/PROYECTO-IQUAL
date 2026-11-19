#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
generar_datos.py - PROYECTO IQUAL (SGE)

Genera 04_DatosSQL_Grupo00.sql (MySQL) y 04_DatosSQL_Grupo00_sqlserver.sql (SQL Server 2005)
a partir de los scripts actuales. Es determinista: siempre produce los mismos archivos.
Usa solo la biblioteca estandar de Python 3.8 o mas nuevo (no hay que instalar nada).

Que hace
  1. Toma las filas que ya existen (catalogos y datos de ejemplo) de iqual_mysql.sql e iqual_sqlserver.sql
     y las deja IGUALES (mismos id: se cargan primero). La tabla log_auditoria no se carga: la pueblan los
     procedimientos almacenados.
  2. Agrega las filas nuevas: 57 usuarios (62 en total), 21 cursos, materias, horarios, sectores, objetos,
     reclamos, reportes, grupos, productos, ventas, donaciones, equipos, prestamos, reservas e inscripciones.
     Todos los nombres y DNI son FICTICIOS.
  3. Antes de cargar vacia las 47 tablas en orden inverso de claves foraneas, asi el script se puede
     ejecutar muchas veces.

Uso (en la carpeta donde estan los scripts):
    python generar_datos.py
    python generar_datos.py --mysql iqual_mysql.sql --sqlserver iqual_sqlserver.sql --salida .
    python generar_datos.py --sqlite iqual_sqlite.sql      (ademas arma 04_DatosSQL_prueba_sqlite.sql para probar sin servidor)
    python generar_datos.py --resumen                      (muestra cuantas filas nuevas pone en cada tabla)

Los nombres del grupo se cambian con --grupo (por defecto Grupo00).
"""
import argparse
import os
import re
import sys
import datetime

# ----------------------------------------------------------------------------- mapa de schemas (CONTEXTO 21)

SCHEMAS = {
    "seguridad": ["rol", "usuario", "log_auditoria", "tipo_log", "resultado_log", "entidad_log"],
    "academico": ["especialidad", "turno", "dia_semana", "anio", "division", "franja_horaria", "curso",
                  "materia", "horario_escolar", "horario_dia"],
    "objetos": ["categoria_objeto", "estado_objeto", "estado_reclamo", "objeto_perdido", "reclamo_objeto",
                "consulta_objeto"],
    "instalaciones": ["tipo_reporte", "estado_reporte", "estado_reserva", "tipo_sector", "sector",
                      "reporte_higiene", "reserva_sector"],
    "tienda": ["estado_venta", "categoria_producto", "grupo_buffet", "integrante_grupo", "producto_buffet",
               "venta_buffet", "detalle_venta", "donacion_buffet"],
    "equipos": ["tipo_recurso", "estado_recurso", "carro", "software", "recursos_ct", "recurso_software",
                "prestamo_ct"],
    "deportes": ["deporte", "oferta_deporte", "inscripcion_ed_fisica"],
}
SCHEMA_DE = {t: s for s, ts in SCHEMAS.items() for t in ts}


# ----------------------------------------------------------------------------- dialectos

class Dialecto(object):
    def __init__(self, nombre):
        self.nombre = nombre

    def t(self, tabla):
        if self.nombre == "sqlserver":
            return SCHEMA_DE[tabla] + "." + tabla
        return tabla

    def s(self, texto):
        if "\\" in texto:
            raise ValueError("barra invertida en un texto: " + texto)
        prefijo = "N" if self.nombre == "sqlserver" else ""
        return prefijo + "'" + texto.replace("'", "''") + "'"

    def fecha(self, iso):
        if self.nombre == "sqlserver":
            return "'" + iso.replace("-", "") + "'"
        return "'" + iso + "'"

    def fecha_hora(self, iso):
        if self.nombre == "sqlserver":
            return "'" + iso[:10].replace("-", "") + iso[10:] + "'"
        return "'" + iso + "'"

    def rel(self, n):
        if self.nombre == "mysql":
            if n == 0:
                return "CURDATE()"
            return "DATE_ADD(CURDATE(), INTERVAL %d DAY)" % n
        if self.nombre == "sqlserver":
            return "DATEADD(day, %d, DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0))" % n
        return "date('now', '%+d day')" % n

    def insertar(self, tabla, columnas, valores):
        return "INSERT INTO %s (%s) VALUES (%s);" % (self.t(tabla), ", ".join(columnas), ", ".join(valores))

    # subconsultas por nombre (los ids de catalogos nunca se escriben a mano)
    def por_nombre(self, tabla, col_id, col_nombre, valor):
        return "(SELECT %s FROM %s WHERE %s = %s)" % (col_id, self.t(tabla), col_nombre, self.s(valor))

    def usuario(self, nick):
        return self.por_nombre("usuario", "id_usuario", "usuario_nick", nick)

    def usuario_o_null(self, nick):
        if nick is None:
            return "NULL"
        return self.usuario(nick)

    def rol(self, nombre):
        return self.por_nombre("rol", "id_rol", "nombre_rol", nombre)

    def turno(self, nombre):
        return self.por_nombre("turno", "id_turno", "nombre_turno", nombre)

    def dia(self, nombre):
        return self.por_nombre("dia_semana", "id_dia", "nombre_dia", nombre)

    def materia(self, nombre):
        return self.por_nombre("materia", "id_materia", "nombre_materia", nombre)

    def sector(self, nombre):
        return self.por_nombre("sector", "id_sector", "nombre_sector", nombre)

    def tipo_sector(self, nombre):
        return self.por_nombre("tipo_sector", "id_tipo_sector", "nombre_tipo", nombre)

    def categoria_objeto(self, nombre):
        return self.por_nombre("categoria_objeto", "id_categoria_objeto", "nombre_categoria", nombre)

    def estado_objeto(self, nombre):
        return self.por_nombre("estado_objeto", "id_estado_objeto", "nombre_estado", nombre)

    def estado_reclamo(self, nombre):
        return self.por_nombre("estado_reclamo", "id_estado_reclamo", "nombre_estado", nombre)

    def tipo_reporte(self, nombre):
        return self.por_nombre("tipo_reporte", "id_tipo_reporte", "nombre_tipo", nombre)

    def estado_reporte(self, nombre):
        return self.por_nombre("estado_reporte", "id_estado_reporte", "nombre_estado", nombre)

    def estado_reserva(self, nombre):
        return self.por_nombre("estado_reserva", "id_estado_reserva", "nombre_estado", nombre)

    def estado_venta(self, nombre):
        return self.por_nombre("estado_venta", "id_estado_venta", "nombre_estado", nombre)

    def categoria_producto(self, nombre):
        return self.por_nombre("categoria_producto", "id_categoria_producto", "nombre_categoria", nombre)

    def estado_recurso(self, nombre):
        return self.por_nombre("estado_recurso", "id_estado_recurso", "nombre_estado", nombre)

    def tipo_recurso(self, nombre):
        return self.por_nombre("tipo_recurso", "id_tipo_recurso", "nombre_tipo", nombre)

    def carro(self, nombre):
        return self.por_nombre("carro", "id_carro", "nombre_carro", nombre)

    def grupo(self, nombre):
        return self.por_nombre("grupo_buffet", "id_grupo", "nombre_grupo", nombre)

    def producto(self, nombre):
        return self.por_nombre("producto_buffet", "id_producto", "nombre_producto", nombre)

    def objeto(self, titulo):
        return self.por_nombre("objeto_perdido", "id_objeto", "titulo", titulo)

    def curso(self, anio, division, especialidad):
        return ("(SELECT c.id_curso FROM %s c JOIN %s a ON a.id_anio = c.id_anio "
                "JOIN %s v ON v.id_division = c.id_division "
                "JOIN %s e ON e.id_especialidad = c.id_especialidad "
                "WHERE a.numero_anio = %d AND v.numero_division = %d AND e.nombre_especialidad = %s)"
                % (self.t("curso"), self.t("anio"), self.t("division"), self.t("especialidad"),
                   anio, division, self.s(especialidad)))

    def recurso(self, tipo, carro, numero):
        if carro is None:
            cond_carro = "id_carro IS NULL"
        else:
            cond_carro = "id_carro = " + self.carro(carro)
        return ("(SELECT id_recurso FROM %s WHERE id_tipo_recurso = %s AND %s AND numero_equipo = %d)"
                % (self.t("recursos_ct"), self.tipo_recurso(tipo), cond_carro, numero))

    def oferta(self, deporte, dia, ini, fin):
        return ("(SELECT id_oferta FROM %s WHERE id_deporte = %s AND id_dia = %s AND id_franja = "
                "(SELECT id_franja FROM %s WHERE hora_inicio = %s AND hora_fin = %s))"
                % (self.t("oferta_deporte"),
                   self.por_nombre("deporte", "id_deporte", "nombre_deporte", deporte),
                   self.dia(dia), self.t("franja_horaria"), self.s(ini), self.s(fin)))

    def venta(self, fecha_hora, nick):
        return ("(SELECT id_venta FROM %s WHERE fecha_hora = %s AND id_usuario = %s)"
                % (self.t("venta_buffet"), self.fecha_hora(fecha_hora), self.usuario(nick)))

    def bloque(self, curso, materia, ini):
        return ("(SELECT id_bloque FROM %s WHERE id_curso = %s AND id_materia = %s AND hora_inicio = %s)"
                % (self.t("horario_escolar"), self.curso(*curso), self.materia(materia), self.s(ini)))


# ----------------------------------------------------------------------------- generador pseudoaleatorio propio (determinista)

class Gen(object):
    def __init__(self, semilla):
        self.x = semilla

    def prox(self, n):
        self.x = (1103515245 * self.x + 12345) % 2147483648
        return (self.x >> 8) % n


# ----------------------------------------------------------------------------- datos de base

ESPECIALIDADES = ["Computación", "Óptica", "Geografía-Matemática"]
ABREV_ESP = {"Computación": "Computación", "Óptica": "Óptica", "Geografía-Matemática": "Geografía-Matemática"}
ORDINAL = {4: "4to", 5: "5to", 6: "6to", 7: "7mo"}
DIVISION_TXT = {1: "1ra", 2: "2da"}
DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]

NOMBRES = ["Lucía", "Mateo", "Sofía", "Benjamín", "Valentina", "Thiago", "Martina", "Santiago", "Camila", "Joaquín",
           "Julieta", "Tomás", "Agustina", "Facundo", "Micaela", "Nicolás", "Florencia", "Lautaro", "Catalina",
           "Bruno", "Milagros", "Franco", "Abril", "Ignacio", "Renata", "Dante", "Candela", "Ramiro", "Delfina",
           "Gonzalo", "Pilar", "Emiliano", "Rocío", "Federico", "Antonella", "Lisandro", "Guadalupe",
           "Maximiliano", "Belén", "Ezequiel"]
APELLIDOS = ["Gómez", "Fernández", "López", "Díaz", "Martínez", "Pérez", "Romero", "Sosa", "Álvarez", "Torres", "Ruiz",
             "Ramírez", "Flores", "Acosta", "Benítez", "Medina", "Herrera", "Suárez", "Aguirre", "Giménez",
             "Gutiérrez", "Peralta", "Rojas", "Molina", "Castro", "Ortiz", "Silva", "Núñez", "Luna", "Cabrera",
             "Ríos", "Vega", "Morales", "Domínguez", "Paz", "Sánchez", "Vera", "Ledesma", "Maldonado", "Ibarra"]

HASH_DEMO = "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"

MATERIAS_NUEVAS = [
    ("Inglés", "ING-406"), ("Sistemas Operativos", "SOP-407"), ("Redes de Datos", "RED-408"),
    ("Laboratorio de Computación", "LAB-409"), ("Ética y Ciudadanía", "ETI-410"), ("Óptica Oftálmica", "OPT-411"),
    ("Física", "FIS-412"), ("Tecnología de los Materiales", "TEM-413"), ("Dibujo Técnico", "DIB-414"),
    ("Química", "QUI-415"), ("Seguridad e Higiene", "SEH-416"), ("Geografía", "GEO-417"),
    ("Cartografía", "CAR-418"), ("Geometría Analítica", "GEA-419"), ("Historia", "HIS-420"),
    ("Economía", "ECO-421"),
]
POOL_MATERIAS = {
    "Computación": ["Programación", "Bases de Datos", "Matemática", "Lengua y Literatura", "Inglés",
                    "Sistemas Operativos", "Redes de Datos", "Laboratorio de Computación",
                    "Proyecto Informático I", "Ética y Ciudadanía"],
    "Óptica": ["Óptica Oftálmica", "Física", "Matemática", "Lengua y Literatura", "Inglés",
               "Tecnología de los Materiales", "Dibujo Técnico", "Química", "Seguridad e Higiene",
               "Ética y Ciudadanía"],
    "Geografía-Matemática": ["Geografía", "Cartografía", "Matemática", "Geometría Analítica",
                             "Lengua y Literatura", "Historia", "Economía", "Inglés", "Física",
                             "Ética y Ciudadanía"],
}

CURSOS_EXISTENTES = [(4, 1, "Computación"), (4, 2, "Computación"), (5, 2, "Óptica")]
CURSO_SIN_HORARIO = (5, 2, "Óptica")
HORARIO_EXISTENTE_4_1 = [("13:00", "14:40", ["Lunes", "Miércoles"]), ("14:50", "16:30", ["Martes", "Jueves"]),
                         ("13:00", "14:40", ["Martes", "Viernes"]), ("14:50", "16:30", ["Miércoles", "Viernes"]),
                         ("14:50", "16:30", ["Lunes"])]
SLOTS = {"Tarde": [("13:00", "14:40"), ("14:50", "16:30")], "Mañana": [("08:00", "09:40"), ("09:50", "11:30")]}
GRUPOS_DIAS = [[["Lunes", "Miércoles"], ["Martes", "Jueves"], ["Viernes"]],
               [["Martes", "Miércoles"], ["Lunes", "Viernes"], ["Jueves"]]]

SECTORES_NUEVOS = [
    ("Laboratorio de física", "Reservable"), ("Sala de informática", "Reservable"), ("Gimnasio", "Reservable"),
    ("Aula magna", "Reservable"), ("Sala de reuniones", "Reservable"), ("Taller de electrónica", "Reservable"),
    ("Taller de óptica", "Reservable"), ("Sala de profesores", "Uso común"), ("Cantina", "Uso común"),
    ("Dirección", "Uso común"), ("Secretaría", "Uso común"), ("Pasillo planta baja", "Uso común"),
    ("Pasillo planta alta", "Uso común"),
]
SECTORES_RESERVABLES = ["Laboratorio de química", "Biblioteca", "SUM", "Laboratorio de física",
                        "Sala de informática", "Gimnasio", "Aula magna", "Sala de reuniones",
                        "Taller de electrónica", "Taller de óptica"]
SECTORES_TODOS = ["Laboratorio de química", "Biblioteca", "SUM", "Baño planta baja", "Baño planta alta", "Aula",
                  "Patio", "Preceptoría", "Taller de computación"] + [s for s, _ in SECTORES_NUEVOS]

OBJETOS = [
    ("Mochila negra", "Mochila negra con un cierre roto y un parche en el frente", "Útiles", "Aula", "Disponible",
     "Adentro hay un cuaderno de Matemática con nombre"),
    ("Estuche rosa", "Estuche rosa con lapiceras y una goma con forma de frutilla", "Útiles", "Biblioteca",
     "Disponible", None),
    ("Buzo gris con capucha", "Buzo gris talle L con el cierre a medias", "Ropa", "Patio", "Devuelto",
     "La etiqueta tiene unas iniciales escritas"),
    ("Auriculares blancos", "Auriculares con cable y caja transparente", "Electrónica", "Laboratorio de física",
     "En reclamo", None),
    ("Llave de casillero 23", "Llave chica con una cinta amarilla", "Llaves", "Pasillo planta baja", "Disponible",
     None),
    ("Cargador de celular", "Cargador blanco con cable USB-C trenzado", "Electrónica", "Sala de informática",
     "Disponible", "El cable tiene una marca hecha con tinta"),
    ("Carnet de biblioteca", "Carnet de socio de una biblioteca barrial", "Documentación", "Preceptoría",
     "Archivado", None),
    ("Campera de jean", "Campera de jean con un botón de otro color", "Ropa", "SUM", "Disponible", None),
    ("Termo verde", "Termo verde oscuro de acero con una abolladura", "Otros", "Cantina", "En reclamo", None),
    ("Regla de 30 cm", "Regla transparente con inscripciones a lápiz", "Útiles", "Taller de electrónica",
     "Disponible", None),
    ("Calculadora Casio", "Calculadora científica con tapa celeste", "Útiles", "Aula", "Devuelto",
     "Atrás tiene escrito un número de lista"),
    ("Gorra azul", "Gorra azul marino sin logo", "Ropa", "Gimnasio", "Disponible", None),
    ("Pendrive 16 GB", "Pendrive negro con tapa roja", "Electrónica", "Sala de informática", "En reclamo",
     "Tiene una carpeta con trabajos de Programación"),
    ("Llaves de bicicleta", "Dos llaves chicas con un candado", "Llaves", "Patio", "Devuelto", None),
    ("Carpeta verde", "Carpeta de tres anillos con hojas de Lengua", "Útiles", "Biblioteca", "Disponible", None),
    ("Bufanda lila", "Bufanda lila tejida a mano", "Ropa", "Pasillo planta alta", "Archivado", None),
    ("Anteojos con marco negro", "Anteojos con marco negro y funda gris", "Otros", "Taller de óptica",
     "En reclamo", "En la funda hay un papelito con una graduación"),
    ("Botella azul", "Botella de plástico azul con la etiqueta de un club", "Otros", "Gimnasio", "Disponible", None),
    ("Compás metálico", "Compás con estuche de lata", "Útiles", "Taller de computación", "Devuelto", None),
    ("Tarjeta de transporte", "Tarjeta sin datos visibles", "Documentación", "Secretaría", "Disponible",
     "El número de la tarjeta quedó anotado en Secretaría"),
]
PRUEBAS = [
    "Lo reconozco por una marca que le hice con birome", "Es mía y tiene mi nombre escrito adentro",
    "Se me cayó ayer en el recreo, tiene un detalle que solo yo conozco", "Tiene una pegatina mía en un costado",
    "Se la presté a un compañero y la perdió, tiene mis iniciales", "Puedo describir lo que hay adentro",
    "La compré hace poco y tengo la foto en el celular", "Tiene el nombre de mi curso escrito con fibrón",
    "Es igual a la mía y le falta el mismo detalle", "La uso todos los días y le falta una parte",
    "Tiene mi apellido en una etiqueta interna", "Me la regaló mi hermana y tiene su dibujo",
    "Se me perdió en la clase de Educación Física", "Tiene mi número de lista anotado",
    "Tengo el ticket de compra guardado en casa", "Lo busqué por todos lados y es el único igual",
    "Puedo decir qué marca tiene y de qué color es el interior", "Tiene un pequeño rayón que le hice yo",
    "Lo dejé en el aula después de la última hora", "Reconozco el estado en el que está, es mío",
]
CONSULTAS = [
    "Perdí un cuaderno rojo de Matemática, alguien lo vio?", "Busco una campera negra que dejé en el SUM",
    "Se me perdió una llave con llavero de goma en el patio", "Alguien encontró unos auriculares negros?",
    "Perdí un estuche azul en el laboratorio de química", "Busco una botella térmica naranja del gimnasio",
    "Dejé una calculadora en el aula después de la última hora", "Se me cayó una pulsera plateada en el pasillo",
    "Perdí una remera de egresados talle S", "Busco un cargador blanco que dejé en la sala de informática",
    "Alguien vio una carpeta amarilla de Lengua?", "Perdí una gorra roja en el recreo",
    "Busco un pendrive negro de 8 GB, tiene trabajos míos", "Se me perdió una bufanda gris en la biblioteca",
    "Perdí un compás en el taller de dibujo", "Alguien encontró unas anteojos con funda verde?",
    "Busco una mochila celeste con un llavero de gato", "Dejé un termo azul en la cantina",
    "Perdí una tarjeta de transporte con una calcomanía", "Busco un buzo azul con capucha que dejé en Educación Física",
]
HIGIENE = [
    ("Rotura", "Se rompió la canilla del lavatorio del fondo"), ("Limpieza", "Falta jabón y papel higiénico"),
    ("Rotura", "La puerta del cubículo no cierra bien"), ("Limpieza", "Hay que limpiar el piso, quedó mojado"),
    ("Rotura", "Un tubo de luz titila y se apagó"), ("Limpieza", "Los tachos de basura están llenos"),
    ("Rotura", "Hay una silla con la pata floja"), ("Limpieza", "Hay manchas en las mesas del fondo"),
    ("Rotura", "El enchufe de la pared está suelto"), ("Limpieza", "Quedaron restos de comida en el piso"),
    ("Rotura", "La ventana no cierra y entra agua"), ("Limpieza", "Falta limpiar el pizarrón y las repisas"),
    ("Rotura", "El inodoro pierde agua"), ("Limpieza", "Hay que barrer las hojas del patio"),
    ("Rotura", "El perchero está desprendido de la pared"), ("Limpieza", "Falta jabón en los dispensadores"),
    ("Rotura", "El ventilador hace ruido y no gira"), ("Limpieza", "Hay papeles tirados en todo el pasillo"),
    ("Rotura", "Se despegó el zócalo cerca de la puerta"), ("Limpieza", "Los vidrios están sucios y hay que lavarlos"),
]
PRODUCTOS = [
    # nombre, precio, categoria, con grupo (True) o individual (False)
    ("Pancho con papas", 1800, "Comida", True), ("Torta casera porción", 1500, "Comida", True),
    ("Brownie", 1000, "Comida", True), ("Gaseosa 500 ml", 1200, "Bebida", True),
    ("Agua mineral", 800, "Bebida", True), ("Budín de limón", 1100, "Comida", True),
    ("Pastafrola porción", 1300, "Comida", True), ("Alfajor de maicena", 700, "Comida", True),
    ("Chipá caliente", 600, "Comida", True), ("Café con leche", 900, "Bebida", True),
    ("Muffin de chocolate", 1100, "Comida", True), ("Tostado de jamón y queso", 2200, "Comida", True),
    ("Pizza porción", 1600, "Comida", True), ("Empanada de carne", 1000, "Comida", True),
    ("Gomitas surtidas", 500, "Comida", False), ("Remera de egresados", 9500, "Ropa", False),
    ("Gorra con visera", 6000, "Ropa", False), ("Pulsera artesanal", 1500, "Accesorios", False),
    ("Funda de calculadora", 2500, "Accesorios", False), ("Cuaderno artesanal", 3000, "Otros", False),
    ("Planilla de stickers", 800, "Otros", False), ("Taza personalizada", 4500, "Accesorios", False),
    ("Pochoclo dulce", 600, "Comida", False), ("Limonada casera", 900, "Bebida", False),
    ("Buzo personalizado", 14000, "Ropa", False),
]
CARROS_NUEVOS = ["C1", "C2", "C3"]
SOFTWARE_CARRO = {"C1": ["Qt Creator", "Visual Studio Code", "Microsoft Office"],
                  "C2": ["Microsoft Office", "SQL Server 2005", "DB Browser for SQLite"],
                  "C3": ["AutoCAD", "Visual Studio Code", "Microsoft Office"]}


def sin_tildes(texto):
    tabla = {"á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u", "ü": "u", "ñ": "n", "Á": "a", "É": "e", "Í": "i",
             "Ó": "o", "Ú": "u", "Ñ": "n"}
    return "".join(tabla.get(c, c) for c in texto).lower()


def hm(texto):
    return int(texto[:2]) * 60 + int(texto[3:])


def fecha_iso(base, dias):
    d = datetime.date.fromisoformat(base) + datetime.timedelta(days=dias)
    return d.isoformat()


# ----------------------------------------------------------------------------- modelo de datos nuevos

class Modelo(object):
    pass


def construir(ofertas_existentes):
    """Arma todas las filas nuevas en estructuras de Python (no depende del motor)."""
    m = Modelo()
    g = Gen(20261114)

    # ---- usuarios
    m.usuarios = []
    cantidades = [("Alumno", 44), ("Profesor", 8), ("Preceptor", 3), ("Maestranza", 2)]
    base_dni = {"Alumno": 47000000, "Profesor": 25000000, "Preceptor": 28000000, "Maestranza": 22000000}
    i = 0
    usados = set(["alumno1", "alumno2", "profe1", "preceptor1", "maestranza1"])
    for rol, cuantos in cantidades:
        for k in range(cuantos):
            nombre = NOMBRES[i % 40]
            apellido = APELLIDOS[(i * 11 + 5 + (i // 40) * 7) % 40]
            nick = sin_tildes(nombre) + "." + sin_tildes(apellido)
            if nick in usados:
                raise ValueError("nick repetido: " + nick)
            usados.add(nick)
            m.usuarios.append({"rol": rol, "nombre": nombre + " " + apellido, "nick": nick,
                               "dni": base_dni[rol] + (k + 1) * 1013 + i * 7,
                               "email": nick + "@iqual.demo",
                               "tel": "11556%05d" % (i + 1), "curso": None})
            i += 1
    m.alumnos = [u for u in m.usuarios if u["rol"] == "Alumno"]
    m.profes = ["profe1"] + [u["nick"] for u in m.usuarios if u["rol"] == "Profesor"]
    m.preceptores = ["preceptor1"] + [u["nick"] for u in m.usuarios if u["rol"] == "Preceptor"]
    m.maestranza = ["maestranza1"] + [u["nick"] for u in m.usuarios if u["rol"] == "Maestranza"]
    m.staff = m.profes + m.preceptores
    m.todos_los_nicks = ["alumno1", "alumno2"] + [u["nick"] for u in m.alumnos] + m.staff + m.maestranza

    # ---- cursos
    todos = []
    for anio in (4, 5, 6, 7):
        for esp in ESPECIALIDADES:
            for div in (1, 2):
                todos.append((anio, div, esp))
    m.cursos_todos = todos
    m.cursos_nuevos = [c for c in todos if c not in CURSOS_EXISTENTES]
    cursos_con_horario = [c for c in todos if c != CURSO_SIN_HORARIO]
    for k, u in enumerate(m.alumnos):
        u["curso"] = cursos_con_horario[k % len(cursos_con_horario)]
    curso_de = {"alumno1": (4, 1, "Computación"), "alumno2": (5, 2, "Óptica")}
    for u in m.alumnos:
        curso_de[u["nick"]] = u["curso"]
    m.curso_de = curso_de

    # ---- materias y horarios
    m.materias = list(MATERIAS_NUEVAS)
    m.bloques = []
    m.horarios = {(4, 1, "Computación"): [(a, b, list(d)) for a, b, d in HORARIO_EXISTENTE_4_1]}
    ocupado = {}
    nro = 0
    for curso in todos:
        if curso == (4, 1, "Computación") or curso == CURSO_SIN_HORARIO:
            continue
        anio, div, esp = curso
        turno = "Tarde" if div == 1 else "Mañana"
        pool = POOL_MATERIAS[esp]
        inicio = ((anio - 4) * 2) % len(pool)
        elegidas = [pool[(inicio + k) % len(pool)] for k in range(6)]
        patron = GRUPOS_DIAS[(anio + div) % 2]
        lista = []
        k = 0
        for slot_i, (ini, fin) in enumerate(SLOTS[turno]):
            for dias in (patron if slot_i == 0 else GRUPOS_DIAS[(anio + div + 1) % 2]):
                materia = elegidas[k]
                k += 1
                docente = None
                pref = (hm(ini) + len(materia)) % len(m.profes)
                for paso in range(len(m.profes)):
                    cand = m.profes[(pref + paso) % len(m.profes)]
                    if all((cand, d, ini) not in ocupado for d in dias):
                        docente = cand
                        break
                if docente is not None:
                    for d in dias:
                        ocupado[(docente, d, ini)] = True
                lista.append((ini, fin, list(dias)))
                m.bloques.append({"curso": curso, "materia": materia, "ini": ini, "fin": fin, "turno": turno,
                                  "docente": docente, "dias": list(dias)})
        m.horarios[curso] = lista
        nro += 1

    # ---- objetos perdidos, reclamos y consultas
    m.objetos = []
    for k, (titulo, desc, cat, sec, est, det) in enumerate(OBJETOS):
        m.objetos.append({"titulo": titulo, "desc": desc, "cat": cat, "sector": sec, "estado": est, "detalle": det,
                          "fecha": fecha_iso("2026-10-05", k + (k // 3)), "nick": m.preceptores[k % len(m.preceptores)]})
    alumnos_nicks = [u["nick"] for u in m.alumnos]
    reclamos_plan = []
    for o in m.objetos:
        if o["estado"] == "En reclamo":
            reclamos_plan.append((o, "Pendiente"))
    reclamos_plan.append((m.objetos[3], "Pendiente"))
    reclamos_plan.append((m.objetos[12], "Pendiente"))
    for o in m.objetos:
        if o["estado"] == "Devuelto":
            reclamos_plan.append((o, "Aprobado"))
    reclamos_plan.append((m.objetos[2], "Rechazado"))
    reclamos_plan.append((m.objetos[10], "Rechazado"))
    for o in m.objetos:
        if o["estado"] == "Disponible":
            reclamos_plan.append((o, "Rechazado"))
    m.reclamos = []
    pares = set()
    for k, (o, est) in enumerate(reclamos_plan):
        c = alumnos_nicks[(k * 5 + 1) % len(alumnos_nicks)]
        while (c, o["titulo"]) in pares:
            c = alumnos_nicks[(alumnos_nicks.index(c) + 1) % len(alumnos_nicks)]
        pares.add((c, o["titulo"]))
        m.reclamos.append({"nick": c, "objeto": o["titulo"], "estado": est, "prueba": PRUEBAS[k % len(PRUEBAS)],
                           "fecha": fecha_iso(o["fecha"], 1 + (k % 4))})
    m.consultas = []
    for k, texto in enumerate(CONSULTAS):
        quien = alumnos_nicks[(k * 3 + 2) % len(alumnos_nicks)] if k % 5 != 4 else m.profes[k % len(m.profes)]
        m.consultas.append({"nick": quien, "texto": texto, "fecha": fecha_iso("2026-10-08", k + (k // 2))})

    # ---- higiene
    m.higiene = []
    pool_rep = alumnos_nicks + m.profes
    for k, (tipo, obs) in enumerate(HIGIENE):
        fh = "%s %02d:%02d:00" % (fecha_iso("2026-10-12", k + (k // 3)), 8 + (k * 7) % 9, (k * 13) % 60)
        reg = {"fh": fh, "obs": obs, "nick": pool_rep[(k * 7 + 3) % len(pool_rep)],
               "sector": SECTORES_TODOS[(k * 5 + 2) % len(SECTORES_TODOS)], "tipo": tipo,
               "estado": "Resuelto" if k % 5 in (0, 1, 3) else "Pendiente", "fh_res": None, "resolutor": None}
        if reg["estado"] == "Resuelto":
            t = datetime.datetime.strptime(fh, "%Y-%m-%d %H:%M:%S") + datetime.timedelta(hours=3 + k % 20)
            reg["fh_res"] = t.strftime("%Y-%m-%d %H:%M:%S")
            reg["resolutor"] = (m.maestranza + m.preceptores + m.profes)[(k * 3) % (len(m.maestranza) + len(m.preceptores) + len(m.profes))]
        m.higiene.append(reg)

    # ---- tienda
    m.grupos = []
    combos = [(a, d, e) for a in (4, 5, 6, 7) for e in ESPECIALIDADES for d in (1, 2)]
    pines = 0
    for k, (a, d, e) in enumerate(combos[:20]):
        nombre = "Viaje de Estudios %s %s %s" % (ORDINAL[a], DIVISION_TXT[d], e)
        m.grupos.append({"nombre": nombre, "pin": "%04d" % (1300 + k * 37), "meta": 40000 + 5000 * (k % 9),
                         "miembros": []})
    m.integrantes = []
    for k, gr in enumerate(m.grupos):
        elegidos = []
        paso = 0
        while len(elegidos) < 3:
            c = alumnos_nicks[(k * 2 + paso * 7) % len(alumnos_nicks)]
            if c not in elegidos:
                elegidos.append(c)
            paso += 1
        gr["miembros"] = elegidos
        for c in elegidos:
            m.integrantes.append((c, gr["nombre"]))
    m.productos = []
    for k, (nombre, precio, cat, con_grupo) in enumerate(PRODUCTOS):
        if con_grupo:
            gr = m.grupos[(k * 3 + 1) % len(m.grupos)]
            dueno = gr["miembros"][k % 3]
            grupo = gr["nombre"]
        else:
            dueno = alumnos_nicks[(k * 4 + 6) % len(alumnos_nicks)]
            grupo = None
        m.productos.append({"nombre": nombre, "precio": precio, "cat": cat, "nick": dueno, "grupo": grupo,
                            "stock0": 10 + (k * 7) % 25, "vendido": 0})
    m.ventas = []
    estados_v = ["Entregada", "Entregada", "Reservada", "Entregada", "Cancelada", "Entregada", "Reservada"]
    compradores = alumnos_nicks + m.profes + m.preceptores
    for k in range(25):
        estado = estados_v[k % len(estados_v)]
        comprador = compradores[(k * 5 + 4) % len(compradores)]
        items = []
        n_items = 1 + (k % 3 == 0)
        p_idx = (k * 7 + 2) % len(m.productos)
        while len(items) < n_items:
            p = m.productos[p_idx % len(m.productos)]
            if p["nick"] != comprador and all(i[0] is not p for i in items):
                items.append((p, 1 + (k + len(items)) % 3))
            p_idx += 1
        fh = "%s %02d:%02d:00" % (fecha_iso("2026-10-26", k // 2), 9 + (k * 3) % 8, (k * 11) % 60)
        m.ventas.append({"fh": fh, "nick": comprador, "estado": estado, "items": items})
        if estado != "Cancelada":
            for p, cant in items:
                p["vendido"] += cant
    for p in m.productos:
        p["stock"] = p["stock0"] - p["vendido"]
        if p["stock"] < 0:
            raise ValueError("stock negativo en " + p["nombre"])
    m.donaciones = []
    montos = [500, 1000, 1500, 2000, 2500, 3000, 5000]
    for k in range(25):
        gr = m.grupos[(k * 3 + 2) % len(m.grupos)]
        donante = compradores[(k * 9 + 1) % len(compradores)]
        m.donaciones.append({"monto": montos[(k * 3) % len(montos)], "nick": donante, "grupo": gr["nombre"],
                             "fh": "%s %02d:%02d:00" % (fecha_iso("2026-10-27", k // 2), 8 + (k * 5) % 10, (k * 17) % 60)})

    # ---- equipos y prestamos
    m.recursos = []
    for carro in CARROS_NUEVOS:
        for n in range(1, 11):
            if n in (1, 2):
                estado = "Prestado"
            elif n == 10:
                estado = "Fuera de servicio"
            else:
                estado = "Disponible"
            m.recursos.append({"carro": carro, "n": n, "estado": estado})
    m.prestamos = []
    solicitantes = alumnos_nicks + m.profes
    autorizadores = m.profes + m.preceptores
    k = 0

    def agregar(carro, n, fecha, ini, fin, obs):
        nonlocal k
        m.prestamos.append({"carro": carro, "n": n, "fecha": fecha, "ini": ini, "fin": fin, "obs": obs,
                            "sol": solicitantes[(k * 5 + 3) % len(solicitantes)],
                            "aut": autorizadores[(k * 3 + 1) % len(autorizadores)]})
        k += 1

    for carro in CARROS_NUEVOS:
        for n in (1, 2):
            agregar(carro, n, "2026-11-12", "%02d:%02d" % (8 + k % 8, 10 * (k % 5)), None, None)
    for carro in CARROS_NUEVOS:
        agregar(carro, 10, "2026-11-05", "09:20", "10:45", "No funciona: no enciende")
    plan_ok = [("C1", 3), ("C1", 4), ("C2", 3), ("C2", 4), ("C3", 3), ("C3", 4), ("C1", 5), ("C2", 5), ("C3", 5),
               ("C4", 1), ("C4", 2), ("C4", 3), ("C5", 1)]
    for j, (carro, n) in enumerate(plan_ok):
        ini_h = 8 + (j * 3) % 8
        fin_h = ini_h + 1
        agregar(carro, n, fecha_iso("2026-10-26", j % 12), "%02d:%02d" % (ini_h, (j * 10) % 60),
                "%02d:%02d" % (fin_h, (j * 10) % 60), "Funciona")

    # ---- reservas de sectores (fechas relativas a hoy)
    m.reservas = []
    estados_r = ["Pendiente", "Aprobada", "Aprobada", "Rechazada", "Pendiente", "Aprobada", "Cancelada"]
    franjas_r = [("08:00", "09:30"), ("09:45", "11:15"), ("11:30", "13:00"), ("14:00", "15:30")]
    solic_r = m.profes + m.preceptores + alumnos_nicks[:6]
    for k in range(24):
        estado = estados_r[k % len(estados_r)]
        ini, fin = franjas_r[(k * 3 + k // 10) % len(franjas_r)]
        m.reservas.append({"dias": 3 + k // 10, "ini": ini, "fin": fin, "nick": solic_r[(k * 5 + 2) % len(solic_r)],
                           "sector": SECTORES_RESERVABLES[k % len(SECTORES_RESERVABLES)], "estado": estado,
                           "aut": m.preceptores[k % len(m.preceptores)] if estado in ("Aprobada", "Rechazada") else None})

    # ---- inscripciones a Educacion Fisica
    cupo = {}
    for (dep, dia, ini, fin, c) in ofertas_existentes:
        cupo[(dep, dia, ini, fin)] = [c, 0]
    cupo[("Handball", "Lunes", "08:00", "10:00")][1] += 1
    m.inscripciones = []
    claves = [(dep, dia, ini, fin) for (dep, dia, ini, fin, c) in ofertas_existentes]

    def choca(curso, dia, ini, fin):
        for (bi, bf, dias) in m.horarios.get(curso, []):
            if dia in dias and hm(bi) < hm(fin) and hm(bf) > hm(ini):
                return True
        return False

    for k, u in enumerate(m.alumnos[:36]):
        elegida = None
        for paso in range(len(claves)):
            clave = claves[(k * 3 + paso) % len(claves)]
            dep, dia, ini, fin = clave
            if cupo[clave][1] < cupo[clave][0] and not choca(u["curso"], dia, ini, fin):
                elegida = clave
                break
        if elegida is None:
            raise ValueError("no hay oferta posible para " + u["nick"])
        cupo[elegida][1] += 1
        m.inscripciones.append({"nick": u["nick"], "oferta": elegida,
                                "fecha": fecha_iso("2026-10-26", k % 14)})
    return m


# ----------------------------------------------------------------------------- emision de las filas nuevas

def emitir_nuevas(d, m):
    L = []
    ins = d.insertar
    for (a, v, e) in m.cursos_nuevos:
        L.append(ins("curso", ["id_anio", "id_division", "id_especialidad"],
                     ["(SELECT id_anio FROM %s WHERE numero_anio = %d)" % (d.t("anio"), a),
                      "(SELECT id_division FROM %s WHERE numero_division = %d)" % (d.t("division"), v),
                      d.por_nombre("especialidad", "id_especialidad", "nombre_especialidad", e)]))
    for u in m.usuarios:
        curso = "NULL" if u["curso"] is None else d.curso(*u["curso"])
        L.append(ins("usuario", ["dni", "nombre_completo", "usuario_nick", "password_hash", "email",
                                 "contacto_telefono", "id_rol", "id_curso"],
                     [str(u["dni"]), d.s(u["nombre"]), d.s(u["nick"]), "'" + HASH_DEMO + "'", d.s(u["email"]),
                      d.s(u["tel"]), d.rol(u["rol"]), curso]))
    for nombre, codigo in m.materias:
        L.append(ins("materia", ["nombre_materia", "codigo_materia"], [d.s(nombre), d.s(codigo)]))
    for b in m.bloques:
        L.append(ins("horario_escolar", ["hora_inicio", "hora_fin", "id_materia", "id_curso", "id_usuario", "id_turno"],
                     [d.s(b["ini"]), d.s(b["fin"]), d.materia(b["materia"]), d.curso(*b["curso"]),
                      d.usuario_o_null(b["docente"]), d.turno(b["turno"])]))
    for b in m.bloques:
        for dia in b["dias"]:
            L.append(ins("horario_dia", ["id_bloque", "id_dia"],
                         [d.bloque(b["curso"], b["materia"], b["ini"]), d.dia(dia)]))
    for nombre, tipo in SECTORES_NUEVOS:
        L.append(ins("sector", ["nombre_sector", "id_tipo_sector"], [d.s(nombre), d.tipo_sector(tipo)]))
    for o in m.objetos:
        L.append(ins("objeto_perdido", ["titulo", "descripcion", "ruta_foto", "fecha_registro", "id_usuario",
                                        "id_categoria_objeto", "id_estado_objeto", "id_sector", "detalle_reservado"],
                     [d.s(o["titulo"]), d.s(o["desc"]), "NULL", d.fecha(o["fecha"]), d.usuario(o["nick"]),
                      d.categoria_objeto(o["cat"]), d.estado_objeto(o["estado"]), d.sector(o["sector"]),
                      "NULL" if o["detalle"] is None else d.s(o["detalle"])]))
    for r in m.reclamos:
        L.append(ins("reclamo_objeto", ["prueba_pertenencia", "fecha_reclamo", "id_usuario", "id_objeto",
                                        "id_estado_reclamo"],
                     [d.s(r["prueba"]), d.fecha(r["fecha"]), d.usuario(r["nick"]), d.objeto(r["objeto"]),
                      d.estado_reclamo(r["estado"])]))
    for c in m.consultas:
        L.append(ins("consulta_objeto", ["fecha_publicacion", "descripcion_busqueda", "id_usuario"],
                     [d.fecha(c["fecha"]), d.s(c["texto"]), d.usuario(c["nick"])]))
    for h in m.higiene:
        fh_res = "NULL" if h["fh_res"] is None else d.fecha_hora(h["fh_res"])
        L.append(ins("reporte_higiene", ["fecha_hora", "observaciones", "id_usuario", "id_sector", "id_tipo_reporte",
                                         "id_estado_reporte", "fecha_hora_resolucion", "id_usuario_resolutor"],
                     [d.fecha_hora(h["fh"]), d.s(h["obs"]), d.usuario(h["nick"]), d.sector(h["sector"]),
                      d.tipo_reporte(h["tipo"]), d.estado_reporte(h["estado"]), fh_res,
                      d.usuario_o_null(h["resolutor"])]))
    for gr in m.grupos:
        L.append(ins("grupo_buffet", ["nombre_grupo", "pin_acceso", "meta_monto"],
                     [d.s(gr["nombre"]), d.s(gr["pin"]), str(gr["meta"])]))
    for nick, grupo in m.integrantes:
        L.append(ins("integrante_grupo", ["id_usuario", "id_grupo"], [d.usuario(nick), d.grupo(grupo)]))
    for p in m.productos:
        L.append(ins("producto_buffet", ["nombre_producto", "precio", "stock", "id_usuario", "id_grupo",
                                         "id_categoria_producto", "ruta_foto"],
                     [d.s(p["nombre"]), str(p["precio"]), str(p["stock"]), d.usuario(p["nick"]),
                      "NULL" if p["grupo"] is None else d.grupo(p["grupo"]), d.categoria_producto(p["cat"]),
                      "NULL"]))
    for v in m.ventas:
        L.append(ins("venta_buffet", ["fecha_hora", "id_usuario", "id_estado_venta"],
                     [d.fecha_hora(v["fh"]), d.usuario(v["nick"]), d.estado_venta(v["estado"])]))
    for v in m.ventas:
        for p, cant in v["items"]:
            L.append(ins("detalle_venta", ["id_venta", "id_producto", "cantidad", "precio_unitario"],
                         [d.venta(v["fh"], v["nick"]), d.producto(p["nombre"]), str(cant), str(p["precio"])]))
    for x in m.donaciones:
        L.append(ins("donacion_buffet", ["monto", "fecha_hora", "id_usuario", "id_grupo"],
                     [str(x["monto"]), d.fecha_hora(x["fh"]), d.usuario(x["nick"]), d.grupo(x["grupo"])]))
    for r in m.recursos:
        L.append(ins("recursos_ct", ["id_carro", "numero_equipo", "id_tipo_recurso", "id_estado_recurso"],
                     [d.carro(r["carro"]), str(r["n"]), d.tipo_recurso("Computadora"),
                      d.estado_recurso(r["estado"])]))
    for carro in CARROS_NUEVOS:
        nombres = ", ".join(d.s(x) for x in SOFTWARE_CARRO[carro])
        L.append("INSERT INTO %s (id_recurso, id_software) SELECT r.id_recurso, s.id_software FROM %s r "
                 "JOIN %s c ON c.id_carro = r.id_carro JOIN %s s ON s.nombre_software IN (%s) "
                 "WHERE c.nombre_carro = %s;"
                 % (d.t("recurso_software"), d.t("recursos_ct"), d.t("carro"), d.t("software"), nombres, d.s(carro)))
    for p in m.prestamos:
        L.append(ins("prestamo_ct", ["fecha_prestamo", "hora_prestamo", "hora_devolucion", "observaciones",
                                     "id_usuario_solicitante", "id_usuario_autorizador", "id_recurso"],
                     [d.fecha(p["fecha"]), d.s(p["ini"]), "NULL" if p["fin"] is None else d.s(p["fin"]),
                      "NULL" if p["obs"] is None else d.s(p["obs"]), d.usuario(p["sol"]), d.usuario(p["aut"]),
                      d.recurso("Computadora", p["carro"], p["n"])]))
    for r in m.reservas:
        L.append(ins("reserva_sector", ["fecha_reserva", "hora_inicio", "hora_fin", "id_usuario", "id_sector",
                                        "id_estado_reserva", "id_usuario_autorizador"],
                     [d.rel(r["dias"]), d.s(r["ini"]), d.s(r["fin"]), d.usuario(r["nick"]), d.sector(r["sector"]),
                      d.estado_reserva(r["estado"]), d.usuario_o_null(r["aut"])]))
    for i in m.inscripciones:
        dep, dia, ini, fin = i["oferta"]
        L.append(ins("inscripcion_ed_fisica", ["fecha_inscripcion", "id_usuario", "id_oferta"],
                     [d.fecha(i["fecha"]), d.usuario(i["nick"]), d.oferta(dep, dia, ini, fin)]))
    return L


def contar_nuevas(m):
    return [("curso", len(m.cursos_nuevos)), ("usuario", len(m.usuarios)), ("materia", len(m.materias)),
            ("horario_escolar", len(m.bloques)), ("horario_dia", sum(len(b["dias"]) for b in m.bloques)),
            ("sector", len(SECTORES_NUEVOS)), ("objeto_perdido", len(m.objetos)),
            ("reclamo_objeto", len(m.reclamos)), ("consulta_objeto", len(m.consultas)),
            ("reporte_higiene", len(m.higiene)), ("grupo_buffet", len(m.grupos)),
            ("integrante_grupo", len(m.integrantes)), ("producto_buffet", len(m.productos)),
            ("venta_buffet", len(m.ventas)), ("detalle_venta", sum(len(v["items"]) for v in m.ventas)),
            ("donacion_buffet", len(m.donaciones)), ("recursos_ct", len(m.recursos)),
            ("prestamo_ct", len(m.prestamos)), ("reserva_sector", len(m.reservas)),
            ("inscripcion_ed_fisica", len(m.inscripciones))]


# ----------------------------------------------------------------------------- lectura de los scripts actuales

def leer(ruta):
    with open(ruta, encoding="utf-8") as f:
        return f.read()


def orden_de_tablas(texto):
    return re.findall(r"CREATE\s+TABLE\s+(\w+)\s*\(", texto, re.I)


def sentencias_existentes(texto):
    """Devuelve las sentencias de datos (una por linea) sin log_auditoria ni comentarios."""
    salida = []
    en_datos = False
    for linea in texto.split("\n"):
        s = linea.strip()
        if not en_datos:
            if s.startswith("INSERT INTO"):
                en_datos = True
            else:
                continue
        if s == "" or s.startswith("--") or s.upper() == "GO":
            continue
        if s.startswith("INSERT INTO log_auditoria"):
            continue
        salida.append(s)
    return salida


def ofertas_de_mysql(texto):
    patron = re.compile(r"INSERT INTO oferta_deporte .*?nombre_deporte = '([^']+)'.*?nombre_dia = '([^']+)'.*?"
                        r"hora_inicio = '(\d\d:\d\d)' AND hora_fin = '(\d\d:\d\d)'\), (\d+)\);")
    r = []
    for linea in texto.split("\n"):
        if linea.startswith("INSERT INTO oferta_deporte"):
            mm = patron.search(linea)
            if mm is None:
                raise ValueError("no pude leer la oferta: " + linea[:80])
            r.append((mm.group(1), mm.group(2), mm.group(3), mm.group(4), int(mm.group(5))))
    return r


def calificar(sql, tablas):
    """Agrega el schema a los nombres de tabla de una sentencia de SQL Server (fuera de los textos entre comillas)."""
    partes = re.split(r"(N?'(?:[^']|'')*')", sql)
    patron = re.compile(r"\b(INSERT INTO|FROM|JOIN|UPDATE|REFERENCES|ON|TABLE)\s+(\w+)\b")

    def cambio(mm):
        nombre = mm.group(2)
        if nombre in tablas:
            return mm.group(1) + " " + SCHEMA_DE[nombre] + "." + nombre
        return mm.group(0)

    for i in range(0, len(partes), 2):
        partes[i] = patron.sub(cambio, partes[i])
    return "".join(partes)


# ----------------------------------------------------------------------------- armado de los archivos 04

def encabezado(motor, grupo, resumen):
    lineas = [
        "-- 04_DatosSQL_%s%s.sql - PROYECTO IQUAL (SGE) - %s" % (grupo, "_sqlserver" if motor == "sqlserver" else "",
                                                                  "MySQL 8 / MariaDB 10.11" if motor == "mysql" else "SQL Server 2005"),
        "-- Datos de la base. Se ejecuta DESPUES de 03_ModeloSQL y se puede repetir: primero vacia las 47 tablas y despues las carga.",
        "-- Primero van las filas que ya existian (con los mismos id) y despues las filas nuevas.",
        "-- Todos los nombres, DNI, correos y telefonos de personas son FICTICIOS. La clave de demostracion de todos los usuarios es la misma.",
        "-- log_auditoria queda vacia a proposito: la pueblan los procedimientos almacenados (05_Backend) a medida que se usan.",
        "-- Generado por generar_datos.py (siempre da el mismo resultado).",
    ]
    return lineas


def armar_mysql(texto_mysql, m, grupo):
    tablas = orden_de_tablas(texto_mysql)
    d = Dialecto("mysql")
    L = encabezado("mysql", grupo, None)
    L.append("USE iqual;")
    L.append("SET FOREIGN_KEY_CHECKS = 0;")
    for t in reversed(tablas):
        L.append("TRUNCATE TABLE %s;" % t)
    L.append("SET FOREIGN_KEY_CHECKS = 1;")
    L.extend(sentencias_existentes(texto_mysql))
    L.extend(emitir_nuevas(d, m))
    return "\n".join(L) + "\n"


def armar_sqlserver(texto_ss, m, grupo):
    tablas = orden_de_tablas(texto_ss)
    con_identity = []
    for mm in re.finditer(r"CREATE\s+TABLE\s+(\w+)\s*\((.*?)\n\);", texto_ss, re.S):
        if "IDENTITY" in mm.group(2):
            con_identity.append(mm.group(1))
    d = Dialecto("sqlserver")
    L = encabezado("sqlserver", grupo, None)
    L.append("USE iqual;")
    L.append("GO")
    for t in reversed(tablas):
        L.append("DELETE FROM %s.%s;" % (SCHEMA_DE[t], t))
    L.append("GO")
    for t in con_identity:
        nombre = "%s.%s" % (SCHEMA_DE[t], t)
        L.append("IF EXISTS (SELECT 1 FROM sys.identity_columns WHERE object_id = OBJECT_ID('%s') "
                 "AND last_value IS NOT NULL) DBCC CHECKIDENT ('%s', RESEED, 0) WITH NO_INFOMSGS;" % (nombre, nombre))
    L.append("GO")
    for s in sentencias_existentes(texto_ss):
        L.append(calificar(s, set(tablas)))
    L.extend(emitir_nuevas(d, m))
    L.append("GO")
    return "\n".join(L) + "\n"


def armar_sqlite(texto_sqlite, m):
    d = Dialecto("sqlite")
    L = ["-- datos de prueba para SQLite (no es un entregable)"]
    L.extend(sentencias_existentes(texto_sqlite))
    L.extend(emitir_nuevas(d, m))
    return "\n".join(L) + "\n"


def escribir(ruta, texto):
    os.makedirs(os.path.dirname(os.path.abspath(ruta)), exist_ok=True)
    with open(ruta, "w", encoding="utf-8", newline="\n") as f:
        f.write(texto)
    print("Escribi " + ruta)


def main():
    ap = argparse.ArgumentParser(description="Genera los scripts 04_DatosSQL de IQUAL.")
    ap.add_argument("--mysql", default="iqual_mysql.sql")
    ap.add_argument("--sqlserver", default="iqual_sqlserver.sql")
    ap.add_argument("--sqlite", default=None, help="arma ademas un archivo de prueba para SQLite")
    ap.add_argument("--salida", default=".")
    ap.add_argument("--grupo", default="Grupo00")
    ap.add_argument("--resumen", action="store_true")
    a = ap.parse_args()
    try:
        t_mysql = leer(a.mysql)
        t_ss = leer(a.sqlserver)
        ofertas = ofertas_de_mysql(t_mysql)
        if len(ofertas) != 20:
            raise ValueError("se esperaban 20 ofertas de Ed. Fisica y hay %d" % len(ofertas))
        m = construir(ofertas)
    except (OSError, ValueError) as e:
        print("Error: %s" % e)
        return 1
    if a.resumen:
        print("Filas nuevas por tabla:")
        for t, n in contar_nuevas(m):
            print("  %-24s %4d" % (t, n))
    escribir(os.path.join(a.salida, "04_DatosSQL_%s.sql" % a.grupo), armar_mysql(t_mysql, m, a.grupo))
    escribir(os.path.join(a.salida, "04_DatosSQL_%s_sqlserver.sql" % a.grupo), armar_sqlserver(t_ss, m, a.grupo))
    if a.sqlite:
        escribir(os.path.join(a.salida, "04_DatosSQL_prueba_sqlite.sql"), armar_sqlite(leer(a.sqlite), m))
    return 0


if __name__ == "__main__":
    sys.exit(main())
