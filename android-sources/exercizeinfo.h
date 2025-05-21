#ifndef EXERCIZEINFO_H
#define EXERCIZEINFO_H

#include <QString>
#include <QtXml>
#include <QQmlContext>


class ExercizeInfo
{
public:
    ExercizeInfo();
    bool openExercize(QString exercizeName);
    void closeExercize();
    QString     getMainCategory();
    QStringList getSubCategories();

private:
    QDomDocument *xmlBOM = nullptr;
    QString lastErrTxt;
};

#endif // EXERCIZEINFO_H
