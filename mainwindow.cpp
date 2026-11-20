#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "ventanadetalle.h"
#include "ventanaproducto.h"
#include <QMessageBox>
#include <QSettings>
#include <QApplication>
#include <QComboBox>
#include <QPushButton>
#include <QListWidget>
#include <QListWidgetItem>
#include <QSqlQuery>
#include <QSqlError>
#include <QCryptographicHash>
#include <QDateTime>
#include <QFile>
#include <QTextStream>
#include <QFileDialog>
#include <QFileInfo>
#include <QDir>
#include <QCoreApplication>
#include <QSysInfo>
#include <QPixmap>
#include <QIcon>
#include <QBrush>
#include <QColor>
#include <QFont>
#include <QLabel>
#include <QProgressBar>
#include <QVariant>

const QString PIN_PERSONAL = "IQUAL2026";
const QString HORA_APERTURA = "07:00";
const QString HORA_CIERRE = "19:00";
const int MAX_INTENTOS = 5;
const int MAX_RESUELTOS = 20;

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , temaOscuro(false)
    , idActual(0)
    , intentosFallidos(0)
{
    ui->setupUi(this);
    ui->stackedWidget->setCurrentIndex(PAG_LANDING);
    connect(ui->btnVolverAcceso, &QPushButton::clicked, this, &MainWindow::irAlInicio);

    QPixmap logo(":/imagenes/logo_iqual.png");
    ui->lblLogo->setPixmap(logo);
    ui->lblLogoLateral->setPixmap(logo);
    ponerIcono(ui->btnMenuObjetos, ":/iconos/tarj_objetos.png", 40);
    ponerIcono(ui->btnMenuHigiene, ":/iconos/tarj_higiene.png", 40);
    ponerIcono(ui->btnMenuBuffet, ":/iconos/tarj_tienda.png", 40);
    ponerIcono(ui->btnMenuPlanillas, ":/iconos/tarj_equipos.png", 40);
    ponerIcono(ui->btnMenuSectores, ":/iconos/tarj_sectores.png", 40);
    ponerIcono(ui->btnMenuEdFisica, ":/iconos/tarj_edfisica.png", 40);
    ponerIcono(ui->btnNavInicio, ":/iconos/nav_inicio.png", 22);
    ponerIcono(ui->btnNavObjetos, ":/iconos/nav_objetos.png", 22);
    ponerIcono(ui->btnNavHigiene, ":/iconos/nav_higiene.png", 22);
    ponerIcono(ui->btnNavBuffet, ":/iconos/nav_tienda.png", 22);
    ponerIcono(ui->btnNavPlanillas, ":/iconos/nav_equipos.png", 22);
    ponerIcono(ui->btnNavSectores, ":/iconos/nav_sectores.png", 22);
    ponerIcono(ui->btnNavEdFisica, ":/iconos/nav_edfisica.png", 22);
    ponerIcono(ui->btnNavCuenta, ":/iconos/nav_cuenta.png", 22);
    ponerIcono(ui->btnNavSalir, ":/iconos/nav_salir.png", 22);

    QSettings ajustes("IQUAL", "SGE");
    aplicarTema(ajustes.value("tema", "claro").toString() == "oscuro");
    on_stackedWidget_currentChanged(PAG_LANDING);

    ui->deSectoresDia->setMinimumDate(QDate::currentDate());
    ui->deSectoresDia->setDate(QDate::currentDate());
    ui->teSectoresInicio->setTime(QTime(8, 0));
    ui->teSectoresFin->setTime(QTime(9, 0));

    if (!abrirBase()) {
        aviso("No se pudo abrir la base de datos. Revisá iqual.ini y que el servidor MySQL esté encendido.");
        ui->stackedWidget->setEnabled(false);
        return;
    }
    cargarCatalogos();
}

MainWindow::~MainWindow()
{
    delete ui;
}

bool MainWindow::abrirBase()
{
    QSettings cfg(QCoreApplication::applicationDirPath() + "/iqual.ini", QSettings::IniFormat);
    if (!cfg.contains("base/host")) cfg.setValue("base/host", "localhost");
    if (!cfg.contains("base/puerto")) cfg.setValue("base/puerto", 3306);
    if (!cfg.contains("base/usuario")) cfg.setValue("base/usuario", "root");
    if (!cfg.contains("base/clave")) cfg.setValue("base/clave", "12341234");
    if (!cfg.contains("base/nombre")) cfg.setValue("base/nombre", "iqual");
    cfg.sync();

    QString error;
    if (abrirMySql(cfg, error)) {
        QString sufijo = " · MySQL";
        if (db.driverName() == "QODBC") sufijo = " · MySQL (ODBC)";
        setWindowTitle(windowTitle() + sufijo);
        return true;
    }
    db = QSqlDatabase();
    QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
    aviso("No se pudo usar MySQL:\n" + error + "\n\nRevisá iqual.ini y que el servidor esté encendido.");
    return false;
}

int MainWindow::ultimoId(QSqlQuery &q)
{
    if (db.driverName() == "QODBC") {
        QSqlQuery u;
        if (u.exec("SELECT LAST_INSERT_ID()") && u.next()) return u.value(0).toInt();
        return 0;
    }
    return q.lastInsertId().toInt();
}

QString MainWindow::nombreDriverOdbc(QSettings &cfg)
{
    QString configurado = cfg.value("base/odbc_driver").toString().trimmed();
    if (!configurado.isEmpty()) return configurado;
#ifdef Q_OS_WIN
    QSettings registro("HKEY_LOCAL_MACHINE\\SOFTWARE\\ODBC\\ODBCINST.INI\\ODBC Drivers", QSettings::NativeFormat);
    QStringList nombres = registro.childKeys();
    for (int i = 0; i < nombres.size(); i++) {
        if (nombres[i].contains("MySQL", Qt::CaseInsensitive) && nombres[i].contains("Unicode", Qt::CaseInsensitive)) return nombres[i];
    }
    for (int i = 0; i < nombres.size(); i++) {
        if (nombres[i].contains("MySQL", Qt::CaseInsensitive)) return nombres[i];
    }
#endif
    return "MySQL ODBC 8.0 Unicode Driver";
}

bool MainWindow::abrirMySql(QSettings &cfg, QString &error)
{
    QString preferido = cfg.value("base/driver", "auto").toString().toLower();
    bool hayMysql = QSqlDatabase::isDriverAvailable("QMYSQL");
    bool hayOdbc = QSqlDatabase::isDriverAvailable("QODBC");
    bool usarOdbc = preferido == "odbc" || (preferido != "qmysql" && !hayMysql);
    if (usarOdbc && !hayOdbc) {
        error = "Qt no tiene ni el driver QMYSQL ni el QODBC (ver la guía GUIA_CONEXION_APP_MYSQL).";
        return false;
    }
    if (!usarOdbc && !hayMysql) {
        error = "Falta el driver QMYSQL de Qt (ver la guía GUIA_CONEXION_APP_MYSQL).";
        return false;
    }
    if (usarOdbc) {
        db = QSqlDatabase::addDatabase("QODBC");
        db.setDatabaseName(QString("DRIVER={%1};SERVER=%2;PORT=%3;DATABASE=%4")
                           .arg(nombreDriverOdbc(cfg)).arg(cfg.value("base/host").toString()).arg(cfg.value("base/puerto").toString())
                           .arg(cfg.value("base/nombre").toString()));
    } else {
        db = QSqlDatabase::addDatabase("QMYSQL");
        db.setHostName(cfg.value("base/host").toString());
        db.setPort(cfg.value("base/puerto").toInt());
        db.setDatabaseName(cfg.value("base/nombre").toString());
    }
    db.setUserName(cfg.value("base/usuario").toString());
    db.setPassword(cfg.value("base/clave").toString());
    if (!db.open()) {
        error = db.lastError().text();
        return false;
    }
    QSqlQuery q;
    q.exec("SET NAMES utf8mb4");
    if (!db.tables().contains("usuario")) {
        error = "La base " + cfg.value("base/nombre").toString() + " existe pero está vacía. Cargá 03_ModeloSQL_Grupo00.sql y 04_DatosSQL_Grupo00.sql desde DBeaver.";
        db.close();
        return false;
    }
    if (db.driverName() == "QODBC") {
        QSqlQuery prueba;
        prueba.prepare("SELECT COUNT(*) FROM rol WHERE nombre_rol = :nombre");
        prueba.bindValue(":nombre", "Alumno");
        if (!prueba.exec() || !prueba.next() || prueba.value(0).toInt() < 1) {
            error = "El driver ODBC no compara bien los textos (le pasa al MariaDB Connector/ODBC). Instalá MySQL Connector/ODBC o usá el driver QMYSQL.";
            db.close();
            return false;
        }
    }
    return true;
}

void MainWindow::ponerIcono(QPushButton *boton, const QString &ruta, int tamano)
{
    QPixmap imagen(ruta);
    if (imagen.isNull()) return;
    boton->setIcon(QIcon(imagen));
    boton->setIconSize(QSize(tamano, tamano));
}

void MainWindow::cargarCatalogos()
{
    cargarCombo(ui->cbRegRol, "SELECT id_rol, nombre_rol FROM rol ORDER BY id_rol", "Elegí tu rol", "");
    cargarCursoCombos(ui->cbRegAnio, ui->cbRegDivision, ui->cbRegEspecialidad);
    cargarCursoCombos(ui->cbCuentaAnio, ui->cbCuentaDivision, ui->cbCuentaEspecialidad);
    cargarCombo(ui->cbHigieneSector, "SELECT id_sector, nombre_sector FROM sector ORDER BY nombre_sector", "", "");
    cargarCombo(ui->cbHigieneTipo, "SELECT id_tipo_reporte, nombre_tipo FROM tipo_reporte ORDER BY id_tipo_reporte", "", "");
    cargarCombo(ui->cbObjCategoria, "SELECT id_categoria_objeto, nombre_categoria FROM categoria_objeto ORDER BY nombre_categoria", "Elegí una categoría", "");
    cargarCombo(ui->cbObjFiltroCategoria, "SELECT id_categoria_objeto, nombre_categoria FROM categoria_objeto ORDER BY nombre_categoria", "Todas las categorías", "");
    cargarCombo(ui->cbObjSector, "SELECT id_sector, nombre_sector FROM sector ORDER BY nombre_sector", "Elegí un sector", "");
    cargarCombo(ui->cbBuffetCategoria, "SELECT id_categoria_producto, nombre_categoria FROM categoria_producto ORDER BY id_categoria_producto", "Todas", "");
    cargarCombo(ui->cbProdCategoria, "SELECT id_categoria_producto, nombre_categoria FROM categoria_producto ORDER BY id_categoria_producto", "", "");
    cargarCombo(ui->cbEdFisicaDeporte, "SELECT id_deporte, nombre_deporte FROM deporte ORDER BY nombre_deporte", "", "");
    cargarCombo(ui->cbEdFisicaDia, "SELECT id_dia, nombre_dia FROM dia_semana ORDER BY id_dia", "", "");
    cargarCombo(ui->cbSectoresLugar, "SELECT s.id_sector, s.nombre_sector FROM sector s JOIN tipo_sector t ON t.id_tipo_sector = s.id_tipo_sector "
                                          "WHERE t.nombre_tipo = 'Reservable' ORDER BY s.nombre_sector", "", "");
    cargarCombo(ui->cbPlanillasPrograma, "SELECT id_software, nombre_software FROM software ORDER BY nombre_software", "Todos los programas", "");
    actualizarRegistro();
}

void MainWindow::cargarCursoCombos(QComboBox *anio, QComboBox *division, QComboBox *especialidad)
{
    cargarCombo(anio, "SELECT id_anio, numero_anio FROM anio ORDER BY numero_anio", "Año", "°");
    cargarCombo(division, "SELECT id_division, numero_division FROM division ORDER BY numero_division", "División", "°");
    cargarCombo(especialidad, "SELECT id_especialidad, nombre_especialidad FROM especialidad ORDER BY nombre_especialidad", "Especialidad", "");
}

void MainWindow::cargarTodo()
{
    ui->tabObjetos->setCurrentIndex(0);
    ui->tabBuffet->setCurrentIndex(0);
    aplicarPermisos();
    cargarCuenta();
    cargarResumen();
    cargarObjetos();
    cargarReclamos();
    cargarConsultas();
    cargarHigiene();
    actualizarUltimoMantenimiento();
    cargarGrupos();
    cargarBuffet();
    cargarMisReservas();
    cargarMisProductos();
    cargarMisVentas();
    cargarCombo(ui->cbPlanillasAlumno, "SELECT u.id_usuario, u.nombre_completo FROM usuario u JOIN rol r ON r.id_rol = u.id_rol "
                                       "WHERE r.nombre_rol = 'Alumno' ORDER BY u.nombre_completo", "Elegí el alumno", "");
    if (rolActual() == "Alumno") elegirPorId(ui->cbPlanillasAlumno, idActual);
    cargarPlanillas();
    cargarPrestamos();
    cargarOcupacion();
    cargarReservasSector();
    cargarEdFisica();
    cargarAuditoria();
}

void MainWindow::aplicarPermisos()
{
    QString rol = rolActual();
    bool alumno = rol == "Alumno";
    bool profesor = rol == "Profesor";
    bool preceptor = rol == "Preceptor";
    bool maestranza = rol == "Maestranza";
    bool docente = profesor || preceptor;
    bool personal = docente || maestranza;
    bool prestamos = alumno || docente;
    bool reparador = preceptor || maestranza;

    ui->btnMenuEdFisica->setVisible(alumno);
    ui->btnNavEdFisica->setVisible(alumno);

    ui->tabObjetos->setTabVisible(1, preceptor);
    ui->tabObjetos->setTabVisible(3, preceptor);
    ui->tabObjetos->setTabVisible(4, preceptor);
    habilitar(preceptor, QList<QWidget *>() << ui->btnObjArchivar);
    habilitar(alumno, QList<QWidget *>() << ui->frmObjReclamo);

    habilitar(personal, QList<QWidget *>() << ui->btnHigieneResolver);

    ui->tabBuffet->setTabVisible(1, alumno);
    ui->tabBuffet->setTabVisible(4, alumno);
    habilitar(alumno, QList<QWidget *>() << ui->lblGrupoCrearTit << ui->leGrupoNombre << ui->leGrupoMeta << ui->leGrupoPin
              << ui->btnGrupoCrear << ui->lblGrupoUnirTit << ui->cbUnirseGrupo << ui->leBuffetPin << ui->btnBuffetUnirse);
    habilitar(alumno, QList<QWidget *>() << ui->btnBuffetEntregar << ui->btnBuffetCancelarVenta
              << ui->sbProdReponer << ui->btnProdReponer << ui->btnProdQuitar << ui->btnProdEliminar);

    habilitar(prestamos, QList<QWidget *>() << ui->frmPlanillasPrestar << ui->lblPlanillasEstadoEt
              << ui->cbPlanillasEstado << ui->btnPlanillasDevolver);
    ui->cbPlanillasAlumno->setEnabled(docente);
    habilitar(reparador, QList<QWidget *>() << ui->frmPlanillasFuera);

    habilitar(docente, QList<QWidget *>() << ui->widgetSectoresReservar << ui->teSectoresInicio << ui->teSectoresFin << ui->btnSectoresReservar
              << ui->tarjetaSectoresReservas << ui->btnSectoresCancelar << ui->lblSectoresReservas << ui->listSectores);
    ui->lblSectoresAviso->setVisible(!docente);
    habilitar(preceptor, QList<QWidget *>() << ui->btnSectoresAprobar << ui->btnSectoresRechazar);

    habilitar(alumno, QList<QWidget *>() << ui->btnEdFisicaInscribir << ui->btnEdFisicaCancelar << ui->lblEdFisicaMia);

    habilitar(alumno, QList<QWidget *>() << ui->tarjetaCuentaCurso << ui->lblCuentaCambio << ui->cbCuentaAnio << ui->cbCuentaDivision
              << ui->cbCuentaEspecialidad << ui->btnCuentaGuardar << ui->lblCuentaCursoTit << ui->lblCuentaCurso);
}

void MainWindow::habilitar(bool si, QList<QWidget *> widgets)
{
    for (int i = 0; i < widgets.size(); i++) {
        widgets[i]->setEnabled(si);
        widgets[i]->setVisible(si);
    }
}

int MainWindow::idPorNombre(const QString &tabla, const QString &columnaId, const QString &columnaNombre, const QString &valor)
{
    QSqlQuery q;
    q.prepare(QString("SELECT %1 FROM %2 WHERE %3 = :valor").arg(columnaId).arg(tabla).arg(columnaNombre));
    q.bindValue(":valor", valor);
    q.exec();
    if (q.next()) return q.value(0).toInt();
    return 0;
}

int MainWindow::idEstado(const QString &tabla, const QString &nombre)
{
    return idPorNombre(tabla, "id_" + tabla, "nombre_estado", nombre);
}

QString MainWindow::valorUnico(const QString &sql, int id)
{
    QSqlQuery q;
    q.prepare(sql);
    q.bindValue(":id", id);
    q.exec();
    if (q.next()) return q.value(0).toString();
    return "";
}

QString MainWindow::valorUnicoHoy(const QString &sql, int id)
{
    QSqlQuery q;
    q.prepare(sql);
    q.bindValue(":id", id);
    q.bindValue(":hoy", valorFecha(QDate::currentDate()));
    q.exec();
    if (q.next()) return q.value(0).toString();
    return "";
}

bool MainWindow::existe(const QString &tabla, const QString &columna, const QString &valor)
{
    QSqlQuery q;
    q.prepare(QString("SELECT COUNT(*) FROM %1 WHERE %2 = :valor").arg(tabla).arg(columna));
    q.bindValue(":valor", valor);
    q.exec();
    q.next();
    return q.value(0).toInt() > 0;
}

QString MainWindow::rolActual()
{
    return valorUnico("SELECT r.nombre_rol FROM usuario u JOIN rol r ON r.id_rol = u.id_rol WHERE u.id_usuario = :id", idActual);
}

bool MainWindow::rolEs(const QString &lista)
{
    return lista.split(",").contains(rolActual());
}

bool MainWindow::exigir(const QString &roles, const QString &evento, const QString &entidad)
{
    if (rolEs(roles)) return true;
    QString quienes = roles;
    quienes.replace(",", ", ");
    fallar(evento, entidad, "Esta acción es solo para estos roles: " + quienes + ".");
    return false;
}

void MainWindow::aviso(const QString &texto)
{
    QMessageBox::warning(this, "Atención", texto);
}

void MainWindow::info(const QString &texto)
{
    QMessageBox::information(this, "Listo", texto);
}

bool MainWindow::confirmar(const QString &titulo, const QString &pregunta)
{
    QMessageBox caja(this);
    caja.setIcon(QMessageBox::Question);
    caja.setWindowTitle(titulo);
    caja.setText(pregunta);
    QPushButton *si = caja.addButton("Sí", QMessageBox::YesRole);
    QPushButton *no = caja.addButton("No", QMessageBox::NoRole);
    caja.setDefaultButton(no);
    caja.exec();
    return caja.clickedButton() == si;
}

void MainWindow::fallar(const QString &evento, const QString &entidad, const QString &mensaje)
{
    aviso(mensaje);
    if (evento.isEmpty()) return;
    registrarLog(evento, mensaje, entidad, "Fallido");
}

void MainWindow::registrarLog(const QString &evento, const QString &descripcion, const QString &entidad, const QString &resultado)
{
    QVariant usuario;
    if (idActual > 0) usuario = idActual;
    QVariant nick;
    if (idActual > 0) {
        QSqlQuery qn;
        qn.prepare("SELECT usuario_nick FROM usuario WHERE id_usuario = :id");
        qn.bindValue(":id", idActual);
        qn.exec();
        if (qn.next()) nick = qn.value(0).toString();
    }
    QSqlQuery sp;
    sp.prepare("CALL sp_registrar_log(:evento, :descripcion, :entidad, :nick, :resultado, :ip)");
    sp.bindValue(":evento", evento);
    sp.bindValue(":descripcion", descripcion);
    sp.bindValue(":entidad", entidad);
    sp.bindValue(":nick", nick);
    sp.bindValue(":resultado", resultado);
    sp.bindValue(":ip", QSysInfo::machineHostName());
    if (sp.exec()) {
        sp.finish();
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) "
              "VALUES (:fecha, :ip, :descripcion, :entidad, :usuario, :tipo, :resultado)");
    q.bindValue(":fecha", valorAhora());
    q.bindValue(":ip", QSysInfo::machineHostName());
    q.bindValue(":descripcion", descripcion);
    q.bindValue(":entidad", idPorNombre("entidad_log", "id_entidad", "nombre_entidad", entidad));
    q.bindValue(":usuario", usuario);
    q.bindValue(":tipo", idPorNombre("tipo_log", "id_tipo_log", "nombre_evento", evento));
    q.bindValue(":resultado", idPorNombre("resultado_log", "id_resultado", "nombre_resultado", resultado));
    q.exec();
}

QString MainWindow::hashClave(const QString &clave)
{
    return QString::fromLatin1(QCryptographicHash::hash(clave.toUtf8(), QCryptographicHash::Sha256).toHex());
}

QString MainWindow::ahora()
{
    return QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
}

QVariant MainWindow::valorAhora()
{
    return QDateTime::currentDateTime();
}

QVariant MainWindow::valorFecha(const QDate &fecha)
{
    return fecha;
}

QString MainWindow::hoy()
{
    return QDate::currentDate().toString("yyyy-MM-dd");
}

QString MainWindow::formatoCorto(const QString &fechaHora)
{
    QString texto = fechaHora.left(19);
    texto.replace('T', ' ');
    return QDateTime::fromString(texto, "yyyy-MM-dd HH:mm:ss").toString("dd/MM HH:mm");
}

bool MainWindow::soloDigitos(const QString &texto, int minimo, int maximo)
{
    if (texto.size() < minimo || texto.size() > maximo) return false;
    for (int i = 0; i < texto.size(); i++) {
        if (!texto.at(i).isDigit()) return false;
    }
    bool ok;
    texto.toLongLong(&ok);
    return ok;
}

void MainWindow::cargarCombo(QComboBox *combo, const QString &sql, const QString &inicial, const QString &sufijo)
{
    combo->blockSignals(true);
    combo->clear();
    if (!inicial.isEmpty()) combo->addItem(inicial, 0);
    QSqlQuery q;
    q.prepare(sql);
    q.exec();
    while (q.next()) {
        combo->addItem(q.value(1).toString() + sufijo, q.value(0).toInt());
    }
    combo->blockSignals(false);
}

void MainWindow::agregarItem(QListWidget *lista, const QString &texto, int id, int extra)
{
    QListWidgetItem *item = new QListWidgetItem(texto);
    item->setData(Qt::UserRole, id);
    item->setData(Qt::UserRole + 1, extra);
    lista->addItem(item);
}

int MainWindow::seleccionado(QListWidget *lista, int rol)
{
    int fila = lista->currentRow();
    if (fila < 0) return 0;
    return lista->item(fila)->data(rol).toInt();
}

int MainWindow::obtenerCurso(QComboBox *anio, QComboBox *division, QComboBox *especialidad)
{
    QSqlQuery q;
    q.prepare("SELECT id_curso FROM curso WHERE id_anio = :a AND id_division = :d AND id_especialidad = :e");
    q.bindValue(":a", anio->currentData().toInt());
    q.bindValue(":d", division->currentData().toInt());
    q.bindValue(":e", especialidad->currentData().toInt());
    q.exec();
    if (q.next()) return q.value(0).toInt();
    q.prepare("INSERT INTO curso (id_anio, id_division, id_especialidad) VALUES (:a, :d, :e)");
    q.bindValue(":a", anio->currentData().toInt());
    q.bindValue(":d", division->currentData().toInt());
    q.bindValue(":e", especialidad->currentData().toInt());
    if (!q.exec()) return 0;
    return ultimoId(q);
}

QString MainWindow::textoCurso(int idCurso)
{
    if (idCurso <= 0) return "sin curso";
    QSqlQuery q;
    q.prepare("SELECT a.numero_anio, d.numero_division, e.nombre_especialidad FROM curso c "
              "JOIN anio a ON a.id_anio = c.id_anio JOIN division d ON d.id_division = c.id_division "
              "JOIN especialidad e ON e.id_especialidad = c.id_especialidad WHERE c.id_curso = :curso");
    q.bindValue(":curso", idCurso);
    q.exec();
    if (!q.next()) return "sin curso";
    return QString("%1° %2° %3").arg(q.value(0).toInt()).arg(q.value(1).toInt()).arg(q.value(2).toString());
}

QString MainWindow::codigoRecurso(const QString &carro, int numero)
{
    QString texto = QString::number(numero);
    if (texto.size() < 2) texto = "0" + texto;
    if (carro.isEmpty()) return "Tablero " + texto;
    return carro + "-" + texto;
}

void MainWindow::irAlInicio() { ui->stackedWidget->setCurrentIndex(PAG_LANDING); }
void MainWindow::irAlMenu() { ui->stackedWidget->setCurrentIndex(PAG_DASHBOARD); }

void MainWindow::irACuenta()
{
    cargarCuenta();
    ui->stackedWidget->setCurrentIndex(PAG_CUENTA);
}

void MainWindow::cerrarSesion()
{
    registrarLog("Cierre de sesión", "El usuario cerró sesión", "usuario", "Exitoso");
    idActual = 0;
    ui->leObjPrueba->clear();
    ui->leObjReservado->clear();
    ui->leObjBuscar->clear();
    ui->cbObjFiltroCategoria->setCurrentIndex(0);
    ui->leObjTitulo->clear();
    ui->leObjDescripcion->clear();
    ui->leConsultaDesc->clear();
    ui->lblObjFoto->setText("Sin foto");
    fotoElegida = "";
    ui->leHigieneObs->clear();
    ui->cbBuffetVendedor->setCurrentIndex(0);
    ui->leBuffetBuscar->clear();
    ui->cbPlanillasPrograma->setCurrentIndex(0);
    ui->cbHigieneFiltro->setCurrentIndex(0);
    ui->leBuffetPin->clear();
    ui->leBuffetMonto->clear();
    ui->cbBuffetCategoria->setCurrentIndex(0);
    fotoProducto = "";
    mostrarFotoProducto();
    ui->leFiltroPlanillas->clear();
    ui->lePlanillasObs->clear();
    ui->leCuentaClaveActual->clear();
    ui->leCuentaClaveNueva->clear();
    ui->leCuentaClaveRepetir->clear();
    ui->leCuentaTelefono->clear();
    ui->cbHigieneSector->setCurrentIndex(0);
    ui->cbHigieneTipo->setCurrentIndex(0);
    ui->cbObjCategoria->setCurrentIndex(0);
    ui->cbObjSector->setCurrentIndex(0);
    ui->cbSectoresLugar->setCurrentIndex(0);
    ui->deSectoresDia->setDate(QDate::currentDate());
    ui->teSectoresInicio->setTime(QTime(8, 0));
    ui->teSectoresFin->setTime(QTime(9, 0));
    ui->listObjetos->clearSelection();
    ui->leProdNombre->clear();
    ui->leProdPrecio->clear();
    ui->leProdStock->clear();
    ui->cbProdCategoria->setCurrentIndex(0);
    ui->leGrupoNombre->clear();
    ui->leGrupoMeta->clear();
    ui->leGrupoPin->clear();
    ui->stackedWidget->setCurrentIndex(PAG_LANDING);
}

void MainWindow::on_btnLandingLogin_clicked()
{
    ui->tabAcceso->setCurrentIndex(0);
    ui->stackedWidget->setCurrentIndex(PAG_ACCESO);
    ui->leUsuario->setFocus();
}

void MainWindow::on_btnLandingRegister_clicked()
{
    ui->tabAcceso->setCurrentIndex(1);
    ui->stackedWidget->setCurrentIndex(PAG_ACCESO);
    ui->leRegNombre->setFocus();
}

void MainWindow::on_leUsuario_returnPressed() { ui->leClave->setFocus(); }
void MainWindow::on_leClave_returnPressed() { on_btnLoginIngresar_clicked(); }

void MainWindow::on_leRegContacto_returnPressed()
{
    if (ui->btnRegistrar->isEnabled()) on_btnRegistrar_clicked();
}

void MainWindow::on_cbRegRol_currentIndexChanged(int) { actualizarRegistro(); }
void MainWindow::on_cbRegAnio_currentIndexChanged(int) { actualizarRegistro(); }
void MainWindow::on_cbRegDivision_currentIndexChanged(int) { actualizarRegistro(); }
void MainWindow::on_cbRegEspecialidad_currentIndexChanged(int) { actualizarRegistro(); }

void MainWindow::actualizarRegistro()
{
    bool hayRol = ui->cbRegRol->currentData().toInt() > 0;
    bool alumno = ui->cbRegRol->currentText() == "Alumno";
    bool cursoCompleto = ui->cbRegAnio->currentData().toInt() > 0
            && ui->cbRegDivision->currentData().toInt() > 0
            && ui->cbRegEspecialidad->currentData().toInt() > 0;
    ui->cbRegAnio->setEnabled(alumno);
    ui->cbRegDivision->setEnabled(alumno);
    ui->cbRegEspecialidad->setEnabled(alumno);
    ui->leRegPin->setEnabled(hayRol && !alumno);
    ui->btnRegistrar->setEnabled(hayRol && (!alumno || cursoCompleto));
}

void MainWindow::limpiarRegistro()
{
    ui->leRegNombre->clear();
    ui->leRegUsuario->clear();
    ui->leRegClave->clear();
    ui->leRegDni->clear();
    ui->leRegMail->clear();
    ui->leRegContacto->clear();
    ui->leRegPin->clear();
    ui->cbRegRol->setCurrentIndex(0);
    ui->cbRegAnio->setCurrentIndex(0);
    ui->cbRegDivision->setCurrentIndex(0);
    ui->cbRegEspecialidad->setCurrentIndex(0);
}

void MainWindow::on_btnRegistrar_clicked()
{
    QString nombre = ui->leRegNombre->text().trimmed();
    QString nick = ui->leRegUsuario->text().trimmed().toLower();
    QString clave = ui->leRegClave->text();
    QString dni = ui->leRegDni->text().trimmed();
    QString mail = ui->leRegMail->text().trimmed();
    QString telefono = ui->leRegContacto->text().trimmed();
    bool alumno = ui->cbRegRol->currentText() == "Alumno";

    QString problema = "";
    if (!nombre.contains(" ")) problema = "Escribí tu nombre y apellido separados por un espacio.";
    else if (nick.size() < 3) problema = "El usuario tiene que tener al menos 3 caracteres.";
    else if (clave.size() < 4) problema = "La contraseña tiene que tener al menos 4 caracteres.";
    else if (!soloDigitos(dni, 7, 8)) problema = "El DNI tiene que tener 7 u 8 números, sin puntos.";
    else if (!mail.contains("@") || !mail.contains(".")) problema = "El correo tiene que llevar un @ y un punto.";
    else if (!soloDigitos(telefono, 8, 15)) problema = "El teléfono tiene que tener entre 8 y 15 números.";
    else if (!alumno && ui->leRegPin->text() != PIN_PERSONAL) problema = "El PIN de personal es incorrecto.";
    else if (existe("usuario", "LOWER(usuario_nick)", nick)) problema = "Ese usuario ya existe, probá con otro.";
    else if (existe("usuario", "dni", dni)) problema = "Ya hay una cuenta con ese DNI.";
    else if (existe("usuario", "email", mail)) problema = "Ya hay una cuenta con ese correo.";
    if (!problema.isEmpty()) {
        fallar("Registro de usuario", "usuario", problema);
        return;
    }

    QVariant curso;
    if (alumno) {
        int idCurso = obtenerCurso(ui->cbRegAnio, ui->cbRegDivision, ui->cbRegEspecialidad);
        if (idCurso == 0) {
            fallar("Registro de usuario", "usuario", "No se pudo guardar el curso elegido.");
            return;
        }
        curso = idCurso;
    }

    QSqlQuery q;
    q.prepare("INSERT INTO usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) "
              "VALUES (:dni, :nombre, :nick, :hash, :mail, :telefono, :rol, :curso)");
    q.bindValue(":dni", dni);
    q.bindValue(":nombre", nombre);
    q.bindValue(":nick", nick);
    q.bindValue(":hash", hashClave(clave));
    q.bindValue(":mail", mail);
    q.bindValue(":telefono", telefono);
    q.bindValue(":rol", ui->cbRegRol->currentData().toInt());
    q.bindValue(":curso", curso);
    if (!q.exec()) {
        fallar("Registro de usuario", "usuario", "No se pudo crear la cuenta. Revisá los datos.");
        return;
    }
    registrarLog("Registro de usuario", QString("Se creó la cuenta %1").arg(nick), "usuario", "Exitoso");
    limpiarRegistro();
    ui->tabAcceso->setCurrentIndex(0);
    info("Cuenta creada. Ya podés iniciar sesión.");
}

void MainWindow::on_btnLoginIngresar_clicked()
{
    if (intentosFallidos >= MAX_INTENTOS) {
        aviso("Superaste el máximo de intentos. Cerrá y volvé a abrir la aplicación.");
        return;
    }
    QString nick = ui->leUsuario->text().trimmed().toLower();
    QString clave = ui->leClave->text();
    if (nick.isEmpty() || clave.isEmpty()) {
        aviso("Completá el usuario y la contraseña.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT id_usuario FROM usuario WHERE LOWER(usuario_nick) = :nick AND password_hash = :hash");
    q.bindValue(":nick", nick);
    q.bindValue(":hash", hashClave(clave));
    q.exec();
    if (!q.next()) {
        intentosFallidos++;
        idActual = idPorNombre("usuario", "id_usuario", "LOWER(usuario_nick)", nick);
        QString detalle = "Intento fallido con un usuario inexistente";
        if (idActual > 0) detalle = QString("Intento fallido con el usuario %1").arg(nick);
        registrarLog("Inicio de sesión", detalle, "usuario", "Fallido");
        idActual = 0;
        if (intentosFallidos >= MAX_INTENTOS) {
            ui->btnLoginIngresar->setEnabled(false);
            aviso(QString("Fallaste %1 veces seguidas. Cerrá y volvé a abrir la aplicación para intentar de nuevo.").arg(MAX_INTENTOS));
        } else {
            aviso(QString("Usuario o contraseña incorrectos. Intentos restantes: %1.").arg(MAX_INTENTOS - intentosFallidos));
        }
        return;
    }
    intentosFallidos = 0;
    idActual = q.value(0).toInt();
    ui->leUsuario->clear();
    ui->leClave->clear();
    registrarLog("Inicio de sesión", QString("Ingresó el usuario %1").arg(nick), "usuario", "Exitoso");
    cargarTodo();
    ui->stackedWidget->setCurrentIndex(PAG_DASHBOARD);
}

void MainWindow::cargarCuenta()
{
    QSqlQuery q;
    q.prepare("SELECT u.nombre_completo, u.usuario_nick, u.dni, u.email, u.contacto_telefono, r.nombre_rol, "
              "u.id_curso, cu.id_anio, cu.id_division, cu.id_especialidad FROM usuario u "
              "JOIN rol r ON r.id_rol = u.id_rol LEFT JOIN curso cu ON cu.id_curso = u.id_curso WHERE u.id_usuario = :usuario");
    q.bindValue(":usuario", idActual);
    q.exec();
    if (!q.next()) return;
    QString telefono = q.value(4).toString();
    if (telefono.isEmpty()) telefono = "Sin teléfono cargado";
    ui->lblBienvenida->setText(QString("Hola, %1").arg(q.value(0).toString().split(" ").first()));
    ui->lblUsuarioChip->setText(QString("%1 · %2").arg(q.value(0).toString()).arg(q.value(5).toString()));
    ui->lblCuentaNombre->setText(q.value(0).toString());
    ui->lblCuentaUsuario->setText(q.value(1).toString());
    ui->lblCuentaDni->setText(q.value(2).toString());
    ui->lblCuentaMail->setText(q.value(3).toString());
    ui->lblCuentaContacto->setText(telefono);
    ui->lblCuentaRol->setText(q.value(5).toString());
    ui->lblCuentaCurso->setText(textoCurso(q.value(6).toInt()));
    ponerDato(ui->cbCuentaAnio, q.value(7).toInt());
    ponerDato(ui->cbCuentaDivision, q.value(8).toInt());
    ponerDato(ui->cbCuentaEspecialidad, q.value(9).toInt());
    ui->lblProdContacto->setText("Tu contacto: " + q.value(4).toString());
}

void MainWindow::on_btnCuentaGuardar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    if (ui->cbCuentaAnio->currentData().toInt() == 0 || ui->cbCuentaDivision->currentData().toInt() == 0
            || ui->cbCuentaEspecialidad->currentData().toInt() == 0) {
        fallar("", "", "Elegí el año, la división y la especialidad.");
        return;
    }
    int curso = obtenerCurso(ui->cbCuentaAnio, ui->cbCuentaDivision, ui->cbCuentaEspecialidad);
    if (curso == 0) {
        fallar("", "", "No se pudo cambiar tu curso. Probá de nuevo.");
        return;
    }
    int cursoActual = valorUnico("SELECT COALESCE(id_curso, 0) FROM usuario WHERE id_usuario = :id", idActual).toInt();
    if (cursoActual == curso) {
        info("Ese ya es tu curso.");
        return;
    }
    int oferta = valorUnico("SELECT id_oferta FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt();
    QString materia = "";
    if (oferta != 0) materia = chocaHorario(oferta, curso);
    if (!materia.isEmpty()) {
        QString pregunta = QString("Con ese curso, tu inscripción a Educación Física choca con %1 y se va a cancelar. ¿Querés cambiar de curso igual?").arg(materia);
        if (!confirmar("Cambiar de curso", pregunta)) {
            cargarCuenta();
            return;
        }
    }
    QSqlQuery q;
    q.prepare("UPDATE usuario SET id_curso = :curso WHERE id_usuario = :usuario");
    q.bindValue(":curso", curso);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo cambiar tu curso. Probá de nuevo.");
        return;
    }
    bool cancelada = false;
    if (!materia.isEmpty()) {
        QSqlQuery d;
        d.prepare("DELETE FROM inscripcion_ed_fisica WHERE id_usuario = :usuario");
        d.bindValue(":usuario", idActual);
        cancelada = d.exec();
    }
    if (cancelada) {
        registrarLog("Inscripción a Ed. Física", QString("Inscripción a la oferta %1 cancelada por cambio de curso").arg(oferta), "inscripcion_ed_fisica", "Exitoso");
    }
    cargarCuenta();
    cargarEdFisica();
    if (cancelada) {
        info("Cambiaste tu curso. Se canceló tu inscripción a Educación Física porque choca con " + materia + " en tu nuevo horario.");
        return;
    }
    info("Cambiaste tu curso.");
}

void MainWindow::on_btnCuentaClave_clicked()
{
    if (!exigir("Alumno,Profesor,Preceptor,Maestranza", "", "")) return;
    QString actual = ui->leCuentaClaveActual->text();
    QString nueva = ui->leCuentaClaveNueva->text();
    QString repetida = ui->leCuentaClaveRepetir->text();
    QString guardada = valorUnico("SELECT password_hash FROM usuario WHERE id_usuario = :id", idActual);
    if (actual.isEmpty()) {
        ui->leCuentaClaveActual->setFocus();
        fallar("", "", "Escribí tu contraseña actual.");
        return;
    }
    if (hashClave(actual) != guardada) {
        ui->leCuentaClaveActual->setFocus();
        fallar("", "", "La contraseña actual no es correcta.");
        return;
    }
    if (nueva.size() < 4) {
        ui->leCuentaClaveNueva->setFocus();
        fallar("", "", "La contraseña nueva necesita 4 caracteres o más.");
        return;
    }
    if (nueva != repetida) {
        ui->leCuentaClaveRepetir->setFocus();
        fallar("", "", "Las contraseñas nuevas no son iguales.");
        return;
    }
    if (nueva == actual) {
        ui->leCuentaClaveNueva->setFocus();
        fallar("", "", "Elegí una contraseña distinta de la actual.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE usuario SET password_hash = :hash WHERE id_usuario = :usuario");
    q.bindValue(":hash", hashClave(nueva));
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo cambiar la contraseña. Probá de nuevo.");
        return;
    }
    ui->leCuentaClaveActual->clear();
    ui->leCuentaClaveNueva->clear();
    ui->leCuentaClaveRepetir->clear();
    info("Contraseña cambiada. Usala la próxima vez que ingreses.");
}

void MainWindow::on_leCuentaClaveRepetir_returnPressed() { on_btnCuentaClave_clicked(); }

void MainWindow::on_btnCuentaTelefono_clicked()
{
    if (!exigir("Alumno,Profesor,Preceptor,Maestranza", "", "")) return;
    QString telefono = ui->leCuentaTelefono->text().trimmed();
    if (telefono.isEmpty()) {
        ui->leCuentaTelefono->setFocus();
        fallar("", "", "Escribí el teléfono nuevo.");
        return;
    }
    if (!soloDigitos(telefono, 8, 15)) {
        ui->leCuentaTelefono->setFocus();
        fallar("", "", "Escribí el teléfono solo con números (entre 8 y 15), sin espacios ni guiones.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE usuario SET contacto_telefono = :telefono WHERE id_usuario = :usuario");
    q.bindValue(":telefono", telefono);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo cambiar el teléfono. Probá de nuevo.");
        return;
    }
    ui->leCuentaTelefono->clear();
    cargarCuenta();
    cargarConsultas();
    cargarBuffet();
    cargarMisReservas();
    info("Teléfono actualizado.");
}

void MainWindow::on_leCuentaTelefono_returnPressed() { on_btnCuentaTelefono_clicked(); }

void MainWindow::on_btnMenuObjetos_clicked() { ui->stackedWidget->setCurrentIndex(PAG_OBJETOS); }
void MainWindow::on_btnMenuHigiene_clicked() { ui->stackedWidget->setCurrentIndex(PAG_HIGIENE); }
void MainWindow::on_btnMenuBuffet_clicked() { ui->stackedWidget->setCurrentIndex(PAG_BUFFET); }
void MainWindow::on_btnMenuPlanillas_clicked() { ui->stackedWidget->setCurrentIndex(PAG_PLANILLAS); }
void MainWindow::on_btnMenuSectores_clicked() { ui->stackedWidget->setCurrentIndex(PAG_SECTORES); }
void MainWindow::on_btnMenuEdFisica_clicked() { ui->stackedWidget->setCurrentIndex(PAG_EDFISICA); }

void MainWindow::cargarObjetos()
{
    int elegido = seleccionado(ui->listObjetos);
    QString buscar = ui->leObjBuscar->text().trimmed();
    int categoria = ui->cbObjFiltroCategoria->currentData().toInt();
    bool preceptor = rolEs("Preceptor");
    ui->listObjetos->clear();
    QString sql = "SELECT o.id_objeto, o.titulo, o.descripcion, o.ruta_foto, c.nombre_categoria, s.nombre_sector, e.nombre_estado, "
                  "(SELECT COUNT(*) FROM reclamo_objeto r WHERE r.id_objeto = o.id_objeto) "
                  "FROM objeto_perdido o JOIN categoria_objeto c ON c.id_categoria_objeto = o.id_categoria_objeto "
                  "JOIN sector s ON s.id_sector = o.id_sector JOIN estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto "
                  "WHERE o.id_estado_objeto <> :archivado ";
    if (categoria > 0) sql += "AND o.id_categoria_objeto = :categoria ";
    sql += "ORDER BY o.id_objeto DESC";
    QSqlQuery q;
    q.prepare(sql);
    q.bindValue(":archivado", idEstado("estado_objeto", "Archivado"));
    if (categoria > 0) q.bindValue(":categoria", categoria);
    q.exec();
    int disponibles = 0;
    int devueltos = 0;
    QString carpeta = QCoreApplication::applicationDirPath() + "/imagenes_objetos/";
    QString rutaVacia = ":/iconos/sin_foto_claro.png";
    if (temaOscuro) rutaVacia = ":/iconos/sin_foto_oscuro.png";
    QPixmap vacia(rutaVacia);
    if (vacia.isNull()) {
        vacia = QPixmap(96, 96);
        vacia.fill(colorToken("seleccion"));
    }
    while (q.next()) {
        QString estado = q.value(6).toString();
        QString conjunto = q.value(1).toString() + " " + q.value(2).toString() + " " + q.value(4).toString() + " " + q.value(5).toString();
        if (buscar.isEmpty() || conjunto.contains(buscar, Qt::CaseInsensitive)) {
            QString nombreEstado = estado;
            if (estado == "Devuelto") nombreEstado = "Ya devuelto";
            QString cantidad = "(" + plural(q.value(7).toInt(), "reclamo", "reclamos") + ")";
            QString texto = QString("%1\n%2 · %3\n%4 · %5").arg(q.value(1).toString()).arg(q.value(4).toString())
                                .arg(q.value(5).toString()).arg(nombreEstado).arg(cantidad);
            agregarItem(ui->listObjetos, texto, q.value(0).toInt());
            QListWidgetItem *item = ui->listObjetos->item(ui->listObjetos->count() - 1);
            QPixmap miniatura = vacia;
            QPixmap foto(carpeta + q.value(3).toString());
            if (!q.value(3).toString().isEmpty() && !foto.isNull()) miniatura = foto.scaled(96, 96, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            item->setIcon(QIcon(miniatura));
            if (estado == "Disponible") item->setForeground(QBrush(colorToken("ok")));
            else item->setForeground(QBrush(colorToken("suave")));
            if (estado == "Disponible") disponibles++;
            if (estado == "Devuelto") devueltos++;
            if (q.value(0).toInt() == elegido) ui->listObjetos->setCurrentRow(ui->listObjetos->count() - 1);
        }
    }
    if (ui->listObjetos->count() == 0) {
        if (buscar.isEmpty() && categoria == 0) agregarVacio(ui->listObjetos, "Todavía no hay objetos publicados.");
        else agregarVacio(ui->listObjetos, "No hay objetos que coincidan con la búsqueda.");
    }
    QString resumen = QString("Objetos para reclamar: %1 · Ya devueltos: %2").arg(disponibles).arg(devueltos);
    if (preceptor) {
        QString pendientes = valorUnico("SELECT COUNT(*) FROM reclamo_objeto r JOIN estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo "
                                        "WHERE e.nombre_estado = 'Pendiente' AND :id > 0", idActual);
        resumen += " · Reclamos pendientes: " + pendientes;
    }
    ui->lblObjResumen->setText(resumen);
}

void MainWindow::on_listObjetos_itemDoubleClicked(QListWidgetItem *item)
{
    int objeto = item->data(Qt::UserRole).toInt();
    QSqlQuery q;
    q.prepare("SELECT titulo, COALESCE(descripcion, ''), COALESCE(ruta_foto, ''), COALESCE(detalle_reservado, '') "
              "FROM objeto_perdido WHERE id_objeto = :objeto");
    q.bindValue(":objeto", objeto);
    q.exec();
    if (!q.next()) return;
    VentanaDetalle ventana;
    ventana.setObjeto(q.value(0).toString(), q.value(1).toString(), q.value(2).toString());
    if (rolEs("Preceptor")) ventana.setReservado(q.value(3).toString());
    ventana.exec();
}

void MainWindow::cargarReclamos()
{
    ui->listReclamos->clear();
    ui->tabObjetos->setTabText(1, "Reclamos");
    if (!rolEs("Preceptor")) return;
    QSqlQuery q;
    q.prepare("SELECT r.id_reclamo, r.id_objeto, o.titulo, u.nombre_completo, r.prueba_pertenencia, COALESCE(o.detalle_reservado, '') "
              "FROM reclamo_objeto r JOIN objeto_perdido o ON o.id_objeto = r.id_objeto "
              "JOIN usuario u ON u.id_usuario = r.id_usuario WHERE r.id_estado_reclamo = :pendiente "
              "ORDER BY r.id_objeto, r.id_reclamo");
    q.bindValue(":pendiente", idEstado("estado_reclamo", "Pendiente"));
    q.exec();
    while (q.next()) {
        QString reservado = q.value(5).toString();
        if (reservado.isEmpty()) reservado = "ninguno cargado";
        QString texto = QString("%1 · lo reclama %2\nSu detalle: %3\nDato reservado: %4")
                            .arg(q.value(2).toString()).arg(q.value(3).toString()).arg(q.value(4).toString()).arg(reservado);
        agregarItem(ui->listReclamos, texto, q.value(0).toInt(), q.value(1).toInt());
    }
    int total = ui->listReclamos->count();
    if (total == 0) agregarVacio(ui->listReclamos, "No hay reclamos pendientes. Cuando un alumno reclame un objeto, aparece acá.");
    ui->tabObjetos->setTabText(1, QString("Reclamos (%1)").arg(total));
}

void MainWindow::on_btnObjReclamar_clicked()
{
    if (!exigir("Alumno", "Reclamo de objeto", "reclamo_objeto")) return;
    int objeto = seleccionado(ui->listObjetos);
    QString detalle = ui->leObjPrueba->text().trimmed();
    if (objeto == 0) {
        fallar("Reclamo de objeto", "reclamo_objeto", "Elegí un objeto de la lista.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM objeto_perdido o JOIN estado_objeto e "
                                "ON e.id_estado_objeto = o.id_estado_objeto WHERE o.id_objeto = :id", objeto);
    if (estado == "Devuelto" || estado == "Archivado") {
        fallar("Reclamo de objeto", "reclamo_objeto", "Este objeto ya no se puede reclamar: se devolvió o se archivó.");
        return;
    }
    if (detalle.size() < 10) {
        fallar("Reclamo de objeto", "reclamo_objeto", "Contanos un poco más: el detalle necesita 10 caracteres o más.");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) "
              "VALUES (:prueba, :fecha, :usuario, :objeto, :estado)");
    q.bindValue(":prueba", detalle);
    q.bindValue(":fecha", valorFecha(QDate::currentDate()));
    q.bindValue(":usuario", idActual);
    q.bindValue(":objeto", objeto);
    q.bindValue(":estado", idEstado("estado_reclamo", "Pendiente"));
    if (!q.exec()) {
        q.prepare("SELECT COUNT(*) FROM reclamo_objeto WHERE id_usuario = :usuario AND id_objeto = :objeto");
        q.bindValue(":usuario", idActual);
        q.bindValue(":objeto", objeto);
        q.exec();
        q.next();
        if (q.value(0).toInt() > 0) fallar("Reclamo de objeto", "reclamo_objeto", "Ya reclamaste este objeto. Solo se puede reclamar una vez.");
        else fallar("Reclamo de objeto", "reclamo_objeto", "No se pudo enviar el reclamo. Probá de nuevo.");
        return;
    }
    registrarLog("Reclamo de objeto", QString("Reclamo sobre el objeto %1").arg(objeto), "reclamo_objeto", "Exitoso");
    ui->leObjPrueba->clear();
    cargarObjetos();
    cargarReclamos();
    info("Reclamo enviado. El preceptor lo va a revisar.");
}

void MainWindow::resolverReclamo(const QString &estadoReclamo, const QString &evento)
{
    if (!exigir("Preceptor", evento, "reclamo_objeto")) return;
    int reclamo = seleccionado(ui->listReclamos);
    int objeto = seleccionado(ui->listReclamos, Qt::UserRole + 1);
    if (reclamo == 0) {
        fallar(evento, "reclamo_objeto", "Elegí un reclamo de la lista.");
        return;
    }
    QString actual = valorUnico("SELECT e.nombre_estado FROM reclamo_objeto r JOIN estado_reclamo e "
                                "ON e.id_estado_reclamo = r.id_estado_reclamo WHERE r.id_reclamo = :id", reclamo);
    if (actual != "Pendiente") {
        fallar(evento, "reclamo_objeto", "Ese reclamo ya fue resuelto.");
        cargarReclamos();
        return;
    }
    QString titulo = valorUnico("SELECT titulo FROM objeto_perdido WHERE id_objeto = :id", objeto);
    QString quien = valorUnico("SELECT u.nombre_completo FROM reclamo_objeto r JOIN usuario u ON u.id_usuario = r.id_usuario "
                               "WHERE r.id_reclamo = :id", reclamo);
    QString pregunta = QString("¿Querés rechazar el reclamo de %1 sobre “%2”? El objeto sigue en la lista.").arg(quien).arg(titulo);
    if (estadoReclamo == "Aprobado") {
        pregunta = QString("¿Querés aprobar el reclamo de %1 sobre “%2”? El objeto figura como Devuelto y los otros reclamos se rechazan.").arg(quien).arg(titulo);
    }
    if (!confirmar("Confirmar", pregunta)) return;
    db.transaction();
    QSqlQuery q;
    q.prepare("UPDATE reclamo_objeto SET id_estado_reclamo = :estado WHERE id_reclamo = :reclamo");
    q.bindValue(":estado", idEstado("estado_reclamo", estadoReclamo));
    q.bindValue(":reclamo", reclamo);
    bool ok = q.exec();
    if (estadoReclamo == "Aprobado") {
        q.prepare("UPDATE reclamo_objeto SET id_estado_reclamo = :estado WHERE id_objeto = :objeto AND id_reclamo <> :reclamo");
        q.bindValue(":estado", idEstado("estado_reclamo", "Rechazado"));
        q.bindValue(":objeto", objeto);
        q.bindValue(":reclamo", reclamo);
        ok = ok && q.exec();
        q.prepare("UPDATE objeto_perdido SET id_estado_objeto = :estado WHERE id_objeto = :objeto");
        q.bindValue(":estado", idEstado("estado_objeto", "Devuelto"));
        q.bindValue(":objeto", objeto);
        ok = ok && q.exec();
    }
    if (!ok) {
        db.rollback();
        fallar(evento, "reclamo_objeto", "No se pudo actualizar el reclamo. Probá de nuevo.");
        return;
    }
    db.commit();
    registrarLog(evento, QString("Reclamo %1: %2").arg(reclamo).arg(estadoReclamo), "reclamo_objeto", "Exitoso");
    cargarObjetos();
    cargarReclamos();
    if (estadoReclamo == "Aprobado") info("Reclamo aprobado. El objeto figura como Devuelto y los otros reclamos se rechazaron.");
    else info("Reclamo rechazado. El objeto sigue en la lista.");
}

void MainWindow::on_btnReclamoAprobar_clicked() { resolverReclamo("Aprobado", "Resolución de reclamo"); }
void MainWindow::on_btnReclamoRechazar_clicked() { resolverReclamo("Rechazado", "Resolución de reclamo"); }

void MainWindow::on_btnObjArchivar_clicked()
{
    if (!exigir("Preceptor", "", "")) return;
    int objeto = seleccionado(ui->listObjetos);
    if (objeto == 0) {
        fallar("", "", "Elegí un objeto de la lista.");
        return;
    }
    int pendientes = valorUnico("SELECT COUNT(*) FROM reclamo_objeto r JOIN estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo "
                                "WHERE r.id_objeto = :id AND e.nombre_estado = 'Pendiente'", objeto).toInt();
    if (pendientes > 0) {
        fallar("", "", "Ese objeto tiene reclamos pendientes. Resolvelos antes de archivarlo.");
        return;
    }
    QString titulo = valorUnico("SELECT titulo FROM objeto_perdido WHERE id_objeto = :id", objeto);
    if (!confirmar("Archivar objeto", QString("¿Querés archivar “%1”? Sale de la lista de objetos.").arg(titulo))) return;
    QSqlQuery q;
    q.prepare("UPDATE objeto_perdido SET id_estado_objeto = :estado WHERE id_objeto = :objeto");
    q.bindValue(":estado", idEstado("estado_objeto", "Archivado"));
    q.bindValue(":objeto", objeto);
    if (!q.exec()) {
        fallar("", "", "No se pudo archivar el objeto. Probá de nuevo.");
        return;
    }
    cargarObjetos();
}

void MainWindow::on_btnObjFoto_clicked()
{
    QString ruta = QFileDialog::getOpenFileName(this, "Elegir foto", "", "Imágenes (*.png *.jpg *.jpeg)");
    if (ruta.isEmpty()) return;
    QPixmap foto(ruta);
    if (foto.isNull()) {
        aviso("No se pudo abrir esa imagen. Probá con otra foto PNG o JPG.");
        return;
    }
    fotoElegida = ruta;
    ui->lblObjFoto->setPixmap(foto.scaled(ui->lblObjFoto->size(), Qt::KeepAspectRatio, Qt::SmoothTransformation));
}

void MainWindow::on_btnObjPublicar_clicked()
{
    if (!exigir("Preceptor", "Publicación de objeto", "objeto_perdido")) return;
    QString titulo = ui->leObjTitulo->text().trimmed();
    QString descripcion = ui->leObjDescripcion->text().trimmed();
    QString reservado = ui->leObjReservado->text().trimmed();
    if (titulo.isEmpty()) {
        fallar("Publicación de objeto", "objeto_perdido", "Escribí un título para el objeto.");
        return;
    }
    if (ui->cbObjCategoria->currentData().toInt() == 0) {
        fallar("Publicación de objeto", "objeto_perdido", "Elegí la categoría del objeto.");
        return;
    }
    if (ui->cbObjSector->currentData().toInt() == 0) {
        fallar("Publicación de objeto", "objeto_perdido", "Elegí el sector donde lo encontraron.");
        return;
    }
    QString archivo = "";
    if (!fotoElegida.isEmpty()) {
        archivo = QDateTime::currentDateTime().toString("yyyyMMddHHmmss") + "_" + QFileInfo(fotoElegida).fileName();
        QString carpeta = QCoreApplication::applicationDirPath() + "/imagenes_objetos";
        QDir().mkpath(carpeta);
        if (!QFile::copy(fotoElegida, carpeta + "/" + archivo)) {
            fallar("Publicación de objeto", "objeto_perdido", "No se pudo guardar la foto. Probá con otra imagen.");
            return;
        }
    }
    QVariant valorDescripcion;
    if (!descripcion.isEmpty()) valorDescripcion = descripcion;
    QVariant valorFoto;
    if (!archivo.isEmpty()) valorFoto = archivo;
    QVariant valorReservado;
    if (!reservado.isEmpty()) valorReservado = reservado;
    QSqlQuery q;
    q.prepare("INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, detalle_reservado, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) "
              "VALUES (:titulo, :descripcion, :foto, :reservado, :fecha, :usuario, :categoria, :estado, :sector)");
    q.bindValue(":titulo", titulo);
    q.bindValue(":descripcion", valorDescripcion);
    q.bindValue(":foto", valorFoto);
    q.bindValue(":reservado", valorReservado);
    q.bindValue(":fecha", valorFecha(QDate::currentDate()));
    q.bindValue(":usuario", idActual);
    q.bindValue(":categoria", ui->cbObjCategoria->currentData().toInt());
    q.bindValue(":estado", idEstado("estado_objeto", "Disponible"));
    q.bindValue(":sector", ui->cbObjSector->currentData().toInt());
    if (!q.exec()) {
        fallar("Publicación de objeto", "objeto_perdido", "No se pudo publicar el objeto. Probá de nuevo.");
        return;
    }
    registrarLog("Publicación de objeto", QString("Objeto publicado: %1").arg(titulo), "objeto_perdido", "Exitoso");
    ui->leObjTitulo->clear();
    ui->leObjDescripcion->clear();
    ui->leObjReservado->clear();
    ui->cbObjCategoria->setCurrentIndex(0);
    ui->cbObjSector->setCurrentIndex(0);
    ui->lblObjFoto->setText("Sin foto");
    fotoElegida = "";
    cargarObjetos();
    info("Objeto publicado.");
}

void MainWindow::cargarConsultas()
{
    ui->listConsultas->clear();
    QSqlQuery q;
    q.prepare("SELECT c.id_consulta, c.id_usuario, u.nombre_completo, u.contacto_telefono, c.descripcion_busqueda, c.fecha_publicacion "
              "FROM consulta_objeto c JOIN usuario u ON u.id_usuario = c.id_usuario ORDER BY c.id_consulta DESC");
    q.exec();
    while (q.next()) {
        QString dia = QDate::fromString(q.value(5).toString().left(10), "yyyy-MM-dd").toString("dd/MM");
        QString texto = QString("%1 · tel. %2 · %3\n%4").arg(q.value(2).toString()).arg(q.value(3).toString()).arg(dia).arg(q.value(4).toString());
        agregarItem(ui->listConsultas, texto, q.value(0).toInt(), q.value(1).toInt());
    }
    if (ui->listConsultas->count() == 0) agregarVacio(ui->listConsultas, "Todavía no hay consultas. ¿Perdiste algo? Publicá la primera.");
}

void MainWindow::on_btnConsultaPublicar_clicked()
{
    QString descripcion = ui->leConsultaDesc->text().trimmed();
    if (descripcion.size() < 10) {
        fallar("", "", "Describí mejor lo que buscás (10 caracteres o más).");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES (:fecha, :descripcion, :usuario)");
    q.bindValue(":fecha", valorFecha(QDate::currentDate()));
    q.bindValue(":descripcion", descripcion);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo publicar la consulta. Probá de nuevo.");
        return;
    }
    ui->leConsultaDesc->clear();
    cargarConsultas();
}

void MainWindow::on_btnConsultaBorrar_clicked()
{
    int consulta = seleccionado(ui->listConsultas);
    int autor = seleccionado(ui->listConsultas, Qt::UserRole + 1);
    if (consulta == 0) {
        fallar("", "", "Elegí una consulta de la lista.");
        return;
    }
    if (autor != idActual && !rolEs("Preceptor")) {
        fallar("", "", "Solo podés borrar tus propias consultas.");
        return;
    }
    if (!confirmar("Borrar consulta", "¿Querés borrar esta consulta? No se puede deshacer.")) return;
    QSqlQuery q;
    q.prepare("DELETE FROM consulta_objeto WHERE id_consulta = :consulta");
    q.bindValue(":consulta", consulta);
    if (!q.exec()) {
        fallar("", "", "No se pudo borrar la consulta. Probá de nuevo.");
        return;
    }
    cargarConsultas();
}

void MainWindow::on_leConsultaDesc_returnPressed() { on_btnConsultaPublicar_clicked(); }

void MainWindow::cargarHigiene()
{
    ui->listHigiene->clear();
    QString filtro = ui->cbHigieneFiltro->currentText();
    QString sql = "SELECT r.id_reporte, r.fecha_hora, r.observaciones, s.nombre_sector, t.nombre_tipo, e.nombre_estado, "
                  "u.nombre_completo, r.fecha_hora_resolucion, rs.nombre_completo FROM reporte_higiene r "
                  "JOIN sector s ON s.id_sector = r.id_sector JOIN tipo_reporte t ON t.id_tipo_reporte = r.id_tipo_reporte "
                  "JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte JOIN usuario u ON u.id_usuario = r.id_usuario "
                  "LEFT JOIN usuario rs ON rs.id_usuario = r.id_usuario_resolutor ";
    if (filtro == "Pendientes") sql += "WHERE e.nombre_estado = 'Pendiente' ";
    if (filtro == "Resueltos") sql += "WHERE e.nombre_estado = 'Resuelto' ";
    sql += "ORDER BY CASE WHEN e.nombre_estado = 'Pendiente' THEN 0 ELSE 1 END, r.id_reporte DESC";
    QSqlQuery q;
    q.prepare(sql);
    q.exec();
    int resueltos = 0;
    while (q.next()) {
        QString estado = q.value(5).toString();
        bool pendiente = estado == "Pendiente";
        if (pendiente || resueltos < MAX_RESUELTOS) {
            QString texto = estado + " · " + q.value(3).toString() + " · " + q.value(4).toString() + "\n";
            texto += formatoCorto(q.value(1).toString()) + " · Reportó " + q.value(6).toString();
            if (!q.value(7).isNull()) {
                texto += " · Resuelto " + formatoCorto(q.value(7).toString()) + " por " + q.value(8).toString();
            }
            texto += "\n" + q.value(2).toString();
            agregarItem(ui->listHigiene, texto, q.value(0).toInt());
            ui->listHigiene->item(ui->listHigiene->count() - 1)->setToolTip(texto);
            if (pendiente) pintarUltimo(ui->listHigiene, "peligro");
            else pintarUltimo(ui->listHigiene, "ok");
            if (!pendiente) resueltos++;
        }
    }
    if (ui->listHigiene->count() == 0) {
        if (filtro == "Pendientes") agregarVacio(ui->listHigiene, "No hay reportes pendientes.");
        else if (filtro == "Resueltos") agregarVacio(ui->listHigiene, "Todavía no hay reportes resueltos.");
        else agregarVacio(ui->listHigiene, "Todavía no hay reportes. Si ves algo roto o sucio, avisanos desde el formulario.");
    }
    actualizarPendientesHigiene();
}

void MainWindow::actualizarUltimoMantenimiento()
{
    QSqlQuery q;
    q.prepare("SELECT r.fecha_hora_resolucion, u.nombre_completo FROM reporte_higiene r "
              "JOIN usuario u ON u.id_usuario = r.id_usuario_resolutor "
              "WHERE r.id_sector = :sector AND r.fecha_hora_resolucion IS NOT NULL ORDER BY r.fecha_hora_resolucion DESC");
    q.bindValue(":sector", ui->cbHigieneSector->currentData().toInt());
    q.exec();
    if (q.next()) {
        ui->lblHigieneUltimo->setText(QString("%1 — %2").arg(formatoCorto(q.value(0).toString())).arg(q.value(1).toString()));
    } else {
        ui->lblHigieneUltimo->setText("Todavía no hay ninguno");
    }
}

void MainWindow::on_cbHigieneSector_currentIndexChanged(int) { actualizarUltimoMantenimiento(); }

void MainWindow::on_btnHigieneReportar_clicked()
{
    QString observaciones = ui->leHigieneObs->text().trimmed();
    if (observaciones.isEmpty()) {
        ui->leHigieneObs->setFocus();
        fallar("Reporte de higiene", "reporte_higiene", "Contanos qué pasa para poder resolverlo.");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte) "
              "VALUES (:fecha, :observaciones, :usuario, :sector, :tipo, :estado)");
    q.bindValue(":fecha", valorAhora());
    q.bindValue(":observaciones", observaciones);
    q.bindValue(":usuario", idActual);
    q.bindValue(":sector", ui->cbHigieneSector->currentData().toInt());
    q.bindValue(":tipo", ui->cbHigieneTipo->currentData().toInt());
    q.bindValue(":estado", idEstado("estado_reporte", "Pendiente"));
    if (!q.exec()) {
        fallar("Reporte de higiene", "reporte_higiene", "No se pudo enviar el reporte. Probá de nuevo.");
        return;
    }
    registrarLog("Reporte de higiene", QString("Reporte en %1").arg(ui->cbHigieneSector->currentText()), "reporte_higiene", "Exitoso");
    ui->leHigieneObs->clear();
    cargarHigiene();
    info("Reporte enviado. Gracias por avisar.");
}

void MainWindow::on_leHigieneObs_returnPressed() { on_btnHigieneReportar_clicked(); }

void MainWindow::on_btnHigieneResolver_clicked()
{
    if (!exigir("Profesor,Preceptor,Maestranza", "Resolución de reporte", "reporte_higiene")) return;
    int reporte = seleccionado(ui->listHigiene);
    if (reporte == 0) {
        fallar("Resolución de reporte", "reporte_higiene", "Elegí un reporte de la lista.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM reporte_higiene r JOIN estado_reporte e "
                                "ON e.id_estado_reporte = r.id_estado_reporte WHERE r.id_reporte = :id", reporte);
    if (estado != "Pendiente") {
        fallar("Resolución de reporte", "reporte_higiene", "Ese reporte ya está resuelto.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE reporte_higiene SET id_estado_reporte = :estado, fecha_hora_resolucion = :fecha, id_usuario_resolutor = :usuario "
              "WHERE id_reporte = :reporte");
    q.bindValue(":estado", idEstado("estado_reporte", "Resuelto"));
    q.bindValue(":fecha", valorAhora());
    q.bindValue(":usuario", idActual);
    q.bindValue(":reporte", reporte);
    if (!q.exec()) {
        fallar("Resolución de reporte", "reporte_higiene", "No se pudo marcar el reporte como resuelto. Probá de nuevo.");
        return;
    }
    registrarLog("Resolución de reporte", QString("Reporte %1 resuelto").arg(reporte), "reporte_higiene", "Exitoso");
    cargarHigiene();
    actualizarUltimoMantenimiento();
}

void MainWindow::cargarGrupos()
{
    int vista = ui->cbBuffetVista->currentData().toInt();
    int donar = ui->cbDonarGrupo->currentData().toInt();
    cargarCombo(ui->cbBuffetVista, "SELECT id_grupo, nombre_grupo FROM grupo_buffet ORDER BY nombre_grupo", "Productos sueltos de alumnos", "");
    elegirPorId(ui->cbBuffetVista, vista);
    cargarCombo(ui->cbUnirseGrupo, "SELECT id_grupo, nombre_grupo FROM grupo_buffet ORDER BY nombre_grupo", "", "");
    cargarCombo(ui->cbDonarGrupo, "SELECT id_grupo, nombre_grupo FROM grupo_buffet ORDER BY nombre_grupo", "", "");
    elegirPorId(ui->cbDonarGrupo, donar);

    ui->cbProdGrupo->clear();
    ui->cbProdGrupo->addItem("Venta individual", 0);
    QSqlQuery q;
    q.prepare("SELECT g.id_grupo, g.nombre_grupo FROM grupo_buffet g JOIN integrante_grupo i ON i.id_grupo = g.id_grupo "
              "WHERE i.id_usuario = :usuario ORDER BY g.nombre_grupo");
    q.bindValue(":usuario", idActual);
    q.exec();
    while (q.next()) {
        ui->cbProdGrupo->addItem(q.value(1).toString(), q.value(0).toInt());
    }
    habilitar(rolEs("Alumno"), QList<QWidget *>() << ui->colGrupoAlumno);
    cargarDonaciones();
}

int MainWindow::recaudado(int grupo)
{
    QSqlQuery q;
    q.prepare("SELECT COALESCE((SELECT SUM(monto) FROM donacion_buffet WHERE id_grupo = :grupo), 0) + "
              "COALESCE((SELECT SUM(d.cantidad * d.precio_unitario) FROM detalle_venta d "
              "JOIN venta_buffet v ON v.id_venta = d.id_venta JOIN producto_buffet p ON p.id_producto = d.id_producto "
              "WHERE p.id_grupo = :grupo AND v.id_estado_venta = :entregada), 0)");
    q.bindValue(":grupo", grupo);
    q.bindValue(":entregada", idEstado("estado_venta", "Entregada"));
    q.exec();
    q.next();
    return q.value(0).toInt();
}

void MainWindow::cargarBuffet()
{
    cargarVendedores();
    ui->listBuffet->clear();
    int grupo = ui->cbBuffetVista->currentData().toInt();
    int categoria = ui->cbBuffetCategoria->currentData().toInt();
    int vendedor = ui->cbBuffetVendedor->currentData().toInt();
    QString busqueda = ui->leBuffetBuscar->text().trimmed();

    QString sql = "SELECT p.id_producto, p.nombre_producto, p.precio, p.stock, u.nombre_completo, c.nombre_categoria, COALESCE(p.ruta_foto, '') "
                  "FROM producto_buffet p JOIN usuario u ON u.id_usuario = p.id_usuario "
                  "JOIN categoria_producto c ON c.id_categoria_producto = p.id_categoria_producto ";
    if (grupo > 0) sql += "WHERE p.id_grupo = :grupo ";
    else sql += "WHERE p.id_grupo IS NULL ";
    if (categoria > 0) sql += "AND p.id_categoria_producto = :categoria ";
    if (vendedor > 0) sql += "AND p.id_usuario = :vendedor ";
    if (!busqueda.isEmpty()) sql += "AND (p.nombre_producto LIKE :texto OR u.nombre_completo LIKE :texto) ";
    sql += "ORDER BY p.nombre_producto";
    QSqlQuery q;
    q.prepare(sql);
    if (grupo > 0) q.bindValue(":grupo", grupo);
    if (categoria > 0) q.bindValue(":categoria", categoria);
    if (vendedor > 0) q.bindValue(":vendedor", vendedor);
    if (!busqueda.isEmpty()) q.bindValue(":texto", "%" + busqueda + "%");
    q.exec();
    int cantidad = 0;
    while (q.next()) {
        int stock = q.value(3).toInt();
        QString tercera = "Stock " + QString::number(stock) + " · " + q.value(4).toString();
        if (stock == 0) tercera = "SIN STOCK · " + q.value(4).toString();
        QString texto = q.value(1).toString() + "\n$" + QString::number(q.value(2).toInt()) + " · " + q.value(5).toString() + "\n" + tercera;
        agregarItem(ui->listBuffet, texto, q.value(0).toInt());
        QListWidgetItem *item = ui->listBuffet->item(ui->listBuffet->count() - 1);
        item->setIcon(QIcon(miniaturaProducto(q.value(6).toString())));
        item->setToolTip("Doble clic para ver el detalle y la foto");
        if (stock == 0) item->setForeground(QBrush(colorToken("peligro")));
        cantidad++;
    }
    ui->lblBuffetResumen->setText(plural(cantidad, "producto", "productos"));
    ui->listBuffet->setVisible(cantidad > 0);
    ui->lblBuffetVacio->setVisible(cantidad == 0);

    ui->lblBuffetMeta->setVisible(grupo > 0);
    if (grupo > 0) {
        QSqlQuery g;
        g.prepare("SELECT meta_monto FROM grupo_buffet WHERE id_grupo = :grupo");
        g.bindValue(":grupo", grupo);
        g.exec();
        if (g.next() && g.value(0).toInt() > 0) {
            int meta = g.value(0).toInt();
            int juntado = recaudado(grupo);
            ui->lblBuffetMeta->setText(QString("Meta del grupo: $%1 · recaudado $%2 (%3%)").arg(meta).arg(juntado).arg(juntado * 100 / meta));
        }
    }
    mostrarSeleccionBuffet();
    cargarDonaciones();
}

void MainWindow::on_cbBuffetVista_currentIndexChanged(int) { cargarBuffet(); }

void MainWindow::on_cbBuffetCategoria_currentIndexChanged(int) { cargarBuffet(); }

void MainWindow::on_listBuffet_itemDoubleClicked(QListWidgetItem *item)
{
    int producto = item->data(Qt::UserRole).toInt();
    QSqlQuery q;
    q.prepare("SELECT p.nombre_producto, c.nombre_categoria, p.precio, p.stock, u.nombre_completo, u.contacto_telefono, COALESCE(p.ruta_foto, '') "
              "FROM producto_buffet p JOIN categoria_producto c ON c.id_categoria_producto = p.id_categoria_producto "
              "JOIN usuario u ON u.id_usuario = p.id_usuario WHERE p.id_producto = :producto");
    q.bindValue(":producto", producto);
    q.exec();
    if (!q.next()) return;
    VentanaProducto ventana;
    ventana.setProducto(q.value(0).toString(), q.value(1).toString(), q.value(2).toInt(), q.value(3).toInt(),
                        q.value(4).toString(), q.value(5).toString(), q.value(6).toString());
    ventana.exec();
}

void MainWindow::cargarMisReservas()
{
    ui->listMisReservas->clear();
    QSqlQuery q;
    q.prepare("SELECT v.id_venta, p.nombre_producto, d.cantidad, "
              "(SELECT SUM(x.cantidad * x.precio_unitario) FROM detalle_venta x WHERE x.id_venta = v.id_venta), "
              "u.nombre_completo, u.contacto_telefono, v.fecha_hora, e.nombre_estado "
              "FROM venta_buffet v JOIN detalle_venta d ON d.id_venta = v.id_venta "
              "JOIN producto_buffet p ON p.id_producto = d.id_producto JOIN usuario u ON u.id_usuario = p.id_usuario "
              "JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta "
              "WHERE v.id_usuario = :usuario ORDER BY v.id_venta DESC");
    q.bindValue(":usuario", idActual);
    q.exec();
    int activas = 0;
    while (q.next()) {
        QString estado = q.value(7).toString();
        QString texto = QString("%1 · %2 x%3 · $%4 · vende %5 (tel. %6) · %7").arg(estado).arg(q.value(1).toString()).arg(q.value(2).toInt())
                .arg(q.value(3).toInt()).arg(q.value(4).toString()).arg(q.value(5).toString()).arg(formatoCorto(q.value(6).toString()));
        agregarItem(ui->listMisReservas, texto, q.value(0).toInt());
        pintarEstadoVenta(ui->listMisReservas->item(ui->listMisReservas->count() - 1), estado);
        if (estado == "Reservada") activas++;
    }
    ui->lblMisReservasResumen->setText(plural(activas, "reserva activa", "reservas activas"));
    ui->lblMisReservasResumen->setVisible(ui->listMisReservas->count() > 0);
    alternarVacio(ui->listMisReservas, ui->lblMisReservasVacio);
}

void MainWindow::on_btnBuffetReservar_clicked()
{
    int producto = seleccionado(ui->listBuffet);
    int cantidad = ui->sbBuffetCantidad->value();
    if (producto == 0) {
        fallar("Reserva de producto", "venta_buffet", "Elegí un producto de la lista.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT stock, precio, id_usuario FROM producto_buffet WHERE id_producto = :producto");
    q.bindValue(":producto", producto);
    q.exec();
    if (!q.next()) {
        fallar("Reserva de producto", "venta_buffet", "Ese producto ya no existe.");
        return;
    }
    int stock = q.value(0).toInt();
    int precio = q.value(1).toInt();
    if (q.value(2).toInt() == idActual) {
        fallar("Reserva de producto", "venta_buffet", "No podés reservar tus propios productos.");
        return;
    }
    if (cantidad > stock) {
        QString faltante = QString("No hay stock suficiente: quedan %1.").arg(plural(stock, "unidad", "unidades"));
        if (stock == 1) faltante = "No hay stock suficiente: queda 1 unidad.";
        fallar("Reserva de producto", "venta_buffet", faltante);
        return;
    }
    db.transaction();
    q.prepare("INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES (:fecha, :usuario, :estado)");
    q.bindValue(":fecha", valorAhora());
    q.bindValue(":usuario", idActual);
    q.bindValue(":estado", idEstado("estado_venta", "Reservada"));
    bool ok = q.exec();
    int venta = ultimoId(q);
    q.prepare("INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (:venta, :producto, :cantidad, :precio)");
    q.bindValue(":venta", venta);
    q.bindValue(":producto", producto);
    q.bindValue(":cantidad", cantidad);
    q.bindValue(":precio", precio);
    ok = ok && q.exec();
    q.prepare("UPDATE producto_buffet SET stock = stock - :cantidad WHERE id_producto = :producto");
    q.bindValue(":cantidad", cantidad);
    q.bindValue(":producto", producto);
    ok = ok && q.exec();
    if (!ok) {
        db.rollback();
        fallar("Reserva de producto", "venta_buffet", "No se pudo hacer la reserva.");
        return;
    }
    db.commit();
    registrarLog("Reserva de producto", QString("Venta %1: producto %2 x%3").arg(venta).arg(producto).arg(cantidad), "venta_buffet", "Exitoso");
    ui->sbBuffetCantidad->setValue(1);
    cargarBuffet();
    cargarMisReservas();
    info("Reserva hecha. Coordiná la entrega en persona con el vendedor.");
}

void MainWindow::on_btnBuffetCancelar_clicked()
{
    int venta = seleccionado(ui->listMisReservas);
    if (venta == 0) {
        fallar("", "", "Elegí una reserva de la lista.");
        return;
    }
    if (valorUnico("SELECT id_usuario FROM venta_buffet WHERE id_venta = :id", venta).toInt() != idActual) {
        fallar("", "", "Esa reserva no es tuya.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
    QString producto = valorUnico("SELECT p.nombre_producto FROM detalle_venta d JOIN producto_buffet p ON p.id_producto = d.id_producto "
                                  "WHERE d.id_venta = :id", venta);
    if (!confirmar("Cancelar reserva", QString("¿Querés cancelar tu reserva de “%1”? El stock vuelve al producto.").arg(producto))) return;
    if (!cancelarReserva(venta)) {
        fallar("", "", "No se pudo cancelar la reserva. Probá de nuevo.");
        return;
    }
    cargarBuffet();
    cargarMisReservas();
    cargarMisProductos();
    cargarMisVentas();
    info("Reserva cancelada. El stock volvió al producto.");
}

bool MainWindow::cancelarReserva(int venta)
{
    db.transaction();
    QSqlQuery q;
    q.prepare("UPDATE venta_buffet SET id_estado_venta = :estado WHERE id_venta = :venta");
    q.bindValue(":estado", idEstado("estado_venta", "Cancelada"));
    q.bindValue(":venta", venta);
    bool ok = q.exec();
    QSqlQuery detalle;
    detalle.prepare("SELECT id_producto, cantidad FROM detalle_venta WHERE id_venta = :venta");
    detalle.bindValue(":venta", venta);
    detalle.exec();
    while (detalle.next()) {
        q.prepare("UPDATE producto_buffet SET stock = stock + :cantidad WHERE id_producto = :producto");
        q.bindValue(":cantidad", detalle.value(1).toInt());
        q.bindValue(":producto", detalle.value(0).toInt());
        ok = ok && q.exec();
    }
    if (!ok) {
        db.rollback();
        return false;
    }
    db.commit();
    return true;
}

bool MainWindow::ventaEsMia(int venta)
{
    QSqlQuery q;
    q.prepare("SELECT COUNT(*) FROM detalle_venta d JOIN producto_buffet p ON p.id_producto = d.id_producto "
              "WHERE d.id_venta = :venta AND p.id_usuario = :usuario");
    q.bindValue(":venta", venta);
    q.bindValue(":usuario", idActual);
    q.exec();
    q.next();
    return q.value(0).toInt() > 0;
}

bool MainWindow::productoEsMio(int producto)
{
    return valorUnico("SELECT id_usuario FROM producto_buffet WHERE id_producto = :id", producto).toInt() == idActual;
}

void MainWindow::cargarMisVentas()
{
    ui->listMisVentas->clear();
    QSqlQuery q;
    q.prepare("SELECT v.id_venta, p.nombre_producto, d.cantidad, d.cantidad * d.precio_unitario, "
              "c.nombre_completo, c.contacto_telefono, v.fecha_hora, e.nombre_estado "
              "FROM venta_buffet v JOIN detalle_venta d ON d.id_venta = v.id_venta "
              "JOIN producto_buffet p ON p.id_producto = d.id_producto JOIN usuario c ON c.id_usuario = v.id_usuario "
              "JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta "
              "WHERE p.id_usuario = :usuario ORDER BY v.id_venta DESC");
    q.bindValue(":usuario", idActual);
    q.exec();
    int pendientes = 0;
    while (q.next()) {
        QString estado = q.value(7).toString();
        QString texto = QString("%1 · %2 x%3 · $%4 · reservó %5 (tel. %6) · %7").arg(estado).arg(q.value(1).toString()).arg(q.value(2).toInt())
                .arg(q.value(3).toInt()).arg(q.value(4).toString()).arg(q.value(5).toString()).arg(formatoCorto(q.value(6).toString()));
        agregarItem(ui->listMisVentas, texto, q.value(0).toInt());
        pintarEstadoVenta(ui->listMisVentas->item(ui->listMisVentas->count() - 1), estado);
        if (estado == "Reservada") pendientes++;
    }
    ui->lblMisVentasResumen->setText(plural(pendientes, "reserva por entregar", "reservas por entregar"));
    ui->lblMisVentasResumen->setVisible(ui->listMisVentas->count() > 0);
    alternarVacio(ui->listMisVentas, ui->lblMisVentasVacio);
}

void MainWindow::cargarMisProductos()
{
    ui->tabBuffet->setTabVisible(5, rolEs("Alumno"));
    ui->listMisProductos->clear();
    QSqlQuery q;
    q.prepare("SELECT p.id_producto, p.nombre_producto, p.precio, p.stock, COALESCE(g.nombre_grupo, 'Venta individual') "
              "FROM producto_buffet p LEFT JOIN grupo_buffet g ON g.id_grupo = p.id_grupo "
              "WHERE p.id_usuario = :usuario ORDER BY p.nombre_producto");
    q.bindValue(":usuario", idActual);
    q.exec();
    while (q.next()) {
        QString texto = QString("%1 · $%2 · stock %3 · %4").arg(q.value(1).toString()).arg(q.value(2).toInt())
                .arg(q.value(3).toInt()).arg(q.value(4).toString());
        if (q.value(3).toInt() == 0) texto += " · SIN STOCK";
        agregarItem(ui->listMisProductos, texto, q.value(0).toInt());
        if (q.value(3).toInt() == 0) ui->listMisProductos->item(ui->listMisProductos->count() - 1)->setForeground(QBrush(colorToken("peligro")));
    }
    alternarVacio(ui->listMisProductos, ui->lblProdMisVacio);
}

void MainWindow::on_btnBuffetEntregar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int venta = seleccionado(ui->listMisVentas);
    if (venta == 0) {
        fallar("", "", "Elegí una reserva de la lista.");
        return;
    }
    if (!ventaEsMia(venta)) {
        fallar("", "", "Esa reserva es de un producto que no es tuyo.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE venta_buffet SET id_estado_venta = :estado WHERE id_venta = :venta");
    q.bindValue(":estado", idEstado("estado_venta", "Entregada"));
    q.bindValue(":venta", venta);
    if (!q.exec()) {
        fallar("", "", "No se pudo marcar la entrega.");
        return;
    }
    cargarBuffet();
    cargarMisReservas();
    cargarMisVentas();
    info("Entrega confirmada. La venta quedó como Entregada.");
}

void MainWindow::on_btnBuffetCancelarVenta_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int venta = seleccionado(ui->listMisVentas);
    if (venta == 0) {
        fallar("", "", "Elegí una reserva de la lista.");
        return;
    }
    if (!ventaEsMia(venta)) {
        fallar("", "", "Esa reserva es de un producto que no es tuyo.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
    QString comprador = valorUnico("SELECT u.nombre_completo FROM venta_buffet v JOIN usuario u ON u.id_usuario = v.id_usuario "
                                   "WHERE v.id_venta = :id", venta);
    QString producto = valorUnico("SELECT p.nombre_producto FROM detalle_venta d JOIN producto_buffet p ON p.id_producto = d.id_producto "
                                  "WHERE d.id_venta = :id", venta);
    if (!confirmar("Cancelar reserva", QString("¿Querés cancelar la reserva de %1 sobre “%2”? El stock vuelve a tu producto.").arg(comprador).arg(producto))) return;
    if (!cancelarReserva(venta)) {
        fallar("", "", "No se pudo cancelar la reserva. Probá de nuevo.");
        return;
    }
    cargarBuffet();
    cargarMisReservas();
    cargarMisProductos();
    cargarMisVentas();
    info("Reserva cancelada. El stock volvió a tu producto.");
}

void MainWindow::on_btnProdQuitar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int producto = seleccionado(ui->listMisProductos);
    int cantidad = ui->sbProdReponer->value();
    if (producto == 0) {
        fallar("", "", "Elegí un producto de tu lista.");
        return;
    }
    if (!productoEsMio(producto)) {
        fallar("", "", "Ese producto no es tuyo.");
        return;
    }
    int stock = valorUnico("SELECT stock FROM producto_buffet WHERE id_producto = :id", producto).toInt();
    if (cantidad > stock) {
        fallar("", "", QString("No podés quitar más de lo que hay: el producto tiene %1.").arg(plural(stock, "unidad", "unidades")));
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE producto_buffet SET stock = stock - :cantidad WHERE id_producto = :producto AND id_usuario = :usuario AND stock >= :cantidad");
    q.bindValue(":cantidad", cantidad);
    q.bindValue(":producto", producto);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo quitar el stock. Probá de nuevo.");
        return;
    }
    ui->sbProdReponer->setValue(1);
    cargarBuffet();
    cargarMisProductos();
    info(QString("Quitaste %1. Ahora quedan %2.").arg(plural(cantidad, "unidad", "unidades")).arg(stock - cantidad));
}

void MainWindow::on_btnProdReponer_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int producto = seleccionado(ui->listMisProductos);
    int cantidad = ui->sbProdReponer->value();
    if (producto == 0) {
        fallar("", "", "Elegí un producto de tu lista.");
        return;
    }
    if (!productoEsMio(producto)) {
        fallar("", "", "Ese producto no es tuyo.");
        return;
    }
    int stock = valorUnico("SELECT stock FROM producto_buffet WHERE id_producto = :id", producto).toInt();
    QSqlQuery q;
    q.prepare("UPDATE producto_buffet SET stock = stock + :cantidad WHERE id_producto = :producto AND id_usuario = :usuario");
    q.bindValue(":cantidad", cantidad);
    q.bindValue(":producto", producto);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo reponer el stock. Probá de nuevo.");
        return;
    }
    ui->sbProdReponer->setValue(1);
    cargarBuffet();
    cargarMisProductos();
    info(QString("Sumaste %1. Ahora hay %2.").arg(plural(cantidad, "unidad", "unidades")).arg(stock + cantidad));
}

void MainWindow::on_btnProdEliminar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int producto = seleccionado(ui->listMisProductos);
    if (producto == 0) {
        fallar("", "", "Elegí un producto de tu lista.");
        return;
    }
    if (!productoEsMio(producto)) {
        fallar("", "", "Ese producto no es tuyo.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT COUNT(*) FROM detalle_venta d JOIN venta_buffet v ON v.id_venta = d.id_venta "
              "WHERE d.id_producto = :producto AND v.id_estado_venta = :reservada");
    q.bindValue(":producto", producto);
    q.bindValue(":reservada", idEstado("estado_venta", "Reservada"));
    q.exec();
    q.next();
    if (q.value(0).toInt() > 0) {
        fallar("", "", "Tiene reservas activas. Entregalas o cancelalas antes de eliminar el producto.");
        return;
    }
    q.prepare("SELECT COUNT(*) FROM detalle_venta WHERE id_producto = :producto");
    q.bindValue(":producto", producto);
    q.exec();
    q.next();
    if (q.value(0).toInt() > 0) {
        fallar("", "", "Este producto ya tuvo ventas, así que no se puede eliminar (se conserva el historial).");
        return;
    }
    QString nombre = valorUnico("SELECT nombre_producto FROM producto_buffet WHERE id_producto = :id", producto);
    QString foto = valorUnico("SELECT COALESCE(ruta_foto, '') FROM producto_buffet WHERE id_producto = :id", producto);
    if (!confirmar("Eliminar producto", QString("¿Querés eliminar “%1”? No se puede deshacer.").arg(nombre))) return;
    q.prepare("DELETE FROM producto_buffet WHERE id_producto = :producto AND id_usuario = :usuario");
    q.bindValue(":producto", producto);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo eliminar el producto. Probá de nuevo.");
        return;
    }
    if (!foto.isEmpty()) QFile::remove(QCoreApplication::applicationDirPath() + "/imagenes_productos/" + foto);
    cargarBuffet();
    cargarMisProductos();
    info("Producto eliminado.");
}

void MainWindow::on_btnBuffetDonar_clicked()
{
    int grupo = ui->cbDonarGrupo->currentData().toInt();
    bool ok;
    int monto = ui->leBuffetMonto->text().trimmed().toInt(&ok);
    if (grupo == 0) {
        fallar("Donación", "donacion_buffet", "Todavía no hay grupos para donar.");
        return;
    }
    if (!ok || monto <= 0) {
        fallar("Donación", "donacion_buffet", "Escribí un monto en pesos, mayor a 0 y sin centavos.");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO donacion_buffet (monto, fecha_hora, id_usuario, id_grupo) VALUES (:monto, :fecha, :usuario, :grupo)");
    q.bindValue(":monto", monto);
    q.bindValue(":fecha", valorAhora());
    q.bindValue(":usuario", idActual);
    q.bindValue(":grupo", grupo);
    if (!q.exec()) {
        fallar("Donación", "donacion_buffet", "No se pudo registrar la donación.");
        return;
    }
    registrarLog("Donación", QString("Donó $%1 al grupo %2").arg(monto).arg(grupo), "donacion_buffet", "Exitoso");
    ui->leBuffetMonto->clear();
    cargarBuffet();
    info("¡Gracias por tu donación!");
}

void MainWindow::on_leBuffetMonto_returnPressed() { on_btnBuffetDonar_clicked(); }

void MainWindow::on_leBuffetPin_returnPressed() { on_btnBuffetUnirse_clicked(); }

void MainWindow::on_leGrupoPin_returnPressed() { on_btnGrupoCrear_clicked(); }

void MainWindow::on_btnBuffetUnirse_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int grupo = ui->cbUnirseGrupo->currentData().toInt();
    if (grupo == 0) {
        fallar("", "", "Todavía no hay grupos para unirse.");
        return;
    }
    QString pin = valorUnico("SELECT pin_acceso FROM grupo_buffet WHERE id_grupo = :id", grupo);
    if (ui->leBuffetPin->text().trimmed() != pin) {
        fallar("", "", "El PIN no coincide. Pedíselo a quien creó el grupo.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT COUNT(*) FROM integrante_grupo WHERE id_usuario = :usuario AND id_grupo = :grupo");
    q.bindValue(":usuario", idActual);
    q.bindValue(":grupo", grupo);
    q.exec();
    q.next();
    if (q.value(0).toInt() > 0) {
        fallar("", "", "Ya sos integrante de ese grupo.");
        return;
    }
    q.prepare("INSERT INTO integrante_grupo (id_usuario, id_grupo) VALUES (:usuario, :grupo)");
    q.bindValue(":usuario", idActual);
    q.bindValue(":grupo", grupo);
    if (!q.exec()) {
        fallar("", "", "No se pudo unir al grupo.");
        return;
    }
    ui->leBuffetPin->clear();
    cargarGrupos();
    info("Ya sos parte del grupo.");
}

void MainWindow::on_btnProdFoto_clicked()
{
    QString ruta = QFileDialog::getOpenFileName(this, "Elegir foto", "", "Imágenes (*.png *.jpg *.jpeg)");
    if (ruta.isEmpty()) return;
    if (QPixmap(ruta).isNull()) {
        aviso("No se pudo abrir esa imagen. Probá con otro archivo .png o .jpg.");
        return;
    }
    fotoProducto = ruta;
    mostrarFotoProducto();
}

void MainWindow::on_btnProdPublicar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    QString nombre = ui->leProdNombre->text().trimmed();
    bool okPrecio;
    bool okStock;
    int precio = ui->leProdPrecio->text().trimmed().toInt(&okPrecio);
    int stock = ui->leProdStock->text().trimmed().toInt(&okStock);
    int grupo = ui->cbProdGrupo->currentData().toInt();
    int categoria = ui->cbProdCategoria->currentData().toInt();
    if (nombre.isEmpty()) {
        fallar("", "", "Escribí el nombre del producto.");
        return;
    }
    if (!okPrecio || precio <= 0 || !okStock || stock <= 0) {
        fallar("", "", "Precio y stock: escribí números enteros mayores a 0.");
        return;
    }
    if (categoria == 0) {
        fallar("", "", "Elegí la categoría del producto.");
        return;
    }
    QVariant valorGrupo;
    if (grupo > 0) {
        QSqlQuery m;
        m.prepare("SELECT COUNT(*) FROM integrante_grupo WHERE id_usuario = :usuario AND id_grupo = :grupo");
        m.bindValue(":usuario", idActual);
        m.bindValue(":grupo", grupo);
        m.exec();
        m.next();
        if (m.value(0).toInt() == 0) {
            fallar("", "", "Para vender en un grupo tenés que ser integrante.");
            return;
        }
        valorGrupo = grupo;
    }
    QString archivo = "";
    QString carpeta = QCoreApplication::applicationDirPath() + "/imagenes_productos";
    if (!fotoProducto.isEmpty()) {
        archivo = QDateTime::currentDateTime().toString("yyyyMMddHHmmss") + "_" + QString::number(idActual) + "_" + QFileInfo(fotoProducto).fileName();
        QDir().mkpath(carpeta);
        if (!QFile::copy(fotoProducto, carpeta + "/" + archivo)) {
            fallar("", "", "No se pudo copiar la foto elegida.");
            return;
        }
    }
    QVariant valorFoto;
    if (!archivo.isEmpty()) valorFoto = archivo;
    QSqlQuery q;
    q.prepare("INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo, id_categoria_producto, ruta_foto) "
              "VALUES (:nombre, :precio, :stock, :usuario, :grupo, :categoria, :foto)");
    q.bindValue(":nombre", nombre);
    q.bindValue(":precio", precio);
    q.bindValue(":stock", stock);
    q.bindValue(":usuario", idActual);
    q.bindValue(":grupo", valorGrupo);
    q.bindValue(":categoria", categoria);
    q.bindValue(":foto", valorFoto);
    if (!q.exec()) {
        if (!archivo.isEmpty()) QFile::remove(carpeta + "/" + archivo);
        fallar("", "", "No se pudo publicar el producto.");
        return;
    }
    ui->leProdNombre->clear();
    ui->leProdPrecio->clear();
    ui->leProdStock->clear();
    fotoProducto = "";
    mostrarFotoProducto();
    cargarBuffet();
    cargarMisProductos();
    info("Producto publicado.");
}

void MainWindow::on_btnGrupoCrear_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    QString nombre = ui->leGrupoNombre->text().trimmed();
    QString pin = ui->leGrupoPin->text().trimmed();
    bool ok;
    int meta = ui->leGrupoMeta->text().trimmed().toInt(&ok);
    if (nombre.isEmpty()) {
        fallar("", "", "Escribí el nombre del grupo.");
        return;
    }
    if (!ok || meta <= 0) {
        fallar("", "", "La meta es un monto en pesos, mayor a 0 y sin centavos.");
        return;
    }
    if (pin.size() < 4) {
        fallar("", "", "El PIN necesita 4 caracteres o más.");
        return;
    }
    if (existe("grupo_buffet", "nombre_grupo", nombre)) {
        fallar("", "", "Ya existe un grupo con ese nombre.");
        return;
    }
    db.transaction();
    QSqlQuery q;
    q.prepare("INSERT INTO grupo_buffet (nombre_grupo, pin_acceso, meta_monto) VALUES (:nombre, :pin, :meta)");
    q.bindValue(":nombre", nombre);
    q.bindValue(":pin", pin);
    q.bindValue(":meta", meta);
    bool correcto = q.exec();
    int grupo = ultimoId(q);
    q.prepare("INSERT INTO integrante_grupo (id_usuario, id_grupo) VALUES (:usuario, :grupo)");
    q.bindValue(":usuario", idActual);
    q.bindValue(":grupo", grupo);
    correcto = correcto && q.exec();
    if (!correcto) {
        db.rollback();
        fallar("", "", "No se pudo crear el grupo.");
        return;
    }
    db.commit();
    ui->leGrupoNombre->clear();
    ui->leGrupoMeta->clear();
    ui->leGrupoPin->clear();
    cargarGrupos();
    info("Grupo creado. Ya sos integrante.");
}

void MainWindow::cargarPlanillas()
{
    QString filtro = ui->leFiltroPlanillas->text().trimmed();
    int programa = ui->cbPlanillasPrograma->currentData().toInt();
    ui->listPlanillas->clear();
    QString sql = "SELECT r.id_recurso, c.nombre_carro, r.numero_equipo, t.nombre_tipo FROM recursos_ct r "
                  "LEFT JOIN carro c ON c.id_carro = r.id_carro JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso "
                  "WHERE r.id_estado_recurso = :disponible ";
    if (programa > 0) sql += "AND EXISTS (SELECT 1 FROM recurso_software rs WHERE rs.id_recurso = r.id_recurso AND rs.id_software = :programa) ";
    sql += "ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo";
    QSqlQuery q;
    q.prepare(sql);
    q.bindValue(":disponible", idEstado("estado_recurso", "Disponible"));
    if (programa > 0) q.bindValue(":programa", programa);
    q.exec();
    while (q.next()) {
        QString codigo = codigoRecurso(q.value(1).toString(), q.value(2).toInt());
        if (filtro.isEmpty() || codigo.contains(filtro, Qt::CaseInsensitive)) {
            agregarItem(ui->listPlanillas, QString("%1 · %2").arg(codigo).arg(q.value(3).toString()), q.value(0).toInt());
        }
    }
    if (ui->listPlanillas->count() == 0) {
        if (filtro.isEmpty() && programa == 0) agregarVacio(ui->listPlanillas, "No hay equipos disponibles en este momento.");
        else agregarVacio(ui->listPlanillas, "No hay equipos disponibles con ese filtro.");
    }
    cargarFueraServicio();
    actualizarResumenPlanillas();
}

void MainWindow::cargarFueraServicio()
{
    QString filtro = ui->leFiltroPlanillas->text().trimmed();
    ui->listFueraServicio->clear();
    QSqlQuery q;
    q.prepare("SELECT r.id_recurso, c.nombre_carro, r.numero_equipo, t.nombre_tipo FROM recursos_ct r "
              "LEFT JOIN carro c ON c.id_carro = r.id_carro JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso "
              "WHERE r.id_estado_recurso = :fuera ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo");
    q.bindValue(":fuera", idEstado("estado_recurso", "Fuera de servicio"));
    q.exec();
    while (q.next()) {
        QString codigo = codigoRecurso(q.value(1).toString(), q.value(2).toInt());
        if (filtro.isEmpty() || codigo.contains(filtro, Qt::CaseInsensitive)) {
            agregarItem(ui->listFueraServicio, QString("%1 · %2").arg(codigo).arg(q.value(3).toString()), q.value(0).toInt());
            pintarUltimo(ui->listFueraServicio, "peligro");
        }
    }
    if (ui->listFueraServicio->count() == 0) agregarVacio(ui->listFueraServicio, "No hay equipos fuera de servicio.");
}

void MainWindow::on_btnPlanillasReparar_clicked()
{
    if (!exigir("Preceptor,Maestranza", "", "")) return;
    int recurso = seleccionado(ui->listFueraServicio);
    if (recurso == 0) {
        fallar("", "", "Elegí un equipo de la lista de fuera de servicio.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM recursos_ct r JOIN estado_recurso e "
                                "ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = :id", recurso);
    if (estado != "Fuera de servicio") {
        fallar("", "", "Ese equipo ya no está fuera de servicio.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE recursos_ct SET id_estado_recurso = :estado WHERE id_recurso = :recurso");
    q.bindValue(":estado", idEstado("estado_recurso", "Disponible"));
    q.bindValue(":recurso", recurso);
    if (!q.exec()) {
        fallar("", "", "No se pudo marcar el equipo como reparado. Probá de nuevo.");
        return;
    }
    cargarPlanillas();
    info("Equipo reparado. Ya se puede prestar.");
}

void MainWindow::on_leFiltroPlanillas_textChanged(const QString &)
{
    cargarPlanillas();
    cargarPrestamos();
}

void MainWindow::on_leFiltroPlanillas_returnPressed()
{
    cargarPlanillas();
    cargarPrestamos();
}

void MainWindow::cargarPrestamos()
{
    QString filtro = ui->leFiltroPlanillas->text().trimmed();
    ui->listPrestamos->clear();
    QSqlQuery q;
    bool soloMios = rolActual() == "Alumno";
    QString donde = "";
    if (soloMios) donde = "WHERE p.id_usuario_solicitante = :usuario ";
    q.prepare(QString("SELECT p.id_prestamo, a.nombre_completo, an.numero_anio, dv.numero_division, c.nombre_carro, r.numero_equipo, "
              "p.hora_prestamo, p.hora_devolucion, au.nombre_completo, p.fecha_prestamo FROM prestamo_ct p "
              "JOIN usuario a ON a.id_usuario = p.id_usuario_solicitante LEFT JOIN curso cu ON cu.id_curso = a.id_curso "
              "LEFT JOIN anio an ON an.id_anio = cu.id_anio LEFT JOIN division dv ON dv.id_division = cu.id_division "
              "JOIN usuario au ON au.id_usuario = p.id_usuario_autorizador JOIN recursos_ct r ON r.id_recurso = p.id_recurso "
              "LEFT JOIN carro c ON c.id_carro = r.id_carro %1"
              "ORDER BY CASE WHEN p.hora_devolucion IS NULL THEN 0 ELSE 1 END, p.id_prestamo DESC").arg(donde));
    if (soloMios) q.bindValue(":usuario", idActual);
    q.exec();
    int mostrados = 0;
    while (q.next() && mostrados < 40) {
        QString codigo = codigoRecurso(q.value(4).toString(), q.value(5).toInt());
        if (filtro.isEmpty() || codigo.contains(filtro, Qt::CaseInsensitive)) {
            QString curso = "sin curso";
            if (!q.value(2).isNull()) curso = QString("%1°%2°").arg(q.value(2).toInt()).arg(q.value(3).toInt());
            QString estado = "En préstamo";
            if (!q.value(7).isNull()) estado = "Devuelto " + q.value(7).toString();
            QString dia = QDate::fromString(q.value(9).toString(), "yyyy-MM-dd").toString("dd/MM");
            QString texto = QString("%1 · %2 (%3)\nRetiró %4 %5 · Autorizó %6 · %7").arg(codigo).arg(q.value(1).toString()).arg(curso)
                                .arg(dia).arg(q.value(6).toString()).arg(q.value(8).toString()).arg(estado);
            agregarItem(ui->listPrestamos, texto, q.value(0).toInt());
            if (q.value(7).isNull()) pintarUltimo(ui->listPrestamos, "ok");
            else pintarUltimo(ui->listPrestamos, "suave");
            mostrados++;
        }
    }
    if (mostrados == 0) {
        if (filtro.isEmpty() && soloMios) agregarVacio(ui->listPrestamos, "Todavía no tenés préstamos registrados.");
        else if (filtro.isEmpty()) agregarVacio(ui->listPrestamos, "Todavía no hay préstamos registrados.");
        else agregarVacio(ui->listPrestamos, "No hay préstamos de ese equipo.");
    }
}

void MainWindow::on_btnPlanillasPrestar_clicked()
{
    if (!exigir("Alumno,Profesor,Preceptor", "Préstamo de recurso", "prestamo_ct")) return;
    int recurso = seleccionado(ui->listPlanillas);
    int alumno = ui->cbPlanillasAlumno->currentData().toInt();
    if (rolActual() == "Alumno") alumno = idActual;
    QString observaciones = ui->lePlanillasObs->text().trimmed();
    if (recurso == 0) {
        fallar("Préstamo de recurso", "prestamo_ct", "Elegí un equipo de la lista de disponibles.");
        return;
    }
    if (alumno == 0) {
        fallar("Préstamo de recurso", "prestamo_ct", "Elegí quién se lleva el equipo.");
        return;
    }
    if (valorUnico("SELECT COUNT(*) FROM prestamo_ct WHERE id_usuario_solicitante = :id AND hora_devolucion IS NULL", alumno).toInt() > 0) {
        QString mensaje = "Ese alumno ya tiene un equipo prestado. Tiene que devolverlo antes de retirar otro.";
        if (rolActual() == "Alumno") mensaje = "Ya tenés un equipo prestado. Devolvelo antes de retirar otro.";
        fallar("Préstamo de recurso", "prestamo_ct", mensaje);
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM recursos_ct r JOIN estado_recurso e "
                                "ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = :id", recurso);
    if (estado != "Disponible") {
        fallar("Préstamo de recurso", "prestamo_ct", "Ese equipo no está disponible.");
        return;
    }
    QVariant valorObservaciones;
    if (!observaciones.isEmpty()) valorObservaciones = observaciones;
    db.transaction();
    QSqlQuery q;
    q.prepare("INSERT INTO prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) "
              "VALUES (:fecha, :hora, NULL, :observaciones, :alumno, :autorizador, :recurso)");
    q.bindValue(":fecha", valorFecha(QDate::currentDate()));
    q.bindValue(":hora", QTime::currentTime().toString("HH:mm"));
    q.bindValue(":observaciones", valorObservaciones);
    q.bindValue(":alumno", alumno);
    q.bindValue(":autorizador", idActual);
    q.bindValue(":recurso", recurso);
    bool ok = q.exec();
    q.prepare("UPDATE recursos_ct SET id_estado_recurso = :estado WHERE id_recurso = :recurso");
    q.bindValue(":estado", idEstado("estado_recurso", "Prestado"));
    q.bindValue(":recurso", recurso);
    ok = ok && q.exec();
    if (!ok) {
        db.rollback();
        fallar("Préstamo de recurso", "prestamo_ct", "No se pudo registrar el préstamo. Probá de nuevo.");
        return;
    }
    db.commit();
    registrarLog("Préstamo de recurso", QString("Equipo %1 prestado al alumno %2").arg(recurso).arg(alumno), "prestamo_ct", "Exitoso");
    ui->lePlanillasObs->clear();
    cargarPlanillas();
    cargarPrestamos();
    info("Préstamo registrado.");
}

void MainWindow::on_btnPlanillasDevolver_clicked()
{
    if (!exigir("Alumno,Profesor,Preceptor", "Devolución de recurso", "prestamo_ct")) return;
    int prestamo = seleccionado(ui->listPrestamos);
    QString observaciones = ui->lePlanillasObs->text().trimmed();
    if (prestamo == 0) {
        fallar("Devolución de recurso", "prestamo_ct", "Elegí un préstamo de la lista.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT hora_devolucion, id_recurso, id_usuario_solicitante FROM prestamo_ct WHERE id_prestamo = :prestamo");
    q.bindValue(":prestamo", prestamo);
    q.exec();
    q.next();
    if (!q.value(0).isNull()) {
        fallar("Devolución de recurso", "prestamo_ct", "Ese préstamo ya fue devuelto.");
        return;
    }
    if (rolActual() == "Alumno" && q.value(2).toInt() != idActual) {
        fallar("Devolución de recurso", "prestamo_ct", "Solo podés devolver tus propios préstamos.");
        return;
    }
    int recurso = q.value(1).toInt();
    QString nuevoEstado = "Fuera de servicio";
    if (ui->cbPlanillasEstado->currentText() == "Funciona") nuevoEstado = "Disponible";
    if (nuevoEstado == "Fuera de servicio") {
        if (!confirmar("Devolver equipo", "Vas a devolver el equipo como que NO funciona. Queda fuera de servicio hasta que el preceptor o maestranza lo repare. ¿Confirmás?")) return;
    }
    db.transaction();
    q.prepare("UPDATE prestamo_ct SET hora_devolucion = :hora WHERE id_prestamo = :prestamo");
    q.bindValue(":hora", QTime::currentTime().toString("HH:mm"));
    q.bindValue(":prestamo", prestamo);
    bool ok = q.exec();
    if (!observaciones.isEmpty()) {
        QString anterior = valorUnico("SELECT COALESCE(observaciones, '') FROM prestamo_ct WHERE id_prestamo = :id", prestamo);
        if (!anterior.isEmpty()) observaciones = anterior + " / Devolución: " + observaciones;
        q.prepare("UPDATE prestamo_ct SET observaciones = :observaciones WHERE id_prestamo = :prestamo");
        q.bindValue(":observaciones", observaciones);
        q.bindValue(":prestamo", prestamo);
        ok = ok && q.exec();
    }
    q.prepare("UPDATE recursos_ct SET id_estado_recurso = :estado WHERE id_recurso = :recurso");
    q.bindValue(":estado", idEstado("estado_recurso", nuevoEstado));
    q.bindValue(":recurso", recurso);
    ok = ok && q.exec();
    if (!ok) {
        db.rollback();
        fallar("Devolución de recurso", "prestamo_ct", "No se pudo registrar la devolución. Probá de nuevo.");
        return;
    }
    db.commit();
    registrarLog("Devolución de recurso", QString("Préstamo %1 devuelto, queda: %2").arg(prestamo).arg(nuevoEstado), "prestamo_ct", "Exitoso");
    ui->lePlanillasObs->clear();
    cargarPlanillas();
    cargarPrestamos();
    info("Devolución registrada.");
}

void MainWindow::cargarOcupacion()
{
    ui->listOcupacion->clear();
    int sector = ui->cbSectoresLugar->currentData().toInt();
    if (sector <= 0) return;
    QString dia = ui->deSectoresDia->date().toString("dd/MM");
    ui->lblSectoresOcupacion->setText(QString("Ocupación de %1 el %2").arg(ui->cbSectoresLugar->currentText()).arg(dia));
    QSqlQuery q;
    q.prepare("SELECT r.hora_inicio, r.hora_fin, u.nombre_completo, e.nombre_estado FROM reserva_sector r "
              "JOIN usuario u ON u.id_usuario = r.id_usuario JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
              "WHERE r.id_sector = :sector AND r.fecha_reserva = :fecha AND r.id_estado_reserva IN (:pendiente, :aprobada) "
              "ORDER BY r.hora_inicio");
    q.bindValue(":sector", sector);
    q.bindValue(":fecha", valorFecha(ui->deSectoresDia->date()));
    q.bindValue(":pendiente", idEstado("estado_reserva", "Pendiente"));
    q.bindValue(":aprobada", idEstado("estado_reserva", "Aprobada"));
    q.exec();
    int pendientes = 0;
    while (q.next()) {
        QString estado = q.value(3).toString();
        QString estadoTexto = estado;
        if (estado == "Pendiente") {
            pendientes++;
            estadoTexto = "Pendiente de aprobación";
        }
        QString texto = QString("%1 a %2 - %3").arg(q.value(0).toString()).arg(q.value(1).toString()).arg(estadoTexto);
        texto += "\n" + q.value(2).toString();
        agregarItem(ui->listOcupacion, texto, 0);
        pintarUltimo(ui->listOcupacion, "peligro");
    }
    if (ui->listOcupacion->count() == 0) {
        agregarItem(ui->listOcupacion, "Sin reservas ese día: el sector está libre.", 0);
        pintarUltimo(ui->listOcupacion, "ok");
    }
    if (pendientes > 0) {
        QString texto = "Atención: " + plural(pendientes, "reserva pendiente", "reservas pendientes") + " de aprobación ese día.";
        ui->listOcupacion->insertItem(0, texto);
        QListWidgetItem *primero = ui->listOcupacion->item(0);
        primero->setFlags(Qt::ItemIsEnabled);
        QFont fuente = primero->font();
        fuente.setBold(true);
        primero->setFont(fuente);
    }
}

void MainWindow::cargarReservasSector()
{
    ui->listSectores->clear();
    QString sql = "SELECT r.id_reserva, r.fecha_reserva, r.hora_inicio, r.hora_fin, s.nombre_sector, u.nombre_completo, "
                  "e.nombre_estado, r.id_usuario FROM reserva_sector r JOIN sector s ON s.id_sector = r.id_sector "
                  "JOIN usuario u ON u.id_usuario = r.id_usuario JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
                  "WHERE r.fecha_reserva >= :hoy AND r.id_estado_reserva <> :cancelada ";
    bool preceptor = rolEs("Preceptor");
    if (!preceptor) sql += "AND r.id_usuario = :usuario ";
    sql += "ORDER BY ";
    if (preceptor) sql += "CASE WHEN e.nombre_estado = 'Pendiente' THEN 0 ELSE 1 END, ";
    sql += "r.fecha_reserva, r.hora_inicio";
    QSqlQuery q;
    q.prepare(sql);
    q.bindValue(":hoy", valorFecha(QDate::currentDate()));
    q.bindValue(":cancelada", idEstado("estado_reserva", "Cancelada"));
    if (!preceptor) q.bindValue(":usuario", idActual);
    q.exec();
    while (q.next()) {
        QString dia = QDate::fromString(q.value(1).toString(), "yyyy-MM-dd").toString("dd/MM");
        QString estado = q.value(6).toString();
        QString estadoTexto = estado;
        if (estado == "Pendiente") estadoTexto = "Pendiente de aprobación";
        QString texto = QString("%1 - %2 %3 a %4").arg(q.value(4).toString()).arg(dia).arg(q.value(2).toString()).arg(q.value(3).toString());
        texto += "\n" + estadoTexto + " - " + q.value(5).toString();
        agregarItem(ui->listSectores, texto, q.value(0).toInt(), q.value(7).toInt());
        ui->listSectores->item(ui->listSectores->count() - 1)->setToolTip(texto);
        if (estado == "Aprobada") pintarUltimo(ui->listSectores, "ok");
        else if (estado == "Rechazada") pintarUltimo(ui->listSectores, "peligro");
        else pintarUltimo(ui->listSectores, "suave");
    }
    if (ui->listSectores->count() == 0) {
        if (preceptor) agregarVacio(ui->listSectores, "No hay reservas próximas.");
        else agregarVacio(ui->listSectores, "Todavía no tenés reservas próximas. Elegí un lugar, un día y un horario para reservar.");
    }
}

void MainWindow::on_cbSectoresLugar_currentIndexChanged(int) { cargarOcupacion(); }
void MainWindow::on_deSectoresDia_dateChanged(const QDate &) { cargarOcupacion(); }

void MainWindow::on_btnSectoresReservar_clicked()
{
    if (!exigir("Profesor,Preceptor", "Reserva de sector", "reserva_sector")) return;
    int sector = ui->cbSectoresLugar->currentData().toInt();
    QDate dia = ui->deSectoresDia->date();
    QString inicio = ui->teSectoresInicio->time().toString("HH:mm");
    QString fin = ui->teSectoresFin->time().toString("HH:mm");
    if (sector <= 0) {
        fallar("Reserva de sector", "reserva_sector", "Elegí un sector para reservar.");
        return;
    }
    QString tipoSector = valorUnico("SELECT t.nombre_tipo FROM sector s JOIN tipo_sector t "
                                    "ON t.id_tipo_sector = s.id_tipo_sector WHERE s.id_sector = :id", sector);
    if (tipoSector != "Reservable") {
        fallar("Reserva de sector", "reserva_sector", "Ese sector no se puede reservar.");
        return;
    }
    if (dia < QDate::currentDate()) {
        fallar("Reserva de sector", "reserva_sector", "No se puede reservar en una fecha que ya pasó.");
        return;
    }
    if (fin <= inicio) {
        ui->teSectoresFin->setFocus();
        fallar("Reserva de sector", "reserva_sector", "La hora de fin tiene que ser después de la de inicio.");
        return;
    }
    if (inicio < HORA_APERTURA || fin > HORA_CIERRE) {
        fallar("Reserva de sector", "reserva_sector", QString("El horario tiene que estar entre %1 y %2.").arg(HORA_APERTURA).arg(HORA_CIERRE));
        return;
    }
    if (dia == QDate::currentDate() && ui->teSectoresInicio->time() < QTime::currentTime()) {
        ui->teSectoresInicio->setFocus();
        fallar("Reserva de sector", "reserva_sector", "Ese horario de inicio ya pasó. Elegí uno más tarde.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT r.hora_inicio, r.hora_fin, u.nombre_completo FROM reserva_sector r JOIN usuario u ON u.id_usuario = r.id_usuario "
              "WHERE r.id_sector = :sector AND r.fecha_reserva = :fecha AND r.id_estado_reserva IN (:pendiente, :aprobada) "
              "AND r.hora_inicio < :fin AND r.hora_fin > :inicio");
    q.bindValue(":sector", sector);
    q.bindValue(":fecha", valorFecha(dia));
    q.bindValue(":pendiente", idEstado("estado_reserva", "Pendiente"));
    q.bindValue(":aprobada", idEstado("estado_reserva", "Aprobada"));
    q.bindValue(":fin", fin);
    q.bindValue(":inicio", inicio);
    q.exec();
    if (q.next()) {
        fallar("Reserva de sector", "reserva_sector", QString("Ese horario está ocupado: %1 tiene el sector de %2 a %3. Probá con otro.")
               .arg(q.value(2).toString()).arg(q.value(0).toString()).arg(q.value(1).toString()));
        return;
    }
    bool esPreceptor = rolEs("Preceptor");
    QString estado = "Pendiente";
    QVariant autorizador;
    if (esPreceptor) {
        estado = "Aprobada";
        autorizador = idActual;
    }
    q.prepare("INSERT INTO reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) "
              "VALUES (:fecha, :inicio, :fin, :usuario, :sector, :estado, :autorizador)");
    q.bindValue(":fecha", valorFecha(dia));
    q.bindValue(":inicio", inicio);
    q.bindValue(":fin", fin);
    q.bindValue(":usuario", idActual);
    q.bindValue(":sector", sector);
    q.bindValue(":estado", idEstado("estado_reserva", estado));
    q.bindValue(":autorizador", autorizador);
    if (!q.exec()) {
        fallar("Reserva de sector", "reserva_sector", "No se pudo guardar la reserva. Probá de nuevo.");
        return;
    }
    registrarLog("Reserva de sector", QString("Reserva %1 de %2 a %3 (%4)").arg(dia.toString("dd/MM")).arg(inicio).arg(fin).arg(estado), "reserva_sector", "Exitoso");
    cargarOcupacion();
    cargarReservasSector();
    if (esPreceptor) info("Reserva aprobada.");
    else info("Reserva enviada. Queda pendiente hasta que un preceptor la apruebe.");
}

void MainWindow::on_btnSectoresCancelar_clicked()
{
    if (!exigir("Profesor,Preceptor", "", "")) return;
    int reserva = seleccionado(ui->listSectores);
    int dueno = seleccionado(ui->listSectores, Qt::UserRole + 1);
    if (reserva == 0) {
        fallar("", "", "Elegí una reserva de la lista.");
        return;
    }
    if (dueno != idActual && !rolEs("Preceptor")) {
        fallar("", "", "Solo podés cancelar tus propias reservas.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM reserva_sector r JOIN estado_reserva e "
                                "ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = :id", reserva);
    if (estado != "Pendiente" && estado != "Aprobada") {
        fallar("", "", "Esa reserva ya está rechazada o cancelada.");
        return;
    }
    QString detalle = ui->listSectores->currentItem()->text().split("\n").first();
    QString pregunta = QString("¿Querés cancelar la reserva de %1? El horario queda libre para otros.").arg(detalle);
    if (!confirmar("Cancelar reserva", pregunta)) return;
    QSqlQuery q;
    q.prepare("UPDATE reserva_sector SET id_estado_reserva = :estado WHERE id_reserva = :reserva");
    q.bindValue(":estado", idEstado("estado_reserva", "Cancelada"));
    q.bindValue(":reserva", reserva);
    if (!q.exec()) {
        fallar("", "", "No se pudo cancelar la reserva. Probá de nuevo.");
        return;
    }
    cargarOcupacion();
    cargarReservasSector();
}

void MainWindow::resolverReservaSector(const QString &estado, const QString &evento)
{
    if (!exigir("Preceptor", evento, "reserva_sector")) return;
    int reserva = seleccionado(ui->listSectores);
    if (reserva == 0) {
        fallar(evento, "reserva_sector", "Elegí una reserva de la lista.");
        return;
    }
    QString actual = valorUnico("SELECT e.nombre_estado FROM reserva_sector r JOIN estado_reserva e "
                                "ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = :id", reserva);
    if (actual != "Pendiente") {
        fallar(evento, "reserva_sector", "Solo se pueden aprobar o rechazar reservas pendientes.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE reserva_sector SET id_estado_reserva = :estado, id_usuario_autorizador = :autorizador WHERE id_reserva = :reserva");
    q.bindValue(":estado", idEstado("estado_reserva", estado));
    q.bindValue(":autorizador", idActual);
    q.bindValue(":reserva", reserva);
    if (!q.exec()) {
        fallar(evento, "reserva_sector", "No se pudo actualizar la reserva. Probá de nuevo.");
        return;
    }
    registrarLog(evento, QString("Reserva %1: %2").arg(reserva).arg(estado), "reserva_sector", "Exitoso");
    cargarOcupacion();
    cargarReservasSector();
}

void MainWindow::on_btnSectoresAprobar_clicked() { resolverReservaSector("Aprobada", "Reserva de sector"); }
void MainWindow::on_btnSectoresRechazar_clicked()
{
    int reserva = seleccionado(ui->listSectores);
    if (rolEs("Preceptor") && reserva != 0) {
        QString estado = valorUnico("SELECT e.nombre_estado FROM reserva_sector r JOIN estado_reserva e "
                                    "ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = :id", reserva);
        if (estado == "Pendiente") {
            QString detalle = ui->listSectores->currentItem()->text().split("\n").first();
            QString pregunta = QString("¿Querés rechazar la reserva de %1? El horario queda libre.").arg(detalle);
            if (!confirmar("Rechazar reserva", pregunta)) return;
        }
    }
    resolverReservaSector("Rechazada", "Reserva de sector");
}

QString MainWindow::chocaFranja(int dia, int franja, int curso)
{
    QSqlQuery q;
    q.prepare("SELECT MIN(m.nombre_materia) FROM franja_horaria f JOIN horario_dia hd ON hd.id_dia = :dia "
              "JOIN horario_escolar he ON he.id_bloque = hd.id_bloque JOIN materia m ON m.id_materia = he.id_materia "
              "WHERE f.id_franja = :franja AND he.id_curso = :curso AND he.hora_inicio < f.hora_fin AND he.hora_fin > f.hora_inicio");
    q.bindValue(":dia", dia);
    q.bindValue(":franja", franja);
    q.bindValue(":curso", curso);
    q.exec();
    q.next();
    return q.value(0).toString();
}

QString MainWindow::chocaHorario(int oferta, int curso)
{
    QSqlQuery q;
    q.prepare("SELECT id_dia, id_franja FROM oferta_deporte WHERE id_oferta = :oferta");
    q.bindValue(":oferta", oferta);
    q.exec();
    if (!q.next()) return "";
    return chocaFranja(q.value(0).toInt(), q.value(1).toInt(), curso);
}

int MainWindow::ofertaElegida()
{
    QSqlQuery q;
    q.prepare("SELECT id_oferta FROM oferta_deporte WHERE id_deporte = :deporte AND id_dia = :dia AND id_franja = :franja");
    q.bindValue(":deporte", ui->cbEdFisicaDeporte->currentData().toInt());
    q.bindValue(":dia", ui->cbEdFisicaDia->currentData().toInt());
    q.bindValue(":franja", ui->cbEdFisicaHora->currentData().toInt());
    q.exec();
    if (q.next()) return q.value(0).toInt();
    return 0;
}

void MainWindow::cargarDiasEdFisica()
{
    int dia = ui->cbEdFisicaDia->currentData().toInt();
    int deporte = ui->cbEdFisicaDeporte->currentData().toInt();
    ui->cbEdFisicaDia->blockSignals(true);
    ui->cbEdFisicaDia->clear();
    QSqlQuery q;
    q.prepare("SELECT d.id_dia, d.nombre_dia, (SELECT COUNT(*) FROM oferta_deporte o WHERE o.id_dia = d.id_dia AND o.id_deporte = :deporte) "
              "FROM dia_semana d ORDER BY d.id_dia");
    q.bindValue(":deporte", deporte);
    q.exec();
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM usuario WHERE id_usuario = :id", idActual).toInt();
    int primero = -1;
    int elegido = -1;
    while (q.next()) {
        int id = q.value(0).toInt();
        int fila = ui->cbEdFisicaDia->count();
        bool hayLibre = false;
        if (q.value(2).toInt() > 0) {
            QSqlQuery f;
            f.prepare("SELECT id_franja FROM oferta_deporte WHERE id_dia = :dia AND id_deporte = :deporte");
            f.bindValue(":dia", id);
            f.bindValue(":deporte", deporte);
            f.exec();
            while (f.next() && !hayLibre) {
                if (chocaFranja(id, f.value(0).toInt(), curso).isEmpty()) hayLibre = true;
            }
        }
        if (hayLibre) {
            ui->cbEdFisicaDia->addItem(q.value(1).toString(), id);
            if (primero < 0) primero = fila;
            if (id == dia) elegido = fila;
        } else {
            QString motivo = " (sin clase)";
            if (q.value(2).toInt() > 0) motivo = " (choca con tu horario)";
            ui->cbEdFisicaDia->addItem(q.value(1).toString() + motivo, id);
            ui->cbEdFisicaDia->setItemData(fila, 0, Qt::UserRole - 1);
            ui->cbEdFisicaDia->setItemData(fila, QBrush(colorToken("suave")), Qt::ForegroundRole);
        }
    }
    if (elegido >= 0) ui->cbEdFisicaDia->setCurrentIndex(elegido);
    else if (primero >= 0) ui->cbEdFisicaDia->setCurrentIndex(primero);
    else ui->cbEdFisicaDia->setCurrentIndex(-1);
    ui->cbEdFisicaDia->blockSignals(false);
    cargarFranjas();
}

void MainWindow::cargarFranjas()
{
    int franja = ui->cbEdFisicaHora->currentData().toInt();
    int dia = ui->cbEdFisicaDia->currentData().toInt();
    int deporte = ui->cbEdFisicaDeporte->currentData().toInt();
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM usuario WHERE id_usuario = :id", idActual).toInt();
    ui->cbEdFisicaHora->blockSignals(true);
    ui->cbEdFisicaHora->clear();
    QSqlQuery q;
    q.prepare("SELECT f.id_franja, f.hora_inicio, f.hora_fin, "
              "(SELECT COUNT(*) FROM oferta_deporte o WHERE o.id_franja = f.id_franja AND o.id_dia = :dia AND o.id_deporte = :deporte) "
              "FROM franja_horaria f ORDER BY f.hora_inicio");
    q.bindValue(":dia", dia);
    q.bindValue(":deporte", deporte);
    q.exec();
    int primera = -1;
    int elegida = -1;
    while (q.next()) {
        int id = q.value(0).toInt();
        int fila = ui->cbEdFisicaHora->count();
        QString texto = q.value(1).toString() + " a " + q.value(2).toString();
        bool hayClase = q.value(3).toInt() > 0;
        QString materia = "";
        if (hayClase) materia = chocaFranja(dia, id, curso);
        if (hayClase && materia.isEmpty()) {
            ui->cbEdFisicaHora->addItem(texto, id);
            if (primera < 0) primera = fila;
            if (id == franja) elegida = fila;
        } else {
            QString motivo = " (sin clase)";
            if (hayClase) motivo = " (choca con " + materia + ")";
            ui->cbEdFisicaHora->addItem(texto + motivo, id);
            ui->cbEdFisicaHora->setItemData(fila, 0, Qt::UserRole - 1);
            ui->cbEdFisicaHora->setItemData(fila, QBrush(colorToken("suave")), Qt::ForegroundRole);
        }
    }
    if (elegida >= 0) ui->cbEdFisicaHora->setCurrentIndex(elegida);
    else if (primera >= 0) ui->cbEdFisicaHora->setCurrentIndex(primera);
    else ui->cbEdFisicaHora->setCurrentIndex(-1);
    ui->cbEdFisicaHora->blockSignals(false);
    mostrarEstadoEdFisica();
}

void MainWindow::mostrarEstadoEdFisica()
{
    int oferta = ofertaElegida();
    if (oferta == 0) {
        ui->lblEdFisicaEstado->setText("No hay clase de ese deporte en ese día y horario. Probá con otra combinación.");
        ui->btnEdFisicaInscribir->setEnabled(false);
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT o.cupo_maximo, (SELECT COUNT(*) FROM inscripcion_ed_fisica i WHERE i.id_oferta = o.id_oferta) "
              "FROM oferta_deporte o WHERE o.id_oferta = :oferta");
    q.bindValue(":oferta", oferta);
    q.exec();
    q.next();
    int maximo = q.value(0).toInt();
    int libres = maximo - q.value(1).toInt();
    int miOferta = valorUnico("SELECT id_oferta FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt();
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM usuario WHERE id_usuario = :id", idActual).toInt();
    QString materia = chocaHorario(oferta, curso);
    bool puede = true;
    QString texto = QString("Hay lugar. Cupos libres: %1 de %2.").arg(libres).arg(maximo);
    if (libres <= 0) {
        texto = "No hay lugar: todos los cupos están ocupados.";
        puede = false;
    }
    if (!materia.isEmpty()) {
        texto += " Choca con " + materia + " en tu horario.";
        puede = false;
    }
    if (miOferta == oferta) {
        texto = "Ya estás inscripto a esta opción.";
        puede = false;
    } else if (miOferta > 0) {
        texto += " Ya tenés otra inscripción: cancelala para elegir esta.";
        puede = false;
    }
    ui->lblEdFisicaEstado->setText(texto);
    ui->btnEdFisicaInscribir->setEnabled(puede);
}

void MainWindow::on_cbEdFisicaDeporte_currentIndexChanged(int) { cargarDiasEdFisica(); }
void MainWindow::on_cbEdFisicaDia_currentIndexChanged(int) { cargarFranjas(); }
void MainWindow::on_cbEdFisicaHora_currentIndexChanged(int) { mostrarEstadoEdFisica(); }

void MainWindow::cargarEdFisica()
{
    QSqlQuery m;
    m.prepare("SELECT d.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin FROM inscripcion_ed_fisica i "
              "JOIN oferta_deporte o ON o.id_oferta = i.id_oferta JOIN deporte d ON d.id_deporte = o.id_deporte "
              "JOIN dia_semana ds ON ds.id_dia = o.id_dia JOIN franja_horaria f ON f.id_franja = o.id_franja WHERE i.id_usuario = :usuario");
    m.bindValue(":usuario", idActual);
    m.exec();
    bool inscripto = m.next();
    if (inscripto) {
        ui->lblEdFisicaMia->setText(m.value(0).toString());
        ui->lblEdFisicaMiaDetalle->setText(m.value(1).toString() + " de " + m.value(2).toString() + " a " + m.value(3).toString() + " hs");
    } else {
        ui->lblEdFisicaMia->setText("Todavía no te inscribiste.");
        ui->lblEdFisicaMiaDetalle->setText("Elegí deporte, día y hora, y tocá Inscribirme.");
    }
    ui->btnEdFisicaCancelar->setEnabled(inscripto);
    cargarDiasEdFisica();
}

void MainWindow::on_btnEdFisicaInscribir_clicked()
{
    if (!exigir("Alumno", "Inscripción a Ed. Física", "inscripcion_ed_fisica")) return;
    int oferta = ofertaElegida();
    if (oferta == 0) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "No hay clase de ese deporte en ese día y horario. Probá con otra combinación.");
        return;
    }
    if (valorUnico("SELECT COUNT(*) FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt() > 0) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Ya estás inscripto. Cancelá tu inscripción antes de elegir otra.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT o.cupo_maximo, (SELECT COUNT(*) FROM inscripcion_ed_fisica i WHERE i.id_oferta = o.id_oferta) "
              "FROM oferta_deporte o WHERE o.id_oferta = :oferta");
    q.bindValue(":oferta", oferta);
    q.exec();
    q.next();
    if (q.value(1).toInt() >= q.value(0).toInt()) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Esa opción ya no tiene cupo.");
        return;
    }
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM usuario WHERE id_usuario = :id", idActual).toInt();
    QString materia = chocaHorario(oferta, curso);
    if (!materia.isEmpty()) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Esa opción se superpone con " + materia + " en tu horario.");
        return;
    }
    q.prepare("INSERT INTO inscripcion_ed_fisica (fecha_inscripcion, id_usuario, id_oferta) VALUES (:fecha, :usuario, :oferta)");
    q.bindValue(":fecha", valorFecha(QDate::currentDate()));
    q.bindValue(":usuario", idActual);
    q.bindValue(":oferta", oferta);
    if (!q.exec()) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "No se pudo guardar la inscripción.");
        return;
    }
    registrarLog("Inscripción a Ed. Física", QString("Inscripción a la oferta %1").arg(oferta), "inscripcion_ed_fisica", "Exitoso");
    cargarEdFisica();
    info("¡Listo! Quedaste inscripto.");
}

void MainWindow::on_btnEdFisicaCancelar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    if (valorUnico("SELECT COUNT(*) FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt() == 0) {
        fallar("", "", "No tenés ninguna inscripción para cancelar.");
        return;
    }
    QString deporte = ui->lblEdFisicaMia->text();
    if (!confirmar("Cancelar inscripción", QString("¿Querés cancelar tu inscripción a %1? Después vas a poder elegir otra opción.").arg(deporte))) return;
    QSqlQuery q;
    q.prepare("DELETE FROM inscripcion_ed_fisica WHERE id_usuario = :usuario");
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo cancelar la inscripción. Probá de nuevo.");
        return;
    }
    cargarEdFisica();
    info("Inscripción cancelada.");
}

void MainWindow::cargarAuditoria()
{
    ui->listAuditoria->clear();
    if (!rolEs("Preceptor")) return;
    QString resultado = ui->cbAuditoriaResultado->currentText();
    QString sql = "SELECT l.fecha_hora, u.nombre_completo, t.nombre_evento, r.nombre_resultado, l.descripcion_evento "
                  "FROM log_auditoria l JOIN tipo_log t ON t.id_tipo_log = l.id_tipo_log "
                  "JOIN resultado_log r ON r.id_resultado = l.id_resultado "
                  "LEFT JOIN usuario u ON u.id_usuario = l.id_usuario ";
    if (resultado != "Todos") sql += "WHERE r.nombre_resultado = :resultado ";
    sql += "ORDER BY l.fecha_hora DESC, l.id_log DESC";
    QSqlQuery q;
    q.prepare(sql);
    if (resultado != "Todos") q.bindValue(":resultado", resultado);
    q.exec();
    int mostrados = 0;
    while (q.next() && mostrados < 50) {
        QString usuario = "desconocido";
        if (!q.value(1).isNull()) usuario = q.value(1).toString();
        QString texto = QString("%1 · %2 · %3 · %4\n%5").arg(formatoCorto(q.value(0).toString())).arg(usuario)
                            .arg(q.value(2).toString()).arg(q.value(3).toString()).arg(q.value(4).toString());
        agregarItem(ui->listAuditoria, texto, 0);
        if (q.value(3).toString() == "Fallido") pintarUltimo(ui->listAuditoria, "peligro");
        mostrados++;
    }
    if (mostrados == 0) agregarVacio(ui->listAuditoria, "No hay registros para este filtro.");
}

void MainWindow::on_cbAuditoriaResultado_currentIndexChanged(int) { cargarAuditoria(); }

void MainWindow::on_tabObjetos_currentChanged(int indice)
{
    if (indice == 4) cargarAuditoria();
}


void MainWindow::mostrarProgramas()
{
    int recurso = seleccionado(ui->listPlanillas);
    if (recurso == 0) {
        ui->lblPlanillasProgramas->setText("Programas instalados: elegí un equipo de la lista.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT s.nombre_software FROM recurso_software rs JOIN software s ON s.id_software = rs.id_software "
              "WHERE rs.id_recurso = :recurso ORDER BY s.nombre_software");
    q.bindValue(":recurso", recurso);
    q.exec();
    QStringList programas;
    while (q.next()) {
        programas << q.value(0).toString();
    }
    if (programas.isEmpty()) ui->lblPlanillasProgramas->setText("Programas instalados: todavía no hay ninguno registrado.");
    else ui->lblPlanillasProgramas->setText("Programas instalados: " + programas.join(", "));
}

void MainWindow::on_listPlanillas_currentRowChanged(int) { mostrarProgramas(); }

void MainWindow::on_cbPlanillasPrograma_currentIndexChanged(int) { cargarPlanillas(); }

void MainWindow::on_cbHigieneFiltro_currentIndexChanged(int) { cargarHigiene(); }

void MainWindow::on_stackedWidget_currentChanged(int pagina)
{
    bool conMenu = pagina >= PAG_DASHBOARD;
    ui->barraLateral->setVisible(conMenu);
    ui->barraSuperior->setVisible(conMenu);
    QStringList titulos;
    titulos << "" << "" << "Inicio" << "Objetos perdidos" << "Higiene y mantenimiento" << "Tienda de alumnos"
            << "Préstamo de equipos" << "Reserva de sectores" << "Educación Física" << "Mi cuenta";
    ui->lblTituloPagina->setText(titulos[pagina]);
    if (pagina == PAG_DASHBOARD) {
        ui->btnNavInicio->setChecked(true);
        if (idActual > 0) cargarResumen();
    }
    if (pagina == PAG_OBJETOS) ui->btnNavObjetos->setChecked(true);
    if (pagina == PAG_HIGIENE) ui->btnNavHigiene->setChecked(true);
    if (pagina == PAG_BUFFET) ui->btnNavBuffet->setChecked(true);
    if (pagina == PAG_PLANILLAS) ui->btnNavPlanillas->setChecked(true);
    if (pagina == PAG_SECTORES) ui->btnNavSectores->setChecked(true);
    if (pagina == PAG_EDFISICA) ui->btnNavEdFisica->setChecked(true);
    if (pagina == PAG_CUENTA) ui->btnNavCuenta->setChecked(true);
}

void MainWindow::on_btnNavInicio_clicked() { ui->stackedWidget->setCurrentIndex(PAG_DASHBOARD); }
void MainWindow::on_btnNavObjetos_clicked() { ui->stackedWidget->setCurrentIndex(PAG_OBJETOS); }
void MainWindow::on_btnNavHigiene_clicked() { ui->stackedWidget->setCurrentIndex(PAG_HIGIENE); }
void MainWindow::on_btnNavBuffet_clicked() { ui->stackedWidget->setCurrentIndex(PAG_BUFFET); }
void MainWindow::on_btnNavPlanillas_clicked() { ui->stackedWidget->setCurrentIndex(PAG_PLANILLAS); }
void MainWindow::on_btnNavSectores_clicked() { ui->stackedWidget->setCurrentIndex(PAG_SECTORES); }
void MainWindow::on_btnNavEdFisica_clicked() { ui->stackedWidget->setCurrentIndex(PAG_EDFISICA); }
void MainWindow::on_btnNavCuenta_clicked() { irACuenta(); }
void MainWindow::on_btnNavSalir_clicked() { cerrarSesion(); }

void MainWindow::on_btnTema_clicked()
{
    aplicarTema(!temaOscuro);
    QSettings ajustes("IQUAL", "SGE");
    if (temaOscuro) ajustes.setValue("tema", "oscuro");
    else ajustes.setValue("tema", "claro");
}

void MainWindow::aplicarTema(bool oscuro)
{
    temaOscuro = oscuro;
    QFile archivo(":/tema/claro.qss");
    if (oscuro) archivo.setFileName(":/tema/oscuro.qss");
    if (archivo.open(QIODevice::ReadOnly)) {
        qApp->setStyleSheet(QString::fromUtf8(archivo.readAll()));
        archivo.close();
    }
    if (oscuro) {
        ui->btnTema->setText("Tema claro");
        ponerIcono(ui->btnTema, ":/iconos/barra_oscuro_sol.png", 18);
    } else {
        ui->btnTema->setText("Tema oscuro");
        ponerIcono(ui->btnTema, ":/iconos/barra_claro_luna.png", 18);
    }
    if (idActual != 0) {
        cargarObjetos();
        cargarReclamos();
        cargarPlanillas();
        cargarPrestamos();
        cargarAuditoria();
        cargarHigiene();
        cargarOcupacion();
        cargarReservasSector();
        cargarBuffet();
        cargarMisReservas();
        cargarMisVentas();
        cargarMisProductos();
        cargarDiasEdFisica();
    }
}

void MainWindow::cargarResumen()
{
    QString rol = rolActual();
    QString t1 = "";
    QString t2 = "";
    QString t3 = "";
    QString s1 = "";
    QString s2 = "";
    QString s3 = "";
    if (rol == "Alumno") {
        t1 = "Tus reclamos de objetos";
        s1 = "SELECT COUNT(*) FROM reclamo_objeto WHERE id_usuario = :id";
        t2 = "Tus reservas en la tienda";
        s2 = "SELECT COUNT(*) FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta "
             "WHERE v.id_usuario = :id AND e.nombre_estado = 'Reservada'";
        t3 = "Préstamos activos a tu nombre";
        s3 = "SELECT COUNT(*) FROM prestamo_ct WHERE id_usuario_solicitante = :id AND hora_devolucion IS NULL";
    } else if (rol == "Preceptor") {
        t1 = "Reclamos de objetos pendientes";
        s1 = "SELECT COUNT(*) FROM reclamo_objeto r JOIN estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
        t2 = "Reservas de sectores pendientes";
        s2 = "SELECT COUNT(*) FROM reserva_sector r JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
             "WHERE e.nombre_estado = 'Pendiente' AND r.fecha_reserva >= :hoy AND :id > 0";
        t3 = "Reportes de higiene pendientes";
        s3 = "SELECT COUNT(*) FROM reporte_higiene r JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
    } else if (rol == "Profesor") {
        t1 = "Tus reservas de sectores";
        s1 = "SELECT COUNT(*) FROM reserva_sector r JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
             "WHERE r.id_usuario = :id AND e.nombre_estado IN ('Pendiente', 'Aprobada') AND r.fecha_reserva >= :hoy";
        t2 = "Reportes de higiene pendientes";
        s2 = "SELECT COUNT(*) FROM reporte_higiene r JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
        t3 = "Préstamos activos en el colegio";
        s3 = "SELECT COUNT(*) FROM prestamo_ct WHERE hora_devolucion IS NULL AND :id > 0";
    } else {
        t1 = "Reportes de higiene pendientes";
        s1 = "SELECT COUNT(*) FROM reporte_higiene r JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
        t2 = "Equipos fuera de servicio";
        s2 = "SELECT COUNT(*) FROM recursos_ct r JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso "
             "WHERE e.nombre_estado = 'Fuera de servicio' AND :id > 0";
        t3 = "Préstamos activos en el colegio";
        s3 = "SELECT COUNT(*) FROM prestamo_ct WHERE hora_devolucion IS NULL AND :id > 0";
    }
    ui->lblResumenTit1->setText(t1);
    ui->lblResumenTit2->setText(t2);
    ui->lblResumenTit3->setText(t3);
    ui->lblResumenNum1->setText(valorUnicoHoy(s1, idActual));
    ui->lblResumenNum2->setText(valorUnicoHoy(s2, idActual));
    ui->lblResumenNum3->setText(valorUnicoHoy(s3, idActual));
}


QColor MainWindow::colorToken(const QString &nombre)
{
    if (nombre == "ok") {
        if (temaOscuro) return QColor("#4ADE80");
        return QColor("#12703A");
    }
    if (nombre == "peligro") {
        if (temaOscuro) return QColor("#F87171");
        return QColor("#C62828");
    }
    if (nombre == "seleccion") {
        if (temaOscuro) return QColor("#1D3A6B");
        return QColor("#E3EAFB");
    }
    if (temaOscuro) return QColor("#9FB0CC");
    return QColor("#546480");
}

void MainWindow::elegirPorId(QComboBox *combo, int id)
{
    combo->blockSignals(true);
    for (int i = 0; i < combo->count(); i++) {
        if (combo->itemData(i).toInt() == id) combo->setCurrentIndex(i);
    }
    combo->blockSignals(false);
}

QString MainWindow::plural(int cantidad, const QString &uno, const QString &varios)
{
    if (cantidad == 1) return "1 " + uno;
    return QString::number(cantidad) + " " + varios;
}

void MainWindow::alternarVacio(QListWidget *lista, QLabel *vacio)
{
    bool hay = lista->count() > 0;
    lista->setVisible(hay);
    vacio->setVisible(!hay);
}

void MainWindow::pintarEstadoVenta(QListWidgetItem *item, const QString &estado)
{
    if (estado == "Entregada") item->setForeground(QBrush(colorToken("ok")));
    else if (estado == "Cancelada") item->setForeground(QBrush(colorToken("peligro")));
    else item->setForeground(QBrush(colorToken("suave")));
}

QPixmap MainWindow::miniaturaProducto(const QString &ruta)
{
    QPixmap foto(QCoreApplication::applicationDirPath() + "/imagenes_productos/" + ruta);
    if (ruta.isEmpty() || foto.isNull()) foto = QPixmap(":/iconos/tarj_tienda.png");
    return foto.scaled(160, 160, Qt::KeepAspectRatio, Qt::SmoothTransformation);
}

void MainWindow::cargarVendedores()
{
    int actual = ui->cbBuffetVendedor->currentData().toInt();
    cargarCombo(ui->cbBuffetVendedor, "SELECT DISTINCT u.id_usuario, u.nombre_completo FROM usuario u "
                                      "JOIN producto_buffet p ON p.id_usuario = u.id_usuario ORDER BY u.nombre_completo",
                "Todos los vendedores", "");
    elegirPorId(ui->cbBuffetVendedor, actual);
}

void MainWindow::mostrarSeleccionBuffet()
{
    int producto = seleccionado(ui->listBuffet);
    ui->sbBuffetCantidad->setMaximum(1);
    ui->sbBuffetCantidad->setValue(1);
    ui->sbBuffetCantidad->setEnabled(producto > 0);
    ui->btnBuffetReservar->setEnabled(producto > 0);
    if (producto == 0) {
        ui->lblBuffetSeleccion->setText("Elegí un producto para reservarlo. Con doble clic ves la foto en grande.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT p.nombre_producto, p.precio, p.stock, p.id_usuario, u.nombre_completo, u.contacto_telefono "
              "FROM producto_buffet p JOIN usuario u ON u.id_usuario = p.id_usuario WHERE p.id_producto = :producto");
    q.bindValue(":producto", producto);
    q.exec();
    if (!q.next()) return;
    int stock = q.value(2).toInt();
    QString texto = QString("%1 · $%2 · vende %3 (tel. %4)").arg(q.value(0).toString()).arg(q.value(1).toInt())
            .arg(q.value(4).toString()).arg(q.value(5).toString());
    if (stock == 0) texto += " · SIN STOCK";
    if (q.value(3).toInt() == idActual) texto += " · es tu producto";
    ui->lblBuffetSeleccion->setText(texto);
    if (stock > 0) ui->sbBuffetCantidad->setMaximum(stock);
}

void MainWindow::cargarDonaciones()
{
    ui->listDonaciones->clear();
    int grupo = ui->cbDonarGrupo->currentData().toInt();
    if (grupo == 0) {
        ui->pbGrupoMeta->setValue(0);
        ui->lblGrupoMeta->setText("Todavía no hay grupos de recaudación. Un alumno puede crear el primero.");
        alternarVacio(ui->listDonaciones, ui->lblDonacionesVacio);
        return;
    }
    QSqlQuery g;
    g.prepare("SELECT meta_monto FROM grupo_buffet WHERE id_grupo = :grupo");
    g.bindValue(":grupo", grupo);
    g.exec();
    if (!g.next()) return;
    int meta = g.value(0).toInt();
    int juntado = recaudado(grupo);
    int porcentaje = 0;
    if (meta > 0) porcentaje = juntado * 100 / meta;
    int avance = porcentaje;
    if (avance > 100) avance = 100;
    ui->pbGrupoMeta->setValue(avance);
    ui->lblGrupoMeta->setText(QString("Se recaudaron $%1 de $%2 (%3%)").arg(juntado).arg(meta).arg(porcentaje));

    QSqlQuery d;
    d.prepare("SELECT u.nombre_completo, o.monto, o.fecha_hora FROM donacion_buffet o JOIN usuario u ON u.id_usuario = o.id_usuario "
              "WHERE o.id_grupo = :grupo ORDER BY o.id_donacion DESC");
    d.bindValue(":grupo", grupo);
    d.exec();
    int mostradas = 0;
    while (d.next() && mostradas < 10) {
        agregarItem(ui->listDonaciones, QString("%1 donó $%2 · %3").arg(d.value(0).toString()).arg(d.value(1).toInt()).arg(formatoCorto(d.value(2).toString())), 0);
        mostradas++;
    }
    alternarVacio(ui->listDonaciones, ui->lblDonacionesVacio);
}

void MainWindow::mostrarFotoProducto()
{
    QPixmap foto(fotoProducto);
    if (fotoProducto.isEmpty() || foto.isNull()) {
        ui->lblProdFoto->setText("Sin foto");
        ui->lblProdFotoNombre->setText("La foto es opcional, pero ayuda a vender.");
        return;
    }
    ui->lblProdFoto->setPixmap(foto.scaled(ui->lblProdFoto->width() - 8, ui->lblProdFoto->height() - 8, Qt::KeepAspectRatio, Qt::SmoothTransformation));
    ui->lblProdFotoNombre->setText(QFileInfo(fotoProducto).fileName());
}

void MainWindow::on_btnProdFotoQuitar_clicked()
{
    fotoProducto = "";
    mostrarFotoProducto();
}

void MainWindow::on_cbBuffetVendedor_currentIndexChanged(int) { cargarBuffet(); }

void MainWindow::on_leBuffetBuscar_textChanged(const QString &) { cargarBuffet(); }

void MainWindow::on_cbDonarGrupo_currentIndexChanged(int) { cargarDonaciones(); }

void MainWindow::on_listBuffet_currentRowChanged(int) { mostrarSeleccionBuffet(); }

void MainWindow::pintarUltimo(QListWidget *lista, const QString &tono)
{
    int ultimo = lista->count() - 1;
    if (ultimo < 0) return;
    lista->item(ultimo)->setForeground(QBrush(colorToken(tono)));
}

void MainWindow::agregarVacio(QListWidget *lista, const QString &texto)
{
    agregarItem(lista, texto, 0);
    int ultimo = lista->count() - 1;
    lista->item(ultimo)->setFlags(Qt::ItemIsEnabled);
    pintarUltimo(lista, "suave");
}

void MainWindow::ponerDato(QComboBox *combo, int dato)
{
    combo->setCurrentIndex(0);
    for (int i = 0; i < combo->count(); i++) {
        if (combo->itemData(i).toInt() == dato) {
            combo->setCurrentIndex(i);
            return;
        }
    }
}

void MainWindow::actualizarPendientesHigiene()
{
    QSqlQuery q;
    q.prepare("SELECT COUNT(*) FROM reporte_higiene r JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
              "WHERE e.nombre_estado = :estado");
    q.bindValue(":estado", "Pendiente");
    q.exec();
    int pendientes = 0;
    if (q.next()) pendientes = q.value(0).toInt();
    if (pendientes == 0) ui->lblHigienePendientes->setText("No hay reportes pendientes. ¡Todo en orden!");
    else if (pendientes == 1) ui->lblHigienePendientes->setText("1 reporte pendiente de resolver");
    else ui->lblHigienePendientes->setText(QString("%1 reportes pendientes de resolver").arg(pendientes));
}

void MainWindow::on_leObjBuscar_textChanged(const QString &) { cargarObjetos(); }

void MainWindow::on_cbObjFiltroCategoria_currentIndexChanged(int) { cargarObjetos(); }

void MainWindow::on_leObjPrueba_returnPressed() { on_btnObjReclamar_clicked(); }

void MainWindow::on_leObjReservado_returnPressed() { on_btnObjPublicar_clicked(); }

void MainWindow::actualizarResumenPlanillas()
{
    int disponibles = 0;
    int prestados = 0;
    int fuera = 0;
    QSqlQuery q;
    q.prepare("SELECT e.nombre_estado, COUNT(*) FROM recursos_ct r JOIN estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso "
              "GROUP BY e.nombre_estado");
    q.exec();
    while (q.next()) {
        QString estado = q.value(0).toString();
        if (estado == "Disponible") disponibles = q.value(1).toInt();
        if (estado == "Prestado") prestados = q.value(1).toInt();
        if (estado == "Fuera de servicio") fuera = q.value(1).toInt();
    }
    ui->lblPlanillasResumen->setText(QString("Disponibles: %1 · Prestados: %2 · Fuera de servicio: %3").arg(disponibles).arg(prestados).arg(fuera));
}