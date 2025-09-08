#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QQuickStyle>
#include <QIcon>

#include <QQuickView>
#include "entryhandler.h"

#include <QList>
#include <QDebug>



#include "processaimagem.h"
#include "provedorimagem.h"
#include "environment.h"

#include "learnlistentrymanager.h"

#include "packageprovider.h"
#include "packagemanager.h"
#include "packagedesc.h"
#include "entrydesc.h"

#include <QXmlStreamWriter>
#include <QXmlStreamReader>
#include <QFile>
#include <QtXml>

#include "networkchecker.h"

#ifdef Q_OS_IOS
#include <QtWebView>
#include "ios_file_protection.h"    // <- unsere Helper-API
#else
#include <QQuickView>
#include <QtWebEngineQuick>
#endif

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
    QGuiApplication::setApplicationName("Memory Trainerxx");
    QGuiApplication::setOrganizationName("QtProject");

    Environment::setStyleForOS();


    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    qmlRegisterType<processaImagem>("ProcessaImagemQml", 1, 0, "ProcessaImagem");

    QGuiApplication app(argc, argv);
#ifdef Q_OS_IOS
    QtWebView::initialize(); // ✅
#else
    QtWebEngineQuick::initialize(); // ✅
#endif
    Environment env;

    // create neccessary directories
    const QString base = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR;
    const QString dirLearn  = base + "/" + DEFAULT_LEARNLIST_DIR;
    const QString dirCustom = base + "/" + DEFAULT_MIXED_PACKAGE_DIR;

    QDir().mkpath(dirLearn);
    QDir().mkpath(dirCustom);

#ifdef Q_OS_IOS
    // optional auch einen Import-Ordner anlegen
    QDir().mkpath(base + "/Import");
    iosSetNoProtectionTree(base);      // jetzt rekursiv Attribute setzen
#endif

    // Singleton-Instanz von ExerciceEntryManager
    LearnListEntryManager *learnListEntryManager = new LearnListEntryManager();

    // Registriere die Singleton-Instanz in QML
    qmlRegisterSingletonInstance<LearnListEntryManager>("com.memorytrainer.LearnListEntryManager", 1, 0, "LearnListEntryManager", learnListEntryManager);
    qmlRegisterType<EntryHandler>("com.memoryhandler.EntryHandler", 1, 0, "EntryHandler");
    qmlRegisterType<EntryHandler>("com.memoryhandler.PackageDesc", 1, 0, "PackageDesc");
    qmlRegisterType<EntryHandler>("com.memoryhandler.EntryDesc", 1, 0, "EntryDesc");
    qmlRegisterType<EntryHandler>("com.memoryhandler.ExcludeAerea", 1, 0, "ExcludeAerea");
    // Registrierung der Klasse für QML
    qmlRegisterType<LicenceInfo>("com.memoryhandler.LicenceInfo", 1, 0, "LicenceInfo");

    // Register the NetworkChecker class with QML
    qmlRegisterType<NetworkChecker>("com.memorytrainer.network", 1, 0, "NetworkChecker");

    qRegisterMetaType<PackageDesc>("PackageDesc");
    qRegisterMetaType<EntryDesc>("EntryDesc");
    qRegisterMetaType<LicenceInfo>("LicenceInfo");
    qRegisterMetaType<EntryDesc>("ExcludeAerea");

    QIcon::setThemeName("gallery");

    QSettings settings;
    QString style = QQuickStyle::name();
    if (!style.isEmpty())
        settings.setValue("style", style);
    else
        QQuickStyle::setStyle(settings.value("style").toString());


    QQmlApplicationEngine engine;

    provedorImagem *provedorImg = new provedorImagem;
    engine.rootContext()->setContextProperty("ProvedorImagem", provedorImg);
    engine.addImageProvider("provedor", provedorImg);

    EntryHandler::registerSingleton(&engine);
    PackageProvider::registerSingleton(&engine);
    PackageManager::registerSingleton(&engine);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    //engine.load(QUrl(QStringLiteral("qrc:/TestWeb.qml")));

    // Fix: use a reference to rootObjects()
    const QObjectList &rootObjects = engine.rootObjects();
    if (!rootObjects.isEmpty()) {
        // Access the root object (the ApplicationWindow)
        QObject *rootObject = rootObjects.first();

        // Expose the root object to all QML files
        engine.rootContext()->setContextProperty("appId", rootObject);
    }

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}

