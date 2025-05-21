#include "environment.h"

#include <QStandardPaths>
#include <QCoreApplication>
#include <QQuickStyle>

Environment::Environment()
{

}


QString Environment::getWritableDirectionForOS() {

    if (QSysInfo::productType() == "android") {
        return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    }
    else if (QSysInfo::productType() == "ios" || QSysInfo::productType() == "osx") {
         return QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation)[0];
    }
    else if (QSysInfo::productType() == "windows") {
       return "K:/QT-Projekte/memorytrainer";  //only indevelopment
    }
    return QCoreApplication::applicationDirPath();
}

void Environment::setStyleForOS() {

    QString styleName  = "Fusion";
    if (QSysInfo::productType() == "android") {
        styleName = "Material";
    }
    else if (QSysInfo::productType() == "windows") {
        styleName = "Universal";
    }
    QQuickStyle::setStyle(styleName);
    return;
}
