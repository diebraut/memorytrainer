#include <QDebug>

#include "packagedesc.h"

PackageDesc::PackageDesc(QString pathToXmlFile,QString packageName, QObject *parent)
    : QObject(parent),
    packageName(packageName),
    displayExercizesInSequence(false),
    showList(DISPLAY_MAIN),
    customPackage(false),
    fromCustomPackageCreated(false)
{
    this->fullPathToPackage = pathToXmlFile;
    this->xmlParser = getXMLParser(pathToXmlFile);
}


PackageDesc::PackageDesc(QString packageName,bool customPackage,bool fromCustomPackageCreated, QObject *parent)
    : QObject(parent),
    packageName(packageName),
    displayExercizesInSequence(false),
    showList(DISPLAY_MAIN),
    customPackage(customPackage),
    fromCustomPackageCreated(fromCustomPackageCreated)
{
    QString dir = env.getWritableDirectionForOS();
    this->fullPathToPackage = "file:"+ dir + "/" + DEFAULT_PACK_DIR + "/" +  packageName + "/";

    QString pathToXmlFile = dir + DEFAULT_PACK_DIR + packageName + "/" + XML_DESCRIPTION_FILENAME;
    this->xmlParser = getXMLParser(pathToXmlFile);
}

XMLParser* PackageDesc::getXMLParser(QString pathToXmlFile) {
    try {
        // Build filename to description file

        // Erstelle das XMLParser-Objekt
        XMLParser* parser = new XMLParser(pathToXmlFile);

        // Überprüfe, ob der Parser gültig ist
        if (parser->isValid()) {
            this->mainQuestion = parser->getFrageText();
            this->mainQuestionReverse = parser->getFrageTextUmgekehrt();
            this->uebungsTitel = parser->getÜbungsTitel();
            this->frageType = parser->getFrageType();
            this->displayExercizesInSequence = parser->isSequential();
            this->hideAuthorByQuestion_      = parser->isHideAuthorByQuestion();  // <<< NEU
            this->isXMLDescripted = true;
            this->mainQuestions = getCountEntries(parser,DISPLAY_MAIN);
            this->reverseQuestions = getCountEntries(parser,DISPLAY_REVERSE);
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
    return getCountEntries(this->xmlParser,dispOpt);
}

int PackageDesc::getCountEntries(XMLParser* parser,DisplayOption dispOpt) {

    if (dispOpt == DISPLAY_ALL) {
        return parser->countExercizeElements("MainÜbungsliste") * ((parser->existReverseList())?2:1);
    }
    else if (dispOpt == DISPLAY_MAIN) {
        return parser->countExercizeElements("MainÜbungsliste");
    }
    return (parser->existReverseList())?parser->countExercizeElements("MainÜbungsliste"):0;
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
        //check exist an priorizesed packagePart.
        bool isExistPrioritizedPackagePart = existPrioritizedPackagePart();
        for (int i=0; i < listEntries.size();i++) {
            if (!isActiveItemFromLearningPackageList(i)) {
                continue;
            } else {
                if (!isPrioritizedItemFromLearningPackageList(i) && isExistPrioritizedPackagePart) {
                    continue;
                }
            }
            returnList.append(listEntries[i]);
        }
        return returnList;
    }
    return listEntries;
}

bool PackageDesc::existPrioritizedPackagePart() {
    if (this->singlePackageLearning) {
        for (int i = 0; i < this->packageLearningParts.count(); i++) {
            if (this->packageLearningParts[i].prioritized) {
                return true;
            }
        }
    }
    return false;
}

void PackageDesc::setSinglePackageLearning(bool activedSinglePackageLearning,const QList<int> &parts, QString packageName) {
    this->singlePackageLearning = activedSinglePackageLearning;
    this->packageLearningParts.clear();
    if (activedSinglePackageLearning) {
        this->singlePackageLearningName = packageName;
        for (int i=0; i < parts.count();i++) {
            PackagePartState *packagePartState = new PackagePartState(false,false,parts.value(i));
            if (i == 0) packagePartState->active = true;
            this->packageLearningParts.append(*packagePartState);
        }
    }
}

void PackageDesc::setSinglePackageLearningPart(bool setToActive,int partIdx) {

    if (partIdx < this->packageLearningParts.size()) {
        PackagePartState packagePartState =  this->packageLearningParts.value(partIdx);
        packagePartState.active = setToActive;
        this->packageLearningParts.replace(partIdx,packagePartState);
    }
    return;
}

void PackageDesc::setSinglePackageLearningPartPrioritized(bool setToPrioritized,int partIdx) {
    for (int i = 0; i < this->packageLearningParts.size();i++ ) {
       PackagePartState packagePartState =  this->packageLearningParts.value(i);
       packagePartState.prioritized = false;
       if (partIdx == i && setToPrioritized) {
           packagePartState.prioritized = true;
       }
       this->packageLearningParts.replace(i,packagePartState);
    }
    return;
}


bool PackageDesc::isActiveItemFromLearningPackageList(int idxItem) {
    int firstIdx = 0;
    for (int i=0; i < this->packageLearningParts.count();i++) {
        PackagePartState packagePartState = this->packageLearningParts.value(i);
        if (packagePartState.active) { //active flag
            //set range
            int from = firstIdx;
            int to   = firstIdx + packagePartState.count - 1 ;
            if (idxItem >= from && idxItem <= to) {
                return true;
            }
        }
        firstIdx += packagePartState.count;
    }
    return false;
}

bool PackageDesc::isPrioritizedItemFromLearningPackageList(int idxItem) {
    int firstIdx = 0;
    for (int i=0; i < this->packageLearningParts.count();i++) {
        PackagePartState packagePartState = this->packageLearningParts.value(i);
        if (packagePartState.prioritized) { //prioritized flag
            //set range
            int from = firstIdx;
            int to   = firstIdx + packagePartState.count - 1 ;
            if (idxItem >= from && idxItem <= to) {
                return true;
            }
        }
        firstIdx += packagePartState.count;
    }
    return false;
}


LicenceInfo PackageDesc::getLicenceInfo(int number,bool isReverse) {
    if (this->xmlParser != NULL) {
        return this->xmlParser->getLicenceInfo(number,isReverse);
    }
    return LicenceInfo();
}

