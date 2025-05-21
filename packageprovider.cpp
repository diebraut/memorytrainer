#include "packageprovider.h"

static PackageProvider *qml_instance = nullptr;

void PackageProvider::registerSingleton(QQmlEngine *qmlEngine,QObject *parent)
{
    if (!qml_instance) {
        qml_instance = new PackageProvider(parent,qmlEngine);
    }
    QQmlContext *rootContext = qmlEngine->rootContext();
    rootContext->setContextProperty("PackageProvider", qml_instance);
}

PackageProvider::PackageProvider(QObject *parent,QQmlEngine *qmlEngine) :
    QObject(parent)
{
    this->qmlEngine  = qmlEngine;

}


QDomDocument *PackageProvider::extractPackage (QString fileName) {
    return nullptr;
}

QDomDocument *PackageProvider::createPackage  (QString fromLocation) {
    return nullptr;
}

bool PackageProvider::installPackage(QString packageName, QJSValue  jsCallback) {
    return true;
}

QStringList PackageProvider::getInstallablePackages() {
    QStringList l;
    return l;
}
