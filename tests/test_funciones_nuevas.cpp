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

    qInfo().noquote() << QString("RESULTADO: %1 de %2 pruebas OK").arg(total - fallos).arg(total);
    return fallos;
}
