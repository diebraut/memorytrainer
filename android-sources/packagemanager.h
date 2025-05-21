#ifndef PACKAGEMANAGER_H
#define PACKAGEMANAGER_H

#include "environment.h"


#include <QObject>
#include <QQmlEngine>


class PackageManager : public QObject
{
    Q_OBJECT

public:
    static void registerSingleton(QQmlEngine *qmlEngine,QObject *parent=nullptr);

    Q_INVOKABLE bool createMixPackage(QString packageName,int cntExercise,QVariantList fromPackageList, QJSValue  jsReturnInfoVal);
    Q_INVOKABLE bool removePackage(QString packageName,QJSValue  jsReturnInfoVal);

private:
    explicit   PackageManager(QObject *parent = nullptr, QQmlEngine *qmlEngine=nullptr);
    bool existPackDir(QString packDir);
    bool createPackDir(QString packDir);
    QVariantList cutAndRandomize(int cntExercise,QVariantList fromPackageList);
    bool putEntriesToMixPackage(int cntEntries,QString package,QString mixPackage);
    //QString buildDirectoryStruct (bool &directoryExist);
    void sorting(int **arr,int n, bool firstCol);
    static bool compareAsc1Col(int *a, int *b);
    static bool compareDesc2Col(int *a, int *b);

    std::vector<std::pair<int,bool>> buildExersizesPerPackageVector(QVariantList *fromPackageList,int exercizes);

    int getPerPackageEntries(int allEntriesLessThanExPerPackTotal,int allEntriesGreaterThanExPerPack,int *remainRemainExersizePerPack);

private:
    Environment env;
    QQmlEngine * qmlEngine=nullptr;

};


#endif // PACKAGEMANAGER_H
