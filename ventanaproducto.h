#ifndef VENTANAPRODUCTO_H
#define VENTANAPRODUCTO_H

#include <QDialog>
#include <QString>

namespace Ui { class VentanaProducto; }

class VentanaProducto : public QDialog {
    Q_OBJECT

public:
    VentanaProducto(QWidget *parent = nullptr);
    ~VentanaProducto();
    void setProducto(const QString &nombre, const QString &categoria, int precio, int stock,
                     const QString &vendedor, const QString &telefono, const QString &rutaFoto);

private slots:
    void on_btnProductoCerrar_clicked();

private:
    Ui::VentanaProducto *ui;
};

#endif
