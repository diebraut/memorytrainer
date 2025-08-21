#include "xmlparser.h"
#include "entrydesc.h"
#include <QFile>
#include <QDebug>

typedef QSharedPointer<ExcludeAerea> ExcludeAereaPtr;
typedef QVector<ExcludeAereaPtr> ExcludeAereaList;  // oder QList<ExcludeAereaPtr>, falls du QList bevorzugst


XMLParser::XMLParser(const QString& xmlFilePath) {
    QFile file(xmlFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        // Fehlerbehandlung: Datei konnte nicht geöffnet werden
        return;
    }
    if (!doc.setContent(&file)) {
        // Fehlerbehandlung: XML-Inhalt konnte nicht geparst werden
        file.close();
        throw std::invalid_argument("xml description file nicht gültig");
    }

    root_ = doc.documentElement();
    uebungenElement = root_.firstChildElement("Übungen");
    file.close();
    this->valid_ = true; // Erfolgreich geladen und geparst
}

QString XMLParser::getPfad() const {
    return root_.attribute("pfad");
}

int XMLParser::countExercizeElements(QString exercizeType) {
    int retSize = uebungenElement.firstChildElement(exercizeType).elementsByTagName("Übung").size();
    return retSize;
}

QList<EntryDesc *> XMLParser::getExercizeList(QString exercizeType, int idxPackage, QList<EntryDesc *> listEntries, QList<Entry> *filterEntries) {
    QDomElement mainUebungslisteElement = uebungenElement.firstChildElement("MainÜbungsliste");
    QDomElement frageTextElement = mainUebungslisteElement.firstChildElement("FrageText");
    QDomElement frageTextUmgekehrtElement = mainUebungslisteElement.firstChildElement("FrageTextUmgekehrt");

    QDomElement childElement = mainUebungslisteElement.firstChildElement("Übung");
    while (!childElement.isNull()) {
        int exercizeNumber = childElement.attribute("nummer").toInt();
        bool isReverse = (exercizeType == "MainÜbungsliste") ? false : true;
        if (!filterEntries || (filterEntries && entryExistsWithPosition(filterEntries,exercizeNumber,isReverse))) {
            QString frageSubjekt = childElement.firstChildElement("FrageSubjekt").isNull() ? "" : childElement.firstChildElement("FrageSubjekt").text();
            QString antwortSubjekt = childElement.firstChildElement("AntwortSubjekt").isNull() ? "" : childElement.firstChildElement("AntwortSubjekt").text();
            QString subjectPrefixFrage = childElement.firstChildElement("SubjektPrefixFrage").isNull() ? "" : childElement.firstChildElement("SubjektPrefixFrage").text();
            QString subjectPrefixAntwort = childElement.firstChildElement("SubjektPrefixAntwort").isNull() ? "" : childElement.firstChildElement("SubjektPrefixAntwort").text();
            QString imageFilenameFrage = childElement.firstChildElement("ImagefileFrage").isNull() ? "" : childElement.firstChildElement("ImagefileFrage").text();
            QString imageFilenameAntwort = childElement.firstChildElement("ImagefileAntwort").isNull() ? "" : childElement.firstChildElement("ImagefileAntwort").text();

            bool recognizedState = false; // Adjust based on your needs
            QString excludeAereaStr;           
            if (!isReverse) {
                excludeAereaStr = childElement.firstChildElement("ExcludeAereaFra").isNull() ? "" : childElement.firstChildElement("ExcludeAereaFra").text();
            } else {
                excludeAereaStr = childElement.firstChildElement("ExcludeAereaAnt").isNull() ? "" : childElement.firstChildElement("ExcludeAereaAnt").text();
            }

            // Konvertiere den String in einen QVector<ExcludeAerea>
            ExcludeAereaList excludeAereaList = parseExcludeAereaStr(excludeAereaStr);

            EntryDesc* entry = new EntryDesc(
                (!isReverse)?frageSubjekt:antwortSubjekt,
                (!isReverse)?antwortSubjekt:frageSubjekt,
                (!isReverse)?subjectPrefixFrage:subjectPrefixAntwort,
                (!isReverse)?subjectPrefixAntwort:subjectPrefixFrage,
                (!isReverse)?imageFilenameFrage:imageFilenameAntwort,
                (!isReverse)?imageFilenameAntwort:imageFilenameFrage,
                recognizedState,
                idxPackage,
                exercizeNumber,
                isReverse,
                excludeAereaList
                );
            listEntries.append(entry);
        }
        childElement = childElement.nextSiblingElement();
    }

    return listEntries;
}

bool XMLParser::entryExistsWithPosition(QList<Entry> *entries, int position, bool isReverse) {
    for (const Entry entry : *entries) {
        if (entry.getPosition() == position && entry.isReverse() == isReverse) {
            return true;  // Found an entry with the specified position
        }
    }
    return false;  // No matching entry found
}


ExcludeAereaList XMLParser::parseExcludeAereaStr(const QString& excludeAereaStr)
{
    ExcludeAereaList list;

    if (excludeAereaStr.trimmed().isEmpty())
        return list;

    const QStringList areas = excludeAereaStr.split('|', Qt::SkipEmptyParts);

    for (const QString& areaStr : areas) {
        const QStringList coords = areaStr.split(',', Qt::KeepEmptyParts);
        if (coords.size() < 5)
            continue; // zu kurz

        const int x      = coords[0].toInt();
        const int y      = coords[1].toInt();
        const int width  = coords[2].toInt();
        const int height = coords[3].toInt();
        const int angle  = coords[4].toInt();

        // 6. Feld: Farbe als QString (CSS-Name oder Hex, z.B. "#ff0000")
        QString color = QStringLiteral("black");
        if (coords.size() > 5) {
            color = coords[5].trimmed();
            if (color.isEmpty())
                color = QStringLiteral("black");
        }

        // 7. Feld: Flag für „rectTranspWithLine“/Hintergrundrechteck als bool
        bool isBackgroundRectancle = false;
        if (coords.size() > 6) {
            const QString f = coords[6].trimmed().toLower();
            isBackgroundRectancle = (f == QLatin1String("1") ||
                                     f == QLatin1String("true") ||
                                     f == QLatin1String("yes"));
        }

        // Falls du den erweiterten ctor aus meinem Fix benutzt:
        ExcludeAereaPtr e(new ExcludeAerea(QRect(x, y, width, height),
                                           angle,
                                           color,
                                           isBackgroundRectancle));
        list.append(e);

    }

    return list;
}

QString XMLParser::getÜbungsTitel() const {
    QDomElement ÜbungenElement = uebungenElement.firstChildElement("Übungen");
    return ÜbungenElement.attribute("name");
}

bool  XMLParser::isSequential() const {
    return (uebungenElement.attribute("sequentiell") == "true")?true:false;
}

bool XMLParser::existMainList() const {
    if (uebungenElement.elementsByTagName("MainÜbungsliste").count() > 0) {
        return true;
    }
    return false;
}

bool XMLParser::existReverseList() const {

    QDomElement mainUbungsliste = findExcerziseList("MainÜbungsliste");
    if (!mainUbungsliste.isNull()) {
        QDomElement frageText = mainUbungsliste.firstChildElement("FrageTextUmgekehrt");
        if (!frageText.isNull()) {
            return (frageText.text().trimmed().size() > 0)?true:false ;
        }
    }
    return false;
}

QString XMLParser::getFrageText() const {
    QDomElement mainUbungsliste = findExcerziseList("MainÜbungsliste");
    if (!mainUbungsliste.isNull()) {
        QDomElement frageText = mainUbungsliste.firstChildElement("FrageText");
        if (!frageText.isNull()) {
            return frageText.text();
        }
    }
    return QString();
}

QString XMLParser::getFrageTextUmgekehrt() const {
    QDomElement mainUbungsliste = findExcerziseList("MainÜbungsliste");
    if (!mainUbungsliste.isNull()) {
        QDomElement frageText = mainUbungsliste.firstChildElement("FrageTextUmgekehrt");
        if (!frageText.isNull()) {
            return frageText.text();
        }
    }
    return QString();
}


QDomElement XMLParser::findExcerziseList(QString exercizeType) const {
    QDomElement mainUbungsliste;
    QDomNodeList ubungenList = root_.elementsByTagName(exercizeType);
    if (ubungenList.size() > 0) {
        mainUbungsliste = ubungenList.at(0).toElement();
    }
    return mainUbungsliste;
}

LicenceInfo XMLParser::getLicenceInfo(int number,bool isReverse) const {
    // Finde alle <Übung> Elemente unterhalb von <Übungen>
    QDomNodeList exerciseList = uebungenElement.elementsByTagName("Übung");

    // Suche nach dem <Übung> Element mit dem Attribut nummer == number
    for (int i = 0; i < exerciseList.size(); ++i) {
        QDomElement exerciseElement = exerciseList.at(i).toElement();
        if (exerciseElement.attribute("nummer").toInt() == number) {
            // Erstelle ein LicenceInfo-Objekt und fülle es mit den entsprechenden Werten
            LicenceInfo licenceInfo;

            // Lese die verschiedenen Elemente und setze sie im LicenceInfo-Objekt
            licenceInfo.setImageFrageAuthor((!isReverse)?exerciseElement.firstChildElement("ImageFrageAuthor").text()
                                                        :exerciseElement.firstChildElement("ImageAntwortAuthor").text());
            licenceInfo.setImageFrageLizenz((!isReverse)?exerciseElement.firstChildElement("ImageFrageLizenz").text()
                                                        :exerciseElement.firstChildElement("ImageAntwortLizenz").text());
            licenceInfo.setImageAntwortAuthor((!isReverse)?exerciseElement.firstChildElement("ImageAntwortAuthor").text()
                                                          :exerciseElement.firstChildElement("ImageFrageAuthor").text());
            licenceInfo.setImageAntwortLizenz((!isReverse)?exerciseElement.firstChildElement("ImageAntwortLizenz").text()
                                                          :exerciseElement.firstChildElement("ImageFrageLizenz").text());
            licenceInfo.setImageFrageBildDescription((!isReverse)?exerciseElement.firstChildElement("ImageFrageBildDescription").text()
                                                      :exerciseElement.firstChildElement("ImageAntwortBildDescription").text());
            licenceInfo.setImageAntwortBildDescription((!isReverse)?exerciseElement.firstChildElement("ImageAntwortBildDescription").text()
                                                                   :exerciseElement.firstChildElement("ImageFrageBildDescription").text());
            licenceInfo.setImageFrageUrl((!isReverse)?exerciseElement.firstChildElement("ImageFrageUrl").text()
                                                     :exerciseElement.firstChildElement("ImageAntwortUrl").text());
            licenceInfo.setImageAntwortUrl((!isReverse)?exerciseElement.firstChildElement("ImageAntwortUrl").text()
                                                       :exerciseElement.firstChildElement("ImageFrageUrl").text());
            // Setze InfoURLFrage und InfoURLAntwort
            licenceInfo.setInfoURLFrage((!isReverse)?exerciseElement.firstChildElement("InfoURLFrage").text()
                                                    :exerciseElement.firstChildElement("InfoURLAntwort").text());
            licenceInfo.setInfoURLAntwort((!isReverse)?exerciseElement.firstChildElement("InfoURLAntwort").text()
                                                      :exerciseElement.firstChildElement("InfoURLFrage").text());

            // Gib das gefüllte LicenceInfo-Objekt zurück
            return licenceInfo;
        }
    }

    // Wenn keine Übung mit der angegebenen Nummer gefunden wurde, gib ein leeres LicenceInfo zurück
    return LicenceInfo();
}

bool XMLParser::addMainUebungslisteIfNeeded(const QString &packageName, bool sequential, bool reverse, const QString &mainQuestion, const QString &reverseQuestion) {
    QDomElement root = root_;
    QDomNodeList existingUebungen = root.elementsByTagName("Übungen");

    // Prüfen, ob <Übungen> mit dem Attribut name=packageName existiert
    for (int i = 0; i < existingUebungen.size(); ++i) {
        QDomElement elem = existingUebungen.at(i).toElement();
        if (elem.attribute("name") == packageName) {
            // <MainÜbungsliste> prüfen oder hinzufügen
            if (elem.elementsByTagName("MainÜbungsliste").isEmpty()) {
                QDomElement mainListElem = doc.createElement("MainÜbungsliste");
                QDomElement frageTextElem = doc.createElement("FrageText");
                frageTextElem.appendChild(doc.createTextNode(mainQuestion));
                mainListElem.appendChild(frageTextElem);

                QDomElement frageTextUmgekehrtElem = doc.createElement("FrageTextUmgekehrt");
                frageTextUmgekehrtElem.appendChild(doc.createTextNode(reverseQuestion));
                mainListElem.appendChild(frageTextUmgekehrtElem);

                elem.appendChild(mainListElem);
            }
            return true;
        }
    }

    // <Übungen> existiert nicht; neu erstellen
    QDomElement uebungenElem = doc.createElement("Übungen");
    uebungenElem.setAttribute("name", packageName);
    uebungenElem.setAttribute("sequentiell", sequential ? "true" : "false");
    uebungenElem.setAttribute("umgekehrt", reverse ? "true" : "false");

    QDomElement mainListElem = doc.createElement("MainÜbungsliste");
    QDomElement frageTextElem = doc.createElement("FrageText");
    frageTextElem.appendChild(doc.createTextNode(mainQuestion));
    mainListElem.appendChild(frageTextElem);

    QDomElement frageTextUmgekehrtElem = doc.createElement("FrageTextUmgekehrt");
    frageTextUmgekehrtElem.appendChild(doc.createTextNode(reverseQuestion));
    mainListElem.appendChild(frageTextUmgekehrtElem);

    uebungenElem.appendChild(mainListElem);
    root.appendChild(uebungenElem);

    return true;
}

bool XMLParser::addEntryToMainUebungsliste(const EntryDesc &entry) {
    QDomElement mainListElem = root_.firstChildElement("Übungen").firstChildElement("MainÜbungsliste");

    if (mainListElem.isNull()) {
        qWarning() << "MainÜbungsliste fehlt. Bitte zuerst addMainUebungslisteIfNeeded aufrufen.";
        return false;
    }

    // Bestimme die laufende Nummer für den neuen Eintrag
    int nextNumber = mainListElem.elementsByTagName("Übung").size() + 1;

    QDomElement uebungElem = doc.createElement("Übung");
    uebungElem.setAttribute("nummer", nextNumber);  // Setze die laufende Nummer

    // Erstelle die Unterelemente und fülle sie mit den Werten aus EntryDesc
    QDomElement frageSubjektElem = doc.createElement("FrageSubjekt");
    frageSubjektElem.appendChild(doc.createTextNode(entry.frageSubjekt()));
    uebungElem.appendChild(frageSubjektElem);

    QDomElement antwortSubjektElem = doc.createElement("AntwortSubjekt");
    antwortSubjektElem.appendChild(doc.createTextNode(entry.antwortSubjekt()));
    uebungElem.appendChild(antwortSubjektElem);

    QDomElement subjektPrefixFrageElem = doc.createElement("SubjektPrefixFrage");
    subjektPrefixFrageElem.appendChild(doc.createTextNode(entry.subjektPrefixFrage()));
    uebungElem.appendChild(subjektPrefixFrageElem);

    QDomElement subjektPrefixAntwortElem = doc.createElement("SubjektPrefixAntwort");
    subjektPrefixAntwortElem.appendChild(doc.createTextNode(entry.subjektPrefixAntwort()));
    uebungElem.appendChild(subjektPrefixAntwortElem);

    QDomElement imageFilenameFrageElem = doc.createElement("ImagefileFrage");
    imageFilenameFrageElem.appendChild(doc.createTextNode(entry.imageFilenameFrage()));
    uebungElem.appendChild(imageFilenameFrageElem);

    QDomElement imageFilenameAntwortElem = doc.createElement("ImagefileAntwort");
    imageFilenameAntwortElem.appendChild(doc.createTextNode(entry.imageFilenameAntwort()));
    uebungElem.appendChild(imageFilenameAntwortElem);

    // Füge den neuen Eintrag <Übung> der <MainÜbungsliste> hinzu
    mainListElem.appendChild(uebungElem);

    return true;
}

