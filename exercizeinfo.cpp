#include "exercizeinfo.h"
#include <QFile>

ExercizeInfo::ExercizeInfo()
{
}

bool ExercizeInfo::openExercize(QString fileName)
{
    lastErrTxt = "";
    QFile file(fileName);
    if (file.open(QIODevice::ReadOnly)) {
        xmlBOM = new QDomDocument();
        xmlBOM->setContent(&file);
    } else {
       lastErrTxt += "Error loading xml file: " +  file.errorString();
       return false;
    }
    file.close();
    return true;
}

void ExercizeInfo::closeExercize()
{
    lastErrTxt = "";
    delete xmlBOM;
    xmlBOM = nullptr;
}

QString ExercizeInfo::getMainCategory() {
    QDomNode categoryNode = this->xmlBOM->documentElement().namedItem("category").namedItem("path");
    return categoryNode.toElement().text();
}

QStringList ExercizeInfo::getSubCategories() {
    QStringList retList;
    for (int i=0; i < 10; i++) { //max 10 subcategories
        QString nodeName = "subcategory_";
        nodeName += QString::number(i);
        QDomNode node = this->xmlBOM->documentElement().namedItem(nodeName);
        if (!node.isNull()) {
            node = node.namedItem("path");
            if (!node.isNull()) {
                retList.append(node.toElement().text());
            }
        }
        else {
            break;
        }
    }
    return retList;
}
