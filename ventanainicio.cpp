#include "ventanainicio.h"
#include <QLabel>
#include <QMovie>
#include <QTimer>
#include <QSize>
#include <QMouseEvent>

VentanaInicio::VentanaInicio(QWidget *parent)
    : QDialog(parent)
{
    setWindowFlags(Qt::FramelessWindowHint | Qt::SplashScreen);
    setFixedSize(960, 540);

    lblAnimacion = new QLabel(this);
    lblAnimacion->setGeometry(0, 0, 960, 540);
    animacion = new QMovie(":/imagenes/splash_escritorio.gif", QByteArray(), this);
    animacion->setScaledSize(QSize(960, 540));
    lblAnimacion->setMovie(animacion);
    animacion->start();

    reloj = new QTimer(this);
    connect(reloj, &QTimer::timeout, this, &QDialog::accept);
    reloj->start(2600);
}

VentanaInicio::~VentanaInicio()
{
}

void VentanaInicio::mousePressEvent(QMouseEvent *)
{
    accept();
}
