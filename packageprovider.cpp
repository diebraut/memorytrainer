#include "packageprovider.h"

#include <QDir>
#include <QDomDocument>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QTemporaryDir>
#include <QUuid>
#include <QtCore/private/qzipreader_p.h>

static PackageProvider *qml_instance = nullptr;

namespace {
bool isSafePackageName(const QString &name)
{
    const QString suffix = QFileInfo(name).suffix().toLower();
    return !name.isEmpty() && name.size() <= 200 && name != QStringLiteral(".")
            && name != QStringLiteral("..") && !name.contains('/')
            && !name.contains('\\') && !name.contains(QChar::Null)
            && (suffix == QStringLiteral("zip") || suffix == QStringLiteral("xml")
                || suffix == QStringLiteral("json"));
}

bool isSafePathPart(const QString &part)
{
    if (part.isEmpty() || part == QStringLiteral(".") || part == QStringLiteral("..")
            || part.endsWith('.') || part.endsWith(' '))
        return false;
    for (const QChar character : part) {
        if (character.unicode() < 32 || character.unicode() == 127
                || QStringLiteral("<>:\"/\\|?*").contains(character))
            return false;
    }
    return true;
}
}

void PackageProvider::registerSingleton(QQmlEngine *qmlEngine,QObject *parent)
{
    if (!qml_instance) {
        qml_instance = new PackageProvider(parent,qmlEngine);
    }
    QQmlContext *rootContext = qmlEngine->rootContext();
    rootContext->setContextProperty("packageProviderBackend", qml_instance);
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

QString PackageProvider::importDirectoryPath()
{
    return QDir(env.getWritableDirectionForOS() + QStringLiteral(DEFAULT_PACK_DIR))
            .filePath(QStringLiteral("Import"));
}

QVariantList PackageProvider::getDownloadedPackages()
{
    QVariantList packages;
    QDir directory(importDirectoryPath());
    const QFileInfoList files = directory.entryInfoList(
                QDir::Files | QDir::NoDotAndDotDot | QDir::NoSymLinks,
                QDir::Name | QDir::IgnoreCase);
    for (const QFileInfo &file : files) {
        if (!isSafePackageName(file.fileName()))
            continue;
        packages.append(QVariantMap{
            {QStringLiteral("name"), file.fileName()},
            {QStringLiteral("size"), file.size()},
            {QStringLiteral("modified"), file.lastModified().toString(Qt::ISODateWithMs)},
        });
    }
    return packages;
}

void PackageProvider::refreshAvailablePackages()
{
    if (availablePackagesReply) {
        availablePackagesReply->abort();
        availablePackagesReply = nullptr;
    }

    QNetworkRequest request(QUrl(QStringLiteral("https://roland-prinz.de/memorytrainer/api/available-packages/")));
    request.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("MemoryTrainer/1.0"));
    request.setTransferTimeout(15000);
    availablePackagesReply = networkManager.get(request);
    QNetworkReply *reply = availablePackagesReply;

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply != availablePackagesReply) {
            reply->deleteLater();
            return;
        }
        availablePackagesReply = nullptr;

        if (reply->error() != QNetworkReply::NoError) {
            emit availablePackagesError(reply->errorString());
            reply->deleteLater();
            return;
        }

        QJsonParseError parseError;
        const QJsonDocument document = QJsonDocument::fromJson(reply->readAll(), &parseError);
        reply->deleteLater();
        if (parseError.error != QJsonParseError::NoError || !document.isObject()
                || !document.object().value(QStringLiteral("files")).isArray()) {
            emit availablePackagesError(QStringLiteral("Die Paketliste des Servers ist ungültig."));
            return;
        }

        QVariantList packages;
        const QJsonArray files = document.object().value(QStringLiteral("files")).toArray();
        for (const QJsonValue &value : files) {
            const QJsonObject file = value.toObject();
            const QString name = file.value(QStringLiteral("name")).toString();
            const QFileInfo localFile(QDir(importDirectoryPath()).filePath(name));
            if (!isSafePackageName(name)
                    || (localFile.isFile() && !localFile.isSymLink()))
                continue;
            packages.append(QVariantMap{
                {QStringLiteral("name"), name},
                {QStringLiteral("size"), file.value(QStringLiteral("size")).toDouble()},
                {QStringLiteral("modified"), file.value(QStringLiteral("modified")).toString()},
            });
        }
        emit availablePackagesLoaded(packages);
    });
}

void PackageProvider::downloadPackage(const QString &packageName)
{
    if (downloadReply) {
        emit downloadError(packageName, QStringLiteral("Es läuft bereits ein Download."));
        return;
    }
    if (!isSafePackageName(packageName)) {
        emit downloadError(packageName, QStringLiteral("Ungültiger Paketname."));
        return;
    }

    const QString directoryPath = importDirectoryPath();
    if (!QDir().mkpath(directoryPath)) {
        emit downloadError(packageName, QStringLiteral("Der Import-Ordner konnte nicht angelegt werden."));
        return;
    }
    const QString targetPath = QDir(directoryPath).filePath(packageName);
    if (QFileInfo::exists(targetPath)) {
        emit downloadError(packageName, QStringLiteral("Das Paket ist bereits heruntergeladen."));
        return;
    }

    downloadFile = std::make_unique<QSaveFile>(targetPath);
    if (!downloadFile->open(QIODevice::WriteOnly)) {
        const QString error = downloadFile->errorString();
        downloadFile.reset();
        emit downloadError(packageName, error);
        return;
    }

    downloadWriteError.clear();
    const QString encodedName = QString::fromLatin1(QUrl::toPercentEncoding(packageName));
    QNetworkRequest request(QUrl(QStringLiteral("https://roland-prinz.de/memorytrainer/api/available-packages/")
                                + encodedName + QStringLiteral("/download/")));
    request.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("MemoryTrainer/1.0"));
    request.setTransferTimeout(30000);
    downloadReply = networkManager.get(request);
    QNetworkReply *reply = downloadReply;
    emit downloadStarted(packageName);

    auto writeAvailableData = [this, reply]() {
        const QByteArray chunk = reply->readAll();
        if (!chunk.isEmpty() && downloadFile
                && downloadFile->write(chunk) != chunk.size()) {
            downloadWriteError = downloadFile->errorString();
            reply->abort();
        }
    };
    connect(reply, &QIODevice::readyRead, this, writeAvailableData);
    connect(reply, &QNetworkReply::downloadProgress, this,
            [this, packageName](qint64 received, qint64 total) {
        emit downloadProgress(packageName, received, total);
    });
    connect(reply, &QNetworkReply::finished, this,
            [this, reply, packageName, targetPath, writeAvailableData]() {
        writeAvailableData();
        downloadReply = nullptr;
        const int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const bool isAttachment = reply->rawHeader("Content-Disposition")
                                      .startsWith("attachment;");
        QString error;
        if (!downloadWriteError.isEmpty())
            error = downloadWriteError;
        else if (reply->error() != QNetworkReply::NoError)
            error = reply->errorString();
        else if (status != 200 || !isAttachment)
            error = QStringLiteral("Der Server hat keine Paketdatei geliefert.");
        else if (QFileInfo::exists(targetPath))
            error = QStringLiteral("Das Paket ist bereits heruntergeladen.");
        else if (!downloadFile->commit())
            error = downloadFile->errorString();

        if (!error.isEmpty()) {
            if (downloadFile)
                downloadFile->cancelWriting();
            emit downloadError(packageName, error);
        } else {
            emit downloadFinished(packageName);
        }
        downloadFile.reset();
        reply->deleteLater();
    });
}

void PackageProvider::installDownloadedPackage(const QString &packageName, bool overwrite)
{
    auto fail = [this, &packageName](const QString &message) {
        emit installationError(packageName, message);
    };
    if (!isSafePackageName(packageName)
            || QFileInfo(packageName).suffix().compare(QStringLiteral("zip"), Qt::CaseInsensitive) != 0) {
        fail(QStringLiteral("Nur heruntergeladene ZIP-Pakete können installiert werden."));
        return;
    }

    const QString packageFolder = QFileInfo(packageName).completeBaseName();
    if (!isSafePathPart(packageFolder) || packageFolder.startsWith('.')
            || packageFolder.startsWith(QStringLiteral("__"))
            || packageFolder.compare(QStringLiteral("Import"), Qt::CaseInsensitive) == 0) {
        fail(QStringLiteral("Der Paketname ist als Installationsordner nicht zulässig."));
        return;
    }

    const QFileInfo archive(QDir(importDirectoryPath()).filePath(packageName));
    if (!archive.isFile() || archive.isSymLink()) {
        fail(QStringLiteral("Die heruntergeladene Paketdatei wurde nicht gefunden."));
        return;
    }

    const QString basePath = env.getWritableDirectionForOS() + QStringLiteral(DEFAULT_PACK_DIR);
    if (!QDir().mkpath(basePath)) {
        fail(QStringLiteral("Der Ordner excercisedata konnte nicht angelegt werden."));
        return;
    }
    const QString targetPath = QDir(basePath).filePath(packageFolder);
    const QFileInfo targetInfo(targetPath);
    const bool targetExists = targetInfo.exists() || targetInfo.isSymLink();
    if (targetExists) {
        if (!targetInfo.isDir() || targetInfo.isSymLink()) {
            fail(QStringLiteral("Am Installationsort liegt bereits eine Datei oder Verknüpfung."));
            return;
        }
        if (!overwrite) {
            emit installationNeedsOverwrite(packageName, packageFolder);
            return;
        }
    }

    QZipReader zip(archive.filePath());
    if (!zip.exists() || !zip.isReadable() || zip.status() != QZipReader::NoError) {
        fail(QStringLiteral("Das ZIP-Paket kann nicht geöffnet werden."));
        return;
    }
    const QList<QZipReader::FileInfo> entries = zip.fileInfoList();
    if (entries.isEmpty() || entries.size() > 10000) {
        fail(QStringLiteral("Das ZIP-Paket ist leer oder enthält zu viele Dateien."));
        return;
    }

    QTemporaryDir staging(QDir(basePath).filePath(QStringLiteral(".memorytrainer-install-XXXXXX")));
    if (!staging.isValid()) {
        fail(QStringLiteral("Der temporäre Installationsordner konnte nicht angelegt werden."));
        return;
    }
    const QString stagedPackagePath = QDir(staging.path()).filePath(packageFolder);
    qint64 totalSize = 0;
    for (const QZipReader::FileInfo &entry : entries) {
        QString entryPath = entry.filePath;
        if (entryPath.endsWith('/'))
            entryPath.chop(1);
        const QStringList parts = entryPath.split('/');
        if (entry.isSymLink || (!entry.isDir && !entry.isFile)
                || parts.isEmpty() || parts.first() != packageFolder) {
            fail(QStringLiteral("Das ZIP-Paket enthält einen ungültigen Pfad."));
            return;
        }
        for (const QString &part : parts) {
            if (!isSafePathPart(part)) {
                fail(QStringLiteral("Das ZIP-Paket enthält einen unsicheren Dateinamen."));
                return;
            }
        }

        const QString relativePath = parts.join('/');
        const QString outputPath = QDir(staging.path()).filePath(relativePath);
        if (entry.isDir) {
            if (!QDir().mkpath(outputPath)) {
                fail(QStringLiteral("Ein Paketordner konnte nicht angelegt werden."));
                return;
            }
            continue;
        }
        if (parts.size() < 2 || entry.size < 0 || entry.size > 64 * 1024 * 1024
                || totalSize > 512 * 1024 * 1024 - entry.size) {
            fail(QStringLiteral("Das ZIP-Paket enthält eine zu große oder ungültige Datei."));
            return;
        }
        totalSize += entry.size;
        if (!QDir().mkpath(QFileInfo(outputPath).absolutePath())) {
            fail(QStringLiteral("Ein Paketordner konnte nicht angelegt werden."));
            return;
        }
        QByteArray data = zip.fileData(entry.filePath);
        if (data.size() != entry.size) {
            // QZipReader decodes UTF-8 names in fileInfoList(), but fileData()
            // compares the raw ZIP name using fromLocal8Bit() on Windows.
            const QString localLookupName = QString::fromLocal8Bit(entry.filePath.toUtf8());
            if (localLookupName != entry.filePath)
                data = zip.fileData(localLookupName);
        }
        if (zip.status() != QZipReader::NoError || data.size() != entry.size) {
            fail(QStringLiteral("Die Datei %1 konnte nicht entpackt werden.").arg(entry.filePath));
            return;
        }
        QSaveFile output(outputPath);
        if (!output.open(QIODevice::WriteOnly) || output.write(data) != data.size()
                || !output.commit()) {
            fail(QStringLiteral("Eine entpackte Paketdatei konnte nicht gespeichert werden."));
            return;
        }
    }
    zip.close();

    QFile description(QDir(stagedPackagePath).filePath(QStringLiteral("package.xml")));
    QDomDocument document;
    if (!description.open(QIODevice::ReadOnly) || !document.setContent(&description)
            || document.documentElement().isNull()) {
        fail(QStringLiteral("Das Paket enthält keine gültige package.xml."));
        return;
    }
    description.close();

    if (!targetExists) {
        const QFileInfo currentTarget(targetPath);
        if (currentTarget.exists() || currentTarget.isSymLink()) {
            emit installationNeedsOverwrite(packageName, packageFolder);
            return;
        }
    }

    QString backupPath;
    if (targetExists) {
        backupPath = QDir(basePath).filePath(QStringLiteral(".memorytrainer-backup-")
                + QUuid::createUuid().toString(QUuid::WithoutBraces));
        if (!QDir().rename(targetPath, backupPath)) {
            fail(QStringLiteral("Das bestehende Paket konnte nicht gesichert werden."));
            return;
        }
    }
    if (!QDir().rename(stagedPackagePath, targetPath)) {
        if (!backupPath.isEmpty() && !QDir().rename(backupPath, targetPath))
            fail(QStringLiteral("Installation fehlgeschlagen. Das bisherige Paket liegt unter %1.").arg(backupPath));
        else
            fail(QStringLiteral("Das entpackte Paket konnte nicht installiert werden."));
        return;
    }
    if (!backupPath.isEmpty() && !QDir(backupPath).removeRecursively()) {
        emit installationFinished(packageName, packageFolder);
        emit installationWarning(QStringLiteral("Die Sicherung unter %1 konnte nicht gelöscht werden.").arg(backupPath));
        return;
    }
    emit installationFinished(packageName, packageFolder);
}
