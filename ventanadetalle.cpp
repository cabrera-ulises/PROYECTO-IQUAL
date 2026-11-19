#include "ventanadetalle.h"
#include "ui_ventanadetalle.h"
#include <QPixmap>
#include <QCoreApplication>

VentanaDetalle::VentanaDetalle(QWidget *parent)
    : QDialog(parent)
    , ui(new Ui::VentanaDetalle)
{
    ui->setupUi(this);
}

VentanaDetalle::~VentanaDetalle()
{
    delete ui;
}

void VentanaDetalle::setObjeto(const QString &titulo, const QString &descripcion, const QString &rutaFoto)
{
    ui->lblDetalleTitulo->setText(titulo);
    if (descripcion.isEmpty()) ui->lblDetalleDescripcion->setText("Sin descripción.");
    else ui->lblDetalleDescripcion->setText(descripcion);
    QPixmap foto(QCoreApplication::applicationDirPath() + "/imagenes_objetos/" + rutaFoto);
    if (rutaFoto.isEmpty() || foto.isNull()) {
        ui->lblDetalleFoto->setText("Este objeto no tiene foto.");
        return;
    }
    ui->lblDetalleFoto->setPixmap(foto.scaled(440, 280, Qt::KeepAspectRatio, Qt::SmoothTransformation));
}

void VentanaDetalle::on_btnDetalleCerrar_clicked()
{
    accept();
}


void VentanaDetalle::setReservado(const QString &detalle)
{
    if (detalle.isEmpty()) ui->lblDetalleReservado->setText("Ninguno cargado.");
    else ui->lblDetalleReservado->setText(detalle);
    ui->frmDetalleReservado->show();
}
