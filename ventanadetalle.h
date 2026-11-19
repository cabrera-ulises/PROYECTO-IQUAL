#ifndef VENTANADETALLE_H
#define VENTANADETALLE_H

#include <QDialog>
#include <QString>

namespace Ui { class VentanaDetalle; }

class VentanaDetalle : public QDialog {
    Q_OBJECT

public:
    VentanaDetalle(QWidget *parent = nullptr);
    ~VentanaDetalle();
    void setObjeto(const QString &titulo, const QString &descripcion, const QString &rutaFoto);
    void setReservado(const QString &detalle);

private slots:
    void on_btnDetalleCerrar_clicked();

private:
    Ui::VentanaDetalle *ui;
};

#endif
