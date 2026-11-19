#include "mainwindow.h"
#include "ventanainicio.h"
#include <QApplication>

int main(int argc, char *argv[]) {
    QApplication a(argc, argv);
    VentanaInicio inicio;
    inicio.show();
    a.processEvents();
    MainWindow w;
    inicio.exec();
    w.show();
    return a.exec();
}
