import QtQuick 2.0
import Qt.labs.folderlistmodel 2.12


Item {

    // property to configure target dispatcher / logic

    id:dataModel

    // you can place getter functions here that do not modify the data
    // pages trigger write operations through logic signals only

    function debugPt () {
        return;
    }

    function debugPt01 () {
        return;
    }


    function init () {
        ImageHandler.init();
    }


    function randomizeEntryList () {
        ImageHandler.randomizeEntryList();
    }

    function setPlatform(isMobile) {

        return ImageHandler.setPlatform(isMobile);
    }

    function getActImageName() {

        return ImageHandler.imageName();
    }

    function getLastImageName() {

        return ImageHandler.imageNameLast();
    }

    function getActImageFileName() {

        return ImageHandler.imageFileName();
    }

    function getActPackageDescription() {
        return ImageHandler.getActPackageDescription();
    }

    function getActPackageDescriptionIdx(idx) {
        return ImageHandler.getActPackageDescriptionIdx(idx);
    }

    function setQuestionOptionInActPackageIdx(idx,option) {
        ImageHandler.setQuestionOptionInActPackageIdx(idx,option);
    }

    function setDisplayExercizesInSequenceInActPackageIdx(idx,inSequence) {
        ImageHandler.setDisplayExercizesInSequenceInActPackageIdx(idx,inSequence);
    }

    function hideAuthorByQuestionInActPackageIdx(idx,inSequence) {
        return ImageHandler.hideAuthorByQuestionInActPackageIdx(idx);
    }

    function getActEntryDescription() {
        return ImageHandler.getActEntryDescription();
    }

    function getActLicenceInfo() {
        return ImageHandler.getActLicenceInfo();
    }

    function countEntries() {
            return ImageHandler.getEntriesSize();
    }

    function setSaveToPackage(packagePath) {
            return ImageHandler.setSaveToPackage(packagePath);
    }

    function getEntryFilename(cnt) {
        return ImageHandler.getEntryFilename(cnt)
    }

    function deleteEntry(cnt) {
        return ImageHandler.deleteEntry(cnt)
    }

    function changeEntryName(cnt,newName) {
        return ImageHandler.changeEntryName(cnt,newName)
    }


    function getEntryName(cnt) {
        return ImageHandler.getEntryName(cnt)
    }

    function getMatchingEntry(pattern) {
        return ImageHandler.getMatchingEntry(pattern)
    }


    function getActPackage() {
        return ImageHandler.getActPackage();
    }

    function getEntriesSize() {
        return ImageHandler.getEntriesSize()
    }

    function isLastImage() {
        return _.m_IsLastImage;
    }

    function isFirstEntry() {
        return ImageHandler.isFirstEntry();
    }


    function existImage(imageName) {
        return ImageHandler.existImage(imageName);
    }


    function setEntryList(all,recognizedState,useEntryList) {
        return ImageHandler.setEntryList(all,recognizedState,useEntryList);
    }

    function saveLastPictureTaken(picureName,isWideFormat) {
        //console.log("saveLastPictureTaken(model)");
        return ImageHandler.saveLastPictureTaken(picureName,isWideFormat)
    }

    function setActEntryRecognizedState(state) {
        ImageHandler.setActEntryRecognizedState(state);
    }

    function setLastEntryRecognizedState(state) {
        ImageHandler.setLastEntryRecognizedState(state);
    }

    function getNotRecognizedEntries() {
        return ImageHandler.cntEntriesInRecognizedState(false);
    }

    function getRecognizedEntries() {
        return ImageHandler.cntEntriesInRecognizedState(true);
    }

    function getPackageEntries(packageName,isCustomPackage,selectOnlyMainQuestions) {
        return ImageHandler.getPackageEntries(packageName,isCustomPackage,selectOnlyMainQuestions)
    }

    function setNextQuestion(pictureName) {
        _.m_IsLastImage = ImageHandler.setNextQuestion(pictureName);
    }

    function getPackages(onlyXMLPackages,withCustomPackages) {
        return ImageHandler.getPackages(onlyXMLPackages,withCustomPackages);
    }

    function removeExercisePackage(packageName) {
        return ImageHandler.removeExercisePackage(packageName);
    }

    function addExercisePackage(packageName,customPackage) {
        return ImageHandler.addExercisePackage(packageName,customPackage);
    }

    function initExercisePackages() {
        return ImageHandler.initExercisePackages();
    }

    function loadPackage(packageName) {
        return ImageHandler.loadPackage(packageName);
    }

    function loadLearnListPackage() {
        return ImageHandler.loadLearnListPackage();
    }
    function copyToLearnList(entryPos) {
        return ImageHandler.copyToLearnList(entryPos);
    }

    function removeFromLearnList(entryName) {
        return ImageHandler.removeFromLearnList(entryName);
    }
    function getActEntryPos() {
        return ImageHandler.getActEntryPos();
    }

    function adjustEntryListWithLearnList() {
        ImageHandler.adjustEntryListWithLearnList();
    }

    function setSinglePackageLearningPart(activatePart,partIdx) {
        return ImageHandler.setSinglePackageLearningPart(activatePart,partIdx);
    }

    function setSinglePackageLearning(activatePackageLearning,listCntParts,packageName) {
        return ImageHandler.setSinglePackageLearning(activatePackageLearning,listCntParts,packageName);
    }

    function sizeActExercisePackages() {
        return ImageHandler.sizeActExercisePackages();
    }

    function getInstallablePackages() {
        return PackageProvider.getInstallablePackages();
    }

    function installPackage(packageName, resultText) {
        return PackageProvider.installPackage(packageName,resultText);
    }

    function createMixPackage(packageName,cntExercises,list,override,withReverseEntries,retInfo) {
        return PackageManager.createMixPackage(packageName,cntExercises,list,override,withReverseEntries,retInfo);
    }
    function removePackage(packageName,isCustomPackage,retInfo) {
        return PackageManager.removePackage(packageName,isCustomPackage,retInfo);
    }

    // private
    Item {
        id: _
        property bool m_IsLastImage: false
    }
}
