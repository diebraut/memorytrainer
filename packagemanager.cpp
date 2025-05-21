#include "packagemanager.h"
#include "xmlparser.h"

#include <QQmlContext>

#include <QDir>
#include <random>

static PackageManager *qml_instance = nullptr;

void PackageManager::registerSingleton(QQmlEngine *qmlEngine,QObject *parent)
{
    if (!qml_instance) {
        qml_instance = new PackageManager(parent,qmlEngine);
    }
    QQmlContext *rootContext = qmlEngine->rootContext();
    rootContext->setContextProperty("PackageManager", qml_instance);
}

PackageManager::PackageManager(QObject *parent,QQmlEngine *qmlEngine) :
    QObject(parent)
{
    this->qmlEngine  = qmlEngine;

}

bool PackageManager::removePackage(QString packageName,bool isCustomPackage,QJSValue  jsReturnInfoVal) {
    if (isCustomPackage) {
        QString filePath = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + DEFAULT_MIXED_PACKAGE_DIR + packageName + ".txt";
        if (!QFile::exists(filePath)) {
            jsReturnInfoVal.setProperty("RETURN_TYPE", "ERROR");
            jsReturnInfoVal.setProperty("RETURN_VALUE", "Package existiert nicht.");
            return false;
        }
        // Datei löschen
        QFile file(filePath);
        if (!file.remove()) {
            jsReturnInfoVal.setProperty("RETURN_TYPE", "ERROR");
            jsReturnInfoVal.setProperty("RETURN_VALUE", "Package konnte nicht gelöscht werden.");
            return false;
        }
    } else {
        QString dir  = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR  + packageName;
        if (!QDir(dir).exists()) {
            jsReturnInfoVal.setProperty("RETURN_TYPE","ERROR");
            jsReturnInfoVal.setProperty("RETURN_VALUE","Package existiert nicht.");
            return false;
        }
        QDir dirPackage(dir);
        dirPackage.removeRecursively();
    }
    return true;
}


bool PackageManager::createMixPackage  (QString mixPackageName,int cntExercise,QVariantList fromPackageList,  bool override,bool withReverseEntries, QJSValue  jsReturnInfoVal) {

    //int xyz[][]
    qDebug() << "packageName in = " << mixPackageName << " anzahl übungen=" << cntExercise;
    if (fromPackageList.count() <= 0) {

        jsReturnInfoVal.setProperty("RETURN_TYPE","INFO");
        jsReturnInfoVal.setProperty("RETURN_VALUE","Es wurde keine Übung ausgewählt.");
        return false;
    }
    //check ob package already exist
    if (existPackage(mixPackageName)) {
        if (!override) {
            jsReturnInfoVal.setProperty("RETURN_TYPE","ERROR_PACKAGE_EXIST");
            jsReturnInfoVal.setProperty("RETURN_VALUE","Das Packet <" + mixPackageName + "> existiert bereits. Soll es überschrieben werden?");
            return false;
        } else {
            //remove file
            removePackage(mixPackageName,true,jsReturnInfoVal);
        }
    }

    int cntArr=fromPackageList.count();

    for(int i = 0; i < cntArr; i++) {
        QVariant ct = fromPackageList.at(i);
        QList<QVariant> q = ct.toList();
       int cntEntries = qvariant_cast<int>(q.at(1));
       qDebug() << "entrie=" << cntEntries;
    }
    if (cntExercise < fromPackageList.count()) {
        //liste einschränken auf anzah7
        //vorher randomisieren
        fromPackageList = cutAndRandomize(cntExercise,fromPackageList);
    }

    std::vector<std::pair<int,bool>> vecAssignedSizes = buildExersizesPerPackageVector(&fromPackageList,cntExercise);

    for (int i=0 ;i < fromPackageList.count();i++) {
        //move randomized entry to new entry
        //get name from list
        QVariant ct = fromPackageList.at(i);
        QList<QVariant> q = ct.toList();
        QString packName = qvariant_cast<QString>(q.at(0));
        if (!putEntriesToMixPackage(vecAssignedSizes.at(i).first,packName,mixPackageName,withReverseEntries,jsReturnInfoVal)) {
            jsReturnInfoVal.setProperty("RETURN_TYPE","ERROR");
            //jsReturnInfoVal.setProperty("RETURN_VALUE","Das Packet konnte nicht angelegt werden(copy error).");
            jsReturnInfoVal.setProperty("RETURN_VALUE","Das Packet konnte nicht angelegt werden(copy error).");
            return false;
        }
    }
    return true;
}

QList<Entry> PackageManager::getPackageEntryList(QString fullPackageName,bool withReverseEntries, QJSValue  jsReturnInfoVal) {

    XMLParser *parser = new XMLParser(fullPackageName);
    if (parser == NULL) {
        jsReturnInfoVal.setProperty("RETURN_TYPE","ERROR");
        jsReturnInfoVal.setProperty("RETURN_VALUE","Das Packet konnte nicht angelegt werden(package.xml konnte nicht geöffnet werden).");
        return QList<Entry>();
    }
    bool generateReverseEntries = false;
    if (withReverseEntries) {
        //check if possible
        if (parser->existReverseList()) {
            generateReverseEntries = true;
        }
    }
    QList<Entry> retList;
    // Iteriere durch die Elemente und füge neue Einträge hinzu
    for (int i = 1; i <= parser->countExercizeElements("MainÜbungsliste"); i++) {
        retList.append(Entry(i, false)); // Erstelle einen neuen Eintrag und füge ihn der Liste hinzu
        if (generateReverseEntries) {
            retList.append(Entry(i, true)); // Erstelle einen neuen Eintrag und füge ihn der Liste hinzu
        }
    }
    delete parser; // Speicher des Parser-Objekts freigeben
    return retList; // Rückgabe der Liste
}



std::vector<std::pair<int,bool>> PackageManager::buildExersizesPerPackageVector(QVariantList *fromPackageList,int exercizes) {
    std::vector<std::pair<int,bool>> v;
    int lenInList = fromPackageList->count();
    int availExercises=0;
    for (int i = 0; i < lenInList;i++) {
        QVariant ct = fromPackageList->at(i);
        QList<QVariant> q = ct.toList();
        int cntEntries = qvariant_cast<int>(q.at(1));
        availExercises += cntEntries;
    }
    if (availExercises < exercizes) {
        exercizes = availExercises;
    }
    int exersizePerPack = exercizes / lenInList ;
    int remainExersizePerPack = exercizes % lenInList;
    int allEntriesGreaterThanExPerPack = 0;
    int allEntriesLessThanExPerPackTotal = 0;
    for (int i = 0; i < lenInList;i++) {
        QVariant ct = fromPackageList->at(i);
        QList<QVariant> q = ct.toList();
        int cntEntries = qvariant_cast<int>(q.at(1));
        if (cntEntries < exersizePerPack) {
            allEntriesLessThanExPerPackTotal += (exersizePerPack - cntEntries);
        }
        else {
            allEntriesGreaterThanExPerPack++;
        }
        if (cntEntries > exersizePerPack) {
            v.push_back(std::make_pair(cntEntries,true));
        }
        else  {
            v.push_back(std::make_pair(cntEntries,false));
        }
    }
    //comp remain
    allEntriesLessThanExPerPackTotal += remainExersizePerPack;
    int perPackEntries = 0;
    int remainPackEntries = 0;
    perPackEntries = getPerPackageEntries(allEntriesLessThanExPerPackTotal,allEntriesGreaterThanExPerPack,&remainPackEntries);
    bool allProcceeded = false;
    int lastProcceededAt = -1;
    int lastProcceededAtInValue;
    do {
        //looking for lowest value in list
        int lowestVal = 1000000;
        int foundLowestAt = -1;
        for (int i=0; i < lenInList;i++) {
            if (v.at(i).second) {
                if (v.at(i).first < lowestVal) {
                    lowestVal = v.at(i).first;
                    foundLowestAt = i;
                }
            }
        }
        if (foundLowestAt > -1) {
            lastProcceededAt = foundLowestAt;
            lastProcceededAtInValue = v.at(foundLowestAt).first;
            //set is procceed
            allEntriesGreaterThanExPerPack--;
            v.at(foundLowestAt).second = false;
            int mustEntries = exersizePerPack + perPackEntries + ((remainPackEntries > 0)?1:0);
            if (mustEntries > v.at(foundLowestAt).first) {
                int addValDiff = v.at(foundLowestAt).first - exersizePerPack;
                v.at(foundLowestAt).first = exersizePerPack + addValDiff;
                //recalculate
                allEntriesLessThanExPerPackTotal -= addValDiff;
                perPackEntries = getPerPackageEntries(allEntriesLessThanExPerPackTotal,allEntriesGreaterThanExPerPack,&remainPackEntries);
            }
            else {
                v.at(foundLowestAt).first = mustEntries;
                if (remainPackEntries > 0) {
                    remainPackEntries--;
                }
            }
        }
        else {
           allProcceeded = true;
        }

    } while (!allProcceeded);
    //if there are still remaining entries to be distributed
    if (remainPackEntries > 0) {
        if (lastProcceededAt > 0) {
            if (lastProcceededAtInValue > v.at(lastProcceededAt).first) {
                if ((v.at(lastProcceededAt).first + remainPackEntries) > lastProcceededAtInValue) {
                    int diff = lastProcceededAtInValue - (v.at(lastProcceededAt).first + remainPackEntries);
                    v.at(lastProcceededAt).first += diff;
                }
                else {
                    v.at(lastProcceededAt).first += remainPackEntries;
                }
            }
        }
    }
    //add all remaining values to the entries greater perPack
    return v;
}

int PackageManager::getPerPackageEntries(int allEntriesLessThanExPerPackTotal,int allEntriesGreaterThanExPerPack,int *remainRemainExersizePerPack) {
    int retVal;

    retVal = allEntriesLessThanExPerPackTotal / allEntriesGreaterThanExPerPack;
    *remainRemainExersizePerPack = allEntriesLessThanExPerPackTotal % allEntriesGreaterThanExPerPack;
    return retVal;
}

bool PackageManager::existPackage(QString mixedPackage) {

    QString mixedPackageDir  = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR  + DEFAULT_MIXED_PACKAGE_DIR ;
    if (QDir(mixedPackageDir).exists(mixedPackage + ".txt") == true) {
        return true;
    }
    return false;
}

bool PackageManager::putEntriesToMixPackage(int cntEntries,QString package, QString mixPackage,bool withReverseEntries,QJSValue jsReturnInfoVal) {

    //get all entries from package
    QString fullPackageXMLFile = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR  + package + QDir::separator() + "package.xml" ;
    QString fullMixPackageName = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR  + DEFAULT_MIXED_PACKAGE_DIR + mixPackage + ".txt";

    QList<Entry> entries = getPackageEntryList(fullPackageXMLFile,withReverseEntries,jsReturnInfoVal);
    //randomize
    std::random_device rd;
    std::mt19937 rng(rd());
    std::shuffle(entries.begin(),entries.end(),rng);
    ExerciceEntryManager *mgr = new ExerciceEntryManager(fullMixPackageName);
    for (int i=0; i < cntEntries; i++) {
        mgr->putExerciceInList(package,entries.at(i).getPosition(),entries.at(i).isReverse(),false);
    }
    mgr->save();
    delete (mgr);
    return true;
}




bool PackageManager::existPackDir(QString packDir) {
    qDebug() << "baseDir" << env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + DEFAULT_MIXED_PACKAGE_DIR;
    QString fullPackDir  = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR  + DEFAULT_MIXED_PACKAGE_DIR + packDir;
    if (!QDir(fullPackDir).exists()) {
        return false;
    }
    return true;
}

#include <random>
#include <vector>

QVariantList PackageManager::cutAndRandomize(int cntExercise, QVariantList fromPackageList) {
    // Konvertiere QVariantList in std::vector<QVariant>
    std::vector<QVariant> tempList;
    for (const QVariant &item : fromPackageList) {
        tempList.push_back(item);
    }

    // Zufallsgenerator erstellen
    std::random_device rd;
    std::mt19937 rng(rd());

    // Elemente mischen
    std::shuffle(tempList.begin(), tempList.end(), rng);

    // Bereich zum Entfernen bestimmen
    if (tempList.size() > static_cast<size_t>(cntExercise)) {
        tempList.erase(tempList.begin(), tempList.begin() + (tempList.size() - cntExercise));
    }

    // Konvertiere std::vector<QVariant> zurück in QVariantList
    QVariantList resultList;
    for (const QVariant &item : tempList) {
        resultList.append(item);
    }

    return resultList;
}

bool PackageManager::compareDesc2Col(int *a, int *b){
    // sorting on basis of 2nd column
    return a[1] > b[1]; //descending
}

bool PackageManager::compareAsc1Col(int *a, int *b){
    // sorting on basis of 2nd column
    return a[0] < b[0]; //ascending
}


void PackageManager::sorting(int **arr,int n, bool firstCol){
    //calling in built sort
    if (firstCol)
        std::sort(arr, arr + n, compareAsc1Col);
    else
        std::sort(arr, arr + n, compareDesc2Col);
}


