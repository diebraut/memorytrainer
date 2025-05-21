#ifndef EXERCICE_H
#define EXERCICE_H

#include <QString>
#include <QRect>
#include <QList>
#include <QSharedPointer>

class ExcludeAerea; // Forward declaration

class Exercice {
public:
    // Konstruktor
    Exercice(int nummer, const QString &frageSubjekt, const QString &antwortSubjekt,
           const QString &subjektPrefixFrage, const QString &subjektPrefixAntwort,
           const QString &imageFilenameFrage, const QString &imageFilenameAntwort,
           const QString &infoURLFrage, const QString &infoURLAntwort,
           const QString &imageFrageAuthor, const QString &imageFrageLizenz,
           const QString &imageAntwortAuthor, const QString &imageAntwortLizenz,
           const QString &wikiPageFraVers, const QString &wikiPageAntVers,
           const QString &excludeAereaFra, const QString &excludeAereaAnt,
           const QString &imageFrageBildDescription, const QString &imageAntwortBildDescription,
           const QString &imageFrageUrl, const QString &imageAntwortUrl);

    // Getter-Methoden
    int getNummer() const;
    QString getFrageSubjekt() const;
    QString getAntwortSubjekt() const;
    QString getSubjektPrefixFrage() const;
    QString getSubjektPrefixAntwort() const;
    QString getImageFilenameFrage() const;
    QString getImageFilenameAntwort() const;
    QString getInfoURLFrage() const;
    QString getInfoURLAntwort() const;
    QString getImageFrageAuthor() const;
    QString getImageFrageLizenz() const;
    QString getImageAntwortAuthor() const;
    QString getImageAntwortLizenz() const;
    QString getWikiPageFraVers() const;
    QString getWikiPageAntVers() const;
    QString getExcludeAereaFra() const;
    QString getExcludeAereaAnt() const;
    QString getImageFrageBildDescription() const;
    QString getImageAntwortBildDescription() const;
    QString getImageFrageUrl() const;
    QString getImageAntwortUrl() const;

    // Setter-Methoden
    void setNummer(int nummer);
    void setFrageSubjekt(const QString &frageSubjekt);
    void setAntwortSubjekt(const QString &antwortSubjekt);
    void setSubjektPrefixFrage(const QString &subjektPrefixFrage);
    void setSubjektPrefixAntwort(const QString &subjektPrefixAntwort);
    void setImageFilenameFrage(const QString &imageFilenameFrage);
    void setImageFilenameAntwort(const QString &imageFilenameAntwort);
    void setInfoURLFrage(const QString &infoURLFrage);
    void setInfoURLAntwort(const QString &infoURLAntwort);
    void setImageFrageAuthor(const QString &imageFrageAuthor);
    void setImageFrageLizenz(const QString &imageFrageLizenz);
    void setImageAntwortAuthor(const QString &imageAntwortAuthor);
    void setImageAntwortLizenz(const QString &imageAntwortLizenz);
    void setWikiPageFraVers(const QString &wikiPageFraVers);
    void setWikiPageAntVers(const QString &wikiPageAntVers);
    void setExcludeAereaFra(const QString &excludeAereaFra);
    void setExcludeAereaAnt(const QString &excludeAereaAnt);
    void setImageFrageBildDescription(const QString &imageFrageBildDescription);
    void setImageAntwortBildDescription(const QString &imageAntwortBildDescription);
    void setImageFrageUrl(const QString &imageFrageUrl);
    void setImageAntwortUrl(const QString &imageAntwortUrl);

private:
    int nummer_;
    QString frageSubjekt_;
    QString antwortSubjekt_;
    QString subjektPrefixFrage_;
    QString subjektPrefixAntwort_;
    QString imageFilenameFrage_;
    QString imageFilenameAntwort_;
    QString infoURLFrage_;
    QString infoURLAntwort_;
    QString imageFrageAuthor_;
    QString imageFrageLizenz_;
    QString imageAntwortAuthor_;
    QString imageAntwortLizenz_;
    QString wikiPageFraVers_;
    QString wikiPageAntVers_;
    QString excludeAereaFra_;
    QString excludeAereaAnt_;
    QString imageFrageBildDescription_;
    QString imageAntwortBildDescription_;
    QString imageFrageUrl_;
    QString imageAntwortUrl_;
};


#endif // EXERCICE_H
