#ifndef LICENCEINFO_H
#define LICENCEINFO_H

#include <QString>
#include <QObject>
#include <QMetaType>

class LicenceInfo : public QObject {
    Q_GADGET
    Q_PROPERTY(QString imageFrageAuthor READ imageFrageAuthor CONSTANT)
    Q_PROPERTY(QString imageFrageLizenz READ imageFrageLizenz CONSTANT)
    Q_PROPERTY(QString imageAntwortAuthor READ imageAntwortAuthor CONSTANT)
    Q_PROPERTY(QString imageAntwortLizenz READ imageAntwortLizenz CONSTANT)
    Q_PROPERTY(QString imageFrageBildDescription READ imageFrageBildDescription CONSTANT)
    Q_PROPERTY(QString imageAntwortBildDescription READ imageAntwortBildDescription CONSTANT)
    Q_PROPERTY(QString imageFrageUrl READ imageFrageUrl CONSTANT)
    Q_PROPERTY(QString imageAntwortUrl READ imageAntwortUrl CONSTANT)
    Q_PROPERTY(QString infoURLFrage READ infoURLFrage CONSTANT)
    Q_PROPERTY(QString infoURLAntwort READ infoURLAntwort CONSTANT)

public:
    explicit LicenceInfo(QObject* parent = nullptr) : QObject(parent) {}

    // Copy constructor
    LicenceInfo(const LicenceInfo& other)
        : QObject(nullptr),
        mImageFrageAuthor(other.mImageFrageAuthor),
        mImageFrageLizenz(other.mImageFrageLizenz),
        mImageAntwortAuthor(other.mImageAntwortAuthor),
        mImageAntwortLizenz(other.mImageAntwortLizenz),
        mImageFrageBildDescription(other.mImageFrageBildDescription),
        mImageAntwortBildDescription(other.mImageAntwortBildDescription),
        mImageFrageUrl(other.mImageFrageUrl),
        mImageAntwortUrl(other.mImageAntwortUrl),
        mInfoURLFrage(other.mInfoURLFrage),
        mInfoURLAntwort(other.mInfoURLAntwort) {}

    // Assignment operator
    LicenceInfo& operator=(const LicenceInfo& other) {
        if (this != &other) {
            mImageFrageAuthor = other.mImageFrageAuthor;
            mImageFrageLizenz = other.mImageFrageLizenz;
            mImageAntwortAuthor = other.mImageAntwortAuthor;
            mImageAntwortLizenz = other.mImageAntwortLizenz;
            mImageFrageBildDescription = other.mImageFrageBildDescription;
            mImageAntwortBildDescription = other.mImageAntwortBildDescription;
            mImageFrageUrl = other.mImageFrageUrl;
            mImageAntwortUrl = other.mImageAntwortUrl;
            mInfoURLFrage = other.mInfoURLFrage;
            mInfoURLAntwort = other.mInfoURLAntwort;
        }
        return *this;
    }

    // Getter
    QString imageFrageAuthor() const { return mImageFrageAuthor; }
    QString imageFrageLizenz() const { return mImageFrageLizenz; }
    QString imageAntwortAuthor() const { return mImageAntwortAuthor; }
    QString imageAntwortLizenz() const { return mImageAntwortLizenz; }
    QString imageFrageBildDescription() const { return mImageFrageBildDescription; }
    QString imageAntwortBildDescription() const { return mImageAntwortBildDescription; }
    QString imageFrageUrl() const { return mImageFrageUrl; }
    QString imageAntwortUrl() const { return mImageAntwortUrl; }
    QString infoURLFrage() const { return mInfoURLFrage; }
    QString infoURLAntwort() const { return mInfoURLAntwort; }

    // Setter
    void setImageFrageAuthor(const QString& author) {
        if (mImageFrageAuthor != author) {
            mImageFrageAuthor = author;
        }
    }

    void setImageFrageLizenz(const QString& lizenz) {
        if (mImageFrageLizenz != lizenz) {
            mImageFrageLizenz = lizenz;
        }
    }

    void setImageAntwortAuthor(const QString& author) {
        if (mImageAntwortAuthor != author) {
            mImageAntwortAuthor = author;
        }
    }

    void setImageAntwortLizenz(const QString& lizenz) {
        if (mImageAntwortLizenz != lizenz) {
            mImageAntwortLizenz = lizenz;
        }
    }

    void setImageFrageBildDescription(const QString& description) {
        if (mImageFrageBildDescription != description) {
            mImageFrageBildDescription = description;
        }
    }

    void setImageAntwortBildDescription(const QString& description) {
        if (mImageAntwortBildDescription != description) {
            mImageAntwortBildDescription = description;
        }
    }

    void setImageFrageUrl(const QString& url) {
        if (mImageFrageUrl != url) {
            mImageFrageUrl = url;
        }
    }

    void setImageAntwortUrl(const QString& url) {
        if (mImageAntwortUrl != url) {
            mImageAntwortUrl = url;
        }
    }

    void setInfoURLFrage(const QString& url) {
        if (mInfoURLFrage != url) {
            mInfoURLFrage = url;
        }
    }

    void setInfoURLAntwort(const QString& url) {
        if (mInfoURLAntwort != url) {
            mInfoURLAntwort = url;
        }
    }

private:
    QString mImageFrageAuthor;
    QString mImageFrageLizenz;
    QString mImageAntwortAuthor;
    QString mImageAntwortLizenz;
    QString mImageFrageBildDescription;
    QString mImageAntwortBildDescription;
    QString mImageFrageUrl;
    QString mImageAntwortUrl;
    QString mInfoURLFrage;
    QString mInfoURLAntwort;
};

Q_DECLARE_METATYPE(LicenceInfo)

#endif // LICENCEINFO_H
