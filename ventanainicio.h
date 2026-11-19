#ifndef VENTANAINICIO_H
#define VENTANAINICIO_H

#include <QDialog>

class QLabel;
class QMovie;
class QTimer;
class QMouseEvent;

class VentanaInicio : public QDialog {
    Q_OBJECT

public:
    VentanaInicio(QWidget *parent = nullptr);
    ~VentanaInicio();

protected:
    void mousePressEvent(QMouseEvent *evento);

private:
    QLabel *lblAnimacion;
    QMovie *animacion;
    QTimer *reloj;
};

#endif
