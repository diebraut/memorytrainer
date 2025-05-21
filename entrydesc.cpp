#include "entrydesc.h"

// Copy constructor
EntryDesc::EntryDesc(const EntryDesc& other)
    : mFrageSubjekt(other.mFrageSubjekt),
    mAntwortSubjekt(other.mAntwortSubjekt),
    mSubjektPrefixFrage(other.mSubjektPrefixFrage),
    mSubjektPrefixAntwort(other.mSubjektPrefixAntwort),
    mImageFilenameFrage(other.mImageFilenameFrage),
    mImageFilenameAntwort(other.mImageFilenameAntwort),
    mInfoUrlFrage(other.mInfoUrlFrage),
    mInfoUrlAntwort(other.mInfoUrlAntwort),
    mImageFrageAuthor(other.mImageFrageAuthor),
    mImageAntwortAuthor(other.mImageAntwortAuthor),
    mImageFrageLizenz(other.mImageFrageLizenz),
    mImageAntwortLizenz(other.mImageAntwortLizenz),
    mWikiPageFraVers(other.mWikiPageFraVers),
    mWikiPageAntVers(other.mWikiPageAntVers),
    mRecognizedState(other.mRecognizedState),
    mIdxActExercisePackages(other.mIdxActExercisePackages),
    mIsReverse(other.mIsReverse),
    mExcludeAereaList(other.mExcludeAereaList) {}

// Assignment operator
EntryDesc& EntryDesc::operator=(const EntryDesc& other) {
    if (this != &other) {
        mFrageSubjekt = other.mFrageSubjekt;
        mAntwortSubjekt = other.mAntwortSubjekt;
        mSubjektPrefixFrage = other.mSubjektPrefixFrage;
        mSubjektPrefixAntwort = other.mSubjektPrefixAntwort;
        mImageFilenameFrage = other.mImageFilenameFrage;
        mImageFilenameAntwort = other.mImageFilenameAntwort;
        mInfoUrlFrage = other.mInfoUrlFrage;
        mInfoUrlAntwort = other.mInfoUrlAntwort;
        mImageFrageAuthor = other.mImageFrageAuthor;
        mImageAntwortAuthor = other.mImageAntwortAuthor;
        mImageFrageLizenz = other.mImageFrageLizenz;
        mImageAntwortLizenz = other.mImageAntwortLizenz;
        mWikiPageFraVers = other.mWikiPageFraVers;
        mWikiPageAntVers = other.mWikiPageAntVers;
        mRecognizedState = other.mRecognizedState;
        mIdxActExercisePackages = other.mIdxActExercisePackages;
        mIsReverse = other.mIsReverse;
        mExcludeAereaList = other.mExcludeAereaList;
    }
    return *this;
}
