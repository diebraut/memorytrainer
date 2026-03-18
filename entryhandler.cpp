#define XML_DESCRIPTION_FILENAME "package.xml"

#include "entryhandler.h"
#include "provedorimagem.h"

#include <algorithm>
#include <random>

#include <QDebug>
#include <QList>

#include <QDebug>
#include <QUrl>
#include <QQmlEngine>
#include <QQmlContext>
#include <QImageWriter>
#include <QStandardPaths>
#include <QRegularExpression>

static EntryHandler *qml_instance = nullptr;

void EntryHandler::registerSingleton(QQmlEngine *qmlEngine,QObject *parent)
{
    if (!qml_instance) {
        qml_instance = new EntryHandler(parent,qmlEngine);
    }
    QQmlContext *rootContext = qmlEngine->rootContext();
    rootContext->setContextProperty("ImageHandler", qml_instance);
}


EntryHandler::EntryHandler(QObject *parent,QQmlEngine *qmlEngine) :
    QObject(parent)
{
    this->qmlEngine  = qmlEngine;
    this->firstCall = true;
    learnListManager = LearnListEntryManager::getInstance();

}

void EntryHandler::setPlatform (bool isMobile) {
    this->isMobilePlatform = isMobile;
    if (!isMobile) {
        //set image
        QString fileName = DEFAULT_PACK_DIR + this->actPackage + "/" + this-> m_entryDesc.imageFilenameFrage() ;
        this->lastPictureTaken = new QImage(fileName);
        return;
    } else {
        if (this->firstCall) {
            qDebug("firstCall");
            QQmlImageProviderBase* imageProviderBase = qmlEngine->imageProvider("provedor");
            provedorImagem* imageProvider = static_cast<provedorImagem*>(imageProviderBase);
            if (imageProvider != nullptr) {
                qDebug("connect Imageprovider");
                //connect
                connect(imageProvider, SIGNAL(CapturedImageSignal(QImage*,int)), this, SLOT(SetLastPictureTaken(QImage*,int)));
            }
            this->firstCall = false;
        }
    }
}


int  EntryHandler::sizeActExercisePackages() {
    return actExercisePackages.size();
}


int EntryHandler::getPackageEntries(QString packageName,int unit,bool isCustomPackage,bool onlyMainEntries) {
    int retSize = 0;
    if (isCustomPackage) {
        QString packageFilename = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + DEFAULT_MIXED_PACKAGE_DIR + packageName + ".txt";
        ExerciceEntryManager *mgr = new ExerciceEntryManager(packageFilename);
        retSize = mgr->getTotalPositionCount();
        delete(mgr);
    } else {
        QDir directory(env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + packageName);
        PackageDesc *packageDesc = new PackageDesc(directory.dirName(),unit,false,false);
        qDebug() << "DIRECTORY=" + directory.dirName();
        if (packageDesc->getIsXMLDescripted()) {
            if (onlyMainEntries) {
                retSize = packageDesc->getCountEntries(PackageDesc::DISPLAY_MAIN);
            } else {
                retSize = packageDesc->getCountEntries(PackageDesc::DISPLAY_ALL);
            }
            qDebug() << "Package size: =" + std::to_string(retSize) ;
        } else {
            QStringList images = directory.entryList(QStringList()  << "*.jpg" << "*.JPG",QDir::Files);
            retSize =images.size();
        }
        delete(packageDesc);
    }
    return retSize;
}


QList<PackageDesc *> EntryHandler::getPackages(bool onlyXMLPackages, bool withCustomPackages)
{
    qDeleteAll(m_packages);
    m_packages.clear();

    QList<PackageDesc *> result;

    QString packageDir = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR;
    QDir directory(packageDir);

    const QStringList dirEntries =
        directory.entryList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);

    for (const auto &entryName : std::as_const(dirEntries)) {

        if (entryName.startsWith("__"))
            continue;

        const QString dirPath = packageDir + "/" + entryName;
        QDir subDir(dirPath);

        const QStringList xmlFiles = subDir.entryList(
            QStringList() << "package*.xml",
            QDir::Files,
            QDir::Name
            );

        bool hasMatchingXml = false;

        for (const auto &fileName : std::as_const(xmlFiles)) {

            int exercizeUnit = -1;

            if (fileName == "package.xml") {
                exercizeUnit = 0;
            } else if (fileName.size() == 14 &&
                       fileName.startsWith("package_") &&
                       fileName.endsWith(".xml")) {
                bool ok = false;
                const int nr = QStringView{fileName}.mid(8, 2).toInt(&ok);
                if (!ok || nr < 1 || nr > 99)
                    continue;
                exercizeUnit = nr;
            } else {
                continue;
            }

            hasMatchingXml = true;

            PackageDesc *packageDesc =
                new PackageDesc(subDir.filePath(fileName),exercizeUnit, entryName, this);

            packageDesc->setExercizeUnit(exercizeUnit);

            m_packages.append(packageDesc);
            result.append(packageDesc);
        }

        if (!hasMatchingXml && !onlyXMLPackages) {
            PackageDesc *packageDesc = new PackageDesc(entryName,0, false, false, this);
            m_packages.append(packageDesc);
            result.append(packageDesc);
        }
    }

    if (withCustomPackages) {
        packageDir = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + DEFAULT_MIXED_PACKAGE_DIR;
        const QStringList customPackages = getTxtFilesWithoutSuffix(packageDir);

        for (const auto &entryName : std::as_const(customPackages)) {
            PackageDesc *packageDesc = new PackageDesc(entryName,0, true, false, this);
            packageDesc->setShowList(PackageDesc::DISPLAY_ALL);
            const QString fullFileName =
                env.getWritableDirectionForOS()
                + DEFAULT_PACK_DIR
                + DEFAULT_MIXED_PACKAGE_DIR
                + entryName
                + ".txt";

            packageDesc->setFullPathToPackage(fullFileName);

            m_packages.append(packageDesc);
            result.append(packageDesc);
        }
    }

    return result;
}

QStringList EntryHandler::getTxtFilesWithoutSuffix(const QString &directoryName) {
    QStringList result; // Liste, die zurückgegeben wird

    // QDir-Objekt für das angegebene Verzeichnis
    QDir directory(directoryName);

    // Überprüfen, ob das Verzeichnis existiert
    if (!directory.exists()) {
        qWarning() << "Directory does not exist:" << directoryName;
        return result;
    }

    // Liste aller Dateien mit dem Suffix ".txt"
    QStringList txtFiles = directory.entryList({"*.txt"}, QDir::Files);

    // Entfernen des Suffixes ".txt"
    for (const QString &fileName : txtFiles) {
        result.append(fileName.left(fileName.lastIndexOf(".txt")));
    }

    return result;
}

void EntryHandler::initEntryList(bool useLearnList) {

    this->listEntries.clear();
    PackageDesc *p = getPackageIsInPartedLearningMode();
    if (p != NULL) {
        int idx =getIndexFromPackageList(p->getSinglePackageLearningName(),p->getExercizeUnit());
        if (idx >= 0) {
            putItemInEntryList(p->getSinglePackageLearningName(),p->getExercizeUnit(),idx);
        }
        else {
            qDebug("Error:can't fond package. Do nothing!! ");
        }
    }
    else {
        for (int cntPackage=0; cntPackage < this->actExercisePackages.size();cntPackage++) {
            putItemInEntryList( this->actExercisePackages[cntPackage]->getPackageName(),this->actExercisePackages[cntPackage]->getExercizeUnit(),cntPackage,useLearnList);
        }
    }
    this->allAvailableEntrys = this->listEntries.size();
    return;
}

int EntryHandler::getIndexFromPackageList(QString packageName,int unit) {
    for (int i=0; i < this->actExercisePackages.size();i++) {
        if ((QString::compare(packageName, this->actExercisePackages[i]->getPackageName(), Qt::CaseInsensitive) == 0) && actExercisePackages[i]->getExercizeUnit() == unit) {
            return i;
        }
    }
    return -1;
}


void EntryHandler::putItemInEntryList(QString packageName, int unit, int idxPackage, bool useLearnList ) {
    if (this->actExercisePackages[idxPackage]->isFromCustomPackageCreated()) {
        return;
    }
    else if (this->actExercisePackages[idxPackage]->isCustomPackage()) {
        ExerciceEntryManager *extMgr = new ExerciceEntryManager(this->actExercisePackages[idxPackage]->getFullPathToPackage());
        if (extMgr !=NULL) {
            QList<Package> list = extMgr->getPackages();
            for (int i = 0; i < list.size(); i++) {
                QList<Entry> entries = list.at(i).getEntries();
                int idx = addExercisePackage(list.at(i).getPackageName(),false,true);
                if (idx > 0) {
                    this->actExercisePackages[idx]->setSinglePackageLearning(this->actExercisePackages[idxPackage]->isSinglePackageLearning());
                    this->actExercisePackages[idx]->setPackageLearningParts(this->actExercisePackages[idxPackage]->getPackageLearningParts());
                    this->listEntries = this->actExercisePackages[idx]->getEntriesForList(this->listEntries,idx,&entries);
                }
            }
        } else {
           qDebug("Error:can't found custom package. Do nothing!! ");
        }
    } else {
        QString entryDir  = env.getWritableDirectionForOS() + DEFAULT_PACK_DIR + packageName;
        QDir directory(entryDir);
        PackageDesc *packageDesc = getPackageDesc(packageName,unit);
        if (packageDesc->getIsXMLDescripted()) {
            if (useLearnList) {
                QList<Entry> entries ;
                PackageDesc::DisplayOption lastDisplayState = packageDesc->getShowList();
                entries = learnListManager->getPackageByName(this->actExercisePackages[idxPackage]->getPackageName(), this->actExercisePackages[idxPackage]->getExercizeUnit())->getEntries();
                //first all with not main
                QList<Entry> entriesMain = getFilteredEntries(entries,false);
                packageDesc->setShowList(PackageDesc::DISPLAY_MAIN);
                this->listEntries = packageDesc->getEntriesForList(this->listEntries,idxPackage,&entriesMain);
                QList<Entry> entriesReverse = getFilteredEntries(entries,true);
                packageDesc->setShowList(PackageDesc::DISPLAY_REVERSE);
                this->listEntries = packageDesc->getEntriesForList(this->listEntries,idxPackage,&entriesReverse);
                packageDesc->setShowList(lastDisplayState);
            } else {
                this->listEntries = packageDesc->getEntriesForList(this->listEntries,idxPackage);
            }
            if (idxPackage==0 && this->listEntries.size() > 0) {
                this-> m_entryDesc = *this->listEntries.value(0);
            }
            return;
        } else {
            QStringList images = directory.entryList(QStringList()  << "*.jpg" << "*.JPG",QDir::Files,QDir::Name);
            for (int i=0; i < images.size(); i++) {
                if (packageDesc->isSinglePackageLearning() && !packageDesc->isActiveItemFromLearningPackageList(i)) {
                    continue;
                }
                this->listEntries.append(new EntryDesc(images.value(i),idxPackage));
            }
            if (idxPackage==0 && this->listEntries.size() > 0) {
                this-> m_entryDesc.setImageFilenameFrage(this->listEntries.value(0)->imageFilenameFrage());
                this-> m_entryDesc.setIdxActExercisePackages(this->listEntries.value(0)->getIdxActExercisePackages());
            }
        }
    }
    return;
}

QList<Entry> EntryHandler::getFilteredEntries(const QList<Entry> &entries, bool reversed) {
    QList<Entry> returnEntries;

    for (const Entry &entry : entries) {
        // If `reversed` is true, add only entries with `isReverse() == true`
        // If `reversed` is false, add only entries with `isReverse() == false`
        if (entry.isReverse() == reversed) {
            returnEntries.append(entry);
        }
    }

    return returnEntries;
}

PackageDesc *EntryHandler::getPackageDesc(QString packageName,int unit) {
    for (int i=0; i < this->actExercisePackages.size();i++) {
        if ((QString::compare(packageName, this->actExercisePackages[i]->getPackageName(), Qt::CaseInsensitive) == 0) && this->actExercisePackages[i]->getExercizeUnit() == unit) {
            return this->actExercisePackages[i];
        }
    }
    return NULL;
}

PackageDesc *EntryHandler::getPackageIsInPartedLearningMode() {
    for (int i=0; i < this->actExercisePackages.size();i++) {
        if (actExercisePackages[i]->isSinglePackageLearning()) {
            return this->actExercisePackages[i];
        }
    }
    return NULL;
}


void EntryHandler::randomizeEntryList() {

    std::random_device rd;
    std::mt19937 rng(rd());
    std::shuffle(this->listEntries.begin(),this->listEntries.end(),rng);
    if (actImgIdx >= 0) {
        this-> m_entryDesc.setImageFilenameFrage(this->listEntries.value(actImgIdx)->imageFilenameFrage());
        this-> m_entryDesc.setIdxActExercisePackages(this->listEntries.value(actImgIdx)->getIdxActExercisePackages());
    }
}

//
bool EntryHandler::existImage(QString imgName) {
    for (int i=0; i < this->listEntries.size(); i++) {
        if (getEntryName(i).trimmed().toUpper() == imgName.trimmed().toUpper()) {
            return true;
        }
    }
    return false;
}


QString EntryHandler::imageName()
{
    if (actImgIdx < this->listEntries.size() && actImgIdx >=0 ) {
        return this->listEntries.value(actImgIdx)->imageFilenameFrage();
    }
    return "";
}

QString EntryHandler::imageNameLast()
{
    if (actImgIdx < this->listEntries.size() && actImgIdx > 0 ) {
        return this->listEntries.value(actImgIdx-1)->imageFilenameFrage();
    }
    return "";
}


QString EntryHandler::imageFileName()
{
    QString dir = env.getWritableDirectionForOS();
    return "file:"+ dir + "/" + DEFAULT_PACK_DIR + "/" +  getPackageName(this-> m_entryDesc.getIdxActExercisePackages()) + "/" + m_entryDesc.imageFilenameFrage();
}

EntryDesc EntryHandler::getActEntryDescription() {
    return m_entryDesc;
}


LicenceInfo EntryHandler::getActLicenceInfo() {
    PackageDesc packageDesc = getActPackageDescription();
    LicenceInfo licenceInfo = packageDesc.getLicenceInfo(m_entryDesc.getExercizeNumber(),m_entryDesc.isReverse());
    return licenceInfo;
}


PackageDesc* EntryHandler::getActPackageDescriptionIdx(int idx)
{
    const int sizePackages = this->actExercisePackages.size();

    if (idx >= 0 && idx < sizePackages) {
        return this->actExercisePackages[idx];
    }

    return nullptr;
}

PackageDesc* EntryHandler::getActPackageDescription()
{
    const int sizePackages = this->actExercisePackages.size();
    const int idx = m_entryDesc.getIdxActExercisePackages();

    if (idx >= 0 && idx < sizePackages) {
        return this->actExercisePackages[idx];
    }

    return nullptr;
}

void EntryHandler::setQuestionOptionInActPackageIdx(int idx,PackageDesc::DisplayOption option) {
    int sizePackages = this->actExercisePackages.size();
    if ( sizePackages > idx ) {
        this->actExercisePackages[idx]->setShowList(option);
        this->actExercisePackagesChanged = true;
    }
}

bool EntryHandler::hideAuthorByQuestionInActPackageIdx(int idx) {
    int sizePackages = this->actExercisePackages.size();
    if ( sizePackages > idx ) {
        return this->actExercisePackages[idx]->hideAuthorByQuestion();
    }
    return false;
}

void EntryHandler::setDisplayExercizesInSequenceInActPackageIdx(int idx,bool inSequence) {
    int sizePackages = this->actExercisePackages.size();
    if ( sizePackages > idx ) {
        this->actExercisePackages[idx]->setDisplayExercizesInSequence(inSequence);
        this->actExercisePackagesChanged = true;
    }
}


bool Q_INVOKABLE EntryHandler::changeEntryName (int cnt, QString newName) {

    if (newName.size() < 3) {
        return false;
    }
    EntryDesc *img =  getEntryDesc(cnt);
    if (img == nullptr) return false;
    QString dir = env.getWritableDirectionForOS();
    QString fileNameOld = dir + "/" + DEFAULT_PACK_DIR + "/" + getPackageName(img->getIdxActExercisePackages()) + "/" + img->imageFilenameFrage();
    QString fileNameNew = dir + "/" + DEFAULT_PACK_DIR + "/" + getPackageName(img->getIdxActExercisePackages()) + "/" + newName;
    QFile file (fileNameOld);
    if (!file.rename(fileNameNew)) {
        return false;
    }
    img->setImageFilenameFrage(newName);
    return true;
}


bool Q_INVOKABLE EntryHandler::deleteEntry (int cnt) {

    EntryDesc *img =  getEntryDesc(cnt);
    if (img == nullptr) return false;
    QString dir = env.getWritableDirectionForOS();
    QString fileName = dir + "/" + DEFAULT_PACK_DIR + "/" + getPackageName(img->getIdxActExercisePackages()) + "/" + img->imageFilenameFrage();
    QFile file (fileName);
    if (file.remove()) {
        int cntEntry=0;
        for (int i=0;i < this->listEntries.size();i++) {
            cntEntry++;
            if (cntEntry == cnt) {
                this->listEntries.removeAt(i);
                break;
            }
        }
        triggerEvent(cnt);
    }
    else {
        return false;
    }
    return true;
}

Q_INVOKABLE QString EntryHandler::getEntryFilename (int cnt) {

    EntryDesc *img =  getEntryDesc(cnt);
    if (img != nullptr) {
        QString dir = env.getWritableDirectionForOS();
        return "file:" + dir +"/" + DEFAULT_PACK_DIR + "/" + getPackageName(img->getIdxActExercisePackages()) + "/" + img->imageFilenameFrage();
    }
    return "";
}

Q_INVOKABLE QString EntryHandler::getEntryName (int cnt) {

    EntryDesc *img =  getEntryDesc(cnt);
    if (img != nullptr) {
        return img->imageFilenameFrage();
    }
    return "";
}

QString EntryHandler::getPackageName(int cnt) {
    int sizePackages = this->actExercisePackages.size();
    if (cnt < sizePackages && sizePackages > 0) {
        return this->actExercisePackages[cnt]->getPackageName();
    }
    return "unknownPackage";
}

EntryDesc *EntryHandler::getEntryDesc(int cnt) {
    if (cnt > this->listEntries.size()) {
        cnt = this->listEntries.size();
    }
    /*
    int cntEntry=0;
    //search in
    for (int i=0;i < this->listEntries.size();i++) {
        cntEntry++;
        if (cntEntry == cnt) {
            return this->listEntries.value(i);
        }
    }
    */
    return (this->listEntries.size() > 0) ? this->listEntries.value(cnt-1) : nullptr;
}


void EntryHandler::SetLastPictureTaken(QImage *image,int capturedImageID)
{
    if (image != nullptr) {
        this->lastPictureTaken      = image;
        this->lastCapturedImageID   = capturedImageID;
    }
}

bool EntryHandler::saveLastPictureTaken (QString imgName,bool isWideformat) {
    if ((this->lastPictureTaken == nullptr) && !existImage(imgName)) {
        return false;
    }

    //check if folder exist and create if not
    //QDir dir(DEFAULT_PACK_DIR + this->actPackage);
    QString packageDir = DEFAULT_PACK_DIR;
    QString dir = env.getWritableDirectionForOS();
    dir += "/" + packageDir;
    if (!QDir(dir).exists()) {
        if (!QDir().mkdir(dir)) {
            qDebug() << "Fatal error: can't create directory -> " << packageDir;
            return false;
        }
    }
    dir += "/" + this->actPackage;
    if (!QDir(dir).exists()) {
        if (!QDir().mkdir(dir)) {
            qDebug() << "Fatal error: can't create directory -> " << this->actPackage;
            return false;
        }
    }
    QString saveName = dir +  "/" + imgName;
    if (this->lastSavedImageID != this->lastCapturedImageID) { //is new

        QImageWriter writer(saveName);

        if (isWideformat) {
            QTransform rotacao;
            rotacao.rotate(270);
            *this->lastPictureTaken = this->lastPictureTaken->transformed(rotacao);
        }
        if (!writer.write(*this->lastPictureTaken)) {
            qDebug() << writer.errorString();
            return false;
        }
        this->lastSavedImageID = this->lastCapturedImageID;
        this->lastImageFilename = imgName;
    }
    else { //same image => update filename
        //looking for file
        if (existImage(this->lastImageFilename)) {
            QString oldName = dir + "/" + this->lastImageFilename;
            if (!QFile::rename(oldName,saveName)) {
                return false;
            }
            this->lastImageFilename = imgName;
        }
    }
     // TODO: Packagename zuordnen
    //initEntryList();
    return true;
}

bool EntryHandler::setNextQuestion(void)
{
    if (listEntries.size() > 0 && actImgIdx < listEntries.size()) {
        actImgIdx++;
        m_entryDesc = *listEntries.value(actImgIdx);
        return (actImgIdx == listEntries.size() - 1);
    }
    return true;
}

void EntryHandler::adjustEntryListWithLearnList() {
    for (int i=listEntries.size() - 1; i >= 0;i--) {
        if (!isEntryOnLearnList(listEntries.at(i))) {
            listEntries.removeAt(i);
            actImgIdx--; //one back
        }
    }
}

bool EntryHandler::isEntryOnLearnList(EntryDesc *entry) {
    //get positio
    int position = entry->getExercizeNumber();
    int idxPackage = entry->getIdxActExercisePackages();
    if (learnListManager) {
        QList<Package> packages = learnListManager->getPackages();
        for (int i = 0; i < packages.size(); i++ ) {
            if (actExercisePackages.at(idxPackage)->getPackageName().contains(packages.at(i).getPackageName()) ) {
                for (int y=0; y < packages.at(i).getEntries().size(); y++) {
                    if (packages.at(i).getEntries().at(y).getPosition() == position) {
                        return true;
                    }
                }
            }
        }
    }
    return false;
}

bool EntryHandler::isFirstEntry() {
    return (actImgIdx <= 0);
}


void EntryHandler::setActEntryRecognizedState(bool state) {
    if (this->actImgIdx >= 0 && this->actImgIdx < this->listEntries.size()  ) {
        this->listEntries.value(this->actImgIdx)->setRecognizedState(state);
    }
}

void EntryHandler::setLastEntryRecognizedState(bool state) {
    if (this->actImgIdx > 0 && this->actImgIdx < this->listEntries.size()  ) {
        this->listEntries.value(this->actImgIdx - 1)->setRecognizedState(state);
    }
}

int EntryHandler::setEntryList(bool all, bool recognizedState,bool isLearnlist) {
    if (this->actExercisePackagesChanged) {
        initEntryList(isLearnlist);
        this->actExercisePackagesChanged = false;
    }
    else if (!all) {
        //remove all with other state than recognizedState
        for (int i = this->listEntries.size() - 1; i >= 0; i--) {
            if (this->listEntries.value(i)->isRecognizedState() != recognizedState) {
                this->listEntries.removeAt(i);
            }
        }
    }
    else {
        if (this->allAvailableEntrys != this->listEntries.size()) {
            initEntryList(isLearnlist);
        }
        else {
            for (int i = this->listEntries.size() - 1; i >= 0; i--) {
                this->listEntries.value(i)->setRecognizedState(recognizedState);
            }
        }
    }
    this->actImgIdx = -1;
    //
    return this->listEntries.size();
}

void EntryHandler::setSinglePackageLearning(bool activedSinglePackageLearning,const QList<int> &parts, QString packageName, int unit) {

    PackageDesc *p = getPackageDesc(packageName,unit);
    if (p != NULL) {
        p->setSinglePackageLearning(activedSinglePackageLearning,parts,packageName,unit);
        //force load all packages
        this->actExercisePackagesChanged = true;
    }
}


void EntryHandler::setSinglePackageLearningPart(bool setToActive,int partIdx) {

    //looking for package with singlePackageLerning is true (only one is allowed)
    for (int i = 0; i < actExercisePackages.size();i++) {
        if (actExercisePackages[i]->isSinglePackageLearning()) {
            actExercisePackages[i]->setSinglePackageLearningPart(setToActive,partIdx);
            this->actExercisePackagesChanged = true;
            return;
        }
    }
}

void EntryHandler::setSinglePackageLearningPartPrioritized(bool setToPrioritized,int partIdx) {

    //looking for package with singlePackageLerning is true (only one is allowed)
    for (int i = 0; i < actExercisePackages.size();i++) {
        if (actExercisePackages[i]->isSinglePackageLearning()) {
            actExercisePackages[i]->setSinglePackageLearningPartPrioritized(setToPrioritized,partIdx);
            this->actExercisePackagesChanged = true;
            return;
        }
    }
}


int  EntryHandler::cntEntriesInRecognizedState(bool state) {
    int cnt =  0;
    for (int i = 0; i < this->listEntries.size(); i++) {
        if (this->listEntries.value(i)->isRecognizedState() == state) {
            cnt++;
        }
    }
    return cnt;
}
void EntryHandler::initExercisePackages() {

    this->actExercisePackages.clear();
    this->actExercisePackagesChanged = true;
}


int EntryHandler::addExercisePackage(QString packageName,int unit,bool isCustomPackage,bool isFromCustomPackageCreated) {
    int idx = isPackageInExersizeList(packageName,unit);
    if ((this->actExercisePackages.size() == 0) || idx < 0) {
        PackageDesc *p = new PackageDesc(packageName,unit, isCustomPackage,isFromCustomPackageCreated);
        this->actExercisePackages.append(p);
        this->actExercisePackagesChanged = true;
        if (isCustomPackage) {
            p->setShowList(PackageDesc::DISPLAY_ALL);
            QString dir = env.getWritableDirectionForOS();
            QString fullFileName = dir + DEFAULT_PACK_DIR + DEFAULT_MIXED_PACKAGE_DIR + packageName + ".txt";
            p->setFullPathToPackage(fullFileName);
        }
        idx = this->actExercisePackages.size() - 1;
    }
    return idx;
}

void EntryHandler::removeExercisePackage(QString packageName,int unit) {
    int atPos = isPackageInExersizeList(packageName,unit);
    if (atPos >= 0) {
        this->actExercisePackages.removeAt(atPos);
        this->actExercisePackagesChanged = true;
    }
}

int EntryHandler::isPackageInExersizeList(QString package,int unit) {
    for (int i=0; i < this->actExercisePackages.size();i++) {
        if ((package.compare(this->actExercisePackages[i]->getPackageName()) == 0) && this->actExercisePackages[i]->getExercizeUnit() == unit) {
            return i;
        }
    }
    return -1;
}

int EntryHandler::getEntriesSize (void) {
    return this->listEntries.size();
}

int EntryHandler::loadPackage(QString packageName,int unit, bool isLearnlist) {
    initExercisePackages();
    if (isLearnlist) {
        addPackagesFromLearnList();
    } else {
        addExercisePackage(packageName,unit);
    }
    initEntryList(isLearnlist);
    this->allEntryNames.clear();
    return this->allAvailableEntrys;
}

void EntryHandler::addPackagesFromLearnList() {
    if (learnListManager) {
        QList<Package> packages = learnListManager->getPackages();
        for (int i = 0; i < packages.size(); i++ ) {
            addExercisePackage(packages.at(i).getPackageName(),0);
        }
    }
}


int EntryHandler::getMatchingEntry(QString pattern) {
    if (this->allEntryNames.size() == 0) {
        for (int i=1; i <= this->allAvailableEntrys ;i++) {
            QString name = getEntryName(i);
            this->allEntryNames.append(name);
        }
    }
    auto regExp01 = QRegularExpression(QRegularExpression::wildcardToRegularExpression(pattern + "*"));
    //QRegularExpression regExp01 (pattern + "*");
    regExp01.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
    //regExp01.setCaseSensitivity(Qt::CaseInsensitive);
    bool pos01=false;

    auto regExp02 = QRegularExpression(QRegularExpression::wildcardToRegularExpression("*" + pattern + "*"));
    //QRegularExpression regExp02 ("*" + pattern + "*");
    //regExp02.setCaseSensitivity(Qt::CaseInsensitive);
    regExp02.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
    //regExp02.setPatternSyntax(QRegExp::Wildcard);
    bool pos02=false;
    int idxPos02 = -1;
    for (int i=0; i < this->allEntryNames.size() ;i++) {
        QRegularExpressionMatch match = regExp01.match(this->allEntryNames.value(i));
        pos01 =  match.hasMatch();
        //pos01 = regExp01.exactMatch(this->allEntryNames.value(i));
        match = regExp02.match(this->allEntryNames.value(i));
        pos02 = match.hasMatch();
        if (pos01) {
            return i++;
        }
        if ((idxPos02  == -1) && pos02) {
            //check if ok with pattern inside of entryname
            idxPos02 = i++;
        }
    }
    if (idxPos02 >= 0) {
        return idxPos02;
    }
    return -1;

}

int EntryHandler::getActEntryPos() {
    return this->actImgIdx+1;
}


void EntryHandler::setSaveToPackage(QString packageName) {

    //check if dir already exist
    //check count of images
    this->actPackage = packageName;
    return;
}

void EntryHandler::loadLearnListPackage() {
    initExercisePackages();
    QList<Package> list = learnListManager->getPackages();
    for (int i=0; i < list.size();i++) {
        addExercisePackage(list.at(i).getPackageName(),list.at(i).getUnit());
    }
}




