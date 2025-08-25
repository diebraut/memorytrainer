#ifndef IMAGEHANDLER_H
#define IMAGEHANDLER_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QPair>
#include <QQmlEngine>

#include <QDir>

#include "entrydesc.h"
#include "environment.h"
#include "xmlparser.h"
#include "packagedesc.h"

#include "environment.h"

#include "learnlistentrymanager.h"


class EntryHandler : public QObject
{
    Q_OBJECT

public:

    static void registerSingleton(QQmlEngine *qmlEngine,QObject *parent=nullptr);

    Q_INVOKABLE QString imageName();
    Q_INVOKABLE QString imageNameLast();
    Q_INVOKABLE QString imageFileName();

    Q_INVOKABLE bool isFirstEntry();
    Q_INVOKABLE bool setNextQuestion(void);
    Q_INVOKABLE int setEntryList(bool all,bool inState,bool isLearnlist = false);

    Q_INVOKABLE void setSaveToPackage (QString packageName);

    Q_INVOKABLE int getPackageEntries(QString package,bool isCustomPackage = false,bool onlyMainEntries = false);

    Q_INVOKABLE void setActEntryRecognizedState(bool);
    Q_INVOKABLE void setLastEntryRecognizedState(bool state);
    Q_INVOKABLE int  cntEntriesInRecognizedState(bool state);

    Q_INVOKABLE bool saveLastPictureTaken (QString imgName,bool isWideformat);
    Q_INVOKABLE void setPlatform (bool isMobile);

    Q_INVOKABLE QString getEntryFilename (int cnt);
    Q_INVOKABLE QString getEntryName (int cnt);
    Q_INVOKABLE int getEntriesSize ();
    Q_INVOKABLE bool deleteEntry (int cnt);
    Q_INVOKABLE bool changeEntryName (int cnt,QString newName);
    Q_INVOKABLE bool existImage (QString imgName);

    Q_INVOKABLE void randomizeEntryList ();

    Q_INVOKABLE void triggerEvent(int customImageNr) {
        emit imageRemoved(customImageNr);
    }

    Q_INVOKABLE int addExercisePackage(QString packageName,bool isCustomPackage = false,bool isFromCustomPackageCreated = false);
    Q_INVOKABLE void removeExercisePackage(QString packageName);
    Q_INVOKABLE QList<PackageDesc *> initExercisePackages();
    Q_INVOKABLE QStringList getPackages(bool onlyXMLPackages = false,bool withCustomPackages = false);

    Q_INVOKABLE int loadPackage(QString packageName,bool isLearnList = false);

    Q_INVOKABLE void loadLearnListPackage();

    Q_INVOKABLE PackageDesc getActPackageDescription();

    Q_INVOKABLE PackageDesc getActPackageDescriptionIdx(int idx);

    Q_INVOKABLE void setQuestionOptionInActPackageIdx(int idx,PackageDesc::DisplayOption option);

    Q_INVOKABLE void setDisplayExercizesInSequenceInActPackageIdx(int idx,bool inSequence);

    Q_INVOKABLE bool hideAuthorByQuestionInActPackageIdx(int idx);

    Q_INVOKABLE EntryDesc getActEntryDescription();
    Q_INVOKABLE LicenceInfo getActLicenceInfo();

    Q_INVOKABLE int getActEntryPos();
    Q_INVOKABLE int getMatchingEntry(QString pattern);

    Q_INVOKABLE void setSinglePackageLearning(bool activedSinglePackageLearning,const QList<int> &parts, QString packageName = "");
    Q_INVOKABLE void setSinglePackageLearningPart(bool setToActive,int partIdx);

    Q_INVOKABLE int  sizeActExercisePackages();

    Q_INVOKABLE void adjustEntryListWithLearnList();


private slots:
    void SetLastPictureTaken(QImage *image,int capturedImageID);

private:
    explicit    EntryHandler(QObject *parent = nullptr, QQmlEngine *qmlEngine=nullptr);
    void        initEntryList(bool useLearnList = false);
    EntryDesc  *getEntryDesc(int cnt);
    int         isPackageInExersizeList(QString package);
    QString     getPackageName(int cnt);
    //int         setLearnList();
    void        putItemInEntryList(QString entryDir,int idxPackage,bool useLearnList = false);
    int         getIndexFromPackageList(QString packageName);
    XMLParser   *getXMLDescription(QString entryName);
    PackageDesc *getPackageDesc(QString packageName);
    PackageDesc *getPackageIsInPartedLearningMode();
    QStringList getTxtFilesWithoutSuffix(const QString &directoryName);

    void        addPackagesFromLearnList();

private:

    Environment env;
    QQmlEngine *qmlEngine=nullptr;
    QString     actPackage;
    QList<PackageDesc *> actExercisePackages;
    bool        actExercisePackagesChanged=false;

    bool        firstCall=true;


    EntryDesc m_entryDesc;

    //QString     m_entryName="nicht gesetzt set";
    //int         m_entryNamePackageIdx=-1;

    bool        m_actImgIsCustom=false;
    int         actImgIdx=0;

    QList<EntryDesc *> listEntries;
    int allAvailableEntrys = 0;

    QStringList listRemovedEntries;

    QImage *lastPictureTaken = nullptr;
    int     lastCapturedImageID  = 0;
    int     lastSavedImageID = -1;
    QString lastImageFilename;

    QStringList allEntryNames;

    bool isMobilePlatform = true;

    LearnListEntryManager *learnListManager;
    QList<Entry> getFilteredEntries(const QList<Entry> &entries, bool reversed);

    bool isEntryOnLearnList(EntryDesc *entry);

    int getPackageIndexInPackageList(QString packageName);

signals:
    void imageRemoved(int customImageNr);

};

#endif // IMAGEHANDLER
