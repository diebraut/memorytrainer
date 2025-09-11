QT += core gui quick quickcontrols2 multimedia xml
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
CONFIG += c++17

ios {
    QT += webview
    OBJECTIVE_SOURCES += ios_file_protection.mm
    HEADERS += ios_file_protection.h
} else {
    QT += webenginequick
    SOURCES += ios_file_protection_stub.cpp
}

HEADERS += \
    licenceinfo.h \
    exerciceentrymanager.h \
    learnlistentrymanager.h \
    excludeaerea.h \
    entrydesc.h \
    entryhandler.h \
    environment.h \
    exercizeinfo.h \
    networkchecker.h \
    packagedesc.h \
    packagemanager.h \
    packageprovider.h \
    processaimagem.h \
    provedorimagem.h \
    xmlaccess.h \
    xmlparser.h

SOURCES += \
    exerciceentrymanager.cpp \
    learnlistentrymanager.cpp \
    entryhandler.cpp \
    environment.cpp \
    exercizeinfo.cpp \
    main.cpp \
    networkchecker.cpp \
    packagedesc.cpp \
    packagemanager.cpp \
    packageprovider.cpp \
    processaimagem.cpp \
    provedorimagem.cpp \
    xmlaccess.cpp \
    xmlparser.cpp

RESOURCES += images/images.qrc qml.qrc

ios {
    QMAKE_IOS_DEPLOYMENT_TARGET = 17.5
    QMAKE_TARGET_BUNDLE_PREFIX = com.yourcompany   
    TARGET = memorytrainer
    # Asset Catalog(s) einbinden
    QMAKE_ASSET_CATALOGS += $$PWD/ios/Assets.xcassets

    # Name des Icon-Sets (Verzeichnisname ohne .appiconset)
    QMAKE_ASSET_CATALOGS_APP_ICON = AppIcon

    # Optional: eigene Info.plist (wenn du zusätzliche Keys brauchst)
    # QMAKE_INFO_PLIST = $$PWD/ios/Info.plist
    QMAKE_INFO_PLIST = Info.plist
}
