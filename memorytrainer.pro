QT += gui core quick quickcontrols2  multimedia xml webenginequick
greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

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

RESOURCES += \
    images/images.qrc \
    qml.qrc
