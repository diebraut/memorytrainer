#include "exerciceentrymanager.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QDir>

ExerciceEntryManager::ExerciceEntryManager(QString exersizeListFullFilename)
    : exersizeListFullFilename_(exersizeListFullFilename)
{
    if (QFile::exists(exersizeListFullFilename_)) {
        if (!load()) {
            qDebug() << "Error: Failed to load existing file -> " << exersizeListFullFilename_;
        }
    } else {
        qDebug() << "Info: No existing file found. A new list will be created.";
    }
}

bool ExerciceEntryManager::load()
{
    packages_.clear();

    QFile file(exersizeListFullFilename_);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Fehler beim Öffnen der Datei zum Laden:" << exersizeListFullFilename_;
        return false;
    }

    QTextStream in(&file);

    Package currentPackage("", 0);
    bool hasCurrentPackage = false;

    auto flushCurrentPackage = [&]() {
        if (hasCurrentPackage) {
            packages_.append(currentPackage);
            hasCurrentPackage = false;
        }
    };

    while (!in.atEnd()) {
        const QString line = in.readLine().trimmed();

        if (line.isEmpty()) {
            flushCurrentPackage();
            continue;
        }

        if (line.startsWith("Package:")) {
            // Vorheriges Paket abschließen
            flushCurrentPackage();

            const QString packageLine =
                line.mid(QString("Package:").length()).trimmed();

            QString packageName;
            int unit = 0;

            // Neues Format: Package: name,unit
            // Altes Format:  Package: name
            const QStringList headerParts = packageLine.split(",");

            if (!headerParts.isEmpty()) {
                packageName = headerParts[0].trimmed();
            }

            if (headerParts.size() >= 2) {
                bool ok = false;
                const int parsedUnit = headerParts[1].trimmed().toInt(&ok);
                if (ok) {
                    unit = parsedUnit;
                }
            }

            currentPackage = Package(packageName, unit);
            hasCurrentPackage = true;
            continue;
        }

        // Eintragszeile nur verarbeiten, wenn bereits ein Package aktiv ist
        if (!hasCurrentPackage)
            continue;

        const QStringList parts = line.split(",");
        if (parts.size() != 2)
            continue;

        bool okPos = false;
        const int position = parts[0].trimmed().toInt(&okPos);
        if (!okPos)
            continue;

        const QString reverseStr = parts[1].trimmed().toLower();
        const bool reverse = (reverseStr == "true");

        currentPackage.addEntry(Entry(position, reverse));
    }

    // Letztes Paket übernehmen
    flushCurrentPackage();

    file.close();
    return true;
}


bool ExerciceEntryManager::save()
{
    QFile file(exersizeListFullFilename_);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Error: Unable to open file for writing -> " << exersizeListFullFilename_;
        return false;
    }

    QTextStream out(&file);

    for (const auto &package : std::as_const(packages_)) {
        out << "Package: "
            << package.getPackageName()
            << "," << package.getUnit()
            << "\n";

        QList<Entry> sortedEntries = package.getEntries();
        std::sort(sortedEntries.begin(), sortedEntries.end(),
                  [](const Entry &a, const Entry &b) {
                      return a.getPosition() < b.getPosition();
                  });

        for (const Entry &entry : sortedEntries) {
            out << formatEntry(entry) << "\n";
        }

        out << "\n";
    }

    file.close();
    qDebug() << "Success: Packages saved to file -> " << exersizeListFullFilename_;
    return true;
}

QString ExerciceEntryManager::formatEntry(const Entry &entry) const
{
    return QString::number(entry.getPosition()) + "," + (entry.isReverse() ? "true" : "false");
}

bool ExerciceEntryManager::removeExerciceFromList(const QString &packageName,
                                                  int unit,
                                                  int exercicePosition,
                                                  bool reverse)
{
    for (int i = 0; i < packages_.size(); ++i) {
        if (packages_[i].getPackageName() == packageName &&
            packages_[i].getUnit() == unit) {

            Package &package = packages_[i];
            QList<Entry> &entries = package.getEntries();

            for (int j = 0; j < entries.size(); ++j) {
                if (entries[j].getPosition() == exercicePosition &&
                    entries[j].isReverse() == reverse) {

                    entries.removeAt(j);

                    if (entries.isEmpty()) {
                        packages_.removeAt(i);
                        qDebug() << "Package" << packageName << "unit" << unit
                                 << "is empty and has been removed.";
                    }

                    save();
                    return true;
                }
            }

            qDebug() << "Entry with position" << exercicePosition
                     << "and reverse" << reverse
                     << "not found in package" << packageName
                     << "unit" << unit;
            return false;
        }
    }

    qDebug() << "Package" << packageName << "unit" << unit << "not found.";
    return false;
}

void ExerciceEntryManager::clearAllEntries()
{
    packages_.clear();
    save();
    qDebug() << "All entries have been cleared and saved to file -> " << exersizeListFullFilename_;
}

void ExerciceEntryManager::putExerciceInList(const QString &packageName,
                                             int unit,
                                             int exercicePosition,
                                             bool reverse,
                                             bool saveImmediately)
{
    Package* package = findOrCreatePackage(packageName, unit);

    for (const Entry &entry : package->getEntries()) {
        if (entry.getPosition() == exercicePosition &&
            entry.isReverse() == reverse) {
            qDebug() << "Duplicate entry ignored: position" << exercicePosition
                     << "reverse" << reverse
                     << "in package" << packageName
                     << "unit" << unit;
            return;
        }
    }

    package->addEntry(Entry(exercicePosition, reverse));

    if (saveImmediately)
        save();
}

Package* ExerciceEntryManager::findOrCreatePackage(const QString &packageName, int unit)
{
    for (Package &package : packages_) {
        if (package.getPackageName() == packageName &&
            package.getUnit() == unit) {
            return &package;
        }
    }

    packages_.append(Package(packageName, unit));
    return &packages_.last();
}

bool ExerciceEntryManager::entryExists(const QString &packageName,
                                       int unit,
                                       int position,
                                       bool reverse) const
{
    for (const Package &package : packages_) {
        if (package.getPackageName() == packageName &&
            package.getUnit() == unit) {

            for (const Entry &entry : package.getEntries()) {
                if (entry.getPosition() == position &&
                    entry.isReverse() == reverse) {
                    return true;
                }
            }
            return false;
        }
    }

    return false;
}

Package* ExerciceEntryManager::getPackageByName(const QString &packageName, int unit)
{
    for (Package &package : packages_) {
        if (package.getPackageName() == packageName &&
            package.getUnit() == unit) {
            return &package;
        }
    }
    return nullptr;
}

int ExerciceEntryManager::getTotalPositionCount() const
{
    int totalCount = 0;

    for (const Package &package : packages_) {
        totalCount += package.getEntries().size();
    }

    return totalCount;
}
