#include "entrydesc.h"

EntryDesc::EntryDesc() = default;

EntryDesc::EntryDesc(QString imgFileName, int idxPackageList)
    : mImageFilenameFrage(imgFileName),
    mIdxActExercisePackages(idxPackageList)
{
    mIsReverse = false;
}

EntryDesc::EntryDesc(
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
    const QString& arrowDescFra,
    const QString& arrowDescAnt
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
    mArrowDescFra(arrowDescFra),
    mArrowDescAnt(arrowDescAnt)
{
}

EntryDesc::EntryDesc(const EntryDesc& other)
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
    mArrowDescFra(other.mArrowDescFra),
    mArrowDescAnt(other.mArrowDescAnt)
{
}

EntryDesc& EntryDesc::operator=(const EntryDesc& other)
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
        mArrowDescFra = other.mArrowDescFra;
        mArrowDescAnt = other.mArrowDescAnt;
    }
    return *this;
}

QString EntryDesc::frageSubjekt() const
{
    return mFrageSubjekt;
}

QString EntryDesc::antwortSubjekt() const
{
    return mAntwortSubjekt;
}

QString EntryDesc::subjektPrefixFrage() const
{
    return mSubjektPrefixFrage;
}

QString EntryDesc::subjektPrefixAntwort() const
{
    return mSubjektPrefixAntwort;
}

QString EntryDesc::imageFilenameFrage() const
{
    return mImageFilenameFrage;
}

QString EntryDesc::imageFilenameAntwort() const
{
    return mImageFilenameAntwort;
}

bool EntryDesc::isRecognizedState() const
{
    return mRecognizedState;
}

int EntryDesc::getIdxActExercisePackages() const
{
    return mIdxActExercisePackages;
}

int EntryDesc::getExercizeNumber() const
{
    return mExercizeNumber;
}

bool EntryDesc::isReverse() const
{
    return mIsReverse;
}

QVariantList EntryDesc::excludeAereaFraAsVariant() const
{
    QVariantList variantList;
    for (const auto& ptr : mExcludeAereaFraList) {
        variantList.append(QVariant::fromValue(ptr.data()));
    }
    return variantList;
}

QVariantList EntryDesc::excludeAereaAntAsVariant() const
{
    QVariantList variantList;
    for (const auto& ptr : mExcludeAereaAntList) {
        variantList.append(QVariant::fromValue(ptr.data()));
    }
    return variantList;
}

QString EntryDesc::arrowDescFra() const
{
    return mArrowDescFra;
}

QString EntryDesc::arrowDescAnt() const
{
    return mArrowDescAnt;
}

void EntryDesc::setFrageSubjekt(const QString &frage)
{
    mFrageSubjekt = frage;
}

void EntryDesc::setAntwortSubjekt(const QString &antwort)
{
    mAntwortSubjekt = antwort;
}

void EntryDesc::setSubjektPrefixFrage(const QString &prefix)
{
    mSubjektPrefixFrage = prefix;
}

void EntryDesc::setSubjektPrefixAntwort(const QString &prefix)
{
    mSubjektPrefixAntwort = prefix;
}

void EntryDesc::setImageFilenameFrage(const QString &imageFilename)
{
    mImageFilenameFrage = imageFilename;
}

void EntryDesc::setImageFilenameAntwort(const QString &imageFilename)
{
    mImageFilenameAntwort = imageFilename;
}

void EntryDesc::setRecognizedState(bool state)
{
    mRecognizedState = state;
}

void EntryDesc::setIdxActExercisePackages(int idx)
{
    mIdxActExercisePackages = idx;
}

void EntryDesc::setExercizeNumber(int exercizeNumber)
{
    mExercizeNumber = exercizeNumber;
}

void EntryDesc::setReverse(bool reverse)
{
    mIsReverse = reverse;
}

void EntryDesc::setExcludeAereaFra(const QVector<QSharedPointer<ExcludeAerea>> &excludeAereaList)
{
    mExcludeAereaFraList = excludeAereaList;
}

void EntryDesc::setExcludeAereaAnt(const QVector<QSharedPointer<ExcludeAerea>> &excludeAereaList)
{
    mExcludeAereaAntList = excludeAereaList;
}

void EntryDesc::setArrowDescFra(const QString &arrowDesc)
{
    mArrowDescFra = arrowDesc;
}

void EntryDesc::setArrowDescAnt(const QString &arrowDesc)
{
    mArrowDescAnt = arrowDesc;
}
