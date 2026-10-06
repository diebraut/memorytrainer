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
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSaveFile>
#include <QVariantList>
#include <memory>
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
    Q_INVOKABLE void refreshAvailablePackages();
    Q_INVOKABLE QVariantList getDownloadedPackages();
    Q_INVOKABLE void downloadPackage(const QString &packageName);
    Q_INVOKABLE void installDownloadedPackage(const QString &packageName, bool overwrite = false);

signals:
    void availablePackagesLoaded(const QVariantList &packages);
    void availablePackagesError(const QString &message);
    void downloadStarted(const QString &packageName);
    void downloadProgress(const QString &packageName, qint64 received, qint64 total);
    void downloadFinished(const QString &packageName);
    void downloadError(const QString &packageName, const QString &message);
    void installationNeedsOverwrite(const QString &packageName, const QString &installedName);
    void installationFinished(const QString &packageName, const QString &installedName);
    void installationError(const QString &packageName, const QString &message);
    void installationWarning(const QString &message);

private:
    explicit   PackageProvider(QObject *parent = nullptr, QQmlEngine *qmlEngine=nullptr);
    QString buildDirectoryStruct (bool &directoryExist);
    QString importDirectoryPath();

private:
    ExercizeInfo exercizeInfo;
    Environment env;
    QQmlEngine * qmlEngine=nullptr;
    QDomDocument *xmlBOM = nullptr;
    QNetworkAccessManager networkManager;
    QNetworkReply *availablePackagesReply = nullptr;
    QNetworkReply *downloadReply = nullptr;
    std::unique_ptr<QSaveFile> downloadFile;
    QString downloadWriteError;

};

#endif // PACKAGEPROVIDER_H
