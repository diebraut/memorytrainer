#ifndef EXERCICEENTRYMANAGER_H
#define EXERCICEENTRYMANAGER_H

#include <QObject>
#include <QString>
#include <QList>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>
#include "environment.h"

class Entry {
public:
    Entry(int position, bool reverse) : position_(position), reverse_(reverse) {}

    int getPosition() const { return position_; }
    bool isReverse() const { return reverse_; }

    void setPosition(int position) { position_ = position; }
    void setReverse(bool reverse) { reverse_ = reverse; }

private:
    int position_;
    bool reverse_;
};

class Package {
public:
    Package(const QString &packageName, int unit)
        : packageName_(packageName), unit_(unit) {}

    QString getPackageName() const { return packageName_; }
    int getUnit() const { return unit_; }

    QList<Entry>& getEntries() { return entries_; }
    const QList<Entry>& getEntries() const { return entries_; }
    void addEntry(const Entry &entry) { entries_.append(entry); }

private:
    QString packageName_;
    int unit_;
    QList<Entry> entries_;
};

class ExerciceEntryManager : public QObject {
    Q_OBJECT

public:
    ExerciceEntryManager(QString filenameList);

    bool load();
    bool save();

    Q_INVOKABLE void putExerciceInList(const QString &packageName,
                                       int unit,
                                       int exercicePosition,
                                       bool reverse,
                                       bool saveImmediately = true);

    Q_INVOKABLE bool removeExerciceFromList(const QString &packageName,
                                            int unit,
                                            int exercicePosition,
                                            bool reverse);

    Q_INVOKABLE bool entryExists(const QString &packageName,
                                 int unit,
                                 int position,
                                 bool reverse) const;

    Q_INVOKABLE QString getNameOfLearnList() { return "Lernliste"; }
    Q_INVOKABLE bool isLearnListEmpty() { return (packages_.size() == 0); }
    Q_INVOKABLE int getTotalPositionCount() const;
    Q_INVOKABLE void clearAllEntries();

    QList<Package> getPackages() const { return packages_; }

    Package* getPackageByName(const QString &packageName, int unit);

private:
    Environment     env;
    QString         exersizeListFullFilename_;
    QList<Package>  packages_;

    Package* findOrCreatePackage(const QString &packageName, int unit);
    QString  formatEntry(const Entry &entry) const;
};

#endif // EXERCICEENTRYMANAGER_H
