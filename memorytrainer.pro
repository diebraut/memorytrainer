QT += core gui quick quickcontrols2 multimedia xml
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets
CONFIG += c++17

ios {
    QT += webview
    OBJECTIVE_SOURCES += ios_file_protection.mm
    HEADERS += ios_file_protection.h
} else:android {
        QT += webview

        # Basis-Pfad zu deinen OpenSSL-Libs
        OPENSSL_DIR = $$PWD/android_openssl/lib

        # ---- ABI-spezifische Bibliotheken wählen ----
        contains(ANDROID_TARGET_ARCH, arm64-v8a) {
            message("Using arm64-v8a OpenSSL libraries")
            ANDROID_EXTRA_LIBS += \
                $$OPENSSL_DIR/arm64-v8a/libssl_3.so \
                #$$OPENSSL_DIR/arm64-v8a/libcrypto.so \
                $$OPENSSL_DIR/arm64-v8a/libcrypto_3.so
        }

        contains(ANDROID_TARGET_ARCH, x86_64) {
            message("Using x86_64 OpenSSL libraries")
            ANDROID_EXTRA_LIBS += \
            $$OPENSSL_DIR/x86_64/libssl_3.so \
            #$$OPENSSL_DIR/x86_64/libcrypto.so \
            $$OPENSSL_DIR/x86_64/libcrypto_3.so
        }
        HEADERS += processaimagem.h \
                   provedorimagem.h
        SOURCES += processaimagem.cpp \
                   provedorimagem.cpp

} else {
    QT += webenginequick
    SOURCES += ios_file_protection_stub.cpp
    HEADERS += ios_file_protection.h
    #           processaimagem.h \
    #          provedorimagem.h
    #SOURCES += processaimagem.cpp \
    #          provedorimagem.cpp
}

HEADERS += \
    arrowdesc.h \
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
