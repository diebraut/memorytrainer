#ifndef NETWORKCHECKER_H
#define NETWORKCHECKER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>

class NetworkChecker : public QObject
{
    Q_OBJECT
public:
    explicit NetworkChecker(QObject *parent = nullptr);

    Q_INVOKABLE void checkInternetConnection();
    Q_INVOKABLE void checkWikipediaSummary(const QString &pageUrl);

signals:
    void networkStatusChanged(bool isOnline);
    void wikipediaSummaryChecked(const QString &pageUrl, bool summaryAvailable, const QString &title, const QString &extract);

private slots:
    void onNetworkReply(QNetworkReply *reply);

private:
    bool buildWikipediaSummaryUrl(const QString &pageUrl, QUrl &summaryUrl) const;

private:
    QNetworkAccessManager m_networkManager;
};

#endif // NETWORKCHECKER_H
