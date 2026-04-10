#ifndef ENTRYDESC_H
#define ENTRYDESC_H

#include <QString>
#include <QMetaType>
#include <QVector>
#include <QSharedPointer>
#include <QVariant>

#include "excludeaerea.h"
#include "arrowdesc.h"

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

    Q_PROPERTY(QVariantList excludeAereaFra READ excludeAereaFraAsVariant CONSTANT)
    Q_PROPERTY(QVariantList excludeAereaAnt READ excludeAereaAntAsVariant CONSTANT)
    Q_PROPERTY(QVariantList arrowDescFra READ arrowDescFraAsVariant CONSTANT)
    Q_PROPERTY(QVariantList arrowDescAnt READ arrowDescAntAsVariant CONSTANT)

public:
    EntryDesc() = default;

    EntryDesc(QString imgFileName, int idxPackageList)
        : mImageFilenameFrage(imgFileName),
        mIdxActExercisePackages(idxPackageList)
    {
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
        int exercizeNumber,
        bool isReverse,
        const QVector<QSharedPointer<ExcludeAerea>>& excludeAereaFraList,
        const QVector<QSharedPointer<ExcludeAerea>>& excludeAereaAntList,
        const QVector<QSharedPointer<ArrowDesc>>& arrowDescFraList,
        const QVector<QSharedPointer<ArrowDesc>>& arrowDescAntList
        )
        : mFrageSubjekt(frageSubjekt),
        mAntwortSubjekt(antwortSubjekt),
        mSubjektPrefixFrage(subjektPrefixFrage),
        mSubjektPrefixAntwort(subjektPrefixAntwort),
        mImageFilenameFrage(imageFilenameFrage),
        mImageFilenameAntwort(imageFilenameAntwort),
        mRecognizedState(recognizedState),
        mIdxActExercisePackages(idxActExercisePackages),
        mExercizeNumber(exercizeNumber),
        mIsReverse(isReverse),
        mExcludeAereaFraList(excludeAereaFraList),
        mExcludeAereaAntList(excludeAereaAntList),
        mArrowDescFraList(arrowDescFraList),
        mArrowDescAntList(arrowDescAntList)
    {}

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
        mExcludeAereaFraList(other.mExcludeAereaFraList),
        mExcludeAereaAntList(other.mExcludeAereaAntList),
        mArrowDescFraList(other.mArrowDescFraList),
        mArrowDescAntList(other.mArrowDescAntList)
    {}

    EntryDesc& operator=(const EntryDesc& other)
    {
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
            mExcludeAereaFraList = other.mExcludeAereaFraList;
            mExcludeAereaAntList = other.mExcludeAereaAntList;
            mArrowDescFraList = other.mArrowDescFraList;
            mArrowDescAntList = other.mArrowDescAntList;
        }
        return *this;
    }

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

    QVariantList excludeAereaFraAsVariant() const
    {
        QVariantList variantList;
        for (const auto& ptr : mExcludeAereaFraList) {
            variantList.append(QVariant::fromValue(ptr.data()));
        }
        return variantList;
    }

    QVariantList excludeAereaAntAsVariant() const
    {
        QVariantList variantList;
        for (const auto& ptr : mExcludeAereaAntList) {
            variantList.append(QVariant::fromValue(ptr.data()));
        }
        return variantList;
    }

    QVariantList arrowDescFraAsVariant() const
    {
        QVariantList variantList;
        for (const auto& ptr : mArrowDescFraList) {
            variantList.append(QVariant::fromValue(ptr.data()));
        }
        return variantList;
    }

    QVariantList arrowDescAntAsVariant() const
    {
        QVariantList variantList;
        for (const auto& ptr : mArrowDescAntList) {
            variantList.append(QVariant::fromValue(ptr.data()));
        }
        return variantList;
    }

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

    void setExcludeAereaFra(const QVector<QSharedPointer<ExcludeAerea>> &excludeAereaList)
    {
        mExcludeAereaFraList = excludeAereaList;
    }

    void setExcludeAereaAnt(const QVector<QSharedPointer<ExcludeAerea>> &excludeAereaList)
    {
        mExcludeAereaAntList = excludeAereaList;
    }

    void setArrowDescFra(const QVector<QSharedPointer<ArrowDesc>> &arrowDescList)
    {
        mArrowDescFraList = arrowDescList;
    }

    void setArrowDescAnt(const QVector<QSharedPointer<ArrowDesc>> &arrowDescList)
    {
        mArrowDescAntList = arrowDescList;
    }

private:
    QString mFrageSubjekt;
    QString mAntwortSubjekt;
    QString mSubjektPrefixFrage;
    QString mSubjektPrefixAntwort;
    QString mImageFilenameFrage;
    QString mImageFilenameAntwort;
    bool mRecognizedState = false;
    int  mIdxActExercisePackages = -1;
    int  mExercizeNumber = 0;
    bool mIsReverse = false;

    QVector<QSharedPointer<ExcludeAerea>> mExcludeAereaFraList;
    QVector<QSharedPointer<ExcludeAerea>> mExcludeAereaAntList;
    QVector<QSharedPointer<ArrowDesc>> mArrowDescFraList;
    QVector<QSharedPointer<ArrowDesc>> mArrowDescAntList;
};

Q_DECLARE_METATYPE(EntryDesc)

#endif // ENTRYDESC_H
