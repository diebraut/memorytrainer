#include <QDebug>

#include "packagedesc.h"

PackageDesc::PackageDesc(QString packageName,bool customPackage,bool fromCustomPackageCreated, QObject *parent)
    : QObject(parent),
    packageName(packageName),
    displayExercizesInSequence(false),
    showList(DISPLAY_MAIN),
    customPackage(customPackage),
    fromCustomPackageCreated(fromCustomPackageCreated)
{
    this->xmlParser = getXMLDescription(packageName);
    QString dir = env.getWritableDirectionForOS();
    this->fullPathToPackage = "file:"+ dir + "/" + DEFAULT_PACK_DIR + "/" +  packageName + "/";

    if (this->xmlParser != NULL) {
        this->mainQuestion = this->xmlParser->getFrageText();
        this->mainQuestionReverse = this->xmlParser->getFrageTextUmgekehrt();
        this->uebungsTitel = this->xmlParser->getÜbungsTitel();
        this->displayExercizesInSequence = this->xmlParser->isSequential();
        this->hideAuthorByQuestion_      = this->xmlParser->isHideAuthorByQuestion();  // <<< NEU
        this->isXMLDescripted = true;
        this->mainQuestions = getCountEntries(DISPLAY_MAIN);
        this->reverseQuestions = getCountEntries(DISPLAY_REVERSE);
        if (!this->mainQuestion.isEmpty() && !this->mainQuestionReverse.isEmpty()) {
            this->showList = DISPLAY_ALL;
        }
        else if (!this->mainQuestion.isEmpty()) {
            this->showList = DISPLAY_MAIN;
        }
        else if (!this->mainQuestionReverse.isEmpty()) {
            this->showList = DISPLAY_REVERSE;
        }
        else {
            this->showList = DISPLAY_NOTHING;
        }
    }
}

XMLParser* PackageDesc::getXMLDescription(QString packageName) {
    try {
        // Build filename to description file
        QString entryDir = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + packageName + "/" + XML_DESCRIPTION_FILENAME;

        // Erstelle das XMLParser-Objekt
        XMLParser* parser = new XMLParser(entryDir);

        // Überprüfe, ob der Parser gültig ist
        if (parser->isValid()) {
            return parser; // Erfolgreich, gib den Parser zurück
        } else {
            delete parser; // Parser ist ungültig, Speicher freigeben
            return NULL; // NULL zurückgeben
        }
    } catch (std::exception &e) {
        qDebug() << "Error: " << e.what();
        return NULL;
    }
}


int PackageDesc::getCountEntries(DisplayOption dispOpt) {

    if (dispOpt == DISPLAY_ALL) {
        return xmlParser->countExercizeElements("MainÜbungsliste") * ((xmlParser->existReverseList())?2:1);
    }
    else if (dispOpt == DISPLAY_MAIN) {
        return xmlParser->countExercizeElements("MainÜbungsliste");
    }
    return (xmlParser->existReverseList())?xmlParser->countExercizeElements("MainÜbungsliste"):0;
}


QList<EntryDesc *> PackageDesc::getEntriesForList(QList<EntryDesc *> listEntries,int idxPackageList,QList<Entry> *filterEntries) {

    QList<EntryDesc *> returnList;
    if (this->showList == DISPLAY_ALL) {
        listEntries = this->xmlParser->getExercizeList("MainÜbungsliste",idxPackageList,listEntries,filterEntries);
        listEntries = this->xmlParser->getExercizeList("MainÜbungslisteUmgekehrt",idxPackageList,listEntries,filterEntries);
    } else if (this->showList == DISPLAY_MAIN) {
        listEntries = this->xmlParser->getExercizeList("MainÜbungsliste",idxPackageList,listEntries,filterEntries);
    } else if (this->showList == DISPLAY_REVERSE) {
        listEntries = this->xmlParser->getExercizeList("MainÜbungslisteUmgekehrt",idxPackageList,listEntries,filterEntries);
    } else {
        //do nothing
        return  returnList;
    }
    if (singlePackageLearning) {
        for (int i=0; i < listEntries.size();i++) {
            if (isSinglePackageLearning() && !isActiveItemFromLearningPackageList(i)) {
                continue;
            }
            returnList.append(listEntries[i]);
        }
        return returnList;
    }
    return listEntries;
}

void PackageDesc::setSinglePackageLearning(bool activedSinglePackageLearning,const QList<int> &parts, QString packageName) {
    this->singlePackageLearning = activedSinglePackageLearning;
    this->packageLearningParts.clear();
    if (activedSinglePackageLearning) {
        this->singlePackageLearningName = packageName;
        for (int i=0; i < parts.count();i++) {
            bool active = false;
            if (i == 0) active = true;
            this->packageLearningParts.append(QPair<bool,int>(active,parts.value(i)));
        }
    }
}

void PackageDesc::setSinglePackageLearningPart(bool setToActive,int partIdx) {

    if (partIdx < this->packageLearningParts.size()) {
        QPair<bool,int> p =  this->packageLearningParts.value(partIdx);
        p.first = setToActive;
        this->packageLearningParts.replace(partIdx,p);
    }
    return;
}

bool PackageDesc::isActiveItemFromLearningPackageList(int idxItem) {
    int firstIdx = 0;
    for (int i=0; i < this->packageLearningParts.count();i++) {
        QPair<bool,int> pair = this->packageLearningParts.value(i);
        if (pair.first) { //active flag
            //set range
            int from = firstIdx;
            int to   = firstIdx + pair.second - 1 ;
            if (idxItem >= from && idxItem <= to) {
                return true;
            }
        }
        firstIdx += pair.second;
    }
    return false;
}

LicenceInfo PackageDesc::getLicenceInfo(int number,bool isReverse) {
    if (this->xmlParser != NULL) {
        return this->xmlParser->getLicenceInfo(number,isReverse);
    }
    return LicenceInfo();
}

