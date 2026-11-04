#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSqlDatabase>
#include <QString>
#include <QStringList>
#include <QDate>
#include <QList>
#include <QWidget>

class QMenu;
class QComboBox;
class QPushButton;
class QListWidget;

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

enum Pagina {
    PAG_LANDING,
    PAG_ACCESO,
    PAG_DASHBOARD,
    PAG_OBJETOS,
    PAG_HIGIENE,
    PAG_BUFFET,
    PAG_PLANILLAS,
    PAG_SECTORES,
    PAG_EDFISICA,
    PAG_CUENTA
};

class MainWindow : public QMainWindow {
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_btnLandingLogin_clicked();
    void on_btnLandingRegister_clicked();
    void on_btnLoginIngresar_clicked();
    void on_btnRegistrar_clicked();
    void on_leUsuario_returnPressed();
    void on_leClave_returnPressed();
    void on_leRegContacto_returnPressed();
    void on_cbRegRol_currentIndexChanged(int indice);
    void on_cbRegAnio_currentIndexChanged(int indice);
    void on_cbRegDivision_currentIndexChanged(int indice);
    void on_cbRegEspecialidad_currentIndexChanged(int indice);
    void on_btnMenuObjetos_clicked();
    void on_btnMenuHigiene_clicked();
    void on_btnMenuBuffet_clicked();
    void on_btnMenuPlanillas_clicked();
    void on_btnMenuSectores_clicked();
    void on_btnMenuEdFisica_clicked();
    void on_btnObjReclamar_clicked();
    void on_btnReclamoAprobar_clicked();
    void on_btnReclamoRechazar_clicked();
    void on_btnObjArchivar_clicked();
    void on_btnObjFoto_clicked();
    void on_btnObjPublicar_clicked();
    void on_btnConsultaPublicar_clicked();
    void on_btnConsultaBorrar_clicked();
    void on_leConsultaDesc_returnPressed();
    void on_btnHigieneReportar_clicked();
    void on_btnHigieneResolver_clicked();
    void on_leHigieneObs_returnPressed();
    void on_cbHigieneSector_currentIndexChanged(int indice);
    void on_cbBuffetVista_currentIndexChanged(int indice);
    void on_btnBuffetReservar_clicked();
    void on_btnBuffetCancelar_clicked();
    void on_btnBuffetDonar_clicked();
    void on_btnBuffetUnirse_clicked();
    void on_leBuffetMonto_returnPressed();
    void on_btnProdPublicar_clicked();
    void on_btnGrupoCrear_clicked();
    void on_btnPlanillasPrestar_clicked();
    void on_btnPlanillasDevolver_clicked();
    void on_leFiltroPlanillas_textChanged(const QString &texto);
    void on_leFiltroPlanillas_returnPressed();
    void on_btnSectoresReservar_clicked();
    void on_btnSectoresCancelar_clicked();
    void on_btnSectoresAprobar_clicked();
    void on_btnSectoresRechazar_clicked();
    void on_cbSectoresLugar_currentIndexChanged(int indice);
    void on_deSectoresDia_dateChanged(const QDate &fecha);
    void on_btnEdFisicaInscribir_clicked();
    void on_btnEdFisicaCancelar_clicked();
    void on_btnCuentaGuardar_clicked();
    void mostrarMenu();
    void irAlInicio();
    void irAlMenu();
    void irACuenta();
    void cerrarSesion();

private:
    Ui::MainWindow *ui;
    QMenu *menuUsuario;
    QSqlDatabase db;
    int idActual;
    QString fotoElegida;

    bool abrirBase();
    void cargarCatalogos();
    void cargarTodo();
    void aplicarPermisos();
    void ponerIcono(QPushButton *boton, const QString &archivo);

    int idPorNombre(const QString &tabla, const QString &columnaId, const QString &columnaNombre, const QString &valor);
    int idEstado(const QString &tabla, const QString &nombre);
    QString valorUnico(const QString &sql, int id);
    bool existe(const QString &tabla, const QString &columna, const QString &valor);
    QString rolActual();
    bool rolEs(const QString &lista);
    bool exigir(const QString &roles, const QString &evento, const QString &entidad);
    void aviso(const QString &texto);
    void info(const QString &texto);
    void fallar(const QString &evento, const QString &entidad, const QString &mensaje);
    void registrarLog(const QString &evento, const QString &descripcion, const QString &entidad, const QString &resultado);
    QString hashClave(const QString &clave);
    QString ahora();
    QString hoy();
    QString formatoCorto(const QString &fechaHora);
    bool soloDigitos(const QString &texto, int minimo, int maximo);
    void habilitar(bool si, QList<QWidget *> widgets);

    void cargarCombo(QComboBox *combo, const QString &sql, const QString &inicial, const QString &sufijo);
    void cargarCursoCombos(QComboBox *anio, QComboBox *division, QComboBox *especialidad);
    void agregarItem(QListWidget *lista, const QString &texto, int id, int extra = 0);
    int seleccionado(QListWidget *lista, int rol = Qt::UserRole);
    int obtenerCurso(QComboBox *anio, QComboBox *division, QComboBox *especialidad);
    QString textoCurso(int idCurso);
    QString codigoRecurso(const QString &carro, int numero);

    void actualizarRegistro();
    void limpiarRegistro();
    void cargarCuenta();
    void cargarObjetos();
    void cargarReclamos();
    void cargarConsultas();
    void resolverReclamo(const QString &estadoReclamo, const QString &estadoObjeto, const QString &evento);
    void cargarHigiene();
    void actualizarUltimoMantenimiento();
    void cargarGrupos();
    void cargarBuffet();
    void cargarMisReservas();
    int recaudado(int grupo);
    void cargarPlanillas();
    void cargarPrestamos();
    void cargarOcupacion();
    void cargarReservasSector();
    void resolverReservaSector(const QString &estado, const QString &evento);
    void cargarEdFisica();
    bool chocaHorario(int oferta, int curso, QString &materia);
};

#endif