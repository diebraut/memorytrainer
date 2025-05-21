#ifndef LEARNLISTENTRYMANAGER_H
#define LEARNLISTENTRYMANAGER_H

#include "exerciceentrymanager.h"
#include "environment.h"

class LearnListEntryManager : public ExerciceEntryManager {
    Q_OBJECT

public:
    explicit LearnListEntryManager();
    static LearnListEntryManager* getInstance() {return instance;};

    // Q_INVOKABLE Methoden
    Q_INVOKABLE void putExerciceInList(const QString &packageName, int exercicePosition, bool reverse, bool saveImmediately = true);
    Q_INVOKABLE bool removeExerciceFromList(const QString &packageName, int exercicePosition, bool reverse);
    Q_INVOKABLE bool entryExists(const QString &packageName, int position, bool reverse) const;
    Q_INVOKABLE QString getNameOfLearnList();
    Q_INVOKABLE bool isLearnListEmpty();
    Q_INVOKABLE int getTotalPositionCount() const;
    Q_INVOKABLE void clearAllEntries();
private:
    static LearnListEntryManager *instance;
    Environment env;

};

#endif // LEARNLISTENTRYMANAGER_H
