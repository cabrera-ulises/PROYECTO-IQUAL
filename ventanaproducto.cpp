#include "ventanaproducto.h"
#include "ui_ventanaproducto.h"
#include <QPixmap>
#include <QCoreApplication>

VentanaProducto::VentanaProducto(QWidget *parent)
    : QDialog(parent)
    , ui(new Ui::VentanaProducto)
{
    ui->setupUi(this);
}

VentanaProducto::~VentanaProducto()
{
    delete ui;
}

void VentanaProducto::setProducto(const QString &nombre, const QString &categoria, int precio, int stock,
                                  const QString &vendedor, const QString &telefono, const QString &rutaFoto)
{
    ui->lblProductoNombre->setText(nombre);
    ui->lblProductoCategoria->setText("Categoría: " + categoria);
    ui->lblProductoPrecio->setText("$" + QString::number(precio));
    if (stock == 0) ui->lblProductoStock->setText("Sin stock");
    else ui->lblProductoStock->setText("Stock: " + QString::number(stock));
    ui->lblProductoVendedor->setText("Vende: " + vendedor + " (tel. " + telefono + ")");
    QPixmap foto(QCoreApplication::applicationDirPath() + "/imagenes_productos/" + rutaFoto);
    if (rutaFoto.isEmpty() || foto.isNull()) {
        ui->lblProductoFoto->setText("Sin foto");
        return;
    }
    ui->lblProductoFoto->setPixmap(foto.scaled(ui->lblProductoFoto->width() - 8, ui->lblProductoFoto->height() - 8, Qt::KeepAspectRatio, Qt::SmoothTransformation));
}

void VentanaProducto::on_btnProductoCerrar_clicked()
{
    accept();
}
