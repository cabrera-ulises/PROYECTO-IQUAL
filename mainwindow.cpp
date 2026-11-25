#include "mainwindow.h"
#include <QRegularExpression>
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
    , conn(NULL)
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
    if (conn != NULL) mysql_close(conn);
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
        setWindowTitle(windowTitle() + " · MySQL");
        return true;
    }
    aviso("No se pudo usar MySQL:\n" + error + "\n\nRevisá iqual.ini y que el servidor esté encendido.");
    return false;
}

bool MainWindow::abrirMySql(QSettings &cfg, QString &error)
{
    conn = mysql_init(NULL);
    if (conn == NULL) {
        error = "No se pudo inicializar la conexión de MySQL (mysql_init).";
        return false;
    }
    mysql_options(conn, MYSQL_SET_CHARSET_NAME, "utf8mb4");
    QByteArray host = cfg.value("base/host").toString().toUtf8();
    QByteArray usuario = cfg.value("base/usuario").toString().toUtf8();
    QByteArray clave = cfg.value("base/clave").toString().toUtf8();
    QByteArray base = cfg.value("base/nombre").toString().toUtf8();
    unsigned int puerto = cfg.value("base/puerto").toUInt();
    if (mysql_real_connect(conn, host.constData(), usuario.constData(), clave.constData(), base.constData(), puerto, NULL, 0) == NULL) {
        error = QString::fromUtf8(mysql_error(conn));
        mysql_close(conn);
        conn = NULL;
        return false;
    }
    ejecutar("SET NAMES utf8mb4");
    MYSQL_RES *result = hacerSelect("SELECT COUNT(*) FROM seguridad.usuario");
    if (result == NULL) {
        error = "Los schemas de IQUAL no existen. Cargá 03_ModeloSQL_Grupo06.sql y 04_DatosSQL_Grupo06.sql desde DBeaver.";
        mysql_close(conn);
        conn = NULL;
        return false;
    }
    mysql_free_result(result);
    return true;
}

MYSQL_RES *MainWindow::hacerSelect(const QString &sql)
{
    if (mysql_query(conn, sql.toUtf8().constData()) != 0) return NULL;
    MYSQL_RES *result = mysql_store_result(conn);
    while (mysql_next_result(conn) == 0) {
        MYSQL_RES *resto = mysql_store_result(conn);
        if (resto != NULL) mysql_free_result(resto);
    }
    return result;
}

bool MainWindow::ejecutar(const QString &sql)
{
    if (mysql_query(conn, sql.toUtf8().constData()) != 0) return false;
    MYSQL_RES *result = mysql_store_result(conn);
    if (result != NULL) mysql_free_result(result);
    while (mysql_next_result(conn) == 0) {
        result = mysql_store_result(conn);
        if (result != NULL) mysql_free_result(result);
    }
    return true;
}

QString MainWindow::texto(const QString &valor)
{
    QByteArray origen = valor.toUtf8();
    QByteArray destino(origen.size() * 2 + 1, '\0');
    unsigned long largo = mysql_real_escape_string(conn, destino.data(), origen.constData(), origen.size());
    return "'" + QString::fromUtf8(destino.constData(), largo) + "'";
}

QString MainWindow::textoONulo(const QString &valor)
{
    if (valor.isEmpty()) return "NULL";
    return texto(valor);
}

QString MainWindow::numeroONulo(int numero)
{
    if (numero <= 0) return "NULL";
    return QString::number(numero);
}

int MainWindow::ultimoId()
{
    return mysql_insert_id(conn);
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
    cargarCombo(ui->cbRegRol, "SELECT id_rol, nombre_rol FROM seguridad.rol ORDER BY id_rol", "Elegí tu rol", "");
    cargarCursoCombos(ui->cbRegAnio, ui->cbRegDivision, ui->cbRegEspecialidad);
    cargarCursoCombos(ui->cbCuentaAnio, ui->cbCuentaDivision, ui->cbCuentaEspecialidad);
    cargarCombo(ui->cbHigieneSector, "SELECT id_sector, nombre_sector FROM instalaciones.sector ORDER BY nombre_sector", "", "");
    cargarCombo(ui->cbHigieneTipo, "SELECT id_tipo_reporte, nombre_tipo FROM instalaciones.tipo_reporte ORDER BY id_tipo_reporte", "", "");
    cargarCombo(ui->cbObjCategoria, "SELECT id_categoria_objeto, nombre_categoria FROM objetos.categoria_objeto ORDER BY nombre_categoria", "Elegí una categoría", "");
    cargarCombo(ui->cbObjFiltroCategoria, "SELECT id_categoria_objeto, nombre_categoria FROM objetos.categoria_objeto ORDER BY nombre_categoria", "Todas las categorías", "");
    cargarCombo(ui->cbObjSector, "SELECT id_sector, nombre_sector FROM instalaciones.sector ORDER BY nombre_sector", "Elegí un sector", "");
    cargarCombo(ui->cbBuffetCategoria, "SELECT id_categoria_producto, nombre_categoria FROM tienda.categoria_producto ORDER BY id_categoria_producto", "Todas", "");
    cargarCombo(ui->cbProdCategoria, "SELECT id_categoria_producto, nombre_categoria FROM tienda.categoria_producto ORDER BY id_categoria_producto", "", "");
    cargarCombo(ui->cbEdFisicaDeporte, "SELECT id_deporte, nombre_deporte FROM deportes.deporte ORDER BY nombre_deporte", "", "");
    cargarCombo(ui->cbEdFisicaDia, "SELECT id_dia, nombre_dia FROM academico.dia_semana ORDER BY id_dia", "", "");
    cargarCombo(ui->cbSectoresLugar, "SELECT s.id_sector, s.nombre_sector FROM instalaciones.sector s JOIN instalaciones.tipo_sector t ON t.id_tipo_sector = s.id_tipo_sector "
                                          "WHERE t.nombre_tipo = 'Reservable' ORDER BY s.nombre_sector", "", "");
    cargarCombo(ui->cbPlanillasPrograma, "SELECT id_software, nombre_software FROM equipos.software ORDER BY nombre_software", "Todos los programas", "");
    actualizarRegistro();
}

void MainWindow::cargarCursoCombos(QComboBox *anio, QComboBox *division, QComboBox *especialidad)
{
    cargarCombo(anio, "SELECT id_anio, numero_anio FROM academico.anio ORDER BY numero_anio", "Año", "°");
    cargarCombo(division, "SELECT id_division, numero_division FROM academico.division ORDER BY numero_division", "División", "°");
    cargarCombo(especialidad, "SELECT id_especialidad, nombre_especialidad FROM academico.especialidad ORDER BY nombre_especialidad", "Especialidad", "");
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
    cargarCombo(ui->cbPlanillasAlumno, "SELECT u.id_usuario, u.nombre_completo FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol "
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
    QString sql = "SELECT " + columnaId + " FROM " + tabla + " WHERE " + columnaNombre + " = " + texto(valor);
    MYSQL_RES *result = hacerSelect(sql);
    if (result == NULL) return 0;
    int id = 0;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila != NULL) id = QString(fila[0]).toInt();
    mysql_free_result(result);
    return id;
}

int MainWindow::idEstado(const QString &tabla, const QString &nombre)
{
    return idPorNombre(tabla, "id_" + tabla.section('.', -1), "nombre_estado", nombre);
}

QString MainWindow::valorUnico(const QString &sql, int id)
{
    QString consulta = sql;
    consulta.replace(":id", QString::number(id));
    MYSQL_RES *result = hacerSelect(consulta);
    if (result == NULL) return "";
    QString valor = "";
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila != NULL) valor = QString(fila[0]);
    mysql_free_result(result);
    return valor;
}

QString MainWindow::valorUnicoHoy(const QString &sql, int id)
{
    QString consulta = sql;
    consulta.replace(":hoy", valorFecha(QDate::currentDate()));
    return valorUnico(consulta, id);
}

bool MainWindow::existe(const QString &tabla, const QString &columna, const QString &valor)
{
    QString sql = "SELECT COUNT(*) FROM " + tabla + " WHERE " + columna + " = " + texto(valor);
    MYSQL_RES *result = hacerSelect(sql);
    if (result == NULL) return false;
    int cantidad = 0;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila != NULL) cantidad = QString(fila[0]).toInt();
    mysql_free_result(result);
    return cantidad > 0;
}

QString MainWindow::rolActual()
{
    return valorUnico("SELECT r.nombre_rol FROM seguridad.usuario u JOIN seguridad.rol r ON r.id_rol = u.id_rol WHERE u.id_usuario = :id", idActual);
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
    QString nick = "NULL";
    if (idActual > 0) {
        nick = texto(valorUnico("SELECT usuario_nick FROM seguridad.usuario WHERE id_usuario = :id", idActual));
    }
    QString sql = "CALL sp_registrar_log(" + texto(evento) + ", " + texto(descripcion) + ", " + texto(entidad) + ", "
                  + nick + ", " + texto(resultado) + ", " + texto(QSysInfo::machineHostName()) + ")";
    if (ejecutar(sql)) return;
    sql = "INSERT INTO seguridad.log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) VALUES ("
          + valorAhora() + ", " + texto(QSysInfo::machineHostName()) + ", " + texto(descripcion) + ", "
          + QString::number(idPorNombre("seguridad.entidad_log", "id_entidad", "nombre_entidad", entidad)) + ", "
          + numeroONulo(idActual) + ", "
          + QString::number(idPorNombre("seguridad.tipo_log", "id_tipo_log", "nombre_evento", evento)) + ", "
          + QString::number(idPorNombre("seguridad.resultado_log", "id_resultado", "nombre_resultado", resultado)) + ")";
    ejecutar(sql);
}

QString MainWindow::hashClave(const QString &clave)
{
    return QString::fromLatin1(QCryptographicHash::hash(clave.toUtf8(), QCryptographicHash::Sha256).toHex());
}

QString MainWindow::ahora()
{
    return QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
}

QString MainWindow::valorAhora()
{
    return texto(ahora());
}

QString MainWindow::valorFecha(const QDate &fecha)
{
    return texto(fecha.toString("yyyy-MM-dd"));
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
    MYSQL_RES *result = hacerSelect(sql);
    if (result != NULL) {
        MYSQL_ROW fila;
        while ((fila = mysql_fetch_row(result)) != NULL) {
            combo->addItem(QString(fila[1]) + sufijo, QString(fila[0]).toInt());
        }
        mysql_free_result(result);
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
    QString a = QString::number(anio->currentData().toInt());
    QString d = QString::number(division->currentData().toInt());
    QString e = QString::number(especialidad->currentData().toInt());
    int curso = valorUnico("SELECT id_curso FROM academico.curso WHERE id_anio = " + a + " AND id_division = " + d + " AND id_especialidad = " + e, 0).toInt();
    if (curso > 0) return curso;
    if (!ejecutar("INSERT INTO academico.curso (id_anio, id_division, id_especialidad) VALUES (" + a + ", " + d + ", " + e + ")")) return 0;
    return ultimoId();
}

QString MainWindow::textoCurso(int idCurso)
{
    if (idCurso <= 0) return "sin curso";
    MYSQL_RES *result = hacerSelect("SELECT a.numero_anio, d.numero_division, e.nombre_especialidad FROM academico.curso c "
                                    "JOIN academico.anio a ON a.id_anio = c.id_anio JOIN academico.division d ON d.id_division = c.id_division "
                                    "JOIN academico.especialidad e ON e.id_especialidad = c.id_especialidad WHERE c.id_curso = " + QString::number(idCurso));
    if (result == NULL) return "sin curso";
    QString resultado = "sin curso";
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila != NULL) resultado = QString("%1° %2° %3").arg(QString(fila[0]).toInt()).arg(QString(fila[1]).toInt()).arg(QString(fila[2]));
    mysql_free_result(result);
    return resultado;
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
    else if (nick.contains(QRegularExpression("\\s"))) problema = "El usuario no puede tener espacios.";
    else if (clave.size() < 4) problema = "La contraseña tiene que tener al menos 4 caracteres.";
    else if (clave.trimmed().isEmpty()) problema = "La contraseña no puede estar en blanco.";
    else if (!soloDigitos(dni, 7, 8)) problema = "El DNI tiene que tener 7 u 8 números, sin puntos.";
    else if (!QRegularExpression("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$").match(mail).hasMatch()) problema = "El correo no es válido. Tiene que ser algo como nombre@dominio.com.";
    else if (!soloDigitos(telefono, 8, 15)) problema = "El teléfono tiene que tener entre 8 y 15 números.";
    else if (!alumno && ui->leRegPin->text() != PIN_PERSONAL) problema = "El PIN de personal es incorrecto.";
    else if (existe("seguridad.usuario", "LOWER(usuario_nick)", nick)) problema = "Ese usuario ya existe, probá con otro.";
    else if (existe("seguridad.usuario", "dni", dni)) problema = "Ya hay una cuenta con ese DNI.";
    else if (existe("seguridad.usuario", "email", mail)) problema = "Ya hay una cuenta con ese correo.";
    if (!problema.isEmpty()) {
        fallar("Registro de usuario", "usuario", problema);
        return;
    }

    int curso = 0;
    if (alumno) {
        curso = obtenerCurso(ui->cbRegAnio, ui->cbRegDivision, ui->cbRegEspecialidad);
        if (curso == 0) {
            fallar("Registro de usuario", "usuario", "No se pudo guardar el curso elegido.");
            return;
        }
    }

    QString sql = "INSERT INTO seguridad.usuario (dni, nombre_completo, usuario_nick, password_hash, email, contacto_telefono, id_rol, id_curso) VALUES ("
                  + texto(dni) + ", " + texto(nombre) + ", " + texto(nick) + ", " + texto(hashClave(clave)) + ", " + texto(mail) + ", "
                  + texto(telefono) + ", " + QString::number(ui->cbRegRol->currentData().toInt()) + ", " + numeroONulo(curso) + ")";
    if (!ejecutar(sql)) {
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
    int encontrado = valorUnico("SELECT id_usuario FROM seguridad.usuario WHERE LOWER(usuario_nick) = " + texto(nick)
                                + " AND password_hash = " + texto(hashClave(clave)), 0).toInt();
    if (encontrado == 0) {
        intentosFallidos++;
        idActual = idPorNombre("seguridad.usuario", "id_usuario", "LOWER(usuario_nick)", nick);
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
    idActual = encontrado;
    ui->leUsuario->clear();
    ui->leClave->clear();
    registrarLog("Inicio de sesión", QString("Ingresó el usuario %1").arg(nick), "usuario", "Exitoso");
    cargarTodo();
    ui->stackedWidget->setCurrentIndex(PAG_DASHBOARD);
}

void MainWindow::cargarCuenta()
{
    MYSQL_RES *result = hacerSelect("SELECT u.nombre_completo, u.usuario_nick, u.dni, u.email, u.contacto_telefono, r.nombre_rol, "
                                    "u.id_curso, cu.id_anio, cu.id_division, cu.id_especialidad FROM seguridad.usuario u "
                                    "JOIN seguridad.rol r ON r.id_rol = u.id_rol LEFT JOIN academico.curso cu ON cu.id_curso = u.id_curso "
                                    "WHERE u.id_usuario = " + QString::number(idActual));
    if (result == NULL) return;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila == NULL) {
        mysql_free_result(result);
        return;
    }
    QString telefono = QString(fila[4]);
    if (telefono.isEmpty()) telefono = "Sin teléfono cargado";
    ui->lblBienvenida->setText(QString("Hola, %1").arg(QString(fila[0]).split(" ").first()));
    ui->lblUsuarioChip->setText(QString("%1 · %2").arg(QString(fila[0])).arg(QString(fila[5])));
    ui->lblCuentaNombre->setText(QString(fila[0]));
    ui->lblCuentaUsuario->setText(QString(fila[1]));
    ui->lblCuentaDni->setText(QString(fila[2]));
    ui->lblCuentaMail->setText(QString(fila[3]));
    ui->lblCuentaContacto->setText(telefono);
    ui->lblCuentaRol->setText(QString(fila[5]));
    int curso = QString(fila[6]).toInt();
    int anio = QString(fila[7]).toInt();
    int division = QString(fila[8]).toInt();
    int especialidad = QString(fila[9]).toInt();
    QString contacto = QString(fila[4]);
    mysql_free_result(result);
    ui->lblCuentaCurso->setText(textoCurso(curso));
    ponerDato(ui->cbCuentaAnio, anio);
    ponerDato(ui->cbCuentaDivision, division);
    ponerDato(ui->cbCuentaEspecialidad, especialidad);
    ui->lblProdContacto->setText("Tu contacto: " + contacto);
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
    int cursoActual = valorUnico("SELECT COALESCE(id_curso, 0) FROM seguridad.usuario WHERE id_usuario = :id", idActual).toInt();
    if (cursoActual == curso) {
        info("Ese ya es tu curso.");
        return;
    }
    int oferta = valorUnico("SELECT id_oferta FROM deportes.inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt();
    QString materia = "";
    if (oferta != 0) materia = chocaHorario(oferta, curso);
    if (!materia.isEmpty()) {
        QString pregunta = QString("Con ese curso, tu inscripción a Educación Física choca con %1 y se va a cancelar. ¿Querés cambiar de curso igual?").arg(materia);
        if (!confirmar("Cambiar de curso", pregunta)) {
            cargarCuenta();
            return;
        }
    }
    if (!ejecutar("UPDATE seguridad.usuario SET id_curso = " + QString::number(curso) + " WHERE id_usuario = " + QString::number(idActual))) {
        fallar("", "", "No se pudo cambiar tu curso. Probá de nuevo.");
        return;
    }
    bool cancelada = false;
    if (!materia.isEmpty()) {
        cancelada = ejecutar("DELETE FROM deportes.inscripcion_ed_fisica WHERE id_usuario = " + QString::number(idActual));
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
    QString guardada = valorUnico("SELECT password_hash FROM seguridad.usuario WHERE id_usuario = :id", idActual);
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
    if (!ejecutar("UPDATE seguridad.usuario SET password_hash = " + texto(hashClave(nueva)) + " WHERE id_usuario = " + QString::number(idActual))) {
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
    if (!ejecutar("UPDATE seguridad.usuario SET contacto_telefono = " + texto(telefono) + " WHERE id_usuario = " + QString::number(idActual))) {
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
                  "(SELECT COUNT(*) FROM objetos.reclamo_objeto r WHERE r.id_objeto = o.id_objeto) "
                  "FROM objetos.objeto_perdido o JOIN objetos.categoria_objeto c ON c.id_categoria_objeto = o.id_categoria_objeto "
                  "JOIN instalaciones.sector s ON s.id_sector = o.id_sector JOIN objetos.estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto "
                  "WHERE o.id_estado_objeto <> " + QString::number(idEstado("objetos.estado_objeto", "Archivado")) + " ";
    if (categoria > 0) sql += "AND o.id_categoria_objeto = " + QString::number(categoria) + " ";
    sql += "ORDER BY o.id_objeto DESC";
    MYSQL_RES *result = hacerSelect(sql);
    MYSQL_ROW fila;
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
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString estado = QString(fila[6]);
        QString conjunto = QString(fila[1]) + " " + QString(fila[2]) + " " + QString(fila[4]) + " " + QString(fila[5]);
        if (buscar.isEmpty() || conjunto.contains(buscar, Qt::CaseInsensitive)) {
            QString nombreEstado = estado;
            if (estado == "Devuelto") nombreEstado = "Ya devuelto";
            QString cantidad = "(" + plural(QString(fila[7]).toInt(), "reclamo", "reclamos") + ")";
            QString texto = QString("%1\n%2 · %3\n%4 · %5").arg(QString(fila[1])).arg(QString(fila[4]))
                                .arg(QString(fila[5])).arg(nombreEstado).arg(cantidad);
            agregarItem(ui->listObjetos, texto, QString(fila[0]).toInt());
            QListWidgetItem *item = ui->listObjetos->item(ui->listObjetos->count() - 1);
            QPixmap miniatura = vacia;
            QPixmap foto(carpeta + QString(fila[3]));
            if (!QString(fila[3]).isEmpty() && !foto.isNull()) miniatura = foto.scaled(96, 96, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            item->setIcon(QIcon(miniatura));
            if (estado == "Disponible") item->setForeground(QBrush(colorToken("ok")));
            else item->setForeground(QBrush(colorToken("suave")));
            if (estado == "Disponible") disponibles++;
            if (estado == "Devuelto") devueltos++;
            if (QString(fila[0]).toInt() == elegido) ui->listObjetos->setCurrentRow(ui->listObjetos->count() - 1);
        }
    }
    if (result != NULL) mysql_free_result(result);
    if (ui->listObjetos->count() == 0) {
        if (buscar.isEmpty() && categoria == 0) agregarVacio(ui->listObjetos, "Todavía no hay objetos publicados.");
        else agregarVacio(ui->listObjetos, "No hay objetos que coincidan con la búsqueda.");
    }
    QString resumen = QString("Objetos para reclamar: %1 · Ya devueltos: %2").arg(disponibles).arg(devueltos);
    if (preceptor) {
        QString pendientes = valorUnico("SELECT COUNT(*) FROM objetos.reclamo_objeto r JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo "
                                        "WHERE e.nombre_estado = 'Pendiente' AND :id > 0", idActual);
        resumen += " · Reclamos pendientes: " + pendientes;
    }
    ui->lblObjResumen->setText(resumen);
}

void MainWindow::on_listObjetos_itemDoubleClicked(QListWidgetItem *item)
{
    int objeto = item->data(Qt::UserRole).toInt();
    MYSQL_RES *result = hacerSelect("SELECT titulo, COALESCE(descripcion, ''), COALESCE(ruta_foto, ''), COALESCE(detalle_reservado, '') "
                                    "FROM objetos.objeto_perdido WHERE id_objeto = " + QString::number(objeto));
    if (result == NULL) return;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila == NULL) {
        mysql_free_result(result);
        return;
    }
    VentanaDetalle ventana;
    ventana.setObjeto(QString(fila[0]), QString(fila[1]), QString(fila[2]));
    if (rolEs("Preceptor")) ventana.setReservado(QString(fila[3]));
    mysql_free_result(result);
    ventana.exec();
}

void MainWindow::cargarReclamos()
{
    ui->listReclamos->clear();
    ui->tabObjetos->setTabText(1, "Reclamos");
    if (!rolEs("Preceptor")) return;
    MYSQL_RES *result = hacerSelect("SELECT r.id_reclamo, r.id_objeto, o.titulo, u.nombre_completo, r.prueba_pertenencia, COALESCE(o.detalle_reservado, '') "
                                    "FROM objetos.reclamo_objeto r JOIN objetos.objeto_perdido o ON o.id_objeto = r.id_objeto "
                                    "JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario WHERE r.id_estado_reclamo = "
                                    + QString::number(idEstado("objetos.estado_reclamo", "Pendiente")) + " ORDER BY r.id_objeto, r.id_reclamo");
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString reservado = QString(fila[5]);
        if (reservado.isEmpty()) reservado = "ninguno cargado";
        QString texto = QString("%1 · lo reclama %2\nSu detalle: %3\nDato reservado: %4")
                            .arg(QString(fila[2])).arg(QString(fila[3])).arg(QString(fila[4])).arg(reservado);
        agregarItem(ui->listReclamos, texto, QString(fila[0]).toInt(), QString(fila[1]).toInt());
    }
    if (result != NULL) mysql_free_result(result);
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM objetos.objeto_perdido o JOIN objetos.estado_objeto e "
                                "ON e.id_estado_objeto = o.id_estado_objeto WHERE o.id_objeto = :id", objeto);
    if (estado == "Devuelto" || estado == "Archivado") {
        fallar("Reclamo de objeto", "reclamo_objeto", "Este objeto ya no se puede reclamar: se devolvió o se archivó.");
        return;
    }
    if (detalle.size() < 10) {
        fallar("Reclamo de objeto", "reclamo_objeto", "Contanos un poco más: el detalle necesita 10 caracteres o más.");
        return;
    }
    QString sql = "INSERT INTO objetos.reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) VALUES ("
                  + texto(detalle) + ", " + valorFecha(QDate::currentDate()) + ", " + QString::number(idActual) + ", "
                  + QString::number(objeto) + ", " + QString::number(idEstado("objetos.estado_reclamo", "Pendiente")) + ")";
    if (!ejecutar(sql)) {
        int yaReclamado = valorUnico("SELECT COUNT(*) FROM objetos.reclamo_objeto WHERE id_usuario = " + QString::number(idActual)
                                     + " AND id_objeto = :id", objeto).toInt();
        if (yaReclamado > 0) fallar("Reclamo de objeto", "reclamo_objeto", "Ya reclamaste este objeto. Solo se puede reclamar una vez.");
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
    QString actual = valorUnico("SELECT e.nombre_estado FROM objetos.reclamo_objeto r JOIN objetos.estado_reclamo e "
                                "ON e.id_estado_reclamo = r.id_estado_reclamo WHERE r.id_reclamo = :id", reclamo);
    if (actual != "Pendiente") {
        fallar(evento, "reclamo_objeto", "Ese reclamo ya fue resuelto.");
        cargarReclamos();
        return;
    }
    QString titulo = valorUnico("SELECT titulo FROM objetos.objeto_perdido WHERE id_objeto = :id", objeto);
    QString quien = valorUnico("SELECT u.nombre_completo FROM objetos.reclamo_objeto r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario "
                               "WHERE r.id_reclamo = :id", reclamo);
    QString pregunta = QString("¿Querés rechazar el reclamo de %1 sobre “%2”? El objeto sigue en la lista.").arg(quien).arg(titulo);
    if (estadoReclamo == "Aprobado") {
        pregunta = QString("¿Querés aprobar el reclamo de %1 sobre “%2”? El objeto figura como Devuelto y los otros reclamos se rechazan.").arg(quien).arg(titulo);
    }
    if (!confirmar("Confirmar", pregunta)) return;
    ejecutar("START TRANSACTION");
    bool ok = ejecutar("UPDATE objetos.reclamo_objeto SET id_estado_reclamo = " + QString::number(idEstado("objetos.estado_reclamo", estadoReclamo))
                       + " WHERE id_reclamo = " + QString::number(reclamo));
    if (estadoReclamo == "Aprobado") {
        ok = ok && ejecutar("UPDATE objetos.reclamo_objeto SET id_estado_reclamo = " + QString::number(idEstado("objetos.estado_reclamo", "Rechazado"))
                            + " WHERE id_objeto = " + QString::number(objeto) + " AND id_reclamo <> " + QString::number(reclamo));
        ok = ok && ejecutar("UPDATE objetos.objeto_perdido SET id_estado_objeto = " + QString::number(idEstado("objetos.estado_objeto", "Devuelto"))
                            + " WHERE id_objeto = " + QString::number(objeto));
    }
    if (!ok) {
        ejecutar("ROLLBACK");
        fallar(evento, "reclamo_objeto", "No se pudo actualizar el reclamo. Probá de nuevo.");
        return;
    }
    ejecutar("COMMIT");

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
    int pendientes = valorUnico("SELECT COUNT(*) FROM objetos.reclamo_objeto r JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo "
                                "WHERE r.id_objeto = :id AND e.nombre_estado = 'Pendiente'", objeto).toInt();
    if (pendientes > 0) {
        fallar("", "", "Ese objeto tiene reclamos pendientes. Resolvelos antes de archivarlo.");
        return;
    }
    QString titulo = valorUnico("SELECT titulo FROM objetos.objeto_perdido WHERE id_objeto = :id", objeto);
    if (!confirmar("Archivar objeto", QString("¿Querés archivar “%1”? Sale de la lista de objetos.").arg(titulo))) return;
    if (!ejecutar("UPDATE objetos.objeto_perdido SET id_estado_objeto = " + QString::number(idEstado("objetos.estado_objeto", "Archivado"))
                  + " WHERE id_objeto = " + QString::number(objeto))) {
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
    QString sql = "INSERT INTO objetos.objeto_perdido (titulo, descripcion, ruta_foto, detalle_reservado, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) VALUES ("
                  + texto(titulo) + ", " + textoONulo(descripcion) + ", " + textoONulo(archivo) + ", " + textoONulo(reservado) + ", "
                  + valorFecha(QDate::currentDate()) + ", " + QString::number(idActual) + ", " + QString::number(ui->cbObjCategoria->currentData().toInt()) + ", "
                  + QString::number(idEstado("objetos.estado_objeto", "Disponible")) + ", " + QString::number(ui->cbObjSector->currentData().toInt()) + ")";
    if (!ejecutar(sql)) {
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
    MYSQL_RES *result = hacerSelect("SELECT c.id_consulta, c.id_usuario, u.nombre_completo, u.contacto_telefono, c.descripcion_busqueda, c.fecha_publicacion "
                                    "FROM objetos.consulta_objeto c JOIN seguridad.usuario u ON u.id_usuario = c.id_usuario ORDER BY c.id_consulta DESC");
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString dia = QDate::fromString(QString(fila[5]).left(10), "yyyy-MM-dd").toString("dd/MM");
        QString texto = QString("%1 · tel. %2 · %3\n%4").arg(QString(fila[2])).arg(QString(fila[3])).arg(dia).arg(QString(fila[4]));
        agregarItem(ui->listConsultas, texto, QString(fila[0]).toInt(), QString(fila[1]).toInt());
    }
    if (result != NULL) mysql_free_result(result);
    if (ui->listConsultas->count() == 0) agregarVacio(ui->listConsultas, "Todavía no hay consultas. ¿Perdiste algo? Publicá la primera.");
}

void MainWindow::on_btnConsultaPublicar_clicked()
{
    QString descripcion = ui->leConsultaDesc->text().trimmed();
    if (descripcion.size() < 10) {
        fallar("", "", "Describí mejor lo que buscás (10 caracteres o más).");
        return;
    }
    if (!ejecutar("INSERT INTO objetos.consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES ("
                  + valorFecha(QDate::currentDate()) + ", " + texto(descripcion) + ", " + QString::number(idActual) + ")")) {
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
    if (!ejecutar("DELETE FROM objetos.consulta_objeto WHERE id_consulta = " + QString::number(consulta))) {
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
                  "u.nombre_completo, r.fecha_hora_resolucion, rs.nombre_completo FROM instalaciones.reporte_higiene r "
                  "JOIN instalaciones.sector s ON s.id_sector = r.id_sector JOIN instalaciones.tipo_reporte t ON t.id_tipo_reporte = r.id_tipo_reporte "
                  "JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario "
                  "LEFT JOIN seguridad.usuario rs ON rs.id_usuario = r.id_usuario_resolutor ";
    if (filtro == "Pendientes") sql += "WHERE e.nombre_estado = 'Pendiente' ";
    if (filtro == "Resueltos") sql += "WHERE e.nombre_estado = 'Resuelto' ";
    sql += "ORDER BY CASE WHEN e.nombre_estado = 'Pendiente' THEN 0 ELSE 1 END, r.id_reporte DESC";
    MYSQL_RES *result = hacerSelect(sql);
    MYSQL_ROW fila;
    int resueltos = 0;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString estado = QString(fila[5]);
        bool pendiente = estado == "Pendiente";
        if (pendiente || resueltos < MAX_RESUELTOS) {
            QString texto = estado + " · " + QString(fila[3]) + " · " + QString(fila[4]) + "\n";
            texto += formatoCorto(QString(fila[1])) + " · Reportó " + QString(fila[6]);
            if (fila[7] != NULL) {
                texto += " · Resuelto " + formatoCorto(QString(fila[7])) + " por " + QString(fila[8]);
            }
            texto += "\n" + QString(fila[2]);
            agregarItem(ui->listHigiene, texto, QString(fila[0]).toInt());
            ui->listHigiene->item(ui->listHigiene->count() - 1)->setToolTip(texto);
            if (pendiente) pintarUltimo(ui->listHigiene, "peligro");
            else pintarUltimo(ui->listHigiene, "ok");
            if (!pendiente) resueltos++;
        }
    }
    if (result != NULL) mysql_free_result(result);
    if (ui->listHigiene->count() == 0) {
        if (filtro == "Pendientes") agregarVacio(ui->listHigiene, "No hay reportes pendientes.");
        else if (filtro == "Resueltos") agregarVacio(ui->listHigiene, "Todavía no hay reportes resueltos.");
        else agregarVacio(ui->listHigiene, "Todavía no hay reportes. Si ves algo roto o sucio, avisanos desde el formulario.");
    }
    actualizarPendientesHigiene();
}

void MainWindow::actualizarUltimoMantenimiento()
{
    ui->lblHigieneUltimo->setText("Todavía no hay ninguno");
    MYSQL_RES *result = hacerSelect("SELECT r.fecha_hora_resolucion, u.nombre_completo FROM instalaciones.reporte_higiene r "
                                    "JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario_resolutor WHERE r.id_sector = "
                                    + QString::number(ui->cbHigieneSector->currentData().toInt())
                                    + " AND r.fecha_hora_resolucion IS NOT NULL ORDER BY r.fecha_hora_resolucion DESC");
    if (result == NULL) return;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila != NULL) {
        ui->lblHigieneUltimo->setText(QString("%1 — %2").arg(formatoCorto(QString(fila[0]))).arg(QString(fila[1])));
    }
    mysql_free_result(result);
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
    QString sql = "INSERT INTO instalaciones.reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte) VALUES ("
                  + valorAhora() + ", " + texto(observaciones) + ", " + QString::number(idActual) + ", "
                  + QString::number(ui->cbHigieneSector->currentData().toInt()) + ", " + QString::number(ui->cbHigieneTipo->currentData().toInt()) + ", "
                  + QString::number(idEstado("instalaciones.estado_reporte", "Pendiente")) + ")";
    if (!ejecutar(sql)) {
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM instalaciones.reporte_higiene r JOIN instalaciones.estado_reporte e "
                                "ON e.id_estado_reporte = r.id_estado_reporte WHERE r.id_reporte = :id", reporte);
    if (estado != "Pendiente") {
        fallar("Resolución de reporte", "reporte_higiene", "Ese reporte ya está resuelto.");
        return;
    }
    int sectorResuelto = valorUnico("SELECT id_sector FROM instalaciones.reporte_higiene WHERE id_reporte = :id", reporte).toInt();
    QString sql = "UPDATE instalaciones.reporte_higiene SET id_estado_reporte = " + QString::number(idEstado("instalaciones.estado_reporte", "Resuelto"))
                  + ", fecha_hora_resolucion = " + valorAhora() + ", id_usuario_resolutor = " + QString::number(idActual)
                  + " WHERE id_reporte = " + QString::number(reporte);
    if (!ejecutar(sql)) {
        fallar("Resolución de reporte", "reporte_higiene", "No se pudo marcar el reporte como resuelto. Probá de nuevo.");
        return;
    }
    registrarLog("Resolución de reporte", QString("Reporte %1 resuelto").arg(reporte), "reporte_higiene", "Exitoso");
    cargarHigiene();
    if (sectorResuelto > 0) elegirPorId(ui->cbHigieneSector, sectorResuelto);
    actualizarUltimoMantenimiento();
}

void MainWindow::cargarGrupos()
{
    bool primeraVez = (ui->cbBuffetVista->count() == 0);
    int vista = -1;
    if (!primeraVez) vista = ui->cbBuffetVista->currentData().toInt();
    int donar = ui->cbDonarGrupo->currentData().toInt();
    cargarCombo(ui->cbBuffetVista, "SELECT id_grupo, nombre_grupo FROM tienda.grupo_buffet ORDER BY nombre_grupo", "Productos sueltos de alumnos", "");
    ui->cbBuffetVista->blockSignals(true);
    ui->cbBuffetVista->insertItem(0, "TODOS", -1);
    ui->cbBuffetVista->blockSignals(false);
    elegirPorId(ui->cbBuffetVista, vista);
    cargarCombo(ui->cbUnirseGrupo, "SELECT id_grupo, nombre_grupo FROM tienda.grupo_buffet ORDER BY nombre_grupo", "", "");
    cargarCombo(ui->cbDonarGrupo, "SELECT id_grupo, nombre_grupo FROM tienda.grupo_buffet ORDER BY nombre_grupo", "", "");
    elegirPorId(ui->cbDonarGrupo, donar);

    ui->cbProdGrupo->clear();
    ui->cbProdGrupo->addItem("Venta individual", 0);
    MYSQL_RES *result = hacerSelect("SELECT g.id_grupo, g.nombre_grupo FROM tienda.grupo_buffet g JOIN tienda.integrante_grupo i ON i.id_grupo = g.id_grupo "
                                    "WHERE i.id_usuario = " + QString::number(idActual) + " ORDER BY g.nombre_grupo");
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        ui->cbProdGrupo->addItem(QString(fila[1]), QString(fila[0]).toInt());
    }
    if (result != NULL) mysql_free_result(result);
    habilitar(rolEs("Alumno"), QList<QWidget *>() << ui->colGrupoAlumno);
    cargarDonaciones();
}

int MainWindow::recaudado(int grupo)
{
    QString entregada = QString::number(idEstado("tienda.estado_venta", "Entregada"));
    return valorUnico("SELECT COALESCE((SELECT SUM(monto) FROM tienda.donacion_buffet WHERE id_grupo = :id), 0) + "
                      "COALESCE((SELECT SUM(d.cantidad * d.precio_unitario) FROM tienda.detalle_venta d "
                      "JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto "
                      "WHERE p.id_grupo = :id AND v.id_estado_venta = " + entregada + "), 0)", grupo).toInt();
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
                  "FROM tienda.producto_buffet p JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario "
                  "JOIN tienda.categoria_producto c ON c.id_categoria_producto = p.id_categoria_producto ";
    if (grupo > 0) sql += "WHERE p.id_grupo = " + QString::number(grupo) + " ";
    else if (grupo == 0) sql += "WHERE p.id_grupo IS NULL ";
    else sql += "WHERE 1 = 1 ";
    if (categoria > 0) sql += "AND p.id_categoria_producto = " + QString::number(categoria) + " ";
    if (vendedor > 0) sql += "AND p.id_usuario = " + QString::number(vendedor) + " ";
    if (!busqueda.isEmpty()) sql += "AND (p.nombre_producto LIKE " + texto("%" + busqueda + "%") + " OR u.nombre_completo LIKE " + texto("%" + busqueda + "%") + ") ";
    sql += "ORDER BY p.nombre_producto";
    MYSQL_RES *result = hacerSelect(sql);
    MYSQL_ROW fila;
    int cantidad = 0;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        int stock = QString(fila[3]).toInt();
        QString tercera = "Stock " + QString::number(stock) + " · " + QString(fila[4]);
        if (stock == 0) tercera = "SIN STOCK · " + QString(fila[4]);
        QString texto = QString(fila[1]) + "\n$" + QString::number(QString(fila[2]).toInt()) + " · " + QString(fila[5]) + "\n" + tercera;
        agregarItem(ui->listBuffet, texto, QString(fila[0]).toInt());
        QListWidgetItem *item = ui->listBuffet->item(ui->listBuffet->count() - 1);
        item->setIcon(QIcon(miniaturaProducto(QString(fila[6]))));
        item->setToolTip("Doble clic para ver el detalle y la foto");
        if (stock == 0) item->setForeground(QBrush(colorToken("peligro")));
        cantidad++;
    }
    if (result != NULL) mysql_free_result(result);
    ui->lblBuffetResumen->setText(plural(cantidad, "producto", "productos"));
    ui->listBuffet->setVisible(cantidad > 0);
    ui->lblBuffetVacio->setVisible(cantidad == 0);

    ui->lblBuffetMeta->setVisible(grupo > 0);
    if (grupo > 0) {
        int meta = valorUnico("SELECT meta_monto FROM tienda.grupo_buffet WHERE id_grupo = :id", grupo).toInt();
        if (meta > 0) {
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
    MYSQL_RES *result = hacerSelect("SELECT p.nombre_producto, c.nombre_categoria, p.precio, p.stock, u.nombre_completo, u.contacto_telefono, COALESCE(p.ruta_foto, '') "
                                    "FROM tienda.producto_buffet p JOIN tienda.categoria_producto c ON c.id_categoria_producto = p.id_categoria_producto "
                                    "JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario WHERE p.id_producto = " + QString::number(producto));
    if (result == NULL) return;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila == NULL) {
        mysql_free_result(result);
        return;
    }
    VentanaProducto ventana;
    ventana.setProducto(QString(fila[0]), QString(fila[1]), QString(fila[2]).toInt(), QString(fila[3]).toInt(),
                        QString(fila[4]), QString(fila[5]), QString(fila[6]));
    mysql_free_result(result);
    ventana.exec();

}

void MainWindow::cargarMisReservas()
{
    ui->listMisReservas->clear();
    MYSQL_RES *result = hacerSelect("SELECT v.id_venta, p.nombre_producto, d.cantidad, "
                                    "(SELECT SUM(x.cantidad * x.precio_unitario) FROM tienda.detalle_venta x WHERE x.id_venta = v.id_venta), "
                                    "u.nombre_completo, u.contacto_telefono, v.fecha_hora, e.nombre_estado "
                                    "FROM tienda.venta_buffet v JOIN tienda.detalle_venta d ON d.id_venta = v.id_venta "
                                    "JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario "
                                    "JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta "
                                    "WHERE v.id_usuario = " + QString::number(idActual) + " ORDER BY v.id_venta DESC");
    MYSQL_ROW fila;
    int activas = 0;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString estado = QString(fila[7]);
        QString texto = QString("%1 · %2 x%3 · $%4 · vende %5 (tel. %6) · %7").arg(estado).arg(QString(fila[1])).arg(QString(fila[2]).toInt())
                .arg(QString(fila[3]).toInt()).arg(QString(fila[4])).arg(QString(fila[5])).arg(formatoCorto(QString(fila[6])));
        agregarItem(ui->listMisReservas, texto, QString(fila[0]).toInt());
        pintarEstadoVenta(ui->listMisReservas->item(ui->listMisReservas->count() - 1), estado);
        if (estado == "Reservada") activas++;
    }
    if (result != NULL) mysql_free_result(result);
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
    MYSQL_RES *result = hacerSelect("SELECT stock, precio, id_usuario FROM tienda.producto_buffet WHERE id_producto = " + QString::number(producto));
    MYSQL_ROW fila = NULL;
    if (result != NULL) fila = mysql_fetch_row(result);
    if (fila == NULL) {
        if (result != NULL) mysql_free_result(result);
        fallar("Reserva de producto", "venta_buffet", "Ese producto ya no existe.");
        return;
    }
    int stock = QString(fila[0]).toInt();
    int precio = QString(fila[1]).toInt();
    int vendedor = QString(fila[2]).toInt();
    mysql_free_result(result);
    if (vendedor == idActual) {
        fallar("Reserva de producto", "venta_buffet", "No podés reservar tus propios productos.");
        return;
    }
    if (cantidad > stock) {
        QString faltante = QString("No hay stock suficiente: quedan %1.").arg(plural(stock, "unidad", "unidades"));
        if (stock == 1) faltante = "No hay stock suficiente: queda 1 unidad.";
        fallar("Reserva de producto", "venta_buffet", faltante);
        return;
    }
    ejecutar("START TRANSACTION");
    bool ok = ejecutar("INSERT INTO tienda.venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES (" + valorAhora() + ", "
                       + QString::number(idActual) + ", " + QString::number(idEstado("tienda.estado_venta", "Reservada")) + ")");
    int venta = ultimoId();
    ok = ok && ejecutar("INSERT INTO tienda.detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES (" + QString::number(venta) + ", "
                        + QString::number(producto) + ", " + QString::number(cantidad) + ", " + QString::number(precio) + ")");
    ok = ok && ejecutar("UPDATE tienda.producto_buffet SET stock = stock - " + QString::number(cantidad) + " WHERE id_producto = " + QString::number(producto));
    if (!ok) {
        ejecutar("ROLLBACK");
        fallar("Reserva de producto", "venta_buffet", "No se pudo hacer la reserva.");
        return;
    }
    ejecutar("COMMIT");
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
    if (valorUnico("SELECT id_usuario FROM tienda.venta_buffet WHERE id_venta = :id", venta).toInt() != idActual) {
        fallar("", "", "Esa reserva no es tuya.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM tienda.venta_buffet v JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
    QString producto = valorUnico("SELECT p.nombre_producto FROM tienda.detalle_venta d JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto "
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
    ejecutar("START TRANSACTION");
    bool ok = ejecutar("UPDATE tienda.venta_buffet SET id_estado_venta = " + QString::number(idEstado("tienda.estado_venta", "Cancelada"))
                       + " WHERE id_venta = " + QString::number(venta));
    QStringList productos;
    QStringList cantidades;
    MYSQL_RES *result = hacerSelect("SELECT id_producto, cantidad FROM tienda.detalle_venta WHERE id_venta = " + QString::number(venta));
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        productos << QString(fila[0]);
        cantidades << QString(fila[1]);
    }
    if (result != NULL) mysql_free_result(result);
    for (int i = 0; i < productos.size(); i++) {
        ok = ok && ejecutar("UPDATE tienda.producto_buffet SET stock = stock + " + cantidades[i] + " WHERE id_producto = " + productos[i]);
    }
    if (!ok) {
        ejecutar("ROLLBACK");
        return false;
    }
    ejecutar("COMMIT");
    return true;
}

bool MainWindow::ventaEsMia(int venta)
{
    return valorUnico("SELECT COUNT(*) FROM tienda.detalle_venta d JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto "
                      "WHERE d.id_venta = :id AND p.id_usuario = " + QString::number(idActual), venta).toInt() > 0;
}

bool MainWindow::productoEsMio(int producto)
{
    return valorUnico("SELECT id_usuario FROM tienda.producto_buffet WHERE id_producto = :id", producto).toInt() == idActual;
}

void MainWindow::cargarMisVentas()
{
    ui->listMisVentas->clear();
    MYSQL_RES *result = hacerSelect("SELECT v.id_venta, p.nombre_producto, d.cantidad, d.cantidad * d.precio_unitario, "
                                    "c.nombre_completo, c.contacto_telefono, v.fecha_hora, e.nombre_estado "
                                    "FROM tienda.venta_buffet v JOIN tienda.detalle_venta d ON d.id_venta = v.id_venta "
                                    "JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto JOIN seguridad.usuario c ON c.id_usuario = v.id_usuario "
                                    "JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta "
                                    "WHERE p.id_usuario = " + QString::number(idActual) + " ORDER BY v.id_venta DESC");
    MYSQL_ROW fila;
    int pendientes = 0;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString estado = QString(fila[7]);
        QString texto = QString("%1 · %2 x%3 · $%4 · reservó %5 (tel. %6) · %7").arg(estado).arg(QString(fila[1])).arg(QString(fila[2]).toInt())
                .arg(QString(fila[3]).toInt()).arg(QString(fila[4])).arg(QString(fila[5])).arg(formatoCorto(QString(fila[6])));
        agregarItem(ui->listMisVentas, texto, QString(fila[0]).toInt());
        pintarEstadoVenta(ui->listMisVentas->item(ui->listMisVentas->count() - 1), estado);
        if (estado == "Reservada") pendientes++;
    }
    if (result != NULL) mysql_free_result(result);
    ui->lblMisVentasResumen->setText(plural(pendientes, "reserva por entregar", "reservas por entregar"));
    ui->lblMisVentasResumen->setVisible(ui->listMisVentas->count() > 0);
    alternarVacio(ui->listMisVentas, ui->lblMisVentasVacio);
}

void MainWindow::cargarMisProductos()
{
    ui->tabBuffet->setTabVisible(5, rolEs("Alumno"));
    ui->listMisProductos->clear();
    MYSQL_RES *result = hacerSelect("SELECT p.id_producto, p.nombre_producto, p.precio, p.stock, COALESCE(g.nombre_grupo, 'Venta individual') "
                                    "FROM tienda.producto_buffet p LEFT JOIN tienda.grupo_buffet g ON g.id_grupo = p.id_grupo "
                                    "WHERE p.id_usuario = " + QString::number(idActual) + " ORDER BY p.nombre_producto");
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        int stock = QString(fila[3]).toInt();
        QString texto = QString("%1 · $%2 · stock %3 · %4").arg(QString(fila[1])).arg(QString(fila[2]).toInt())
                .arg(stock).arg(QString(fila[4]));
        if (stock == 0) texto += " · SIN STOCK";
        agregarItem(ui->listMisProductos, texto, QString(fila[0]).toInt());
        if (stock == 0) ui->listMisProductos->item(ui->listMisProductos->count() - 1)->setForeground(QBrush(colorToken("peligro")));
    }
    if (result != NULL) mysql_free_result(result);
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM tienda.venta_buffet v JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
    if (!ejecutar("UPDATE tienda.venta_buffet SET id_estado_venta = " + QString::number(idEstado("tienda.estado_venta", "Entregada"))
                  + " WHERE id_venta = " + QString::number(venta))) {
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM tienda.venta_buffet v JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
    QString comprador = valorUnico("SELECT u.nombre_completo FROM tienda.venta_buffet v JOIN seguridad.usuario u ON u.id_usuario = v.id_usuario "
                                   "WHERE v.id_venta = :id", venta);
    QString producto = valorUnico("SELECT p.nombre_producto FROM tienda.detalle_venta d JOIN tienda.producto_buffet p ON p.id_producto = d.id_producto "
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
    int stock = valorUnico("SELECT stock FROM tienda.producto_buffet WHERE id_producto = :id", producto).toInt();
    if (cantidad > stock) {
        fallar("", "", QString("No podés quitar más de lo que hay: el producto tiene %1.").arg(plural(stock, "unidad", "unidades")));
        return;
    }
    if (!ejecutar("UPDATE tienda.producto_buffet SET stock = stock - " + QString::number(cantidad) + " WHERE id_producto = " + QString::number(producto)
                  + " AND id_usuario = " + QString::number(idActual) + " AND stock >= " + QString::number(cantidad))) {
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
    int stock = valorUnico("SELECT stock FROM tienda.producto_buffet WHERE id_producto = :id", producto).toInt();
    if (!ejecutar("UPDATE tienda.producto_buffet SET stock = stock + " + QString::number(cantidad) + " WHERE id_producto = " + QString::number(producto)
                  + " AND id_usuario = " + QString::number(idActual))) {
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
    int reservas = valorUnico("SELECT COUNT(*) FROM tienda.detalle_venta d JOIN tienda.venta_buffet v ON v.id_venta = d.id_venta "
                              "WHERE d.id_producto = :id AND v.id_estado_venta = " + QString::number(idEstado("tienda.estado_venta", "Reservada")), producto).toInt();
    if (reservas > 0) {
        fallar("", "", "Tiene reservas activas. Entregalas o cancelalas antes de eliminar el producto.");
        return;
    }
    if (valorUnico("SELECT COUNT(*) FROM tienda.detalle_venta WHERE id_producto = :id", producto).toInt() > 0) {
        fallar("", "", "Este producto ya tuvo ventas, así que no se puede eliminar (se conserva el historial).");
        return;
    }
    QString nombre = valorUnico("SELECT nombre_producto FROM tienda.producto_buffet WHERE id_producto = :id", producto);
    QString foto = valorUnico("SELECT COALESCE(ruta_foto, '') FROM tienda.producto_buffet WHERE id_producto = :id", producto);
    if (!confirmar("Eliminar producto", QString("¿Querés eliminar “%1”? No se puede deshacer.").arg(nombre))) return;
    if (!ejecutar("DELETE FROM tienda.producto_buffet WHERE id_producto = " + QString::number(producto) + " AND id_usuario = " + QString::number(idActual))) {
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
    if (!ejecutar("INSERT INTO tienda.donacion_buffet (monto, fecha_hora, id_usuario, id_grupo) VALUES (" + QString::number(monto) + ", "
                  + valorAhora() + ", " + QString::number(idActual) + ", " + QString::number(grupo) + ")")) {
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
    QString pin = valorUnico("SELECT pin_acceso FROM tienda.grupo_buffet WHERE id_grupo = :id", grupo);
    if (ui->leBuffetPin->text().trimmed() != pin) {
        fallar("", "", "El PIN no coincide. Pedíselo a quien creó el grupo.");
        return;
    }
    if (valorUnico("SELECT COUNT(*) FROM tienda.integrante_grupo WHERE id_usuario = " + QString::number(idActual) + " AND id_grupo = :id", grupo).toInt() > 0) {
        fallar("", "", "Ya sos integrante de ese grupo.");
        return;
    }
    if (!ejecutar("INSERT INTO tienda.integrante_grupo (id_usuario, id_grupo) VALUES (" + QString::number(idActual) + ", " + QString::number(grupo) + ")")) {
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
    if (grupo > 0) {
        if (valorUnico("SELECT COUNT(*) FROM tienda.integrante_grupo WHERE id_usuario = " + QString::number(idActual) + " AND id_grupo = :id", grupo).toInt() == 0) {
            fallar("", "", "Para vender en un grupo tenés que ser integrante.");
            return;
        }
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
    QString sql = "INSERT INTO tienda.producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo, id_categoria_producto, ruta_foto) VALUES ("
                  + texto(nombre) + ", " + QString::number(precio) + ", " + QString::number(stock) + ", " + QString::number(idActual) + ", "
                  + numeroONulo(grupo) + ", " + QString::number(categoria) + ", " + textoONulo(archivo) + ")";
    if (!ejecutar(sql)) {
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
    if (existe("tienda.grupo_buffet", "nombre_grupo", nombre)) {
        fallar("", "", "Ya existe un grupo con ese nombre.");
        return;
    }
    ejecutar("START TRANSACTION");
    bool correcto = ejecutar("INSERT INTO tienda.grupo_buffet (nombre_grupo, pin_acceso, meta_monto) VALUES (" + texto(nombre) + ", "
                             + texto(pin) + ", " + QString::number(meta) + ")");
    int grupo = ultimoId();
    correcto = correcto && ejecutar("INSERT INTO tienda.integrante_grupo (id_usuario, id_grupo) VALUES (" + QString::number(idActual) + ", " + QString::number(grupo) + ")");
    if (!correcto) {
        ejecutar("ROLLBACK");
        fallar("", "", "No se pudo crear el grupo.");
        return;
    }
    ejecutar("COMMIT");

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
    QString sql = "SELECT r.id_recurso, c.nombre_carro, r.numero_equipo, t.nombre_tipo FROM equipos.recursos_ct r "
                  "LEFT JOIN equipos.carro c ON c.id_carro = r.id_carro JOIN equipos.tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso "
                  "WHERE r.id_estado_recurso = " + QString::number(idEstado("equipos.estado_recurso", "Disponible")) + " ";
    if (programa > 0) sql += "AND EXISTS (SELECT 1 FROM equipos.recurso_software rs WHERE rs.id_recurso = r.id_recurso AND rs.id_software = " + QString::number(programa) + ") ";
    sql += "ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo";
    MYSQL_RES *result = hacerSelect(sql);
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString codigo = codigoRecurso(QString(fila[1]), QString(fila[2]).toInt());
        if (filtro.isEmpty() || codigo.contains(filtro, Qt::CaseInsensitive)) {
            agregarItem(ui->listPlanillas, QString("%1 · %2").arg(codigo).arg(QString(fila[3])), QString(fila[0]).toInt());
        }
    }
    if (result != NULL) mysql_free_result(result);
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
    MYSQL_RES *result = hacerSelect("SELECT r.id_recurso, c.nombre_carro, r.numero_equipo, t.nombre_tipo FROM equipos.recursos_ct r "
                                    "LEFT JOIN equipos.carro c ON c.id_carro = r.id_carro JOIN equipos.tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso "
                                    "WHERE r.id_estado_recurso = " + QString::number(idEstado("equipos.estado_recurso", "Fuera de servicio"))
                                    + " ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo");
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString codigo = codigoRecurso(QString(fila[1]), QString(fila[2]).toInt());
        if (filtro.isEmpty() || codigo.contains(filtro, Qt::CaseInsensitive)) {
            agregarItem(ui->listFueraServicio, QString("%1 · %2").arg(codigo).arg(QString(fila[3])), QString(fila[0]).toInt());
            pintarUltimo(ui->listFueraServicio, "peligro");
        }
    }
    if (result != NULL) mysql_free_result(result);
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM equipos.recursos_ct r JOIN equipos.estado_recurso e "
                                "ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = :id", recurso);
    if (estado != "Fuera de servicio") {
        fallar("", "", "Ese equipo ya no está fuera de servicio.");
        return;
    }
    if (!ejecutar("UPDATE equipos.recursos_ct SET id_estado_recurso = " + QString::number(idEstado("equipos.estado_recurso", "Disponible"))
                  + " WHERE id_recurso = " + QString::number(recurso))) {
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
    bool soloMios = rolActual() == "Alumno";
    QString donde = "";
    if (soloMios) donde = "WHERE p.id_usuario_solicitante = " + QString::number(idActual) + " ";
    MYSQL_RES *result = hacerSelect(QString("SELECT p.id_prestamo, a.nombre_completo, an.numero_anio, dv.numero_division, c.nombre_carro, r.numero_equipo, "
              "p.hora_prestamo, p.hora_devolucion, au.nombre_completo, p.fecha_prestamo FROM equipos.prestamo_ct p "
              "JOIN seguridad.usuario a ON a.id_usuario = p.id_usuario_solicitante LEFT JOIN academico.curso cu ON cu.id_curso = a.id_curso "
              "LEFT JOIN academico.anio an ON an.id_anio = cu.id_anio LEFT JOIN academico.division dv ON dv.id_division = cu.id_division "
              "JOIN seguridad.usuario au ON au.id_usuario = p.id_usuario_autorizador JOIN equipos.recursos_ct r ON r.id_recurso = p.id_recurso "
              "LEFT JOIN equipos.carro c ON c.id_carro = r.id_carro %1"
              "ORDER BY CASE WHEN p.hora_devolucion IS NULL THEN 0 ELSE 1 END, p.id_prestamo DESC").arg(donde));
    MYSQL_ROW fila;
    int mostrados = 0;
    while (result != NULL && mostrados < 40 && (fila = mysql_fetch_row(result)) != NULL) {
        QString codigo = codigoRecurso(QString(fila[4]), QString(fila[5]).toInt());
        if (filtro.isEmpty() || codigo.contains(filtro, Qt::CaseInsensitive)) {
            QString curso = "sin curso";
            if (fila[2] != NULL) curso = QString("%1°%2°").arg(QString(fila[2]).toInt()).arg(QString(fila[3]).toInt());
            QString estado = "En préstamo";
            if (fila[7] != NULL) estado = "Devuelto " + QString(fila[7]);
            QString dia = QDate::fromString(QString(fila[9]), "yyyy-MM-dd").toString("dd/MM");
            QString texto = QString("%1 · %2 (%3)\nRetiró %4 %5 · Autorizó %6 · %7").arg(codigo).arg(QString(fila[1])).arg(curso)
                                .arg(dia).arg(QString(fila[6])).arg(QString(fila[8])).arg(estado);
            agregarItem(ui->listPrestamos, texto, QString(fila[0]).toInt());
            if (fila[7] == NULL) pintarUltimo(ui->listPrestamos, "ok");
            else pintarUltimo(ui->listPrestamos, "suave");
            mostrados++;
        }
    }
    if (result != NULL) mysql_free_result(result);
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
    if (valorUnico("SELECT COUNT(*) FROM equipos.prestamo_ct WHERE id_usuario_solicitante = :id AND hora_devolucion IS NULL", alumno).toInt() > 0) {
        QString mensaje = "Ese alumno ya tiene un equipo prestado. Tiene que devolverlo antes de retirar otro.";
        if (rolActual() == "Alumno") mensaje = "Ya tenés un equipo prestado. Devolvelo antes de retirar otro.";
        fallar("Préstamo de recurso", "prestamo_ct", mensaje);
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM equipos.recursos_ct r JOIN equipos.estado_recurso e "
                                "ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = :id", recurso);
    if (estado != "Disponible") {
        fallar("Préstamo de recurso", "prestamo_ct", "Ese equipo no está disponible.");
        return;
    }
    ejecutar("START TRANSACTION");
    bool ok = ejecutar("INSERT INTO equipos.prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) VALUES ("
                       + valorFecha(QDate::currentDate()) + ", " + texto(QTime::currentTime().toString("HH:mm")) + ", NULL, " + textoONulo(observaciones) + ", "
                       + QString::number(alumno) + ", " + QString::number(idActual) + ", " + QString::number(recurso) + ")");
    ok = ok && ejecutar("UPDATE equipos.recursos_ct SET id_estado_recurso = " + QString::number(idEstado("equipos.estado_recurso", "Prestado"))
                        + " WHERE id_recurso = " + QString::number(recurso));
    if (!ok) {
        ejecutar("ROLLBACK");
        fallar("Préstamo de recurso", "prestamo_ct", "No se pudo registrar el préstamo. Probá de nuevo.");
        return;
    }
    ejecutar("COMMIT");
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
    MYSQL_RES *result = hacerSelect("SELECT hora_devolucion, id_recurso, id_usuario_solicitante FROM equipos.prestamo_ct WHERE id_prestamo = " + QString::number(prestamo));
    MYSQL_ROW fila = NULL;
    if (result != NULL) fila = mysql_fetch_row(result);
    bool devuelto = fila == NULL || fila[0] != NULL;
    int recurso = 0;
    int solicitante = 0;
    if (fila != NULL) {
        recurso = QString(fila[1]).toInt();
        solicitante = QString(fila[2]).toInt();
    }
    if (result != NULL) mysql_free_result(result);
    if (devuelto) {
        fallar("Devolución de recurso", "prestamo_ct", "Ese préstamo ya fue devuelto.");
        return;
    }
    if (rolActual() == "Alumno" && solicitante != idActual) {
        fallar("Devolución de recurso", "prestamo_ct", "Solo podés devolver tus propios préstamos.");
        return;
    }
    QString nuevoEstado = "Fuera de servicio";
    if (ui->cbPlanillasEstado->currentText() == "Funciona") nuevoEstado = "Disponible";
    if (nuevoEstado == "Fuera de servicio") {
        if (!confirmar("Devolver equipo", "Vas a devolver el equipo como que NO funciona. Queda fuera de servicio hasta que el preceptor o maestranza lo repare. ¿Confirmás?")) return;
    }
    ejecutar("START TRANSACTION");
    bool ok = ejecutar("UPDATE equipos.prestamo_ct SET hora_devolucion = " + texto(QTime::currentTime().toString("HH:mm"))
                       + " WHERE id_prestamo = " + QString::number(prestamo));
    if (!observaciones.isEmpty()) {
        QString anterior = valorUnico("SELECT COALESCE(observaciones, '') FROM equipos.prestamo_ct WHERE id_prestamo = :id", prestamo);
        if (!anterior.isEmpty()) observaciones = anterior + " / Devolución: " + observaciones;
        ok = ok && ejecutar("UPDATE equipos.prestamo_ct SET observaciones = " + texto(observaciones) + " WHERE id_prestamo = " + QString::number(prestamo));
    }
    ok = ok && ejecutar("UPDATE equipos.recursos_ct SET id_estado_recurso = " + QString::number(idEstado("equipos.estado_recurso", nuevoEstado))
                        + " WHERE id_recurso = " + QString::number(recurso));
    if (!ok) {
        ejecutar("ROLLBACK");
        fallar("Devolución de recurso", "prestamo_ct", "No se pudo registrar la devolución. Probá de nuevo.");
        return;
    }
    ejecutar("COMMIT");
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
    MYSQL_RES *result = hacerSelect("SELECT r.hora_inicio, r.hora_fin, u.nombre_completo, e.nombre_estado FROM instalaciones.reserva_sector r "
                                    "JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
                                    "WHERE r.id_sector = " + QString::number(sector) + " AND r.fecha_reserva = " + valorFecha(ui->deSectoresDia->date())
                                    + " AND r.id_estado_reserva IN (" + QString::number(idEstado("instalaciones.estado_reserva", "Pendiente")) + ", "
                                    + QString::number(idEstado("instalaciones.estado_reserva", "Aprobada")) + ") ORDER BY r.hora_inicio");
    MYSQL_ROW fila;
    int pendientes = 0;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString estado = QString(fila[3]);
        QString estadoTexto = estado;
        if (estado == "Pendiente") {
            pendientes++;
            estadoTexto = "Pendiente de aprobación";
        }
        QString texto = QString("%1 a %2 - %3").arg(QString(fila[0])).arg(QString(fila[1])).arg(estadoTexto);
        texto += "\n" + QString(fila[2]);
        agregarItem(ui->listOcupacion, texto, 0);
        pintarUltimo(ui->listOcupacion, "peligro");
    }
    if (result != NULL) mysql_free_result(result);
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
                  "e.nombre_estado, r.id_usuario FROM instalaciones.reserva_sector r JOIN instalaciones.sector s ON s.id_sector = r.id_sector "
                  "JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
                  "WHERE r.fecha_reserva >= " + valorFecha(QDate::currentDate())
                  + " AND r.id_estado_reserva <> " + QString::number(idEstado("instalaciones.estado_reserva", "Cancelada")) + " ";
    bool preceptor = rolEs("Preceptor");
    if (!preceptor) sql += "AND r.id_usuario = " + QString::number(idActual) + " ";
    sql += "ORDER BY ";
    if (preceptor) sql += "CASE WHEN e.nombre_estado = 'Pendiente' THEN 0 ELSE 1 END, ";
    sql += "r.fecha_reserva, r.hora_inicio";
    MYSQL_RES *result = hacerSelect(sql);
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString dia = QDate::fromString(QString(fila[1]), "yyyy-MM-dd").toString("dd/MM");
        QString estado = QString(fila[6]);
        QString estadoTexto = estado;
        if (estado == "Pendiente") estadoTexto = "Pendiente de aprobación";
        QString texto = QString("%1 - %2 %3 a %4").arg(QString(fila[4])).arg(dia).arg(QString(fila[2])).arg(QString(fila[3]));
        texto += "\n" + estadoTexto + " - " + QString(fila[5]);
        agregarItem(ui->listSectores, texto, QString(fila[0]).toInt(), QString(fila[7]).toInt());
        ui->listSectores->item(ui->listSectores->count() - 1)->setToolTip(texto);
        if (estado == "Aprobada") pintarUltimo(ui->listSectores, "ok");
        else if (estado == "Rechazada") pintarUltimo(ui->listSectores, "peligro");
        else pintarUltimo(ui->listSectores, "suave");
    }
    if (result != NULL) mysql_free_result(result);
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
    QString tipoSector = valorUnico("SELECT t.nombre_tipo FROM instalaciones.sector s JOIN instalaciones.tipo_sector t "
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
    MYSQL_RES *result = hacerSelect("SELECT r.hora_inicio, r.hora_fin, u.nombre_completo FROM instalaciones.reserva_sector r JOIN seguridad.usuario u ON u.id_usuario = r.id_usuario "
                                    "WHERE r.id_sector = " + QString::number(sector) + " AND r.fecha_reserva = " + valorFecha(dia)
                                    + " AND r.id_estado_reserva IN (" + QString::number(idEstado("instalaciones.estado_reserva", "Pendiente")) + ", "
                                    + QString::number(idEstado("instalaciones.estado_reserva", "Aprobada")) + ") AND r.hora_inicio < " + texto(fin)
                                    + " AND r.hora_fin > " + texto(inicio));
    MYSQL_ROW fila = NULL;
    if (result != NULL) fila = mysql_fetch_row(result);
    if (fila != NULL) {
        QString ocupado = QString("Ese horario está ocupado: %1 tiene el sector de %2 a %3. Probá con otro.")
                              .arg(QString(fila[2])).arg(QString(fila[0])).arg(QString(fila[1]));
        mysql_free_result(result);
        fallar("Reserva de sector", "reserva_sector", ocupado);
        return;
    }
    if (result != NULL) mysql_free_result(result);
    bool esPreceptor = rolEs("Preceptor");
    QString estado = "Pendiente";
    int autorizador = 0;
    if (esPreceptor) {
        estado = "Aprobada";
        autorizador = idActual;
    }
    QString sql = "INSERT INTO instalaciones.reserva_sector (fecha_reserva, hora_inicio, hora_fin, id_usuario, id_sector, id_estado_reserva, id_usuario_autorizador) VALUES ("
                  + valorFecha(dia) + ", " + texto(inicio) + ", " + texto(fin) + ", " + QString::number(idActual) + ", " + QString::number(sector) + ", "
                  + QString::number(idEstado("instalaciones.estado_reserva", estado)) + ", " + numeroONulo(autorizador) + ")";
    if (!ejecutar(sql)) {
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM instalaciones.reserva_sector r JOIN instalaciones.estado_reserva e "
                                "ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = :id", reserva);
    if (estado != "Pendiente" && estado != "Aprobada") {
        fallar("", "", "Esa reserva ya está rechazada o cancelada.");
        return;
    }
    QString detalle = ui->listSectores->currentItem()->text().split("\n").first();
    QString pregunta = QString("¿Querés cancelar la reserva de %1? El horario queda libre para otros.").arg(detalle);
    if (!confirmar("Cancelar reserva", pregunta)) return;
    if (!ejecutar("UPDATE instalaciones.reserva_sector SET id_estado_reserva = " + QString::number(idEstado("instalaciones.estado_reserva", "Cancelada"))
                  + " WHERE id_reserva = " + QString::number(reserva))) {
        fallar("Reserva de sector", "reserva_sector", "No se pudo cancelar la reserva. Probá de nuevo.");
        return;
    }
    registrarLog("Reserva de sector", QString("Reserva %1: Cancelada").arg(reserva), "reserva_sector", "Exitoso");
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
    QString actual = valorUnico("SELECT e.nombre_estado FROM instalaciones.reserva_sector r JOIN instalaciones.estado_reserva e "
                                "ON e.id_estado_reserva = r.id_estado_reserva WHERE r.id_reserva = :id", reserva);
    if (actual != "Pendiente") {
        fallar(evento, "reserva_sector", "Solo se pueden aprobar o rechazar reservas pendientes.");
        return;
    }
    if (!ejecutar("UPDATE instalaciones.reserva_sector SET id_estado_reserva = " + QString::number(idEstado("instalaciones.estado_reserva", estado))
                  + ", id_usuario_autorizador = " + QString::number(idActual) + " WHERE id_reserva = " + QString::number(reserva))) {
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
        QString estado = valorUnico("SELECT e.nombre_estado FROM instalaciones.reserva_sector r JOIN instalaciones.estado_reserva e "
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
    return valorUnico("SELECT MIN(m.nombre_materia) FROM academico.franja_horaria f JOIN academico.horario_dia hd ON hd.id_dia = " + QString::number(dia) + " "
                      "JOIN academico.horario_escolar he ON he.id_bloque = hd.id_bloque JOIN academico.materia m ON m.id_materia = he.id_materia "
                      "WHERE f.id_franja = " + QString::number(franja) + " AND he.id_curso = :id AND he.hora_inicio < f.hora_fin AND he.hora_fin > f.hora_inicio", curso);
}

QString MainWindow::chocaHorario(int oferta, int curso)
{
    MYSQL_RES *result = hacerSelect("SELECT id_dia, id_franja FROM deportes.oferta_deporte WHERE id_oferta = " + QString::number(oferta));
    if (result == NULL) return "";
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila == NULL) {
        mysql_free_result(result);
        return "";
    }
    int dia = QString(fila[0]).toInt();
    int franja = QString(fila[1]).toInt();
    mysql_free_result(result);
    return chocaFranja(dia, franja, curso);
}

int MainWindow::ofertaElegida()
{
    return valorUnico("SELECT id_oferta FROM deportes.oferta_deporte WHERE id_deporte = " + QString::number(ui->cbEdFisicaDeporte->currentData().toInt())
                      + " AND id_dia = " + QString::number(ui->cbEdFisicaDia->currentData().toInt())
                      + " AND id_franja = " + QString::number(ui->cbEdFisicaHora->currentData().toInt()), 0).toInt();
}

void MainWindow::cargarDiasEdFisica()
{
    int dia = ui->cbEdFisicaDia->currentData().toInt();
    int deporte = ui->cbEdFisicaDeporte->currentData().toInt();
    ui->cbEdFisicaDia->blockSignals(true);
    ui->cbEdFisicaDia->clear();
    QStringList ids;
    QStringList nombres;
    QStringList ofertas;
    MYSQL_RES *result = hacerSelect("SELECT d.id_dia, d.nombre_dia, (SELECT COUNT(*) FROM deportes.oferta_deporte o WHERE o.id_dia = d.id_dia AND o.id_deporte = "
                                    + QString::number(deporte) + ") FROM academico.dia_semana d ORDER BY d.id_dia");
    MYSQL_ROW datos;
    while (result != NULL && (datos = mysql_fetch_row(result)) != NULL) {
        ids << QString(datos[0]);
        nombres << QString(datos[1]);
        ofertas << QString(datos[2]);
    }
    if (result != NULL) mysql_free_result(result);
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM seguridad.usuario WHERE id_usuario = :id", idActual).toInt();
    int primero = -1;
    int elegido = -1;
    for (int i = 0; i < ids.size(); i++) {
        int id = ids[i].toInt();
        int fila = ui->cbEdFisicaDia->count();
        bool hayLibre = false;
        if (ofertas[i].toInt() > 0) {
            QStringList franjas;
            MYSQL_RES *resultFranjas = hacerSelect("SELECT id_franja FROM deportes.oferta_deporte WHERE id_dia = " + QString::number(id)
                                                   + " AND id_deporte = " + QString::number(deporte));
            MYSQL_ROW f;
            while (resultFranjas != NULL && (f = mysql_fetch_row(resultFranjas)) != NULL) {
                franjas << QString(f[0]);
            }
            if (resultFranjas != NULL) mysql_free_result(resultFranjas);
            for (int j = 0; j < franjas.size() && !hayLibre; j++) {
                if (chocaFranja(id, franjas[j].toInt(), curso).isEmpty()) hayLibre = true;
            }
        }
        if (hayLibre) {
            ui->cbEdFisicaDia->addItem(nombres[i], id);
            if (primero < 0) primero = fila;
            if (id == dia) elegido = fila;
        } else {
            QString motivo = " (sin clase)";
            if (ofertas[i].toInt() > 0) motivo = " (choca con tu horario)";
            ui->cbEdFisicaDia->addItem(nombres[i] + motivo, id);
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
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM seguridad.usuario WHERE id_usuario = :id", idActual).toInt();
    ui->cbEdFisicaHora->blockSignals(true);
    ui->cbEdFisicaHora->clear();
    QStringList ids;
    QStringList horarios;
    QStringList ofertas;
    MYSQL_RES *result = hacerSelect("SELECT f.id_franja, f.hora_inicio, f.hora_fin, "
                                    "(SELECT COUNT(*) FROM deportes.oferta_deporte o WHERE o.id_franja = f.id_franja AND o.id_dia = " + QString::number(dia)
                                    + " AND o.id_deporte = " + QString::number(deporte) + ") FROM academico.franja_horaria f ORDER BY f.hora_inicio");
    MYSQL_ROW datos;
    while (result != NULL && (datos = mysql_fetch_row(result)) != NULL) {
        ids << QString(datos[0]);
        horarios << QString(datos[1]) + " a " + QString(datos[2]);
        ofertas << QString(datos[3]);
    }
    if (result != NULL) mysql_free_result(result);
    int primera = -1;
    int elegida = -1;
    for (int i = 0; i < ids.size(); i++) {
        int id = ids[i].toInt();
        int fila = ui->cbEdFisicaHora->count();
        QString texto = horarios[i];
        bool hayClase = ofertas[i].toInt() > 0;
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
    int maximo = valorUnico("SELECT cupo_maximo FROM deportes.oferta_deporte WHERE id_oferta = :id", oferta).toInt();
    int libres = maximo - valorUnico("SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica WHERE id_oferta = :id", oferta).toInt();
    int miOferta = valorUnico("SELECT id_oferta FROM deportes.inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt();
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM seguridad.usuario WHERE id_usuario = :id", idActual).toInt();
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
    MYSQL_RES *result = hacerSelect("SELECT d.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin FROM deportes.inscripcion_ed_fisica i "
                                    "JOIN deportes.oferta_deporte o ON o.id_oferta = i.id_oferta JOIN deportes.deporte d ON d.id_deporte = o.id_deporte "
                                    "JOIN academico.dia_semana ds ON ds.id_dia = o.id_dia JOIN academico.franja_horaria f ON f.id_franja = o.id_franja "
                                    "WHERE i.id_usuario = " + QString::number(idActual));
    MYSQL_ROW fila = NULL;
    if (result != NULL) fila = mysql_fetch_row(result);
    bool inscripto = fila != NULL;
    if (inscripto) {
        ui->lblEdFisicaMia->setText(QString(fila[0]));
        ui->lblEdFisicaMiaDetalle->setText(QString(fila[1]) + " de " + QString(fila[2]) + " a " + QString(fila[3]) + " hs");
    }
    if (result != NULL) mysql_free_result(result);
    if (!inscripto) {
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
    if (valorUnico("SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt() > 0) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Ya estás inscripto. Cancelá tu inscripción antes de elegir otra.");
        return;
    }
    int cupo = valorUnico("SELECT cupo_maximo FROM deportes.oferta_deporte WHERE id_oferta = :id", oferta).toInt();
    int inscriptos = valorUnico("SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica WHERE id_oferta = :id", oferta).toInt();
    if (inscriptos >= cupo) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Esa opción ya no tiene cupo.");
        return;
    }
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM seguridad.usuario WHERE id_usuario = :id", idActual).toInt();
    QString materia = chocaHorario(oferta, curso);
    if (!materia.isEmpty()) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Esa opción se superpone con " + materia + " en tu horario.");
        return;
    }
    if (!ejecutar("INSERT INTO deportes.inscripcion_ed_fisica (fecha_inscripcion, id_usuario, id_oferta) VALUES (" + valorFecha(QDate::currentDate()) + ", "
                  + QString::number(idActual) + ", " + QString::number(oferta) + ")")) {
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
    if (valorUnico("SELECT COUNT(*) FROM deportes.inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt() == 0) {
        fallar("", "", "No tenés ninguna inscripción para cancelar.");
        return;
    }
    QString deporte = ui->lblEdFisicaMia->text();
    if (!confirmar("Cancelar inscripción", QString("¿Querés cancelar tu inscripción a %1? Después vas a poder elegir otra opción.").arg(deporte))) return;
    if (!ejecutar("DELETE FROM deportes.inscripcion_ed_fisica WHERE id_usuario = " + QString::number(idActual))) {
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
                  "FROM seguridad.log_auditoria l JOIN seguridad.tipo_log t ON t.id_tipo_log = l.id_tipo_log "
                  "JOIN seguridad.resultado_log r ON r.id_resultado = l.id_resultado "
                  "LEFT JOIN seguridad.usuario u ON u.id_usuario = l.id_usuario ";
    if (resultado != "Todos") sql += "WHERE r.nombre_resultado = " + texto(resultado) + " ";
    sql += "ORDER BY l.fecha_hora DESC, l.id_log DESC";
    MYSQL_RES *result = hacerSelect(sql);
    MYSQL_ROW fila;
    int mostrados = 0;
    while (result != NULL && mostrados < 50 && (fila = mysql_fetch_row(result)) != NULL) {
        QString usuario = "desconocido";
        if (fila[1] != NULL) usuario = QString(fila[1]);
        QString texto = QString("%1 · %2 · %3 · %4\n%5").arg(formatoCorto(QString(fila[0]))).arg(usuario)
                            .arg(QString(fila[2])).arg(QString(fila[3])).arg(QString(fila[4]));
        agregarItem(ui->listAuditoria, texto, 0);
        if (QString(fila[3]) == "Fallido") pintarUltimo(ui->listAuditoria, "peligro");
        mostrados++;
    }
    if (result != NULL) mysql_free_result(result);
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
    MYSQL_RES *result = hacerSelect("SELECT s.nombre_software FROM equipos.recurso_software rs JOIN equipos.software s ON s.id_software = rs.id_software "
                                    "WHERE rs.id_recurso = " + QString::number(recurso) + " ORDER BY s.nombre_software");
    MYSQL_ROW fila;
    QStringList programas;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        programas << QString(fila[0]);
    }
    if (result != NULL) mysql_free_result(result);
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
        s1 = "SELECT COUNT(*) FROM objetos.reclamo_objeto WHERE id_usuario = :id";
        t2 = "Tus reservas en la tienda";
        s2 = "SELECT COUNT(*) FROM tienda.venta_buffet v JOIN tienda.estado_venta e ON e.id_estado_venta = v.id_estado_venta "
             "WHERE v.id_usuario = :id AND e.nombre_estado = 'Reservada'";
        t3 = "Préstamos activos a tu nombre";
        s3 = "SELECT COUNT(*) FROM equipos.prestamo_ct WHERE id_usuario_solicitante = :id AND hora_devolucion IS NULL";
    } else if (rol == "Preceptor") {
        t1 = "Reclamos de objetos pendientes";
        s1 = "SELECT COUNT(*) FROM objetos.reclamo_objeto r JOIN objetos.estado_reclamo e ON e.id_estado_reclamo = r.id_estado_reclamo "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
        t2 = "Reservas de sectores pendientes";
        s2 = "SELECT COUNT(*) FROM instalaciones.reserva_sector r JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
             "WHERE e.nombre_estado = 'Pendiente' AND r.fecha_reserva >= :hoy AND :id > 0";
        t3 = "Reportes de higiene pendientes";
        s3 = "SELECT COUNT(*) FROM instalaciones.reporte_higiene r JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
    } else if (rol == "Profesor") {
        t1 = "Tus reservas de sectores";
        s1 = "SELECT COUNT(*) FROM instalaciones.reserva_sector r JOIN instalaciones.estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
             "WHERE r.id_usuario = :id AND e.nombre_estado IN ('Pendiente', 'Aprobada') AND r.fecha_reserva >= :hoy";
        t2 = "Reportes de higiene pendientes";
        s2 = "SELECT COUNT(*) FROM instalaciones.reporte_higiene r JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
        t3 = "Préstamos activos en el colegio";
        s3 = "SELECT COUNT(*) FROM equipos.prestamo_ct WHERE hora_devolucion IS NULL AND :id > 0";
    } else {
        t1 = "Reportes de higiene pendientes";
        s1 = "SELECT COUNT(*) FROM instalaciones.reporte_higiene r JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
             "WHERE e.nombre_estado = 'Pendiente' AND :id > 0";
        t2 = "Equipos fuera de servicio";
        s2 = "SELECT COUNT(*) FROM equipos.recursos_ct r JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso "
             "WHERE e.nombre_estado = 'Fuera de servicio' AND :id > 0";
        t3 = "Préstamos activos en el colegio";
        s3 = "SELECT COUNT(*) FROM equipos.prestamo_ct WHERE hora_devolucion IS NULL AND :id > 0";
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
    cargarCombo(ui->cbBuffetVendedor, "SELECT DISTINCT u.id_usuario, u.nombre_completo FROM seguridad.usuario u "
                                      "JOIN tienda.producto_buffet p ON p.id_usuario = u.id_usuario ORDER BY u.nombre_completo",
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
    MYSQL_RES *result = hacerSelect("SELECT p.nombre_producto, p.precio, p.stock, p.id_usuario, u.nombre_completo, u.contacto_telefono "
                                    "FROM tienda.producto_buffet p JOIN seguridad.usuario u ON u.id_usuario = p.id_usuario WHERE p.id_producto = " + QString::number(producto));
    if (result == NULL) return;
    MYSQL_ROW fila = mysql_fetch_row(result);
    if (fila == NULL) {
        mysql_free_result(result);
        return;
    }
    int stock = QString(fila[2]).toInt();
    QString texto = QString("%1 · $%2 · vende %3 (tel. %4)").arg(QString(fila[0])).arg(QString(fila[1]).toInt())
            .arg(QString(fila[4])).arg(QString(fila[5]));
    if (stock == 0) texto += " · SIN STOCK";
    if (QString(fila[3]).toInt() == idActual) texto += " · es tu producto";
    mysql_free_result(result);
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
    QString textoMeta = valorUnico("SELECT meta_monto FROM tienda.grupo_buffet WHERE id_grupo = :id", grupo);
    if (textoMeta.isEmpty()) return;
    int meta = textoMeta.toInt();
    int juntado = recaudado(grupo);
    int porcentaje = 0;
    if (meta > 0) porcentaje = juntado * 100 / meta;
    int avance = porcentaje;
    if (avance > 100) avance = 100;
    ui->pbGrupoMeta->setValue(avance);
    ui->lblGrupoMeta->setText(QString("Se recaudaron $%1 de $%2 (%3%)").arg(juntado).arg(meta).arg(porcentaje));

    MYSQL_RES *result = hacerSelect("SELECT u.nombre_completo, o.monto, o.fecha_hora FROM tienda.donacion_buffet o JOIN seguridad.usuario u ON u.id_usuario = o.id_usuario "
                                    "WHERE o.id_grupo = " + QString::number(grupo) + " ORDER BY o.id_donacion DESC");
    MYSQL_ROW fila;
    int mostradas = 0;
    while (result != NULL && mostradas < 10 && (fila = mysql_fetch_row(result)) != NULL) {
        agregarItem(ui->listDonaciones, QString("%1 donó $%2 · %3").arg(QString(fila[0])).arg(QString(fila[1]).toInt()).arg(formatoCorto(QString(fila[2]))), 0);
        mostradas++;
    }
    if (result != NULL) mysql_free_result(result);
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
    int pendientes = valorUnico("SELECT COUNT(*) FROM instalaciones.reporte_higiene r JOIN instalaciones.estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte "
                                "WHERE e.nombre_estado = 'Pendiente'", 0).toInt();
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
    MYSQL_RES *result = hacerSelect("SELECT e.nombre_estado, COUNT(*) FROM equipos.recursos_ct r JOIN equipos.estado_recurso e ON e.id_estado_recurso = r.id_estado_recurso "
                                    "GROUP BY e.nombre_estado");
    MYSQL_ROW fila;
    while (result != NULL && (fila = mysql_fetch_row(result)) != NULL) {
        QString estado = QString(fila[0]);
        if (estado == "Disponible") disponibles = QString(fila[1]).toInt();
        if (estado == "Prestado") prestados = QString(fila[1]).toInt();
        if (estado == "Fuera de servicio") fuera = QString(fila[1]).toInt();
    }
    if (result != NULL) mysql_free_result(result);

    ui->lblPlanillasResumen->setText(QString("Disponibles: %1 · Prestados: %2 · Fuera de servicio: %3").arg(disponibles).arg(prestados).arg(fuera));
}