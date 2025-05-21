/*** PackageProvider
 *
 * Extrahiert/Erzeugt Übungspakete
 *
 **/

#ifndef PACKAGEPROVIDER_H
#define PACKAGEPROVIDER_H

#include "environment.h"
#include "exercizeinfo.h"

#include <QObject>
#include <QString>
#include <QList>
//#include <QtXml>

#include <QQmlEngine>

class PackageProvider : public QObject
{
    Q_OBJECT

public:
    static void registerSingleton(QQmlEngine *qmlEngine,QObject *parent=nullptr);

    QDomDocument *extractPackage (QString fileName);
    QDomDocument *createPackage  (QString fromLocation);

    Q_INVOKABLE bool        installPackage(QString packageName, QJSValue  jsCallback);
    Q_INVOKABLE QStringList getInstallablePackages();

private:
    explicit   PackageProvider(QObject *parent = nullptr, QQmlEngine *qmlEngine=nullptr);
    QString buildDirectoryStruct (bool &directoryExist);

private:
    ExercizeInfo exercizeInfo;
    Environment env;
    QQmlEngine * qmlEngine=nullptr;
    QDomDocument *xmlBOM = nullptr;

};

#endif // PACKAGEPROVIDER_H
