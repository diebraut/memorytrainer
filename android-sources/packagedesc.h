#ifndef PACKAGEDESC_H
#define PACKAGEDESC_H

#include <QObject>
#include <QString>
#include <QMetaType>

#include "xmlparser.h"
#include "environment.h"

#include "xmlparser.h"

#include "exerciceentrymanager.h"

class PackageDesc : public QObject {
    Q_GADGET
    Q_PROPERTY(QString packageName READ getPackageName CONSTANT)
    Q_PROPERTY(QString uebungsTitel READ getUebungsTitel CONSTANT)
    Q_PROPERTY(QString mainQuestion READ getMainQuestion CONSTANT)
    Q_PROPERTY(QString mainQuestionReverse READ getMainQuestionReverse CONSTANT)
    Q_PROPERTY(bool isXMLDescripted READ getIsXMLDescripted CONSTANT);
    Q_PROPERTY(bool displayExercizesInSequence READ getDisplayExercizesInSequence CONSTANT)
    Q_PROPERTY(QString fullPathToPackage READ getFullPathToPackage CONSTANT)
    Q_PROPERTY(int mainQuestions READ sizeMainQuestions CONSTANT)
    Q_PROPERTY(int reverseQuestions READ sizeReverseQuestions CONSTANT)
    Q_PROPERTY(int displayQuestionOption READ getShowList CONSTANT)

public:
    explicit PackageDesc(QObject *parent = nullptr) : QObject(parent) {}

    // Copy constructor
    PackageDesc(const PackageDesc &other) : QObject(other.parent()) {
        this->uebungsTitel = other.uebungsTitel;
        this->packageName = other.packageName;
        this->mainQuestion = other.mainQuestion;
        this->mainQuestionReverse = other.mainQuestionReverse;
        this->displayExercizesInSequence = other.displayExercizesInSequence;
        this->isXMLDescripted = other.isXMLDescripted;
        this->showList = other.showList;
        this->mainQuestions = other.mainQuestions;
        this->reverseQuestions = other.reverseQuestions;
        this->fullPathToPackage = other.fullPathToPackage;
        this->xmlParser = other.xmlParser;
    }

    // Assignment operator
    PackageDesc& operator=(const PackageDesc &other) {
        if (this != &other) {
            this->uebungsTitel = other.uebungsTitel;
            this->packageName = other.packageName;
            this->mainQuestion = other.mainQuestion;
            this->mainQuestionReverse = other.mainQuestionReverse;
            this->displayExercizesInSequence = other.displayExercizesInSequence;
            this->isXMLDescripted = other.isXMLDescripted;
            this->showList = other.showList;
            this->fullPathToPackage = other.fullPathToPackage;
            this->mainQuestions = other.mainQuestions;
            this->reverseQuestions = other.reverseQuestions;
            this->xmlParser = other.xmlParser;
        }
        return *this;
    }

    // Copy constructor from a pointer
    PackageDesc(const PackageDesc* other) {
        if (other) {
            this->uebungsTitel = other->uebungsTitel;
            this->packageName = other->packageName;
            this->mainQuestion = other->mainQuestion;
            this->mainQuestionReverse = other->mainQuestionReverse;
            this->displayExercizesInSequence = other->displayExercizesInSequence;
            this->isXMLDescripted = other->isXMLDescripted;
            this->showList = other->showList;
            this->fullPathToPackage = other->fullPathToPackage;
            this->mainQuestions = other->mainQuestions;
            this->reverseQuestions = other->reverseQuestions;
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

    QString getMainQuestion() const {
        return mainQuestion;
    }

    QString getMainQuestionReverse() const {
        return mainQuestionReverse;
    }

    QString getFullPathToPackage () const {
        return fullPathToPackage;
    }

    bool getDisplayExercizesInSequence() const  {
        return displayExercizesInSequence;
    }

    void setDisplayExercizesInSequence(bool inSequence)  {
        displayExercizesInSequence = inSequence;
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

    QString getSinglePackageLearningName() {
        return singlePackageLearningName;
    }

    LicenceInfo getLicenceInfo(int number,bool isReverse);

    void setSinglePackageLearning(bool activedSinglePackageLearning,const QList<int> &parts, QString packageName = "");

    void setSinglePackageLearningPart(bool setToActive,int partIdx);

    bool isActiveItemFromLearningPackageList(int idxItem);

    explicit PackageDesc(QString packageNAME, QObject *parent = nullptr);

    QList<EntryDesc *> getEntriesForList(QList<EntryDesc *> listEntries,int idxPackageList, QList<Entry> *filterEntries = NULL);

    int getCountEntries(DisplayOption dispOpt);

    QString packageName;

private:
    QString uebungsTitel;
    QString mainQuestion;
    QString mainQuestionReverse;
    bool isXMLDescripted = false;
    bool            displayExercizesInSequence;
    DisplayOption   showList;
    XMLParser *xmlParser = nullptr;
    XMLParser *getXMLDescription(QString packageName);
    Environment env;
    QString fullPathToPackage="";
    int reverseQuestions;
    int mainQuestions;

    bool                    singlePackageLearning = false;
    bool                    randomizeSinglePackages = true;
    QString                 singlePackageLearningName;
    QList<QPair<bool,int>>  packageLearningParts;


};

Q_DECLARE_METATYPE(PackageDesc)

#endif // PACKAGEDESC_H
