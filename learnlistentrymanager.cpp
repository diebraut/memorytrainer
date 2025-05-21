#include "learnlistentrymanager.h"

LearnListEntryManager* LearnListEntryManager::instance = nullptr;

LearnListEntryManager::LearnListEntryManager()
    : ExerciceEntryManager((Environment().getWritableDirectionForOS() + DEFAULT_PACK_DIR + DEFAULT_LEARNLIST_DIR + DEFAULT_LEARNLIST_FILE)),
    env() {  // Initialisierung von env nach Basiskonstruktor
    instance = this;  // Setze die statische Instanz
}

// Methoden, die direkt die Basisklassen-Implementierungen aufrufen
void LearnListEntryManager::putExerciceInList(const QString &packageName, int exercicePosition, bool reverse, bool saveImmediately) {
    ExerciceEntryManager::putExerciceInList(packageName, exercicePosition, reverse, saveImmediately);
}

bool LearnListEntryManager::removeExerciceFromList(const QString &packageName, int exercicePosition, bool reverse) {
    return ExerciceEntryManager::removeExerciceFromList(packageName, exercicePosition, reverse);
}

bool LearnListEntryManager::entryExists(const QString &packageName, int position, bool reverse) const {
    return ExerciceEntryManager::entryExists(packageName, position, reverse);
}

QString LearnListEntryManager::getNameOfLearnList() {
    return ExerciceEntryManager::getNameOfLearnList();
}

bool LearnListEntryManager::isLearnListEmpty() {
    return ExerciceEntryManager::isLearnListEmpty();
}

int LearnListEntryManager::getTotalPositionCount() const {
    return ExerciceEntryManager::getTotalPositionCount();
}


void LearnListEntryManager::clearAllEntries() {
    ExerciceEntryManager::clearAllEntries();
}

