#ifndef ENTRYDESC_H
#define ENTRYDESC_H

#include <QString>
#include <QMetaType>
#include <QVector>
#include <QSharedPointer>
#include <QVariant>
#include "excludeaerea.h"

class EntryDesc {
    Q_GADGET
    Q_PROPERTY(int exercizeNumber READ getExercizeNumber CONSTANT)
    Q_PROPERTY(QString frageSubjekt READ frageSubjekt CONSTANT)
    Q_PROPERTY(QString antwortSubjekt READ antwortSubjekt CONSTANT)
    Q_PROPERTY(QString subjektPrefixFrage READ subjektPrefixFrage CONSTANT)
    Q_PROPERTY(QString subjektPrefixAntwort READ subjektPrefixAntwort CONSTANT)
    Q_PROPERTY(QString imageFilenameFrage READ imageFilenameFrage CONSTANT)
    Q_PROPERTY(QString imageFilenameAntwort READ imageFilenameAntwort CONSTANT)
    Q_PROPERTY(bool recognizedState READ isRecognizedState CONSTANT)
    Q_PROPERTY(int idxActExercisePackages READ getIdxActExercisePackages CONSTANT)
    Q_PROPERTY(bool reverse READ isReverse CONSTANT)
    Q_PROPERTY(QVariantList excludeAerea READ excludeAereaAsVariant CONSTANT)

public:
    EntryDesc() = default;

    EntryDesc(QString imgFileName, int idxPackageList)
        : mImageFilenameFrage(imgFileName), mIdxActExercisePackages(idxPackageList)  {
        mIsReverse = false;
    }

    EntryDesc(
        const QString& frageSubjekt,
        const QString& antwortSubjekt,
        const QString& subjektPrefixFrage,
        const QString& subjektPrefixAntwort,
        const QString& imageFilenameFrage,
        const QString& imageFilenameAntwort,
        bool recognizedState,
        int idxActExercisePackages,
        const int exercizeNumber,
        bool isReverse,
        const QVector<QSharedPointer<ExcludeAerea>>& excludeAereaList
        ) : mFrageSubjekt(frageSubjekt),
        mAntwortSubjekt(antwortSubjekt),
        mSubjektPrefixFrage(subjektPrefixFrage),
        mSubjektPrefixAntwort(subjektPrefixAntwort),
        mImageFilenameFrage(imageFilenameFrage),
        mImageFilenameAntwort(imageFilenameAntwort),
        mRecognizedState(recognizedState),
        mIdxActExercisePackages(idxActExercisePackages),
        mExercizeNumber(exercizeNumber),
        mIsReverse(isReverse),
        mExcludeAereaList(excludeAereaList)
    {}

    // Copy constructor
    EntryDesc(const EntryDesc& other)
        : mFrageSubjekt(other.mFrageSubjekt),
        mAntwortSubjekt(other.mAntwortSubjekt),
        mSubjektPrefixFrage(other.mSubjektPrefixFrage),
        mSubjektPrefixAntwort(other.mSubjektPrefixAntwort),
        mImageFilenameFrage(other.mImageFilenameFrage),
        mImageFilenameAntwort(other.mImageFilenameAntwort),
        mRecognizedState(other.mRecognizedState),
        mIdxActExercisePackages(other.mIdxActExercisePackages),
        mExercizeNumber(other.mExercizeNumber),
        mIsReverse(other.mIsReverse),
        mExcludeAereaList(other.mExcludeAereaList) {}

    // Assignment operator
    EntryDesc& operator=(const EntryDesc& other) {
        if (this != &other) {
            mFrageSubjekt = other.mFrageSubjekt;
            mAntwortSubjekt = other.mAntwortSubjekt;
            mSubjektPrefixFrage = other.mSubjektPrefixFrage;
            mSubjektPrefixAntwort = other.mSubjektPrefixAntwort;
            mImageFilenameFrage = other.mImageFilenameFrage;
            mImageFilenameAntwort = other.mImageFilenameAntwort;
            mRecognizedState = other.mRecognizedState;
            mIdxActExercisePackages = other.mIdxActExercisePackages;
            mExercizeNumber = other.mExercizeNumber;
            mIsReverse = other.mIsReverse;
            mExcludeAereaList = other.mExcludeAereaList;
        }
        return *this;
    }

    // Getter-Methoden für die verbleibenden Eigenschaften
    QString frageSubjekt() const { return mFrageSubjekt; }
    QString antwortSubjekt() const { return mAntwortSubjekt; }
    QString subjektPrefixFrage() const { return mSubjektPrefixFrage; }
    QString subjektPrefixAntwort() const { return mSubjektPrefixAntwort; }
    QString imageFilenameFrage() const { return mImageFilenameFrage; }
    QString imageFilenameAntwort() const { return mImageFilenameAntwort; }
    bool isRecognizedState() const { return mRecognizedState; }
    int getIdxActExercisePackages() const { return mIdxActExercisePackages; }
    int getExercizeNumber() const { return mExercizeNumber; }
    bool isReverse() const { return mIsReverse; }

    QVariantList excludeAereaAsVariant() const {
        QVariantList variantList;
        for (const auto& ptr : mExcludeAereaList) {
            variantList.append(QVariant::fromValue(ptr.data()));
        }
        return variantList;
    }

    // Setter-Methoden für die verbleibenden Eigenschaften
    void setFrageSubjekt(const QString &frage) { mFrageSubjekt = frage; }
    void setAntwortSubjekt(const QString &antwort) { mAntwortSubjekt = antwort; }
    void setSubjektPrefixFrage(const QString &prefix) { mSubjektPrefixFrage = prefix; }
    void setSubjektPrefixAntwort(const QString &prefix) { mSubjektPrefixAntwort = prefix; }
    void setImageFilenameFrage(const QString &imageFilename) { mImageFilenameFrage = imageFilename; }
    void setImageFilenameAntwort(const QString &imageFilename) { mImageFilenameAntwort = imageFilename; }
    void setRecognizedState(bool state) { mRecognizedState = state; }
    void setIdxActExercisePackages(int idx) { mIdxActExercisePackages = idx; }
    void setExercizeNumber(int exercizeNumber) { mExercizeNumber = exercizeNumber; }
    void setReverse(bool reverse) { mIsReverse = reverse; }
    void setExcludeAerea(const QVector<QSharedPointer<ExcludeAerea>> &excludeAereaList) { mExcludeAereaList = excludeAereaList; }

private:
    QString mFrageSubjekt;
    QString mAntwortSubjekt;
    QString mSubjektPrefixFrage;
    QString mSubjektPrefixAntwort;
    QString mImageFilenameFrage;
    QString mImageFilenameAntwort;
    bool mRecognizedState = false;
    int  mIdxActExercisePackages = -1;
    int  mExercizeNumber;
    bool mIsReverse = false;
    QVector<QSharedPointer<ExcludeAerea>> mExcludeAereaList;
};

Q_DECLARE_METATYPE(EntryDesc)

#endif // ENTRYDESC_H
