#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>
#include <QMenu>
#include <QCursor>
#include <QComboBox>
#include <QPushButton>
#include <QListWidget>
#include <QListWidgetItem>
#include <QSqlQuery>
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
#include <QVariant>

const QString PIN_PERSONAL = "IQUAL2026";

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , idActual(0)
{
    ui->setupUi(this);
    setFixedSize(800, 600);
    ui->stackedWidget->setCurrentIndex(PAG_LANDING);

    menuUsuario = new QMenu(this);
    menuUsuario->addAction("Menú Principal", this, &MainWindow::irAlMenu);
    menuUsuario->addAction("Mi Cuenta / Perfil", this, &MainWindow::irACuenta);
    menuUsuario->addAction("Cerrar Sesión", this, &MainWindow::cerrarSesion);

    QList<QPushButton *> botonesMenu;
    botonesMenu << ui->btnHamb2 << ui->btnHamb3 << ui->btnHamb4 << ui->btnHamb5
                << ui->btnHamb6 << ui->btnHamb7 << ui->btnHamb8 << ui->btnHamb9;
    for (int i = 0; i < botonesMenu.size(); i++) {
        connect(botonesMenu[i], &QPushButton::clicked, this, &MainWindow::mostrarMenu);
    }

    QList<QPushButton *> botonesVolver;
    botonesVolver << ui->btnVolverObj << ui->btnVolverHigiene << ui->btnVolverBuffet
                  << ui->btnVolverPlanillas << ui->btnVolverSectores << ui->btnVolverEdFisica
                  << ui->btnCuentaVolver;
    for (int i = 0; i < botonesVolver.size(); i++) {
        connect(botonesVolver[i], &QPushButton::clicked, this, &MainWindow::irAlMenu);
    }
    connect(ui->btnVolverAcceso, &QPushButton::clicked, this, &MainWindow::irAlInicio);

    QPixmap logo(":/imagenes/logo.png");
    if (!logo.isNull()) {
        ui->lblLogo->setPixmap(logo.scaled(ui->lblLogo->size(), Qt::KeepAspectRatio, Qt::SmoothTransformation));
    }
    ponerIcono(ui->btnMenuObjetos, "ico_objetos.png");
    ponerIcono(ui->btnMenuHigiene, "ico_higiene.png");
    ponerIcono(ui->btnMenuBuffet, "ico_buffet.png");
    ponerIcono(ui->btnMenuPlanillas, "ico_planillas.png");
    ponerIcono(ui->btnMenuSectores, "ico_sectores.png");
    ponerIcono(ui->btnMenuEdFisica, "ico_edfisica.png");

    ui->deSectoresDia->setMinimumDate(QDate::currentDate());
    ui->deSectoresDia->setDate(QDate::currentDate());
    ui->teSectoresInicio->setTime(QTime(8, 0));
    ui->teSectoresFin->setTime(QTime(9, 0));

    if (!abrirBase()) {
        aviso("No se pudo abrir ni crear la base de datos iqual.db junto al programa.");
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
    QString ruta = QCoreApplication::applicationDirPath() + "/iqual.db";
    bool nueva = !QFile::exists(ruta);
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(ruta);
    if (!db.open()) return false;
    QSqlQuery q;
    q.prepare("PRAGMA foreign_keys = ON");
    q.exec();
    if (!nueva) return true;

    QFile script(":/imagenes/iqual_sqlite.sql");
    if (!script.open(QIODevice::ReadOnly | QIODevice::Text)) {
        db.close();
        QFile::remove(ruta);
        return false;
    }
    QTextStream entrada(&script);
    QStringList sentencias = entrada.readAll().split(";");
    db.transaction();
    for (int i = 0; i < sentencias.size(); i++) {
        QString sentencia = sentencias[i].trimmed();
        if (sentencia.isEmpty()) continue;
        if (!q.exec(sentencia)) {
            db.rollback();
            db.close();
            QFile::remove(ruta);
            return false;
        }
    }
    db.commit();
    return true;
}

void MainWindow::ponerIcono(QPushButton *boton, const QString &archivo)
{
    QPixmap imagen(":/imagenes/" + archivo);
    if (imagen.isNull()) return;
    boton->setIcon(QIcon(imagen));
    boton->setIconSize(QSize(40, 40));
}

void MainWindow::cargarCatalogos()
{
    cargarCombo(ui->cbRegRol, "SELECT id_rol, nombre_rol FROM rol ORDER BY id_rol", "Elegí tu rol", "");
    cargarCursoCombos(ui->cbRegAnio, ui->cbRegDivision, ui->cbRegEspecialidad);
    cargarCursoCombos(ui->cbCuentaAnio, ui->cbCuentaDivision, ui->cbCuentaEspecialidad);
    cargarCombo(ui->cbHigieneSector, "SELECT id_sector, nombre_sector FROM sector ORDER BY nombre_sector", "", "");
    cargarCombo(ui->cbHigieneTipo, "SELECT id_tipo_reporte, nombre_tipo FROM tipo_reporte ORDER BY id_tipo_reporte", "", "");
    cargarCombo(ui->cbObjCategoria, "SELECT id_categoria_objeto, nombre_categoria FROM categoria_objeto ORDER BY nombre_categoria", "", "");
    cargarCombo(ui->cbObjSector, "SELECT id_sector, nombre_sector FROM sector ORDER BY nombre_sector", "", "");
    cargarCombo(ui->cbSectoresLugar, "SELECT s.id_sector, s.nombre_sector FROM sector s JOIN tipo_sector t ON t.id_tipo_sector = s.id_tipo_sector "
                                          "WHERE t.nombre_tipo = 'Reservable' ORDER BY s.nombre_sector", "", "");
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
    cargarObjetos();
    cargarReclamos();
    cargarConsultas();
    cargarHigiene();
    actualizarUltimoMantenimiento();
    cargarGrupos();
    cargarBuffet();
    cargarMisReservas();
    cargarCombo(ui->cbPlanillasAlumno, "SELECT u.id_usuario, u.nombre_completo FROM usuario u JOIN rol r ON r.id_rol = u.id_rol "
                                       "WHERE r.nombre_rol = 'Alumno' ORDER BY u.nombre_completo", "Elegí el alumno", "");
    if (rolActual() == "Alumno") ui->cbPlanillasAlumno->setCurrentIndex(ui->cbPlanillasAlumno->findData(idActual));
    cargarPlanillas();
    cargarPrestamos();
    cargarOcupacion();
    cargarReservasSector();
    cargarEdFisica();
}

void MainWindow::aplicarPermisos()
{
    QString rol = rolActual();
    bool alumno = rol == "Alumno";
    bool preceptor = rol == "Preceptor";
    bool docente = rolEs("Profesor,Preceptor");

    ui->tabObjetos->setTabEnabled(2, preceptor);
    habilitar(preceptor, QList<QWidget *>() << ui->btnReclamoAprobar << ui->btnReclamoRechazar << ui->btnObjArchivar);
    habilitar(alumno, QList<QWidget *>() << ui->leObjPrueba << ui->btnObjReclamar);
    habilitar(rolEs("Profesor,Preceptor,Maestranza"), QList<QWidget *>() << ui->btnHigieneResolver);
    ui->tabBuffet->setTabEnabled(1, alumno);
    habilitar(alumno, QList<QWidget *>() << ui->leGrupoNombre << ui->leGrupoMeta << ui->leGrupoPin
              << ui->btnGrupoCrear << ui->cbUnirseGrupo << ui->leBuffetPin << ui->btnBuffetUnirse);
    habilitar(docente, QList<QWidget *>() << ui->cbPlanillasAlumno);
    habilitar(rolEs("Alumno,Profesor,Preceptor"), QList<QWidget *>() << ui->lePlanillasObs << ui->btnPlanillasPrestar
              << ui->cbPlanillasEstado << ui->btnPlanillasDevolver);
    habilitar(docente, QList<QWidget *>() << ui->teSectoresInicio << ui->teSectoresFin
              << ui->btnSectoresReservar << ui->btnSectoresCancelar);
    habilitar(preceptor, QList<QWidget *>() << ui->btnSectoresAprobar << ui->btnSectoresRechazar);
    habilitar(alumno, QList<QWidget *>() << ui->btnEdFisicaInscribir << ui->btnEdFisicaCancelar);
    habilitar(alumno, QList<QWidget *>() << ui->cbCuentaAnio << ui->cbCuentaDivision
              << ui->cbCuentaEspecialidad << ui->btnCuentaGuardar);
}

void MainWindow::habilitar(bool si, QList<QWidget *> widgets)
{
    for (int i = 0; i < widgets.size(); i++) {
        widgets[i]->setEnabled(si);
    }
}

int MainWindow::idPorNombre(const QString &tabla, const QString &columnaId, const QString &columnaNombre, const QString &valor)
{
    QSqlQuery q;
    q.prepare(QString("SELECT %1 FROM %2 WHERE %3 = :valor").arg(columnaId, tabla, columnaNombre));
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

bool MainWindow::existe(const QString &tabla, const QString &columna, const QString &valor)
{
    QSqlQuery q;
    q.prepare(QString("SELECT COUNT(*) FROM %1 WHERE %2 = :valor").arg(tabla, columna));
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
    QSqlQuery q;
    q.prepare("INSERT INTO log_auditoria (fecha_hora, direccion_ip, descripcion_evento, id_entidad, id_usuario, id_tipo_log, id_resultado) "
              "VALUES (:fecha, :ip, :descripcion, :entidad, :usuario, :tipo, :resultado)");
    q.bindValue(":fecha", ahora());
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

QString MainWindow::hoy()
{
    return QDate::currentDate().toString("yyyy-MM-dd");
}

QString MainWindow::formatoCorto(const QString &fechaHora)
{
    return QDateTime::fromString(fechaHora, "yyyy-MM-dd HH:mm:ss").toString("dd/MM HH:mm");
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
    return q.lastInsertId().toInt();
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
    if (carro.isEmpty()) return QString("Tablero %1").arg(numero, 2, 10, QChar('0'));
    return QString("%1-%2").arg(carro).arg(numero, 2, 10, QChar('0'));
}

void MainWindow::mostrarMenu() { menuUsuario->exec(QCursor::pos()); }
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
    habilitar(alumno, QList<QWidget *>() << ui->cbRegAnio << ui->cbRegDivision << ui->cbRegEspecialidad);
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
    QString nick = ui->leRegUsuario->text().trimmed();
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
    else if (existe("usuario", "usuario_nick", nick)) problema = "Ese usuario ya existe, probá con otro.";
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
    QString nick = ui->leUsuario->text().trimmed();
    QString clave = ui->leClave->text();
    if (nick.isEmpty() || clave.isEmpty()) {
        aviso("Completá el usuario y la contraseña.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT id_usuario FROM usuario WHERE usuario_nick = :nick AND password_hash = :hash");
    q.bindValue(":nick", nick);
    q.bindValue(":hash", hashClave(clave));
    q.exec();
    if (!q.next()) {
        aviso("Usuario o contraseña incorrectos.");
        idActual = idPorNombre("usuario", "id_usuario", "usuario_nick", nick);
        registrarLog("Inicio de sesión", QString("Intento fallido con el usuario %1").arg(nick), "usuario", "Fallido");
        idActual = 0;
        return;
    }
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
    ui->lblBienvenida->setText(QString("Hola, %1 (%2)").arg(q.value(0).toString(), q.value(5).toString()));
    ui->lblCuentaNombre->setText("Nombre completo: " + q.value(0).toString());
    ui->lblCuentaUsuario->setText("Usuario: " + q.value(1).toString());
    ui->lblCuentaDni->setText("DNI: " + q.value(2).toString());
    ui->lblCuentaMail->setText("Correo: " + q.value(3).toString());
    ui->lblCuentaContacto->setText("Teléfono: " + q.value(4).toString());
    ui->lblCuentaRol->setText("Rol: " + q.value(5).toString());
    ui->lblCuentaCurso->setText("Curso: " + textoCurso(q.value(6).toInt()));
    ui->cbCuentaAnio->setCurrentIndex(qMax(0, ui->cbCuentaAnio->findData(q.value(7).toInt())));
    ui->cbCuentaDivision->setCurrentIndex(qMax(0, ui->cbCuentaDivision->findData(q.value(8).toInt())));
    ui->cbCuentaEspecialidad->setCurrentIndex(qMax(0, ui->cbCuentaEspecialidad->findData(q.value(9).toInt())));
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
    QSqlQuery q;
    q.prepare("UPDATE usuario SET id_curso = :curso WHERE id_usuario = :usuario");
    q.bindValue(":curso", curso);
    q.bindValue(":usuario", idActual);
    if (curso == 0 || !q.exec()) {
        fallar("", "", "No se pudo guardar el curso.");
        return;
    }
    int oferta = valorUnico("SELECT id_oferta FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt();
    QString materia = "";
    bool cancelada = false;
    if (oferta != 0 && chocaHorario(oferta, curso, materia)) {
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
        info("Curso actualizado. Se canceló tu inscripción a Educación Física porque se superpone con " + materia + " en tu nuevo horario.");
        return;
    }
    info("Curso actualizado.");
}

void MainWindow::on_btnMenuObjetos_clicked() { ui->stackedWidget->setCurrentIndex(PAG_OBJETOS); }
void MainWindow::on_btnMenuHigiene_clicked() { ui->stackedWidget->setCurrentIndex(PAG_HIGIENE); }
void MainWindow::on_btnMenuBuffet_clicked() { ui->stackedWidget->setCurrentIndex(PAG_BUFFET); }
void MainWindow::on_btnMenuPlanillas_clicked() { ui->stackedWidget->setCurrentIndex(PAG_PLANILLAS); }
void MainWindow::on_btnMenuSectores_clicked() { ui->stackedWidget->setCurrentIndex(PAG_SECTORES); }
void MainWindow::on_btnMenuEdFisica_clicked() { ui->stackedWidget->setCurrentIndex(PAG_EDFISICA); }

void MainWindow::cargarObjetos()
{
    ui->listObjetos->clear();
    QSqlQuery q;
    q.prepare("SELECT o.id_objeto, o.titulo, o.descripcion, o.ruta_foto, c.nombre_categoria, s.nombre_sector, e.nombre_estado "
              "FROM objeto_perdido o JOIN categoria_objeto c ON c.id_categoria_objeto = o.id_categoria_objeto "
              "JOIN sector s ON s.id_sector = o.id_sector JOIN estado_objeto e ON e.id_estado_objeto = o.id_estado_objeto "
              "WHERE o.id_estado_objeto <> :archivado ORDER BY o.id_objeto DESC");
    q.bindValue(":archivado", idEstado("estado_objeto", "Archivado"));
    q.exec();
    while (q.next()) {
        QString texto = QString("%1 (%2) - hallado en %3 - %4").arg(q.value(1).toString(), q.value(4).toString(),
                                                                    q.value(5).toString(), q.value(6).toString());
        if (!q.value(2).toString().isEmpty()) texto += " - " + q.value(2).toString();
        if (!q.value(3).toString().isEmpty()) texto += " [con foto]";
        agregarItem(ui->listObjetos, texto, q.value(0).toInt());
    }
}

void MainWindow::cargarReclamos()
{
    ui->listReclamos->clear();
    if (!rolEs("Preceptor")) return;
    QSqlQuery q;
    q.prepare("SELECT r.id_reclamo, r.id_objeto, o.titulo, u.nombre_completo, r.prueba_pertenencia "
              "FROM reclamo_objeto r JOIN objeto_perdido o ON o.id_objeto = r.id_objeto "
              "JOIN usuario u ON u.id_usuario = r.id_usuario WHERE r.id_estado_reclamo = :pendiente ORDER BY r.id_reclamo");
    q.bindValue(":pendiente", idEstado("estado_reclamo", "Pendiente"));
    q.exec();
    while (q.next()) {
        QString texto = QString("%1 - lo reclama %2. Prueba: %3").arg(q.value(2).toString(), q.value(3).toString(), q.value(4).toString());
        agregarItem(ui->listReclamos, texto, q.value(0).toInt(), q.value(1).toInt());
    }
}

void MainWindow::on_btnObjReclamar_clicked()
{
    if (!exigir("Alumno", "Reclamo de objeto", "reclamo_objeto")) return;
    int objeto = seleccionado(ui->listObjetos);
    QString prueba = ui->leObjPrueba->text().trimmed();
    if (objeto == 0) {
        fallar("Reclamo de objeto", "reclamo_objeto", "Elegí un objeto de la lista.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM objeto_perdido o JOIN estado_objeto e "
                                "ON e.id_estado_objeto = o.id_estado_objeto WHERE o.id_objeto = :id", objeto);
    if (estado != "Disponible") {
        fallar("Reclamo de objeto", "reclamo_objeto", "Ese objeto no está disponible: ya tiene un reclamo o fue devuelto.");
        return;
    }
    if (prueba.size() < 10) {
        fallar("Reclamo de objeto", "reclamo_objeto", "La prueba de pertenencia tiene que tener al menos 10 caracteres.");
        return;
    }
    db.transaction();
    QSqlQuery q;
    q.prepare("INSERT INTO reclamo_objeto (prueba_pertenencia, fecha_reclamo, id_usuario, id_objeto, id_estado_reclamo) "
              "VALUES (:prueba, :fecha, :usuario, :objeto, :estado)");
    q.bindValue(":prueba", prueba);
    q.bindValue(":fecha", hoy());
    q.bindValue(":usuario", idActual);
    q.bindValue(":objeto", objeto);
    q.bindValue(":estado", idEstado("estado_reclamo", "Pendiente"));
    bool ok = q.exec();
    q.prepare("UPDATE objeto_perdido SET id_estado_objeto = :estado WHERE id_objeto = :objeto");
    q.bindValue(":estado", idEstado("estado_objeto", "En reclamo"));
    q.bindValue(":objeto", objeto);
    ok = ok && q.exec();
    if (!ok) {
        db.rollback();
        fallar("Reclamo de objeto", "reclamo_objeto", "No se pudo registrar el reclamo.");
        return;
    }
    db.commit();
    registrarLog("Reclamo de objeto", QString("Reclamo sobre el objeto %1").arg(objeto), "reclamo_objeto", "Exitoso");
    ui->leObjPrueba->clear();
    cargarObjetos();
    cargarReclamos();
    info("Reclamo enviado. El preceptor lo va a revisar.");
}

void MainWindow::resolverReclamo(const QString &estadoReclamo, const QString &estadoObjeto, const QString &evento)
{
    if (!exigir("Preceptor", evento, "reclamo_objeto")) return;
    int reclamo = seleccionado(ui->listReclamos);
    int objeto = seleccionado(ui->listReclamos, Qt::UserRole + 1);
    if (reclamo == 0) {
        fallar(evento, "reclamo_objeto", "Elegí un reclamo de la lista.");
        return;
    }
    db.transaction();
    QSqlQuery q;
    q.prepare("UPDATE reclamo_objeto SET id_estado_reclamo = :estado WHERE id_reclamo = :reclamo");
    q.bindValue(":estado", idEstado("estado_reclamo", estadoReclamo));
    q.bindValue(":reclamo", reclamo);
    bool ok = q.exec();
    q.prepare("UPDATE objeto_perdido SET id_estado_objeto = :estado WHERE id_objeto = :objeto");
    q.bindValue(":estado", idEstado("estado_objeto", estadoObjeto));
    q.bindValue(":objeto", objeto);
    ok = ok && q.exec();
    if (!ok) {
        db.rollback();
        fallar(evento, "reclamo_objeto", "No se pudo actualizar el reclamo.");
        return;
    }
    db.commit();
    registrarLog(evento, QString("Reclamo %1: %2").arg(reclamo).arg(estadoReclamo), "reclamo_objeto", "Exitoso");
    cargarObjetos();
    cargarReclamos();
}

void MainWindow::on_btnReclamoAprobar_clicked() { resolverReclamo("Aprobado", "Devuelto", "Resolución de reclamo"); }
void MainWindow::on_btnReclamoRechazar_clicked() { resolverReclamo("Rechazado", "Disponible", "Resolución de reclamo"); }

void MainWindow::on_btnObjArchivar_clicked()
{
    if (!exigir("Preceptor", "", "")) return;
    int objeto = seleccionado(ui->listObjetos);
    if (objeto == 0) {
        fallar("", "", "Elegí un objeto de la lista.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM objeto_perdido o JOIN estado_objeto e "
                                "ON e.id_estado_objeto = o.id_estado_objeto WHERE o.id_objeto = :id", objeto);
    if (estado == "En reclamo") {
        fallar("", "", "Ese objeto tiene un reclamo pendiente. Resolvelo antes de archivarlo.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE objeto_perdido SET id_estado_objeto = :estado WHERE id_objeto = :objeto");
    q.bindValue(":estado", idEstado("estado_objeto", "Archivado"));
    q.bindValue(":objeto", objeto);
    if (!q.exec()) {
        fallar("", "", "No se pudo archivar el objeto.");
        return;
    }
    cargarObjetos();
}

void MainWindow::on_btnObjFoto_clicked()
{
    QString ruta = QFileDialog::getOpenFileName(this, "Elegir foto", "", "Imágenes (*.png *.jpg *.jpeg)");
    if (ruta.isEmpty()) return;
    fotoElegida = ruta;
    ui->lblObjFoto->setText("Foto: " + QFileInfo(ruta).fileName());
}

void MainWindow::on_btnObjPublicar_clicked()
{
    if (!exigir("Preceptor", "Publicación de objeto", "objeto_perdido")) return;
    QString titulo = ui->leObjTitulo->text().trimmed();
    QString descripcion = ui->leObjDescripcion->text().trimmed();
    if (titulo.isEmpty()) {
        fallar("Publicación de objeto", "objeto_perdido", "Escribí un título para el objeto.");
        return;
    }
    QString archivo = "";
    if (!fotoElegida.isEmpty()) {
        archivo = QDateTime::currentDateTime().toString("yyyyMMddHHmmss") + "_" + QFileInfo(fotoElegida).fileName();
        QString carpeta = QCoreApplication::applicationDirPath() + "/imagenes_objetos";
        QDir().mkpath(carpeta);
        if (!QFile::copy(fotoElegida, carpeta + "/" + archivo)) {
            fallar("Publicación de objeto", "objeto_perdido", "No se pudo copiar la foto elegida.");
            return;
        }
    }
    QVariant valorDescripcion;
    if (!descripcion.isEmpty()) valorDescripcion = descripcion;
    QVariant valorFoto;
    if (!archivo.isEmpty()) valorFoto = archivo;
    QSqlQuery q;
    q.prepare("INSERT INTO objeto_perdido (titulo, descripcion, ruta_foto, fecha_registro, id_usuario, id_categoria_objeto, id_estado_objeto, id_sector) "
              "VALUES (:titulo, :descripcion, :foto, :fecha, :usuario, :categoria, :estado, :sector)");
    q.bindValue(":titulo", titulo);
    q.bindValue(":descripcion", valorDescripcion);
    q.bindValue(":foto", valorFoto);
    q.bindValue(":fecha", hoy());
    q.bindValue(":usuario", idActual);
    q.bindValue(":categoria", ui->cbObjCategoria->currentData().toInt());
    q.bindValue(":estado", idEstado("estado_objeto", "Disponible"));
    q.bindValue(":sector", ui->cbObjSector->currentData().toInt());
    if (!q.exec()) {
        fallar("Publicación de objeto", "objeto_perdido", "No se pudo publicar el objeto.");
        return;
    }
    registrarLog("Publicación de objeto", QString("Objeto publicado: %1").arg(titulo), "objeto_perdido", "Exitoso");
    ui->leObjTitulo->clear();
    ui->leObjDescripcion->clear();
    ui->lblObjFoto->setText("Sin foto");
    fotoElegida = "";
    cargarObjetos();
    info("Objeto publicado.");
}

void MainWindow::cargarConsultas()
{
    ui->listConsultas->clear();
    QSqlQuery q;
    q.prepare("SELECT c.id_consulta, c.id_usuario, u.nombre_completo, u.contacto_telefono, c.descripcion_busqueda "
              "FROM consulta_objeto c JOIN usuario u ON u.id_usuario = c.id_usuario ORDER BY c.id_consulta DESC");
    q.exec();
    while (q.next()) {
        QString texto = QString("%1 (tel. %2): %3").arg(q.value(2).toString(), q.value(3).toString(), q.value(4).toString());
        agregarItem(ui->listConsultas, texto, q.value(0).toInt(), q.value(1).toInt());
    }
}

void MainWindow::on_btnConsultaPublicar_clicked()
{
    QString descripcion = ui->leConsultaDesc->text().trimmed();
    if (descripcion.size() < 10) {
        fallar("", "", "La consulta tiene que tener al menos 10 caracteres.");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO consulta_objeto (fecha_publicacion, descripcion_busqueda, id_usuario) VALUES (:fecha, :descripcion, :usuario)");
    q.bindValue(":fecha", hoy());
    q.bindValue(":descripcion", descripcion);
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo publicar la consulta.");
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
    QSqlQuery q;
    q.prepare("DELETE FROM consulta_objeto WHERE id_consulta = :consulta");
    q.bindValue(":consulta", consulta);
    if (!q.exec()) {
        fallar("", "", "No se pudo borrar la consulta.");
        return;
    }
    cargarConsultas();
}

void MainWindow::on_leConsultaDesc_returnPressed() { on_btnConsultaPublicar_clicked(); }

void MainWindow::cargarHigiene()
{
    ui->listHigiene->clear();
    QSqlQuery q;
    q.prepare("SELECT r.id_reporte, r.fecha_hora, r.observaciones, s.nombre_sector, t.nombre_tipo, e.nombre_estado, "
              "u.nombre_completo, r.fecha_hora_resolucion, rs.nombre_completo FROM reporte_higiene r "
              "JOIN sector s ON s.id_sector = r.id_sector JOIN tipo_reporte t ON t.id_tipo_reporte = r.id_tipo_reporte "
              "JOIN estado_reporte e ON e.id_estado_reporte = r.id_estado_reporte JOIN usuario u ON u.id_usuario = r.id_usuario "
              "LEFT JOIN usuario rs ON rs.id_usuario = r.id_usuario_resolutor ORDER BY r.id_reporte DESC");
    q.exec();
    while (q.next()) {
        QString texto = QString("[%1] %2 - %3 - %4 - %5 (reportó %6)").arg(q.value(5).toString(), formatoCorto(q.value(1).toString()),
                                                                           q.value(3).toString(), q.value(4).toString(),
                                                                           q.value(2).toString(), q.value(6).toString());
        if (!q.value(7).isNull()) {
            texto += QString(" - resuelto %1 por %2").arg(formatoCorto(q.value(7).toString()), q.value(8).toString());
        }
        agregarItem(ui->listHigiene, texto, q.value(0).toInt());
    }
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
        ui->lblHigieneUltimo->setText(QString("Último mantenimiento: %1 — %2").arg(formatoCorto(q.value(0).toString()), q.value(1).toString()));
    } else {
        ui->lblHigieneUltimo->setText("Último mantenimiento: ninguno registrado");
    }
}

void MainWindow::on_cbHigieneSector_currentIndexChanged(int) { actualizarUltimoMantenimiento(); }

void MainWindow::on_btnHigieneReportar_clicked()
{
    QString observaciones = ui->leHigieneObs->text().trimmed();
    if (observaciones.isEmpty()) {
        fallar("Reporte de higiene", "reporte_higiene", "Contanos qué pasa en las observaciones.");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO reporte_higiene (fecha_hora, observaciones, id_usuario, id_sector, id_tipo_reporte, id_estado_reporte) "
              "VALUES (:fecha, :observaciones, :usuario, :sector, :tipo, :estado)");
    q.bindValue(":fecha", ahora());
    q.bindValue(":observaciones", observaciones);
    q.bindValue(":usuario", idActual);
    q.bindValue(":sector", ui->cbHigieneSector->currentData().toInt());
    q.bindValue(":tipo", ui->cbHigieneTipo->currentData().toInt());
    q.bindValue(":estado", idEstado("estado_reporte", "Pendiente"));
    if (!q.exec()) {
        fallar("Reporte de higiene", "reporte_higiene", "No se pudo enviar el reporte.");
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
    q.bindValue(":fecha", ahora());
    q.bindValue(":usuario", idActual);
    q.bindValue(":reporte", reporte);
    if (!q.exec()) {
        fallar("Resolución de reporte", "reporte_higiene", "No se pudo marcar el reporte como resuelto.");
        return;
    }
    registrarLog("Resolución de reporte", QString("Reporte %1 resuelto").arg(reporte), "reporte_higiene", "Exitoso");
    cargarHigiene();
    actualizarUltimoMantenimiento();
}

void MainWindow::cargarGrupos()
{
    int vista = ui->cbBuffetVista->currentData().toInt();
    cargarCombo(ui->cbBuffetVista, "SELECT id_grupo, nombre_grupo FROM grupo_buffet ORDER BY nombre_grupo", "Ventas individuales", "");
    ui->cbBuffetVista->setCurrentIndex(qMax(0, ui->cbBuffetVista->findData(vista)));
    cargarCombo(ui->cbUnirseGrupo, "SELECT id_grupo, nombre_grupo FROM grupo_buffet ORDER BY nombre_grupo", "", "");
    cargarCombo(ui->cbDonarGrupo, "SELECT id_grupo, nombre_grupo FROM grupo_buffet ORDER BY nombre_grupo", "", "");

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
}

int MainWindow::recaudado(int grupo)
{
    QSqlQuery q;
    q.prepare("SELECT COALESCE((SELECT SUM(monto) FROM donacion_buffet WHERE id_grupo = :grupo), 0) + "
              "COALESCE((SELECT SUM(d.cantidad * d.precio_unitario) FROM detalle_venta d "
              "JOIN venta_buffet v ON v.id_venta = d.id_venta JOIN producto_buffet p ON p.id_producto = d.id_producto "
              "WHERE p.id_grupo = :grupo AND v.id_estado_venta <> :cancelada), 0)");
    q.bindValue(":grupo", grupo);
    q.bindValue(":cancelada", idEstado("estado_venta", "Cancelada"));
    q.exec();
    q.next();
    return q.value(0).toInt();
}

void MainWindow::cargarBuffet()
{
    ui->listBuffet->clear();
    ui->listDonaciones->clear();
    int grupo = ui->cbBuffetVista->currentData().toInt();

    QString sql = "SELECT p.id_producto, p.nombre_producto, p.precio, p.stock, u.nombre_completo, u.contacto_telefono "
                  "FROM producto_buffet p JOIN usuario u ON u.id_usuario = p.id_usuario ";
    if (grupo > 0) sql += "WHERE p.id_grupo = :grupo ";
    else sql += "WHERE p.id_grupo IS NULL ";
    sql += "ORDER BY p.nombre_producto";
    QSqlQuery q;
    q.prepare(sql);
    if (grupo > 0) q.bindValue(":grupo", grupo);
    q.exec();
    while (q.next()) {
        QString texto = QString("%1 - $%2 - stock %3 - vende %4 (tel. %5)").arg(q.value(1).toString()).arg(q.value(2).toInt())
                .arg(q.value(3).toInt()).arg(q.value(4).toString(), q.value(5).toString());
        if (q.value(3).toInt() == 0) texto += " - SIN STOCK";
        agregarItem(ui->listBuffet, texto, q.value(0).toInt());
    }

    if (grupo == 0) {
        ui->lblBuffetMeta->setText("Ventas individuales (no tienen meta)");
        return;
    }
    QSqlQuery g;
    g.prepare("SELECT meta_monto FROM grupo_buffet WHERE id_grupo = :grupo");
    g.bindValue(":grupo", grupo);
    g.exec();
    if (!g.next()) return;
    int meta = g.value(0).toInt();
    int juntado = recaudado(grupo);
    ui->lblBuffetMeta->setText(QString("Meta: $%1 - Recaudado: $%2 - %3%").arg(meta).arg(juntado).arg(juntado * 100 / meta));

    QSqlQuery d;
    d.prepare("SELECT u.nombre_completo, o.monto FROM donacion_buffet o JOIN usuario u ON u.id_usuario = o.id_usuario "
              "WHERE o.id_grupo = :grupo ORDER BY o.id_donacion DESC");
    d.bindValue(":grupo", grupo);
    d.exec();
    int mostradas = 0;
    while (d.next() && mostradas < 10) {
        agregarItem(ui->listDonaciones, QString("%1 donó $%2").arg(d.value(0).toString()).arg(d.value(1).toInt()), 0);
        mostradas++;
    }
}

void MainWindow::on_cbBuffetVista_currentIndexChanged(int) { cargarBuffet(); }

void MainWindow::cargarMisReservas()
{
    ui->listMisReservas->clear();
    QSqlQuery q;
    q.prepare("SELECT v.id_venta, p.nombre_producto, d.cantidad, "
              "(SELECT SUM(x.cantidad * x.precio_unitario) FROM detalle_venta x WHERE x.id_venta = v.id_venta), "
              "u.nombre_completo, u.contacto_telefono, v.fecha_hora "
              "FROM venta_buffet v JOIN detalle_venta d ON d.id_venta = v.id_venta "
              "JOIN producto_buffet p ON p.id_producto = d.id_producto JOIN usuario u ON u.id_usuario = p.id_usuario "
              "WHERE v.id_usuario = :usuario AND v.id_estado_venta = :reservada ORDER BY v.id_venta DESC");
    q.bindValue(":usuario", idActual);
    q.bindValue(":reservada", idEstado("estado_venta", "Reservada"));
    q.exec();
    while (q.next()) {
        QString texto = QString("%1 x%2 - $%3 - vende %4 (tel. %5) - reservado %6").arg(q.value(1).toString()).arg(q.value(2).toInt())
                .arg(q.value(3).toInt()).arg(q.value(4).toString(), q.value(5).toString(), formatoCorto(q.value(6).toString()));
        agregarItem(ui->listMisReservas, texto, q.value(0).toInt());
    }
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
        fallar("Reserva de producto", "venta_buffet", QString("No alcanza el stock: quedan %1 unidades.").arg(stock));
        return;
    }
    db.transaction();
    q.prepare("INSERT INTO venta_buffet (fecha_hora, id_usuario, id_estado_venta) VALUES (:fecha, :usuario, :estado)");
    q.bindValue(":fecha", ahora());
    q.bindValue(":usuario", idActual);
    q.bindValue(":estado", idEstado("estado_venta", "Reservada"));
    bool ok = q.exec();
    int venta = q.lastInsertId().toInt();
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
    QString estado = valorUnico("SELECT e.nombre_estado FROM venta_buffet v JOIN estado_venta e ON e.id_estado_venta = v.id_estado_venta WHERE v.id_venta = :id", venta);
    if (estado != "Reservada") {
        fallar("", "", "Esa reserva ya no está activa.");
        return;
    }
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
        fallar("", "", "No se pudo cancelar la reserva.");
        return;
    }
    db.commit();
    cargarBuffet();
    cargarMisReservas();
    info("Reserva cancelada. El stock volvió al producto.");
}

void MainWindow::on_btnBuffetDonar_clicked()
{
    int grupo = ui->cbDonarGrupo->currentData().toInt();
    bool ok;
    int monto = ui->leBuffetMonto->text().trimmed().toInt(&ok);
    if (grupo == 0) {
        fallar("Donación", "donacion_buffet", "No hay ningún grupo para donar.");
        return;
    }
    if (!ok || monto <= 0) {
        fallar("Donación", "donacion_buffet", "El monto tiene que ser un número entero mayor a 0.");
        return;
    }
    QSqlQuery q;
    q.prepare("INSERT INTO donacion_buffet (monto, fecha_hora, id_usuario, id_grupo) VALUES (:monto, :fecha, :usuario, :grupo)");
    q.bindValue(":monto", monto);
    q.bindValue(":fecha", ahora());
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

void MainWindow::on_btnBuffetUnirse_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    int grupo = ui->cbUnirseGrupo->currentData().toInt();
    if (grupo == 0) {
        fallar("", "", "No hay ningún grupo para unirse.");
        return;
    }
    QString pin = valorUnico("SELECT pin_acceso FROM grupo_buffet WHERE id_grupo = :id", grupo);
    if (ui->leBuffetPin->text().trimmed() != pin) {
        fallar("", "", "El PIN del grupo es incorrecto.");
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

void MainWindow::on_btnProdPublicar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    QString nombre = ui->leProdNombre->text().trimmed();
    bool okPrecio;
    bool okStock;
    int precio = ui->leProdPrecio->text().trimmed().toInt(&okPrecio);
    int stock = ui->leProdStock->text().trimmed().toInt(&okStock);
    int grupo = ui->cbProdGrupo->currentData().toInt();
    if (nombre.isEmpty()) {
        fallar("", "", "Escribí el nombre del producto.");
        return;
    }
    if (!okPrecio || precio <= 0 || !okStock || stock <= 0) {
        fallar("", "", "El precio y el stock tienen que ser números enteros mayores a 0.");
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
    QSqlQuery q;
    q.prepare("INSERT INTO producto_buffet (nombre_producto, precio, stock, id_usuario, id_grupo) VALUES (:nombre, :precio, :stock, :usuario, :grupo)");
    q.bindValue(":nombre", nombre);
    q.bindValue(":precio", precio);
    q.bindValue(":stock", stock);
    q.bindValue(":usuario", idActual);
    q.bindValue(":grupo", valorGrupo);
    if (!q.exec()) {
        fallar("", "", "No se pudo publicar el producto.");
        return;
    }
    ui->leProdNombre->clear();
    ui->leProdPrecio->clear();
    ui->leProdStock->clear();
    cargarBuffet();
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
        fallar("", "", "La meta tiene que ser un número entero mayor a 0.");
        return;
    }
    if (pin.size() < 4) {
        fallar("", "", "El PIN tiene que tener al menos 4 caracteres.");
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
    int grupo = q.lastInsertId().toInt();
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
    ui->listPlanillas->clear();
    QSqlQuery q;
    q.prepare("SELECT r.id_recurso, c.nombre_carro, r.numero_equipo, t.nombre_tipo FROM recursos_ct r "
              "LEFT JOIN carro c ON c.id_carro = r.id_carro JOIN tipo_recurso t ON t.id_tipo_recurso = r.id_tipo_recurso "
              "WHERE r.id_estado_recurso = :disponible ORDER BY t.nombre_tipo, c.nombre_carro, r.numero_equipo");
    q.bindValue(":disponible", idEstado("estado_recurso", "Disponible"));
    q.exec();
    while (q.next()) {
        QString codigo = codigoRecurso(q.value(1).toString(), q.value(2).toInt());
        if (!filtro.isEmpty() && !codigo.contains(filtro, Qt::CaseInsensitive)) continue;
        agregarItem(ui->listPlanillas, QString("%1 (%2)").arg(codigo, q.value(3).toString()), q.value(0).toInt());
    }
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
    q.prepare("SELECT p.id_prestamo, a.nombre_completo, an.numero_anio, dv.numero_division, c.nombre_carro, r.numero_equipo, "
              "p.hora_prestamo, p.hora_devolucion, au.nombre_completo FROM prestamo_ct p "
              "JOIN usuario a ON a.id_usuario = p.id_usuario_solicitante LEFT JOIN curso cu ON cu.id_curso = a.id_curso "
              "LEFT JOIN anio an ON an.id_anio = cu.id_anio LEFT JOIN division dv ON dv.id_division = cu.id_division "
              "JOIN usuario au ON au.id_usuario = p.id_usuario_autorizador JOIN recursos_ct r ON r.id_recurso = p.id_recurso "
              "LEFT JOIN carro c ON c.id_carro = r.id_carro "
              "ORDER BY CASE WHEN p.hora_devolucion IS NULL THEN 0 ELSE 1 END, p.id_prestamo DESC");
    q.exec();
    int mostrados = 0;
    while (q.next() && mostrados < 40) {
        QString codigo = codigoRecurso(q.value(4).toString(), q.value(5).toInt());
        if (!filtro.isEmpty() && !codigo.contains(filtro, Qt::CaseInsensitive)) continue;
        QString curso = "sin curso";
        if (!q.value(2).isNull()) curso = QString("%1°%2°").arg(q.value(2).toInt()).arg(q.value(3).toInt());
        QString estado = "ACTIVO";
        if (!q.value(7).isNull()) estado = "devuelto " + q.value(7).toString();
        QString texto = QString("%1 (%2) - %3 - retiró %4 - autorizó %5 - %6").arg(q.value(1).toString(), curso,
                                codigo, q.value(6).toString(), q.value(8).toString(), estado);
        agregarItem(ui->listPrestamos, texto, q.value(0).toInt());
        mostrados++;
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
        fallar("Préstamo de recurso", "prestamo_ct", "Elegí un recurso de la lista de disponibles.");
        return;
    }
    if (alumno == 0) {
        fallar("Préstamo de recurso", "prestamo_ct", "Elegí el alumno que retira el recurso.");
        return;
    }
    QString estado = valorUnico("SELECT e.nombre_estado FROM recursos_ct r JOIN estado_recurso e "
                                "ON e.id_estado_recurso = r.id_estado_recurso WHERE r.id_recurso = :id", recurso);
    if (estado != "Disponible") {
        fallar("Préstamo de recurso", "prestamo_ct", "Ese recurso no está disponible.");
        return;
    }
    QVariant valorObservaciones;
    if (!observaciones.isEmpty()) valorObservaciones = observaciones;
    db.transaction();
    QSqlQuery q;
    q.prepare("INSERT INTO prestamo_ct (fecha_prestamo, hora_prestamo, hora_devolucion, observaciones, id_usuario_solicitante, id_usuario_autorizador, id_recurso) "
              "VALUES (:fecha, :hora, NULL, :observaciones, :alumno, :autorizador, :recurso)");
    q.bindValue(":fecha", hoy());
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
        fallar("Préstamo de recurso", "prestamo_ct", "No se pudo registrar el préstamo.");
        return;
    }
    db.commit();
    registrarLog("Préstamo de recurso", QString("Recurso %1 prestado al alumno %2").arg(recurso).arg(alumno), "prestamo_ct", "Exitoso");
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
    db.transaction();
    q.prepare("UPDATE prestamo_ct SET hora_devolucion = :hora WHERE id_prestamo = :prestamo");
    q.bindValue(":hora", QTime::currentTime().toString("HH:mm"));
    q.bindValue(":prestamo", prestamo);
    bool ok = q.exec();
    if (!observaciones.isEmpty()) {
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
        fallar("Devolución de recurso", "prestamo_ct", "No se pudo registrar la devolución.");
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
    QSqlQuery q;
    q.prepare("SELECT r.hora_inicio, r.hora_fin, u.nombre_completo, e.nombre_estado FROM reserva_sector r "
              "JOIN usuario u ON u.id_usuario = r.id_usuario JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
              "WHERE r.id_sector = :sector AND r.fecha_reserva = :fecha AND r.id_estado_reserva IN (:pendiente, :aprobada) "
              "ORDER BY r.hora_inicio");
    q.bindValue(":sector", sector);
    q.bindValue(":fecha", ui->deSectoresDia->date().toString("yyyy-MM-dd"));
    q.bindValue(":pendiente", idEstado("estado_reserva", "Pendiente"));
    q.bindValue(":aprobada", idEstado("estado_reserva", "Aprobada"));
    q.exec();
    while (q.next()) {
        agregarItem(ui->listOcupacion, QString("%1 a %2 - %3 (%4)").arg(q.value(0).toString(), q.value(1).toString(),
                                                                        q.value(2).toString(), q.value(3).toString()), 0);
    }
    if (ui->listOcupacion->count() == 0) agregarItem(ui->listOcupacion, "Sin reservas ese día: el sector está libre.", 0);
}

void MainWindow::cargarReservasSector()
{
    ui->listSectores->clear();
    QString sql = "SELECT r.id_reserva, r.fecha_reserva, r.hora_inicio, r.hora_fin, s.nombre_sector, u.nombre_completo, "
                  "e.nombre_estado, r.id_usuario FROM reserva_sector r JOIN sector s ON s.id_sector = r.id_sector "
                  "JOIN usuario u ON u.id_usuario = r.id_usuario JOIN estado_reserva e ON e.id_estado_reserva = r.id_estado_reserva "
                  "WHERE r.fecha_reserva >= :hoy AND r.id_estado_reserva <> :cancelada ";
    bool propias = !rolEs("Preceptor");
    if (propias) sql += "AND r.id_usuario = :usuario ";
    sql += "ORDER BY r.fecha_reserva, r.hora_inicio";
    QSqlQuery q;
    q.prepare(sql);
    q.bindValue(":hoy", hoy());
    q.bindValue(":cancelada", idEstado("estado_reserva", "Cancelada"));
    if (propias) q.bindValue(":usuario", idActual);
    q.exec();
    while (q.next()) {
        QString dia = QDate::fromString(q.value(1).toString(), "yyyy-MM-dd").toString("dd/MM");
        QString texto = QString("%1 %2 a %3 - %4 - %5 - %6").arg(dia, q.value(2).toString(), q.value(3).toString(),
                                                                 q.value(4).toString(), q.value(5).toString(), q.value(6).toString());
        agregarItem(ui->listSectores, texto, q.value(0).toInt(), q.value(7).toInt());
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
        fallar("Reserva de sector", "reserva_sector", "La hora de fin tiene que ser posterior a la de inicio.");
        return;
    }
    QSqlQuery q;
    q.prepare("SELECT r.hora_inicio, r.hora_fin, u.nombre_completo FROM reserva_sector r JOIN usuario u ON u.id_usuario = r.id_usuario "
              "WHERE r.id_sector = :sector AND r.fecha_reserva = :fecha AND r.id_estado_reserva IN (:pendiente, :aprobada) "
              "AND r.hora_inicio < :fin AND r.hora_fin > :inicio");
    q.bindValue(":sector", sector);
    q.bindValue(":fecha", dia.toString("yyyy-MM-dd"));
    q.bindValue(":pendiente", idEstado("estado_reserva", "Pendiente"));
    q.bindValue(":aprobada", idEstado("estado_reserva", "Aprobada"));
    q.bindValue(":fin", fin);
    q.bindValue(":inicio", inicio);
    q.exec();
    if (q.next()) {
        fallar("Reserva de sector", "reserva_sector", QString("Ese horario ya está ocupado: %1 tiene el sector de %2 a %3.")
               .arg(q.value(2).toString(), q.value(0).toString(), q.value(1).toString()));
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
    q.bindValue(":fecha", dia.toString("yyyy-MM-dd"));
    q.bindValue(":inicio", inicio);
    q.bindValue(":fin", fin);
    q.bindValue(":usuario", idActual);
    q.bindValue(":sector", sector);
    q.bindValue(":estado", idEstado("estado_reserva", estado));
    q.bindValue(":autorizador", autorizador);
    if (!q.exec()) {
        fallar("Reserva de sector", "reserva_sector", "No se pudo guardar la reserva.");
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
    QSqlQuery q;
    q.prepare("UPDATE reserva_sector SET id_estado_reserva = :estado WHERE id_reserva = :reserva");
    q.bindValue(":estado", idEstado("estado_reserva", "Cancelada"));
    q.bindValue(":reserva", reserva);
    if (!q.exec()) {
        fallar("", "", "No se pudo cancelar la reserva.");
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
        fallar(evento, "reserva_sector", "Solo se pueden resolver las reservas pendientes.");
        return;
    }
    QSqlQuery q;
    q.prepare("UPDATE reserva_sector SET id_estado_reserva = :estado, id_usuario_autorizador = :autorizador WHERE id_reserva = :reserva");
    q.bindValue(":estado", idEstado("estado_reserva", estado));
    q.bindValue(":autorizador", idActual);
    q.bindValue(":reserva", reserva);
    if (!q.exec()) {
        fallar(evento, "reserva_sector", "No se pudo actualizar la reserva.");
        return;
    }
    registrarLog(evento, QString("Reserva %1: %2").arg(reserva).arg(estado), "reserva_sector", "Exitoso");
    cargarOcupacion();
    cargarReservasSector();
}

void MainWindow::on_btnSectoresAprobar_clicked() { resolverReservaSector("Aprobada", "Reserva de sector"); }
void MainWindow::on_btnSectoresRechazar_clicked() { resolverReservaSector("Rechazada", "Reserva de sector"); }

bool MainWindow::chocaHorario(int oferta, int curso, QString &materia)
{
    QSqlQuery q;
    q.prepare("SELECT MIN(m.nombre_materia) FROM oferta_deporte o JOIN franja_horaria f ON f.id_franja = o.id_franja "
              "JOIN horario_dia hd ON hd.id_dia = o.id_dia JOIN horario_escolar he ON he.id_bloque = hd.id_bloque "
              "JOIN materia m ON m.id_materia = he.id_materia "
              "WHERE o.id_oferta = :oferta AND he.id_curso = :curso AND he.hora_inicio < f.hora_fin AND he.hora_fin > f.hora_inicio");
    q.bindValue(":oferta", oferta);
    q.bindValue(":curso", curso);
    q.exec();
    q.next();
    materia = q.value(0).toString();
    return !q.value(0).isNull();
}

void MainWindow::cargarEdFisica()
{
    ui->listEdFisica->clear();
    int curso = valorUnico("SELECT COALESCE(id_curso, 0) FROM usuario WHERE id_usuario = :id", idActual).toInt();
    int miOferta = valorUnico("SELECT id_oferta FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt();
    QSqlQuery q;
    q.prepare("SELECT o.id_oferta, d.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin, o.cupo_maximo, "
              "(SELECT COUNT(*) FROM inscripcion_ed_fisica i WHERE i.id_oferta = o.id_oferta) FROM oferta_deporte o "
              "JOIN deporte d ON d.id_deporte = o.id_deporte JOIN dia_semana ds ON ds.id_dia = o.id_dia "
              "JOIN franja_horaria f ON f.id_franja = o.id_franja ORDER BY o.id_dia, f.hora_inicio, d.nombre_deporte");
    q.exec();
    while (q.next()) {
        int oferta = q.value(0).toInt();
        QString materia = "";
        bool choca = chocaHorario(oferta, curso, materia);
        QString texto = QString("%1 - %2 %3 a %4 - cupos %5/%6").arg(q.value(1).toString(), q.value(2).toString(),
                                q.value(3).toString(), q.value(4).toString()).arg(q.value(6).toInt()).arg(q.value(5).toInt());
        if (oferta == miOferta) texto += " - INSCRIPTO";
        if (q.value(6).toInt() >= q.value(5).toInt()) texto += " - SIN CUPO";
        if (choca) texto += " - se superpone con " + materia;
        agregarItem(ui->listEdFisica, texto, oferta);
        if (choca) ui->listEdFisica->item(ui->listEdFisica->count() - 1)->setFlags(Qt::NoItemFlags);
    }
    QSqlQuery m;
    m.prepare("SELECT d.nombre_deporte, ds.nombre_dia, f.hora_inicio, f.hora_fin FROM inscripcion_ed_fisica i "
              "JOIN oferta_deporte o ON o.id_oferta = i.id_oferta JOIN deporte d ON d.id_deporte = o.id_deporte "
              "JOIN dia_semana ds ON ds.id_dia = o.id_dia JOIN franja_horaria f ON f.id_franja = o.id_franja WHERE i.id_usuario = :usuario");
    m.bindValue(":usuario", idActual);
    m.exec();
    if (m.next()) {
        ui->lblEdFisicaMia->setText(QString("Tu inscripción: %1 - %2 %3 a %4").arg(m.value(0).toString(), m.value(1).toString(),
                                                                                  m.value(2).toString(), m.value(3).toString()));
    } else {
        ui->lblEdFisicaMia->setText("Todavía no te inscribiste a ninguna opción.");
    }
}

void MainWindow::on_btnEdFisicaInscribir_clicked()
{
    if (!exigir("Alumno", "Inscripción a Ed. Física", "inscripcion_ed_fisica")) return;
    int oferta = seleccionado(ui->listEdFisica);
    if (oferta == 0) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Elegí una opción de la lista.");
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
    QString materia = "";
    if (chocaHorario(oferta, curso, materia)) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "Esa opción se superpone con " + materia + " en tu horario.");
        return;
    }
    q.prepare("INSERT INTO inscripcion_ed_fisica (fecha_inscripcion, id_usuario, id_oferta) VALUES (:fecha, :usuario, :oferta)");
    q.bindValue(":fecha", hoy());
    q.bindValue(":usuario", idActual);
    q.bindValue(":oferta", oferta);
    if (!q.exec()) {
        fallar("Inscripción a Ed. Física", "inscripcion_ed_fisica", "No se pudo guardar la inscripción.");
        return;
    }
    registrarLog("Inscripción a Ed. Física", QString("Inscripción a la oferta %1").arg(oferta), "inscripcion_ed_fisica", "Exitoso");
    cargarEdFisica();
    info("Inscripción hecha.");
}

void MainWindow::on_btnEdFisicaCancelar_clicked()
{
    if (!exigir("Alumno", "", "")) return;
    if (valorUnico("SELECT COUNT(*) FROM inscripcion_ed_fisica WHERE id_usuario = :id", idActual).toInt() == 0) {
        fallar("", "", "No tenés ninguna inscripción para cancelar.");
        return;
    }
    QSqlQuery q;
    q.prepare("DELETE FROM inscripcion_ed_fisica WHERE id_usuario = :usuario");
    q.bindValue(":usuario", idActual);
    if (!q.exec()) {
        fallar("", "", "No se pudo cancelar la inscripción.");
        return;
    }
    cargarEdFisica();
    info("Inscripción cancelada.");
}
