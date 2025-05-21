#include "exerciceentrymanager.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>

ExerciceEntryManager::ExerciceEntryManager(QString exersizeListFullFilename)
    : exersizeListFullFilename_(exersizeListFullFilename) { // Setze den vollständigen Dateipfad in filename_

    // Datei laden, falls sie bereits existiert
    if (QFile::exists(exersizeListFullFilename_)) {
        if (!load()) { // Aufruf der bestehenden load-Funktion
            qDebug() << "Error: Failed to lo5ad existing file -> " << exersizeListFullFilename_;
        }
    } else {
        qDebug() << "Info: No existing file found. A new list will be created.";
    }
}

bool ExerciceEntryManager::load() {

    packages_.clear();
    QFile file(exersizeListFullFilename_);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Fehler beim Öffnen der Datei zum Laden:" << exersizeListFullFilename_;
        return false;
    }

    QTextStream in(&file);
    while (!in.atEnd()) {
        QString line = in.readLine().trimmed();
        if (line.startsWith("Package:")) {
            QString packageName = line.mid(QString("Package:").length()).trimmed();
            Package package(packageName);

            // Einträge dieses Packages laden
            while (!in.atEnd()) {
                line = in.readLine().trimmed();
                if (line.isEmpty() || line.startsWith("Package:")) break;

                QStringList parts = line.split(",");
                if (parts.size() == 2) {
                    int position = parts[0].toInt();
                    bool reverse = (parts[1] == "true");
                    package.addEntry(Entry(position, reverse));
                }
            }
            packages_.append(package);
        }
    }
    file.close();
    return true;
}


bool ExerciceEntryManager::save() {
    // Datei öffnen (im Schreibmodus, um vorhandene Inhalte zu überschreiben)
    QFile file(exersizeListFullFilename_);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Error: Unable to open file for writing -> " << exersizeListFullFilename_;
        return false;
    }

    QTextStream out(&file);

    // Wenn `packages_` Einträge enthält, speichere diese
    if (!packages_.isEmpty()) {
        for (const Package &package : packages_) {
            // Package-Überschrift schreiben
            out << "Package: " << package.getPackageName() << "\n";

            // Sortierte Einträge des Packages schreiben
            QList<Entry> sortedEntries = package.getEntries();
            std::sort(sortedEntries.begin(), sortedEntries.end(), [](const Entry &a, const Entry &b) {
                return a.getPosition() < b.getPosition();
            });

            for (const Entry &entry : sortedEntries) {
                out << formatEntry(entry) << "\n";
            }
            out << "\n";  // Leerzeile zwischen Packages
        }
    }

    // Datei schließen und Erfolg melden
    file.close();
    qDebug() << "Success: Packages saved to file -> " << exersizeListFullFilename_;
    return true;
}


QString ExerciceEntryManager::formatEntry(const Entry &entry) const {
    return QString::number(entry.getPosition()) + "," + (entry.isReverse() ? "true" : "false");
}

bool ExerciceEntryManager::removeExerciceFromList(const QString &packageName, int exercicePosition, bool reverse) {
    // Find the package by name
    for (int i = 0; i < packages_.size(); ++i) {
        if (packages_[i].getPackageName() == packageName) {
            Package &package = packages_[i];

            // Access the actual list of entries and find the entry with the specified position and reverse
            QList<Entry> &entries = package.getEntries();
            for (int j = 0; j < entries.size(); ++j) {
                if (entries[j].getPosition() == exercicePosition && entries[j].isReverse() == reverse) {
                    // Remove the specific entry
                    entries.removeAt(j);

                    // Check if the package is empty after removing the entry
                    if (entries.isEmpty()) {
                        packages_.removeAt(i);  // Remove the entire package if no entries remain
                        qDebug() << "Package" << packageName << "is empty and has been removed.";
                    }

                    // Save the changes immediately
                    save();
                    return true;  // Successfully removed
                }
            }

            qDebug() << "Entry with position" << exercicePosition << "and reverse" << reverse << "not found in package" << packageName;
            return false;  // Entry not found with matching position and reverse
        }
    }

    qDebug() << "Package" << packageName << "not found.";
    return false;  // Package not found
}


void ExerciceEntryManager::clearAllEntries() {
    // Alle Einträge aus der Liste entfernen
    packages_.clear();
    // Änderungen sofort in die Datei speichern
    save();
    qDebug() << "All entries have been cleared and saved to file -> " << exersizeListFullFilename_;
}

void ExerciceEntryManager::putExerciceInList(const QString &packageName, int exercicePosition, bool reverse,bool saveImmediately) {
    // Find or create the package
    Package* package = findOrCreatePackage(packageName);

    // Check if an entry with the same position and reverse already exists
    for (const Entry &entry : package->getEntries()) {
        if (entry.getPosition() == exercicePosition && entry.isReverse() == reverse) {
            qDebug() << "Duplicate entry ignored: position" << exercicePosition << "reverse" << reverse << "in package" << packageName;
            return;  // Duplicate found, do not add
        }
    }

    // Add new entry if no duplicate exists
    package->addEntry(Entry(exercicePosition, reverse));

    // Save changes immediately
    if (saveImmediately) save();
}

Package* ExerciceEntryManager::findOrCreatePackage(const QString &packageName) {
    for (Package &package : packages_) {
        if (package.getPackageName() == packageName) {
            return &package;  // Gefunden, Rückgabe des existierenden Package
        }
    }

    // Erstellen eines neuen Package, falls nicht vorhanden
    packages_.append(Package(packageName));
    return &packages_.last();
}

bool ExerciceEntryManager::entryExists(const QString &packageName, int position, bool reverse) const {
    // Find the package by name
    for (const Package &package : packages_) {
        if (package.getPackageName() == packageName) {
            // Search for an entry with the specified position and reverse values
            for (const Entry &entry : package.getEntries()) {
                if (entry.getPosition() == position && entry.isReverse() == reverse) {
                    return true;  // Entry found
                }
            }
            return false;  // Package found, but entry does not exist
        }
    }

    return false;  // Package not found
}

Package* ExerciceEntryManager::getPackageByName(const QString &packageName) {
    for (Package &package : packages_) {
        if (package.getPackageName() == packageName) {
            return &package;  // Return a pointer to the matching package
        }
    }
    return nullptr;  // No matching package found
}


int ExerciceEntryManager::getTotalPositionCount() const {
    int totalCount = 0;

    // Iterate through each package and count the entries
    for (const Package &package : packages_) {
        totalCount += package.getEntries().size();
    }

    return totalCount;
}


