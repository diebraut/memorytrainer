#ifndef PACKAGEDESC_H
#define PACKAGEDESC_H

#pragma once
#include <QObject>
#include <QString>
#include <QMetaType>

#include "xmlparser.h"
#include "environment.h"

#include "xmlparser.h"

#include "exerciceentrymanager.h"

class PackagePartState {
public:
    // Felder
    bool active      = false;  // vormals QPair.first
    bool prioritized = false;  // NEU
    int  count       = 0;      // vormals QPair.second

    // Konstruktoren
    constexpr PackagePartState() noexcept = default;

    constexpr PackagePartState(bool active_,
                               bool prioritized_,
                               int  count_) noexcept
        : active(active_), prioritized(prioritized_), count(count_) {}

    // Vergleich (optional, praktisch für Tests)
    friend constexpr bool operator==(const PackagePartState& a,
                                     const PackagePartState& b) noexcept {
        return a.active == b.active &&
               a.prioritized == b.prioritized &&
               a.count == b.count;
    }
    friend constexpr bool operator!=(const PackagePartState& a,
                                     const PackagePartState& b) noexcept {
        return !(a == b);
    }
};

Q_DECLARE_METATYPE(PackagePartState)

class PackageDesc : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString packageName READ getPackageName CONSTANT)
    Q_PROPERTY(int exercizeUnit READ getExercizeUnit CONSTANT)
    Q_PROPERTY(QString uebungsTitel READ getUebungsTitel CONSTANT)
    Q_PROPERTY(QString frageType READ getFrageType CONSTANT)
    Q_PROPERTY(QString mainQuestion READ getMainQuestion CONSTANT)
    Q_PROPERTY(QString mainQuestionReverse READ getMainQuestionReverse CONSTANT)
    Q_PROPERTY(bool isXMLDescripted READ getIsXMLDescripted CONSTANT);
    Q_PROPERTY(bool displayExercizesInSequence READ getDisplayExercizesInSequence CONSTANT)
    Q_PROPERTY(bool hideAuthorByQuestion READ hideAuthorByQuestion CONSTANT)   // <<< NEU
    Q_PROPERTY(QString fullPathToPackage READ getFullPathToPackage CONSTANT)
    Q_PROPERTY(int mainQuestions READ sizeMainQuestions CONSTANT)
    Q_PROPERTY(int reverseQuestions READ sizeReverseQuestions CONSTANT)
    Q_PROPERTY(int displayQuestionOption READ getShowList CONSTANT)

public:
    explicit PackageDesc(QString packageNAME,int unit, bool customPackage,bool fromCustomPackageCreated, QObject *parent = nullptr);

    explicit PackageDesc(QString xmlPackagefile,int unit, QString packageName,QObject *parent = nullptr);

    // Copy constructor
    PackageDesc(const PackageDesc &other) : QObject(other.parent()) {
        this->frageType = other.frageType;
        this->exercizeUnit = other.exercizeUnit;
        this->uebungsTitel = other.uebungsTitel;
        this->packageName = other.packageName;
        this->mainQuestion = other.mainQuestion;
        this->mainQuestionReverse = other.mainQuestionReverse;
        this->displayExercizesInSequence = other.displayExercizesInSequence;
        this->hideAuthorByQuestion_ = other.hideAuthorByQuestion_;            // <<< NEU
        this->isXMLDescripted = other.isXMLDescripted;
        this->showList = other.showList;
        this->mainQuestions = other.mainQuestions;
        this->reverseQuestions = other.reverseQuestions;
        this->fullPathToPackage = other.fullPathToPackage;
        this->xmlParser = other.xmlParser;
        this->customPackage = other.customPackage;
        this->fromCustomPackageCreated = other.fromCustomPackageCreated;
    }

    // Assignment operator
    PackageDesc& operator=(const PackageDesc &other) {
        if (this != &other) {
            this->exercizeUnit = other.exercizeUnit;
            this->frageType = other.frageType;
            this->uebungsTitel = other.uebungsTitel;
            this->packageName = other.packageName;
            this->mainQuestion = other.mainQuestion;
            this->mainQuestionReverse = other.mainQuestionReverse;
            this->displayExercizesInSequence = other.displayExercizesInSequence;
            this->hideAuthorByQuestion_ = other.hideAuthorByQuestion_;
            this->isXMLDescripted = other.isXMLDescripted;
            this->showList = other.showList;
            this->fullPathToPackage = other.fullPathToPackage;
            this->mainQuestions = other.mainQuestions;
            this->reverseQuestions = other.reverseQuestions;
            this->xmlParser = other.xmlParser;
            this->customPackage = other.customPackage;
            this->fromCustomPackageCreated = other.fromCustomPackageCreated;
        }
        return *this;
    }

    // Copy constructor from a pointer
    PackageDesc(const PackageDesc* other) {
        if (other) {
            this->exercizeUnit = other->exercizeUnit;
            this->frageType = other->frageType;
            this->uebungsTitel = other->uebungsTitel;
            this->packageName = other->packageName;
            this->mainQuestion = other->mainQuestion;
            this->mainQuestionReverse = other->mainQuestionReverse;
            this->displayExercizesInSequence = other->displayExercizesInSequence;
            this->hideAuthorByQuestion_ = other->hideAuthorByQuestion_;
            this->isXMLDescripted = other->isXMLDescripted;
            this->showList = other->showList;
            this->fullPathToPackage = other->fullPathToPackage;
            this->mainQuestions = other->mainQuestions;
            this->reverseQuestions = other->reverseQuestions;
            this->xmlParser = other->xmlParser;
            this->customPackage = other->customPackage;
            this->fromCustomPackageCreated = other->fromCustomPackageCreated;
        }
    }

    enum DisplayOption {
        DISPLAY_MAIN = 0,
        DISPLAY_REVERSE = 1,
        DISPLAY_ALL = 2,
        DISPLAY_NOTHING = 3
    };
    Q_ENUM(DisplayOption)


    QString getPackageName() const {
        return packageName;
    }

    QString getUebungsTitel() const {
        return uebungsTitel;
    }

    QString getFrageType() const {
        return frageType;
    }

    int getExercizeUnit() const {
        return exercizeUnit;
    }

    QString getMainQuestion() const {
        return mainQuestion;
    }

    QString getMainQuestionReverse() const {
        return mainQuestionReverse;
    }

    QString getFullPathToPackage () const {
        return fullPathToPackage;
    }

    void setFullPathToPackage (QString fullPathToPackage) {
        this->fullPathToPackage = fullPathToPackage;
    }

    bool getDisplayExercizesInSequence() const  {
        return displayExercizesInSequence;
    }

    void setDisplayExercizesInSequence(bool inSequence)  {
        displayExercizesInSequence = inSequence;
    }

    bool hideAuthorByQuestion() const {
        return hideAuthorByQuestion_;
    }

    void setHideAuthorByQuestion(bool inHideAuthor) {
        hideAuthorByQuestion_ = inHideAuthor;
    }

    bool getIsXMLDescripted() const {
        return isXMLDescripted;
    }

    DisplayOption getShowList() const {
        return showList;
    }

    void setShowList(DisplayOption option) {
        showList = option;
    }

    int sizeMainQuestions() const {
        return mainQuestions;
    }

    int sizeReverseQuestions() const {
        return reverseQuestions;
    }

    bool isSinglePackageLearning() const {
        return  singlePackageLearning;
    }

    void setSinglePackageLearning(bool singlePackageLearning)  {
        this->singlePackageLearning = singlePackageLearning;
    }

    QList<PackagePartState> getPackageLearningParts() const {
        return this->packageLearningParts;
    }

    void setPackageLearningParts(const  QList<PackagePartState> &parts) {
        this->packageLearningParts = parts;
    }

    QString getSinglePackageLearningName() {
        return singlePackageLearningName;
    }

    bool isCustomPackage() const {
        return  customPackage;
    }

    bool isFromCustomPackageCreated() const {
        return fromCustomPackageCreated;
    }

    void setExercizeUnit(int unit) {
        exercizeUnit = unit;
    }

    LicenceInfo getLicenceInfo(int number,bool isReverse);

    void setSinglePackageLearning(bool activedSinglePackageLearning,const QList<int> &parts, QString packageName = "",int unit = 0);

    void setSinglePackageLearningPart(bool setToActive,int partIdx);

    void setSinglePackageLearningPartPrioritized(bool prioritized, int idx);


    bool isActiveItemFromLearningPackageList(int idxItem);

    bool isPrioritizedItemFromLearningPackageList(int idxItem);

    QList<EntryDesc *> getEntriesForList(QList<EntryDesc *> listEntries,int idxPackageList, QList<Entry> *filterEntries = NULL);

    int getCountEntries(DisplayOption dispOpt);
    int getCountEntries(XMLParser* parser,DisplayOption dispOpt);

    QString packageName;

private:
    int exercizeUnit = 0;
    QString frageType;
    QString uebungsTitel;
    QString mainQuestion;
    QString mainQuestionReverse;
    bool isXMLDescripted = false;
    bool displayExercizesInSequence;
    bool hideAuthorByQuestion_ = false;

    DisplayOption   showList;
    XMLParser *xmlParser = nullptr;
    XMLParser *getXMLParser(QString pathToXmlFile);
    Environment env;
    QString fullPathToPackage="";
    int reverseQuestions;
    int mainQuestions;

    bool                    singlePackageLearning = false;
    bool                    randomizeSinglePackages = true;
    QString                 singlePackageLearningName;
    int                     singlePackageLearningUnit;
    QList<PackagePartState> packageLearningParts;  // statt QList<QPair<bool,int>>

    // Komfort-APIs (neu), damit QML/DataModel bequem exklusiv priorisieren kann
    int prioritizedIndex() const;
    void setPrioritizedIndex(int idx);     // -1 => keine Priorisierung
    void clearPrioritization();
    bool customPackage = false;
    bool fromCustomPackageCreated = false;

    bool existPrioritizedPackagePart();
    QString getPackageXmlName(int unit);


};

Q_DECLARE_METATYPE(PackageDesc)

#endif // PACKAGEDESC_H
