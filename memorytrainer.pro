QT += gui core quick quickcontrols2  multimedia xml
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

ios {
    QT += webview
    CONFIG -= entrypoin
    #QMAKE_LFLAGS += -Wl,-e
    QMAKE_CXXFLAGS += -stdlib=libc++
    QMAKE_LFLAGS += -Wl,-e,_qt_main_wrapper
    CONFIG -= entrypoint

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
    ios_file_protection_stub.cpp \
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

RESOURCES += \
    images/images.qrc \
    qml.qrc

ios {
    QMAKE_IOS_DEPLOYMENT_TARGET = 17.5
    QMAKE_TARGET_BUNDLE_PREFIX = com.yourcompany
    TARGET = memorytrainer

    QMAKE_INFO_PLIST = Info.plist

    # Default rules for deployment.
    qnx: target.path = /tmp/$${TARGET}/bin
    else: unix:!android: target.path = /opt/$${TARGET}/bin
    !isEmpty(target.path): INSTALLS += target

    DISTFILES += \
        Info.plist
}
