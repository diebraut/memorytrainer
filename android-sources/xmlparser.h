#ifndef XMLPARSER_H
#define XMLPARSER_H

#define XML_DESCRIPTION_FILENAME "package.xml"

#include <QDomDocument>
#include <QString>
#include <QList>
#include <QRect>
#include "entrydesc.h"
#include "licenceinfo.h"
#include "exerciceentrymanager.h"

class XMLParser {
public:
    XMLParser(const QString& xmlFilePath);
    QString getPfad() const;
    int countExercizeElements(QString exercizeType);
    QList<EntryDesc *> getExercizeList(QString exercizeType, int idxPackage, QList<EntryDesc *> listEntries, QList<Entry> *filterEntries = NULL);
    QString getÜbungsTitel() const;
    bool isSequential() const;
    bool existMainList() const;
    bool existReverseList() const;
    QString getFrageText() const;
    QString getFrageTextUmgekehrt() const;
    LicenceInfo getLicenceInfo(int number,bool isReverse) const;
    bool isValid() const { return valid_; }

    bool addMainUebungslisteIfNeeded(const QString &packageName, bool sequential, bool reverse, const QString &mainQuestion, const QString &reverseQuestion);
    bool addEntryToMainUebungsliste(const EntryDesc &entry);

private:
    QDomElement findExcerziseList(QString exercizeType) const;
    QList<QSharedPointer<ExcludeAerea>> parseExcludeAereaStr(const QString& excludeAereaStr);
    bool entryExistsWithPosition(QList<Entry> *entries, int position);

    QDomElement root_;
    QDomElement uebungenElement;
    bool valid_ = false;
    QDomDocument doc;  // Füge QDomDocument als Mitgliedsvariable hinzu

};

#endif // XMLPARSER_H
