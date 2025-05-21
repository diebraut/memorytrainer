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

// Klasse, die einen einzelnen Eintrag speichert
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

// Klasse, die eine Liste von Einträgen für ein bestimmtes packageName speichert
class Package {
public:
    Package(const QString &packageName) : packageName_(packageName) {}

    QString getPackageName() const { return packageName_; }

    // Return a non-const reference to allow modification
    QList<Entry>& getEntries() { return entries_; }
    const QList<Entry>& getEntries() const { return entries_; }  // Const version for read-only access

    void addEntry(const Entry &entry) { entries_.append(entry); }

private:
    QString packageName_;
    QList<Entry> entries_;
};

// Hauptklasse zur Verwaltung mehrerer Packages und zum Speichern/Laden in eine Datei
class ExerciceEntryManager : public QObject {  // Von QObject erben
    Q_OBJECT  // Q_OBJECT-Makro hinzufügen

public:
    ExerciceEntryManager(QString filename);

    static ExerciceEntryManager* getInstance();

    bool load();
    bool save();
    Q_INVOKABLE void putExerciceInList(const QString &packageName, int exercicePosition, bool reverse);
    Q_INVOKABLE bool removeExerciceFromList(const QString &packageName, int exercicePosition,bool reverse);
    Q_INVOKABLE bool entryExists(const QString &packageName, int position, bool reverse) const;
    Q_INVOKABLE QString getNameOfLearnList() {return  "Lernliste";}
    Q_INVOKABLE bool isLearnListEmpty() {return  (packages_.size() == 0);}
    Q_INVOKABLE int getTotalPositionCount() const;
    Q_INVOKABLE void clearAllEntries();

    QList<Package> getPackages() const { return packages_; }
    // New method to retrieve a package by name
    Package* getPackageByName(const QString &packageName);


private:
    static ExerciceEntryManager *instance;
    Environment env;
    QString filename_;
    QList<Package> packages_;

    Package* findOrCreatePackage(const QString &packageName);
    QString formatEntry(const Entry &entry) const;
};

#endif // EXERCICEENTRYMANAGER_H
