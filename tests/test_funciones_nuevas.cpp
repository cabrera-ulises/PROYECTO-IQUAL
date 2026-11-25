#include "mainwindow.h"
#include <QApplication>
#include <QMessageBox>
#include <QPushButton>
#include <QLineEdit>
#include <QListWidget>
#include <QComboBox>
#include <QTabWidget>
#include <QLabel>
#include <QTimer>
#include <QSqlQuery>
#include <QDebug>
#include <QMetaObject>
#include <QSettings>
#include <QCoreApplication>
#include <QFrame>

static QStringList mensajes;
static int fallos = 0;
static int total = 0;

static void cerrarCajas()
{
    QWidget *m = QApplication::activeModalWidget();
    QMessageBox *caja = qobject_cast<QMessageBox *>(m);
    if (!caja) return;
    mensajes << caja->text();
    QList<QAbstractButton *> botones = caja->buttons();
    for (int i = 0; i < botones.size(); i++) {
        if (botones[i]->text() == "Sí") {
            botones[i]->click();
            return;
        }
    }
    caja->accept();
}

static void check(bool cond, const QString &texto)
{
    total++;
    if (!cond) fallos++;
    qInfo().noquote() << (cond ? "PASS" : "FALLA") << texto;
}

static bool dijo(const QString &parte)
{
    for (int i = 0; i < mensajes.size(); i++) {
        if (mensajes[i].contains(parte)) return true;
    }
    return false;
}

static QString consulta(const QString &sql)
{
    QSqlQuery q;
    q.exec(sql);
    if (q.next()) return q.value(0).toString();
    return "";
}

template <typename T> static T *w(MainWindow &mw, const char *n)
{
    T *x = mw.findChild<T *>(n);
    if (!x) qFatal("no existe %s", n);
    return x;
}

static void clic(MainWindow &mw, const char *n) { w<QPushButton>(mw, n)->click(); }

static void entrar(MainWindow &mw, const QString &nick, const QString &clave)
{
    w<QLineEdit>(mw, "leUsuario")->setText(nick);
    w<QLineEdit>(mw, "leClave")->setText(clave);
    clic(mw, "btnLoginIngresar");
}

static void salir(MainWindow &mw) { QMetaObject::invokeMethod(&mw, "cerrarSesion"); }

static bool listaTiene(QListWidget *l, const QString &t)
{
    for (int i = 0; i < l->count(); i++) {
        if (l->item(i)->text().contains(t)) return true;
    }
    return false;
}

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QTimer t;
    QObject::connect(&t, &QTimer::timeout, cerrarCajas);
    t.start(30);
    QSettings cfg(QCoreApplication::applicationDirPath() + "/iqual.ini", QSettings::IniFormat);
    cfg.remove("seguridad/pin_personal");
    cfg.sync();
    MainWindow mw;

    qInfo() << "== RECUPERAR CONTRASEÑA";
    clic(mw, "btnLoginOlvide");
    check(w<QTabWidget>(mw, "tabAcceso")->currentIndex() == 2, "el botón lleva a la pestaña Recuperar");
    w<QLineEdit>(mw, "leRecUsuario")->setText("alumno1");
    w<QLineEdit>(mw, "leRecDni")->setText("11111111");
    w<QLineEdit>(mw, "leRecMail")->setText("alumno1@iqual.demo");
    w<QLineEdit>(mw, "leRecClave")->setText("nueva123");
    w<QLineEdit>(mw, "leRecClaveRepetir")->setText("nueva123");
    QString antes = consulta("SELECT password_hash FROM usuario WHERE usuario_nick = 'alumno1'");
    mensajes.clear();
    clic(mw, "btnRecuperar");
    check(dijo("no coinciden") && dijo("Intentos restantes: 4"), "DNI incorrecto: avisa y descuenta un intento");
    check(consulta("SELECT password_hash FROM usuario WHERE usuario_nick = 'alumno1'") == antes, "DNI incorrecto: no cambia la contraseña");
    check(consulta("SELECT COUNT(*) FROM log_auditoria l JOIN tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN resultado_log r ON r.id_resultado = l.id_resultado WHERE t.nombre_evento = 'Recuperación de contraseña' AND r.nombre_resultado = 'Fallido'") == "1", "DNI incorrecto: queda en la auditoría como Fallido");
    w<QLineEdit>(mw, "leRecClaveRepetir")->setText("otra");
    mensajes.clear();
    clic(mw, "btnRecuperar");
    check(dijo("no son iguales"), "contraseñas distintas: avisa");
    w<QLineEdit>(mw, "leRecClaveRepetir")->setText("nueva123");
    w<QLineEdit>(mw, "leRecClave")->setText("ab");
    w<QLineEdit>(mw, "leRecClaveRepetir")->setText("ab");
    mensajes.clear();
    clic(mw, "btnRecuperar");
    check(dijo("4 caracteres"), "contraseña corta: avisa");
    w<QLineEdit>(mw, "leRecDni")->setText("40000001");
    w<QLineEdit>(mw, "leRecMail")->setText("ALUMNO1@iqual.demo");
    w<QLineEdit>(mw, "leRecClave")->setText("nueva123");
    w<QLineEdit>(mw, "leRecClaveRepetir")->setText("nueva123");
    mensajes.clear();
    clic(mw, "btnRecuperar");
    check(dijo("Contraseña cambiada"), "datos correctos: confirma el cambio");
    check(consulta("SELECT COUNT(*) FROM log_auditoria l JOIN tipo_log t ON t.id_tipo_log = l.id_tipo_log JOIN resultado_log r ON r.id_resultado = l.id_resultado WHERE t.nombre_evento = 'Recuperación de contraseña' AND r.nombre_resultado = 'Exitoso' AND l.id_usuario = 1") == "1", "datos correctos: queda en la auditoría como Exitoso con el usuario");
    mensajes.clear();
    entrar(mw, "alumno1", "1234");
    check(dijo("incorrectos"), "la contraseña vieja ya no sirve");
    mensajes.clear();
    entrar(mw, "alumno1", "nueva123");
    check(mensajes.isEmpty() && w<QLabel>(mw, "lblCuentaId")->text() == "1", "la contraseña nueva sirve y Mi cuenta muestra el ID 1");
    salir(mw);

    qInfo() << "== APROBACIÓN DE PRODUCTOS";
    entrar(mw, "alumno1", "nueva123");
    check(!w<QTabWidget>(mw, "tabBuffet")->isTabVisible(6), "el alumno no ve la pestaña Por aprobar");
    w<QLineEdit>(mw, "leProdNombre")->setText("Brownie de prueba");
    w<QLineEdit>(mw, "leProdPrecio")->setText("900");
    w<QLineEdit>(mw, "leProdStock")->setText("12");
    w<QComboBox>(mw, "cbProdCategoria")->setCurrentIndex(1);
    mensajes.clear();
    clic(mw, "btnProdPublicar");
    check(dijo("cuando un preceptor lo apruebe"), "al publicar avisa que falta la aprobación");
    check(listaTiene(w<QListWidget>(mw, "listMisProductos"), "Brownie de prueba · $900 · stock 12") && listaTiene(w<QListWidget>(mw, "listMisProductos"), "PENDIENTE DE APROBACIÓN"), "Mis productos lo muestra como pendiente");
    check(!listaTiene(w<QListWidget>(mw, "listBuffet"), "Brownie de prueba"), "todavía no aparece en la tienda");
    w<QLineEdit>(mw, "leProdNombre")->setText("Alfajor rechazable");
    w<QLineEdit>(mw, "leProdPrecio")->setText("500");
    w<QLineEdit>(mw, "leProdStock")->setText("5");
    w<QComboBox>(mw, "cbProdCategoria")->setCurrentIndex(1);
    clic(mw, "btnProdPublicar");
    salir(mw);

    QString idBrownie = consulta("SELECT id_producto FROM producto_buffet WHERE nombre_producto = 'Brownie de prueba'");
    QSqlQuery sp;
    sp.exec(QString("CALL sp_comprar_producto('alumno2', %1, 1)").arg(idBrownie));
    sp.next();
    check(sp.value(0).toString() == "ERROR" && sp.value(2).toString().contains("no fue aprobado"), "sp_comprar_producto rechaza un producto sin aprobar");
    sp.finish();
    while (sp.nextResult()) {}

    entrar(mw, "alumno2", "1234");
    check(!listaTiene(w<QListWidget>(mw, "listBuffet"), "Brownie de prueba"), "otro alumno no lo ve en la tienda");
    salir(mw);

    entrar(mw, "preceptor1", "1234");
    check(w<QTabWidget>(mw, "tabBuffet")->isTabVisible(6), "el preceptor ve la pestaña Por aprobar");
    check(w<QTabWidget>(mw, "tabBuffet")->tabText(6) == "Por aprobar (2)", "la pestaña indica 2 pendientes");
    QListWidget *cola = w<QListWidget>(mw, "listAprobar");
    check(cola->count() == 2 && cola->item(0)->text().contains("Brownie de prueba"), "la lista tiene los 2 productos pendientes");
    mensajes.clear();
    clic(mw, "btnProdAprobar");
    check(dijo("Elegí un producto"), "aprobar sin elegir avisa");
    cola->setCurrentRow(0);
    mensajes.clear();
    clic(mw, "btnProdAprobar");
    check(dijo("Producto aprobado") && cola->count() == 1, "aprobar saca el producto de la cola");
    check(listaTiene(w<QListWidget>(mw, "listBuffet"), "Brownie de prueba"), "el aprobado aparece en la tienda");
    cola->setCurrentRow(0);
    mensajes.clear();
    clic(mw, "btnProdRechazar");
    check(dijo("¿Querés rechazar") && dijo("Producto rechazado") && cola->count() == 0, "rechazar pide confirmación y saca el producto de la cola");
    check(!listaTiene(w<QListWidget>(mw, "listBuffet"), "Alfajor rechazable"), "el rechazado no aparece en la tienda");
    check(consulta("SELECT COUNT(*) FROM log_auditoria l JOIN tipo_log t ON t.id_tipo_log = l.id_tipo_log WHERE t.nombre_evento = 'Revisión de producto' AND l.id_resultado = (SELECT id_resultado FROM resultado_log WHERE nombre_resultado = 'Exitoso')") == "2", "las dos revisiones quedaron en la auditoría");
    check(consulta("SELECT CONCAT(aprobado, '-', COALESCE(id_usuario_revisor, 'x')) FROM producto_buffet WHERE nombre_producto = 'Alfajor rechazable'") == "0-4", "el rechazado guarda aprobado 0 y el revisor");
    salir(mw);

    entrar(mw, "alumno1", "nueva123");
    check(listaTiene(w<QListWidget>(mw, "listMisProductos"), "Alfajor rechazable") && listaTiene(w<QListWidget>(mw, "listMisProductos"), "RECHAZADO"), "el alumno ve su producto como RECHAZADO");
    salir(mw);
    sp.exec(QString("CALL sp_comprar_producto('alumno2', %1, 2)").arg(idBrownie));
    sp.next();
    check(sp.value(0).toString() == "OK", "sp_comprar_producto acepta el producto ya aprobado");
    sp.finish();
    while (sp.nextResult()) {}

    qInfo() << "== ID DE USUARIO EN PRÉSTAMOS";
    entrar(mw, "preceptor1", "1234");
    QMetaObject::invokeMethod(&mw, "on_btnNavPlanillas_clicked");
    QLineEdit *id = w<QLineEdit>(mw, "lePlanillasId");
    QComboBox *alumno = w<QComboBox>(mw, "cbPlanillasAlumno");
    check(id->isVisibleTo(&mw) || !id->isHidden(), "el preceptor ve el campo ID del alumno");
    id->setText("2");
    check(alumno->currentData().toInt() == 2, "escribir 2 elige al alumno con ID 2 (" + alumno->currentText() + ")");
    id->setText("99999");
    check(alumno->currentData().toInt() == 0, "un ID que no existe vuelve a 'Elegí el alumno'");
    id->setText("abc");
    check(alumno->currentData().toInt() == 0, "un texto no numérico no elige a nadie");
    id->setText("2");
    QListWidget *eq = w<QListWidget>(mw, "listPlanillas");
    eq->setCurrentRow(0);
    int recurso = eq->currentItem()->data(Qt::UserRole).toInt();
    mensajes.clear();
    QMetaObject::invokeMethod(id, "returnPressed");
    check(dijo("Préstamo registrado"), "Enter en el ID registra el préstamo");
    check(consulta(QString("SELECT id_usuario_solicitante FROM prestamo_ct WHERE id_recurso = %1 AND hora_devolucion IS NULL").arg(recurso)) == "2", "el préstamo quedó a nombre del usuario con ID 2");
    id->setText("12345");
    mensajes.clear();
    QMetaObject::invokeMethod(id, "returnPressed");
    check(dijo("No hay ningún alumno con ese ID"), "Enter con un ID inexistente avisa");
    salir(mw);
    entrar(mw, "alumno1", "nueva123");
    check(!w<QLineEdit>(mw, "lePlanillasId")->isVisibleTo(&mw), "el alumno no ve el campo ID del alumno");
    salir(mw);


    qInfo() << "== VENCIMIENTOS AL INICIAR SESIÓN";
    check(consulta("SELECT COUNT(*) FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE e.nombre_estado = 'Reservada' AND v.fecha_hora < NOW() - INTERVAL 2 DAY") == "0", "no quedan reservas de la tienda con más de 2 días");
    check(consulta("SELECT COUNT(*) FROM log_auditoria WHERE descripcion_evento LIKE '%vencida%'") == "8", "las 8 reservas viejas de los datos de ejemplo se cancelaron y quedaron en la auditoría");
    QSqlQuery prep;
    prep.exec("SELECT stock FROM producto_buffet WHERE id_producto = 3");
    prep.next();
    int stockAntes = prep.value(0).toInt();
    prep.exec("INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES (NOW() - INTERVAL 3 DAY, 3, (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = 'Reservada'))");
    prep.exec("INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (LAST_INSERT_ID(), 3, 2, 700)");
    prep.exec("UPDATE producto_buffet SET stock = stock - 2 WHERE id_producto = 3");
    prep.exec("INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES (NOW() - INTERVAL 1 DAY, 3, (SELECT id_estado_venta FROM estado_venta WHERE nombre_estado = 'Reservada'))");
    prep.exec("INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (LAST_INSERT_ID(), 3, 1, 700)");
    prep.exec("UPDATE producto_buffet SET stock = stock - 1 WHERE id_producto = 3");
    prep.exec("INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva) VALUES (CURDATE() - INTERVAL 1 DAY, '10:00', '11:00', 3, (SELECT id_sector FROM sector WHERE id_tipo_sector = (SELECT id_tipo_sector FROM tipo_sector WHERE nombre_tipo = 'Reservable') LIMIT 1), (SELECT id_estado_reserva FROM estado_reserva WHERE nombre_estado = 'Pendiente'))");
    QString reservaVieja = consulta("SELECT MAX(id_reserva) FROM reserva_sector");
    entrar(mw, "profe1", "1234");
    check(consulta("SELECT stock FROM producto_buffet WHERE id_producto = 3").toInt() == stockAntes - 1, "la reserva de hace 3 días devolvió su stock y la de ayer lo sigue reteniendo");
    check(consulta("SELECT COUNT(*) FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE e.nombre_estado = 'Reservada' AND v.id_usuario = 3") == "1", "la reserva de ayer sigue activa");
    check(listaTiene(w<QListWidget>(mw, "listMisReservas"), "vence "), "Mis reservas muestra cuándo vence la reserva activa");
    check(consulta("SELECT CONCAT(e.nombre_estado, '-', COALESCE(r.id_usuario_autorizador, 'nadie')) FROM reserva_sector r JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = " + reservaVieja) == "Rechazada-nadie", "la reserva de sector pendiente de ayer se rechazó sola, sin autorizador");
    check(consulta("SELECT COUNT(*) FROM reserva_sector r JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva WHERE e.nombre_estado = 'Pendiente' AND r.fecha_reserva > CURDATE()") == "8", "las reservas pendientes de días que vienen no se tocan");

    qInfo() << "== RECLAMOS DE OBJETOS";
    check(!w<QFrame>(mw, "frmObjReclamo")->isHidden(), "el profesor ve el formulario para reclamar");
    QListWidget *objetos = w<QListWidget>(mw, "listObjetos");
    QString idCampera = consulta("SELECT id_objeto FROM objeto_perdido WHERE titulo = 'Campera azul'");
    for (int i = 0; i < objetos->count(); i++) {
        if (objetos->item(i)->data(Qt::UserRole).toString() == idCampera) objetos->setCurrentRow(i);
    }
    w<QLineEdit>(mw, "leObjPrueba")->setText("Es mía, tiene mis iniciales en la etiqueta");
    mensajes.clear();
    clic(mw, "btnObjReclamar");
    check(dijo("Reclamo enviado"), "el profesor puede reclamar un objeto");
    QString estadoCampera = "SELECT e.nombre_estado FROM objeto_perdido o JOIN estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto WHERE o.titulo = 'Campera azul'";
    check(consulta(estadoCampera) == "En reclamo", "el objeto pasa de Disponible a En reclamo");
    salir(mw);
    sp.exec(QString("CALL sp_reclamar_objeto('alumno2', %1, 'Es mi campera, tiene un parche en la manga')").arg(idCampera));
    sp.next();
    check(sp.value(0).toString() == "OK", "un alumno también la reclama (procedimiento)");
    sp.finish();
    while (sp.nextResult()) {}
    sp.exec(QString("CALL sp_reclamar_objeto('preceptor1', %1, 'Detalle de prueba suficientemente largo')").arg(idCampera));
    sp.next();
    check(sp.value(0).toString() == "ERROR" && sp.value(2).toString().contains("Alumno, Profesor, Maestranza"), "el preceptor no puede reclamar (procedimiento)");
    sp.finish();
    while (sp.nextResult()) {}
    entrar(mw, "preceptor1", "1234");
    check(w<QFrame>(mw, "frmObjReclamo")->isHidden(), "el preceptor no ve el formulario para reclamar");
    QListWidget *reclamos = w<QListWidget>(mw, "listReclamos");
    int filaReclamo = -1;
    for (int i = 0; i < reclamos->count(); i++) {
        if (filaReclamo < 0 && reclamos->item(i)->text().contains("Campera azul")) filaReclamo = i;
    }
    reclamos->setCurrentRow(filaReclamo);
    mensajes.clear();
    clic(mw, "btnReclamoRechazar");
    check(dijo("Reclamo rechazado") && consulta(estadoCampera) == "En reclamo", "rechazar uno de los dos reclamos deja el objeto En reclamo");
    filaReclamo = -1;
    for (int i = 0; i < reclamos->count(); i++) {
        if (filaReclamo < 0 && reclamos->item(i)->text().contains("Campera azul")) filaReclamo = i;
    }
    reclamos->setCurrentRow(filaReclamo);
    clic(mw, "btnReclamoRechazar");
    check(consulta(estadoCampera) == "Disponible", "rechazar el último reclamo pendiente lo vuelve a Disponible");

    qInfo() << "== DEVOLUCIÓN DE EQUIPOS";
    check(!w<QPushButton>(mw, "btnPlanillasDevolver")->isHidden(), "el preceptor ve el botón Devolver equipo");
    salir(mw);
    entrar(mw, "alumno1", "nueva123");
    check(w<QPushButton>(mw, "btnPlanillasDevolver")->isHidden(), "el alumno no ve el botón Devolver equipo");
    check(!w<QFrame>(mw, "frmPlanillasPrestar")->isHidden(), "el alumno sigue pudiendo pedir un equipo");
    check(w<QFrame>(mw, "tarjetaCuentaPin")->isHidden(), "el alumno no ve la tarjeta del PIN de personal");
    mensajes.clear();
    QMetaObject::invokeMethod(&mw, "on_btnPlanillasDevolver_clicked");
    check(dijo("Profesor, Preceptor"), "si el alumno intenta devolver, la app lo rechaza");
    salir(mw);
    QString prestamoAlumno1 = consulta("SELECT p.id_prestamo FROM prestamo_ct p WHERE p.id_usuario_solicitante = 1 AND p.hora_devolucion IS NULL");
    sp.exec(QString("CALL sp_devolver_equipo(%1, 'alumno1', 1, NULL)").arg(prestamoAlumno1));
    sp.next();
    check(sp.value(0).toString() == "ERROR", "sp_devolver_equipo rechaza al alumno");
    sp.finish();
    while (sp.nextResult()) {}
    sp.exec(QString("CALL sp_devolver_equipo(%1, 'profe1', 1, 'Revisado')").arg(prestamoAlumno1));
    sp.next();
    check(sp.value(0).toString() == "OK", "sp_devolver_equipo acepta al profesor");
    sp.finish();
    while (sp.nextResult()) {}

    qInfo() << "== PIN DE PERSONAL";
    check(cfg.value("seguridad/pin_personal").toString().size() == 64 && !cfg.value("seguridad/pin_personal").toString().contains("IQUAL"), "iqual.ini guarda el PIN cifrado, no el texto");
    clic(mw, "btnLandingRegister");
    QComboBox *rol = w<QComboBox>(mw, "cbRegRol");
    w<QLineEdit>(mw, "leRegNombre")->setText("Nora Prueba");
    w<QLineEdit>(mw, "leRegUsuario")->setText("nora.prueba");
    w<QLineEdit>(mw, "leRegClave")->setText("clave1");
    w<QLineEdit>(mw, "leRegDni")->setText("35123456");
    w<QLineEdit>(mw, "leRegMail")->setText("nora@iqual.demo");
    w<QLineEdit>(mw, "leRegContacto")->setText("1155550099");
    rol->setCurrentIndex(rol->findText("Profesor"));
    w<QLineEdit>(mw, "leRegPin")->setText("IQUAL2026");
    entrar(mw, "preceptor1", "1234");
    check(!w<QFrame>(mw, "tarjetaCuentaPin")->isHidden(), "el preceptor ve la tarjeta del PIN de personal");
    w<QLineEdit>(mw, "leCuentaPinNuevo")->setText("abc");
    w<QLineEdit>(mw, "leCuentaPinRepetir")->setText("abc");
    mensajes.clear();
    clic(mw, "btnCuentaPin");
    check(dijo("6 caracteres"), "un PIN corto se rechaza");
    w<QLineEdit>(mw, "leCuentaPinNuevo")->setText("Escuela-3-DE9");
    w<QLineEdit>(mw, "leCuentaPinRepetir")->setText("Escuela-3-DE9");
    mensajes.clear();
    clic(mw, "btnCuentaPin");
    check(dijo("PIN de personal cambiado"), "el preceptor cambia el PIN");
    salir(mw);
    clic(mw, "btnLandingRegister");
    w<QLineEdit>(mw, "leRegNombre")->setText("Nora Prueba");
    w<QLineEdit>(mw, "leRegUsuario")->setText("nora.prueba");
    w<QLineEdit>(mw, "leRegClave")->setText("clave1");
    w<QLineEdit>(mw, "leRegDni")->setText("35123456");
    w<QLineEdit>(mw, "leRegMail")->setText("nora@iqual.demo");
    w<QLineEdit>(mw, "leRegContacto")->setText("1155550099");
    rol->setCurrentIndex(rol->findText("Profesor"));
    w<QLineEdit>(mw, "leRegPin")->setText("IQUAL2026");
    mensajes.clear();
    clic(mw, "btnRegistrar");
    check(dijo("PIN de personal es incorrecto"), "el PIN viejo ya no sirve para crear una cuenta de personal");
    w<QLineEdit>(mw, "leRegPin")->setText("Escuela-3-DE9");
    mensajes.clear();
    clic(mw, "btnRegistrar");
    check(dijo("Cuenta creada"), "con el PIN nuevo se crea la cuenta de Profesor");

    qInfo().noquote() << QString("RESULTADO: %1 de %2 pruebas OK").arg(total - fallos).arg(total);
    return fallos;
}
