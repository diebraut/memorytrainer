#include "XMLParser.h"
#include "entrydesc.h"
#include <QFile>
#include <QDebug>

XMLParser::XMLParser(const QString& xmlFilePath) {
    QFile file(xmlFilePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        // Fehlerbehandlung: Datei konnte nicht geöffnet werden
        throw std::invalid_argument("keine xml description file vorhanden");
    }

    QDomDocument doc;
    if (!doc.setContent(&file)) {
        // Fehlerbehandlung: XML-Inhalt konnte nicht geparst werden
        file.close();
        throw std::invalid_argument("xml description file nicht gültig");
    }

    root_ = doc.documentElement();
    uebungenElement = root_.firstChildElement("Übungen");
    file.close();
}

QString XMLParser::getPfad() const {
    return root_.attribute("pfad");
}

int XMLParser::countExercizeElements(QString exercizeType) {
    int retSize = uebungenElement.firstChildElement(exercizeType).elementsByTagName("Übung").size();
    return retSize;
}

QList<EntryDesc *> XMLParser::getExercizeList(QString exercizeType, int idxPackage, QList<EntryDesc *> listEntries) {
    QDomElement mainUebungslisteElement = uebungenElement.firstChildElement("MainÜbungsliste");
    QDomElement frageTextElement = mainUebungslisteElement.firstChildElement("FrageText");
    QDomElement frageTextUmgekehrtElement = mainUebungslisteElement.firstChildElement("FrageTextUmgekehrt");

    QDomElement childElement = mainUebungslisteElement.firstChildElement("Übung");
    while (!childElement.isNull()) {
        QString frageSubjekt = childElement.firstChildElement("FrageSubjekt").isNull() ? "" : childElement.firstChildElement("FrageSubjekt").text();
        QString antwortSubjekt = childElement.firstChildElement("AntwortSubjekt").isNull() ? "" : childElement.firstChildElement("AntwortSubjekt").text();
        QString subjectPrefixFrage = childElement.firstChildElement("SubjektPrefixFrage").isNull() ? "" : childElement.firstChildElement("SubjektPrefixFrage").text();
        QString subjectPrefixAntwort = childElement.firstChildElement("SubjektPrefixAntwort").isNull() ? "" : childElement.firstChildElement("SubjektPrefixAntwort").text();
        QString imageFilenameFrage = childElement.firstChildElement("ImagefileFrage").isNull() ? "" : childElement.firstChildElement("ImagefileFrage").text();
        QString imageFilenameAntwort = childElement.firstChildElement("ImagefileAntwort").isNull() ? "" : childElement.firstChildElement("ImagefileAntwort").text();
        QString infoUrlFrage = childElement.firstChildElement("InfoURLFrage").isNull() ? "" : childElement.firstChildElement("InfoURLFrage").text();
        QString infoUrlAntwort = childElement.firstChildElement("InfoURLAntwort").isNull() ? "" : childElement.firstChildElement("InfoURLAntwort").text();
        QString imageFrageAuthor = childElement.firstChildElement("ImageFrageAuthor").isNull() ? "" : childElement.firstChildElement("ImageFrageAuthor").text();
        QString imageFrageLizenz = childElement.firstChildElement("ImageFrageLizenz").isNull() ? "" : childElement.firstChildElement("ImageFrageLizenz").text();
        QString imageAntwortAuthor = childElement.firstChildElement("ImageAntwortAuthor").isNull() ? "" : childElement.firstChildElement("ImageAntwortAuthor").text();
        QString imageAntwortLizenz = childElement.firstChildElement("ImageAntwortLizenz").isNull() ? "" : childElement.firstChildElement("ImageAntwortLizenz").text();
        QString wikiPageFraVers = childElement.firstChildElement("WikiPageFraVers").isNull() ? "" : childElement.firstChildElement("WikiPageFraVers").text();
        QString wikiPageAntVers = childElement.firstChildElement("WikiPageAntVers").isNull() ? "" : childElement.firstChildElement("WikiPageAntVers").text();


        bool recognizedState = false; // Adjust based on your needs
        QString excludeAereaStr;
        bool isReverse = (exercizeType == "MainÜbungsliste") ? false : true;
        if (!isReverse) {
            excludeAereaStr = childElement.firstChildElement("ExcludeAereaFra").isNull() ? "" : childElement.firstChildElement("ExcludeAereaFra").text();
        } else {
            excludeAereaStr = childElement.firstChildElement("ExcludeAereaAnt").isNull() ? "" : childElement.firstChildElement("ExcludeAereaAnt").text();
        }
        QRect excludeAerea;
        if (!excludeAereaStr.isEmpty()) {
            QStringList coords = excludeAereaStr.split(",");
            if (coords.size() == 4) {
                int x = coords[0].toInt();
                int y = coords[1].toInt();
                int width = coords[2].toInt();
                int height = coords[3].toInt();
                excludeAerea = QRect(x, y, width, height);
            }
        }


        EntryDesc* entry = new EntryDesc(
            (!isReverse)?frageSubjekt:antwortSubjekt,
            (!isReverse)?antwortSubjekt:frageSubjekt,
            (!isReverse)?subjectPrefixFrage:subjectPrefixAntwort,
            (!isReverse)?subjectPrefixAntwort:subjectPrefixFrage,
            (!isReverse)?imageFilenameFrage:imageFilenameAntwort,
            (!isReverse)?imageFilenameAntwort:imageFilenameFrage,
            (!isReverse)?infoUrlFrage:infoUrlAntwort,
            (!isReverse)?infoUrlAntwort:infoUrlFrage,
            (!isReverse)?imageFrageAuthor:imageAntwortAuthor,
            (!isReverse)?imageAntwortAuthor:imageFrageAuthor,
            (!isReverse)?imageFrageLizenz:imageAntwortLizenz,
            (!isReverse)?imageAntwortLizenz:imageFrageLizenz,
            (!isReverse)?wikiPageFraVers:wikiPageAntVers,
            (!isReverse)?wikiPageAntVers:wikiPageFraVers,
            recognizedState,
            idxPackage,
            isReverse,
            excludeAerea
            );

        listEntries.append(entry);
        childElement = childElement.nextSiblingElement();
    }

    return listEntries;
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
